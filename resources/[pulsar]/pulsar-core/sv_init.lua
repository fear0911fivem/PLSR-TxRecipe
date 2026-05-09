-- Version Checking on resource startup
AddEventHandler('onResourceStart', function(resource)
  if resource ~= GetCurrentResourceName() then return end
  exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-core')
end)
