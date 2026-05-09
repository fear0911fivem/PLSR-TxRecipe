AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterMiddleware()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-chat')
    exports["pulsar-chat"]:RegisterCommand("me", function(source, args, rawCommand)
      if #args > 0 then
        local message = table.concat(args, " ")
        TriggerClientEvent("Chat:Client:ReceiveMe", -1, source, GetGameTimer(), message)
      else
        exports["pulsar-chat"]:SendServerSingle(source, "Invalid Number Of Arguments")
      end
    end, {
      help = "Let People Know What You are Doing",
      params = {},
    }, -1)

    exports["pulsar-chat"]:RegisterStaffCommand("clearall", function(source, args, rawCommand)
      exports["pulsar-chat"]:ClearAll()
    end, {
      help = "[Staff] Clear chat for everyone",
    }, 0)
  end
end)

function RegisterMiddleware()
  exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
    exports["pulsar-chat"]:RefreshCommands(source)
  end, 3)
end

AddEventHandler("Job:Server:DutyRemove", function(dutyData, source)
  exports["pulsar-chat"]:RefreshCommands(source)
end)

AddEventHandler("Job:Server:DutyAdd", function(dutyData, source)
  exports["pulsar-chat"]:RefreshCommands(source)
end)

exports("RefreshCommands", function(source)
  local player = exports['pulsar-core']:FetchSource(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil and player ~= nil then
    local myDuty = Player(source).state.onDuty
    TriggerClientEvent("chat:resetSuggestions", source)
    local allowedCommands = {}
    local removeCommands = {}

    for k, command in pairs(commandSuggestions) do
      local commandString = ("/" .. k)
      --TriggerClientEvent('chat:addSuggestion', source, commandString, '')
      if IsPlayerAceAllowed(source, ("command.%s"):format(k)) then
        if commands[k] ~= nil then
          if commands[k].admin then
            if player.Permissions:IsAdmin() then
              table.insert(allowedCommands, {
                name = commandString,
                help = command.help,
                params = command.params,
              })
            else
              table.insert(removeCommands, commandString)
            end
          elseif commands[k].staff then
            if player.Permissions:IsStaff() then
              table.insert(allowedCommands, {
                name = commandString,
                help = command.help,
                params = command.params,
              })
            else
              table.insert(removeCommands, commandString)
            end
          elseif commands[k].job ~= nil then
            local canUse = false
            for k2, v2 in pairs(commands[k].job) do
              if
                  v2.Id == nil
                  or (
                    myDuty
                    and myDuty == v2.Id
                    and exports['pulsar-jobs']:HasJob(
                      source,
                      v2.Id,
                      v2.Workplace or false,
                      v2.Grade or false,
                      v2.Level or false
                    )
                  )
              then
                canUse = true
              end
            end

            if canUse then
              table.insert(allowedCommands, {
                name = commandString,
                help = command.help,
                params = command.params,
              })
            else
              table.insert(removeCommands, commandString)
            end
          else
            table.insert(allowedCommands, {
              name = commandString,
              help = command.help,
              params = command.params,
            })
          end
        else
          table.insert(allowedCommands, {
            name = commandString,
            help = "",
          })
        end
      end
    end

    TriggerClientEvent("chat:addSuggestions", source, allowedCommands)
    TriggerClientEvent("chat:removeSuggestions", source, removeCommands)
  end
end)

exports("ClearAll", function()
  TriggerClientEvent("chat:clearChat", -1)
end)

exports("SendOOC", function(source, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    TriggerClientEvent("chat:addMessage", -1, {
      time = os.time(),
      type = "ooc",
      message = message,
      author = {
        First = char:GetData("First"),
        Last = char:GetData("Last"),
        SID = char:GetData("SID"),
      },
    })
  end
end)

exports("SendServerAll", function(message)
  TriggerClientEvent("chat:addMessage", -1, {
    time = os.time(),
    type = "server",
    message = message,
  })
end)

exports("SendServerSingle", function(source, message)
  TriggerClientEvent("chat:addMessage", source, {
    time = os.time(),
    type = "server",
    message = message,
  })
end)

exports("SendBroadcastAll", function(author, message)
  TriggerClientEvent("chat:addMessage", -1, {
    time = os.time(),
    type = "broadcast",
    message = message,
  })
end)

exports("SendSystemAll", function(message)
  TriggerClientEvent("chat:addMessage", -1, {
    time = os.time(),
    type = "system",
    message = message,
  })
end)

exports("SendSystemSingle", function(source, message)
  TriggerClientEvent("chat:addMessage", source, {
    time = os.time(),
    type = "system",
    message = message,
  })
end)

exports("SendSystemBroadcast", function(message)
  TriggerClientEvent("chat:addMessage", -1, {
    time = os.time(),
    type = "broadcast",
    message = message,
  })
end)

exports("SendEmergency", function(source, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  TriggerEvent("EmergencyAlerts:Server:ServerDoPredefined", source, "call911", {
    details = string.format("%s | %s", char:GetData("SID"), char:GetData("Phone")),
  })

  for k, v in ipairs(GetPlayers()) do
    local duty = Player(v).state.onDuty

    if tonumber(v) == source or (duty == "police" or duty == "prison" or duty == "ems") then
      TriggerClientEvent("chat:addMessage", v, {
        time = os.time(),
        type = "911",
        message = message,
        author = {
          First = char:GetData("First"),
          Last = char:GetData("Last"),
          Phone = char:GetData("Phone"),
          SID = char:GetData("SID"),
        },
      })
    end
  end
end)

exports("SendEmergencyAnonymous", function(source, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)

  TriggerEvent("EmergencyAlerts:Server:ServerDoPredefined", source, "call911anon")
  for k, v in ipairs(GetPlayers()) do
    local duty = Player(v).state.onDuty
    if tonumber(v) == source or (duty == "police" or duty == "prison" or duty == "ems") then
      TriggerClientEvent("chat:addMessage", v, {
        time = os.time(),
        type = "911",
        message = message,
        author = {
          Anonymous = true,
        },
      })
    end
  end
end)

exports("SendEmergencyRespond", function(source, target, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  local tChar = exports['pulsar-characters']:FetchCharacterSource(target)
  if tChar ~= nil then
    local name = string.format("%s %s", char:GetData("First"), char:GetData("Last"))
    local str = string.format("%s -> %s", name, tChar:GetData("SID"))

    for k, v in ipairs(GetPlayers()) do
      local duty = Player(v).state.onDuty
      if tonumber(v) == target or (duty == "police" or duty == "prison" or duty == "ems") then
        TriggerClientEvent("chat:addMessage", v, {
          time = os.time(),
          type = "911",
          message = message,
          author = {
            First = char:GetData("First"),
            Last = char:GetData("Last"),
            Phone = char:GetData("Phone"),
            SID = char:GetData("SID"),
            Reply = tChar:GetData("SID"),
          },
        })
      end
    end
  end
end)

exports("SendNonEmergency", function(source, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    TriggerEvent("EmergencyAlerts:Server:ServerDoPredefined", source, "call311", {
      details = string.format("%s | %s", char:GetData("SID"), char:GetData("Phone")),
    })

    local name = string.format("%s %s", char:GetData("First"), char:GetData("Last"))
    local str = string.format("(%s) %s | %s", char:GetData("SID"), name, char:GetData("Phone"))
    for k, v in ipairs(GetPlayers()) do
      local duty = Player(v).state.onDuty
      if tonumber(v) == source or (duty == "police" or duty == "ems" or duty == "prison") then
        TriggerClientEvent("chat:addMessage", v, {
          time = os.time(),
          type = "311",
          message = message,
          author = {
            First = char:GetData("First"),
            Last = char:GetData("Last"),
            Phone = char:GetData("Phone"),
            SID = char:GetData("SID"),
          },
        })
      end
    end
  end
end)

exports("SendNonEmergencyAnonymous", function(source, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    TriggerEvent("EmergencyAlerts:Server:ServerDoPredefined", source, "call311anon")
    for k, v in ipairs(GetPlayers()) do
      local duty = Player(v).state.onDuty
      if tonumber(v) == source or (duty == "police" or duty == "ems" or duty == "prison") then
        TriggerClientEvent("chat:addMessage", v, {
          time = os.time(),
          type = "311",
          message = message,
          author = {
            Anonymous = true,
          },
        })
      end
    end
  end
end)

exports("SendNonEmergencyRespond", function(source, target, message)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  local tChar = exports['pulsar-characters']:FetchCharacterSource(target)
  if tChar ~= nil then
    local name = string.format("%s %s", char:GetData("First"), char:GetData("Last"))
    local str = string.format("%s -> %s", name, tChar:GetData("SID"))
    for k, v in ipairs(GetPlayers()) do
      local duty = Player(v).state.onDuty
      if tonumber(v) == target or (duty == "police" or duty == "ems" or duty == "prison") then
        TriggerClientEvent("chat:addMessage", v, {
          time = os.time(),
          type = "311",
          message = message,
          author = {
            First = char:GetData("First"),
            Last = char:GetData("Last"),
            Phone = char:GetData("Phone"),
            SID = char:GetData("SID"),
            Reply = tChar:GetData("SID"),
          },
        })
      end
    end
  end
end)

exports("SendDispatch411", function(message)
  for k, v in ipairs(GetPlayers()) do
    local duty = Player(v).state.onDuty
    if duty == "police" or duty == "prison" then
      TriggerClientEvent("chat:addMessage", v, {
        time = os.time(),
        type = "411",
        message = message,
      })
    end
  end
end)

exports("SendDispatchDOC", function(message)
  for k, v in ipairs(GetPlayers()) do
    local duty = Player(v).state.onDuty
    if duty == "prison" then
      TriggerClientEvent("chat:addMessage", v, {
        time = os.time(),
        type = "411A",
        message = message,
      })
    end
  end
end)

exports("SendDispatch", function(source, message)
  TriggerClientEvent("chat:addMessage", source, {
    time = os.time(),
    type = "dispatch",
    message = message,
  })
end)

exports("SendTestResult", function(source, message)
  TriggerClientEvent("chat:addMessage", source, {
    time = os.time(),
    type = "tests",
    message = message,
  })
end)

AddEventHandler("chatMessage", function(source, n, message)
  if starts_with(message, "/") then
    local command_args = stringsplit(message, " ")
    command_args[1] = string.gsub(command_args[1], "/", "")

    local commandName = command_args[1]
    if not commands[commandName] then
      -- print("Invalid Command: " .. commandName)
      --exports["pulsar-chat"]:SendServerSingle(source, "Invalid Command: " .. commandName)
    end
  end
  CancelEvent()
end)

function stringsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  i = 1
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
