local Config = require('shared.config')
_tempLastLocation = {}
_lastSpawnLocations = {}

_SID = {}
_ID = {}

_afkPlayers = {}

AddEventHandler("Player:Server:Connected", function(source)
	_afkPlayers[source] = os.time()
end)

function RegisterCallbacks()
	CreateThread(function()
		while true do
			if not (GlobalState["DisableAFK"] or false) then
				for k, v in pairs(_afkPlayers) do
					if v < (os.time() - (60 * 10)) then
						local pState = Player(k).state
						if not pState.isDev and not pState.isAdmin and not pState.isStaff then
							exports['pulsar-core']:PunishmentKick(k, "You Were Kicked For Being AFK On Character Select",
								"Pwnzor", true)
						else
							exports['pulsar-core']:LoggerWarn("Characters",
								"Staff or Admin Was AFK, Removing From Checks")
							_afkPlayers[k] = nil
						end
					elseif v < (os.time() - (60 * 5)) then
						-- TODO: Implement better alert when at this stage when we have someway to do it
						exports['pulsar-hud']:Notification("warning", k, "You Will Be Kicked Soon For Being AFK", 58000)
					end
				end
			end
			Wait(60000)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:GetServerData", function(source, data, cb)
		while exports['pulsar-core']:FetchSource(source) == nil do
			Wait(1000)
		end

		local motd = GetConvar("motd", "Welcome to Pulsar Framework")
		local query = 'SELECT * FROM `changelogs` ORDER BY `date` DESC LIMIT 1'

		MySQL.Async.fetchAll(query, {}, function(results)
			if not results then
				cb({ changelog = nil, motd = "" })
				return
			end

			if #results > 0 then
				cb({ changelog = results[1], motd = motd })
			else
				cb({ changelog = nil, motd = motd })
			end
		end)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:GetCharacters", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)
		local license = exports['pulsar-core']:GetPlayerLicense(source)
		local myCharacters = MySQL.query.await('SELECT * FROM `characters` WHERE `License` = @License AND `Deleted` = 0',
			{
				["@License"] = license,
			})
		if #myCharacters == 0 then
			return cb({})
		end

		local cData = {}
		for k, v in ipairs(myCharacters) do
			local pedData = MySQL.single.await(
				[[
			  SELECT * FROM `peds` WHERE `Char` = @Char
			]],
				{
					["@Char"] = v.SID,
				}
			)
			table.insert(cData, {
				License = v.License,
				ID = v.SID,
				First = v.First,
				Last = v.Last,
				Phone = v.Phone,
				DOB = v.DOB,
				Gender = v.Gender,
				LastPlayed = v.LastPlayed,
				Jobs = json.decode(v.Jobs),
				SID = v.SID,
				GangChain = json.decode(v.GangChain),
				Preview = pedData and json.decode(pedData.ped) or false
			})
		end

		player:SetData("Characters", cData)
		cb(cData)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:CreateCharacter", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)

		local pNumber = exports['pulsar-phone']:GeneratePhoneNumber()
		local playerIdentifiers = GetPlayerIdentifiers(source)
		local prioritizedIdentifier = nil -- If Steam ID is available, save that as character license because it's short and simple

		for _, id in ipairs(playerIdentifiers) do
			if string.sub(id, 1, string.len("steam:")) == "steam:" then
				prioritizedIdentifier = id
				break
			end
		end

		if not prioritizedIdentifier then
			for _, id in ipairs(playerIdentifiers) do
				if string.sub(id, 1, string.len("license:")) == "license:" then
					prioritizedIdentifier = id
					break
				end
			end
		end

		if not prioritizedIdentifier then
			prioritizedIdentifier = player:GetData("Identifier")
		end

		local doc = {
			License = prioritizedIdentifier,
			User = player:GetData("AccountID"),
			First = data.first,
			Last = data.last,
			Phone = pNumber,
			Gender = tonumber(data.gender),
			Bio = data.bio,
			Origin = data.origin,
			DOB = string.match(data.dob, "(%d%d%d%d%-%d%d%-%d%d)"),
			LastPlayed = -1,
			Jobs = {},
			SID = exports['pulsar-core']:SequenceGet("Character"),
			Cash = 1000,
			New = true,
			Licenses = {
				Drivers = {
					Active = true,
					Points = 0,
					Suspended = false,
				},
				Weapons = {
					Active = false,
					Suspended = false,
				},
				Hunting = {
					Active = false,
					Suspended = false,
				},
				Fishing = {
					Active = false,
					Suspended = false,
				},
				Pilot = {
					Active = false,
					Suspended = false,
				},
				Drift = {
					Active = false,
					Suspended = false,
				},
			},
		}

		local extra = exports['pulsar-core']:MiddlewareTriggerEventWithData("Characters:Creating", source, doc) or {}
		for k, v in ipairs(extra) do
			for k2, v2 in pairs(v) do
				if k2 ~= "ID" then
					doc[k2] = v2
				end
			end
		end

		local dbData = exports['pulsar-core']:CloneDeep(doc)
		local jsonFields = {}
		for _, f in ipairs(TablesToDecode) do jsonFields[f] = true end
		for k, v in pairs(dbData) do
			if type(v) == 'table' or (type(v) == 'string' and jsonFields[k]) then
				dbData[k] = json.encode(v)
			end
		end

		local insertedCharacter = MySQL.insert.await('INSERT INTO `characters` SET ?', { dbData })
		if insertedCharacter <= 0 then
			return cb(nil)
		end

		doc.ID = insertedCharacter

		TriggerEvent("Characters:Server:CharacterCreated", doc)
		local success, result = pcall(function()
			exports['pulsar-core']:MiddlewareTriggerEvent("Characters:Created", source, doc)
		end)

		if not success then
			exports['pulsar-core']:LoggerError(
				"Characters",
				string.format("Error in Characters:Created middleware: %s", result)
			)
		end

		exports['pulsar-core']:LoggerInfo(
			"Characters",
			string.format(
				"%s [%s] Created a New Character %s %s (%s)",
				player:GetData("Name"),
				player:GetData("AccountID"),
				doc.First,
				doc.Last,
				doc.SID
			),
			{
				console = true,
				file = true,
				database = true,
			}
		)
		return cb(doc)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:DeleteCharacter", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)
		local license = exports['pulsar-core']:GetPlayerLicense(source)
		local myCharacter = MySQL.single.await(
			[[
			SELECT * FROM `characters` WHERE `License` = @License AND `SID` = @ID
		  ]],
			{
				["@License"] = license,
				["@ID"] = data,
			}
		)

		if myCharacter == nil then
			return cb(nil)
		end

		local deletingChar = exports['pulsar-core']:CloneDeep(myCharacter)
		local deletedCharacter = MySQL.update.await(
			[[
			UPDATE `characters` SET `Deleted` = 1 WHERE `License` = @License AND `SID` = @ID
		  ]],
			{
				["@License"] = license,
				["@ID"] = data,
			}
		)

		if deletedCharacter then
			MySQL.query.await("DELETE FROM `peds` WHERE `char` = ?", { data })

			TriggerEvent("Characters:Server:CharacterDeleted", data)
			cb(true)

			exports['pulsar-core']:LoggerWarn(
				"Characters",
				string.format(
					"%s [%s] Deleted Character %s %s (%s)",
					player:GetData("Name"),
					player:GetData("AccountID"),
					deletingChar.First,
					deletingChar.Last,
					deletingChar.SID
				),
				{
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
					},
				}
			)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:GetSpawnPoints", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)
		local license = exports['pulsar-core']:GetPlayerLicense(source)
		local myCharacter = MySQL.single.await(
			[[
			SELECT * FROM `characters` WHERE `License` = @License AND `SID` = @ID
		  ]],
			{
				["@License"] = license,
				["@ID"] = data,
			}
		)
		if myCharacter == nil then
			return cb(nil)
		end
		myCharacter.Jobs = json.decode(myCharacter.Jobs)
		if myCharacter.New then
			return cb({
				{
					id = 1,
					label = "Character Creation",
					location = exports['pulsar-apartments']:GetInteriorLocation(myCharacter.Apartment or 1),
				},
			})
		elseif myCharacter.Jailed then
			local JailedData = json.decode(myCharacter.JailedData)
			-- and not myCharacter.Jailed.Released ~= nil
			if not JailedData.Released then
				return cb({ Config.PrisonSpawn })
			end
		elseif myCharacter.ICU then
			local ICUData = json.decode(myCharacter.ICU)
			if not ICUData.Released then
				return cb({ Config.ICUSpawn })
			end
		end

		local spawns = exports['pulsar-core']:MiddlewareTriggerEventWithData("Characters:GetSpawnPoints", source, data,
			myCharacter)
		cb(spawns)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:GetCharacterData", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)
		local license = exports['pulsar-core']:GetPlayerLicense(source)
		local myCharacter = MySQL.single.await([[
			SELECT * FROM `characters` WHERE `License` = @License AND `SID` = @ID
			]],
			{
				["@License"] = license,
				["@ID"] = data,
			}
		)

		if myCharacter == nil then
			return cb(nil)
		end

		local cData = myCharacter

		for k, v in ipairs(TablesToDecode) do
			if cData[v] then
				cData[v] = json.decode(cData[v])
			end
		end

		cData.Source = source
		cData.ID = myCharacter.SID

		player:SetData("Character", {
			SID = cData.SID,
			First = cData.First,
			Last = cData.Last,
		})

		local store = exports['pulsar-core']:CreateStore(source, "Character", cData)
		ONLINE_CHARACTERS[source] = store

		_SID[cData.SID] = source
		_ID[cData.ID] = source

		GlobalState[string.format("SID:%s", source)] = cData.SID

		exports['pulsar-core']:MiddlewareTriggerEvent("Characters:CharacterSelected", source)

		cb(cData)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:Logout", function(source, data, cb)
		_afkPlayers[source] = os.time()
		local c = exports['pulsar-characters']:FetchCharacterSource(source)
		if c ~= nil then
			local cData = c:GetData()
			if cData.SID and cData.ID then
				_SID[cData.SID] = nil
				_ID[cData.ID] = nil
			end

			TriggerEvent("Characters:Server:PlayerLoggedOut", source, cData)

			exports['pulsar-core']:MiddlewareTriggerEvent("Characters:Logout", source)
			ONLINE_CHARACTERS[source] = nil
			GlobalState[string.format("SID:%s", source)] = nil
			TriggerClientEvent("Characters:Client:Logout", source)
			exports["pulsar-core"]:RoutePlayerToHiddenRoute(source)
			exports["pulsar-core"]:DeleteStore(source, "Character")
		end
		cb("ok")
	end)

	exports["pulsar-core"]:RegisterServerCallback("Characters:GlobalSpawn", function(source, data, cb)
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
		cb()
	end)
end

AddEventHandler("Characters:Server:DropCleanup", function(source, cData)
	_afkPlayers[source] = nil
	ONLINE_CHARACTERS[source] = nil

	GlobalState[string.format("SID:%s", source)] = nil

	if cData and cData.SID and cData.ID then
		_SID[cData.SID] = nil
		_ID[cData.ID] = nil
	end
end)

function HandleLastLocation(source)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)

	if char ~= nil then
		local lastLocation = _tempLastLocation[source]
		if lastLocation and type(lastLocation) == "vector3" then
			_lastSpawnLocations[char:GetData("ID")] = {
				coords = lastLocation,
				time = os.time(),
			}
		end
	end

	_tempLastLocation[source] = nil
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	local lastLocation = _tempLastLocation[source]
	if lastLocation and type(lastLocation) == "vector3" then
		_lastSpawnLocations[cData.ID] = {
			coords = lastLocation,
			time = os.time(),
		}
	end
end)

function RegisterMiddleware()
	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		_afkPlayers[source] = nil
		TriggerClientEvent("Characters:Client:Spawned", source)
	end, 100000)
	exports['pulsar-core']:MiddlewareAdd("Characters:ForceStore", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 100000)
	exports['pulsar-core']:MiddlewareAdd("Characters:Logout", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 10000)

	exports['pulsar-core']:MiddlewareAdd("Characters:GetSpawnPoints", function(source, id)
		if id then
			local hasLastLocation = _lastSpawnLocations[id]
			if hasLastLocation and hasLastLocation.time and (os.time() - hasLastLocation.time) <= (60 * 5) then
				return {
					{
						id = "LastLocation",
						label = "Last Location",
						location = {
							x = hasLastLocation.coords.x,
							y = hasLastLocation.coords.y,
							z = hasLastLocation.coords.z,
							h = 0.0,
						},
						icon = "location-dot",
						event = "Characters:GlobalSpawn",
					},
				}
			end
		end
		return {}
	end, 1)

	exports['pulsar-core']:MiddlewareAdd("Characters:GetSpawnPoints", function(source)
		local spawns = {}
		for k, v in ipairs(Spawns) do
			v.event = "Characters:GlobalSpawn"
			table.insert(spawns, v)
		end
		return spawns
	end, 5)

	exports['pulsar-core']:MiddlewareAdd("playerDropped", function(source, message)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			StoreData(source)
		end
	end, 10000)

	exports['pulsar-core']:MiddlewareAdd("Characters:Logout", function(source)
		local pState = Player(source).state
		if pState.tpLocation then
			_tempLastLocation[source] = pState.tpLocation
		else
			_tempLastLocation[source] = GetEntityCoords(GetPlayerPed(source))
		end
		HandleLastLocation(source)
	end, 1)

	exports['pulsar-core']:MiddlewareAdd("playerDropped", HandleLastLocation, 6)
end

AddEventHandler("playerDropped", function()
	local src = source
	if DoesEntityExist(GetPlayerPed(src)) then
		local pState = Player(src).state
		if pState.tpLocation then
			_tempLastLocation[src] = pState.tpLocation
		else
			_tempLastLocation[src] = GetEntityCoords(GetPlayerPed(src))
		end
	end
end)

RegisterNetEvent("Characters:Server:LastLocation", function(coords)
	local src = source
	_tempLastLocation[src] = coords
end)
