exports("EmailRead", function(charId, id)
	return MySQL.update.await("UPDATE character_emails SET unread = ? WHERE id = ?", {
		false,
		id,
	}) > 0
end)

exports("EmailSend", function(serverId, sender, time, subject, body, flags, expires)
	local char = exports['pulsar-characters']:FetchCharacterSource(serverId)
	if char ~= nil then
		local id = MySQL.insert.await(
			"INSERT INTO character_emails (sid, sender, subject, body, timestamp, flags, expires) VALUES(?, ?, ?, ?, FROM_UNIXTIME(?), ?, FROM_UNIXTIME(?))",
			{
				char:GetData("SID"),
				sender,
				subject,
				body,
				time,
				flags and json.encode(flags) or nil,
				expires,
			}
		)

		local doc = {
			id = id,
			owner = char:GetData("SID"),
			sender = sender,
			subject = subject,
			body = body,
			time = time,
			unread = true,
			flags = flags,
			expires = expires,
		}

		TriggerClientEvent("Phone:Client:Email:Receive", serverId, doc)
	end
end)

exports("EmailDelete", function(charId, id)
	MySQL.query("DELETE FROM character_emails WHERE sid = ? AND id = ?", {
		charId,
		id,
	})

	local char = exports['pulsar-characters']:FetchBySID(charId)
	if char then
		TriggerClientEvent("Phone:Client:Email:Delete", char:GetData("Source"), id)
	end
end)

AddEventHandler("Phone:Server:RegisterMiddleware", function()
	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local alias = char:GetData("Alias")
		local profiles = char:GetData("Profiles") or {}

		if alias.email then
			local rid = MySQL.insert.await(
				"INSERT INTO character_app_profiles (sid, app, name, picture, meta) VALUES(?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), picture = VALUES(picture), meta = VALUES(meta)",
				{
					char:GetData("SID"),
					"email",
					alias.email,
					nil,
					"{}",
				}
			)

			profiles.email = {
				sid = char:GetData("SID"),
				app = "email",
				name = alias.email,
				picture = nil,
				meta = {},
			}

			alias.email = nil
			char:SetData("Alias", alias)
			char:SetData("Profiles", profiles)
		end

		if not profiles.email then
			local emailaddr = string.format("%s_%s%s@pulsarfw.com", char:GetData("First"), char:GetData("Last"),
				char:GetData("SID"))
			local rid = MySQL.insert.await(
				"INSERT INTO character_app_profiles (sid, app, name, picture, meta) VALUES(?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), picture = VALUES(picture), meta = VALUES(meta)",
				{
					char:GetData("SID"),
					"email",
					emailaddr,
					nil,
					"{}",
				}
			)
			profiles.email = {
				sid = char:GetData("SID"),
				app = "email",
				name = emailaddr,
				picture = nil,
				meta = {},
			}
			char:SetData("Profiles", profiles)
		end
	end, 2)

	exports['pulsar-core']:MiddlewareAdd("Phone:Spawning", function(source, char)
		local emails = MySQL.rawExecute.await(
			"SELECT id, sid, sender, subject, body, UNIX_TIMESTAMP(timestamp) as time, flags, expires FROM character_emails WHERE sid = ? AND (expires IS NULL or expires > NOW()) ORDER BY time DESC LIMIT 150",
			{
				char:GetData("SID"),
			}
		)

		for k, v in ipairs(emails) do
			if v.flags ~= nil then
				v.flags = json.decode(v.flags)
			end
		end

		return {
			{
				type = "emails",
				data = emails,
			},
		}
	end)

	exports['pulsar-core']:MiddlewareAdd("Phone:CreateProfiles", function(source, cData)
		local name = string.format("%s_%s%d@pulsarfw.com", cData.First, cData.Last, cData.SID)

		local id = MySQL.insert.await(
			"INSERT INTO character_app_profiles (sid, app, name) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), picture = VALUES(picture), meta = VALUES(meta)",
			{
				cData.SID,
				"email",
				name,
			})

		return {
			{
				app = "email",
				profile = {
					sid = cData.SID,
					app = "email",
					name = name,
					picture = nil,
					meta = {},
				},
			},
		}
	end)
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-chat"]:RegisterAdminCommand("email", function(source, args, rawCommand)
		local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
		if char ~= nil then
			exports['pulsar-phone']:EmailSend(char:GetData("Source"), args[2], os.time(), args[3], args[4])
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Invalid State ID")
		end
	end, {
		help = "Send Email To Player",
		params = {
			{
				name = "Target",
				help = "State ID",
			},
			{
				name = "Sender Email",
				help = "Email To Show As Sender, EX: scaryman@something.net",
			},
			{
				name = "Subject",
				help = "Subject Line Of Email",
			},
			{
				name = "Body",
				help = "Body of email to send",
			},
		},
	}, 4)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Email:Read", function(source, data, cb)
		cb(exports['pulsar-phone']:EmailRead(data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Email:Delete", function(source, data, cb)
		local src = source
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		cb(exports['pulsar-phone']:EmailDelete(char:GetData("SID"), data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Email:DeleteExpired", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local ids = MySQL.rawExecute.await(
				"SELECT id FROM character_emails WHERE sid = ? AND expires IS NOT NULL and expires < NOW()",
				{
					char:GetData("SID"),
				}
			)

			local idsraw = {}
			for k, v in ipairs(ids) do
				table.insert(idsraw, v.id)
			end

			MySQL.query("DELETE FROM character_emails WHERE id IN (" .. table.concat(idsraw) .. ")")

			cb(idsraw)
		end
	end)
end)
