function defaultApps()
  -- local defApps = {}
  -- for k, v in pairs(LAPTOP_APPS) do
  -- 	if not v.canUninstall then
  -- 		table.insert(defApps, v.name)
  -- 	end
  -- end
  -- return {
  -- 	installed = defApps,
  -- 	home = defApps,
  -- }

  return {
    installed = {
      "settings",
      "files",
      "internet",
      "bizwiz",
      "teams",
      "lsunderground",
    },
    home = {
      "settings",
      "files",
      "internet",
      "bizwiz",
      "teams",
      "lsunderground",
    },
  }
end

function hasValue(tbl, value)
  for k, v in ipairs(tbl) do
    if v == value or (type(v) == "table" and hasValue(v, value)) then
      return true
    end
  end
  return false
end

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

function defaultSettings()
  return {
    wallpaper = "wallpaper",
    texttone = "notification.ogg",
    colors = {
      accent = "#1a7cc1",
    },
    zoom = 75,
    volume = 100,
    notifications = true,
    appNotifications = {},
  }
end

local defaultPermissions = {
  redline = {
    create = false,
  },
  lsunderground = {
    admin = false,
  },
}

AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    TriggerClientEvent("Laptop:Client:SetApps", -1, LAPTOP_APPS)
  end
end)

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    Startup()
    RegisterChatCommands()
    TriggerEvent("Laptop:Server:RegisterMiddleware")
    TriggerEvent("Laptop:Server:RegisterCallbacks")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-laptop')

    exports['pulsar-characters']:RepCreate("Chopping", "Vehicle Chopping", {
      { label = "Rank 1",  value = 1000 },
      { label = "Rank 2",  value = 2500 },
      { label = "Rank 3",  value = 5000 },
      { label = "Rank 4",  value = 10000 },
      { label = "Rank 5",  value = 25000 },
      { label = "Rank 6",  value = 50000 },
      { label = "Rank 7",  value = 100000 },
      { label = "Rank 8",  value = 250000 },
      { label = "Rank 9",  value = 500000 },
      { label = "Rank 10", value = 1000000 },
    }, true)

    exports['pulsar-characters']:RepCreate("Boosting", "Boosting", {
      { label = "D",  value = 0 },
      { label = "C",  value = 6000 },
      { label = "B",  value = 15000 },
      { label = "A",  value = 50000 },
      { label = "A+", value = 120000 }, -- Get Scratching
      { label = "S+", value = 150000 },
    }, true)
  end
end)

AddEventHandler("Laptop:Server:RegisterMiddleware", function()
  exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
    exports['pulsar-laptop']:UpdateJobData(source)
    TriggerClientEvent("Laptop:Client:SetApps", source, LAPTOP_APPS)

    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    local myPerms = char:GetData("LaptopPermissions") or {}
    local modified = false
    for app, perms in pairs(defaultPermissions) do
      if myPerms[app] == nil then
        myPerms[app] = perms
        modified = true
      else
        for perm, state in pairs(perms) do
          if myPerms[app][perm] == nil then
            myPerms[app][perm] = state
            modified = true
          end
        end
      end
    end

    if modified then
      char:SetData("LaptopPermissions", myPerms)
    end

    if not char:GetData("LaptopSettings") then
      char:SetData("LaptopSettings", defaultSettings())
    end

    if not char:GetData("LaptopApps") then
      char:SetData("LaptopApps", defaultApps())
    end
  end, 1)
  exports['pulsar-core']:MiddlewareAdd("Laptop:UIReset", function(source)
    exports['pulsar-laptop']:UpdateJobData(source)
    TriggerClientEvent("Laptop:Client:SetApps", source, LAPTOP_APPS)
  end)
  exports['pulsar-core']:MiddlewareAdd("Characters:Creating", function(source, cData)
    local t = exports['pulsar-core']:MiddlewareTriggerEventWithData("Laptop:CharacterCreated", source, cData)

    return {
      {
        LaptopApps = defaultApps(),
        LaptopSettings = defaultSettings(),
        LaptopPermissions = defaultPermissions,
      },
    }
  end)
end)

RegisterNetEvent("Laptop:Server:UIReset", function()
  exports['pulsar-core']:MiddlewareTriggerEvent("Laptop:UIReset", source)
end)

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
  exports["pulsar-core"]:RegisterServerCallback("Laptop:Permissions", function(src, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(src)

    if char ~= nil then
      local perms = char:GetData("LaptopPermissions")

      for k, v in pairs(data) do
        for k2, v2 in ipairs(v) do
          if not perms[k][v2] then
            cb(false)
            return
          end
        end
      end
      cb(true)
    else
      cb(false)
    end
  end)
end)
