local _threading = false
AddEventHandler("Drugs:Server:StartCookThreads", function()
    if _threading then
        return
    end
    _threading = true

    -- Brew completion thread
    CreateThread(function()
        while _threading do
            for k, v in pairs(_inProgBrews) do
                if os.time() > v.end_time then
                    _placedStills[k].pickupReady = true
                    exports['pulsar-core']:LoggerInfo("Drugs:Moonshine",
                        string.format("Brew for Still %s Is Ready For Pickup", k))
                    TriggerClientEvent("Drugs:Client:Moonshine:UpdateStillData", -1, k, _placedStills[k])
                    _inProgBrews[k] = nil
                end
            end

            Wait(30000)
        end
    end)

    -- Barrel aging thread
    CreateThread(function()
        while _threading do
            for k, v in pairs(_inProgAges) do
                if os.time() > v then
                    if _placedBarrels[k] then
                        _placedBarrels[k].pickupReady = true
                        exports['pulsar-core']:LoggerInfo("Drugs:Moonshine",
                            string.format("Brew for Barrel %s Is Ready For Pickup", k))
                        TriggerClientEvent("Drugs:Client:Moonshine:UpdateBarrelData", -1, k, _placedBarrels[k])
                    end
                    _inProgAges[k] = nil
                end
            end

            Wait(5000) -- Check every 5 seconds for more responsive updates
        end
    end)
    
    -- Heat decay thread (decay heat every minute, per still)
    CreateThread(function()
        while _threading do
            for stillId, heat in pairs(_stillHeat) do
                if heat > 0 then
                    _stillHeat[stillId] = math.max(0, heat - _policeDetection.heatDecayRate)
                    if _stillHeat[stillId] == 0 then
                        _stillHeat[stillId] = nil
                    end
                end
            end
            
            Wait(30000) -- Every minute
        end
    end)
    
    -- Delivery expiration thread
    CreateThread(function()
        while _threading do
            for k, delivery in pairs(_activeDeliveries) do
                if os.time() > delivery.expires then
                    if delivery.source then
                        exports['pulsar-hud']:Notification(delivery.source, "error", "Delivery mission expired!")
                    end
                    _activeDeliveries[k] = nil
                end
            end
            
            Wait(30000) -- Check every 30 seconds
        end
    end)
end)
