RegisterNetEvent("Apartment:Server:LeavePoly", function()
	local src = source
	local target = _requestors[src]
	if target and _requests[target] then
		for i = #_requests[target], 1, -1 do
			if _requests[target][i].source == src then
				table.remove(_requests[target], i)
			end
		end
	end
	_requestors[src] = nil
end)

RegisterNetEvent("Apartment:Server:StartShowerParticle", function(showerHeadPos, aptId)
	TriggerClientEvent("Apartment:Client:StartShowerParticle", -1, source, showerHeadPos, aptId)
end)

RegisterNetEvent("Apartment:Server:StopShowerParticle", function()
	TriggerClientEvent("Apartment:Client:StopShowerParticle", -1, source)
end)

RegisterNetEvent("Apartment:Server:ElevatorFloorChanged", function(buildingName, floor)
	local src = source
	local char = exports["pulsar-characters"]:FetchCharacterSource(src)
	if not char or not buildingName or floor == nil then
		return
	end

	local floors = Config.HotelElevators and Config.HotelElevators[buildingName]
	local floorConfig = floors and floors[floor]
	if not floorConfig then
		return
	end

	if floorConfig.bucketReset then
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(src)
		exports["pulsar-pwnzor"]:TempPosIgnore(src)
		GlobalState[string.format("%s:Apartment", src)] = nil
		GlobalState[string.format("%s:", src)] = nil
		Player(src).state.inApartment = nil
		Player(src).state.tpLocation = nil
		TriggerClientEvent("Apartment:Client:ExitElevator", src)
		return
	end

	if not floorConfig.isApartmentFloor then
		return
	end

	local characterSID = char:GetData("SID")
	local aptId = GetCharacterApartment(characterSID) or tonumber(char:GetData("Apartment"))
	if not aptId or not _aptData[aptId] then
		return
	end

	local routeId = exports["pulsar-core"]:RequestRouteId(string.format("Apartment:Floor:%s:%s", buildingName, floor), false)

	local currentState = Player(src).state.inApartment
	local alreadyInApartment = currentState and currentState.type == aptId and currentState.id == characterSID

	if not alreadyInApartment then
		exports["pulsar-pwnzor"]:TempPosIgnore(src)
		exports["pulsar-core"]:AddPlayerToRoute(src, routeId)

		Player(src).state.inApartment = {
			type = aptId,
			id = characterSID,
		}

		local apartment = _aptData[aptId]
		Player(src).state.tpLocation = {
			x = apartment.coords.x,
			y = apartment.coords.y,
			z = apartment.coords.z,
		}

		GlobalState[string.format("%s:Apartment", src)] = characterSID
		GlobalState[string.format("%s:", src)] = characterSID
		TriggerClientEvent("Apartment:Client:InnerStuff", src, aptId, characterSID, false)
	end
end)

RegisterNetEvent("Apartment:Server:LogoutCleanup", function()
	local src = source
	exports[GetCurrentResourceName()]:Exit(src)
end)
