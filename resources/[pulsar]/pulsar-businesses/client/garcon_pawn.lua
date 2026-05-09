local _sellers = {
	{
		coords = vector3(182.720, 2790.476, 44.612),
		heading = 7.687,
		model = `S_M_M_DockWork_01`,
	},
}

AddEventHandler("Businesses:Client:Startup", function()
	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("GarconPawn%s", k), v.model, v.coords, v.heading, 25.0, {
			{
				icon = "fas fa-ring",
				text = "Sell Pawn Goods",
				event = "GarconPawn:Client:Sell",
				groups = { "garcon_pawn" },
			},
		}, "sack-dollar")
	end
end)

AddEventHandler("GarconPawn:Client:Sell", function(e, data)
	exports["pulsar-core"]:ServerCallback("GarconPawn:Sell", {})
end)
