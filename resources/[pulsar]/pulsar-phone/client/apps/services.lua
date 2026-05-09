RegisterNUICallback("Services:GetServices", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Services:GetServices", data, function(servicesData)
		cb(servicesData)
	end)
end)

RegisterNUICallback("Services:SetGPS", function(data, cb)
	if data.location then
		DeleteWaypoint()
		SetNewWaypoint(data.location.x, data.location.y)
		exports["pulsar-hud"]:Notification("success", "GPS route set")
		cb("OK")
	else
		cb(false)
		exports["pulsar-hud"]:Notification("error", "Error setting waypoint.")
	end
end)
