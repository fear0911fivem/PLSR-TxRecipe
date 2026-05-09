-- CHecks version
AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-blips')
  end
end)
