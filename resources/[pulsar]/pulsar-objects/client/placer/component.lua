_placing = false
_placeData = nil
placementCoords = nil
isValid = false

RegisterNetEvent("Characters:Client:Logout", function()
    _placeData = nil
end)

exports('PlacerStart',
    function(model, finishEvent, data, allowedInterior, cancelEvent, useGizmo, isFurniture, startCoords, startHeading,
             startRotation, maxDistOverride)
        if _placing or IsPedInAnyVehicle(PlayerPedId()) then
            return
        end

        _placing = true
        _placeData = {
            finishEvent = finishEvent,
            cancelEvent = cancelEvent,
            data = data,
        }

        placementCoords = nil
        isValid = false

        RunPlacementThread(model, allowedInterior, useGizmo, isFurniture, startCoords, startHeading, startRotation,
            maxDistOverride)
    end)

exports('PlacerEnd', function()
    _placing = false
    if isValid then
        TriggerEvent(_placeData.finishEvent, _placeData.data, placementCoords)
    else
        if _placeData?.cancelEvent then
            TriggerEvent(_placeData.cancelEvent, _placeData.data, true)
        end
        exports["pulsar-hud"]:Notification("error", "Invalid Object Placement")
    end

    placementCoords = nil
    isValid = false
    _placeData = nil
end)

exports('PlacerCancel', function(skipNotification, skipEvent)
    _placing = false
    if not skipEvent and _placeData?.cancelEvent then
        TriggerEvent(_placeData.cancelEvent, _placeData.data)
    end

    if not skipNotification then
        exports["pulsar-hud"]:Notification("error", "Object Placement Cancelled")
    end

    placementCoords = nil
    isValid = false
    _placeData = nil
end)

AddEventHandler("Keybinds:Client:KeyDown:primary_action", function()
    if _placeData ~= nil then
        exports['pulsar-objects']:PlacerEnd()
    end
end)

AddEventHandler("Keybinds:Client:KeyDown:cancel_action", function()
    if _placeData ~= nil then
        exports['pulsar-objects']:PlacerCancel()
    end
end)
