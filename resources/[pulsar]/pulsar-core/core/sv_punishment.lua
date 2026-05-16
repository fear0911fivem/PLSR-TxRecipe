exports("PunishmentCheckBanTokens", function(tokens)
	if not tokens or #tokens == 0 then return nil end

	local p = promise.new()

	exports.oxmysql:execute(
		'SELECT * FROM bans WHERE active = 1 AND tokens IS NOT NULL AND tokens != \'null\'',
		{},
		function(results)
			if not results or #results == 0 then
				p:resolve(nil)
				return
			end

			local tokenSet = {}
			for k = 1, #tokens do
				tokenSet[tokens[k]] = true
			end

			for k = 1, #results do
				local row = results[k]
				if row.expires ~= -1 and row.expires < os.time() then
					exports.oxmysql:execute('UPDATE bans SET active = 0 WHERE id = ?', { row.id }, function() end)
				else
					local stored = json.decode(row.tokens)
					if stored then
						for j = 1, #stored do
							if tokenSet[stored[j]] then
								if row.unbanned then row.unbanned = json.decode(row.unbanned) end
								row._id = row.id
								p:resolve(row)
								return
							end
						end
					end
				end
			end

			p:resolve(nil)
		end
	)

	return Citizen.Await(p)
end)

exports("PunishmentCheckBan", function(key, value)
	local p = promise.new()

	local query = 'SELECT * FROM bans WHERE `' .. key .. '` = ? AND active = 1'
	exports.oxmysql:execute(query, { value }, function(results)
		if results and #results > 0 then
			for k, v in ipairs(results) do
				if v.expires < os.time() and v.expires ~= -1 then
					exports.oxmysql:execute(
						'UPDATE bans SET active = 0 WHERE id = ?',
						{ v.id },
						function(affectedRows)
						end
					)
				else
					if v.tokens then
						v.tokens = json.decode(v.tokens)
					end
					if v.unbanned then
						v.unbanned = json.decode(v.unbanned)
					end
					v._id = v.id
					p:resolve(v)
					return
				end
			end
			p:resolve(nil)
		else
			p:resolve(nil)
		end
	end)

	return Citizen.Await(p)
end)

exports("PunishmentKick", function(source, reason, issuer, afk)
	local tPlayer = exports['pulsar-core']:FetchSource(source)

	if not tPlayer then
		return {
			success = false,
		}
	end

	if issuer ~= "Pwnzor" then
		if source == issuer then
			return {
				success = false,
				message = "Cannot Ban Yourself!",
			}
		end

		local iPlayer = exports['pulsar-core']:FetchSource(issuer)

		if not iPlayer then
			return {
				success = false,
			}
		end

		if iPlayer.Permissions:GetLevel() <= tPlayer.Permissions:GetLevel() then
			return {
				success = false,
				message = "Insufficient Permissions",
			}
		end

		exports['pulsar-core']:LoggerInfo(
			"Punishment",
			string.format(
				"%s [%s] Kicked By %s [%s] For %s",
				tPlayer:GetData("Name"),
				tPlayer:GetData("AccountID"),
				iPlayer:GetData("Name"),
				iPlayer:GetData("AccountID"),
				reason
			),
			{ console = true, file = true, database = true, discord = { embed = true, type = "inform" } },
			{
				account = tPlayer:GetData("AccountID"),
				identifier = tPlayer:GetData("Identifier"),
				reason = reason,
				issuer = string.format("%s [%s]", iPlayer:GetData("Name"), iPlayer:GetData("AccountID")),
			}
		)

		exports['pulsar-core']:PunishmentActionsKick(source, reason, iPlayer:GetData("Name"))
		return {
			success = true,
			Name = tPlayer:GetData("Name"),
			AccountID = tPlayer:GetData("AccountID"),
			reason = reason,
		}
	else
		if not afk then
			exports['pulsar-core']:LoggerInfo(
				"Punishment",
				string.format(
					"%s [%s] Kicked By %s For %s",
					tPlayer:GetData("Name"),
					tPlayer:GetData("AccountID"),
					issuer,
					reason
				),
				{
					console = true,
					file = true,
					database = true,
					discord = { embed = true, type = "inform", webhook = GetConvar("discord_pwnzor_webhook", "") },
				},
				{
					account = tPlayer:GetData("AccountID"),
					identifier = tPlayer:GetData("Identifier"),
					reason = reason,
					issuer = issuer,
				}
			)
		end
		exports['pulsar-core']:PunishmentActionsKick(source, reason, issuer)

		return {
			success = true,
			Name = tPlayer:GetData("Name"),
			AccountID = tPlayer:GetData("AccountID"),
			reason = reason,
		}
	end
end)

exports("PunishmentUnbanBanID", function(id, issuer)
	if exports['pulsar-core']:PunishmentCheckBan("id", id) then
		local iPlayer = exports['pulsar-core']:FetchSource(issuer)

		exports.oxmysql:execute('SELECT * FROM bans WHERE id = ? AND active = 1', { id }, function(results)
			if results and #results > 0 then
				if exports['pulsar-core']:PunishmentActionsUnban(results, iPlayer) then
					exports["pulsar-chat"]:SendServerSingle(
						iPlayer:GetData("Source"),
						string.format("%s Has Been Revoked", id)
					)
				end
			end
		end)
	end
end)

exports("PunishmentUnbanAccountID", function(aId, issuer)
	if exports['pulsar-core']:PunishmentCheckBan("account", aId) then
		local tPlayer = exports['pulsar-core']:FetchPlayerData("AccountID", aId)
		local dbf = false

		if tPlayer == nil then
			tPlayer = exports['pulsar-core']:FetchWebsite("account", aId)
			dbf = true
		end

		local iPlayer = exports['pulsar-core']:FetchSource(issuer)

		exports.oxmysql:execute('SELECT * FROM bans WHERE account = ? AND active = 1', { aId }, function(results)
			if results and #results > 0 then
				if exports['pulsar-core']:PunishmentActionsUnban(results, iPlayer) then
					exports["pulsar-chat"]:SendServerSingle(
						iPlayer:GetData("Source"),
						string.format(
							"%s (Account: %s) Has Been Unbanned",
							tPlayer:GetData("Name"),
							tPlayer:GetData("AccountID")
						)
					)
				end
			end
		end)

		if dbf then
			tPlayer:DeleteStore()
		end
	else
		exports["pulsar-chat"]:SendServerSingle(
			iPlayer:GetData("Source"),
			string.format("%s (Account: %s) Is Not Banned", tPlayer:GetData("Name"), tPlayer:GetData("AccountID"))
		)
	end
end)

exports("PunishmentUnbanIdentifier", function(identifier, issuer)
	if exports['pulsar-core']:PunishmentCheckBan("identifier", identifier) then
		local tPlayer = exports['pulsar-core']:FetchPlayerData("Identifier", identifier)
		local dbf = false
		if tPlayer == nil then
			tPlayer = exports['pulsar-core']:FetchWebsite("identifier", identifier)
			dbf = true
		end
		local iPlayer = exports['pulsar-core']:FetchSource(issuer)

		exports.oxmysql:execute('SELECT * FROM bans WHERE identifier = ? AND active = 1', { identifier },
			function(results)
				if results and #results > 0 then
					if exports['pulsar-core']:PunishmentActionsUnban(results, iPlayer) then
						exports["pulsar-chat"]:SendServerSingle(
							iPlayer:GetData("Source"),
							string.format(
								"%s (Identifier: %s) Has Been Unbanned",
								tPlayer:GetData("Name"),
								tPlayer:GetData("Identifier")
							)
						)
					end
				end
			end)

		if dbf then
			tPlayer:DeleteStore()
		end
	else
		exports["pulsar-chat"]:SendServerSingle(
			iPlayer:GetData("Source"),
			string.format(
				"%s (Identifier: %s) Is Not Banned",
				tPlayer:GetData("Name"),
				tPlayer:GetData("Identifier")
			)
		)
	end
end)

exports("PunishmentBanSource", function(source, expires, reason, issuer)
	local tPlayer = exports['pulsar-core']:FetchSource(source)
	local iPlayer

	if not tPlayer then
		return {
			success = false,
		}
	end

	if issuer ~= "Pwnzor" then
		if source == issuer then
			return {
				success = false,
				message = "Cannot Ban Yourself!",
			}
		end

		iPlayer = exports['pulsar-core']:FetchSource(issuer)
		if not iPlayer then
			return {
				success = false,
			}
		end

		if iPlayer.Permissions:GetLevel() < tPlayer.Permissions:GetLevel() then
			return {
				success = false,
				message = "Insufficient Permissions",
			}
		end

		issuer = string.format("%s [%s]", iPlayer:GetData("Name"), iPlayer:GetData("AccountID"))
	end

	local expStr = "Never"
	if expires ~= -1 then
		expires = (os.time() + ((60 * 60 * 24) * expires))
		expStr = os.date("%Y-%m-%d at %I:%M:%S %p", expires)
	end

	local banStr = string.format("%s Was Permanently Banned By %s for %s", tPlayer:GetData("Name"), issuer, reason)

	if expires ~= -1 then
		banStr = string.format(
			"%s Was Banned By %s Until %s for %s",
			tPlayer:GetData("Name"),
			issuer,
			expStr,
			reason
		)
	end

	if iPlayer ~= nil then
		exports['pulsar-core']:PunishmentActionsBan(
			tPlayer:GetData("Source"),
			tPlayer:GetData("AccountID"),
			tPlayer:GetData("Identifier"),
			tPlayer:GetData("Name"),
			tPlayer:GetData("Tokens"),
			reason,
			expires,
			expStr,
			issuer,
			iPlayer:GetData("AccountID"),
			false
		)

		return {
			success = true,
			Name = tPlayer:GetData("Name"),
			AccountID = tPlayer:GetData("AccountID"),
			expires = expires,
			reason = reason,
			banStr = banStr,
		}
	else
		exports['pulsar-core']:PunishmentActionsBan(
			tPlayer:GetData("Source"),
			tPlayer:GetData("AccountID"),
			tPlayer:GetData("Identifier"),
			tPlayer:GetData("Name"),
			tPlayer:GetData("Tokens"),
			reason,
			expires,
			expStr,
			issuer,
			-1,
			true
		)

		return {
			success = true,
			Name = tPlayer:GetData("Name"),
			AccountID = tPlayer:GetData("AccountID"),
			expires = expires,
			reason = reason,
			banStr = banStr,
		}
	end

	exports['pulsar-core']:LoggerInfo(
		"Punishment",
		banStr,
		{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
		{
			player = tPlayer:GetData("Name"),
			identifier = tPlayer:GetData("Identifier"),
			reason = reason,
			issuer = issuer,
			expires = expStr,
		}
	)
end)

exports("PunishmentBanAccountID", function(aId, expires, reason, issuer)
	local iPlayer = exports['pulsar-core']:FetchSource(issuer)
	if not iPlayer then
		return {
			success = false,
		}
	end

	if iPlayer:GetData("AccountID") == tonumber(aId) then
		return {
			success = false,
			message = "Cannot Ban Yourself!",
		}
	end

	local tPlayer = exports['pulsar-core']:FetchPlayerData("AccountID", tonumber(aId))

	issuer = string.format("%s [%s]", iPlayer:GetData("Name"), iPlayer:GetData("AccountID"))

	local dbf = false
	if tPlayer == nil then
		tPlayer = exports['pulsar-core']:FetchWebsite("account", tonumber(aId))
		dbf = true
	end

	local bannedPlayer = tonumber(aId)

	local expStr = "Never"
	if expires ~= -1 then
		expires = (os.time() + ((60 * 60 * 24) * expires))
		expStr = os.date("%Y-%m-%d at %I:%M:%S %p", expires)
	end

	local banStr = string.format(
		"%s (Account: %s) Was Permanently Banned By %s. Reason: %s",
		tPlayer and tPlayer:GetData("Name") or "Unknown",
		tPlayer and tPlayer:GetData("AccountID") or bannedPlayer,
		issuer,
		reason
	)

	if expires ~= -1 then
		banStr = string.format(
			"%s (Account: %s) Was Banned By %s Until %s. Reason: %s",
			(tPlayer and tPlayer:GetData("Name") or "Unknown"),
			(tPlayer and tPlayer:GetData("AccountID") or bannedPlayer),
			issuer,
			expStr,
			reason
		)
	end

	if tPlayer == nil then
		if
			exports['pulsar-core']:PunishmentActionsBan(
				nil,
				tonumber(aId),
				nil,
				bannedPlayer,
				{},
				reason,
				expires,
				expStr,
				issuer,
				iPlayer:GetData("AccountID"),
				false
			)
		then
			exports['pulsar-core']:LoggerInfo(
				"Punishment",
				banStr,
				{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
				{
					player = bannedPlayer,
					account = tonumber(aId),
					reason = reason,
					issuer = issuer,
					expires = expStr,
				}
			)

			return {
				success = true,
				AccountID = tonumber(aId),
				reason = reason,
				expires = expires,
				banStr = banStr,
			}
		end
	else
		local tPerms = 0

		if tPlayer:GetData("Source") ~= nil then
			for k, v in ipairs(tPlayer:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
				if group and group.Permission then
					if group.Permission.Level > tPerms then
						tPerms = group.Permission.Level
					end
				end
			end
		else
			-- Offline so Cannot Get Groups - Just allow devs for now
			tPerms = 99
		end

		if iPlayer.Permissions:GetLevel() <= tPerms then
			return {
				success = false,
				message = "Insufficient Permissions",
			}
		end

		if
			exports['pulsar-core']:PunishmentActionsBan(
				tPlayer:GetData("Source"),
				tPlayer:GetData("AccountID"),
				tPlayer:GetData("Identifier"),
				tPlayer:GetData("Name"),
				tPlayer:GetData("Tokens"),
				reason,
				expires,
				expStr,
				issuer,
				iPlayer:GetData("AccountID"),
				false
			)
		then
			exports['pulsar-core']:LoggerInfo(
				"Punishment",
				banStr,
				{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
				{
					player = bannedPlayer,
					account = tPlayer:GetData("AccountID"),
					identifier = tPlayer:GetData("Identifier"),
					reason = reason,
					issuer = issuer,
					expires = expStr,
				}
			)

			local retData = {
				success = true,
				Name = tPlayer:GetData("Name"),
				AccountID = tPlayer:GetData("AccountID"),
				expires = expires,
				reason = reason,
				banStr = banStr,
			}

			CreateThread(function()
				if dbf and tPlayer then
					tPlayer:DeleteStore()
				end
			end)

			return retData
		end
	end
end)

exports("PunishmentBanIdentifier", function(identifier, expires, reason, issuer)
	local iPlayer = exports['pulsar-core']:FetchSource(issuer)
	if not iPlayer then
		return {
			success = false,
		}
	end

	if iPlayer:GetData("Identifier") == identifier then
		return {
			success = false,
			message = "Cannot Ban Yourself!",
		}
	end

	local tPlayer = exports['pulsar-core']:FetchPlayerData("Identifier", identifier)

	issuer = string.format("%s [%s]", iPlayer:GetData("Name"), iPlayer:GetData("AccountID"))

	local dbf = false
	if tPlayer == nil then
		tPlayer = exports['pulsar-core']:FetchWebsite("identifier", identifier)
		dbf = true
	end

	local expStr = "Never"
	if expires ~= -1 then
		expires = (os.time() + ((60 * 60 * 24) * expires))
		expStr = os.date("%Y-%m-%d at %I:%M:%S %p", expires)
	end

	local banStr = string.format(
		"%s (Identifier: %s) Was Permanently Banned By %s. Reason: %s",
		tPlayer and tPlayer:GetData("Name") or "Unknown",
		tPlayer and tPlayer:GetData("Identifier") or identifier,
		issuer,
		reason
	)
	if expires ~= -1 then
		banStr = string.format(
			"%s (Identifier: %s) Was Banned By %s Until %s. Reason: %s",
			tPlayer and tPlayer:GetData("Name") or "Unknown",
			tPlayer and tPlayer:GetData("Identifier") or identifier,
			issuer,
			expStr,
			reason
		)
	end

	if tPlayer == nil then
		if
			exports['pulsar-core']:PunishmentActionsBan(
				nil,
				nil,
				identifier,
				bannedPlayer,
				{},
				reason,
				expires,
				expStr,
				issuer,
				iPlayer:GetData("AccountID"),
				false
			)
		then
			exports['pulsar-core']:LoggerInfo(
				"Punishment",
				banStr,
				{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
				{
					player = identifier,
					identifier = identifier,
					reason = reason,
					issuer = issuer,
					expires = expStr,
				}
			)

			if dbf and tPlayer then
				tPlayer:DeleteStore()
			end

			return {
				success = true,
				Identifier = identifier,
				reason = reason,
				expires = expires,
				banStr = banStr,
			}
		end
	else
		local tPerms = 0

		if tPlayer:GetData("Source") ~= nil then
			for k, v in ipairs(tPlayer:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
				if group and group.Permission then
					if group.Permission.Level > tPerms then
						tPerms = group.Permission.Level
					end
				end
			end
		else
			for k, v in ipairs(tPlayer:GetData("Groups")) do
				local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
				if group and group.Permission then
					if group.Permission.Level > tPerms then
						tPerms = group.Permission.Level
					end
				end
			end
		end

		if iPlayer.Permissions:GetLevel() <= tPerms then
			return {
				success = false,
				message = "Insufficient Permissions",
			}
		end

		if
			exports['pulsar-core']:PunishmentActionsBan(
				tPlayer:GetData("Source"),
				tPlayer:GetData("AccountID"),
				tPlayer:GetData("Identifier"),
				tPlayer:GetData("Name"),
				tPlayer:GetData("Tokens"),
				reason,
				expires,
				expStr,
				issuer,
				false
			)
		then
			exports['pulsar-core']:LoggerInfo(
				"Punishment",
				banStr,
				{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
				{
					player = tPlayer:GetData("Name"),
					account = tPlayer:GetData("AccountID"),
					identifier = tPlayer:GetData("Identifier"),
					reason = reason,
					issuer = issuer,
					expires = expStr,
				}
			)

			local retData = {
				success = true,
				Name = tPlayer:GetData("Name"),
				AccountID = tPlayer:GetData("AccountID"),
				Identifier = tPlayer:GetData("Identifier"),
				expires = expires,
				reason = reason,
				banStr = banStr,
			}

			if dbf and tPlayer then
				tPlayer:DeleteStore()
			end

			return retData
		end
	end

	if dbf then
		tPlayer:DeleteStore()
	end
end)

exports("PunishmentActionsKick", function(tSource, reason, issuer)
	DropPlayer(tSource, string.format("Kicked From The Server By %s\nReason: %s", issuer, reason))
end)

-- Helper function
function handleBanResult(banId, tSource, reason, expires, expStr, mask)
	if mask then
		reason = "💙 From Pwnzor 🙂"
	end

	if tSource ~= nil then
		if expires ~= -1 then
			DropPlayer(
				tSource,
				string.format(
					"You're Banned, Appeal in Discord\n\nReason: %s\nExpires: %s\nID: %s",
					reason,
					expStr,
					banId
				)
			)
		else
			DropPlayer(
				tSource,
				string.format(
					"You're Permanently Banned, Appeal in Discord\n\nReason: %s\nID: %s",
					reason,
					banId
				)
			)
		end
	end
end

exports("PunishmentActionsBan",
	function(tSource, tAccount, tIdentifier, tName, tTokens, reason, expires, expStr, issuer, issuerId, mask)
		local p = promise.new()

				if (not tTokens or #tTokens == 0) and tSource then
			tTokens = {}
			for i = 0, GetNumPlayerTokens(tSource) - 1 do
				table.insert(tTokens, GetPlayerToken(tSource, i))
			end
		end

		tAccount = tonumber(tAccount)

		local whereConditions = { "active = 1" }
		local params = {}

		if tAccount then
			table.insert(whereConditions, "account = ?")
			table.insert(params, tAccount)
		end

		if tIdentifier then
			table.insert(whereConditions, "identifier = ?")
			table.insert(params, tIdentifier)
		end

		local whereClause = table.concat(whereConditions, " OR ")

		exports.oxmysql:execute('SELECT * FROM bans WHERE ' .. whereClause, params, function(existingResults)
			if existingResults and #existingResults > 0 then
				local banId = existingResults[1].id
				local tokensJson = json.encode(tTokens)

				exports.oxmysql:execute(
					'UPDATE bans SET account = ?, identifier = ?, expires = ?, reason = ?, issuer = ?, active = 1, started = ?, tokens = ? WHERE id = ?',
					{ tAccount, tIdentifier, expires, reason, issuer, os.time(), tokensJson, banId },
					function(result)
						if result and result.affectedRows > 0 then
							p:resolve(true)
							handleBanResult(banId, tSource, reason, expires, expStr, mask)
						else
							p:resolve(false)
						end
					end
				)
			else
				local tokensJson = json.encode(tTokens)

				exports.oxmysql:execute(
					'INSERT INTO bans (account, identifier, expires, reason, issuer, active, started, tokens) VALUES (?, ?, ?, ?, ?, 1, ?, ?)',
					{ tAccount, tIdentifier, expires, reason, issuer, os.time(), tokensJson },
					function(result)
						if result and result.insertId then
							p:resolve(true)
							handleBanResult(result.insertId, tSource, reason, expires, expStr, mask)
						else
							exports['pulsar-core']:LoggerError(
								"[^8Error^7] Error inserting ban: " .. tostring(result),
								{ console = true, file = true, database = true, discord = { embed = true, type = "error" } }
							)
							p:resolve(false)
						end
					end
				)
			end
		end)

		return Citizen.Await(p)
	end)

exports("PunishmentActionsUnban", function(ids, issuer)
	local _ids = {}
	for k, v in ipairs(ids) do
		if v.tokens then
			v.tokens = json.decode(v.tokens)
		end
		if v.unbanned then
			v.unbanned = json.decode(v.unbanned)
		end

		v._id = v.id

		local unbannedJson = json.encode({
			issuer = issuer:GetData("Name"),
			date = os.time()
		})

		exports.oxmysql:execute(
			'UPDATE bans SET active = 0, unbanned = ? WHERE id = ? AND active = 1',
			{ unbannedJson, v.id },
			function(affectedRows)
			end
		)

		table.insert(_ids, v.id)
	end

	exports['pulsar-core']:LoggerInfo(
		"Punishment",
		string.format("%s Bans Revoked By %s [%s]", #ids, issuer:GetData("Name"), issuer:GetData("AccountID")),
		{ console = true, file = true, database = true, discord = { embed = true, type = "info" } },
		{
			issuer = string.format("%s [%s]", issuer:GetData("Name"), issuer:GetData("AccountID")),
		},
		_ids
	)
end)
