exports("AddToCall", function(source, callChannel)
	if not voiceData[source] then
		return
	end
	exports['pulsar-core']:LoggerTrace("VOIP", ("Adding %s to Call %s"):format(source, callChannel))
	callData[callChannel] = callData[callChannel] or {}
	for player, _ in pairs(callData[callChannel]) do
		if player ~= source then
			TriggerClientEvent("VOIP:Phone:Client:AddPlayerToCall", player, source)
		end
	end
	callData[callChannel][source] = false
	voiceData[source].Call = callChannel
	TriggerClientEvent("VOIP:Phone:Client:SyncCallData", source, callData[callChannel])
end)

exports("RemoveFromCall", function(source, callChannel)
	if not voiceData[source] then
		return
	end
	exports['pulsar-core']:LoggerTrace("VOIP", ("Removing %s from Call %s"):format(source, callChannel))

	callData[callChannel] = callData[callChannel] or {}
	for player, _ in pairs(callData[callChannel]) do
		TriggerClientEvent("VOIP:Phone:Client:RemovePlayerFromCall", player, source)
	end

	callData[callChannel][source] = nil
	voiceData[source].Call = 0
end)

exports("SetCall", function(source, callChannel)
	local plyVoice = voiceData[source]
	local callChannel = tonumber(callChannel)
	if not plyVoice or not callChannel then
		return
	end

	if callChannel ~= 0 and plyVoice.Call == 0 then
		exports["pulsar-voip"]:AddToCall(source, callChannel)
	elseif callChannel == 0 and plyVoice.Call > 0 then
		exports["pulsar-voip"]:RemoveFromCall(source, plyVoice.Call)
	elseif plyVoice.Call > 0 then
		exports["pulsar-voip"]:RemoveFromCall(source, plyVoice.Call)
		exports["pulsar-voip"]:AddToCall(source, callChannel)
	end
	TriggerClientEvent("VOIP:Phone:Client:SetPlayerCall", source, callChannel)
end)

exports("SetTalking", function(source, talking)
	local plyVoice = voiceData[source]
	if not plyVoice then
		return
	end
	local callData = callData[plyVoice.Call]
	if callData then
		for player, _ in pairs(callData) do
			if player ~= source then
				TriggerClientEvent("VOIP:Phone:Client:SetPlayerTalkState", player, source, talking)
			end
		end
	end
end)

RegisterNetEvent("VOIP:Phone:Server:SetCall", function(callChannel)
	exports["pulsar-voip"]:SetCall(source, callChannel)
end)

RegisterNetEvent("VOIP:Phone:Server:SetTalking", function(talking)
	exports["pulsar-voip"]:SetTalking(source, talking)
end)
