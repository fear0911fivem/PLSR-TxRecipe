local Config = require('shared.config')

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        for k, v in ipairs(Config.LogoutLocations) do
            exports.ox_target:addBoxZone({
                id = "logout-location-" .. k,
                coords = v.center,
                size = vector3(v.length, v.width, 2.0),
                rotation = v.options.heading or 0,
                debug = false,
                minZ = v.options.minZ,
                maxZ = v.options.maxZ,
                options = {
                    {
                        icon = "person-from-portal",
                        label = "Logout",
                        event = "Locations:Client:LogoutLocation",
                    },
                }
            })
        end
    end
end)

exports("GetAllLocations", function(type, cb)
    exports["pulsar-core"]:ServerCallback('Locations:GetAll', {
        type = type
    }, cb)
end)

AddEventHandler('Locations:Client:LogoutLocation', function()
    exports['pulsar-characters']:Logout()
end)

AddEventHandler("Characters:Client:Spawn", function()
    CreateThread(function()
        while LocalPlayer.state.loggedIn do
            Wait(60000)

            if not LocalPlayer.state.tpLocation then
                local coords = GetEntityCoords(PlayerPedId())
                if LocalPlayer.state.loggedIn and coords and #(coords - vector3(0.0, 0.0, 0.0)) >= 10.0 then
                    TriggerServerEvent('Characters:Server:LastLocation', coords)
                end
            end
        end
    end)
end)
