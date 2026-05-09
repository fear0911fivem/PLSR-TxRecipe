_stills = {}
_barrels = {}
local _stillModels = {
    `prop_still`
}

local _barrelModels = {
    `prop_wooden_barrel`,
}

local function RunSkillChecks(total)
    local success = 0
    local failed = 0

    for i = 1, total do
        local p = promise.new()
        exports['pulsar-games']:MinigamePlayRoundSkillbar(1.15, 3, {
            onSuccess = function()
                success += 1
                Wait(50)
                p:resolve(true)
            end,
            onFail = function()
                failed += 1
                Wait(50)
                p:resolve(true)
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
                anim = "dj",
            },
        })

        Citizen.Await(p)
    end

    return {
        total = total,
        success = success,
        failed = failed,
    }
end

AddEventHandler("Drugs:Client:Startup", function()
    for k, v in ipairs(_stillModels) do
        exports.ox_target:addModel(v, {
            {
                label = "Dismantle Still (Destroys Still)",
                icon = "fas fa-hand",
                event = "Drugs:Client:Moonshine:PickupStill",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMoonshineStill and
                        (LocalPlayer.state.onDuty == "police" or _barrels[entState?.stillId]?.owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
            {
                label = "Still Info",
                icon = "fas fa-info",
                event = "Drugs:Client:Moonshine:StillDetails",
                distance = 3.0,
                canInteract = function(entity)
                    return Entity(entity).state?.isMoonshineStill
                end,
            },
            {
                label = "Upgrade Still",
                icon = "fas fa-wrench",
                event = "Drugs:Client:Moonshine:UpgradeStill",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMoonshineStill and
                        (_stills[entState.stillId]?.owner == nil or _stills[entState.stillId]?.owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
            {
                label = "Start Brewing",
                icon = "fas fa-clock",
                event = "Drugs:Client:Moonshine:StartCook",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMoonshineStill and
                        not _stills[entState.stillId]?.activeBrew and
                        (not _stills[entState.stillId]?.cooldown or GetCloudTimeAsInt() > _stills[entState.stillId]?.cooldown) and
                        (_stills[entState.stillId]?.owner == nil or _stills[entState.stillId]?.owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
            {
                label = "Collect Brew",
                icon = "fas fa-box",
                event = "Drugs:Client:Moonshine:PickupCook",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMoonshineStill and _stills[entState.stillId]?.activeBrew and
                        _stills[entState.stillId]?.pickupReady and
                        (_stills[entState.stillId]?.owner == nil or _stills[entState.stillId]?.owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
        })
    end

    for k, v in ipairs(_barrelModels) do
        exports.ox_target:addModel(v, {
            {
                label = "Destroy Barrel",
                icon = "fas fa-hand",
                event = "Drugs:Client:Moonshine:PickupBarrel",
                distance = 3.0,
                canInteract = function(entity)
                    local entState = Entity(entity).state
                    return entState?.isMoonshineBarrel and
                        (LocalPlayer.state.onDuty == "police" or _barrels[entState?.barrelId]?.owner == LocalPlayer.state.Character:GetData("SID"))
                end,
            },
            {
                label = "Barrel Info",
                icon = "fas fa-info",
                event = "Drugs:Client:Moonshine:BarrelDetails",
                distance = 3.0,
                canInteract = function(entity)
                    return Entity(entity).state?.isMoonshineBarrel
                end,
            },
            {
                label = "Fill Jars",
                icon = "fas fa-box",
                event = "Drugs:Client:Moonshine:PickupBrew", 
                distance = 3.0,
                canInteract = function(entity)
                    if not entity then
                        return false
                    end
                    local entState = Entity(entity).state
                    if not entState or not entState.isMoonshineBarrel then
                        return false
                    end
                    -- Convert barrelId to number to ensure proper lookup
                    local barrelId = tonumber(entState.barrelId)
                    if not barrelId then
                        return false
                    end
                    local barrel = _barrels[barrelId]
                    if not barrel then
                        return false
                    end
                    -- Check if barrel is ready
                    if not barrel.pickupReady then
                        return false
                    end
                    -- Check ownership
                    local char = LocalPlayer.state.Character
                    if not char then
                        return false
                    end
                    local sid = char:GetData("SID")
                    return barrel.owner == nil or barrel.owner == tostring(sid)
                end,
            },
        })
    end

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Moonshine:PlaceStill", function(data, cb)
        exports['pulsar-objects']:PlacerStart(`prop_still`, "Drugs:Client:Moonshine:FinishPlacement", data, 2)
        cb()
    end)

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Moonshine:PlaceBarrel", function(data, cb)
        exports['pulsar-objects']:PlacerStart(`prop_wooden_barrel`, "Drugs:Client:Moonshine:FinishPlacementBarrel", data,
            2)
        cb()
    end)

    exports["pulsar-core"]:RegisterClientCallback("Drugs:Moonshine:Use", function(data, cb)
        -- data should be { quality = number, recipeId = string }
        Wait(400)
        exports['pulsar-games']:MinigamePlayRoundSkillbar(0.8, 8, {
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
                animDict = "amb@world_human_drinking@coffee@male@idle_a",
                anim = "idle_c",
                flags = 48,
            },
            prop = {
                model = "prop_beer_bottle",
                bone = 28422,
                coords = { x = 0.0, y = 0.0, z = -0.15 },
                rotation = { x = 0.0, y = 0.0, z = 0.0 },
            },
        })
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:SetupStills", function(stills)
    CreateThread(function()
        loadModel(`prop_still`)
        for k, v in pairs(stills) do
            _stills[k] = v
            local obj = CreateObject(`prop_still`, v.coords.x, v.coords.y, v.coords.z, false, true, false)
            SetEntityHeading(obj, v.heading)
            while not DoesEntityExist(obj) do
                Wait(1)
            end
            PlaceObjectOnGroundProperly(obj)
            _stills[k].entity = obj
            Entity(obj).state.isMoonshineStill = true
            Entity(obj).state.stillId = v.id
            Wait(1)
        end
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:SetupBarrels", function(barrels)
    CreateThread(function()
        loadModel(`prop_wooden_barrel`)
        for k, v in pairs(barrels) do
            _barrels[k] = v
            local obj = CreateObject(`prop_wooden_barrel`, v.coords.x, v.coords.y, v.coords.z, false, true, false)
            SetEntityHeading(obj, v.heading)
            while not DoesEntityExist(obj) do
                Wait(1)
            end
            PlaceObjectOnGroundProperly(obj)
            _barrels[k].entity = obj
            Entity(obj).state.isMoonshineBarrel = true
            Entity(obj).state.barrelId = v.id
            Wait(1)
        end
    end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
    CreateThread(function()
        for k, v in pairs(_stills) do
            if v?.entity ~= nil and DoesEntityExist(v?.entity) then
                DeleteEntity(v?.entity)
                _stills[k] = nil
            end
            Wait(1)
        end
    end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
    CreateThread(function()
        for k, v in pairs(_barrels) do
            if v?.entity ~= nil and DoesEntityExist(v?.entity) then
                DeleteEntity(v?.entity)
                _barrels[k] = nil
            end
            Wait(1)
        end
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:CreateStill", function(still)
    CreateThread(function()
        loadModel(`prop_still`)
        _stills[still.id] = still
        local obj = CreateObject(`prop_still`, still.coords.x, still.coords.y, still.coords.z, false, true, false)
        SetEntityHeading(obj, still.heading)
        while not DoesEntityExist(obj) do
            Wait(1)
        end

        _stills[still.id].entity = obj

        Entity(obj).state.isMoonshineStill = true
        Entity(obj).state.stillId = still.id
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:RemoveStill", function(stillId)
    CreateThread(function()
        local objs = GetGamePool("CObject")
        for k, v in ipairs(objs) do
            local entState = Entity(v).state
            if entState.isMoonshineStill and entState.stillId == stillId then
                DeleteEntity(v)
            end
        end
        _stills[stillId] = nil
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:UpdateStillData", function(stillId, data)
    _stills[stillId] = data
end)

AddEventHandler("Drugs:Client:Moonshine:FinishPlacement", function(data, endCoords)
    TaskTurnPedToFaceCoord(LocalPlayer.state.ped, endCoords.coords.x, endCoords.coords.y, endCoords.coords.z, 0.0)
    Wait(1000)
    exports['pulsar-hud']:Progress({
        name = "meth_pickup",
        duration = (math.random(5) + 10) * 1000,
        label = "Placing",
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
            exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:FinishStillPlacement", {
                data = data,
                endCoords = endCoords
            }, function(s)

            end)
        end
    end)
end)

AddEventHandler("Drugs:Client:Moonshine:FinishPlacementBarrel", function(data, endCoords)
    TaskTurnPedToFaceCoord(LocalPlayer.state.ped, endCoords.coords.x, endCoords.coords.y, endCoords.coords.z, 0.0)
    Wait(1000)
    exports['pulsar-hud']:Progress({
        name = "meth_pickup",
        duration = 3 * 1000,
        label = "Placing",
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
            exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:FinishBarrelPlacement", {
                data = data,
                endCoords = endCoords
            }, function(s)

            end)
        end
    end)
end)

AddEventHandler("Drugs:Client:Moonshine:PickupStill", function(entity, data)
    if Entity(entity.entity).state?.isMoonshineStill then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = (math.random(5) + 15) * 1000,
            label = "Picking Up Still",
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
                exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:PickupStill", Entity(entity.entity).state
                    .stillId, function(s)
                        -- if s then
                        --     DeleteObject(entity.entity)
                        -- end
                    end)
            end
        end)
    end
end)

-- Store recipe selection data
local _recipeSelectionData = {}

AddEventHandler("Drugs:Client:Moonshine:StartCook", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMoonshineStill and entState.stillId then
        exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:CheckStill", entState.stillId, function(s)
            if s then
                -- Get still data to store tier
                local stillId = entState.stillId
                local still = _stills[stillId]
                local stillTier = 1
                
                if still and still.tier then
                    stillTier = still.tier
                end
                
                -- Get available recipes
                exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:GetRecipes", {}, function(recipeData)
                    if not recipeData then
                        exports["pulsar-hud"]:Notification("error", "Failed to load recipes")
                        return
                    end
                    
                    -- Store data for event handler (including tier)
                    _recipeSelectionData.stillId = stillId
                    _recipeSelectionData.stillTier = stillTier
                    _recipeSelectionData.recipes = recipeData.recipes
                    
                    -- Show recipe selection menu
                    local menuItems = {}
                    for k, recipe in ipairs(recipeData.recipes) do
                        local ingredientText = ""
                        for i, ing in ipairs(recipe.ingredients) do
                            ingredientText = ingredientText .. string.format("%d %s", ing.amount, ing.item)
                            if i < #recipe.ingredients then
                                ingredientText = ingredientText .. ", "
                            end
                        end
                        
                        table.insert(menuItems, {
                            label = recipe.unlocked and recipe.label or (recipe.label .. " (Locked)"),
                            description = recipe.unlocked and 
                                string.format("%s\nIngredients: %s\nBase Quality: %d", recipe.description, ingredientText, recipe.baseQuality) or
                                string.format("Requires %d reputation", recipe.requiredRep),
                            event = "Drugs:Client:Moonshine:SelectRecipe",
                            data = {
                                recipeId = recipe.id,
                            },
                            disabled = not recipe.unlocked,
                        })
                    end
                    
                    exports['pulsar-hud']:ListMenuShow({
                        main = {
                            label = "Select Recipe",
                            items = menuItems
                        }
                    })
                end)
            else
                exports["pulsar-hud"]:Notification("error", "Still Is Not Ready")
            end
        end)
    end
end)

-- Handle recipe selection
AddEventHandler("Drugs:Client:Moonshine:SelectRecipe", function(data)
    if not data or not data.recipeId or not _recipeSelectionData.stillId then
        return
    end
    
    local selectedRecipe = nil
    for k, recipe in ipairs(_recipeSelectionData.recipes) do
        if recipe.id == data.recipeId then
            selectedRecipe = recipe
            break
        end
    end
    
    if not selectedRecipe or not selectedRecipe.unlocked then
        exports["pulsar-hud"]:Notification("error", "Recipe is locked or invalid")
        return
    end
    
    -- Use stored tier from when we started the cook
    local stillTier = _recipeSelectionData.stillTier or 1
    local tierData = _stillTiers[stillTier]
    local checks = tierData and tierData.checks or 10
    
    -- Get temperature and weather (simplified - using time of day as temperature proxy)
    local hour = GetClockHours()
    local temperature = 20 -- Base temperature
    if hour >= 6 and hour < 12 then
        temperature = 15 + math.random(0, 10) -- Morning: 15-25
    elseif hour >= 12 and hour < 18 then
        temperature = 20 + math.random(0, 15) -- Afternoon: 20-35
    elseif hour >= 18 and hour < 22 then
        temperature = 15 + math.random(0, 10) -- Evening: 15-25
    else
        temperature = 5 + math.random(0, 10) -- Night: 5-15
    end
    
    -- Get weather using export function
    local currentWeather = exports["pulsar-sync"]:GetWeather() or "CLEAR"
    local weatherName = "clear"
    
    -- Convert weather string to our config format
    if currentWeather == "RAIN" then
        weatherName = "rain"
    elseif currentWeather == "THUNDER" then
        weatherName = "thunder"
    elseif currentWeather == "FOGGY" then
        weatherName = "foggy"
    elseif currentWeather == "CLOUDS" or currentWeather == "OVERCAST" or currentWeather == "CLEARING" then
        weatherName = "clouds"
    elseif currentWeather == "SNOW" or currentWeather == "SNOWLIGHT" or currentWeather == "BLIZZARD" or currentWeather == "XMAS" then
        weatherName = "snow"
    else
        -- EXTRASUNNY, CLEAR, SMOG, etc. = clear
        weatherName = "clear"
    end
    
    exports['pulsar-hud']:Progress({
        name = "moonshine_prepare",
        duration = 5 * 1000,
        label = "Preparing Ingredients",
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
            local results = RunSkillChecks(checks)

            LocalPlayer.state.doingAction = false

            exports['pulsar-hud']:Progress({
                name = "moonshine_finish",
                duration = 2 * 1000,
                label = "Starting Brew",
                useWhileDead = false,
                canCancel = false,
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
                    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:StartCooking", {
                        stillId = _recipeSelectionData.stillId,
                        recipeId = selectedRecipe.id,
                        results = results,
                        temperature = temperature,
                        weather = weatherName,
                    }, function(success)
                        if success then
                            exports["pulsar-hud"]:Notification("success", "Brew started successfully!")
                            -- Clear selection data after successful start
                            _recipeSelectionData = {}
                        else
                            exports["pulsar-hud"]:Notification("error", "Failed to start brew. Check your ingredients and still status.")
                        end
                    end)
                else
                    -- User cancelled, clear selection data
                    _recipeSelectionData = {}
                end
            end)
        end
    end)
end)

AddEventHandler("Drugs:Client:Moonshine:PickupCook", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMoonshineStill and entState.stillId then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = 5 * 1000,
            label = "Emptying Still",
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
                exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:PickupCook", entState.stillId, function(s)
                    if s then
                    else
                        exports["pulsar-hud"]:Notification("error", "Still Is Not Ready")
                    end
                end)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Moonshine:PickupBrew", function(entity, data)
    local entState = Entity(entity.entity).state
    if not entState.isMoonshineBarrel or not entState.barrelId then
        return
    end
    
    -- Convert barrelId to number for proper lookup
    local barrelId = tonumber(entState.barrelId)
    if not barrelId then
        return
    end
    
    local barrel = _barrels[barrelId]
    if not barrel then
        return
    end
    
    local requiredJars = barrel.brewData?.Drinks or 15
    
    -- Always show the progress bar, server will check for jars
    exports['pulsar-hud']:Progress({
        name = "meth_pickup",
        duration = 5 * 1000,
        label = "Emptying Barrel",
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
            exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:PickupBrew", barrelId,
                function(success)
                    -- Server will handle notifications for missing jars
                end)
        end
    end)
end)

AddEventHandler("Drugs:Client:Moonshine:StillDetails", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMoonshineStill and entState.stillId then
        exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:GetStillDetails", entState.stillId, function(s)
            if s then
                exports['pulsar-hud']:ListMenuShow(s)
            end
        end)
    end
end)

RegisterNetEvent("Drugs:Client:Moonshine:UpdateBarrelData", function(barrelId, data)
    _barrels[barrelId] = data
end)

RegisterNetEvent("Drugs:Client:Moonshine:CreateBarrel", function(barrel)
    CreateThread(function()
        loadModel(`prop_wooden_barrel`)
        _barrels[barrel.id] = barrel
        local obj = CreateObject(`prop_wooden_barrel`, barrel.coords.x, barrel.coords.y, barrel.coords.z, false, true,
            false)
        SetEntityHeading(obj, barrel.heading)
        PlaceObjectOnGroundProperly(obj)
        while not DoesEntityExist(obj) do
            Wait(1)
        end

        _barrels[barrel.id].entity = obj

        Entity(obj).state.isMoonshineBarrel = true
        Entity(obj).state.barrelId = barrel.id
    end)
end)

RegisterNetEvent("Drugs:Client:Moonshine:RemoveBarrel", function(barrelId)
    CreateThread(function()
        local objs = GetGamePool("CObject")
        for k, v in ipairs(objs) do
            local entState = Entity(v).state
            if entState.isMoonshineBarrel and entState.barrelId == barrelId then
                DeleteEntity(v)
            end
        end
        _barrels[barrelId] = nil
    end)
end)

AddEventHandler("Drugs:Client:Moonshine:PickupBarrel", function(entity, data)
    if Entity(entity.entity).state?.isMoonshineBarrel then
        exports['pulsar-hud']:Progress({
            name = "meth_pickup",
            duration = 8 * 1000,
            label = "Destroying",
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
                exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:PickupBarrel",
                    Entity(entity.entity).state.barrelId,
                    function(s)
                        -- if s then
                        --     DeleteObject(entity.entity)
                        -- end
                    end)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Moonshine:BarrelDetails", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMoonshineBarrel and entState.barrelId then
        exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:GetBarrelDetails", entState.barrelId, function(s)
            if s then
                exports['pulsar-hud']:ListMenuShow(s)
            end
        end)
    end
end)

AddEventHandler("Drugs:Client:Moonshine:UpgradeStill", function(entity, data)
    local entState = Entity(entity.entity).state
    if entState.isMoonshineStill and entState.stillId then
        exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:UpgradeStill", entState.stillId, function(success)
            if success then
                exports["pulsar-hud"]:Notification("success", "Still upgraded successfully!")
            end
        end)
    end
end)

-- Police Alert Handler
RegisterNetEvent("Drugs:Client:Moonshine:PoliceAlert", function(alertData)
    if LocalPlayer.state.onDuty == "police" then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(vector3(alertData.coords.x, alertData.coords.y, alertData.coords.z) - playerCoords)
        
        if distance <= 100.0 then -- Detection radius
            -- Create blip
            local blip = AddBlipForCoord(alertData.coords.x, alertData.coords.y, alertData.coords.z)
            SetBlipSprite(blip, 432)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 1.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Suspicious Moonshine Activity")
            EndTextCommandSetBlipName(blip)
            
            -- Remove blip after 5 minutes
            SetTimeout(300000, function()
                RemoveBlip(blip)
            end)
            
            exports['pulsar-hud']:Notification("info", 
                string.format("Moonshine activity detected! Heat: %d/100", alertData.heat))
        end
    end
end)

-- Delivery System
CreateThread(function()
    while true do
        Wait(1000)
        -- Check for delivery missions (could be triggered via command or phone app)
    end
end)

-- Command to start delivery
RegisterCommand("moonshinedelivery", function()
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:GetDelivery", {}, function(deliveryData)
        if deliveryData then
            -- Create waypoint
            SetNewWaypoint(deliveryData.coords.x, deliveryData.coords.y)
            exports["pulsar-hud"]:Notification("success", 
                string.format("Delivery mission started! Payment: $%d | Time limit: %d minutes", 
                    deliveryData.payment, deliveryData.timeLimit / 60))
            
            -- Create delivery marker
            CreateThread(function()
                local deliveryBlip = AddBlipForCoord(deliveryData.coords.x, deliveryData.coords.y, deliveryData.coords.z)
                SetBlipSprite(deliveryBlip, 1)
                SetBlipColour(deliveryBlip, 5)
                SetBlipRoute(deliveryBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Moonshine Delivery")
                EndTextCommandSetBlipName(deliveryBlip)
                
                while #(GetEntityCoords(PlayerPedId()) - deliveryData.coords) > 5.0 do
                    Wait(1000)
                end
                
                -- Complete delivery
                exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:CompleteDelivery", deliveryData.id, function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("success", "Delivery completed!")
                    else
                        exports["pulsar-hud"]:Notification("error", "Failed to complete delivery")
                    end
                    RemoveBlip(deliveryBlip)
                end)
            end)
        else
            exports["pulsar-hud"]:Notification("error", "Failed to start delivery mission")
        end
    end)
end, false)

-- Create Moonshine Dealer Ped
RegisterNetEvent("Drugs:Client:Moonshine:CreateDealer", function(data)
    -- Remove old vendor ped if it exists
    exports['pulsar-pedinteraction']:Remove("MoonshineSeller")
    
    exports['pulsar-pedinteraction']:Add(data.id, data.model, data.coords, data.heading, 50.0, {
        {
            icon = "fas fa-handshake",
            text = "Talk to Dealer",
            minDist = 2.0,
            onSelect = function()
                TriggerEvent("Drugs:Client:Moonshine:OpenDealerMenu")
            end,
        },
    }, "fas fa-handshake", data.scenario or false, nil, nil)
end)

-- Open Dealer Menu
RegisterNetEvent("Drugs:Client:Moonshine:OpenDealerMenu", function()
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:GetDealerOptions", {}, function(options)
        if not options then
            return
        end
        
        local menuItems = {}
        
        -- Drop Off option
        if options.dropOff.available then
            table.insert(menuItems, {
                label = options.dropOff.label,
                description = options.dropOff.description,
                event = "Drugs:Client:Moonshine:DealerDropOff",
                data = {},
            })
        else
            table.insert(menuItems, {
                label = options.dropOff.label .. " (Locked)",
                description = string.format("Need %d reputation", _deliverySystem.minRep),
                disabled = true,
            })
        end
        
        -- Bulk Sale option
        if options.bulkSale.available then
            table.insert(menuItems, {
                label = options.bulkSale.label,
                description = options.bulkSale.description,
                event = "Drugs:Client:Moonshine:DealerBulkSale",
                data = {},
            })
        else
            table.insert(menuItems, {
                label = options.bulkSale.label .. " (Locked)",
                description = string.format("Need %d reputation", _deliverySystem.bulkSaleRep),
                disabled = true,
            })
        end
        
        -- Travel option
        if options.travel.available then
            table.insert(menuItems, {
                label = options.travel.label,
                description = options.travel.description,
                event = "Drugs:Client:Moonshine:DealerTravel",
                data = {},
            })
        else
            table.insert(menuItems, {
                label = options.travel.label .. " (Locked)",
                description = string.format("Need %d reputation", _deliverySystem.travelRep),
                disabled = true,
            })
        end
        
        exports['pulsar-hud']:ListMenuShow({
            main = {
                label = "Moonshine Dealer",
                items = menuItems
            }
        })
    end)
end)

-- Handle Drop Off
local _activeDeliveryPeds = {}
local _currentDelivery = nil

RegisterNetEvent("Drugs:Client:Moonshine:DealerDropOff", function()
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:DealerDropOff", {}, function(result)
        if result and result.stops and #result.stops > 0 then
            _currentDelivery = {
                id = result.id,
                stops = result.stops,
                currentStop = 1,
                timeLimit = result.timeLimit,
            }
            
            -- Start first stop
            TriggerEvent("Drugs:Client:Moonshine:GoToStop", 1)
            
            exports["pulsar-hud"]:Notification("success", 
                string.format("Delivery route started! %d stops | Time limit: %d minutes", 
                    #result.stops, math.floor(result.timeLimit / 60)))
        else
            exports["pulsar-hud"]:Notification("error", "Failed to start drop off")
        end
    end)
end)

-- Go to a specific stop
RegisterNetEvent("Drugs:Client:Moonshine:GoToStop", function(stopIndex)
    if not _currentDelivery or not _currentDelivery.stops[stopIndex] then
        return
    end
    
    local stop = _currentDelivery.stops[stopIndex]
    
    -- Create waypoint and blip
    SetNewWaypoint(stop.coords.x, stop.coords.y)
    local deliveryBlip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
    SetBlipSprite(deliveryBlip, 1)
    -- Use orange color for travel (Cayo Perico), blue for drop-off
    local blipColor = (_currentDelivery.type == "travel") and 46 or 5
    SetBlipColour(deliveryBlip, blipColor)
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, blipColor)
    BeginTextCommandSetBlipName("STRING")
    local blipName = (_currentDelivery.type == "travel") and "Cayo Perico Delivery" or "Moonshine Delivery"
    AddTextComponentString(string.format("%s (Stop %d/%d)", blipName, stopIndex, #_currentDelivery.stops))
    EndTextCommandSetBlipName(deliveryBlip)
    
    -- Spawn ped at location
    local pedModels = {`a_m_m_hillbilly_01`, `a_m_m_hillbilly_02`, `a_m_y_hippy_01`, `a_m_y_hipster_02`, `a_m_m_tramp_01`}
    local pedModel = pedModels[math.random(#pedModels)]
    
    RequestModel(pedModel)
    local timeout = 0
    while not HasModelLoaded(pedModel) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(pedModel) then
        exports["pulsar-hud"]:Notification("error", "Failed to load ped model")
        return
    end
    
    local ped = CreatePed(4, pedModel, stop.coords.x, stop.coords.y, stop.coords.z, 0.0, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)
    TaskSetBlockingOfNonTemporaryEvents(ped, 1)
    SetBlockingOfNonTemporaryEvents(ped, 1)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedCombatAttributes(ped, 17, 1)
    SetEntityInvincible(ped, true)
    SetPedDefaultComponentVariation(ped)
    SetModelAsNoLongerNeeded(pedModel)
    
    -- Add target option
    exports.ox_target:addLocalEntity(ped, {
        {
            name = "moonshine_sell_ped",
            icon = "fas fa-handshake",
            label = "Sell Moonshine",
            distance = 2.0,
            onSelect = function()
                TriggerEvent("Drugs:Client:Moonshine:SellToPed", stopIndex)
            end,
        },
    })
    
    _activeDeliveryPeds[stopIndex] = {
        ped = ped,
        blip = deliveryBlip,
        model = pedModel,
    }
end)

-- Sell to ped at stop
RegisterNetEvent("Drugs:Client:Moonshine:SellToPed", function(stopIndex)
    if not _currentDelivery then
        return
    end
    
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:SellToPed", {
        deliveryId = _currentDelivery.id,
        stopIndex = stopIndex,
    }, function(result)
        if result then
            local pedData = _activeDeliveryPeds[stopIndex]
            if pedData and pedData.ped and DoesEntityExist(pedData.ped) then
                -- Make ped a normal NPC - remove special flags
                FreezeEntityPosition(pedData.ped, false)
                SetEntityInvincible(pedData.ped, false)
                SetPedCanRagdoll(pedData.ped, true)
                SetBlockingOfNonTemporaryEvents(pedData.ped, false)
                TaskSetBlockingOfNonTemporaryEvents(pedData.ped, 0)
                
                -- Make them wander away
                TaskWanderStandard(pedData.ped, 10.0, 10)
                
                -- Remove target option (they're now a normal NPC, let them roam free)
                exports.ox_target:removeLocalEntity(pedData.ped)
                
                -- Don't delete them - they're now part of the world and will despawn naturally
            end
            
            -- Remove blip
            if pedData and pedData.blip then
                RemoveBlip(pedData.blip)
            end
            
            _activeDeliveryPeds[stopIndex] = nil
            
            if result.completed then
                -- All stops done
                local deliveryType = _currentDelivery and _currentDelivery.type == "travel" and "Cayo Perico delivery" or "Delivery route"
                exports["pulsar-hud"]:Notification("success", 
                    string.format("%s complete! Total payment: $%d", deliveryType, result.payment))
                _currentDelivery = nil
            else
                -- Move to next stop
                local repMsg = result.repGain and string.format(" | Rep +%d", result.repGain) or ""
                exports["pulsar-hud"]:Notification("info", 
                    string.format("Stop %d complete! Moving to next stop...%s", stopIndex, repMsg))
                Wait(2000)
                TriggerEvent("Drugs:Client:Moonshine:GoToStop", result.nextStop)
            end
        else
            exports["pulsar-hud"]:Notification("error", "Failed to sell moonshine")
        end
    end)
end)

-- Handle Bulk Sale
RegisterNetEvent("Drugs:Client:Moonshine:DealerBulkSale", function()
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:DealerBulkSale", {}, function(success)
        if success then
            -- Already handled on server with notification
        else
            exports["pulsar-hud"]:Notification("error", "Failed to complete bulk sale")
        end
    end)
end)

-- Handle Travel (uses same system as drop-off but with Cayo Perico locations)
RegisterNetEvent("Drugs:Client:Moonshine:DealerTravel", function()
    exports["pulsar-core"]:ServerCallback("Drugs:Moonshine:DealerTravel", {}, function(result)
        if result and result.stops and #result.stops > 0 then
            _currentDelivery = {
                id = result.id,
                stops = result.stops,
                currentStop = 1,
                timeLimit = result.timeLimit,
                type = "travel",
            }
            
            -- Start first stop
            TriggerEvent("Drugs:Client:Moonshine:GoToStop", 1)
            
            exports["pulsar-hud"]:Notification("success",
                string.format("Cayo Perico delivery route started! %d stops | Time limit: %d minutes",
                    #result.stops, math.floor(result.timeLimit / 60)))
        else
            exports["pulsar-hud"]:Notification("error", "Failed to start travel delivery")
        end
    end)
end)
