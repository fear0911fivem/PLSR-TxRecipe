local _threading = false
function StartLombankThreads()
    if _threading then return end
    _threading = true

    CreateThread(function()
        while _threading do
            if _lbGlobalReset ~= nil then
                if os.time() > _lbGlobalReset then
                    exports['pulsar-core']:LoggerInfo("Robbery", "Lombank Heist Has Been Reset")
                    ResetLombank()
                end
            end
            Wait(30000)
        end
    end)

    CreateThread(function()
        while _threading do
            local powerDisabled = IsLBPowerDisabled()
            if not powerDisabled and not exports['ox_doorlock']:IsLocked("lombank_hidden_entrance") then
                exports['ox_doorlock']:SetLock("lombank_hidden_entrance", true)
                exports['ox_doorlock']:SetLock("lombank_lasers", true)
            elseif powerDisabled and exports['ox_doorlock']:IsLocked("lombank_hidden_entrance") then
                exports['ox_doorlock']:SetLock("lombank_hidden_entrance", false)
            end
            Wait((1000 * 60) * 1)
        end
    end)

    CreateThread(function()
        while _threading do
            for i = #_unlockingDoors, 1, -1 do
                local v = _unlockingDoors[i]
                if os.time() > v.expires then
                    exports['ox_doorlock']:SetLock(v.door, false)
                    if v.forceOpen then
                        exports['ox_doorlock']:SetForcedOpen(v.door)
                    end
                    exports['pulsar-hud']:Notification("info", v.source, "Door Unlocked")
                    table.remove(_unlockingDoors, i)
                end
            end
            Wait(30000)
        end
    end)

    CreateThread(function()
        while _threading do
            if _lbGlobalReset ~= nil and os.time() > _lbGlobalReset then
                ResetLombank()
                _lbGlobalReset = nil
            end
            Wait(60000)
        end
    end)

    -- CreateThread(function()
    --     while _threading do
    --         local powerDisabled = IsLBPowerDisabled()
    --         if not powerDisabled and not exports['ox_doorlock']:IsLocked("lombank_hidden_entrance") then
    --             exports['ox_doorlock']:SetLock("lombank_hidden_entrance", true)
    --         end
    --         Wait((1000 * 60) * 1)
    --     end
    -- end)
end
