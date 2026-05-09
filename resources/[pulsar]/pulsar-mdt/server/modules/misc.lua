local _runningBoloId = 0

exports("MiscCreateBOLO", function(data)
	data.id = _runningBoloId
	table.insert(_bolos, data)
	for user, _ in pairs(_onDutyUsers) do
		TriggerClientEvent("MDT:Client:AddData", user, "bolos", data)
	end

	_runningBoloId = _runningBoloId + 1
end)

exports("MiscCreateCharge", function(data)
	local id = MySQL.insert.await(
		"INSERT INTO mdt_charges (type, title, description, fine, jail, points) VALUES (?, ?, ?, ?, ?, ?)", {
			data.type,
			data.title,
			data.description,
			data.fine,
			data.jail,
			data.points
		})

	data.id = id

	table.insert(_charges, data)
	for user, _ in pairs(_onDutyUsers) do
		TriggerClientEvent("MDT:Client:AddData", user, "charges", data)
	end
	for user, _ in pairs(_onDutyLawyers) do
		TriggerClientEvent("MDT:Client:AddData", user, "charges", data)
	end

	return true
end)

exports("MiscCreateNotice", function(data)
	if not data.restricted then
		data.restricted = "public"
	end

	local id = MySQL.insert.await(
		"INSERT INTO mdt_notices (title, description, creator, restricted) VALUES (?, ?, ?, ?)", {
			data.title,
			data.description,
			data.author,
			data.restricted
		})

	for user, _ in pairs(_onDutyUsers) do
		TriggerClientEvent("MDT:Client:SetData", user, "homeLastFetch", 0)
	end
	for user, _ in pairs(_onDutyLawyers) do
		TriggerClientEvent("MDT:Client:SetData", user, "homeLastFetch", 0)
	end

	return id
end)

exports("MiscViewNotice", function(id)
	return MySQL.single.await(
		"SELECT id, title, description, creator, created, restricted FROM mdt_notices WHERE id = ?", {
			id
		})
end)

exports("MiscUpdateCharge", function(id, data)
	local u = MySQL.query.await(
		"UPDATE mdt_charges SET type = ?, title = ?, description = ?, fine = ?, jail = ?, points = ? WHERE id = ?",
		{
			data.type,
			data.title,
			data.description,
			data.fine,
			data.jail,
			data.points,
			id
		})

	if u and u.affectedRows > 0 then
		for k, v in ipairs(_charges) do
			if (v.id == id) then
				_charges[k] = data
				break
			end
		end

		for user, _ in pairs(_onDutyUsers) do
			TriggerClientEvent("MDT:Client:UpdateData", user, "charges", id, data)
		end
		for user, _ in pairs(_onDutyLawyers) do
			TriggerClientEvent("MDT:Client:UpdateData", user, "charges", id, data)
		end

		return true
	end
	return false
end)

exports("MiscDeleteBOLO", function(id)
	for k, v in ipairs(_bolos) do
		if v.id == id then
			table.remove(_bolos, k)
			for user, _ in pairs(_onDutyUsers) do
				TriggerClientEvent("MDT:Client:RemoveData", user, "bolos", k)
			end
			return true
		end
	end

	return false
end)

exports("MiscDeleteNotice", function(id)
	MySQL.query.await("DELETE FROM mdt_notices WHERE id = ?", {
		id
	})

	for user, _ in pairs(_onDutyUsers) do
		TriggerClientEvent("MDT:Client:SetData", user, "homeLastFetch", 0)
	end
	for user, _ in pairs(_onDutyLawyers) do
		TriggerClientEvent("MDT:Client:SetData", user, "homeLastFetch", 0)
	end

	return true
end)

exports("MiscDeleteCharge", function(id)
	MySQL.query.await("DELETE FROM mdt_charges WHERE id = ?", {
		id
	})

	for k, v in ipairs(_charges) do
		if (v.id == id) then
			table.remove(_charges, k)
			break
		end
	end

	for user, _ in pairs(_onDutyUsers) do
		TriggerClientEvent("MDT:Client:RemoveData", user, "charges", id)
	end
	for user, _ in pairs(_onDutyLawyers) do
		TriggerClientEvent("MDT:Client:RemoveData", user, "charges", id)
	end

	return true
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("MDT:Create:BOLO", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if CheckMDTPermissions(source, false, 'police') then
			data.doc.author = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
				Callsign = char:GetData("Callsign"),
			}
			exports['pulsar-mdt']:MiscCreateBOLO(data.doc)
			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Delete:BOLO", function(source, data, cb)
		if CheckMDTPermissions(source, false, 'police') then
			cb(exports['pulsar-mdt']:MiscDeleteBOLO(data.id))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Create:charge", function(source, data, cb)
		if CheckMDTPermissions(source, true) then
			data.doc.active = true
			cb(exports['pulsar-mdt']:MiscCreateCharge(data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Update:charge", function(source, data, cb)
		if CheckMDTPermissions(source, true) then
			cb(exports['pulsar-mdt']:MiscUpdateCharge(data.doc.id, data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Delete:charge", function(source, data, cb)
		if CheckMDTPermissions(source, true) then
			cb(exports['pulsar-mdt']:MiscDeleteCharge(data.doc.id))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Create:notice", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and CheckMDTPermissions(source, {
				'PD_HIGH_COMMAND',
				'SAFD_HIGH_COMMAND',
				'DOJ_JUDGE',
				'GOV_MAYOR',
				'GOV_DA',
				'GOV_CPUB',
				'DOC_HIGH_COMMAND',
			}) then
			data.doc.author = char:GetData("SID")
			cb(exports['pulsar-mdt']:MiscCreateNotice(data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:View:notice", function(source, data, cb)
		cb(exports['pulsar-mdt']:MiscViewNotice(data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Delete:notice", function(source, data, cb)
		if CheckMDTPermissions(source, {
				'PD_HIGH_COMMAND',
				'SAFD_HIGH_COMMAND',
				'DOC_HIGH_COMMAND',
			}) then
			cb(exports['pulsar-mdt']:MiscDeleteNotice(data.id))
		else
			cb(false)
		end
	end)
end)
