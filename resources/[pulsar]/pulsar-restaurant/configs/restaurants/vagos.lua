table.insert(Config.Restaurants, {
	Name = "Vagos Clubhouse Bar",
	Job = "vagos",
	IgnoreDuty = true,
	Pickups = {
		{
			id = "vagos-clubhouse-pickup-1",
			coords = vector3(336.4, -1988.5, 24.21),
			width = 1.4,
			length = 0.8,
			options = {
				heading = 321,
				--debugPoly=true,
				minZ = 24.21,
				maxZ = 25.01,
			},
			data = {
				business = "vagos",
			},
		},
	},
	Warmers = false,
})
