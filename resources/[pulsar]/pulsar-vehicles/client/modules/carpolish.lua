local LAST_DIRT_LEVEL = false
local DIRT_MULT = false

AddEventHandler('Vehicles:Client:StartUp', function()
    exports["pulsar-core"]:RegisterClientCallback('Vehicles:UseCarPolish', function(data, cb)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local maxDistance = 2.0
        local includePlayerVehicle = false

        local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
        if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            if exports['pulsar-vehicles']:UtilsIsCloseToVehicle(vehicle) then
                exports['pulsar-hud']:Progress({
                    name = "vehicle_applying_polish",
                    duration = 5000,
                    label = "Applying Polish",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = false,
                    },
                    animation = {
                        anim = "maid",
                    },
                }, function(cancelled)
                    if not cancelled and exports['pulsar-vehicles']:UtilsIsCloseToVehicle(vehicle) then
                        cb(VehToNet(vehicle))
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)


AddEventHandler('Vehicles:Client:StartUp', function()
    AddTaskToVehicleThread('car_polish', 8, true, function(veh, class, running, inside, onExit)
        if LAST_DIRT_LEVEL then
            if DIRT_MULT then
                local diff = GetVehicleDirtLevel(veh) - LAST_DIRT_LEVEL
                if DoesEntityExist(veh) and diff > 0 then
                    local newDirtLevel = exports['pulsar-core']:UtilsRound(LAST_DIRT_LEVEL + (diff / DIRT_MULT), 5)
                    if newDirtLevel > 10.0 then
                        newDirtLevel = 10.0
                    end

                    SetVehicleDirtLevel(veh, newDirtLevel)
                    LAST_DIRT_LEVEL = newDirtLevel
                end
            end
        else
            local ent = Entity(veh)
            LAST_DIRT_LEVEL = GetVehicleDirtLevel(veh)
            if ent?.state?.Polish then
                print('Vehicle Has Polish: ', json.encode(ent?.state?.Polish))
                DIRT_MULT = ent.state.Polish?.Mult or 2
            else
                DIRT_MULT = false
            end
        end

        if onExit then
            LAST_DIRT_LEVEL = false
        end
    end, true)
end)
