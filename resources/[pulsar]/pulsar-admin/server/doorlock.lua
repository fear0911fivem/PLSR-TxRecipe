local function hasAdminPermission(source)
    if IsPlayerAceAllowed(source, 'command.doorlock') then
        return true
    end

    local player = exports['pulsar-core']:FetchSource(source)
    if player and player.Permissions then
        return player.Permissions:IsAdmin() or player.Permissions:GetLevel() >= 90
    end

    return false
end

function RegisterDoorlockCallbacks()
    exports["pulsar-core"]:RegisterServerCallback('Admin:GetDoorLocks', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb({})
        end

        MySQL.query('SELECT id, name, data FROM ox_doorlock', {}, function(results)
            if results and type(results) == 'table' then
                local formattedDoors = {}

                for i = 1, #results do
                    local row = results[i]
                    local success, doorData = pcall(function()
                        return json.decode(row.data)
                    end)

                    if success and doorData then
                        formattedDoors[#formattedDoors + 1] = {
                            id = row.id,
                            name = row.name or 'Unknown',
                            state = doorData.state or 1,
                            coords = doorData.coords or { x = 0, y = 0, z = 0 },
                            groups = doorData.groups or {},
                            characters = doorData.characters or {},
                            items = doorData.items or {},
                            maxDistance = doorData.maxDistance or 2.5,
                            workplace = doorData.workplace or nil,
                            permissions = doorData.permissions or nil,
                            onduty = doorData.onduty or nil,
                        }
                    end
                end

                cb(formattedDoors)
            else
                cb({})
            end
        end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetDoorLockById', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb(false)
        end

        MySQL.query('SELECT id, name, data FROM ox_doorlock WHERE id = ?', { data.id }, function(result)
            if result and result[1] then
                local success, doorData = pcall(function()
                    return json.decode(result[1].data)
                end)

                if success and doorData then
                    local formattedDoor = {
                        id = result[1].id,
                        name = result[1].name or 'Unknown',
                        state = doorData.state or 1,
                        coords = doorData.coords or { x = 0, y = 0, z = 0 },
                        heading = doorData.heading or 0,
                        model = doorData.model or '',
                        doors = doorData.doors or nil,
                        maxDistance = doorData.maxDistance or 2.5,
                        auto = doorData.auto or false,
                        autolock = doorData.autolock or nil,
                        lockpick = doorData.lockpick or false,
                        hideUi = doorData.hideUi or false,
                        holdOpen = doorData.holdOpen or false,
                        lockSound = doorData.lockSound or '',
                        unlockSound = doorData.unlockSound or '',
                        doorRate = doorData.doorRate or 1.0,
                        passcode = doorData.passcode or nil,
                        lockpickDifficulty = doorData.lockpickDifficulty or nil,
                        groups = doorData.groups or {},
                        characters = doorData.characters or {},
                        items = doorData.items or {},
                        workplace = doorData.workplace or nil,
                        permissions = doorData.permissions or nil,
                        onduty = doorData.onduty or false,
                    }

                    cb(formattedDoor)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:CreateDoorLock', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb(false)
        end

        local doorData = {
            name = data.name or tostring(data.coords),
            auto = data.auto,
            autolock = data.autolock,
            coords = data.coords,
            doors = data.doors,
            heading = data.heading,
            lockpick = data.lockpick,
            hideUi = data.hideUi,
            holdOpen = data.holdOpen,
            lockSound = data.lockSound,
            maxDistance = data.maxDistance,
            doorRate = data.doorRate,
            model = data.model,
            state = data.state or 1,
            unlockSound = data.unlockSound,
            lockpickDifficulty = data.lockpickDifficulty,
        }

        if data.groups and next(data.groups) ~= nil then
            doorData.groups = data.groups
        end

        if data.characters and #data.characters > 0 then
            doorData.characters = data.characters
        end

        if data.items and #data.items > 0 then
            doorData.items = data.items
        end

        if data.workplace and data.workplace ~= '' then
            doorData.workplace = data.workplace
        end

        if data.permissions and data.permissions ~= '' then
            doorData.permissions = data.permissions
        end

        if data.onduty then
            doorData.onduty = data.onduty
        end

        if data.passcode and data.passcode ~= '' then
            doorData.passcode = data.passcode
        end

        local encodedData = json.encode(doorData)

        MySQL.insert('INSERT INTO ox_doorlock (name, data) VALUES (?, ?)', { doorData.name, encodedData },
            function(insertId)
                if insertId then
                    TriggerEvent('ox_doorlock:reloadDoor', insertId)

                    TriggerClientEvent('pulsar-hud:Notification', source, 'success', 'Door created successfully!', 3000)
                    cb({ success = true, id = insertId })
                else
                    cb({ success = false })
                end
            end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:UpdateDoorLock', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb(false)
        end

        local id = data.id
        local doorName = data.name

        local doorData = {
            name = doorName,
            auto = data.auto,
            autolock = data.autolock,
            coords = data.coords,
            doors = data.doors,
            heading = data.heading,
            lockpick = data.lockpick,
            hideUi = data.hideUi,
            holdOpen = data.holdOpen,
            lockSound = data.lockSound,
            maxDistance = data.maxDistance,
            doorRate = data.doorRate,
            model = data.model,
            state = data.state or 1,
            unlockSound = data.unlockSound,
            lockpickDifficulty = data.lockpickDifficulty,
        }

        if data.groups and next(data.groups) ~= nil then
            doorData.groups = data.groups
        end

        if data.characters and #data.characters > 0 then
            doorData.characters = data.characters
        end

        if data.items and #data.items > 0 then
            doorData.items = data.items
        end

        if data.workplace and data.workplace ~= '' then
            doorData.workplace = data.workplace
        end

        if data.permissions and data.permissions ~= '' then
            doorData.permissions = data.permissions
        end

        if data.onduty then
            doorData.onduty = data.onduty
        end

        if data.passcode and data.passcode ~= '' then
            doorData.passcode = data.passcode
        end

        local encodedData = json.encode(doorData)

        MySQL.update('UPDATE ox_doorlock SET name = ?, data = ? WHERE id = ?', { doorName, encodedData, id },
            function(affectedRows)
                if affectedRows and affectedRows > 0 then
                    TriggerEvent('ox_doorlock:reloadDoor', id)

                    TriggerClientEvent('pulsar-hud:Notification', source, 'success', 'Door updated successfully!', 3000)
                    cb({ success = true })
                else
                    cb({ success = false })
                end
            end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:DeleteDoorLock', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb(false)
        end

        local doorId = data.id

        MySQL.update('DELETE FROM ox_doorlock WHERE id = ?', { doorId }, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                TriggerEvent('ox_doorlock:removeDoor', doorId)

                TriggerClientEvent('pulsar-hud:Notification', source, 'success', 'Door deleted successfully!', 3000)
                cb({ success = true })
            else
                cb({ success = false })
            end
        end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:TeleportToDoorLock', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        local door = exports.ox_doorlock:getDoor(data.id)

        if door and door.coords then
            local ped = GetPlayerPed(source)
            SetEntityCoords(ped, door.coords.x, door.coords.y, door.coords.z, false, false, false, false)
            cb(true)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:ToggleDoorLockState', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        if GetResourceState('ox_doorlock') ~= 'started' then
            return cb(false)
        end

        MySQL.query('SELECT id, data FROM ox_doorlock WHERE id = ?', { data.id }, function(result)
            if result and result[1] then
                local success, doorData = pcall(function()
                    return json.decode(result[1].data)
                end)

                if success and doorData then
                    local currentState = doorData.state or 1
                    local newState = data.state ~= nil and data.state or (currentState == 1 and 0 or 1)

                    doorData.state = newState
                    local encodedData = json.encode(doorData)

                    MySQL.update('UPDATE ox_doorlock SET data = ? WHERE id = ?', { encodedData, data.id },
                        function(affectedRows)
                            TriggerClientEvent('ox_doorlock:setState', -1, data.id, newState, false)

                            cb(true)
                        end)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetDoorLockSounds', function(source, data, cb)
        if not hasAdminPermission(source) then
            return cb(false)
        end

        cb({
            'door-bolt-4',
            'button-remote',
            'metal-locker',
            'metallic-creak',
            'door_bolt'
        })
    end)
end
