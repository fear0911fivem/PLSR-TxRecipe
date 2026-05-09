local _noUpdate = { "Source", "User", "_id", "ID", "First", "Last", "Phone", "DOB", "Gender", "TempJob", "Ped",
	"MDTHistory", "Parole", "Preview", "Team", "LSUNDGBan", "MDTSuspension", "Profiles", "TempJob", "License",
	"Inventory" }

local _saving = {}

local function tableContains(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

function StoreData(source)
	if _saving[source] then
		return
	end
	_saving[source] = true
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local data = char:GetData()
		local cId = data.ID
		for k, v in ipairs(_noUpdate) do
			data[v] = nil
		end

		local ped = GetPlayerPed(source)
		if ped > 0 then
			data.HP = GetEntityHealth(ped)
			data.Armor = GetPedArmour(ped)
		end

		if data.States then
			local s = {}
			for k, v in ipairs(data.States) do
				if string.sub(v, 1, string.len("SCRIPT")) ~= "SCRIPT" then
					table.insert(s, v)
				end
			end
			data.States = s
		end

		data.LastPlayed = os.time() * 1000

		exports['pulsar-core']:LoggerTrace("Characters", string.format("Saving Character %s", cId), { console = true })

		local dbData = exports['pulsar-core']:CloneDeep(data)

		local jsonFields = {}
		for _, f in ipairs(TablesToDecode) do jsonFields[f] = true end
		for k, v in pairs(dbData) do
			if type(v) == "table" or (type(v) == "string" and jsonFields[k]) then
				dbData[k] = json.encode(v)
			end
		end

		local updateFields = {}
		for k, v in pairs(dbData) do
			if not tableContains(_noUpdate, k) then
				table.insert(updateFields, string.format("`%s` = @%s", k, k))
			end
		end

		local query = string.format([[
			UPDATE `characters` SET %s WHERE `SID` = @ID
		]], table.concat(updateFields, ", "))

		dbData['@ID'] = cId

		local saveCharacter = MySQL.update.await(query, dbData)
		_saving[source] = false

		exports['pulsar-core']:LoggerTrace("Characters",
			string.format("Character %s has been saved to the Database successfully", cId),
			{ console = true })
	end
end

-- local _prevSaved = 0
-- CreateThread(function()

-- 	-- Wait(120000)

-- 	-- while true do
-- 	-- 	local v = Fetch:Next(_prevSaved)
-- 	-- 	exports['pulsar-core']:LoggerTrace(
-- 	-- 		"Characters",
-- 	-- 		string.format("BEFORE SAVE, _prevSaved: %s, v ~= nil: %s", _prevSaved, tostring(v ~= nil)),
-- 	-- 		{ console = true }
-- 	-- 	)
-- 	-- 	if v ~= nil then
-- 	-- 		local s = v:GetData("Source")
-- 	-- 		if v:GetData("Character") ~= nil then
-- 	-- 			StoreData(s)
-- 	-- 		end
-- 	-- 		_prevSaved = s
-- 	-- 	else
-- 	-- 		_prevSaved = 0
-- 	-- 	end
-- 	-- 	local c = exports['pulsar-characters']:FetchCountCharacters() or 1
-- 	-- 	exports['pulsar-core']:LoggerTrace(
-- 	-- 		"Characters",
-- 	-- 		string.format("AFTER SAVE, _prevSaved: %s, c: %s", _prevSaved, c),
-- 	-- 		{ console = true }
-- 	-- 	)

-- 	-- 	Wait(math.min(600000, (1200000 / math.max(1, c))))
-- 	-- end
-- end)
