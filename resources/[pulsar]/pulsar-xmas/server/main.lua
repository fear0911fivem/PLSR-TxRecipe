_currentTree = {}
_treeLooted = {}
_currentDate = os.date("*t", os.time())
XMAS_MONTH = 12

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-xmas')
    RegisterCommands()
    RegisterCallbacks()
    RegisterItems()
    Startup()
    StartThreading()

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      if _currentDate.month == XMAS_MONTH then
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
          local sid = char:GetData("SID")
          TriggerClientEvent("Xmas:Client:Init", source, _currentDate.day, _currentTree,
            _treeLooted[sid] ~= nil)
        end
      end
    end, 2)
  end
end)
