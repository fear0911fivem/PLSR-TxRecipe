function PoliceItems()
    exports.ox_inventory:RegisterUse("det_cord", "PDItems", function(source, slot, itemData)
        local pState = Player(source).state
        if pState.onDuty == "police" then
            exports["pulsar-core"]:ClientCallback(source, "Police:DoDetCord", {}, function(s, doorId)
                if s and exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1) then
                    TriggerEvent('ox_doorlock:setState', doorId, false, source)
                    SetTimeout(60 * 60 * 1000, function()
                        TriggerEvent('ox_doorlock:setState', doorId, true, source)
                    end)
                end
            end)
        end
    end)
end

RegisterNetEvent('ox_inventory:ready', function()
    if GetResourceState(GetCurrentResourceName()) == 'started' then
        PoliceItems()
    end
end)