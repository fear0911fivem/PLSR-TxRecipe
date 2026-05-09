local radioRanges = {
	radio = {
		min = 0.0,
		max = 600.0,
	},
	radio_med = {
		min = 600.0,
		max = 1200.0,
	},
	radio_far = {
		min = 1200.0,
		max = 1800.0,
	},
	radio_really_far = {
		min = 1800.0,
		max = 2400.0,
	}
}

function GetRadioSubmixType(isExtendo, playerCoords, playerVeh)
	if RADIO_CHANNEL >= 100 then -- Shitty Radio
		local isInVehicle = playerVeh and playerVeh > 0

		local myCoords = GetEntityCoords(LocalPlayer.state.ped)
		if LocalPlayer.state.tpLocation then
			myCoords = vector3(LocalPlayer.state.tpLocation.x, LocalPlayer.state.tpLocation.y,
				LocalPlayer.state.tpLocation.z)
		end

		local dist = #(myCoords - playerCoords)
		if isExtendo then
			dist *= 0.5

			if playerVeh and playerVeh > 0 then
				dist *= 0.35
			end
		else
			if playerVeh and playerVeh > 0 then
				dist *= 0.75
			end
		end

		local filter = false
		for k, v in pairs(radioRanges) do
			if dist >= v.min and dist < v.max then
				filter = k
			end
		end

		if filter then
			return filter, false
		else
			return false, 0.0
		end
	else
		return "radio", false
	end
end

RegisterNetEvent('VOIP:Radio:Client:SyncRadioData', function(radioData, coordsData, vehData)
	RADIO_DATA = radioData
	exports['pulsar-core']:LoggerTrace('VOIP', 'Syncing Radio')
	for tgt, talking in pairs(RADIO_DATA) do
		if tgt ~= PLAYER_SERVER_ID then
			if talking then
				local submix, vol = GetRadioSubmixType(coordsData[tgt], vehData[tgt])
				exports["pulsar-voip"]:ToggleVoice(tgt, talking, submix, vol)
			else
				exports["pulsar-voip"]:ToggleVoice(tgt, false)
			end
		end
	end
end)

RegisterNetEvent('VOIP:Radio:Client:SetPlayerTalkState',
	function(targetSource, isTalking, isExtendo, playerCoords, inVeh)
		if isTalking then
			local submix, vol = GetRadioSubmixType(isExtendo, playerCoords, inVeh)

			exports["pulsar-voip"]:ToggleVoice(targetSource, isTalking, submix, vol)
		else
			exports["pulsar-voip"]:ToggleVoice(targetSource, false)
		end

		RADIO_DATA[targetSource] = isTalking
		exports["pulsar-voip"]:MicClicks(isTalking)
	end)

RegisterNetEvent('VOIP:Radio:Client:AddPlayerToRadio', function(targetSource)
	exports['pulsar-core']:LoggerTrace('VOIP', ('%s Joined Current Radio Channel'):format(targetSource))
	RADIO_DATA[targetSource] = false
	if RADIO_TALKING then
		exports["pulsar-voip"]:SetPlayerTargets(RADIO_DATA, PLAYER_TALKING and CALL_DATA or {})
	end
end)

RegisterNetEvent('VOIP:Radio:Client:RemovePlayerFromRadio', function(targetSource)
	if targetSource == PLAYER_SERVER_ID then
		exports['pulsar-core']:LoggerTrace('VOIP', 'Leaving Current Radio Channel - Clearing Up')
		for tgt, enabled in pairs(RADIO_DATA) do
			if tgt ~= PLAYER_SERVER_ID then
				exports["pulsar-voip"]:ToggleVoice(tgt, false)
			end
		end
		RADIO_DATA = {}
		exports["pulsar-voip"]:SetPlayerTargets({}, PLAYER_TALKING and CALL_DATA or {})
	else
		exports['pulsar-core']:LoggerTrace('VOIP', ('%s Left Current Radio Channel'):format(targetSource))
		RADIO_DATA[targetSource] = nil
		exports["pulsar-voip"]:ToggleVoice(targetSource, false)
		if RADIO_TALKING then
			exports["pulsar-voip"]:SetPlayerTargets(RADIO_DATA, PLAYER_TALKING and CALL_DATA or {})
		end
	end
end)

function RadioKeyDown()
	if not RADIO_TALKING and RADIO_CHANNEL and RADIO_CHANNEL > 0 and not LocalPlayer.state.isDead then
		StopUsingMegaphone()
		LoadAnim('random@arrests')
		exports['pulsar-core']:LoggerTrace('VOIP', 'Starting Radio Broadcast')
		exports["pulsar-voip"]:SetPlayerTargets(RADIO_DATA, PLAYER_TALKING and CALL_DATA or {})
		TriggerServerEvent('VOIP:Radio:Server:SetTalking', true, LocalPlayer.state.radioType == 2)
		RADIO_TALKING = true
		exports["pulsar-voip"]:MicClicks(true)
		UpdateVOIPIndicatorStatus()
		CreateThread(function()
			while RADIO_TALKING and _characterLoaded do
				Wait(0)

				local aiming = IsPlayerFreeAiming(LocalPlayer.state.PlayerID)

				SetControlNormal(0, 249, 1.0)
				SetControlNormal(1, 249, 1.0)
				SetControlNormal(2, 249, 1.0)

				if not aiming and not IsEntityPlayingAnim(LocalPlayer.state.ped, 'random@arrests', 'generic_radio_chatter', 3) then
					TaskPlayAnim(LocalPlayer.state.ped, 'random@arrests', 'generic_radio_chatter', 8.0, 0.0, -1, 49, 0,
						false, false, false)
				elseif aiming and not IsEntityPlayingAnim(LocalPlayer.state.ped, 'random@arrests', 'radio_chatter', 3) then
					TaskPlayAnim(LocalPlayer.state.ped, 'random@arrests', 'radio_chatter', 8.0, 0.0, -1, 49, 0, false,
						false, false)
				end
			end

			StopAnimTask(PlayerPedId(), 'random@arrests', 'generic_radio_chatter', 3.0)
			StopAnimTask(PlayerPedId(), 'random@arrests', 'radio_chatter', 3.0)
		end)
	end
end

function RadioKeyUp()
	if RADIO_CHANNEL and RADIO_CHANNEL > 0 and RADIO_TALKING then
		exports['pulsar-core']:LoggerTrace('VOIP', 'Stopping Radio Broadcast')
		RADIO_TALKING = false
		TriggerServerEvent('VOIP:Radio:Server:SetTalking', false)
		MumbleClearVoiceTargetPlayers(1)
		exports["pulsar-voip"]:MicClicks(false)
		UpdateVOIPIndicatorStatus()
	end
end

AddEventHandler('Ped:Client:Died', function()
	RadioKeyUp()
end)

RegisterNetEvent('VOIP:Radio:Client:SetPlayerRadio', function(channel)
	RADIO_CHANNEL = channel
	exports['pulsar-core']:LoggerTrace('VOIP', ('New Radio Channel: %s'):format(channel))
	UpdateVOIPIndicatorStatus()
end)
