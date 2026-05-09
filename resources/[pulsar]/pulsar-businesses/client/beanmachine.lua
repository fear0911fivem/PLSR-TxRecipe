AddEventHandler('Businesses:Client:Startup', function()
    exports['pulsar-polyzone']:CreateBox('beanmachine_door', vector3(115.34, -1038.95, 29.29), 1.6, 2.8, {
        heading = 250,
        --debugPoly=true,
        minZ = 28.29,
        maxZ = 31.09
    }, {
        minH = 200.0,
        maxH = 300.0,
    })

    exports['pulsar-polyzone']:CreateBox('beanmachine_sidedoor', vector3(127.37, -1029.97, 29.29), 1.6, 1.8, {
        heading = 250,
        --debugPoly=true,
        minZ = 28.29,
        maxZ = 31.09
    }, {
        minH = 128.255,
        maxH = 204.710,
    })
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
    if id == 'beanmachine_door' or id == 'beanmachine_sidedoor' then
        local h = GetEntityHeading(LocalPlayer.state.ped)
        if h >= data.minH and h <= data.maxH then
            exports["pulsar-sounds"]:PlayDistance(15, "bell.ogg", 0.3)
        end
    end
end)
