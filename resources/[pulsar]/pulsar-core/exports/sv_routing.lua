local hiddenRoute = 1
local globalRoute = 0
local routeId = 2

local _routes = {}

exports("GetPlayerRoute", function(source)
    local playerState = Player(source).state
    return {
        state = playerState["currentRoute"],
        oldRoute = playerState["oldRoute"],
        route = GetPlayerRoutingBucket(source)
    }
end)

exports("AddPlayerToRoute", function(source, route, force)
    local playerState = Player(source).state
    if playerState["currentRoute"] == route and not force then
        exports['pulsar-core']:LoggerTrace("Routing",
            tostring(source) .. " is already routed to " .. tostring(route))
        return
    end
    local currentRoute = GetPlayerRoutingBucket(source)
    playerState["oldRoute"] = currentRoute
    SetPlayerRoutingBucket(source, route)
    playerState["currentRoute"] = route
    TriggerClientEvent("Routing:Client:NewRoute", source, route)
    exports['pulsar-core']:LoggerTrace("Routing",
        "Routed " .. tostring(source) .. " from " .. tostring(currentRoute) .. " to " .. tostring(route))

    local ped = GetPlayerPed(source)
    if ped then
        for k, v in ipairs(GetAllObjects()) do
            if DoesEntityExist(v) and GetEntityAttachedTo(v) == ped then
                SetEntityRoutingBucket(v, route)
            end
        end
    end
end)

exports("RoutePlayerToHiddenRoute", function(source)
    exports["pulsar-core"]:AddPlayerToRoute(source, hiddenRoute, true)
end)

exports("RoutePlayerToGlobalRoute", function(source)
    exports["pulsar-core"]:AddPlayerToRoute(source, globalRoute, true)
end)

--Get or Create
exports("RequestRouteId", function(name, population)
    if _routes[name] then
        exports['pulsar-core']:LoggerTrace("Routing",
            "Returning Route " .. name .. " as " .. _routes[name])
        return _routes[name]
    end
    return exports["pulsar-core"]:CreateRouteId(name, population)
end)

--Explicit Create
exports("CreateRouteId", function(name, population)
    --This is a race condition I KNOW
    routeId = routeId + 1
    exports['pulsar-core']:LoggerTrace("Routing",
        "Creating new Route with name: " .. name .. " with id " .. tostring(routeId))
    _routes[name] = routeId
    SetRoutingBucketPopulationEnabled(routeId, population)
    return routeId
end)

--Explicit Get
exports("GetRouteId", function(name, population)
    if _routes[name] then
        exports['pulsar-core']:LoggerTrace("Routing",
            "Returning Route " .. name .. " as " .. tostring(_routes[name]))
        return _routes[name]
    end
    exports['pulsar-core']:LoggerError("Routing", "Getting non-existing Route with name " .. name)
end)

--Use sparingly since recreating will eventually cause integer overflow
exports("RemoveRouteId", function(name)
    if _routes[name] then
        _routes[name] = nil
        exports['pulsar-core']:LoggerWarn("Routing", "Removed Routing to " .. name)
        return
    end
    exports['pulsar-core']:LoggerError("Routing", "Attempting to remove invalid Route with name " .. name)
end)

exports("MoveEntityToGlobalRoute", function(entityId)
    SetEntityRoutingBucket(entityId, globalRoute)
end)
