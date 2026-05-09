AddEventHandler("Phone:Server:RegisterMiddleware", function()
	exports['pulsar-core']:MiddlewareAdd("Phone:Spawning", function(source, char)
		return {
			{
				type = "garages",
				data = exports['pulsar-vehicles']:GaragesGetAll(),
			},
		}
	end)
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Garage:GetCars", function(source, data, cb)
		local src = source
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		exports['pulsar-vehicles']:OwnedGetAll(nil, 0, char:GetData("SID"), cb)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Garage:TrackVehicle", function(source, data, cb)
		cb(exports['pulsar-vehicles']:OwnedTrack(data))
	end)
end)
