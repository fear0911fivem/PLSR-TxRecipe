ONLINE_CHARACTERS = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterLocationCallbacks()
    RegisterMiddleware()
    Startup()
    RegisterCommands()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-characters')
  end
end)

exports("GetLastLocation", function(source)
  return _tempLastLocation[source] or false
end)

TablesToDecode = {
  "Origin",
  "Apps",
  "Wardrobe",
  "Jobs",
  "Addiction",
  "PhoneSettings",
  "Crypto",
  "Licenses",
  "Alias",
  "PhonePermissions",
  "LaptopApps",
  "LaptopSettings",
  "LaptopPermissions",
  "Animations",
  "States",
  "MDTHistory",
  "MDTSuspension",
  "Qualifications",
  "LastClockOn",
  "Salary",
  "TimeClockedOn",
  "Reputations",
  "GangChain",
  "Jailed",
  "ICU",
  "Status",
  "Parole",
  "LSUNDGBan",
  "PhonePosition",
  "Callsign",
  "HUDConfig",
  "DrugStates",
  "CasinoChips",
  -- Maybe more to be added
}
