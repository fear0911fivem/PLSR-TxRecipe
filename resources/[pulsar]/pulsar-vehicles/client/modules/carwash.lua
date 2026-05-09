local inCarWash = false
local usingCarWash = false

local carWashLocations = {
    {
        center = vector3(23.94, -1391.87, 29.37),
        length = 4.0,
        width = 19.4,
        options = {
            heading = 0,
            minZ = 28.37,
            maxZ = 31.97
        }
    },
    {
        center = vector3(-699.9, -933.25, 19.01),
        length = 9.8,
        width = 4.8,
        options = {
            heading = 0,
            minZ = 18.01,
            maxZ = 22.01
        }
    },
}

AddEventHandler('Vehicles:Client:StartUp', function()
    for k, v in ipairs(carWashLocations) do
        exports['pulsar-polyzone']:CreateBox('carwash_' .. k, v.center, v.length, v.width, v.options, {
            carwash = true,
        })
    end
end)

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
    if data.carwash and VEHICLE_INSIDE and VEHICLE_SEAT == -1 and not inCarWash then
        inCarWash = true
        exports['pulsar-hud']:ActionShow('carwash', '{keybind}primary_action{/keybind} Use Car Wash for $100')
    end
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
    if inCarWash and data and data.carwash then
        inCarWash = false
        exports['pulsar-hud']:ActionHide('carwash')
    end
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    if inCarWash and not usingCarWash then
        if VEHICLE_INSIDE and VEHICLE_SEAT == -1 then
            if GetVehicleDirtLevel(VEHICLE_INSIDE) > 1.0 then
                local char = LocalPlayer.state.Character
                if char and char:GetData('Cash') >= 250 then
                    usingCarWash = true
                    exports['pulsar-hud']:Progress({
                        name = "vehicle_clean",
                        duration = 10 * 1000,
                        label = "Cleaning Vehicle",
                        useWhileDead = false,
                        canCancel = true,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        },
                        disarm = true,
                    }, function(cancelled)
                        usingCarWash = false
                        if cancelled then return end
                        exports["pulsar-core"]:ServerCallback('Vehicles:CleanVehicle', {
                            vNet = VehToNet(VEHICLE_INSIDE),
                            bill = true,
                        })
                    end)
                else
                    exports["pulsar-hud"]:Notification("error", 'Not Enough Cash')
                end
            else
                exports["pulsar-hud"]:Notification("error", 'This Vehicle Isn\'t Dirty!')
            end
        end
    end
end)

RegisterNetEvent('Vehicles:Client:CleaningKit', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local maxDistance = 2.0
    local includePlayerVehicle = false

    local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)

    if not usingCarWash and vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0 then
        exports['pulsar-animations']:EmotesPlay('clean', false, 14000, true)
        usingCarWash = true
        exports['pulsar-hud']:Progress({
            name = "vehicle_clean",
            duration = 14000,
            label = "Cleaning Vehicle",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            disarm = true,
        }, function(cancelled)
            usingCarWash = false
            if cancelled then return end
            if DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0 then
                exports["pulsar-core"]:ServerCallback('Vehicles:CleanVehicle', {
                    vNet = VehToNet(vehicle),
                    bill = false,
                }, function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("success", 'Vehicle Cleaned')
                    end
                end)
            end
        end)
    end
end)
