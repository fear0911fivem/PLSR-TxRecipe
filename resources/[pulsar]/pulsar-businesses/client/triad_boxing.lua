AddEventHandler("Businesses:Client:Startup", function()
    exports.ox_target:addBoxZone({
        id = "triad_boxing_receptionist",
        coords = vector3(1072.02, -2400.65, 25.9),
        size = vector3(1.8, 0.6, 1.4),
        rotation = 355,
        debug = false,
        minZ = 24.9,
        maxZ = 26.3,
        options = {
            {
                icon = "door-open",
                label = "Lock/Unlock Arena Door",
                event = "Businesses:Client:ToggleTriadBoxingLock",
                groups = { "triad_boxing" },
                reqDuty = true,
            },
        }
    })
end)

AddEventHandler("Businesses:Client:ToggleTriadBoxingLock", function()
    exports["pulsar-core"]:ServerCallback("Doors:ToggleLocks", "triad_boxing_arena", function(success, newState)
        if success then
            exports["pulsar-sounds"]:PlayOne("doorlocks.ogg", 0.2)
        end
    end)
end)
