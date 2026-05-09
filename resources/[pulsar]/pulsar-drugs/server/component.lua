local _addictionTemplate = {
  Meth = {
    LastUse = false,
    Factor = 0.0,
  },
  Coke = {
    LastUse = false,
    Factor = 0.0,
  },
  Moonshine = {
    LastUse = false,
    Factor = 0.0,
  },
}

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterItemUse()
    RunDegenThread()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-drugs')

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local addictions = char:GetData("Addiction")
        if char:GetData("Addiction") == nil then
          char:SetData("Addiction", _addictionTemplate)
        else
          for k, v in pairs(_addictionTemplate) do
            if addictions[k] == nil then
              addictions[k] = table.copy(v)
            end
          end
          char:SetData("Addiction", addictions)
        end
      end
    end, 1)

    TriggerEvent("Drugs:Server:Startup")
    TriggerEvent("Drugs:Server:StartCookThreads")
  end
end)
