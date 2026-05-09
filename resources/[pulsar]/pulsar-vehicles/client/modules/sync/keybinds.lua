AddEventHandler('Vehicles:Client:StartUp', function()
    exports["pulsar-kbs"]:Add('emergency_lights', 'Q', 'keyboard', 'Vehicle - Toggle Emergency Lighting',
        function()
            exports['pulsar-vehicles']:SyncEmergencyLightsToggle()
        end)

    exports["pulsar-kbs"]:Add('emergency_sirens', 'LMENU', 'keyboard', 'Vehicle - Toggle Emergency Sirens',
        function()
            exports['pulsar-vehicles']:SyncEmergencySirenToggle()
        end)

    exports["pulsar-kbs"]:Add('emergency_sirens_tone', 'R', 'keyboard', 'Vehicle - Cycle Emergency Siren Tone',
        function()
            exports['pulsar-vehicles']:SyncEmergencySirenCycle()
        end)

    exports["pulsar-kbs"]:Add('emergency_airhorn', 'E', 'keyboard', 'Vehicle - Emergency Airhorn', function()
        exports['pulsar-vehicles']:SyncEmergencyAirhornSet(true)
    end, function()
        exports['pulsar-vehicles']:SyncEmergencyAirhornSet(false)
    end)

    exports["pulsar-kbs"]:Add('veh_indicators_hazards', '', 'keyboard', 'Vehicle - Indicator - Hazards', function()
        exports['pulsar-vehicles']:SyncIndicatorsSet(0)
    end)

    exports["pulsar-kbs"]:Add('veh_indicators_right', '', 'keyboard', 'Vehicle - Indicator - Right', function()
        exports['pulsar-vehicles']:SyncIndicatorsSet(1)
    end)

    exports["pulsar-kbs"]:Add('veh_indicators_left', '', 'keyboard', 'Vehicle - Indicator - Left', function()
        exports['pulsar-vehicles']:SyncIndicatorsSet(2)
    end)

    exports["pulsar-kbs"]:Add('veh_neons_toggle', '', 'keyboard', 'Vehicle - Toggle Neons/Underglow', function()
        exports['pulsar-vehicles']:SyncNeonsToggle()
    end)

    exports["pulsar-kbs"]:Add('veh_bike_drop', 'G', 'keyboard', 'Vehicle - Put Down Bicycle', function()
        exports['pulsar-vehicles']:SyncBikeDrop()
    end)

    exports["pulsar-kbs"]:Add('veh_k9_leavevehicle', '', 'keyboard', 'Vehicle - K9 - Get Out of Vehicle',
        function()
            if LocalPlayer.state.isK9Ped then
                TriggerEvent("Vehicles:Client:K9LeaveVehicle")
            end
        end)
end)
