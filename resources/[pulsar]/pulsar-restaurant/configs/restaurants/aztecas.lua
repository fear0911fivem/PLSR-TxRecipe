table.insert(Config.Restaurants, {
	Name = "Aztecas Clubhouse Bar",
	Job = "aztecas",
	IgnoreDuty = true,
	Pickups = {
		{
			id = "aztecas-clubhouse-pickup-1",
			coords = vector3(494.08, -1532.34, 29.29),
			width = 1.0,
			length = 1.0,
			options = {
				heading = 320,
				--debugPoly=true,
				minZ = 29.09,
				maxZ = 30.09,
			},
			data = {
				business = "aztecas",
			},
		},
	},
	Warmers = false,
})
