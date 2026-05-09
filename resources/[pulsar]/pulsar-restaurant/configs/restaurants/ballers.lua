table.insert(Config.Restaurants, {
	Name = "Ballers Clubhouse Bar",
	Job = "ballers",
	IgnoreDuty = true,
	Pickups = {
		{
			id = "ballers-clubhouse-pickup-1",
			coords = vector3(-3.31, -1827.16, 29.15),
			width = 1.6,
			length = 1.0,
			options = {
				heading = 320,
				--debugPoly=true,
				minZ = 25.95,
				maxZ = 29.95,
			},
			data = {
				business = "ballers",
			},
		},
	},
	Warmers = false,
})
