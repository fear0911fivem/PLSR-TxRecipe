local _bct = RobberyConfig.moneytruck

CreateThread(function()
    local spawned = false
    while true do
        spawned = false

        if #_moneyTruckSpawns == 0 then
            _moneyTruckSpawns = table.copy(_bct.spawnHolding)
        end

        if _truckSpawnEnabled then
            spawned = SpawnBobcatTruck(`stockade`)
            if not spawned then
                Wait(30000)
            else
                Wait(_bct.spawnRate)
            end
        else
            Wait(60000)
        end
    end
end)
