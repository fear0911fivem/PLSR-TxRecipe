AddEventHandler("Elevators:Client:OpenElevator", function(data)
    if not ELEVATOR_STATE then
        return
    end

    local elevatorData = ELEVATOR_STATE[data.elevator]

    if elevatorData and LocalPlayer.state.loggedIn then
        local menu = {
            main = {
                label = elevatorData.name or "Elevator",
                items = {},
            },
        }

        local isAuthed = false
        if elevatorData.canLock and CheckElevatorPermissions(elevatorData.canLock) then
            isAuthed = true
        end

        for floorId, floorData in pairs(elevatorData.floors) do
            local isDisabled = false
            local description = nil

            if floorData.locked then
                if not floorData.bypassLock or not CheckElevatorPermissions(floorData.bypassLock) then
                    isDisabled = true
                end
                description = "Authorized Access Only (Locked)"
            end

            if data.floor == floorId then
                isDisabled = true
                description = "You are Currently on This Level"
            end

            if isAuthed then
                isDisabled = false
            end

            table.insert(menu.main.items, {
                level = floorId,
                label = floorData.name or "Level " .. floorId,
                disabled = isDisabled,
                description = description,
                event = "Elevators:Client:UseElevator",
                data = { elevator = data.elevator, floor = floorId },
                submenu = isAuthed and string.format("auth-%s", floorId) or false
            })

            if isAuthed then
                if data.floor == floorId then
                    isDisabled = true
                end

                menu[string.format("auth-%s", floorId)] = {
                    label = (floorData.name or "Level " .. floorId),
                    items = {
                        {
                            level = floorId,
                            label = "Visit This Floor",
                            disabled = isDisabled,
                            description = description,
                            event = "Elevators:Client:UseElevator",
                            data = { elevator = data.elevator, floor = floorId },
                            submenu = false
                        },
                        {
                            --level = -1000,
                            label = floorData.locked and "Unlock Floor" or "Lock Floor",
                            description = "Lock/Unlock this Floor",
                            event = "Elevators:Client:LockElevator",
                            data = { elevator = data.elevator, floor = floorId },
                        }
                    }
                }
            end
        end

        table.sort(menu.main.items, function(a, b)
            return a.level < b.level
        end)

        exports['pulsar-hud']:ListMenuShow(menu)
    end
end)

AddEventHandler("Elevators:Client:LockElevator", function(data)
    if ELEVATOR_STATE[data.elevator] and LocalPlayer.state.loggedIn then
        exports["pulsar-core"]:ServerCallback("Elevators:ToggleLocks", data, function(success, newState)
            if success then
                if newState then
                    exports["pulsar-hud"]:Notification("error", "Elevator Locked")
                else
                    exports["pulsar-hud"]:Notification("success", "Elevator Unlocked")
                end
            end
        end)
    end
end)

AddEventHandler("Elevators:Client:UseElevator", function(data)
    local elevatorData = ELEVATOR_STATE[data.elevator]

    if elevatorData and elevatorData.floors and LocalPlayer.state.loggedIn then
        local floorData = elevatorData.floors[data.floor]
        if floorData and floorData.coords then
            exports["pulsar-core"]:ServerCallback("Elevators:Validate", floorData, function()
                exports['pulsar-hud']:ProgressWithTickEvent({
                    name = "door_elevator",
                    duration = 2000,
                    label = "Awaiting Elevator",
                    useWhileDead = false,
                    canCancel = true,
                    ignoreModifier = true,
                    tickrate = 100,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true,
                    },
                }, function()
                    if LocalPlayer.state.isCuffed then
                        return exports['pulsar-hud']:ProgressCancel()
                    end
                end, function(cancelled)
                    if not cancelled and not ELEVATOR_STATE[data.elevator].locked then
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do Wait(10) end
                        local ped = cache.ped
                        SetEntityCoords(ped, floorData.coords.x, floorData.coords.y, floorData.coords.z)
                        SetEntityHeading(ped, floorData.coords.w)
                        exports["pulsar-sounds"]:PlayDistance(5.0, "elevator-bell.ogg", 0.4)
                        Wait(250)
                        DoScreenFadeIn(500)
                    end
                end)
            end)
        end
    end
end)

function CheckElevatorPermissions(restricted)
    if LocalPlayer.state.Character then
        if type(restricted) ~= "table" then
            return true
        end

        local stateId = LocalPlayer.state.Character:GetData("SID")
        for k, v in ipairs(restricted) do
            if v.type == "character" then
                if stateId == v.SID then
                    return true
                end
            elseif v.type == "job" then
                if v.job then
                    if exports['pulsar-jobs']:HasJob(v.job, v.workplace, v.grade, v.gradeLevel, v.reqDuty, v.jobPermission) then
                        return true
                    end
                elseif v.jobPermission then
                    if exports['pulsar-jobs']:HasPermission(v.jobPermission) then
                        return true
                    end
                end
            end
        end
    end
    return false
end
