RegisterServerEvent("Ped:EnterCreator", function()
	local routeId = exports["pulsar-core"]:RequestRouteId("ped:" .. source)
	exports["pulsar-core"]:AddPlayerToRoute(source, routeId)
end)

RegisterServerEvent("Ped:LeaveCreator", function()
	exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
end)
