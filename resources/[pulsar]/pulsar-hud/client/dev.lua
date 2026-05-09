local _devMode = false
local _createdTargets = {
    vehicle = {},
    ped = {},
    object = {}
}

local function addTargets(targetType, targets)
    if targetType == 'vehicle' then
        exports.ox_target:addGlobalVehicle(targets)
    elseif targetType == 'ped' then
        exports.ox_target:addGlobalPed(targets)
    elseif targetType == 'object' then
        exports.ox_target:addGlobalObject(targets)
    end

    for _, target in ipairs(targets) do
        if target.name then
            table.insert(_createdTargets[targetType], target.name)
        end
    end
end

local function removeAllTargets()
    for targetType, targetNames in pairs(_createdTargets) do
        for _, targetName in ipairs(targetNames) do
            if targetType == 'vehicle' then
                exports.ox_target:removeGlobalVehicle(targetName)
            elseif targetType == 'ped' then
                exports.ox_target:removeGlobalPed(targetName)
            elseif targetType == 'object' then
                exports.ox_target:removeGlobalObject(targetName)
            end
        end
    end

    _createdTargets = {
        vehicle = {},
        ped = {},
        object = {}
    }
end

RegisterNetEvent("HUD:Client:DevMode", function()
    if LocalPlayer.state.isStaff or LocalPlayer.state.isAdmin then
        _devMode = not _devMode
        exports['pulsar-hud']:Notification("info", "Dev Mode " .. (_devMode and "Enabled" or "Disabled"), 2500,
            "fas fa-cube")

        if _devMode then
            exports['pulsar-status']:SetSingle("PLAYER_DEV", 1)
        else
            exports['pulsar-status']:SetSingle("PLAYER_DEV", 0)
        end

        if _devMode then
            -- Vehicle targets
            addTargets('vehicle', {
                {
                    label = "Dev Actions",
                    name = "dev_actions",
                    icon = "fas fa-cube",
                    openMenu = "dev_actions",
                    canInteract = function()
                        return _devMode
                    end
                },
                {
                    label = "Delete Vehicle",
                    name = "dev_delete_vehicle",
                    icon = "fas fa-trash",
                    menuName = "dev_actions",
                    canInteract = function()
                        return _devMode
                    end,
                    onSelect = function(data)
                        TriggerServerEvent('dev:deleteVehicle', NetworkGetNetworkIdFromEntity(data.entity))
                    end
                },
                {
                    label = "Get Keys",
                    name = "dev_get_keys",
                    icon = "fas fa-key",
                    menuName = "dev_actions",
                    canInteract = function()
                        return _devMode
                    end,
                    onSelect = function(data)
                        TriggerServerEvent('dev:getKeys', NetworkGetNetworkIdFromEntity(data.entity))
                    end
                },
                {
                    label = 'Debug Vehicle',
                    name = 'debug_vehicle',
                    event = 'ox_target:debug',
                    icon = 'fas fa-car',
                    menuName = 'dev_actions',
                    canInteract = function()
                        return _devMode
                    end,
                }
            })

            -- Ped targets
            addTargets('ped', {
                {
                    name = 'dev_actions_ped',
                    icon = 'fas fa-cube',
                    label = 'Dev Actions',
                    openMenu = 'dev_actions',
                    canInteract = function()
                        return _devMode
                    end
                },
                {
                    name = 'debug_ped',
                    event = 'ox_target:debug',
                    icon = 'fas fa-male',
                    label = 'Debug Ped',
                    menuName = 'dev_actions',
                    canInteract = function()
                        return _devMode
                    end,
                }
            })

            -- Object targets
            addTargets('object', {
                {
                    name = 'dev_actions_object',
                    icon = 'fas fa-cube',
                    label = 'Dev Actions',
                    openMenu = 'dev_actions',
                    canInteract = function()
                        return _devMode
                    end
                },
                {
                    label = "Delete Object",
                    name = "dev_delete_object",
                    icon = "fas fa-trash",
                    menuName = "dev_actions",
                    canInteract = function()
                        return _devMode
                    end,
                    onSelect = function(data)
                        if NetworkGetEntityIsNetworked(data.entity) then
                            local netId = NetworkGetNetworkIdFromEntity(data.entity)
                            TriggerServerEvent('dev:deleteObject', netId)
                        else
                            if DoesEntityExist(data.entity) then
                                SetEntityAsMissionEntity(data.entity, true, true)
                                DeleteEntity(data.entity)
                                SetEntityAsNoLongerNeeded(data.entity)
                                exports['pulsar-hud']:Notification("success", "Object deleted successfully")
                            end
                        end
                    end
                },
                {
                    name = 'debug_object',
                    event = 'ox_target:debug',
                    icon = 'fas fa-bong',
                    label = 'Debug Object',
                    menuName = 'dev_actions',
                    canInteract = function()
                        return _devMode
                    end,
                }
            })
        else
            removeAllTargets()
        end
    else
        exports['pulsar-hud']:Notification("error", "How are you doing this?")
    end
end)

exports('IsDevModeActive', function()
    return _devMode
end)
