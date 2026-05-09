-- If you are adding on to this, make sure you validate permission / distance / whatever you are using it for.

RegisterNetEvent('dev:deleteVehicle', function(netId)
    local player = exports['pulsar-core']:FetchSource(source)
    if player.Permissions:IsStaff() or player.Permissions:IsAdmin() then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if not DoesEntityExist(entity) then return end

        exports['pulsar-vehicles']:Delete(entity, function() end)
    else
        exports['pulsar-core']:LoggerInfo(
            "Pwnzor",
            string.format(
                "%s (%s) Attempted To Use Debug Function: %s. Network ID: %s, potentially a cheater?",
                player:GetData("Name"),
                player:GetData("AccountID"),
                "dev:deleteVehicle",
                netId
            )
        )
        return exports['pulsar-hud']:Notification(source, "error", "How are you doing this?")
    end
end)

RegisterNetEvent('dev:getKeys', function(netId)
    local player = exports['pulsar-core']:FetchSource(source)
    if player.Permissions:IsStaff() or player.Permissions:IsAdmin() then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if not DoesEntityExist(entity) then return end

        local vehicleState = Entity(entity).state
        if vehicleState.VIN then
            exports['pulsar-vehicles']:KeysAdd(source, vehicleState.VIN)
            exports['pulsar-hud']:Notification(source, "success", "Keys added for vehicle VIN: " .. vehicleState.VIN)
        end
    else
        exports['pulsar-core']:LoggerInfo(
            "Pwnzor",
            string.format(
                "%s (%s) Attempted To Use Debug Function: %s. Network ID: %s, potentially a cheater?",
                player:GetData("Name"),
                player:GetData("AccountID"),
                "dev:getKeys"
            )
        )
        return exports['pulsar-hud']:Notification(source, "error", "How are you doing this?")
    end
end)

RegisterNetEvent('dev:deleteObject', function(netId)
    local player = exports['pulsar-core']:FetchSource(source)
    if player.Permissions:IsStaff() or player.Permissions:IsAdmin() then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if not DoesEntityExist(entity) then return end

        DeleteEntity(entity)
        exports['pulsar-hud']:Notification(source, "success", "Object deleted successfully")
    else
        exports['pulsar-core']:LoggerInfo(
            "Pwnzor",
            string.format(
                "%s (%s) Attempted To Use Debug Function: %s. Network ID: %s, potentially a cheater?",
                player:GetData("Name"),
                player:GetData("AccountID"),
                "dev:deleteObject",
                netId
            )
        )
        return exports['pulsar-hud']:Notification(source, "error", "How are you doing this?")
    end
end)
