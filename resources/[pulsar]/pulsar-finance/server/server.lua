AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    TriggerEvent("Finance:Server:Startup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-finance')
  end
end)
