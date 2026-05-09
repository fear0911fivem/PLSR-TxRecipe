_aptData = {}
_aptDataByRoomId = {}
_assignedApartments = {}
_apartmentAssignments = {}
_availableApartments = {}

local INACTIVE_RELEASE_DAYS = 30

local function LogInfo(message)
	exports["pulsar-core"]:LoggerInfo("Custom Apartments", message, { console = true })
end

function EnsureApartmentTables()
	MySQL.query.await([[
		CREATE TABLE IF NOT EXISTS `apartment_assignments` (
			`id` INT NOT NULL AUTO_INCREMENT,
			`apartment_id` INT NOT NULL,
			`character_id` INT NULL DEFAULT NULL,
			`character_sid` INT NOT NULL,
			`assigned_at` BIGINT NOT NULL,
			`last_seen` BIGINT NULL DEFAULT NULL,
			`rent_paid_at` BIGINT NULL DEFAULT NULL,
			`rent_grace_until` BIGINT NULL DEFAULT NULL,
			PRIMARY KEY (`id`),
			UNIQUE KEY `uniq_apartment_id` (`apartment_id`),
			UNIQUE KEY `uniq_character_sid` (`character_sid`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])
	-- Safe migration for existing tables that predate the rent columns
	MySQL.query.await("ALTER TABLE `apartment_assignments` ADD COLUMN IF NOT EXISTS `rent_paid_at` BIGINT NULL DEFAULT NULL")
	MySQL.query.await("ALTER TABLE `apartment_assignments` ADD COLUMN IF NOT EXISTS `rent_grace_until` BIGINT NULL DEFAULT NULL")
end

function BuildApartmentData()
	_aptData = {}
	_aptDataByRoomId = {}
	_availableApartments = {}

	local aptConfigs = GetApartmentDataFromConfig()
	local aptIds = {}

	for _, aptData in ipairs(aptConfigs) do
		local index = #_aptData + 1
		aptData.id = index

		if aptData.roomId then
			_aptDataByRoomId[aptData.roomId] = aptData
		end

		table.insert(_aptData, aptData)
		GlobalState[string.format("Apartment:%s", index)] = aptData
		table.insert(aptIds, index)

		exports.ox_inventory:RegisterStash(
			string.format("apartment_%s", index),
			string.format("%s Stash", aptData.name),
			50,
			100000,
			false
		)
	end

	GlobalState["Apartments"] = aptIds
end

function UpdateAvailableApartments()
	_availableApartments = {}

	for _, aptData in ipairs(_aptData) do
		if aptData.id and not _assignedApartments[aptData.id] then
			table.insert(_availableApartments, aptData.id)
		end
	end

	GlobalState["AvailableApartments"] = _availableApartments
end

function LoadApartmentAssignments()
	_assignedApartments = {}
	_apartmentAssignments = {}

	local now = os.time() * 1000
	local cutoff = now - (INACTIVE_RELEASE_DAYS * 24 * 60 * 60 * 1000)
	local assignments = MySQL.query.await([[
		SELECT aa.*, c.LastPlayed, c.Deleted
		FROM apartment_assignments aa
		LEFT JOIN characters c ON c.SID = aa.character_sid
	]])

	for _, assignment in ipairs(assignments or {}) do
		local aptId = tonumber(assignment.apartment_id)
		local sid = tonumber(assignment.character_sid)
		local deleted = tonumber(assignment.Deleted) or 0
		local lastPlayed = tonumber(assignment.LastPlayed)
		local shouldRelease = not _aptData[aptId]
			or deleted == 1
			or lastPlayed == nil
			or (lastPlayed ~= -1 and lastPlayed < cutoff)

		if shouldRelease then
			MySQL.query.await("DELETE FROM apartment_assignments WHERE apartment_id = ? OR character_sid = ?", {
				aptId,
				sid,
			})
			if sid then
				MySQL.update.await("UPDATE characters SET Apartment = 0 WHERE SID = ? AND Apartment = ?", { sid, aptId })
			end
		else
			_assignedApartments[aptId] = {
				characterID   = assignment.character_id,
				characterSID  = sid,
				assignedAt    = tonumber(assignment.assigned_at) or now,
				rentPaidAt    = assignment.rent_paid_at    and math.floor(tonumber(assignment.rent_paid_at)    / 1000) or nil,
				rentGraceUntil = assignment.rent_grace_until and math.floor(tonumber(assignment.rent_grace_until) / 1000) or nil,
			}
			_apartmentAssignments[sid] = aptId
			_apartmentAssignments[tostring(sid)] = aptId
		end
	end

	local charactersWithApartments = MySQL.query.await([[
		SELECT SID, Apartment
		FROM characters
		WHERE Deleted = 0 AND Apartment IS NOT NULL AND Apartment > 0
	]])

	for _, character in ipairs(charactersWithApartments or {}) do
		local sid = tonumber(character.SID)
		local aptId = tonumber(character.Apartment)
		if _aptData[aptId] and not _assignedApartments[aptId] and not _apartmentAssignments[sid] then
			AssignApartmentToCharacter(aptId, sid, sid, true)
		end
	end

	UpdateAvailableApartments()
	SyncApartmentDoorAccess()
	LogInfo(string.format("Loaded %s apartment rooms, %s available", #_aptData, #_availableApartments))
end

function AssignApartmentToCharacter(apartmentId, characterID, characterSID, silent)
	apartmentId = tonumber(apartmentId)
	characterSID = tonumber(characterSID)

	if not apartmentId or not characterSID or not _aptData[apartmentId] then
		return false
	end

	if _assignedApartments[apartmentId] or _apartmentAssignments[characterSID] then
		return false
	end

	local now = os.time() * 1000
	local inserted = MySQL.insert.await([[
		INSERT INTO apartment_assignments (apartment_id, character_id, character_sid, assigned_at, last_seen)
		VALUES (?, ?, ?, ?, ?)
	]], {
		apartmentId,
		characterID,
		characterSID,
		now,
		now,
	})

	if not inserted or inserted <= 0 then
		return false
	end

	_assignedApartments[apartmentId] = {
		characterID = characterID,
		characterSID = characterSID,
		assignedAt = now,
	}
	_apartmentAssignments[characterSID] = apartmentId
	_apartmentAssignments[tostring(characterSID)] = apartmentId

	MySQL.update.await("UPDATE characters SET Apartment = ? WHERE SID = ?", { apartmentId, characterSID })
	UpdateAvailableApartments()
	SetApartmentDoorAccess(apartmentId, characterSID)

	if not silent then
		LogInfo(string.format("Assigned apartment %s to character %s", apartmentId, characterSID))
	end

	return true
end

function ReleaseApartmentAssignment(apartmentId, characterSID, silent)
	apartmentId = tonumber(apartmentId)
	characterSID = tonumber(characterSID)

	if not apartmentId or not characterSID then
		return false
	end

	MySQL.query.await("DELETE FROM apartment_assignments WHERE apartment_id = ? AND character_sid = ?", {
		apartmentId,
		characterSID,
	})
	MySQL.update.await("UPDATE characters SET Apartment = 0 WHERE SID = ? AND Apartment = ?", {
		characterSID,
		apartmentId,
	})

	_assignedApartments[apartmentId] = nil
	_apartmentAssignments[characterSID] = nil
	_apartmentAssignments[tostring(characterSID)] = nil
	UpdateAvailableApartments()
	SetApartmentDoorAccess(apartmentId, nil)

	if not silent then
		LogInfo(string.format("Released apartment %s from character %s", apartmentId, characterSID))
	end

	return true
end

function GetCharacterApartment(characterSID)
	return _apartmentAssignments[tonumber(characterSID)] or _apartmentAssignments[tostring(characterSID)]
end

function GetApartmentOwner(apartmentId)
	local assignment = _assignedApartments[tonumber(apartmentId)]
	return assignment and assignment.characterSID or nil
end

function GetRandomAvailableApartment()
	if #_availableApartments == 0 then
		return nil
	end

	return _availableApartments[math.random(1, #_availableApartments)]
end

function GetAvailableApartmentsByBuilding()
	local seen = {}
	local result = {}

	for _, aptId in ipairs(_availableApartments) do
		local apt = _aptData[aptId]
		if apt and apt.buildingName then
			local key = apt.buildingName
			if not seen[key] then
				seen[key] = true
				table.insert(result, {
					buildingName = key,
					label = apt.buildingLabel or key,
					count = 0,
				})
			end
			for _, entry in ipairs(result) do
				if entry.buildingName == key then
					entry.count = entry.count + 1
					break
				end
			end
		end
	end

	return result
end

function GetRandomAvailableApartmentInBuilding(buildingName)
	local available = {}
	for _, aptId in ipairs(_availableApartments) do
		local apt = _aptData[aptId]
		if apt and apt.buildingName == buildingName then
			table.insert(available, aptId)
		end
	end
	if #available == 0 then return nil end
	return available[math.random(1, #available)]
end

function Startup()
	EnsureApartmentTables()
	BuildApartmentData()
	LoadApartmentAssignments()
end
