function StartUsingGag()
	if PLAYER_CONNECTED and (not CALL_CHANNEL or CALL_CHANNEL <= 0) and not RADIO_TALKING and not USING_MICROPHONE then
		CreateThread(function()
			exports['pulsar-core']:LoggerInfo("VOIP", "Gag Enabled")
			USING_GAG = true
			UpdateVOIPIndicatorStatus()
			while
				_characterLoaded
				and USING_GAG
				and (not CALL_CHANNEL or CALL_CHANNEL <= 0)
				and not LocalPlayer.state.isDead
				and not USING_MICROPHONE
			do
				TriggerServerEvent("VOIP:Server:Gag:SetPlayerState", true)

				Wait(7500)
			end

			StopUsingGag()
		end)
	end
end

function StopUsingGag()
	if USING_GAG then
		exports['pulsar-core']:LoggerInfo("VOIP", "Gag Off")
		USING_GAG = false
		TriggerServerEvent("VOIP:Server:Gag:SetPlayerState", false)

		UpdateVOIPIndicatorStatus()
	end
end

RegisterNetEvent("VOIP:Client:Gag:SetPlayerState", function(targetSource, state)
	if VOIP ~= nil and LocalPlayer.state.loggedIn then
		exports["pulsar-voip"]:ToggleVoice(targetSource, state, "gag")
	end
end)

RegisterNetEvent("VOIP:Client:Gag:Use", function()
	if not USING_GAG then
		StartUsingGag()
	else
		StopUsingGag()
	end
end)
