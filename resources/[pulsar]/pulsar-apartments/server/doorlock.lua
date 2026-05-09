local _doorWarnings = {}
local _ensureDoorsRunning = false

local function DoorResourceReady()
	return GetResourceState("ox_doorlock"):find("start") ~= nil
end

local function DoorDataForOx(door)
	return json.encode({
		coords = {
			x = door.coords.x,
			y = door.coords.y,
			z = door.coords.z,
		},
		model = door.model,
		heading = door.heading,
		state = door.locked == false and 0 or 1,
		characters = {},
		groups = nil,
		items = nil,
		maxDistance = door.maxDistance or 2.0,
		hideUi = false,
		doorRate = 1.0,
	})
end

function EnsureApartmentDoorsInOxDoorlock()
	if _ensureDoorsRunning then
		return 0
	end
	_ensureDoorsRunning = true

	if not DoorResourceReady() then
		exports["pulsar-core"]:LoggerWarn(
			"Custom Apartments",
			"ox_doorlock is not started; apartment room doors were not imported",
			{ console = true }
		)
		_ensureDoorsRunning = false
		return 0
	end

	local created = 0
	for _, door in ipairs(ApartmentDoorDefinitions or {}) do
		if door.id and not exports.ox_doorlock:getDoorFromName(door.id) then
			local insertId = MySQL.insert.await([[
				INSERT INTO ox_doorlock (name, data)
				VALUES (?, ?)
			]], {
				door.id,
				DoorDataForOx(door),
			})

			if insertId and insertId > 0 then
				created += 1
				TriggerEvent("ox_doorlock:reloadDoor", insertId)
			end
		end
	end

	if created > 0 then
		exports["pulsar-core"]:LoggerInfo(
			"Custom Apartments",
			string.format("Imported %s apartment room doors into ox_doorlock", created),
			{ console = true }
		)
	end

	_ensureDoorsRunning = false
	return created
end

local function GetDoorId(doorName)
	if not doorName or not DoorResourceReady() then
		return nil
	end

	local door = exports.ox_doorlock:getDoorFromName(doorName)
	if not door then
		if not _doorWarnings[doorName] then
			_doorWarnings[doorName] = true
			exports["pulsar-core"]:LoggerWarn(
				"Custom Apartments",
				string.format("No ox_doorlock door found named %s", doorName),
				{ console = true }
			)
		end
		return nil
	end

	return door.id
end

function SetApartmentDoorAccess(apartmentId, characterSID)
	local apt = _aptData[tonumber(apartmentId)]
	if not apt or not apt.doorId then
		return false
	end

	local doorId = GetDoorId(apt.doorId)
	if not doorId then
		return false
	end

	local characters = {}
	if characterSID then
		characters = { tonumber(characterSID) }
	end

	exports.ox_doorlock:editDoor(doorId, {
		characters = characters,
		state = 1,
	})

	return true
end

function LockApartmentDoor(apartmentId, locked)
	local apt = _aptData[tonumber(apartmentId)]
	if not apt or not apt.doorId or not DoorResourceReady() then
		return false
	end

	local doorId = GetDoorId(apt.doorId)
	if not doorId then return false end
	return exports.ox_doorlock:SetLock(doorId, locked)
end

function OpenApartmentDoorForRaid(apartmentId)
	local apt = _aptData[tonumber(apartmentId)]
	if not apt or not apt.doorId or not DoorResourceReady() then
		return false
	end

	local doorId = GetDoorId(apt.doorId)
	if not doorId then return false end
	return exports.ox_doorlock:SetForcedOpen(doorId)
end

function SyncApartmentDoorAccess()
	if not DoorResourceReady() then
		exports["pulsar-core"]:LoggerWarn(
			"Custom Apartments",
			"ox_doorlock is not started; apartment door access was not synced",
			{ console = true }
		)
		return
	end

	local created = EnsureApartmentDoorsInOxDoorlock()
	if created and created > 0 then
		Wait(1000)
	end

	for _, apt in ipairs(_aptData) do
		local owner = GetApartmentOwner(apt.id)
		SetApartmentDoorAccess(apt.id, owner)
	end
end

AddEventHandler("ox_doorlock:loaded", function()
	Wait(500)
	if _aptData and #_aptData > 0 then
		SyncApartmentDoorAccess()
	end
end)
