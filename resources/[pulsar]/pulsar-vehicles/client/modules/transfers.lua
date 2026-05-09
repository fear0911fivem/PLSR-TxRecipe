AddEventHandler("Vehicles:Client:StartUp", function()
    exports["pulsar-core"]:RegisterClientCallback("Vehicles:Transfers:GetTarget", function(data, cb)
        if LocalPlayer.state.loggedIn then
            if VEHICLE_INSIDE then
                return cb(VehToNet(VEHICLE_INSIDE))
            else
                local coords = GetEntityCoords(PlayerPedId())
                local maxDistance = 2.0
                local includePlayerVehicle = true

                local target = lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)

                if target and DoesEntityExist(target) and IsEntityAVehicle(target) then
                    return cb(VehToNet(target))
                end
            end
        end
        cb(false)
    end)
end)

RegisterNetEvent('Vehicles:Tranfers:BeginConfirmation', function(data)
    exports['pulsar-hud']:ConfirmShow(
        'Confirm Vehicle Ownership Transfer',
        {
            yes = 'Vehicles:Transfers:Confirm',
            no = 'Vehicles:Transfers:Deny',
        },
        string.format(
            [[
                Please confirm that you would like to transfer the vehicle below to State ID %s.<br>
                Vehicle: %s %s<br>
                Plate: %s<br>
                VIN: %s<br>
            ]],
            data.SID,
            data.Make or 'Unknown',
            data.Model or 'Unknown',
            data.Plate,
            data.VIN
        ),
        {
            VIN = data.VIN,
            SID = data.SID,
        },
        'Deny',
        'Confirm'
    )
end)

AddEventHandler('Vehicles:Transfers:Confirm', function(data)
    exports["pulsar-core"]:ServerCallback('Vehicles:Tranfers:CompleteTransfer', data)
end)

AddEventHandler('Vehicles:Transfers:Deny', function(data)
    exports['pulsar-hud']:Notification("error", 'Vehicle Transfer Cancelled')
end)
