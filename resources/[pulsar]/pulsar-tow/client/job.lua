AddEventHandler('Tow:Client:RequestJob', function()
    exports["pulsar-core"]:ServerCallback('Tow:RequestJob', {}, function(success)
        if success then
            exports["pulsar-hud"]:Notification("success", 'You are Now Employed at Tow Yard', 5000, 'truck-tow')
        else
            exports["pulsar-hud"]:Notification("error", 'Employement Request Failed', 5000, 'truck-tow')
        end
    end)
end)

AddEventHandler('Tow:Client:QuitJob', function()
    exports["pulsar-core"]:ServerCallback('Tow:QuitJob', {}, function(success)
        if not success then
            exports["pulsar-hud"]:Notification("error", 'Request to Quit Failed', 5000, 'truck-tow')
        end
    end)
end)

AddEventHandler('Tow:Client:OnDuty', function()
    exports["pulsar-core"]:ServerCallback('Tow:OnDuty', {})
end)

AddEventHandler('Tow:Client:OffDuty', function()
    exports["pulsar-core"]:ServerCallback('Tow:OffDuty', {})
end)

AddEventHandler('Tow:Client:RequestTruck', function()
    local availableSpace = GetClosestAvailableParkingSpace(LocalPlayer.state.myPos, _towSpaces)
    if availableSpace then
        exports["pulsar-core"]:ServerCallback('Tow:RequestTruck', availableSpace, function(vehNet)
            if vehNet ~= nil then
                SetEntityAsMissionEntity(NetToVeh(vehNet))
            end
        end)
    else
        exports["pulsar-hud"]:Notification("error", 'Parking Space Occupied, Move Out the Way!', 7500, 'truck-tow')
    end
end)

AddEventHandler('Tow:Client:ReturnTruck', function()
    exports["pulsar-core"]:ServerCallback('Tow:ReturnTruck', {})
end)

AddEventHandler('Tow:Client:RequestImpound', function(entityData)
    local myTowTruck = GlobalState[string.format('TowTrucks:%s', LocalPlayer.state.Character:GetData('SID'))]
    if myTowTruck then
        myTowTruck = NetToVeh(myTowTruck)
    end

    if entityData and entityData.entity and DoesEntityExist(entityData.entity) and (not myTowTruck or myTowTruck ~= entityData.entity) and #(GetEntityCoords(entityData.entity) - GetEntityCoords(LocalPlayer.state.ped)) <= 10.0 and IsVehicleEmpty(entityData.entity) and exports['pulsar-polyzone']:IsCoordsInZone(GetEntityCoords(entityData.entity), 'tow_impound_zone') then
        exports['pulsar-hud']:ProgressWithTickEvent({
            name = 'veh_impound',
            duration = 10 * 1000,
            label = 'Impounding Vehicle',
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            disarm = false,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                anim = 'clipboard',
            },
        }, function()
            if not DoesEntityExist(entityData.entity) or (#(GetEntityCoords(entityData.entity) - GetEntityCoords(LocalPlayer.state.ped)) > 10.0) or not IsVehicleEmpty(entityData.entity) then
                exports['pulsar-hud']:ProgressCancel()
            end
        end, function(cancelled)
            if not cancelled and DoesEntityExist(entityData.entity) and (#(GetEntityCoords(entityData.entity) - GetEntityCoords(LocalPlayer.state.ped)) <= 10.0) and IsVehicleEmpty(entityData.entity) then
                exports["pulsar-core"]:ServerCallback('Vehicles:Impound', {
                    vNet = VehToNet(entityData.entity),
                    type = 'impound',
                }, function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("success", 'Vehicle Impounded Successfully')
                    else
                        exports["pulsar-hud"]:Notification("error", 'Impound Failed Miserably')
                    end
                end)
            else
                exports["pulsar-hud"]:Notification("error", 'Impound Failed')
            end
        end)
    else
        exports["pulsar-hud"]:Notification("error", 'Cannot Impound That Vehicle')
    end
end)
