Convar = {}

local queueEnabled, queueActive, queueClosed = true, false, false
local resourceName = GetCurrentResourceName()
local MAX_PLAYERS = tonumber(GetConvar("sv_maxclients", "32"))

GlobalState["MaxPlayers"] = MAX_PLAYERS

local playerJoining = false
local privPlayerJoining = false

local _dbReadyTime = 0
local _dbReady = false

local APIWorking = false

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-queue')
    Config.Server = exports['pulsar-core']:ConfigGetServer()
    Config.Groups = exports['pulsar-core']:ConfigGetGroups()
    queueActive = true
    exports["pulsar-chat"]:RegisterAdminCommand("queue", function(source, args, rawCommand)
      local message = "Queue List"

      for k, v in ipairs(QUEUE_PLAYERS_SORTED) do
        local pData = QUEUE_PLAYERS_DATA[v]
        if pData then
          message = message .. string.format("<br>#%d - %s (%s)", k, pData.Name, v)
        end
      end
      exports["pulsar-chat"]:SendSystemSingle(source, message)
    end, {
      help = "Print the Queue",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("yeetqueue", function(source, args, rawCommand)
      for k, v in pairs(QUEUE_PLAYERS) do
        if QUEUE_PLAYERS_DATA[k] then
          QUEUE_PLAYERS_DATA[k].Deferrals.done("Deleted")
        end

        exports['pulsar-queue']:Pop(k, true)
      end
      exports["pulsar-chat"]:SendSystemSingle(source, "Done")
    end, {
      help = "Yeet the Queue [DANGER!]",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("maxplayers", function(source, args, rawCommand)
      local max = tonumber(args[1])
      if max and max > 0 and max < 500 then
        MAX_PLAYERS = max
        GlobalState["MaxPlayers"] = MAX_PLAYERS
        SetConvarServerInfo("sv_maxclients", MAX_PLAYERS)
        exports["pulsar-chat"]:SendSystemSingle(source, "Max Players Set")
      end
    end, {
      params = {
        {
          name = "Max Player Count",
          help = "Number",
        },
      },
      help = "Set Max Players",
    })

    exports["pulsar-chat"]:RegisterStaffCommand("tempprio", function(source, args, rawCommand)
      local ident = args[1]
      local prio = tonumber(args[2])

      if ident and prio and prio > 0 and prio <= 200 then
        exports['pulsar-queue']:AddTempPriority(ident, prio)
        exports["pulsar-chat"]:SendSystemSingle(source, "Priority Added")
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Error")
      end
    end, {
      params = {
        {
          name = "Player Identifier",
          help = "Player's FiveM Identifier (License)",
        },
        {
          name = "Priority",
          help = "Number (1-200)",
        },
      },
      help = "Add Temporary Priority",
    })

    _dbReadyTime = GetGameTimer()
    _dbReady = true
  end
end)

QUEUE_PLAYERS_DATA = {}

QUEUE_PLAYERS = {}
QUEUE_PLAYERS_SORTED = {}

CURRENT_CONNECTORS = {}
CURRENT_CONNECTORS_COUNT = 0

QUEUE_CRASH_PRIORITY = {}
QUEUE_TEMP_PRIORITY = {}

CONNECTING_PLAYERS_DATA = {}

QUEUE_PLAYER_HISTORY = {} -- For remembering queue positions

local function SortQueue()
  local sorted = getKeysSortedByValue(QUEUE_PLAYERS, function(a, b)
    if a.priority ~= b.priority then
      return a.priority > b.priority
    end

    return a.joinedAt < b.joinedAt
  end)

  QUEUE_PLAYERS_SORTED = sorted
end

local function PopFromQueue(identifier, disconnect)
  if QUEUE_PLAYERS[identifier] then
    QUEUE_PLAYERS[identifier] = nil
    local ply = QUEUE_PLAYERS_DATA[identifier]
    if ply and disconnect then
      Log(
        string.format(
          Config.Strings.Disconnected,
          ply.Name,
          ply.SteamName or ply.AccountID,
          ply.Identifier
        )
      )
    end

    QUEUE_PLAYERS_DATA[identifier] = nil
    SortQueue()
  end
end

exports('HandleConnection', function(source, identifier, deferrals)
  if not IsSteamRunning(source) then
    deferrals.done(Config.Strings.SteamRequired)
    return CancelEvent()
  end

  local steamName = GetPlayerSteamName(source)
  if not steamName then
    deferrals.done(Config.Strings.SteamNameError)
    return CancelEvent()
  end

  if GlobalState.IsProduction then
    while GetGameTimer() < (_dbReadyTime + (Config.Settings.QueueDelay * (1000 * 60))) do
      local min = math.floor(
        (
          (math.floor(_dbReadyTime / 1000) + (Config.Settings.QueueDelay * 60))
          - math.floor(GetGameTimer() / 1000)
        ) / 60
      )
      local secs = math.floor(
        (
          (math.floor(_dbReadyTime / 1000) + (Config.Settings.QueueDelay * 60))
          - math.floor(GetGameTimer() / 1000)
        ) - (min * 60)
      )

      if min <= 0 then
        deferrals.update(
          string.format(Config.Strings.WaitingSeconds, secs, secs ~= 1 and "Seconds" or "Second")
        )
      else
        deferrals.update(
          string.format(
            Config.Strings.Waiting,
            min,
            min ~= 1 and "Minutes" or "Minute",
            secs,
            secs ~= 1 and "Seconds" or "Second"
          )
        )
      end
      Wait(100)
    end
  end

  while not queueActive do
    Wait(100)
  end

  PopFromQueue(identifier)

  local ply = PlayerClass(identifier, source, deferrals, steamName)

  if not ply:IsWhitelisted() then
    if APIWorking and WebAPI then
      deferrals.presentCard(Config.Cards.NotWhitelisted, function(data, rawData)
        if data and data.linking then
          deferrals.presentCard(Config.Cards.AccountLinking, function(linkData, linkRawData)
            if linkData and linkData.code and not linkData.cancel then
              -- Attempt to link account
              local success = WebAPI:LinkAccount(identifier, linkData.code)
              if success then
                deferrals.done(Config.Strings.WebLinkComplete)
              else
                deferrals.done(Config.Strings.WebLinkError)
              end
            else
              deferrals.done(Config.Strings.NotWhitelisted)
            end
          end)
        else
          deferrals.done(Config.Strings.NotWhitelisted)
        end
      end)
    else
      deferrals.done(Config.Strings.NotWhitelisted)
    end
    return CancelEvent()
  end

  -- Banning Handled by TxAdmin

  local time = GetGameTimer()
  local joinedAt = GetGameTimer()
  local useSavedPos = false
  if QUEUE_PLAYER_HISTORY[identifier] and QUEUE_PLAYER_HISTORY[identifier].expires > GetGameTimer() then
    joinedAt = QUEUE_PLAYER_HISTORY[identifier].joinedAt
    useSavedPos = true
  end

  QUEUE_PLAYERS_DATA[identifier] = ply
  QUEUE_PLAYERS[identifier] = {
    priority = ply:GetPriority(),
    joinedAt = joinedAt,
    time = time,
  }
  QUEUE_PLAYER_HISTORY[identifier] = {
    joinedAt = joinedAt,
    expires = GetGameTimer() + (Config.Settings.SavePosition * 60000),
  }

  SortQueue()
  Wait(1000)

  local pos, total = exports['pulsar-queue']:GetPosition(identifier)
  Log(
    string.format(
      Config.Strings.Add,
      ply.Name,
      ply.SteamName or ply.AccountID,
      ply.Identifier,
      pos,
      total,
      GetNumPlayerIndices(),
      ply.Priority
    )
  )

  while GetPlayerEndpoint(source) and not queueClosed and (
      (not exports['pulsar-queue']:Check(identifier))
      or (GetNumPlayerIndices() == MAX_PLAYERS)
      or ((GetNumPlayerIndices() + CURRENT_CONNECTORS_COUNT + 1) > MAX_PLAYERS)
      or ((GetNumPlayerIndices() + CURRENT_CONNECTORS_COUNT) >= MAX_PLAYERS)
    ) do
    ply.Timer:Tick()
    local pos, total = exports['pulsar-queue']:GetPosition(identifier)
    local msg = ""
    if ply.Priority > 0 then
      msg = "\n\nTotal Priority of " .. ply.Priority .. ": " .. ply.Message
    end

    if useSavedPos then
      msg = msg .. "\n\n🥳 You Were Returned to Your Saved Queue Position"
    end

    if pos == nil or total == nil then
      print("Someone In Queue nil/nil ID:", ply.Identifier, "Data: ", identifier, pos, total,
        json.encode(QUEUE_PLAYERS_DATA[identifier]), json.encode(QUEUE_PLAYERS[identifier]))
    end

    ply.Deferrals.update(string.format(Config.Strings.Queued, pos, total, ply.Timer:Output(), msg))

    if QUEUE_PLAYER_HISTORY[identifier] then
      QUEUE_PLAYER_HISTORY[identifier].expires = GetGameTimer() + (Config.Settings.SavePosition * 60000)
    end

    Wait(5000)
  end

  -- Can join the server now :)

  if queueClosed then
    deferrals.done(Config.Strings.PendingRestart)
    PopFromQueue(identifier, true)
    return CancelEvent()
  end

  if GetPlayerEndpoint(source) then
    CURRENT_CONNECTORS[identifier] = {
      source = source
    }
    CURRENT_CONNECTORS_COUNT += 1

    ply.Deferrals.update(Config.Strings.Joining)
    ply.Deferrals.handover({ -- This is where window.nuiHandoverData is set for loading screen, should also be able to send character data through this
      name = ply.Name,
      priority = ply.Priority,
      priorityMessage = ply.Message,
    })
    Wait(500)
    ply.Deferrals.done()

    Log(
      string.format(
        Config.Strings.Joined,
        ply.Name,
        ply.SteamName or ply.AccountID,
        ply.Identifier
      )
    )

    CONNECTING_PLAYERS_DATA[identifier] = ply
    PopFromQueue(identifier)
  else
    if QUEUE_PLAYERS[identifier] and QUEUE_PLAYERS[identifier].time == time then
      PopFromQueue(identifier, true)
    end
  end
end)

exports('Sort', function()
  SortQueue()
end)

exports('Pop', function(identifier, disconnect)
  PopFromQueue(identifier, disconnect)
end)

exports('Check', function(identifier)
  if QUEUE_PLAYERS_SORTED[1] == identifier then
    return true
  end
  return false
end)

exports('GetCount', function()
  local count = 0
  for k, v in pairs(QUEUE_PLAYERS) do
    count += 1
  end
  return count
end)

exports('GetPosition', function(identifier)
  local count = 0
  local found = nil
  for k, v in ipairs(QUEUE_PLAYERS_SORTED) do
    count += 1

    if v == identifier then
      found = k
    end
  end

  return found, count
end)

exports('CheckGhosts', function()
  for k, v in pairs(CURRENT_CONNECTORS) do
    if v and not GetPlayerEndpoint(v.source) then
      CURRENT_CONNECTORS[k] = nil
    end
  end

  local count = 0
  for k, v in pairs(CURRENT_CONNECTORS) do
    if v then
      count += 1
    end
  end

  CURRENT_CONNECTORS_COUNT = count
end)

exports('AddCrashPriority', function(identifier, message)
  -- for _, v in ipairs(Config.ExcludeDrop) do
  -- 	if string.find(message, v) then
  -- 		return
  -- 	end
  -- end

  local ply = QUEUE_PLAYERS_DATA[identifier]
  if ply then
    Log(
      string.format(
        Config.Strings.Crash,
        ply.Name,
        ply.SteamName or ply.AccountID,
        ply.Identifier
      )
    )
  end

  table.insert(QUEUE_CRASH_PRIORITY, {
    Identifier = identifier,
    Grace = os.time() + (60 * 20),
  })
end)

exports('HasCrashPriority', function(identifier)
  for k, v in ipairs(QUEUE_CRASH_PRIORITY) do
    if v.Identifier == identifier and os.time() < v.Grace then
      return true
    end
  end
end)

exports('AddTempPriority', function(identifier, prio)
  exports['pulsar-queue']:RemoveTempPriority(identifier)

  table.insert(QUEUE_TEMP_PRIORITY, {
    Identifier = identifier,
    Priority = prio,
  })
end)

exports('RemoveTempPriority', function(identifier)
  for k, v in ipairs(QUEUE_TEMP_PRIORITY) do
    if v.Identifier == identifier then
      table.remove(QUEUE_TEMP_PRIORITY, k)
    end
  end
end)

exports('HasTempPriority', function(identifier)
  for k, v in ipairs(QUEUE_TEMP_PRIORITY) do
    if v.Identifier == identifier then
      return v
    end
  end
end)

exports('CloseAndDrop', function()
  queueClosed = true

  for k, v in pairs(QUEUE_PLAYERS) do
    if QUEUE_PLAYERS_DATA[k] then
      QUEUE_PLAYERS_DATA[k].Deferrals.done("Deleted")
    end

    PopFromQueue(k, true)
  end
end)

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
  local _src = source

  deferrals.defer()
  Wait(1)
  deferrals.update(Config.Strings.Init)

  if not _dbReady or GlobalState.IsProduction == nil then
    deferrals.done(Config.Strings.NotReady)
    return CancelEvent()
  end

  if queueClosed then
    deferrals.done(Config.Strings.PendingRestart)
    return CancelEvent()
  end

  local identifier = GetPlayerLicense(_src)
  if not identifier or identifier == "" then
    deferrals.done(Config.Strings.NoIdentifier)
    return CancelEvent()
  end

  exports['pulsar-queue']:HandleConnection(_src, identifier, deferrals)
end)

AddEventHandler("playerDropped", function(message)
  local src = source

  local license = GetPlayerLicense(src)
  if license then
    if CURRENT_CONNECTORS[license] then
      if CURRENT_CONNECTORS_COUNT >= 1 then
        CURRENT_CONNECTORS_COUNT -= 1
      end

      CURRENT_CONNECTORS[license] = nil
    end

    exports['pulsar-queue']:AddCrashPriority(license, message)
    if QUEUE_PLAYERS[license] then
      print("lol someone just got playerDropped while in queue somehow", license, message)
    end
    -- PopFromQueue(license, true)
  end
end)

RegisterServerEvent("Core:Server:SessionStarted")
AddEventHandler("Core:Server:SessionStarted", function()
  local src = source
  local license = GetPlayerLicense(src)
  if license then
    if CURRENT_CONNECTORS[license] then
      if CURRENT_CONNECTORS_COUNT >= 1 then
        CURRENT_CONNECTORS_COUNT -= 1
      end

      -- print("Remove Joiner", CURRENT_CONNECTORS_COUNT)

      CURRENT_CONNECTORS[license] = nil
    end

    local ply = CONNECTING_PLAYERS_DATA[license]
    if ply then
      TriggerClientEvent("Queue:Client:SessionActive", src)
      TriggerEvent("Queue:Server:SessionActive", src, {
        Groups = ply.Groups,
        Name = ply.Name,
        Discord = ply.Discord,
        Mention = ply.Mention,
        AccountID = ply.SteamName or ply.AccountID,
        Avatar = ply.Avatar,
        Identifier = ply.Identifier,
        Tokens = ply.Tokens,
      })

      CONNECTING_PLAYERS_DATA[license] = nil
      exports['pulsar-queue']:RemoveTempPriority(license)
      return
    end
  end

  DropPlayer(src, Config.Strings.NoIdentifier)
end)

CreateThread(function()
  while not queueActive do
    Wait(1000)
  end

  if APIWorking and WebAPI then
    queueEnabled = true
    exports["pulsar-core"]:LoggerInfo("Queue", "Queue enabled with WebAPI support")
  else
    queueEnabled = true
    exports["pulsar-core"]:LoggerInfo("Queue", "Queue enabled without WebAPI - account linking disabled")
  end

  while GetResourceState("hardcap") ~= "stopped" do
    local state = GetResourceState("hardcap")
    if state == "missing" then
      break
    end

    if state == "started" then
      StopResource("hardcap")
      break
    end

    Wait(5000)
  end

  Wait(10000)
end)

CreateThread(function()
  while true do
    GlobalState["QueueCount"] = exports['pulsar-queue']:GetCount()

    exports['pulsar-queue']:CheckGhosts()

    Wait(20000)
  end
end)

RegisterCommand("print_connect_count", function()
  print("CC", CURRENT_CONNECTORS_COUNT)
end, true)

RegisterCommand("print_queue", function()
  print("CC", json.encode(QUEUE_PLAYERS, { indent = true }))
end, true)
