local eventHandlers = {}
local _state = 0
local _position = nil
local _joiner = nil
local _blip = nil

AddEventHandler("Labor:Client:Setup", function()

end)

RegisterNetEvent("WeedRun:Client:OnDuty", function(joiner, time)
    _working = true
    _joiner = joiner
    LocalPlayer.state.weedJoiner = joiner

    eventHandlers["receive"] = RegisterNetEvent(string.format("WeedRun:Client:%s:Receive", joiner),
        function(location, pedModel)
            _state = 1
            _blip = exports["pulsar-blips"]:Add("WeedRun", "Buyer", location, 514, 11, 0.9, 2, false, true)
            SetNewWaypoint(location.x, location.y)
            exports['pulsar-pedinteraction']:Add("WeedDelivery", pedModel,
                vector3(location[1], location[2], location[3]), location[4],
                50.0, {
                    {
                        icon = "box-circle-check",
                        text = "Deliver Goods",
                        event = "WeedRun:Client:Deliver",
                        tempjob = "WeedRun",
                        item = "weed_brick",
                        isEnabled = function()
                            return _working and _state == 1
                        end,
                    },
                }, 'box-circle-check')
        end)
end)

AddEventHandler("WeedRun:Client:Deliver", function()
    exports['pulsar-hud']:Progress({
        name = 'weed-sale-1',
        duration = (math.random(5, 10) + 10) * 1000,
        label = "Inspecting Package",
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
        animation = false,
    }, function(cancelled)
        if not cancelled then
            exports["pulsar-core"]:ServerCallback("WeedRun:StartDropoff", {}, function(r)
                exports['pulsar-hud']:Progress({
                    name = 'weed-sale-2',
                    duration = (math.random(15, 45) + 45) * 1000,
                    label = "Counting Bills",
                    useWhileDead = false,
                    canCancel = true,
                    vehicle = false,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableCombat = true,
                    },
                    animation = false,
                }, function(cancelled)
                    if not cancelled then
                        exports["pulsar-core"]:ServerCallback("WeedRun:DoDropoff", {}, function(r2)
                            if r2 then
                                exports["pulsar-blips"]:Remove("WeedRun")
                                _state = 2
                            end
                        end)
                    end
                end)
            end)
        end
    end)
end)

AddEventHandler("WeedRun:Client:Enable", function()
    exports["pulsar-core"]:ServerCallback('WeedRun:Enable', {})
end)

AddEventHandler("WeedRun:Client:Disable", function()
    exports["pulsar-core"]:ServerCallback('WeedRun:Disable', {})
end)

AddEventHandler("WeedRun:Client:StartJob", function()
    exports["pulsar-core"]:ServerCallback('WeedRun:StartJob', _joiner, function(state)
        if not state then
            exports["pulsar-hud"]:Notification("error", "Unable To Start Job")
        end
    end)
end)

RegisterNetEvent("WeedRun:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    exports['pulsar-pedinteraction']:Remove("WeedDelivery")
    exports["pulsar-blips"]:Remove("WeedDelivery")
end)
