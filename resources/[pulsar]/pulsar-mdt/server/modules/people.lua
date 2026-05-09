local requiredCharacterData = {
	SID = 1,
	User = 1,
	First = 1,
	Last = 1,
	Gender = 1,
	Origin = 1,
	Jobs = 1,
	DOB = 1,
	Callsign = 1,
	Phone = 1,
	Licenses = 1,
	Qualifications = 1,
	Flags = 1,
	Mugshot = 1,
	MDTSystemAdmin = 1,
	MDTHistory = 1,
	MDTSuspension = 1,
	Attorney = 1,
	LastClockOn = 1,
	TimeClockedOn = 1,
}

function GetCharacterVehiclesData(sid)
	local p = promise.new()

	local vehicles = MySQL.query.await("SELECT * FROM vehicles WHERE OwnerId = ?", { sid })
	p:resolve(vehicles)

	return Citizen.Await(p)
end

exports("PeopleSearchPeople", function(term)
	local p = promise.new()
	MySQL.query(
		"SELECT SID, First, Last, DOB, Licenses FROM characters WHERE (CONCAT(First, ' ', Last) LIKE ? OR SID LIKE ?) AND (Deleted = 0 OR Deleted IS NULL) LIMIT 4",
		{ "%" .. term .. "%", "%" .. term .. "%" },
		function(results)
			if not results then
				p:resolve(false)
				return
			end
			p:resolve(results)
		end
	)
	return Citizen.Await(p)
end)

exports("PeopleView", function(id, requireAllData)
	local SID = tonumber(id)

	local character = MySQL.single.await(
		"SELECT SID, User, First, Last, Gender, Origin, Jobs, DOB, Callsign, Phone, Licenses, Qualifications, Flags, MDTSystemAdmin, MDTHistory, Attorney, LastClockOn, TimeClockedOn FROM characters WHERE SID = ? AND (Deleted = 0 OR Deleted IS NULL)",
		{ SID }
	)

	if not character then
		return false
	end

	if character.Origin then
		character.Origin = json.decode(character.Origin)
	end
	if character.Jobs then
		character.Jobs = json.decode(character.Jobs)
	end
	if character.Licenses then
		character.Licenses = json.decode(character.Licenses)
	end
	if character.Qualifications then
		character.Qualifications = json.decode(character.Qualifications)
		if type(character.Qualifications) == "table" and not character.Qualifications[1] then
			local quals = {}
			for k, v in pairs(character.Qualifications) do
				table.insert(quals, k)
			end
			character.Qualifications = quals
		elseif type(character.Qualifications) ~= "table" then
			character.Qualifications = {}
		end
	end
	if character.Flags then
		character.Flags = json.decode(character.Flags)
	end
	if character.MDTHistory then
		character.MDTHistory = json.decode(character.MDTHistory)
	end
	if character.LastClockOn then
		character.LastClockOn = json.decode(character.LastClockOn)
	end
	if character.TimeClockedOn then
		character.TimeClockedOn = json.decode(character.TimeClockedOn)
	end

	if requireAllData then
		local vehicles = GetCharacterVehiclesData(SID)
		local ownedBusinesses = {}

		if character.Jobs then
			for k, v in ipairs(character.Jobs) do
				local jobData = exports['pulsar-jobs']:Get(v.Id)
				if jobData and jobData.Owner and jobData.Owner == character.SID then
					table.insert(ownedBusinesses, v.Id)
				end
			end
		end

		local parole = MySQL.single.await("SELECT end, total, parole FROM character_parole WHERE SID = ?", { SID })

		local chargesData = MySQL.query.await(
			"SELECT SID, charges FROM mdt_reports_people WHERE sentenced = ? AND type = ? AND SID = ? AND expunged = ?",
			{ 1, "suspect", SID, 0 }
		)

		local convictions = {}
		for k, v in ipairs(chargesData) do
			local c = json.decode(v.charges)
			for _, ch in ipairs(c) do
				table.insert(convictions, ch)
			end
		end

		return {
			data = character,
			parole = parole,
			convictions = convictions,
			vehicles = vehicles,
			ownedBusinesses = ownedBusinesses,
		}
	else
		return character
	end
end)

exports("PeopleUpdate", function(requester, id, key, value)
	local logVal = value
	if type(value) == "table" then
		logVal = json.encode(value)
	end

	local currentHistory = MySQL.single.await("SELECT MDTHistory FROM characters WHERE SID = ?", { id })
	local history = {}
	if currentHistory and currentHistory.MDTHistory then
		history = json.decode(currentHistory.MDTHistory) or {}
	end

	local newEntry = {
		Time = (os.time() * 1000),
		Char = requester == -1 and -1 or requester:GetData("SID"),
		Log = requester == -1 and
			string.format("System Updated Profile, Set %s To %s", key, logVal) or
			string.format(
				"%s Updated Profile, Set %s To %s",
				requester:GetData("First") .. " " .. requester:GetData("Last"),
				key,
				logVal
			)
	}
	table.insert(history, newEntry)

	local dbValue
	if key == "MDTSystemAdmin" then
		dbValue = (value == true or value == "true" or value == 1) and 1 or 0
	elseif type(value) == "table" then
		dbValue = json.encode(value)
	else
		dbValue = value
	end

	local success = MySQL.update.await(
		"UPDATE characters SET " .. key .. " = ?, MDTHistory = ? WHERE SID = ?",
		{ dbValue, json.encode(history), id }
	)

	if success then
		local target = exports['pulsar-characters']:FetchBySID(id)
		if target then
			target:SetData(key, value)
		end

		if key == "Mugshot" then
			exports.ox_inventory:UpdateGovIDMugshot(id, value)
		end
	end

	return success
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("MDT:InputSearch:people", function(source, data, cb)
		MySQL.query(
			"SELECT SID, First, Last, DOB, Licenses FROM characters WHERE (CONCAT(First, ' ', Last) LIKE ? OR SID LIKE ?) AND (Deleted = 0 OR Deleted IS NULL) LIMIT 4",
			{ "%" .. data.term .. "%", "%" .. data.term .. "%" },
			function(results)
				if type(results) == "table" then
					cb(results)
				else
					cb({})
				end
			end
		)
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:InputSearch:job", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			MySQL.query(
				"SELECT SID, First, Last, Callsign FROM characters WHERE (CONCAT(First, ' ', Last) LIKE ? OR Callsign LIKE ? OR SID LIKE ?) AND Jobs LIKE ? AND (Deleted = 0 OR Deleted IS NULL) LIMIT 4",
				{ "%" .. data.term .. "%", "%" .. data.term .. "%", "%" .. data.term .. "%", '%"Id":"' ..
				data.job .. '"%' },
				function(results)
					if type(results) == "table" then
						cb(results)
					else
						cb({})
					end
				end
			)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:InputSearchSID", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			MySQL.single(
				"SELECT SID, First, Last, DOB, Licenses FROM characters WHERE SID = ? AND (Deleted = 0 OR Deleted IS NULL)",
				{ tonumber(data.term) },
				function(results)
					if type(results) == "table" then
						cb({ results })
					else
						cb({})
					end
				end
			)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Search:people", function(source, data, cb)
		cb(exports['pulsar-mdt']:PeopleSearchPeople(data.term))
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:View:person", function(source, data, cb)
		cb(exports['pulsar-mdt']:PeopleView(data, true))
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Update:person", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and CheckMDTPermissions(source, false) and data.SID then
			cb(exports['pulsar-mdt']:PeopleUpdate(char, data.SID, data.Key, data.Data))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:CheckCallsign", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			MySQL.single(
				"SELECT SID, Callsign FROM characters WHERE Callsign = ? AND (Deleted = 0 OR Deleted IS NULL)",
				{ data },
				function(success, results)
					cb(not success or not results)
				end
			)
		else
			cb(false)
		end
	end)
end)
