_requests = {}
_requestors = {}
_raidedApartments = {}

local RESOURCE = GetCurrentResourceName()

AddEventHandler("onResourceStart", function(resource)
	if resource == RESOURCE then
		Wait(1000)
		RegisterCallbacks()
		RegisterMiddleware()
		Startup()
	end
end)

exports("Enter", function(source, targetType, target, wakeUp)
	targetType = tonumber(targetType) or 1
	local char = exports["pulsar-characters"]:FetchCharacterSource(source)
	if not char or not _aptData[targetType] then
		return false
	end

	local owner = tonumber(target)
	if owner == -1 or owner == nil then
		owner = char:GetData("SID")
	end

	local canEnter = owner == char:GetData("SID")

	if not canEnter and _requestors[source] == owner then
		for _, request in ipairs(_requests[owner] or {}) do
			if request.source == source then
				canEnter = true
				break
			end
		end
	end

	if not canEnter and _raidedApartments[targetType] and _raidedApartments[targetType].target == owner then
		canEnter = Player(source).state.onDuty == "police"
	end

	if not canEnter then
		return false
	end

	Player(source).state.inApartment = {
		type = targetType,
		id = owner,
	}

	local apartment = _aptData[targetType]
	local routeId = exports["pulsar-core"]:RequestRouteId(string.format("Apartment:Floor:%s:%s", apartment.buildingName, apartment.floor), false)
	exports["pulsar-pwnzor"]:TempPosIgnore(source)
	exports["pulsar-core"]:AddPlayerToRoute(source, routeId)
	GlobalState[string.format("%s:Apartment", source)] = owner
	GlobalState[string.format("%s:", source)] = owner
	Player(source).state.tpLocation = {
		x = apartment.coords.x,
		y = apartment.coords.y,
		z = apartment.coords.z,
	}

	TriggerClientEvent("Apartment:Client:InnerStuff", source, targetType, owner, wakeUp)
	return targetType
end)

exports("Exit", function(source)
	exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
	exports["pulsar-pwnzor"]:TempPosIgnore(source)
	GlobalState[string.format("%s:Apartment", source)] = nil
	GlobalState[string.format("%s:", source)] = nil
	Player(source).state.inApartment = nil
	Player(source).state.tpLocation = nil
	return true
end)

exports("GetInteriorLocation", function(apartment)
	local aptId = tonumber(apartment)
	if not aptId or aptId == 0 then
		-- New character with no apartment yet — spawn at building entrance
		return { x = -461.8189, y = -914.9046, z = 27.1006, h = 87.8875 }
	end
	local apt = _aptData[aptId]
	return apt and apt.interior and apt.interior.wakeup or nil
end)

exports("RequestsGet", function(source)
	local owner = GlobalState[string.format("%s:Apartment", source)]
	return owner and (_requests[owner] or {}) or {}
end)

exports("RequestsCreate", function(source, target, inZone)
	target = tonumber(target)
	if not target or target == source then
		return false
	end

	local char = exports["pulsar-characters"]:FetchCharacterSource(source)
	local targetAptId = GetCharacterApartment(target)
	if not char or not targetAptId then
		return false
	end

	local expectedZone = string.format("apt-%s", targetAptId)
	local zoneId = type(inZone) == "table" and inZone.id or inZone
	if zoneId and zoneId ~= expectedZone then
		return false
	end

	_requests[target] = _requests[target] or {}
	for _, request in ipairs(_requests[target]) do
		if request.source == source then
			return true
		end
	end

	_requestors[source] = target
	table.insert(_requests[target], {
		source = source,
		SID = char:GetData("SID"),
		First = char:GetData("First"),
		Last = char:GetData("Last"),
	})

	local targetChar = exports["pulsar-characters"]:FetchBySID(target)
	if targetChar then
		exports["pulsar-hud"]:Notification(targetChar:GetData("Source"), "info", "Someone is requesting apartment entry")
	end

	return true
end)

exports("ClientEnter", function(source, targetType, target, wakeUp)
	TriggerClientEvent("Apartment:Client:Enter", source, targetType, target, wakeUp)
end)

exports("StartRaid", function(source, apartmentId)
	if Player(source).state.onDuty ~= "police" then
		return false
	end

	apartmentId = tonumber(apartmentId)
	if not apartmentId then return false end

	local characterSID = GetApartmentOwner(apartmentId)
	if not characterSID then return false end

	_raidedApartments[apartmentId] = {
		target = characterSID,
		started = os.time(),
	}
	GlobalState[string.format("Apartment:Raid:%s", apartmentId)] = true
	OpenApartmentDoorForRaid(apartmentId)
	TriggerClientEvent("Apartment:Client:RaidStateChanged", -1, apartmentId, true)
	return true
end)

exports("EndRaid", function(apartmentId)
	apartmentId = tonumber(apartmentId)
	_raidedApartments[apartmentId] = nil
	GlobalState[string.format("Apartment:Raid:%s", apartmentId)] = nil
	LockApartmentDoor(apartmentId, true)
	TriggerClientEvent("Apartment:Client:RaidStateChanged", -1, apartmentId, false)
	return true
end)
