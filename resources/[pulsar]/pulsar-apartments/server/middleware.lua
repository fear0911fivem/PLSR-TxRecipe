local RESOURCE = GetCurrentResourceName()

function RegisterMiddleware()
	exports["pulsar-core"]:MiddlewareAdd("Characters:Creating", function(source, cData)
		return { { Apartment = 0 } }
	end)

	exports["pulsar-core"]:MiddlewareAdd("Characters:Created", function(_, _)
		-- Building selection happens on first CharacterLoaded instead of auto-assigning here
	end)

	exports["pulsar-core"]:MiddlewareAdd("Characters:GetSpawnPoints", function(source, charId, cData)
		local spawns = {}
		local apt = _aptData[tonumber(cData.Apartment) or 0]
		if apt then
			table.insert(spawns, {
				id = string.format("APT:%s:%s", apt.id, cData.SID),
				label = apt.name,
				location = apt.interior.wakeup,
				icon = "building",
				event = "Apartment:SpawnInside",
			})
		end
		return spawns
	end, 2)
end

AddEventHandler("Characters:Server:CharacterLoaded", function(source, cData)
	if not cData or not cData.SID then return end

	SetTimeout(5000, function()
		CheckRentDue(source, tonumber(cData.SID))
	end)

	local aptId = GetCharacterApartment(tonumber(cData.SID)) or tonumber(cData.Apartment)
	if not aptId or aptId == 0 then
		SetTimeout(3000, function()
			if GetPlayerPing(source) > 0 then
				TriggerClientEvent("Apartment:Client:SelectBuilding", source)
			end
		end)
	end
end)

AddEventHandler("Characters:Server:CharacterDeleted", function(characterSID)
	local aptId = GetCharacterApartment(characterSID)
	if aptId then
		ReleaseApartmentAssignment(aptId, characterSID, false)
	end
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	exports[RESOURCE]:Exit(source)
end)
