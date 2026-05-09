exports("FirearmSearch", function(term)
	return MySQL.query.await(
		"SELECT serial, model, owner_sid, owner_name FROM firearms WHERE scratched = ? AND (serial = ? OR owner_sid = ? OR owner_name LIKE ?)",
		{
			0,
			term,
			term,
			"%" .. term .. "%"
		})
end)

exports("FirearmView", function(id)
	local firearm = MySQL.single.await(
		"SELECT serial, model, owner_sid, owner_name, purchased FROM firearms WHERE scratched = ? AND serial = ?", {
			0,
			id,
		})

	if firearm and firearm.serial then
		firearm.flags = MySQL.query.await(
			"SELECT title, description, date, author_sid, author_first, author_last, author_callsign FROM firearms_flags WHERE serial = ?",
			{
				firearm.serial
			})
	end

	return firearm
end)

exports("FirearmFlagsAdd", function(firearmSerial, data, author)
	local flag = {
		title = data.title,
		description = data.description,
		author_sid = author.SID,
		author_first = author.First,
		author_last = author.Last,
		author_callsign = author.Callsign,
	}

	local id = MySQL.insert.await(
		"INSERT INTO firearms_flags (serial, title, description, author_sid, author_first, author_last, author_callsign) VALUES (?, ?, ?, ?, ?, ?, ?)",
		{
			firearmSerial,
			flag.title,
			flag.description,
			flag.author_sid,
			flag.author_first,
			flag.author_last,
			flag.author_callsign
		})

	flag.id = id

	return flag
end)

exports("FirearmFlagsRemove", function(firearmSerial, flagId)
	MySQL.query.await("DELETE FROM firearms_flags WHERE id = ? AND serial = ?", {
		flagId,
		firearmSerial
	})
	return true
end)

exports("FirearmRegister", function(serial, model, ownerSid, ownerName)
	local existing = MySQL.single.await(
		"SELECT serial FROM firearms WHERE serial = ?", { serial }
	)

	if existing then
		return false
	end

	local result = MySQL.query.await(
		"INSERT INTO firearms (serial, model, item, owner_sid, owner_name, purchased) VALUES (?, ?, ?, ?, ?, NOW())",
		{ serial, model, model, ownerSid, ownerName }
	)

	return result and true or false
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("MDT:Search:firearm", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			cb(exports['pulsar-mdt']:FirearmSearch(data.term or ""))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:View:firearm", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			cb(exports['pulsar-mdt']:FirearmView(data))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Create:firearm-flag", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and CheckMDTPermissions(source, false) then
			cb(exports['pulsar-mdt']:FirearmFlagsAdd(data.parentId, data.doc, {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
				Callsign = char:GetData("Callsign"),
			}))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Delete:firearm-flag", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			cb(exports['pulsar-mdt']:FirearmFlagsRemove(data.parentId, data.id))
		else
			cb(false)
		end
	end)
end)
