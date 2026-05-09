_spawnedFurniture = nil

local _specCategories = {
    storage = true,
    beds = true,
}

function CreateFurniture(furniture)
    if _spawnedFurniture then
        DestroyFurniture()
    end

    _insideFurniture = furniture
    _spawnedFurniture = {}

    for k, v in ipairs(furniture) do
        PlaceFurniture(v)
    end
end

function PlaceFurniture(v)
    local model = GetHashKey(v.model)
    if LoadModel(model) then
        local obj = CreateObject(model, v.coords.x, v.coords.y, v.coords.z, false, true, false)
        if v.heading then
            SetEntityHeading(obj, v.heading + 0.0)
        elseif v.rotation then
            SetEntityRotation(obj, v.rotation.x, v.rotation.y, v.rotation.z)
        end
        FreezeEntityPosition(obj, true)
        SetEntityCoords(obj, v.coords.x, v.coords.y, v.coords.z)
        while not DoesEntityExist(obj) do
            Wait(1)
        end

        local furnData = FurnitureConfig[v.model]
        local hasTargeting = false

        if furnData then
            if _specCategories[furnData.cat] then
                local icon = "draw-square"
                local menu = {
                    {
                        icon = "arrows-up-down-left-right",
                        label = "Move",
                        onSelect = function()
                            TriggerEvent("Furniture:Client:OnMove", {
                                id = v.id,
                            })
                        end,
                        canInteract = function()
                            return LocalPlayer.state.furnitureEdit
                        end
                    },
                    {
                        icon = "trash",
                        label = "Delete",
                        onSelect = function()
                            TriggerEvent("Furniture:Client:OnDelete", {
                                id = v.id,
                            })
                        end,
                        canInteract = function()
                            return LocalPlayer.state.furnitureEdit
                        end
                    },
                    {
                        icon = "clone",
                        label = "Clone",
                        onSelect = function()
                            TriggerEvent("Furniture:Client:OnClone", {
                                id = v.id,
                                model = v.model,
                            })
                        end,
                        canInteract = function()
                            return LocalPlayer.state.furnitureEdit
                        end
                    },
                }

                if furnData.cat == "storage" then
                    icon = "box-open-full"

                    table.insert(menu, {
                        icon = "box-open-full",
                        label = "Access Storage",
                        event = "Properties:Client:Stash",
                        canInteract = function(data)
                            if _insideProperty and _propertiesLoaded then
                                local property = _properties[_insideProperty.id]
                                local key = property.keys and property.keys[LocalPlayer.state.Character:GetData("ID")]
                                return (key ~= nil and (((key.Permissions and key.Permissions.stash) and true) or key.Owner)) or
                                    LocalPlayer.state.onDuty == "police"
                            end
                        end,
                    })

                    table.insert(menu, {
                        icon = "clothes-hanger",
                        label = "Open Wardrobe",
                        onSelect = function()
                            TriggerEvent("Properties:Client:Closet")
                        end,
                    })
                elseif furnData.cat == "beds" then
                    icon = "bed"

                    table.insert(menu, {
                        icon = "bed",
                        label = "Logout",
                        event = "Properties:Client:Logout",
                        canInteract = function(data)
                            if _insideProperty and _propertiesLoaded then
                                local property = _properties[_insideProperty.id]
                                return property.keys ~= nil and
                                    property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil
                            end
                        end,
                    })
                end

                hasTargeting = true

                exports.ox_target:addEntity(obj, menu)
            end
        end

        table.insert(_spawnedFurniture, {
            id = v.id,
            entity = obj,
            model = v.model,
            targeting = hasTargeting,
        })

        if LocalPlayer.state.furnitureEdit and not hasTargeting then
            exports.ox_target:addEntity(obj, {
                {
                    icon = "arrows-up-down-left-right",
                    label = "Move",
                    onSelect = function()
                        TriggerEvent("Furniture:Client:OnMove", {
                            id = v.id,
                        })
                    end,
                },
                {
                    icon = "trash",
                    label = "Delete",
                    onSelect = function()
                        TriggerEvent("Furniture:Client:OnDelete", {
                            id = v.id,
                        })
                    end,
                },
                {
                    icon = "clone",
                    label = "Clone",
                    onSelect = function()
                        TriggerEvent("Furniture:Client:OnClone", {
                            id = v.id,
                            model = v.model,
                        })
                    end,
                },
            })
        end

        Wait(1)
    else
        exports["pulsar-hud"]:Notification("error", "Failed to Load Model: " .. v.model)
    end
end

function DestroyFurniture(s)
    if _spawnedFurniture then
        for k, v in ipairs(_spawnedFurniture) do
            DeleteEntity(v.entity)
            if not s then
                exports.ox_target:removeEntity(v.entity)
            end
        end

        _spawnedFurniture = nil
    end
end

function SetFurnitureEditMode(state)
    if _spawnedFurniture then
        if state then
            for k, v in ipairs(_spawnedFurniture) do
                if not v.targeting then
                    exports.ox_target:addEntity(v.entity, {
                        {
                            icon = "arrows-up-down-left-right",
                            label = "Move",
                            onSelect = function()
                                TriggerEvent("Furniture:Client:OnMove", {
                                    id = v.id,
                                })
                            end,
                        },
                        {
                            icon = "trash",
                            label = "Delete",
                            onSelect = function()
                                TriggerEvent("Furniture:Client:OnDelete", {
                                    id = v.id,
                                })
                            end,
                        },
                        {
                            icon = "clone",
                            label = "Clone",
                            onSelect = function()
                                TriggerEvent("Furniture:Client:OnClone", {
                                    id = v.id,
                                    model = v.model,
                                })
                            end,
                        },
                    })
                end
            end

            exports["pulsar-hud"]:Notification("standard",
                "Furniture Edit Mode Enabled - Third Eye Objects to Move or Delete Them",
                -1,
                nil,
                nil,
                "furniture")
        else
            for k, v in ipairs(_spawnedFurniture) do
                if not v.targeting then
                    exports.ox_target:removeEntity(v.entity)
                end
            end

            exports["pulsar-hud"]:Notification("remove", nil, nil, nil, nil, "furniture")
        end

        LocalPlayer.state.furnitureEdit = state
    end
end

function CycleFurniture(direction)
    if not _furnitureCategoryCurrent then
        return
    end

    if direction then
        if _furnitureCategoryCurrent < #_furnitureCategory then
            _furnitureCategoryCurrent = _furnitureCategoryCurrent + 1
        else
            return
        end
    else
        if _furnitureCategoryCurrent > 1 then
            _furnitureCategoryCurrent = _furnitureCategoryCurrent - 1
        else
            return
        end
    end

    exports['pulsar-hud']:InfoOverlayClose()
    exports['pulsar-objects']:PlacerCancel(true, true)
    Wait(200)
    local fKey = _furnitureCategory[_furnitureCategoryCurrent]
    local fData = FurnitureConfig[fKey]
    if fData then
        exports['pulsar-hud']:InfoOverlayShow(fData.name,
            string.format("Category: %s | Model: %s",
                (FurnitureCategories[fData.cat] and FurnitureCategories[fData.cat].name or "Unknown"), fKey))
    end
    exports['pulsar-objects']:PlacerStart(GetHashKey(fKey), "Furniture:Client:Place", {}, true,
        "Furniture:Client:Cancel", true, true)
end

AddEventHandler("Furniture:Client:Place", function(data, placement)
    if _placingFurniture then
        local model = _furnitureCategory[_furnitureCategoryCurrent]
        if not model then
            model = _placingSearchItem
        end

        exports["pulsar-core"]:ServerCallback("Properties:PlaceFurniture", {
            model = model,
            coords = {
                x = placement.coords.x,
                y = placement.coords.y,
                z = placement.coords.z,
            },
            rotation = {
                x = placement.rotation.x,
                y = placement.rotation.y,
                z = placement.rotation.z,
            },
            data = data,
        }, function(success)
            if success then
                exports["pulsar-hud"]:Notification("success", "Placed Item")
            else
                exports["pulsar-hud"]:Notification("error", "Unable to Place Furniture")
            end

            _placingFurniture = false
            LocalPlayer.state.placingFurniture = false
            exports['pulsar-hud']:InfoOverlayClose()

            if not _skipPhone then
                exports['pulsar-phone']:Open()
            end
        end)
    end
    DisablePauseMenu(false)
end)

AddEventHandler("Furniture:Client:Cancel", function()
    if _placingFurniture then
        _placingFurniture = false
        LocalPlayer.state.placingFurniture = false

        if not _skipPhone then
            exports['pulsar-phone']:Open()
        end

        Wait(200)
        DisablePauseMenu(false)
        exports['pulsar-hud']:InfoOverlayClose()
    end
end)

AddEventHandler("Furniture:Client:Move", function(data, placement)
    if _placingFurniture and data.id then
        exports["pulsar-core"]:ServerCallback("Properties:MoveFurniture", {
            id = data.id,
            coords = {
                x = placement.coords.x,
                y = placement.coords.y,
                z = placement.coords.z,
            },
            rotation = {
                x = placement.rotation.x,
                y = placement.rotation.y,
                z = placement.rotation.z,
            },
        }, function(success)
            if success then
                exports["pulsar-hud"]:Notification("success", "Moved Item")
            else
                exports["pulsar-hud"]:Notification("error", "Unable to Move Furniture")
            end

            _placingFurniture = false
            LocalPlayer.state.placingFurniture = false
            exports['pulsar-hud']:InfoOverlayClose()

            if not _skipPhone then
                exports['pulsar-phone']:Open()
            end
        end)
    end
    DisablePauseMenu(false)
end)

AddEventHandler("Furniture:Client:CancelMove", function(data)
    if _placingFurniture and data.id then
        if _insideFurniture then
            for k, v in ipairs(_insideFurniture) do
                if v.id == data.id then
                    PlaceFurniture(v)
                end
            end
        end

        exports["pulsar-hud"]:Notification("error", "Move Cancelled")
        _placingFurniture = false
        LocalPlayer.state.placingFurniture = false
        if not _skipPhone then
            exports['pulsar-phone']:Open()
        end

        Wait(200)
        DisablePauseMenu(false)
    end
end)

RegisterNetEvent("Furniture:Client:AddItem", function(property, index, item)
    if _insideProperty and _insideProperty.id == property and _spawnedFurniture then
        PlaceFurniture(item)
        table.insert(_insideFurniture, item)
    end
end)

RegisterNetEvent("Furniture:Client:MoveItem", function(property, id, item)
    if _insideProperty and _insideProperty.id == property and _spawnedFurniture then
        local ns = {}
        local shouldUpdate = false
        for k, v in ipairs(_spawnedFurniture) do
            if v.id == id then
                DeleteEntity(v.entity)
                exports.ox_target:removeEntity(v.entity)
                shouldUpdate = true
            else
                table.insert(ns, v)
            end
        end
        if shouldUpdate then
            _spawnedFurniture = ns
        end

        PlaceFurniture(item)

        for k, v in ipairs(_insideFurniture) do
            if v.id == id then
                _insideFurniture[k] = item
                break
            end
        end
    end
end)

RegisterNetEvent("Furniture:Client:DeleteItem", function(property, id, furniture)
    if _insideProperty and _insideProperty.id == property and _spawnedFurniture then
        local ns = {}
        for k, v in ipairs(_spawnedFurniture) do
            if v.id == id then
                DeleteEntity(v.entity)
                exports.ox_target:removeEntity(v.entity)
            else
                table.insert(ns, v)
            end
        end

        _spawnedFurniture = ns
        _insideFurniture = furniture
    end
end)

AddEventHandler("Furniture:Client:OnMove", function(entity, data)
    exports['pulsar-properties']:Move(data.id, true)
end)

AddEventHandler("Furniture:Client:OnDelete", function(entity, data)
    exports['pulsar-properties']:Delete(data.id)
end)

AddEventHandler("Furniture:Client:OnClone", function(entity, data)
    exports['pulsar-properties']:Place(data.model, false, {}, false, true, GetEntityCoords(entity.entity),
        GetEntityRotation(entity.entity))
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DestroyFurniture()
    end
end)

local _disablePause = false

function DisablePauseMenu(state)
    if _disablePause ~= state then
        _disablePause = state
        if _disablePause then
            CreateThread(function()
                while _disablePause do
                    DisableControlAction(0, 200, true)
                    Wait(1)
                end
            end)
        end
    end
end
