local _sounds = {}

RegisterNUICallback("SoundEnd", function(data, cb)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Stopping Sound %s For ID %s^7"):format(data.file, data.source))
	if _sounds[data.source] ~= nil and _sounds[data.source][data.file] ~= nil then
		_sounds[data.source][data.file] = nil
	end
end)

exports("PlayOne", function(soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Playing Sound %s On Client Only^7"):format(soundFile))
	_sounds[LocalPlayer.state.ID] = _sounds[LocalPlayer.state.ID] or {}
	_sounds[LocalPlayer.state.ID][soundFile] = {
		file = soundFile,
		volume = soundVolume,
	}
	SendNUIMessage({
		action = "playSound",
		source = LocalPlayer.state.ID,
		file = soundFile,
		volume = soundVolume,
	})
end)

exports("PlayDistance", function(maxDistance, soundFile, soundVolume)
	exports["pulsar-core"]:ServerCallback("Sounds:Play:Distance", {
		maxDistance = maxDistance,
		soundFile = soundFile,
		soundVolume = soundVolume,
	})
end)

exports("PlayLocation", function(location, maxDistance, soundFile, soundVolume)
	exports["pulsar-core"]:ServerCallback("Sounds:Play:Location", {
		location = location,
		maxDistance = maxDistance,
		soundFile = soundFile,
		soundVolume = soundVolume,
	})
end)

exports("LoopOne", function(soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Looping Sound %s On Client Only^7"):format(soundFile))
	_sounds[LocalPlayer.state.ID] = _sounds[LocalPlayer.state.ID] or {}
	_sounds[LocalPlayer.state.ID][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "loopSound",
		source = LocalPlayer.state.ID,
		file = soundFile,
		volume = soundVolume,
	})
end)

exports("LoopDistance", function(maxDistance, soundFile, soundVolume)
	exports["pulsar-core"]:ServerCallback("Sounds:Loop:Distance", {
		maxDistance = maxDistance,
		soundFile = soundFile,
		soundVolume = soundVolume,
	})
end)

exports("LoopLocation", function(location, maxDistance, soundFile, soundVolume)
	exports["pulsar-core"]:ServerCallback("Sounds:Loop:Location", {
		location = location,
		maxDistance = maxDistance,
		soundFile = soundFile,
		soundVolume = soundVolume,
	})
end)

exports("StopOne", function(soundFile)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Stopping Sound %s On Client^7"):format(soundFile))
	if _sounds[LocalPlayer.state.ID] ~= nil and _sounds[LocalPlayer.state.ID][soundFile] ~= nil then
		_sounds[LocalPlayer.state.ID][soundFile] = nil
		SendNUIMessage({
			action = "stopSound",
			source = LocalPlayer.state.ID,
			file = soundFile,
		})
	end
end)

exports("StopDistance", function(pNet, soundFile)
	exports["pulsar-core"]:ServerCallback("Sounds:Stop:Distance", {
		soundFile = soundFile,
	})
end)

exports("StopLocation", function(pNet, soundFile)
	exports["pulsar-core"]:ServerCallback("Sounds:Stop:Distance", {
		soundFile = soundFile,
	})
end)

exports("FadeOne", function(soundFile)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Stopping Sound %s On Client^7"):format(soundFile))
	if _sounds[LocalPlayer.state.ID] ~= nil and _sounds[LocalPlayer.state.ID][soundFile] ~= nil then
		_sounds[LocalPlayer.state.ID][soundFile] = nil
		SendNUIMessage({
			action = "fadeSound",
			source = LocalPlayer.state.ID,
			file = soundFile,
		})
	end
end)

function DoPlayDistance(playerNetId, maxDistance, soundFile, soundVolume)
	playerNetId = tonumber(playerNetId)
	exports['pulsar-core']:LoggerTrace(
		("^2Playing Sound %s Once Per Request From %s For Distance %s^7"):format(
			soundFile,
			playerNetId,
			maxDistance
		)
	)

	local pPed = PlayerPedId()
	local isFromMe = false
	local tPlayer = GetPlayerFromServerId(playerNetId)
	local tPed = GetPlayerPed(tPlayer)

	if playerNetId == LocalPlayer.state.ID then
		isFromMe = true
		tPed = LocalPlayer.state.ped
	end

	local distIs = #(GetEntityCoords(pPed) - GetEntityCoords(tPed))
	local vol = soundVolume * (1.0 - (distIs / maxDistance))
	if isFromMe then
		vol = soundVolume
	elseif
		(tPed ~= 0 and distIs > maxDistance)
		or (tPed == 0)
		or not LocalPlayer.state.loggedIn
		or (tPlayer == -1)
	then
		vol = 0
	end

	_sounds[playerNetId] = _sounds[playerNetId] or {}
	_sounds[playerNetId][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "playSound",
		source = playerNetId,
		file = soundFile,
		volume = vol,
	})

	CreateThread(function()
		while _sounds[playerNetId] ~= nil and _sounds[playerNetId][soundFile] ~= nil do
			tPlayer = GetPlayerFromServerId(playerNetId)
			tPed = GetPlayerPed(tPlayer)

			local distIs = #(GetEntityCoords(pPed) - GetEntityCoords(tPed))
			vol = soundVolume * (1.0 - (distIs / maxDistance))

			if isFromMe then
				vol = soundVolume
			elseif
				(tPed ~= 0 and distIs > maxDistance)
				or (tPed == 0)
				or not LocalPlayer.state.loggedIn
				or (tPlayer == -1)
			then
				vol = 0
			end

			SendNUIMessage({
				action = "updateVol",
				source = playerNetId,
				file = soundFile,
				volume = vol,
			})
			Wait(100)
		end
	end)
end

function DoPlayLocation(playerNetId, location, maxDistance, soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace(
		("^2Playing Sound %s Once Per Request From %s at location %s For Distance %s^7"):format(
			soundFile,
			playerNetId,
			json.encode(location),
			maxDistance
		)
	)
	local distIs = #(
		vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
		- vector3(location.x, location.y, location.z)
	)
	local vol = soundVolume * (1.0 - (distIs / maxDistance))
	if distIs > maxDistance then
		vol = 0
	end
	_sounds[playerNetId] = _sounds[playerNetId] or {}
	_sounds[playerNetId][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "playSound",
		source = playerNetId,
		file = soundFile,
		volume = vol,
	})

	CreateThread(function()
		while _sounds[playerNetId] ~= nil and _sounds[playerNetId][soundFile] ~= nil do
			local distIs = #(
				vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
				- vector3(location.x, location.y, location.z)
			)
			vol = soundVolume * (1.0 - (distIs / maxDistance))
			if distIs > maxDistance then
				vol = 0
			end
			SendNUIMessage({
				action = "updateVol",
				source = playerNetId,
				file = soundFile,
				volume = vol,
			})
			Wait(100)
		end
	end)
end

function DoLoopDistance(playerNetId, maxDistance, soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace(
		("^2Looping Sound %s Per Request From %s For Distance %s^7"):format(soundFile, playerNetId, maxDistance)
	)

	local isFromMe = false
	local pPed = PlayerPedId()

	local tPlayer = GetPlayerFromServerId(playerNetId)
	local tPed = GetPlayerPed(tPlayer)

	if playerNetId == LocalPlayer.state.ID then
		isFromMe = true
		tPed = LocalPlayer.state.ped
	end

	local distIs = #(GetEntityCoords(pPed) - GetEntityCoords(tPed))
	local vol = soundVolume * (1.0 - (distIs / maxDistance))
	if isFromMe then
		vol = soundVolume
	elseif
		(tPed ~= 0 and distIs > maxDistance)
		or tPed == 0
		or not LocalPlayer.state.loggedIn
		or (tPlayer == -1)
	then
		vol = 0
	end

	_sounds[playerNetId] = _sounds[playerNetId] or {}
	_sounds[playerNetId][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "loopSound",
		source = playerNetId,
		file = soundFile,
		volume = vol,
	})

	CreateThread(function()
		while _sounds[playerNetId] ~= nil and _sounds[playerNetId][soundFile] ~= nil do
			tPlayer = GetPlayerFromServerId(playerNetId)
			tPed = GetPlayerPed(tPlayer)

			local distIs = #(GetEntityCoords(pPed) - GetEntityCoords(tPed))
			vol = soundVolume * (1.0 - (distIs / maxDistance))

			if isFromMe then
				vol = soundVolume
			elseif
				(tPed ~= 0 and distIs > maxDistance)
				or tPed == 0
				or not LocalPlayer.state.loggedIn
				or (tPlayer == -1)
			then
				vol = 0
			end

			SendNUIMessage({
				action = "updateVol",
				source = playerNetId,
				file = soundFile,
				volume = vol,
			})
			Wait(100)
		end
	end)
end

function DoLoopLocation(playerNetId, location, maxDistance, soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace(
		("^2Looping Sound %s Per Request From %s at location %s For Distance %s^7"):format(
			soundFile,
			playerNetId,
			json.encode(location),
			maxDistance
		)
	)
	local distIs = #(GetEntityCoords(LocalPlayer.state.ped) - location)
	local vol = soundVolume * (1.0 - (distIs / maxDistance))
	if distIs > maxDistance then
		vol = 0
	end

	_sounds[playerNetId] = _sounds[playerNetId] or {}
	_sounds[playerNetId][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "loopSound",
		source = playerNetId,
		file = soundFile,
		volume = vol,
	})

	CreateThread(function()
		while _sounds[playerNetId] ~= nil and _sounds[playerNetId][soundFile] ~= nil do
			local distIs = #(GetEntityCoords(LocalPlayer.state.ped) - location)
			vol = soundVolume * (1.0 - (distIs / maxDistance))
			if distIs > maxDistance or not LocalPlayer.state.loggedIn then
				vol = 0
			end
			SendNUIMessage({
				action = "updateVol",
				source = playerNetId,
				file = soundFile,
				volume = vol,
			})
			Wait(100)
		end
	end)
end

function DoStopDistance(playerNetId, soundFile)
	exports['pulsar-core']:LoggerTrace("Sounds",
		("^2Stopping Sound %s Per Request From %s^7"):format(soundFile, playerNetId))
	if _sounds[playerNetId] ~= nil and _sounds[playerNetId][soundFile] ~= nil then
		_sounds[playerNetId][soundFile] = nil
		SendNUIMessage({
			action = "stopSound",
			source = playerNetId,
			file = soundFile,
		})
	end
end

RegisterNetEvent("Sounds:Client:Play:One", function(playerNetId, soundFile, soundVolume)
	DoPlayDistance(playerNetId, soundFile, soundVolume)
end)

RegisterNetEvent("Sounds:Client:Play:Distance", function(playerNetId, maxDistance, soundFile, soundVolume)
	DoPlayDistance(playerNetId, maxDistance, soundFile, soundVolume)
end)

RegisterNetEvent("Sounds:Client:Play:Location", function(playerNetId, location, maxDistance, soundFile, soundVolume)
	DoPlayLocation(playerNetId, location, maxDistance, soundFile, soundVolume)
end)

RegisterNetEvent("Sounds:Client:Loop:One", function(soundFile, soundVolume)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Looping Sound %s On Client Only^7"):format(soundFile))
	_sounds[LocalPlayer.state.ID] = _sounds[LocalPlayer.state.ID] or {}
	_sounds[LocalPlayer.state.ID][soundFile] = {
		file = soundFile,
		volume = soundVolume,
		distance = maxDistance,
	}
	SendNUIMessage({
		action = "loopSound",
		source = LocalPlayer.state.ID,
		file = soundFile,
		volume = soundVolume,
	})
end)

RegisterNetEvent("Sounds:Client:Loop:Distance", function(playerNetId, maxDistance, soundFile, soundVolume)
	DoLoopDistance(playerNetId, maxDistance, soundFile, soundVolume)
end)

RegisterNetEvent("Sounds:Client:Loop:Location", function(playerNetId, location, maxDistance, soundFile, soundVolume)
	DoLoopLocation(playerNetId, location, maxDistance, soundFile, soundVolume)
end)

RegisterNetEvent("Sounds:Client:Stop:One", function(soundFile)
	exports['pulsar-core']:LoggerTrace("Sounds", ("^2Stopping Sound %s On Client^7"):format(soundFile))
	if _sounds[LocalPlayer.state.ID] ~= nil and _sounds[LocalPlayer.state.ID][soundFile] ~= nil then
		_sounds[LocalPlayer.state.ID][soundFile] = nil
		SendNUIMessage({
			action = "stopSound",
			source = LocalPlayer.state.ID,
			file = soundFile,
		})
	end
end)

RegisterNetEvent("Sounds:Client:Stop:Distance", function(playerNetId, soundFile)
	DoStopDistance(playerNetId, soundFile)
end)

RegisterNetEvent("Sounds:Client:Stop:All", function(playerNetId, soundFile)
	if _sounds[playerNetId] ~= nil then
		for k, v in pairs(_sounds[playerNetId]) do
			DoStopDistance(playerNetId, v)
		end
		_sounds[playerNetId] = nil
	end
end)
