-- Rhodinium - Submixing for underwater voice & vehicle submixes

AddEventHandler("Characters:Client:Spawn", function()
    local hasSubmix = false
	CreateThread(function()
		while LocalPlayer.state.loggedIn do
			if IsPedSwimmingUnderWater(LocalPlayer.state.ped) then
                if not hasSubmix then
                    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 1)
                    hasSubmix = true
                    exports["pulsar-core"]:LoggerTrace("VOIP", "Adding Underwater Submix")
                end
            else
                if hasSubmix then
                    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
                    hasSubmix = false
                    exports["pulsar-core"]:LoggerTrace("VOIP", "Removing Underwater Submix")
                end
            end

            Wait(1000)
		end
	end)
end)

function EnableSubmix()
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_low`, 1250.0)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_hi`, 8500.0)
    SetAudioSubmixEffectParamFloat(0, 0, `fudge`, 0.5)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_mix`, 19.0)
end

function DisableSubmix()
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
end


local soundmix = false

AddEventHandler("Vehicles:Client:EnterVehicle", function(veh, seat, class)
	local vehmodel = GetEntityModel(veh)
    if IsThisModelAHeli(vehmodel) or IsThisModelAPlane(vehmodel) then
        if soundmix == false then
            exports["pulsar-core"]:LoggerTrace("VOIP", "Adding ATC Submix")
            EnableSubmix()
            soundmix = true
        end
    end
end)

AddEventHandler("Vehicles:Client:ExitVehicle", function(veh)
	exports["pulsar-core"]:LoggerTrace('VOIP', 'Removing ATC Submix')
    DisableSubmix()
    soundmix = false
end)
