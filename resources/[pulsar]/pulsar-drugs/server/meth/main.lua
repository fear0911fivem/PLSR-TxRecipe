_placedTables = {}
_inProgCooks = {}
_pendingPlacements = {}

local bought = {}
local _toolsForSale = {
    { id = 1, item = "meth_table", coin = "MALD", price = 400, qty = 5, vpn = true },
}

local _methSellerLocs = {
    ["0"] = vector4(-1199.910, 3839.323, 481.303, 3.028), -- Sunday
    ["1"] = vector4(-1199.910, 3839.323, 481.303, 3.028), -- Monday
    ["2"] = vector4(-302.883, 2521.718, 73.370, 96.139),  -- Tuesday
    ["3"] = vector4(-382.379, 6087.801, 38.615, 255.065), -- Wednesday
    ["4"] = vector4(-302.883, 2521.718, 73.370, 96.139),  -- Thursday
    ["5"] = vector4(-382.379, 6087.801, 38.615, 255.065), -- Friday
    ["6"] = vector4(-535.855, 2850.274, 26.935, 176.013), -- Saturday
}

exports('MethGenerateTable', function(tier)
    local recipe = {
        ingredients = {},
        cookTimeMax = math.random(_tableTiers[tier].cookTimeMax)
    }

    for i = 1, _tableTiers[tier].ingredients do
        table.insert(recipe.ingredients, math.random(100))
    end

    return MySQL.insert.await('INSERT INTO meth_tables (created, recipe, tier) VALUES(?, ?, ?)',
        { os.time(), json.encode(recipe), tier })
end)

exports('MethGetTable', function(tableId)
    return MySQL.single.await(
        'SELECT id, tier, created, cooldown, recipe, active_cook FROM meth_tables WHERE id = ?', { tableId })
end)

exports('MethIsTablePlaced', function(tableId)
    return MySQL.single.await('SELECT COUNT(table_id) as Count FROM placed_meth_tables WHERE table_id = ?',
        { tableId })?.Count or 0 > 0
end)

exports('StorePlacementData', function(source, slot)
    _pendingPlacements[source] = slot
end)

exports('GetPlacementData', function(source)
    local data = _pendingPlacements[source]
    return data
end)

exports('ClearPlacementData', function(source)
    _pendingPlacements[source] = nil
end)

exports('MethCreatePlacedTable', function(tableId, owner, tier, coords, heading, created)
    local itemInfo = exports.ox_inventory:ItemsGetData("meth_table")
    local tableData = exports['pulsar-drugs']:MethGetTable(tableId)

    MySQL.insert.await(
        "INSERT INTO placed_meth_tables (table_id, owner, placed, expires, coords, heading) VALUES(?, ?, ?, ?, ?, ?)",
        {
            tableId,
            owner,
            os.time(),
            created + itemInfo.durability,
            json.encode(coords),
            heading,
        })

    local cookData = tableData.active_cook ~= nil and json.decode(tableData.active_cook) or {}

    _placedTables[tableId] = {
        id = tableId,
        owner = owner,
        tier = tier,
        placed = os.time(),
        expires = created + itemInfo.durability,
        cooldown = tableData.cooldown,
        activeCook = tableData.active_cook ~= nil,
        pickupReady = os.time() > (cookData?.end_time or 0),
        coords = coords,
        heading = heading,
    }

    TriggerClientEvent("Drugs:Client:Meth:CreateTable", -1, _placedTables[tableId])
end)

exports('MethRemovePlacedTable', function(tableId)
    local s = MySQL.query.await('DELETE FROM placed_meth_tables WHERE table_id = ?', { tableId })
    if s.affectedRows > 0 then
        _placedTables[tableId] = nil
        TriggerClientEvent("Drugs:Client:Meth:RemoveTable", -1, tableId)
    end
    return s.affectedRows > 0
end)

exports('MethStartTableCook', function(tableId, cooldown, recipe)
    MySQL.query.await('UPDATE meth_tables SET cooldown = ?, active_cook = ? WHERE id = ?',
        { cooldown, json.encode(recipe), tableId })
    _placedTables[tableId].cooldown = cooldown
    _placedTables[tableId].activeCook = true
    _placedTables[tableId].pickupReady = false
    _inProgCooks[tableId] = recipe

    TriggerClientEvent("Drugs:Client:Meth:UpdateTableData", -1, tableId, _placedTables[tableId])
end)

exports('MethFinishTableCook', function(tableId)
    MySQL.query.await('UPDATE meth_tables SET active_cook = NULL WHERE id = ?', { tableId })
    _placedTables[tableId].activeCook = false
    _placedTables[tableId].pickupReady = false
    _inProgCooks[tableId] = nil
    TriggerClientEvent("Drugs:Client:Meth:UpdateTableData", -1, tableId, _placedTables[tableId])
end)

AddEventHandler("Drugs:Server:Startup", function()
    local mPos = _methSellerLocs[tostring(os.date("%w"))]

    exports['pulsar-pedinteraction']:VendorCreate("MethSeller", "ped", "Mike", `A_M_M_RurMeth_01`, {
            coords = vector3(mPos.x, mPos.y, mPos.z),
            heading = mPos.w,
            scenario = "WORLD_HUMAN_CHEERING"
        }, _toolsForSale, "fas fa-money-bill", "View Offers", false, false, true, 60 * math.random(30, 60),
        60 * math.random(300, 480))

    local tables = MySQL.query.await('SELECT * FROM placed_meth_tables WHERE expires > ?', { os.time() })
    for k, v in ipairs(tables) do
        if _placedTables[v.table_id] == nil or not DoesEntityExist(_placedTables[v.table_id]?.entity) then
            local tableData = exports['pulsar-drugs']:MethGetTable(v.table_id)
            local coords = json.decode(v.coords)

            local cookData = tableData.active_cook ~= nil and json.decode(tableData.active_cook) or {}
            _placedTables[v.table_id] = {
                id = v.table_id,
                owner = v.owner,
                tier = tableData.tier,
                placed = v.placed,
                expires = v.expires,
                cooldown = tableData.cooldown,
                activeCook = tableData.active_cook ~= nil,
                pickupReady = os.time() > (cookData?.end_time or 0),
                coords = coords,
                heading = v.heading,
            }

            if tableData.active_cook then
                local f = json.decode(tableData.active_cook)
                if f.end_time > os.time() then
                    _inProgCooks[v.table_id] = f
                end
            end
        end
    end

    exports['pulsar-core']:LoggerTrace("Drugs:Meth", string.format("Restored ^2%s^7 Meth Tables", #tables))

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
        TriggerLatentClientEvent("Drugs:Client:Meth:SetupTables", source, 50000, _placedTables)
    end, 1)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:FinishTablePlacement", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            local slot = exports['pulsar-drugs']:GetPlacementData(source)
            if slot and (slot.name == "meth_table" or slot.Name == "meth_table") then
                local md = slot.metadata or slot.MetaData or {}
                if md.MethTable then
                    local tableData = exports['pulsar-drugs']:MethGetTable(md.MethTable)
                    if exports.ox_inventory:RemoveItem(source, "meth_table", 1, md) then
                        exports['pulsar-drugs']:MethCreatePlacedTable(md.MethTable, char:GetData("SID"), 
                            tableData.tier,
                            data.endCoords.coords, data.endCoords.rotation, tableData.created)
                        exports['pulsar-drugs']:ClearPlacementData(source)
                        cb(true)
                    else
                        cb(false)
                    end
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:PickupTable", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            if data then
                if exports['pulsar-drugs']:MethIsTablePlaced(data) then
                    local tableData = exports['pulsar-drugs']:MethGetTable(data)
                    if exports['pulsar-drugs']:MethRemovePlacedTable(data) then
                        if exports.ox_inventory:AddItem(char:GetData("SID"), "meth_table", 1, { MethTable = data }, 1, false, false, false, false, false, tableData.created, false) then
                            cb(true)
                        else
                            cb(false)
                        end
                    else
                        cb(false)
                    end
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:CheckTable", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            if data and _placedTables[data] ~= nil then
                if _placedTables[data].cooldown == nil or os.time() > _placedTables[data].cooldown then
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:StartCooking", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            if data and _placedTables[data.tableId] ~= nil then
                if _placedTables[data.tableId].cooldown == nil or os.time() > _placedTables[data.tableId].cooldown then
                    exports['pulsar-drugs']:MethStartTableCook(data.tableId, os.time() + (60 * 60 * 2), {
                        start_time = os.time(),
                        end_time = os.time() + (60 * data.cookTime),
                        ingredients = data.ingredients,
                        cookTime = data.cookTime,
                    })

                    exports['pulsar-hud']:Notification(source, "success",
                        string.format("Batch Started, Will Be Ready In %s Minutes", data.cookTime))
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:PickupCook", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            if data and _placedTables[data] ~= nil then
                local tableData = exports['pulsar-drugs']:MethGetTable(data)
                local targetData = json.decode(tableData.recipe)
                if tableData.active_cook ~= nil then
                    local cookData = json.decode(tableData.active_cook)
                    if os.time() > cookData.end_time then
                        local total = 0
                        for k, v in ipairs(cookData.ingredients) do
                            local diff = math.abs(v - targetData.ingredients[k])
                            local pct = diff / 100
                            local amt = (100 / #cookData.ingredients) * pct
                            total += amt
                        end

                        local cookPct = math.abs(cookData.cookTime - _tableTiers[tableData.tier].cookTimeMax) /
                            _tableTiers[tableData.tier].cookTimeMax
                        local calc = total * cookPct

                        if exports.ox_inventory:AddItem(char:GetData("SID"), "meth_brick", 1, {}, 1, false, false, false, false, false, false, math.floor(100 - total)) then
                            exports['pulsar-drugs']:MethFinishTableCook(data)
                        end
                    else
                        cb(false)
                    end
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:GetTableDetails", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            if data and _placedTables[data] ~= nil then
                local tableData = exports['pulsar-drugs']:MethGetTable(data)

                local menu = {
                    main = {
                        label = string.format("Table %s Information", data),
                        items = {}
                    },
                }

                if tableData.cooldown ~= nil then
                    local timeUntil = tableData.cooldown - os.time()
                    if timeUntil > 0 then
                        table.insert(menu.main.items, {
                            label = "On Cooldown",
                            description = string.format("Available %s (in about %s)</li>",
                                os.date("%m/%d/%Y %I:%M %p", tableData.cooldown), GetFormattedTimeFromSeconds(timeUntil)),
                        })
                    else
                        table.insert(menu.main.items, {
                            label = "Cooldown Expired",
                            description = string.format("Expired at %s</li>",
                                os.date("%m/%d/%Y %I:%M %p", tableData.cooldown)),
                        })
                    end
                else
                    table.insert(menu.main.items, {
                        label = "Not On Cooldown",
                        description = string.format("No Cooldown Information Available"),
                    })
                end

                if tableData.active_cook ~= nil then
                    local cook = json.decode(tableData.active_cook)

                    local timeUntil = cook.end_time - os.time()
                    if timeUntil > 0 then
                        table.insert(menu.main.items, {
                            label = "Cook Status",
                            description = string.format("Finishes at %s (in about %s)",
                                os.date("%m/%d/%Y %I:%M %p", cook.end_time), GetFormattedTimeFromSeconds(timeUntil)),
                        })
                    else
                        table.insert(menu.main.items, {
                            label = "Cook Status",
                            description = string.format("Finished at %s", os.date("%m/%d/%Y %I:%M %p", cook.end_time)),
                        })
                    end
                else
                    table.insert(menu.main.items, {
                        label = "Cook Status",
                        description = string.format("No Active Cook"),
                    })
                end

                cb(menu)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:GetItems", function(source, data, cb)
        local itms = {}

        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        local hasVpn = exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, 'vpn', 1)

        for k, v in ipairs(_toolsForSale) do
            _toolsForSale[v.item] = _toolsForSale[v.item] or {}
            if (not v.vpn or hasVpn) and not _toolsForSale[v.item][char:GetData("SID")] then
                table.insert(itms, v)
            end
        end

        cb(itms)
    end)

    exports["pulsar-core"]:RegisterServerCallback("Drugs:Meth:BuyItem", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)

        for k, v in ipairs(_toolsForSale) do
            if v.id == data then
                local coinData = exports['pulsar-finance']:CryptoCoinGet(v.coin)
                if exports['pulsar-finance']:CryptoExchangeRemove(v.coin, char:GetData("CryptoWallet"), v.price) then
                    if v.item == "meth_table" then
                        local tableId = exports['pulsar-drugs']:MethGenerateTable(1)
                        exports.ox_inventory:AddItem(char:GetData("SID"), v.item, 1, { MethTable = tableId }, 1)
                    else
                        exports.ox_inventory:AddItem(char:GetData("SID"), v.item, 1, {}, 1)
                    end
                    _toolsForSale[v.item][char:GetData("SID")] = true
                else
                    exports['pulsar-hud']:Notification(source, "error",
                        string.format("Not Enough %s", coinData.Name), 6000)
                end
            end
        end
    end)
end)
