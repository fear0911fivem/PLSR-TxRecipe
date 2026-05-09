local isManagingDoorlock = false

RegisterNUICallback('GetDoorLocks', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:GetDoorLocks', data, cb)
end)

RegisterNUICallback('GetDoorLockById', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:GetDoorLockById', data, cb)
end)

RegisterNUICallback('CreateDoorLock', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:CreateDoorLock', data, function(success)
        if success then
            cb({
                success = true,
                message = 'Door lock created successfully'
            })
        else
            cb({
                success = false,
                message = 'Failed to create door lock'
            })
        end
    end)
end)

RegisterNUICallback('UpdateDoorLock', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:UpdateDoorLock', data, function(success)
        if success then
            cb({
                success = true,
                message = 'Door lock updated successfully'
            })
        else
            cb({
                success = false,
                message = 'Failed to update door lock'
            })
        end
    end)
end)

RegisterNUICallback('DeleteDoorLock', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:DeleteDoorLock', data, function(success)
        if success then
            cb({
                success = true,
                message = 'Door lock deleted successfully'
            })
        else
            cb({
                success = false,
                message = 'Failed to delete door lock'
            })
        end
    end)
end)

RegisterNUICallback('TeleportToDoorLock', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:TeleportToDoorLock', data, function(success)
        if success then
            cb({
                success = true,
                message = 'Teleported to door lock'
            })
        else
            cb({
                success = false,
                message = 'Failed to teleport to door lock'
            })
        end
    end)
end)

RegisterNUICallback('ToggleDoorLockState', function(data, cb)
    exports["pulsar-core"]:ServerCallback('Admin:ToggleDoorLockState', data, function(success)
        if success then
            cb({
                success = true,
                message = 'Door lock state toggled'
            })
        else
            cb({
                success = false,
                message = 'Failed to toggle door lock state'
            })
        end
    end)
end)

RegisterNUICallback('StartAddDoorLock', function(data, cb)
    cb('OK')

    SetNuiFocus(false, false)
    SendNUIMessage({ type = "APP_HIDE" })

    Wait(100)

    local doorCount = data.isDouble and 2 or 1
    local tempData = {}
    local lastEntity = 0
    local isAddingDoorlock = true

    exports['pulsar-hud']:ActionShow(
        "doorlock_add",
        "Left Click: Select Door | Right Click: Cancel"
    )

    CreateThread(function()
        while isAddingDoorlock do
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 25, true)

            local hit, entity, coords = lib.raycast.cam(1|16)
            local changedEntity = lastEntity ~= entity
            local doorA = tempData[1]

            if changedEntity and lastEntity ~= doorA then
                SetEntityDrawOutline(lastEntity, false)
            end

            lastEntity = entity

            if hit then
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24,
                    100, false, false, 0, true, false, false, false)
            end

            if hit and entity > 0 and GetEntityType(entity) == 3 and (doorCount == 1 or doorA ~= entity) then
                if changedEntity then
                    SetEntityDrawOutline(entity, true)
                end

                if IsDisabledControlJustPressed(0, 24) then
                    local model = GetEntityModel(entity)
                    local entityCoords = GetEntityCoords(entity)

                    AddDoorToSystem("temp", model, entityCoords.x, entityCoords.y, entityCoords.z, false, false, false)
                    DoorSystemSetDoorState("temp", 4, false, false)

                    entityCoords = GetEntityCoords(entity)
                    tempData[#tempData + 1] = {
                        model = model,
                        coords = {
                            x = entityCoords.x,
                            y = entityCoords.y,
                            z = entityCoords.z
                        },
                        heading = math.floor(GetEntityHeading(entity) + 0.5)
                    }

                    RemoveDoorFromSystem("temp")

                    exports['pulsar-hud']:Notification("success", string.format("Door %d selected", #tempData), 3500)
                end
            end

            if IsDisabledControlJustPressed(0, 25) then
                isAddingDoorlock = false
                exports['pulsar-hud']:ActionHide("doorlock_add")

                SetEntityDrawOutline(lastEntity, false)
                if doorA then
                    SetEntityDrawOutline(doorA, false)
                end
                if tempData[2] then
                    SetEntityDrawOutline(tempData[2], false)
                end

                exports['pulsar-hud']:Notification("info", "Door selection cancelled", 3500)

                Wait(100)
                SetNuiFocus(true, true)
                SendNUIMessage({ type = "APP_SHOW" })
                return
            end

            if #tempData >= doorCount then
                isAddingDoorlock = false
                exports['pulsar-hud']:ActionHide("doorlock_add")

                if doorA then
                    SetEntityDrawOutline(doorA, false)
                end
                if lastEntity and lastEntity ~= 0 then
                    SetEntityDrawOutline(lastEntity, false)
                end

                local doorData = {
                    isDouble = doorCount == 2
                }

                if doorCount == 1 then
                    doorData.model = tempData[1].model
                    doorData.coords = tempData[1].coords
                    doorData.heading = tempData[1].heading
                else
                    doorData.doors = tempData
                    doorData.coords = {
                        x = (tempData[1].coords.x + tempData[2].coords.x) / 2,
                        y = (tempData[1].coords.y + tempData[2].coords.y) / 2,
                        z = (tempData[1].coords.z + tempData[2].coords.z) / 2
                    }
                end

                exports['pulsar-hud']:Notification("success", "Doors selected! Fill in the details.", 3500)

                Wait(100)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = "DOORLOCK_DOORS_SELECTED",
                    data = doorData
                })
                SendNUIMessage({ type = "APP_SHOW" })
                return
            end

            Wait(0)
        end
    end)
end)

RegisterNUICallback('GetClosestDoorLock', function(data, cb)
    local closestDoor = exports.ox_doorlock:getClosestDoor()

    if closestDoor then
        exports["pulsar-core"]:ServerCallback('Admin:GetDoorLockById', { id = closestDoor.id }, cb)
    else
        cb(false)
    end
end)

exports("OpenDoorlockMenu", function()
    if LocalPlayer.state.isStaff then
        OpenMenu()
    end
end)

RegisterNetEvent('pulsar-admin:openDoorlockMenu', function()
    if LocalPlayer.state.isStaff then
        if not _menuOpen and _hasMenu then
            _menuOpen = true
            SendNUIMessage({ type = "APP_SHOW" })
            SetNuiFocus(true, true)

            Wait(100)
            SendNUIMessage({
                type = "SET_ROUTE",
                data = { route = "#/doorlocks" }
            })
        end
    end
end)
