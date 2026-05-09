RegisterNUICallback("Dyn8:SearchProperty", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Dyn8:Search", data, cb)
end)

RegisterNUICallback("Dyn8:MarkProperty", function(data, cb)
	local prop = GlobalState[string.format("Property:%s", data)]
	if prop ~= nil then
		ClearGpsPlayerWaypoint()
		SetNewWaypoint(prop.location.front.x, prop.location.front.y)
	else
		cb(false)
	end
	exports["pulsar-core"]:ServerCallback("Phone:Dyn8:Search", data, cb)
end)

RegisterNUICallback("Dyn8:SellProperty", function(data, cb)
	cb('OK')
	--exports["pulsar-core"]:ServerCallback("Phone:Dyn8:Sell", data, cb)
end)

RegisterNUICallback("Dyn8:CheckCredit", function(data, cb)
	cb('OK')
	--exports["pulsar-core"]:ServerCallback("Phone:Dyn8:CheckCredit", data, cb)
end)
