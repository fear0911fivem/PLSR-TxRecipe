local startup = false
AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    Startup()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-restaurant')

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      if not startup then
        startup = true
        RunRestaurantJobUpdate(source, true)
      end
    end, 2)
  end
end)

function RunRestaurantJobUpdate(source, onSpawn)
  local charJobs = exports['pulsar-jobs']:GetJobs(source)
  local warmersList = {}
  local fridgesList = {}

  for k, v in ipairs(charJobs) do
    local jobWarmers = _warmers[v.Id]
    if jobWarmers then
      table.insert(warmersList, jobWarmers)
    end

    local jobFridges = _fridges[v.Id]
    if jobFridges then
      table.insert(fridgesList, jobFridges)
    end
  end

  TriggerClientEvent("Restaurant:Client:CreatePoly", source, _pickups, warmersList, fridgesList, onSpawn)
end
