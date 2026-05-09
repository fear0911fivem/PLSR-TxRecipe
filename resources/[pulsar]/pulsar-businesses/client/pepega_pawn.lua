local _sellers = {
	{
		coords = vector3(549.903, -3056.434, 5.169),
		heading = 94.784,
		model = `S_M_M_DockWork_01`,
	},
}

AddEventHandler("Businesses:Client:Startup", function()
	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("PepegaPawn%s", k), v.model, v.coords, v.heading, 25.0, {
			{
				icon = "fas fa-ring",
				text = "Sell Pawn Goods",
				event = "PepegaPawn:Client:Sell",
				groups = { "pepega_pawn" },
			},
		}, "sack-dollar")
	end
end)

AddEventHandler("PepegaPawn:Client:Sell", function(e, data)
	exports["pulsar-core"]:ServerCallback("PepegaPawn:Sell", {})
end)
