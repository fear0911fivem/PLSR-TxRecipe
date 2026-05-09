exports("RadioAddToChannel", function(source, radioChannel)
	if not voiceData[source] then return end
	exports['pulsar-core']:LoggerTrace('VOIP', ('Adding %s to Radio Channel %s'):format(source, radioChannel))
	radioData[radioChannel] = radioData[radioChannel] or {}
	for player, _ in pairs(radioData[radioChannel]) do
		TriggerClientEvent('VOIP:Radio:Client:AddPlayerToRadio', player, source)
	end

	voiceData[source].Radio = radioChannel
	radioData[radioChannel][source] = false

	local sendingCoords = {}
	local sendingInVeh = {}
	for k, v in pairs(radioData[radioChannel]) do
		if v then
			local ped = GetPlayerPed(k)
			local coords = GetEntityCoords(ped)
			local tpCoords = Player(k)?.state?.tpLocation
			if tpCoords then
				coords = vector3(tpCoords.x, tpCoords.y, tpCoords.z)
			end

			sendingCoords[k] = coords
			sendingInVeh[k] = GetVehiclePedIsIn(ped, false)
		end
	end

	TriggerClientEvent('VOIP:Radio:Client:SyncRadioData', source, radioData[radioChannel], sendingCoords,
		sendingInVeh)
end)

exports("RadioRemoveFromChannel", function(source, radioChannel)
	exports['pulsar-core']:LoggerTrace('VOIP',
		('Removing %s from Radio Channel %s'):format(source, radioChannel))

	radioData[radioChannel] = radioData[radioChannel] or {}
	for player, _ in pairs(radioData[radioChannel]) do
		TriggerClientEvent('VOIP:Radio:Client:RemovePlayerFromRadio', player, source)
	end

	radioData[radioChannel][source] = nil

	if voiceData[source] then
		voiceData[source].Radio = 0
	end
end)

exports("RadioSetChannel", function(source, radioChannel)
	local radioChannel = tonumber(radioChannel)
	local plyVoice = voiceData[source]
	if not plyVoice or not radioChannel then return end

	if radioChannel ~= 0 and plyVoice.Radio == 0 then
		exports["pulsar-voip"]:RadioAddToChannel(source, radioChannel)
	elseif radioChannel == 0 and plyVoice.Radio > 0 then
		exports["pulsar-voip"]:RadioRemoveFromChannel(source, plyVoice.Radio)
	elseif plyVoice.Radio > 0 then
		exports["pulsar-voip"]:RadioRemoveFromChannel(source, plyVoice.Radio)
		exports["pulsar-voip"]:RadioAddToChannel(source, radioChannel)
	end
	TriggerClientEvent('VOIP:Radio:Client:SetPlayerRadio', source, radioChannel)
end)

exports("RadioSetTalking", function(source, talking, extendo)
	local plyVoice = voiceData[source]
	if not plyVoice then return end

	local radioChannelData = radioData[plyVoice.Radio]
	if not radioChannelData then return end

	local ped = GetPlayerPed(source)
	local pedCoords = GetEntityCoords(ped)
	local pedVeh = GetVehiclePedIsIn(ped, false)

	local tpCoords = Player(source).state?.tpLocation
	if tpCoords then
		pedCoords = vector3(tpCoords.x, tpCoords.y, tpCoords.z)
	end

	for player, _ in pairs(radioChannelData) do
		if player ~= source then
			TriggerClientEvent('VOIP:Radio:Client:SetPlayerTalkState', player, source, talking, extendo,
				pedCoords, pedVeh)
		end
	end
end)

RegisterServerEvent('VOIP:Radio:Server:SetChannel', function(targetChannel)
	exports["pulsar-voip"]:RadioSetChannel(source, targetChannel)
end)

RegisterServerEvent('VOIP:Radio:Server:SetTalking', function(isTalking, extendo)
	exports["pulsar-voip"]:RadioSetTalking(source, isTalking, extendo)
end)
