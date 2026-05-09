EDITING_VEHICLE = nil

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        exports['pulsar-hud']:InteractionRegisterMenu("veh_wheels", false, "tire", function()
            OpenWheelMenu()
            exports['pulsar-hud']:InteractionHide()
        end, function()
            local pedCoords = GetEntityCoords(LocalPlayer.state.ped)

            local insideZone = exports['pulsar-polyzone']:IsCoordsInZone(pedCoords, false, 'veh_customs_wheels')
            if
                insideZone?.veh_customs_wheels
                and LocalPlayer.state.onDuty
                and insideZone.veh_customs_wheels == LocalPlayer.state.onDuty
                and exports['pulsar-jobs']:HasJob(LocalPlayer.state.onDuty, false, false, 90) then
                return true
            end
            return false
        end)
    end
end)

local fitmentVehicles = {}

RegisterNetEvent('Characters:Client:Spawn')
AddEventHandler('Characters:Client:Spawn', function()
    StartFitmentThread()
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    RunVehicleCleanup()
end)

RegisterNetEvent('Fitment:Client:CamberController:UseItem', function()
    OpenControllerMenu()
end)

RegisterNetEvent('Fitment:Client:Update', function(netId, data)
    if LocalPlayer.state.loggedIn then
        if fitmentVehicles[netId] and fitmentVehicles[netId].veh then
            if data then
                fitmentVehicles[netId] = {
                    veh = fitmentVehicles[netId].veh,
                    data = data,
                }

                if v ~= EDITING_VEHICLE and data?.width then
                    SetVehicleWheelWidth(v, data.width + 0.0)
                end
            else
                fitmentVehicles[netId] = nil
            end
        end
    end
end)

function RunVehicleCleanup()
    for k, v in pairs(fitmentVehicles) do
        if not v?.veh or not DoesEntityExist(v?.veh) then
            fitmentVehicles[k] = nil
        end
    end
end

function RunFitmentDataUpdate()
    local vPool = GetGamePool('CVehicle')
    for k, v in ipairs(vPool) do
        if NetworkGetEntityIsNetworked(v) then
            local fitmentData = Entity(v)?.state?.WheelFitment
            if fitmentData then
                fitmentVehicles[VehToNet(v)] = {
                    veh = v,
                    data = fitmentData,
                }

                if fitmentData.width and v ~= EDITING_VEHICLE then
                    SetVehicleWheelWidth(v, fitmentData.width + 0.0)
                end
            end
        end
    end
end

function StartFitmentThread()
    CreateThread(function()
        local tick = 0
        while LocalPlayer.state.loggedIn do
            RunFitmentDataUpdate()
            Wait(5000)

            if tick >= 5 then
                tick = 0
                RunVehicleCleanup()
            else
                tick = tick + 1
            end
        end
    end)

    CreateThread(function()
        while LocalPlayer.state.loggedIn do
            Wait(1)
            for k, v in pairs(fitmentVehicles) do
                if v?.veh and v.veh ~= EDITING_VEHICLE and DoesEntityExist(v.veh) then
                    SetVehicleFrontTrackWidth(v.veh, v?.data?.frontTrack)
                    SetVehicleRearTrackWidth(v.veh, v?.data?.rearTrack)
                    SetVehicleFrontCamber(v.veh, v?.data?.frontCamber)
                    SetVehicleRearCamber(v.veh, v?.data?.rearCamber)
                end
            end
        end
    end)
end
