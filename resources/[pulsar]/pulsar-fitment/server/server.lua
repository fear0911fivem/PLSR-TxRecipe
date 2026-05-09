AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterItems()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-fitment')
  end
end)

function RegisterItems()
  exports.ox_inventory:RegisterUse("camber_controller", "Vehicles", function(source, item)
    exports["pulsar-core"]:ClientCallback(source, "Vehicles:UseCamberController", {}, function(veh)
      if not veh then
        return
      end
      veh = NetworkGetEntityFromNetworkId(veh)
      if veh and DoesEntityExist(veh) then
        local vehState = Entity(veh).state
        if not vehState.VIN then
          return
        end

        TriggerClientEvent("Fitment:Client:CamberController:UseItem", source)
      end
    end)
  end)
end

RegisterNetEvent('ox_inventory:ready', function()
  if GetResourceState(GetCurrentResourceName()) == 'started' then
    RegisterItems()
  end
end)
