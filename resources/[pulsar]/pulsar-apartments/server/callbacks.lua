function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Apartment:Validate", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		local isMyApartment = pState.inApartment and pState.inApartment.id == char:GetData("SID")

		if data.id then
			if data.type == "wardrobe" and isMyApartment then
				cb(true)
			elseif data.type == "logout" and isMyApartment then
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:SpawnInside", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		cb(exports['pulsar-apartments']:Enter(source, char:GetData("Apartment"), -1, true))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Enter", function(source, data, cb)
		cb(exports['pulsar-apartments']:Enter(source, data.tier, data.id))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Exit", function(source, data, cb)
		cb(exports['pulsar-apartments']:Exit(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:GetVisitRequests", function(source, data, cb)
		cb(exports['pulsar-apartments']:RequestsGet(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Apartment:Visit", function(source, data, cb)
		cb(exports['pulsar-apartments']:Enter(source, data.tier, data.id))
	end)
end
