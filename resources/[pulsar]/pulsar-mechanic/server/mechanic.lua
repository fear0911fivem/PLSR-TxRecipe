AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()

    RegisterMechanicItems()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-mechanic')
    -- Mechanic crafting benches are now handled by ox_inventory crafting.lua, No need to register them here anymore
  end
end)
