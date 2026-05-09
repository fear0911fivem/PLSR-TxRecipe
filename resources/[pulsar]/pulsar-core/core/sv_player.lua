_dropping = {}
local _players = {}
local _recentDisconnects = {}
local _middlewareRegistered = false

CreateThread(function()
	while true do
		for k, v in pairs(_players) do
			if not GetPlayerEndpoint(k) and not _dropping[k] then
				local char = exports['pulsar-characters']:FetchCharacterSource(k)
				if char ~= nil then
					TriggerEvent("Characters:Server:PlayerDropped", k, char:GetData())
				end
				exports['pulsar-core']:MiddlewareTriggerEvent("playerDropped", k, "Time Out")
				_players[k] = nil
			end
		end
		Wait(60000)
	end
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	if _middlewareRegistered then
		return
	end
	_middlewareRegistered = true

	exports['pulsar-core']:MiddlewareAdd("playerDropped", function(source, message)
		local player = _players[source]
		if player ~= nil then
			local lastLocationMessage = ""
			local lastCoords = exports['pulsar-characters']:GetLastLocation(source) or false
			if lastCoords and type(lastCoords) == "vector3" then
				lastLocationMessage = string.format(" [Coords: %s]", lastCoords)
			end

			exports['pulsar-core']:LoggerInfo(
				"Base",
				string.format(
					"%s (%s) With Source %s Disconnected, Reason: %s%s",
					player:GetData("Name"),
					player:GetData("AccountID"),
					source,
					message,
					lastLocationMessage
				),
				{
					console = true,
					discord = {
						embed = true,
						type = "info",
						webhook = GetConvar("discord_connection_webhook", ""),
					},
				}
			)
		end
	end, 1)
	exports['pulsar-core']:MiddlewareAdd("playerDropped", function(source, message)
		local player = _players[source]
		if player ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)

			local pData = {
				Source = source,
				Groups = player:GetData("Groups"),
				Name = player:GetData("Name"),
				GameName = player:GetData("GameName"),
				ID = player:GetData("ID"),
				Discord = player:GetData("Discord"),
				Mention = player:GetData("Mention"),
				AccountID = player:GetData("AccountID"),
				Avatar = player:GetData("Avatar"),
				Identifier = player:GetData("Identifier"),
				Level = player.Permissions:GetLevel(),
				IsStaff = player.Permissions:IsStaff(),
				IsAdmin = player.Permissions:IsAdmin(),
				Character = player:GetData("Character"),
				Reason = message,
				DisconnectedTime = os.time(),
			}

			if #_recentDisconnects >= 60 then
				table.remove(_recentDisconnects, 1)
			end

			table.insert(_recentDisconnects, pData)
		end
	end, 2)
end)

AddEventHandler("playerDropped", function(message)
	local src = source
	_dropping[src] = true

	local char = exports['pulsar-characters']:FetchCharacterSource(src)
	if char ~= nil then
		TriggerEvent("Characters:Server:PlayerDropped", src, char:GetData())
	end

	exports['pulsar-core']:MiddlewareTriggerEvent("playerDropped", src, message)
	_players[src] = nil
	_dropping[src] = nil

	if char ~= nil then
		exports["pulsar-core"]:DeleteStore(src, "Character")
	end
	exports["pulsar-core"]:DeleteStore(src, "Player")
	TriggerEvent("Characters:Server:DropCleanup", src)
end)

AddEventHandler("Core:Server:ForceUnload", function(source)
	DropPlayer(source, "You were force unloaded but were still on the server, this was probably mistake.")
	_players[source] = nil
	_dropping[source] = nil
end)

AddEventHandler("Queue:Server:SessionActive", function(source, data)
	CreateThread(function()
		Player(source).state.ID = source

		if data == nil then
			DropPlayer(source, "Unable To Get Your User Data, Please Try To Rejoin")
		else
			local pData = {
				Source = source,
				Groups = data.Groups,
				Name = data.Name,
				ID = data.ID,
				Discord = data.Discord,
				Mention = data.Mention,
				AccountID = data.AccountID,
				Avatar = data.Avatar,
				Identifier = data.Identifier,
				--Tokens = exports["pulsar-core"]:CheckTokens(source, data.ID, data.Tokens),
				GameName = GetPlayerName(source),
			}

			for k, v in pairs(_players) do
				if v:GetData("AccountID") == pData.AccountID then
					_players[k] = nil
					exports['pulsar-core']:LoggerError(
						"Base",
						string.format("%s Connected But Was Already Registered As A Player, Clearing", pData.AccountID)
					)
					if v:GetData("Source") ~= nil then
						DropPlayer(
							v:GetData("Source"),
							"You've Been Dropped Because Your Account Has Rejoined The Server. Using your account on multiple PCs to connect multiple times is not allowed."
						)
					end
				end
			end

			_players[source] = PlayerClass(source, pData)
			exports["pulsar-core"]:RoutePlayerToHiddenRoute(source)
			exports['pulsar-core']:LoggerInfo(
				"Base",
				string.format(
					"%s (%s) Connected With Source %s",
					_players[source]:GetData("Name"),
					_players[source]:GetData("AccountID"),
					source
				),
				{
					console = true,
					discord = {
						embed = true,
						type = "info",
						webhook = GetConvar("discord_connection_webhook", ""),
					},
				}
			)

			TriggerClientEvent("Player:Client:SetData", source, _players[source]:GetData())

			Player(source).state.isStaff = _players[source].Permissions:IsStaff()
			Player(source).state.isAdmin = _players[source].Permissions:IsAdmin()
			Player(source).state.isDev = _players[source].Permissions:GetLevel() >= 100

			TriggerEvent("Player:Server:Connected", source)
		end
	end)
end)

exports("CheckTokens", function(source, accountId, existing)
	local p = promise.new()

	local ctkns = {}
	for i = 0, GetNumPlayerTokens(source) - 1 do
		ctkns[GetPlayerToken(source, i)] = true
	end

	if existing ~= nil then
		for k, v in ipairs(existing) do
			if ctkns[v] then
				ctkns[v] = nil
			end
		end
		for k, v in pairs(ctkns) do
			table.insert(existing, k)
		end

		local tokensJson = json.encode(existing)
		exports.oxmysql:execute(
			'UPDATE tokens SET tokens = ? WHERE account = ?',
			{ tokensJson, accountId },
			function(affectedRows)
				if affectedRows > 0 then
					p:resolve(existing)
				else
					exports.oxmysql:execute(
						'INSERT INTO tokens (account, tokens) VALUES (?, ?)',
						{ accountId, tokensJson },
						function(insertId)
							p:resolve(existing)
						end
					)
				end
			end
		)
	else
		local tkns = {}
		for k, v in pairs(ctkns) do
			table.insert(tkns, k)
		end

		local tokensJson = json.encode(tkns)
		exports.oxmysql:execute(
			'INSERT INTO tokens (account, tokens) VALUES (?, ?) ON DUPLICATE KEY UPDATE tokens = ?',
			{ accountId, tokensJson, tokensJson },
			function(result)
				p:resolve(tkns)
			end
		)
	end

	return Citizen.Await(p)
end)

exports("GetPlayer", function(source)
	return _players[source]
end)

exports("GetAllPlayers", function()
	return _players
end)

exports("GetRecentDisconnects", function()
	return _recentDisconnects
end)

function PlayerClass(source, data)
	local _data = exports["pulsar-core"]:CreateStore(source, "Player", data)

	_data.Permissions = {
		IsStaff = function(self)
			for k, v in ipairs(_data:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(v)
				if
					group ~= nil
					and type(group.Permission) == "table"
					and (
						group.Permission.Group == "staff"
						or group.Permission.Group == "admin"
					)
				then
					return true
				end
			end
			return false
		end,
		IsAdmin = function(self)
			for k, v in ipairs(_data:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(v)
				if
					group ~= nil
					and type(group.Permission) == "table"
					and group.Permission.Group == "admin"
				then
					return true
				end
			end
			return false
		end,
		GetLevel = function(self)
			local highest = 0
			for k, v in ipairs(_data:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
				if
					group ~= nil
					and type(group.Permission) == "table"
				then
					if group.Permission.Level > highest then
						highest = group.Permission.Level
					end
				end
			end

			return highest
		end,
	}

	local license = GetPlayerLicense(source)
	for k, v in ipairs(_data:GetData("Groups")) do
		local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
		if
			group ~= nil
			and type(group.Permission) == "table"
			and group.Permission.Group
		then
			ExecuteCommand(
				("add_principal identifier.license:%s group.%s"):format(
					license,
					group.Permission.Group
				)
			)
		end
	end

	return _data
end

function GetPlayerLicense(source)
	local playerIds = GetPlayerIdentifiers(source)
	local prioritizedId = nil

	for _, id in ipairs(playerIds) do
		if string.sub(id, 1, string.len("steam:")) == "steam:" then
			prioritizedId = id
			break
		end
	end

	if not prioritizedId then
		for _, id in ipairs(playerIds) do
			if string.sub(id, 1, string.len("license:")) == "license:" then
				prioritizedId = id
				break
			end
		end
	end

	return prioritizedId
end

exports('GetPlayerLicense', GetPlayerLicense)
