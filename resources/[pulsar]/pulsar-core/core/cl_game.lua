exports('GamePlayersGetPlayerPeds', function()
	local players = {}

	for _, player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) then
			table.insert(players, { ["ped"] = ped, ["id"] = player })
		end
	end

	return players
end)

exports('GamePlayersGetClosestPlayer', function(coords)
	local players = exports['pulsar-core']:GamePlayersGetPlayerPeds()
	local closestDistance = -1
	local closestPlayer = -1
	local coords = coords
	local usePlayerPed = false
	local playerPed = PlayerPedId()
	local playerId = PlayerId()

	if coords == nil then
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end

	for i = 1, #players, 1 do
		local target = players[i].ped

		if not usePlayerPed or (usePlayerPed and players[i].id ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance = #(targetCoords - vector3(coords.x, coords.y, coords.z))

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i].id
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end)

exports('GameObjectsGetAll', function()
	local objects = {}
	for obj in EnumerateObjects() do
		table.insert(objects, obj)
	end
	return objects
end)

exports('GameObjectsGetInArea', function(coords, radius)
	local objects = {}
	for obj in EnumerateObjects() do
		local objectCoords = GetEntityCoords(obj)
		if GetDistanceBetweenCoords(objectCoords, coords) <= radius then
			table.insert(objects, obj)
		end
	end
	return objects
end)

exports('GameObjectsSpawn', function(coords, modelName, heading, cb)
	local model = (type(modelName) == "number" and modelName or GetHashKey(modelName))
	CreateThread(function()
		exports['pulsar-core']:StreamRequestModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
		SetEntityHeading(obj, heading)
		if cb ~= nil then
			cb(obj)
		end
	end)
end)

exports('GameObjectsSpawnLocal', function(coords, modelName, heading, cb)
	local model = (type(modelName) == "number" and modelName or GetHashKey(modelName))
	CreateThread(function()
		exports['pulsar-core']:StreamRequestModel(model)

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
		SetEntityHeading(obj, heading)
		if cb ~= nil then
			cb(obj)
		end
	end)
end)

exports('GameObjectsSpawnLocalNoOffset', function(coords, modelName, heading, cb)
	local model = (type(modelName) == "number" and modelName or GetHashKey(modelName))
	CreateThread(function()
		exports['pulsar-core']:StreamRequestModel(model)

		local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, true)
		SetEntityHeading(obj, heading)
		if cb ~= nil then
			cb(obj)
		end
	end)
end)

exports('GameObjectsDelete', function(obj)
	SetEntityAsMissionEntity(obj, false, true)
	DeleteObject(obj)
end)

exports('GameVehiclesSpawn', function(coords, modelName, heading, cb)
	local model = (type(modelName) == "number" and modelName or GetHashKey(modelName))
	CreateThread(function()
		exports['pulsar-core']:StreamRequestModel(model)

		if HasModelLoaded((type(model) == "number" and model or GetHashKey(model))) then
			local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)

			local t = 0
			while not DoesEntityExist(vehicle) and t <= 10000 do
				Wait(1)
				t += 1
			end

			if not DoesEntityExist(vehicle) then
				exports['pulsar-core']:LoggerError(
					"Game",
					string.format(
						"Vehicle (%s) Didn't Spawn, Returning Nil And Aborting Remaining Spawn Behavior",
						model
					)
				)
				return cb(nil)
			end

			local id = NetworkGetNetworkIdFromEntity(vehicle)
			SetNetworkIdCanMigrate(id, true)
			SetEntityAsMissionEntity(vehicle, true, true)
			SetVehicleHasBeenOwnedByPlayer(vehicle, true)
			SetVehicleNeedsToBeHotwired(vehicle, false)
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			SetVehRadioStation(vehicle, "OFF")
			SetModelAsNoLongerNeeded(model)
			while not HasCollisionLoadedAroundEntity(vehicle) do
				RequestCollisionAtCoord(coords.x, coords.y, coords.z)
				Wait(0)
			end

			if cb then
				cb(vehicle)
			end
		else
			exports['pulsar-core']:LoggerError(
				"Stream",
				string.format("failed to load model, please report this: %s", model)
			)
			return cb(nil)
		end
	end)
end)

exports('GameVehiclesSpawnLocal', function(coords, modelName, heading, cb)
	local model = (type(modelName) == "number" and modelName or GetHashKey(modelName))
	CreateThread(function()
		exports['pulsar-core']:StreamRequestModel(model)
		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Wait(0)
		end
		SetVehRadioStation(vehicle, "OFF")
		if cb then
			cb(vehicle)
		end
	end)
end)

exports('GameVehiclesDelete', function(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end)
