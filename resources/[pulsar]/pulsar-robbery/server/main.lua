_accessCodes = {
  paleto = {},
}

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

local _sellerLocs = {
  ["0"] = vector4(728.761, 2522.836, 77.993, 93.041),  -- Sunday
  ["1"] = vector4(-106.182, 6215.862, 31.382, 47.518), -- Monday
  ["2"] = vector4(1000.842, 101.158, 83.991, 68.931),  -- Tuesday
  ["3"] = vector4(440.960, -2206.147, 25.769, 61.780), -- Wednesday
  ["4"] = vector4(1576.270, 2260.446, 72.965, 270.368), -- Thursday
  ["5"] = vector4(-106.182, 6215.862, 31.382, 47.518), -- Friday
  ["6"] = vector4(440.960, -2206.147, 25.769, 61.780), -- Saturday
}

local _toolsForSale = {
  { id = 1, item = "vpn",                 coin = "MALD", price = 60,  qty = 10, vpn = false },
  { id = 1, item = "safecrack_kit",       coin = "MALD", price = 8,   qty = 10, vpn = false },
  { id = 2, item = "adv_electronics_kit", coin = "MALD", price = 100, qty = 25, vpn = true, ignoreUnique = true },
  {
    id = 2,
    item = "adv_electronics_kit",
    coin = "HEIST",
    price = 5,
    qty = 25,
    vpn = true,
    ignoreUnique = true,
    requireCurrency = true,
  },
}

local _heistTools = {
  { id = 2, item = "green_dongle",  coin = "HEIST", price = 20, qty = 3, vpn = true, requireCurrency = true },
  { id = 1, item = "blue_dongle",   coin = "HEIST", price = 30, qty = 1, vpn = true, requireCurrency = true },
  { id = 3, item = "red_dongle",    coin = "HEIST", price = 40, qty = 1, vpn = true, requireCurrency = true },
  { id = 4, item = "purple_dongle", coin = "HEIST", price = 50, qty = 1, vpn = true, requireCurrency = true },
  { id = 5, item = "yellow_dongle", coin = "HEIST", price = 60, qty = 1, vpn = true, requireCurrency = true },
}

local _heistSellerLocs = {
  ["0"] = vector4(0, 0, 0, 0),                          -- Sunday
  ["1"] = vector4(699.795, -817.861, 42.523, 273.516),  -- Monday
  ["2"] = vector4(1011.262, -2865.162, 38.157, 181.887), -- Tuesday
  ["3"] = vector4(-408.751, -182.185, 64.892, 302.832), -- Wednesday
  ["4"] = vector4(699.795, -817.861, 42.523, 273.516),  -- Thursday
  ["5"] = vector4(1011.262, -2865.162, 38.157, 181.887), -- Friday
  ["6"] = vector4(-408.751, -182.185, 64.892, 302.832), -- Saturday
}

local _schemSellerLocs = {
  ["0"] = vector4(175.090, -598.574, 19.688, 86.415), -- Sunday
  ["1"] = vector4(175.090, -598.574, 19.688, 86.415), -- Monday
  ["2"] = vector4(175.090, -598.574, 19.688, 86.415), -- Tuesday
  ["3"] = vector4(595.157, -431.042, 3.054, 225.824), -- Wednesday
  ["4"] = vector4(595.157, -431.042, 3.054, 225.824), -- Thursday
  ["5"] = vector4(595.157, -431.042, 3.054, 225.824), -- Friday
  ["6"] = vector4(595.157, -431.042, 3.054, 225.824), -- Saturday
}

local _schemSeller = {
  {
    id = 1,
    item = "schematic_thermite",
    coin = "MALD",
    price = 420,
    qty = 1,
    vpn = true,
    limited = {
      id = 1,
      qty = 1,
    },
  },
  {
    id = 2,
    item = "schematic_blindfold",
    coin = "MALD",
    price = 200,
    qty = 1,
    vpn = true,
    limited = {
      id = 1,
      qty = 1,
    },
  },
  {
    id = 2,
    item = "schematic_radio_extendo",
    coin = "MALD",
    price = 200,
    qty = 2,
    vpn = false,
    limited = {
      id = 1,
      qty = 1,
    },
  },
}

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

function hasValue(tbl, value)
  for k, v in ipairs(tbl) do
    if v == value or (type(v) == "table" and hasValue(v, value)) then
      return true
    end
  end
  return false
end

local function getPluralForm(type, amount)
  if not amount or amount > 1 then
    return type .. "s"
  end
  return type
end

function GetFormattedTimeFromSeconds(seconds)
  local days = 0
  local hours = exports['pulsar-core']:UtilsRound(seconds / 3600, 0)
  if hours >= 24 then
    days = math.floor(hours / 24)
    hours = math.ceil(hours - (days * 24))
  end

  local timeString
  if days > 0 or hours > 0 then
    if days > 1 then
      if hours > 0 then
        timeString = string.format(
          "%d %s and %d %s",
          days,
          getPluralForm("day", days),
          hours,
          getPluralForm("hour", hours)
        )
      else
        timeString = string.format("%d %s", days, getPluralForm("day", days))
      end
    else
      timeString = string.format("%d %s", hours, getPluralForm("hour", hours))
    end
  else
    local minutes = exports['pulsar-core']:UtilsRound(seconds / 60, 0)
    timeString = string.format("%d %s", minutes, getPluralForm("minute", minutes))
  end
  return timeString
end

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCommands()
    SetupQueues()
    TriggerEvent("Robbery:Server:Setup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-robbery')

    GlobalState["RobberiesDisabled"] = false

    _accessCodes.paleto = {}
    table.insert(_accessCodes.paleto, {
      label = "Office #1",
      code = math.random(1000, 9999),
    })
    table.insert(_accessCodes.paleto, {
      label = "Office #2",
      code = math.random(1000, 9999),
    })
    table.insert(_accessCodes.paleto, {
      label = "Office #3",
      code = math.random(1000, 9999),
    })
    table.insert(_accessCodes.paleto, {
      label = "Office #3 Safe",
      code = math.random(1000, 9999),
    })

    local pos1 = _heistSellerLocs[tostring(os.date("%w"))]
    exports['pulsar-pedinteraction']:VendorCreate("HeistBlocks", "ped", "Devices", GetHashKey("HC_Hacker"), {
      coords = vector3(pos1.x, pos1.y, pos1.z),
      heading = pos1.w,
      scenario = "WORLD_HUMAN_TOURIST_MOBILE",
    }, _heistTools, "fas fa-money-bill", "View Offers", false, 1, true, 60 * math.random(30, 60))

    local pos = _sellerLocs[tostring(os.date("%w"))]
    exports['pulsar-pedinteraction']:VendorCreate("HeistShit", "ped", "Rob Tools", GetHashKey("CS_NervousRon"), {
        coords = vector3(pos.x, pos.y, pos.z),
        heading = pos.w,
      }, _toolsForSale, "fas fa-money-bill", "View Offers", 1, false, true, 60 * math.random(30, 60),
      60 * math.random(240, 360))

    local pos2 = _schemSellerLocs[tostring(os.date("%w"))]
    exports['pulsar-pedinteraction']:VendorCreate("ScamSchemSeller", "ped", "Dom's Deals",
      GetHashKey("a_m_m_eastsa_02"), {
        coords = vector3(pos2.x, pos2.y, pos2.z),
        heading = pos2.w,
      }, _schemSeller, "fas fa-money-bill", "View Offers")

    exports['pulsar-finance']:CryptoCoinCreate("HEIST", "HEIST", 100, false, false)

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      TriggerClientEvent("Robbery:Client:State:Init", source, _bankStates)
    end)

    exports["pulsar-core"]:RegisterServerCallback("Robbery:Pickup", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        if #(_pickups[char:GetData("SID")] or {}) > 0 then
          for i = #_pickups[char:GetData("SID")], 1, -1 do
            local v = _pickups[char:GetData("SID")][i]
            local givingItem = exports.ox_inventory:ItemsGetData(v.giving)
            local receivingItem = exports.ox_inventory:ItemsGetData(v.receiving)

            if exports.ox_inventory:Remove(char:GetData("SID"), 1, v.giving, 1) then
              if exports.ox_inventory:AddItem(char:GetData("SID"), v.receiving, 1, {}, 1) then
                table.remove(_pickups[char:GetData("SID")], i)
              else
                exports.ox_inventory:AddItem(char:GetData("SID"), v.giving, 1, {}, 1)
                exports['pulsar-hud']:Notification(source, "error",
                  string.format("Failed Adding x1 %s", receivingItem.label),
                  6000
                )
              end
            else
              exports['pulsar-hud']:Notification(source, "error",
                string.format("Failed Taking x1 %s", givingItem.label),
                6000
              )
            end
          end
          for k, v in pairs(_pickups[char:GetData("SID")]) do
          end

          exports['pulsar-hud']:Notification(source, "success",
            "You've Picked Up All Available Items", 6000)
        else
          exports['pulsar-hud']:Notification(source, "error", "You Have Nothing To Pickup",
            6000)
        end
      end
    end)
  end
end)

exports('TriggerPDAlert', function(source, coords, code, title, blip, description, cameraGroup, isArea)
  exports["pulsar-core"]:ClientCallback(source, "EmergencyAlerts:GetStreetName", coords, function(location)
    exports['pulsar-mdt']:EmergencyAlertsCreate(
      code,
      title,
      "police_alerts",
      location,
      description,
      false,
      blip,
      false,
      isArea or false,
      cameraGroup or false
    )
  end)
end)

exports('GetAccessCodes', function(bankId)
  return _accessCodes[bankId]
end)

exports('StateSet', function(bank, state)
  _bankStates[bank] = state
  TriggerClientEvent("Robbery:Client:State:Set", -1, bank, state)
end)

exports('StateUpdate', function(bank, key, value, tableId)
  if _bankStates[bank] ~= nil then
    if tableId then
      _bankStates[bank][tableId] = _bankStates[bank][tableId] or {}
      _bankStates[bank][tableId][key] = value
    else
      _bankStates[bank][key] = value
    end
    TriggerClientEvent("Robbery:Client:State:Update", -1, bank, key, value, tableId)
  end
end)

RegisterNetEvent("Robbery:Server:Idiot", function(id)
  local src = source
  local char = exports['pulsar-characters']:FetchCharacterSource(src)
  if char ~= nil then
    exports['pulsar-core']:LoggerInfo(
      "Exploit",
      string.format(
        "%s %s (%s) Exploited Into A Kill Zone (%s) That Was Still Active, They're Now Dead",
        char:GetData("First"),
        char:GetData("Last"),
        char:GetData("SID"),
        id
      ),
      {
        console = true,
        file = true,
        database = true,
        discord = {
          embed = true,
          type = "info",
          webhook = GetConvar("discord_kill_webhook", ""),
        },
      }
    )
  end
end)
