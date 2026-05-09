_methTables = {}
local _tableModels = {
    `bkr_prop_meth_table01a`
}

AddEventHandler("Drugs:Client:Startup", function()
    for k, v in ipairs(_tableModels) do
        exports.ox_target:addModel(v, {
            {
                label = "Pickup Table",
                icon = "fas fa-hand",
                event = "Drugs:Client:Meth:PickupTable",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMethTable and not _methTables[entState?.methTable]?.activeCook
                end,
            },
            {
                label = "Table Info",
                icon = "fas fa-info",
                event = "Drugs:Client:Meth:TableDetails",
                distance = 3.0,
                canInteract = function(entity)
                    return Entity(entity).state?.isMethTable
                end,
            },
            {
                label = "Start Batch",
                icon = "fas fa-clock",
                event = "Drugs:Client:Meth:StartCook",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMethTable and
                        (not _methTables[entState.methTable]?.cooldown or GetCloudTimeAsInt() > _methTables[entState.methTable]?.cooldown) and
                        (_methTables[entState.methTable].owner == nil or _methTables[entState.methTable].owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
            {
                label = "Collect Batch",
                icon = "fas fa-box",
                event = "Drugs:Client:Meth:PickupCook",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMethTable and _methTables[entState?.methTable]?.activeCook and
                        _methTables[entState?.methTable]?.pickupReady and
                        (_methTables[entState.methTable].owner == nil or _methTables[entState.methTable].owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
        })
    end

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Meth:PlaceTable", function(data, cb)
        exports['pulsar-objects']:PlacerStart(`bkr_prop_meth_table01a`, "Drugs:Client:Meth:FinishPlacement", data, false)
        cb()
    end)

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Meth:Use", function(data, cb)
        Wait(400)
        exports['pulsar-games']:MinigamePlayRoundSkillbar(1.0, 6, {
            onSuccess = function()
                cb(true)
            end,
            onFail = function()
                cb(false)
            end,
        }, {
            useWhileDead = false,
            vehicle = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "switch@trevor@trev_smoking_meth",
                anim = "trev_smoking_meth_loop",
                flags = 48,
            },
        })
    end)

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Adrenaline:Use", function(data, cb)
        Wait(400)
        exports['pulsar-games']:MinigamePlayRoundSkillbar(1.0, 6, {
            onSuccess = function()
                cb(true)
            end,
            onFail = function()
                cb(false)
            end,
        }, {
            useWhileDead = false,
            vehicle = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "rcmpaparazzo1ig_4",
                anim = "miranda_shooting_up",
                flags = 48,
            },
        })
    end)
end)

RegisterNetEvent("Drugs:Client:Meth:SetupTables", function(tables)
    CreateThread(function()
        loadModel(`bkr_prop_meth_table01a`)
        for k, v in pairs(tables) do
            _methTables[k] = v
            local obj = CreateObject(`bkr_prop_meth_table01a`, v.coords.x, v.coords.y, v.coords.z, false, true, false)
            SetEntityHeading(obj, v.heading)
            while not DoesEntityExist(obj) do
                Wait(1)
            end
            _methTables[k].entity = obj
            Entity(obj).state.isMethTable = true
            Entity(obj).state.methTable = v.id
        end
    end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
    CreateThread(function()
        for k, v in pairs(_methTables) do
            if v?.entity ~= nil and DoesEntityExist(v?.entity) then
                DeleteEntity(v?.entity)
                _methTables[k] = nil
            end
        end
    end)
end)

RegisterNetEvent("Drugs:Client:Meth:CreateTable", function(table)
    CreateThread(function()
        loadModel(`bkr_prop_meth_table01a`)
        _methTables[table.id] = table
        local obj = CreateObject(`bkr_prop_meth_table01a`, table.coords.x, table.coords.y, table.coords.z, false, true,
            false)
        SetEntityHeading(obj, table.heading)
        while not DoesEntityExist(obj) do
            Wait(1)
        end

        _methTables[table.id].entity = obj

        Entity(obj).state.isMethTable = true
        Entity(obj).state.methTable = table.id
    end)
end)

RegisterNetEvent("Drugs:Client:Meth:RemoveTable", function(tableId)
    CreateThread(function()
        local objs = GetGamePool("CObject")
        for k, v in ipairs(objs) do
            local entState = Entity(v).state
            if entState.isMethTable and entState.methTable == tableId then
                DeleteEntity(v)
            end
        end
        _methTables[tableId] = nil
    end)
end)

RegisterNetEvent("Drugs:Client:Meth:UpdateTableData", function(tableId, data)
    _methTables[tableId] = data
end)

AddEventHandler("Drugs:Client:Meth:FinishPlacement", function(data, endCoords)
    TaskTurnPedToFaceCoord(LocalPlayer.state.ped, endCoords.coords.x, endCoords.coords.y, endCoords.coords.z, 0.0)
    Wait(1000)
    exports['pulsar-hud']:Progress({
        name = "meth_pickup",
        duration = (math.random(5) + 10) * 1000,
        label = "Placing Table",
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            task = "CODE_HUMAN_MEDIC_KNEEL",
        },
    }, function(status)
        if not status then
            exports["pulsar-core"]:ServerCallback("Drugs:Meth:FinishTablePlacement", {
                data = data,
                endCoords = endCoords
            }, function(s)
                -- if s then
                --     local obj = CreateObject(`bkr_prop_meth_table01a`, endCoords.coords.x, endCoords.coords.y, endCoords.coords.z, true, true, false)
                --     SetEntityHeading(obj, endCoords.rotation)
                --     Entity(obj).state:set("isMethTable", true, true)
                -- end
            end)
        end
    end)
end)

AddEventHandler("Drugs:Client:Meth:PickupTable", function(entity, data)
    if Entity(entity.entity).state?.isMethTable then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = (math.random(5) + 15) * 1000,
            label = "Picking Up Table",
            useWhileDead = false,
            canCancel = true,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                task = "CODE_HUMAN_MEDIC_KNEEL",
            },
        }, function(status)
            if not status then
                exports["pulsar-core"]:ServerCallback("Drugs:Meth:PickupTable", Entity(entity.entity).state.methTable,
                    function(s)
                        -- if s then
                        --     DeleteObject(entity.entity)
                        -- end
                    end)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Meth:StartCook", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMethTable and entState.methTable then
        exports["pulsar-core"]:ServerCallback("Drugs:Meth:CheckTable", entState.methTable, function(s)
            if s then
                exports['pulsar-hud']:Progress({
                    name = "meth_pickup",
                    duration = 5 * 1000,
                    label = "Preparing Table",
                    useWhileDead = false,
                    canCancel = true,
                    ignoreModifier = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        anim = "dj",
                    },
                }, function(status)
                    if not status then
                        local c = table.copy(_tableTiers[_methTables[entState.methTable].tier])
                        c.tableId = entState.methTable
                        exports['pulsar-hud']:MethOpen(c)
                    end
                end)
            else
                exports["pulsar-hud"]:Notification("error", "Table Is Not Ready")
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Meth:ConfirmCook", function(data)
    if data ~= nil and _methTables[data.tableId] ~= nil and (not _methTables[data.tableId]?.cooldown or GetCloudTimeAsInt() > _methTables[data.tableId]?.cooldown) then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = 20 * 1000,
            label = "Readying Ingredients",
            useWhileDead = false,
            canCancel = true,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                anim = "dj",
            },
        }, function(status)
            if not status then
                exports['pulsar-hud']:Progress({
                    name = "meth_pickup",
                    duration = 20 * 1000,
                    label = "Mixing Ingredients",
                    useWhileDead = false,
                    canCancel = true,
                    ignoreModifier = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        anim = "dj",
                    },
                }, function(status)
                    if not status then
                        exports['pulsar-hud']:Progress({
                            name = "meth_pickup",
                            duration = 20 * 1000,
                            label = "Starting Cooking Process",
                            useWhileDead = false,
                            canCancel = true,
                            ignoreModifier = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                anim = "dj",
                            },
                        }, function(status)
                            if not status then
                                exports["pulsar-core"]:ServerCallback("Drugs:Meth:StartCooking", data, function(s)

                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Meth:PickupCook", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMethTable and entState.methTable then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = 5 * 1000,
            label = "Gathering Goods",
            useWhileDead = false,
            canCancel = true,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                anim = "dj",
            },
        }, function(status)
            if not status then
                exports["pulsar-core"]:ServerCallback("Drugs:Meth:PickupCook", entState.methTable, function(s)
                    if s then
                    else
                        exports["pulsar-hud"]:Notification("error", "Table Is Not Ready")
                    end
                end)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Meth:TableDetails", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMethTable and entState.methTable then
        exports["pulsar-core"]:ServerCallback("Drugs:Meth:GetTableDetails", entState.methTable, function(s)
            if s then
                exports['pulsar-hud']:ListMenuShow(s)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Meth:ViewItems", function(entity, data)
    exports["pulsar-core"]:ServerCallback("Drugs:Meth:GetItems", {}, function(items)
        local itemList = {}

        if #items > 0 then
            for k, v in ipairs(items) do
                local itemData = exports.ox_inventory:ItemsGetData(v.item)
                if v.qty > 0 then
                    table.insert(itemList, {
                        label = itemData.label,
                        description = string.format("Stock: 1 Per Tsunami | %s $%s", v.price, v.coin),
                        event = "Drugs:Client:Meth:BuyItem",
                        data = v.id,
                    })
                else
                    table.insert(itemList, {
                        label = itemData.label,
                        description = "Sold Out",
                    })
                end
            end
        else
            table.insert(itemList, {
                label = "No Items Available",
                description = "Come Back Later",
            })
        end

        exports['pulsar-hud']:ListMenuShow({
            main = {
                label = "Offers",
                items = itemList,
            },
        })
    end)
end)

AddEventHandler("Drugs:Client:Meth:BuyItem", function(data)
    exports["pulsar-core"]:ServerCallback("Drugs:Meth:BuyItem", data)
end)
