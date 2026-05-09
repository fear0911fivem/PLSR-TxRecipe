function RegisterCallbacks()
    exports["pulsar-core"]:RegisterClientCallback('Vehicles:Admin:GetVehicleToDelete', function(data, cb)
        if LocalPlayer.state.loggedIn then
            if VEHICLE_INSIDE then
                return cb(VehToNet(VEHICLE_INSIDE))
            else
                local playerCoords = GetEntityCoords(PlayerPedId())
                local maxDistance = 5.0
                local includePlayerVehicle = true

                local data = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
                if data and DoesEntityExist(data) and IsEntityAVehicle(data) then
                    return cb(VehToNet(data))
                end
            end
        end
        cb(false)
    end)

    exports["pulsar-core"]:RegisterClientCallback('Vehicles:Admin:GetVehicleInsideData', function(data, cb)
        if LocalPlayer.state.loggedIn then
            if VEHICLE_INSIDE then
                return cb({
                    vehicle = VehToNet(VEHICLE_INSIDE),
                    model = GetEntityModel(VEHICLE_INSIDE),
                    properties = GetVehicleProperties(VEHICLE_INSIDE)
                })
            end
        end
        cb(false)
    end)

    exports["pulsar-core"]:RegisterClientCallback('Vehicles:Admin:GetVehicleSpawnData', function(model, cb)
        if LocalPlayer.state.loggedIn and IsModelValid(model) then
            local spawnLocation = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 2.0, 2.0, 0.0)
            return cb(spawnLocation, GetEntityHeading(GLOBAL_PED), GetVehicleClassFromName(model))
        end
        cb(false)
    end)
end
