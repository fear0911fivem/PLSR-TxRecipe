_pickups = {}
local startup = false
AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    TriggerEvent("Businesses:Server:Startup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-businesses')

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      TriggerClientEvent(
        "Taco:SetQueue",
        source,
        { counter = GlobalState["TacoShop:Counter"], item = GlobalState["TacoShop:CurrentItem"] }
      )
    end, 2)

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      if not startup then
        startup = true
        TriggerLatentClientEvent("Businesses:Client:CreatePoly", source, 50000, _pickups)
      end
    end, 2)

    Startup()
  end
end)

function Startup()
  for k, v in ipairs(Config.Businesses) do
    exports['pulsar-core']:LoggerTrace("Businesses", string.format("Registering Business ^3%s^7", v.Name))
    if v.Pickups then
      for num, pickup in pairs(v.Pickups) do
        table.insert(_pickups, pickup.id)
        pickup.num = num
        pickup.job = v.Job
        pickup.jobName = v.Name

        local stashId = string.format("businesses_pickup_%s", pickup.id)
        exports.ox_inventory:RegisterStash(
          stashId,
          string.format("%s Pickup #%s", v.Name, num),
          10,       -- slots
          10000,    -- maxWeight
          pickup.id -- owner
        )

        pickup.data = pickup.data or {}
        pickup.data.inventory = "stash"
        pickup.data.inventoryId = stashId

        exports['pulsar-core']:LoggerTrace("Businesses",
          string.format("Registered Pickup ^3%s^7 for Business ^3%s^7", pickup.id, v.Name))

        GlobalState[string.format("Businesses:Pickup:%s", pickup.id)] = pickup
      end
    end
  end
end
