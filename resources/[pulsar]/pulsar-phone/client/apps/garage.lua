RegisterNUICallback("Garage:GetCars", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Garage:GetCars", data, cb)
end)

RegisterNUICallback("Garage:TrackVehicle", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Garage:TrackVehicle", data, function(coords)
		if coords then
			DeleteWaypoint()
			SetNewWaypoint(coords.x, coords.y)
			cb(true)
		else
			cb(false)
		end
	end)
end)
