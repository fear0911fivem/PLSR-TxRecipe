PER_PAGE = 10

function RegisterCallbacks()
    if RegisterDoorlockCallbacks then
        RegisterDoorlockCallbacks()
    end
    
    exports["pulsar-core"]:RegisterServerCallback('Admin:GetPlayerList', function(source, data, cb)
        CreateThread(function()
            local player = exports['pulsar-core']:FetchSource(source)
            if player and player.Permissions:IsStaff() then
                local data = {}
                local activePlayers = exports['pulsar-core']:FetchAll()

                for k, v in pairs(activePlayers) do
                    if v ~= nil and v:GetData('AccountID') then
                        table.insert(data, {
                            Source = v:GetData('Source'),
                            Name = v:GetData('Name'),
                            AccountID = v:GetData('AccountID'),
                            Character = v:GetData('Character'),
                        })
                    end
                end
                cb(data)
            else
                cb(false)
            end
        end)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetDisconnectedPlayerList', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() then
            local rDs = exports['pulsar-core']:GetRecentDisconnects()
            cb(rDs)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetPlayer', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() then
            local target = exports['pulsar-core']:FetchSource(data)

            if target then
                local staffGroupName = false
                if target.Permissions:IsStaff() then
                    local highestLevel = 0
                    for k, v in ipairs(target:GetData('Groups')) do
                        local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
                        if group and (type(group.Permission) == 'table') then
                            if group.Permission.Level > highestLevel then
                                highestLevel = group.Permission.Level
                                staffGroupName = group.Name
                            end
                        end
                    end
                end

                local pPed = GetPlayerPed(target:GetData('Source'))
                local coords = GetEntityCoords(pPed)
                local inVehicle = GetVehiclePedIsIn(pPed, false)
                if inVehicle and inVehicle > 0 then
                    local ent = Entity(inVehicle)

                    local isDriver = GetPedInVehicleSeat(inVehicle, -1) == pPed

                    inVehicle = {
                        Entity = inVehicle,
                        VIN = ent.state.VIN,
                        Plate = GetVehicleNumberPlateText(inVehicle),
                        Make = ent.state.Make,
                        Model = ent.state.Model,
                        Driver = isDriver,
                    }
                end

                local char = exports['pulsar-characters']:FetchCharacterSource(data)
                local targetLicense = exports['pulsar-core']:GetPlayerLicense(data)

                MySQL.Async.fetchAll('SELECT * FROM characters WHERE License = @license AND SID != @sid', {
                    ['@license'] = targetLicense,
                    ['@sid'] = char and char:GetData("SID") or nil
                }, function(results)
                    local chars = results or {}

                    for i, c in ipairs(chars) do
                        if c.Jobs then
                            local success, parsed = pcall(json.decode, c.Jobs)
                            chars[i].Jobs = success and parsed or {}
                        else
                            chars[i].Jobs = {}
                        end
                        local aptId = tonumber(c.Apartment)
                        if aptId and aptId > 0 then
                            local aptData = GlobalState[string.format("Apartment:%s", aptId)]
                            if aptData then
                                chars[i].ApartmentRoom = string.format("Room %s — %s",
                                    aptData.roomLabel,
                                    aptData.buildingLabel or aptData.buildingName or "Unknown"
                                )
                            end
                        end
                    end

                    local charAptRoom = nil
                    if char then
                        local charAptId = tonumber(char:GetData('Apartment'))
                        if charAptId and charAptId > 0 then
                            local charAptData = GlobalState[string.format("Apartment:%s", charAptId)]
                            if charAptData then
                                charAptRoom = string.format("Room %s — %s",
                                    charAptData.roomLabel,
                                    charAptData.buildingLabel or charAptData.buildingName or "Unknown"
                                )
                            end
                        end
                    end

                    local tData = {
                        Source = target:GetData('Source'),
                        Name = target:GetData('Name'),
                        GameName = target:GetData('GameName'),
                        AccountID = target:GetData('AccountID'),
                        Identifier = target:GetData('Identifier'),
                        Discord = target:GetData("Discord"),
                        Mention = target:GetData("Mention"),
                        Avatar = target:GetData("Avatar"),
                        Level = target.Permissions:GetLevel(),
                        Groups = target:GetData('Groups'),
                        StaffGroup = staffGroupName,
                        Character = char and {
                            First = char:GetData('First'),
                            Last = char:GetData('Last'),
                            SID = char:GetData('SID'),
                            DOB = char:GetData('DOB'),
                            Phone = char:GetData('Phone'),
                            Jobs = char:GetData('Jobs'),
                            ApartmentRoom = charAptRoom,
                            Coords = {
                                x = coords.x,
                                y = coords.y,
                                z = coords.z
                            }
                        } or false,
                        Characters = chars,
                        Vehicle = inVehicle,
                    }

                    cb(tData)
                end)
            else
                local rDs = exports['pulsar-core']:GetRecentDisconnects()
                for k, v in ipairs(rDs) do
                    if v.Source == data then
                        local tData = v

                        if tData.IsStaff then
                            local highestLevel = 0
                            for k, v in ipairs(tData.Groups) do
                                local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
                                if group and (type(group.Permission) == 'table') then
                                    if group.Permission.Level > highestLevel then
                                        highestLevel = group.Permission.Level
                                        tData.StaffGroup = group.Name
                                    end
                                end
                            end
                        end

                        tData.Disconnected = true
                        tData.Reconnected = false

                        for k, v in pairs(exports['pulsar-core']:FetchAll()) do
                            if v:GetData('AccountID') == tData.AccountID then
                                tData.Reconnected = k
                            end
                        end

                        cb(tData)
                        return
                    end
                end

                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetAllPlayersByCharacter', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() then
            local matchQuery = 'User IS NOT NULL'
            local params = {}

            if #data.term > 0 then
                matchQuery = matchQuery .. ' AND (SID = @term OR CONCAT(First, " ", Last) LIKE @term)'
                params['@term'] = '%' .. data.term .. '%'
            end

            local query = string.format([[
                SELECT * FROM characters
                WHERE %s
                ORDER BY SID DESC
                LIMIT @limit OFFSET @offset
            ]], matchQuery)

            params['@limit'] = PER_PAGE
            params['@offset'] = (data.page - 1) * PER_PAGE

            MySQL.Async.fetchAll(query, params, function(results)
                if results and #results > 0 then
                    local totalQuery = string.format([[
                        SELECT COUNT(*) as total FROM characters
                        WHERE %s
                    ]], matchQuery)

                    MySQL.Async.fetchAll(totalQuery, params, function(totalResults)
                        local totalPages = math.ceil((totalResults[1].total or 1) / PER_PAGE)
                        local data = {}

                        for k, v in ipairs(results) do
                            local isOnline = exports['pulsar-characters']:FetchByID(v.User)

                            if isOnline then
                                v.Online = isOnline:GetData("Source")
                            end

                            table.insert(data, v)
                        end

                        cb({
                            players = data,
                            pages = totalPages,
                        })
                    end)
                else
                    cb(false)
                end
            end)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:BanPlayer', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and data.targetSource and type(data.length) == "number" and type(data.reason) == "string" and data.length >= -1 and data.length <= 90 then
            if player.Permissions:IsAdmin() or (player.Permissions:IsStaff() and data.length > 0 and data.length <= 7) then
                cb(exports['pulsar-core']:PunishmentBanSource(data.targetSource, data.length, data.reason, source))
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:KickPlayer', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and data.targetSource and type(data.reason) == "string" and player.Permissions:IsStaff() then
            cb(exports['pulsar-core']:PunishmentKick(data.targetSource, data.reason, source))
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:ActionPlayer', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and data.action and data.targetSource and player.Permissions:IsStaff() then
            local target = exports['pulsar-core']:FetchSource(data.targetSource)
            if target then
                local havePerms = player.Permissions:GetLevel() > target.Permissions:GetLevel()
                local notMe = player:GetData('Source') ~= target:GetData('Source')
                local wasSuccessful = false

                local targetChar = exports['pulsar-characters']:FetchCharacterSource(data.targetSource)
                if targetChar then
                    local playerPed = GetPlayerPed(player:GetData('Source'))
                    local targetPed = GetPlayerPed(target:GetData('Source'))
                    if data.action == 'bring' and havePerms and notMe then
                        local playerCoords = GetEntityCoords(playerPed)
                        exports['pulsar-pwnzor']:TempPosIgnore(target:GetData("Source"))
                        SetEntityCoords(targetPed, playerCoords.x, playerCoords.y, playerCoords.z + 1.0)

                        cb({
                            success = true,
                            message = 'Brought Successfully'
                        })

                        wasSuccessful = true
                    elseif data.action == 'goto' then
                        local targetCoords = GetEntityCoords(targetPed)
                        SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z + 1.0)

                        cb({
                            success = true,
                            message = 'Teleported To Successfully'
                        })

                        wasSuccessful = true
                    elseif data.action == 'heal' then
                        if (notMe or player.Permissions:IsAdmin()) then
                            exports["pulsar-core"]:ClientCallback(targetChar:GetData("Source"), "Damage:Heal", true)

                            cb({
                                success = true,
                                message = 'Healed Successfully'
                            })

                            wasSuccessful = true
                        else
                            cb({
                                success = false,
                                message = 'Can\'t Heal Yourself'
                            })
                        end
                    elseif data.action == 'attach' and (havePerms or player.Permissions:GetLevel() == 100) and notMe then
                        TriggerClientEvent('Admin:Client:Attach', source, target:GetData('Source'),
                            GetEntityCoords(targetPed), {
                                First = targetChar:GetData("First"),
                                Last = targetChar:GetData("Last"),
                                SID = targetChar:GetData("SID"),
                                Account = target:GetData("AccountID"),
                            })

                        cb({
                            success = true,
                            message = 'Attached Successfully'
                        })

                        wasSuccessful = true
                    elseif data.action == 'marker' and (havePerms or player.Permissions:GetLevel() == 100) then
                        local targetCoords = GetEntityCoords(targetPed)
                        TriggerClientEvent('Admin:Client:Marker', source, targetCoords.x, targetCoords.y)
                    else
                        cb({
                            success = false,
                            message = 'An error has occured due to similar permissions.'
                        })
                    end

                    if wasSuccessful then
                        exports['pulsar-core']:LoggerWarn(
                            "Admin",
                            string.format(
                                "%s [%s] Used Staff Action %s On %s [%s] - Character %s %s (%s)",
                                player:GetData("Name"),
                                player:GetData("AccountID"),
                                string.upper(data.action),
                                target:GetData("Name"),
                                target:GetData("AccountID"),
                                targetChar:GetData('First'),
                                targetChar:GetData('Last'),
                                targetChar:GetData('SID')
                            ),
                            {
                                console = true,
                                file = false,
                                database = true,
                                discord = {
                                    embed = true,
                                    type = "error",
                                    webhook = GetConvar("discord_admin_webhook", ''),
                                },
                            }
                        )
                    end
                    return
                end
            end
        end

        cb(false)
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetVehicleList', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() then
            local tData = {}
            local allVehicles = exports['pulsar-vehicles']:OwnedGetAllActive()
            for k, v in pairs(allVehicles) do
                local entityId = v:GetData("EntityId")
                local ent = Entity(entityId)
                if ent then
                    table.insert(tData, {
                        Entity = entityId,
                        VIN = ent.state.VIN,
                        Plate = GetVehicleNumberPlateText(entityId),
                        Make = ent.state.Make,
                        Model = ent.state.Model,
                        OwnerId = ent.state.Owner?.Id
                    })
                end
            end
            cb(tData)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetVehicle', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() and data and DoesEntityExist(data) then
            local ent = Entity(data)

            local vehicleCoords = GetEntityCoords(data)
            local vehicleHeading = GetEntityHeading(data)

            local vData = {
                Make = ent.state.Make,
                Model = ent.state.Model,
                VIN = ent.state.VIN,
                Owned = ent.state.Owned,
                Owner = ent.state.Owner,
                Plate = ent.state.Plate,
                Value = ent.state.Value,
                Entity = data,
                EntityModel = GetEntityModel(data),
                Coords = {
                    x = vehicleCoords.x,
                    y = vehicleCoords.y,
                    z = vehicleCoords.z,
                },
                Heading = vehicleHeading,
                Fuel = ent.state.Fuel,
                Damage = ent.state.Damage,
                DamagedParts = ent.state.DamagedParts,
            }

            cb(vData)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:VehicleAction', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and data.action and player.Permissions:IsAdmin() and data.target and DoesEntityExist(data.target) then
            local veh = Entity(data.target)
            local netOwner = NetworkGetEntityOwner(data.target)

            if data.action == "fuel" then
                veh.state.Fuel = 100
            elseif data.action == "delete" then
                exports['pulsar-vehicles']:Delete(data.target, function() end)
            elseif data.action == "locks" then
                veh.state.Locked = not veh.state.Locked

                SetVehicleDoorsLocked(data.target, veh.state.Locked and 2 or 1)

                cb({
                    success = true,
                    message = veh.state.Locked and "Vehicle Locked" or "Vehicle Unlocked",
                })

                return
            elseif data.action == "sitinside" then
                local pPed = GetPlayerPed(source)
                local currentVehicle = GetVehiclePedIsIn(pPed, false)
                if currentVehicle == data.target then
                    cb({
                        success = false,
                        message = "Already In Vehicle!",
                    })

                    return
                end

                for i = -1, (data.numSeats - 2) do
                    if GetPedInVehicleSeat(data.target, i) <= 0 then
                        local vehCoords = GetEntityCoords(data.target)

                        SetEntityCoords(pPed, vehCoords.x, vehCoords.y, vehCoords.z - 25.0, true, false, false, false)
                        Wait(300)
                        SetPedIntoVehicle(pPed, data.target, i)

                        break
                    end
                end
            else
                if netOwner > 0 then
                    if data.action == "explode" then
                        TriggerClientEvent("NetSync:Client:Execute", netOwner, "NetworkExplodeVehicle",
                            NetworkGetNetworkIdFromEntity(data.target), 1, 0)
                    elseif data.action == "repair" then
                        TriggerClientEvent("Vehicles:Client:Repair:Normal", netOwner,
                            NetworkGetNetworkIdFromEntity(data.target))
                    elseif data.action == "repair_full" then
                        TriggerClientEvent("Vehicles:Client:Repair:Full", netOwner,
                            NetworkGetNetworkIdFromEntity(data.target))
                    elseif data.action == "repair_engine" then
                        TriggerClientEvent("Vehicles:Client:Repair:Engine", netOwner,
                            NetworkGetNetworkIdFromEntity(data.target))
                    elseif data.action == "stall" then
                        TriggerClientEvent("Admin:Client:Stall", netOwner, NetworkGetNetworkIdFromEntity(data.target))
                    else
                        cb({
                            success = false,
                            message = "Unknown Action"
                        })

                        return
                    end
                else
                    cb({
                        success = false,
                        message = "Cannot Execute RPC Action on This Vehicle At This Time!"
                    })

                    return
                end
            end

            exports['pulsar-core']:LoggerWarn(
                "Admin",
                string.format(
                    "%s [%s] Used Vehicle Action %s on %s",
                    player:GetData("Name"),
                    player:GetData("AccountID"),
                    string.upper(data.action),
                    veh.state.VIN or "Unknown"
                ),
                {
                    console = true,
                    file = false,
                    database = true,
                    discord = {
                        embed = true,
                        type = "error",
                        webhook = GetConvar("discord_admin_webhook", ''),
                    },
                }
            )
            cb({
                success = true,
                message = "Success"
            })
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:CurrentVehicleAction', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and data.action and player.Permissions:IsAdmin() and player.Permissions:GetLevel() >= 90 then
            exports['pulsar-core']:LoggerWarn(
                "Admin",
                string.format(
                    "%s [%s] Used Vehicle Action %s",
                    player:GetData("Name"),
                    player:GetData("AccountID"),
                    string.upper(data.action)
                ),
                {
                    console = (player.Permissions:GetLevel() < 100),
                    file = false,
                    database = true,
                    discord = (player.Permissions:GetLevel() < 100) and {
                        embed = true,
                        type = "error",
                        webhook = GetConvar("discord_admin_webhook", ''),
                    } or false,
                }
            )
            cb(true)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:NoClip', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsStaff() then
            exports['pulsar-core']:LoggerWarn(
                "Admin",
                string.format(
                    "%s [%s] Used NoClip (State: %s)",
                    player:GetData("Name"),
                    player:GetData("AccountID"),
                    data?.active and 'On' or 'Off'
                ),
                {
                    console = true,
                    file = false,
                    database = true,
                    discord = {
                        embed = true,
                        type = "error",
                        webhook = GetConvar("discord_admin_webhook", ''),
                    },
                }
            )
            cb(true)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:UpdatePhonePerms', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player.Permissions:IsAdmin() then
            local char = exports['pulsar-characters']:FetchCharacterSource(data.target)
            if char ~= nil then
                local cPerms = char:GetData("PhonePermissions")
                cPerms[data.app][data.perm] = data.state
                char:SetData("PhonePermissions", cPerms)
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:ToggleInvisible', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsAdmin() then
            exports['pulsar-core']:LoggerWarn(
                "Admin",
                string.format(
                    "%s [%s] Used Invisibility",
                    player:GetData("Name"),
                    player:GetData("AccountID")
                ),
                {
                    console = true,
                    file = false,
                    database = true,
                    discord = {
                        embed = true,
                        type = "error",
                        webhook = GetConvar("discord_admin_webhook", ''),
                    },
                }
            )

            TriggerClientEvent('Admin:Client:Invisible', source)
            cb(true)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GetItemList', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsAdmin() then
            local rarityMap = { none = 0, common = 1, uncommon = 2, rare = 3, epic = 4, special = 5, legendary = 4 }
            local oxItems = exports.ox_inventory:Items()
            local result = {}
            for name, item in pairs(oxItems) do
                local rarity = item.rarity or 0
                if type(rarity) == 'string' then
                    rarity = rarityMap[rarity:lower()] or 0
                end
                table.insert(result, {
                    name = item.name or name,
                    label = item.label or name,
                    type = item.type or 7,
                    rarity = rarity,
                    weight = item.weight or 0,
                    price = item.price or 0,
                    isStackable = item.isStackable or item.stack or false,
                    isUsable = item.isUsable or item.usable or false,
                })
            end
            cb(result)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Admin:GiveItem', function(source, data, cb)
        local player = exports['pulsar-core']:FetchSource(source)
        if player and player.Permissions:IsAdmin() and data and data.itemName then
            local targetSource = data.toSelf and source or tonumber(data.targetSource)

            if not targetSource then
                cb({ success = false, message = 'No target specified' })
                return
            end

            local target = exports['pulsar-core']:FetchSource(targetSource)
            if not target then
                cb({ success = false, message = 'Player not online' })
                return
            end

            local quantity = math.max(1, math.min(tonumber(data.quantity) or 1, 1000))
            local success = exports.ox_inventory:AddItem(targetSource, data.itemName, quantity)

            if success then
                exports['pulsar-core']:LoggerWarn(
                    "Admin",
                    string.format(
                        "%s [%s] Gave %s x%s to %s [%s]",
                        player:GetData("Name"),
                        player:GetData("AccountID"),
                        data.itemName,
                        quantity,
                        target:GetData("Name"),
                        target:GetData("AccountID")
                    ),
                    {
                        console = true,
                        file = false,
                        database = true,
                        discord = {
                            embed = true,
                            type = "error",
                            webhook = GetConvar("discord_admin_webhook", ''),
                        },
                    }
                )
                cb({ success = true, message = string.format('Gave %s x%s', data.itemName, quantity) })
            else
                cb({ success = false, message = 'Failed to give item — player may not have inventory space' })
            end
        else
            cb(false)
        end
    end)
end
