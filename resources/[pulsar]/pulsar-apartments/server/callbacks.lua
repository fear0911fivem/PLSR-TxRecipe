local RESOURCE = GetCurrentResourceName()

local function GetChar(source)
	return exports["pulsar-characters"]:FetchCharacterSource(source)
end

local function EnsureApartmentForCharacter(char)
	local sid = char:GetData("SID")
	local aptId = GetCharacterApartment(sid) or tonumber(char:GetData("Apartment"))

	if aptId and aptId > 0 and _aptData[aptId] then
		if not GetCharacterApartment(sid) then
			AssignApartmentToCharacter(aptId, char:GetData("ID") or sid, sid, true)
		end
		return aptId
	end

	aptId = GetRandomAvailableApartment()
	if not aptId then
		return nil
	end

	if AssignApartmentToCharacter(aptId, char:GetData("ID") or sid, sid) then
		char:SetData("Apartment", aptId)
		return aptId
	end

	return nil
end

function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Apartment:Validate", function(source, data, cb)
		local char = GetChar(source)
		local pState = Player(source).state
		local isOwner = char and pState.inApartment and pState.inApartment.id == char:GetData("SID")

		if data and data.type == "stash" and pState.inApartment then
			cb(true)
		elseif data and (data.type == "wardrobe" or data.type == "logout") then
			cb(isOwner == true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:SpawnInside", function(source, data, cb)
		local char = GetChar(source)
		if not char then
			cb(false)
			return
		end

		local sid = char:GetData("SID")
		local existingApt = GetCharacterApartment(sid) or tonumber(char:GetData("Apartment"))
		if not existingApt or existingApt == 0 then
			cb(false)
			SetTimeout(1500, function()
				if GetPlayerPing(source) > 0 then
					TriggerClientEvent("Apartment:Client:SelectBuilding", source)
				end
			end)
			return
		end

		local aptId = EnsureApartmentForCharacter(char)
		if aptId then
			local result = exports[RESOURCE]:Enter(source, aptId, -1, true)
			if result then
				SetTimeout(3000, function()
					CheckRentDue(source, char:GetData("SID"))
				end)
			end
			cb(result)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Enter", function(source, data, cb)
		cb(exports[RESOURCE]:Enter(source, data.tier, data.id))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Exit", function(source, data, cb)
		cb(exports[RESOURCE]:Exit(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:GetVisitRequests", function(source, data, cb)
		cb(exports[RESOURCE]:RequestsGet(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Visit", function(source, data, cb)
		cb(exports[RESOURCE]:Enter(source, data.tier, data.id))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:RequestEntry", function(source, data, cb)
		local aptId = tonumber(data.aptId)
		if not aptId then
			cb(false)
			return
		end
		local ownerSID = GetApartmentOwner(aptId)
		if not ownerSID then
			cb(false)
			return
		end
		cb(exports[RESOURCE]:RequestsCreate(source, ownerSID, string.format("apt-%s", aptId)))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:RequestApartment", function(source, data, cb)
		local char = GetChar(source)
		if not char then
			cb({ success = false, message = "Character not found" })
			return
		end

		local sid = char:GetData("SID")
		if GetCharacterApartment(sid) or (tonumber(char:GetData("Apartment")) or 0) > 0 then
			cb({ success = false, message = "You already have an apartment assigned" })
			return
		end

		local aptId = EnsureApartmentForCharacter(char)
		if not aptId then
			cb({ success = false, message = "No apartments are available" })
			return
		end

		local apt = _aptData[aptId]

		if source and source > 0 then
			exports["pulsar-phone"]:EmailSend(
				source,
				"apartments@nexus.gov",
				os.time(),
				"Apartment Assignment Confirmation",
				string.format(
					"Your apartment request has been approved!<br><br>" ..
					"Building: <b>%s</b><br>" ..
					"Room: <b>%s</b><br>" ..
					"Floor: <b>%s</b><br><br>" ..
					"Your key card has been activated. Use the elevator in the lobby to reach your floor.<br><br>" ..
					"<b>Rent: $2,000/week</b> — charged automatically from your bank account.<br><br>" ..
					"Welcome home.",
					apt.buildingLabel or apt.buildingName or apt.name,
					apt.roomLabel or aptId,
					apt.floor or "Unknown"
				)
			)
		end

		cb({
			success = true,
			apartmentId = aptId,
			roomLabel = apt.roomLabel or aptId,
			buildingName = apt.buildingLabel or apt.buildingName or apt.name,
			floor = apt.floor or "Unknown",
		})
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:GetMyRoom", function(source, data, cb)
		local char = GetChar(source)
		if not char then
			cb({ success = false, message = "Character not found" })
			return
		end

		local aptId = GetCharacterApartment(char:GetData("SID")) or tonumber(char:GetData("Apartment"))
		local apt = aptId and _aptData[aptId] or nil
		if not apt then
			cb({ success = false, message = "You don't have an apartment assigned" })
			return
		end

		cb({
			success = true,
			buildingName = apt.buildingLabel or apt.buildingName or apt.name,
			roomLabel = apt.roomLabel or aptId,
			floor = apt.floor or "Unknown",
		})
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:GetFloorApartments", function(source, data, cb)
		local floorApartments = {}
		if not data or not data.buildingName or data.floor == nil then
			cb(floorApartments)
			return
		end

		for _, apt in ipairs(_aptData) do
			if apt.buildingName == data.buildingName and apt.floor == data.floor then
				table.insert(floorApartments, {
					aptId = apt.id,
					unit = GetApartmentOwner(apt.id),
					roomLabel = apt.roomLabel or apt.id,
				})
			end
		end

		cb(floorApartments)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:StartRaid", function(source, data, cb)
		cb(exports[RESOURCE]:StartRaid(source, data.apartmentId))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:GetAvailableBuildings", function(_, _, cb)
		cb(GetAvailableApartmentsByBuilding())
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:SelectBuilding", function(source, data, cb)
		local char = GetChar(source)
		if not char then
			cb({ success = false, message = "Character not found" })
			return
		end

		local sid = char:GetData("SID")
		if GetCharacterApartment(sid) or (tonumber(char:GetData("Apartment")) or 0) > 0 then
			cb({ success = false, message = "You already have an apartment" })
			return
		end

		local aptId = GetRandomAvailableApartmentInBuilding(data.buildingName)
		if not aptId then
			cb({ success = false, message = "No rooms available in that building. Please choose another." })
			return
		end

		if not AssignApartmentToCharacter(aptId, char:GetData("ID") or sid, sid) then
			cb({ success = false, message = "Assignment failed, please try again" })
			return
		end

		char:SetData("Apartment", aptId)
		local apt = _aptData[aptId]

		exports["pulsar-phone"]:EmailSend(
			source,
			"apartments@nexus.gov",
			os.time(),
			"Welcome to Your Apartment",
			string.format(
				"Welcome to <b>%s</b>!<br><br>" ..
				"You have been assigned <b>Room %s</b> on Floor <b>%s</b>.<br><br>" ..
				"Take the elevator in the lobby to reach your floor. " ..
				"Your door is locked to your key card only.<br><br>" ..
				"<b>Rent: $2,000/week</b> — charged automatically from your bank account.<br><br>" ..
				"Welcome home.",
				apt.buildingLabel or apt.buildingName,
				apt.roomLabel or aptId,
				apt.floor or "?"
			)
		)

		cb({
			success = true,
			apartmentId = aptId,
			roomLabel = apt.roomLabel or aptId,
			buildingName = apt.buildingLabel or apt.buildingName,
			floor = apt.floor or "?",
		})
	end)
end
