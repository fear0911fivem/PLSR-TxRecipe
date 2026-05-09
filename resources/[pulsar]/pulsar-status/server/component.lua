Callbacks = nil
Status = nil

local _statuses = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-status')
    RegisterCallbacks()
    RegisterChatCommands()
    registerUsables()

    exports['pulsar-core']:MiddlewareAdd("Characters:Logout", function(source)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local p = promise.new()
        exports["pulsar-core"]:ClientCallback(source, "Status:StoreValues", {}, function(vals)
          local status = char:GetData("Status") or {}
          for k, v in pairs(vals) do
            status[k] = v
          end
          char:SetData("Status", status)
          p:resolve(true)
        end)
        Citizen.Await(p)
      end
    end, 1)
  end
end)

exports('Register', function(name, max, icon, tick, modify)
  table.insert(_statuses, {
    name = name,
    max = max,
    icon = icon,
    tick = tick,
    modify = modify,
  })
end)

exports('GetAll', function()
  return _statuses
end)

exports('GetSingle', function(name)
  for k, v in ipairs(_statuses) do
    if v.name == name then
      return v
    end
  end
end)

exports('Add', function(source, name, value, addCd, isForced)
  exports["pulsar-core"]:ClientCallback(source, "Status:Modify", {
    name = name,
    value = math.abs(value),
    addCd = addCd,
    isForced = isForced,
  })
end)

exports('Remove', function(source, name, value, addCd, isForced)
  exports["pulsar-core"]:ClientCallback(source, "Status:Modify", {
    name = name,
    value = -(math.abs(value)),
    addCd = addCd,
    isForced = isForced,
  })
end)

exports('Set', function(source, name, value)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local status = char:GetData("Status")
    if status == nil then
      status = {}
    end
    status[name] = value
    char:SetData("Status", status)
    TriggerClientEvent("Status:Client:Update", source, name, value)
  end
end)

RegisterServerEvent("Status:Server:Update", function(data)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local status = char:GetData("Status")
    if status == nil then
      status = {}
    end
    status[data.status] = data.value
    char:SetData("Status", status)
  end
end)

RegisterServerEvent("Status:Server:StoreAll", function(data)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local status = char:GetData("Status") or {}
    for k, v in pairs(data) do
      status[k] = v
    end
    char:SetData("Status", status)
  end
end)
