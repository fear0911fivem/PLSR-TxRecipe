table.insert(Config.Restaurants, {
	Name = "The Last Train",
	Job = "lasttrain",
	Pickups = {
		{
			id = "lasttrain-pickup-1",
			coords = vector3(-380.74, 266.21, 86.46),
			width = 1.8,
			length = 1.4,
			options = {
				heading = 305,
				--debugPoly = true,
				minZ = 86.46,
				maxZ = 87.26,
			},
			data = {
				business = "lasttrain",
			},
		},
	},
	Warmers = {
		{
			id = "lasttrain-warmer-1",
			coords = vector3(-379.15, 267.83, 86.46),
			width = 2.4,
			length = 0.8,
			options = {
				heading = 305,
				--debugPoly = true,
				minZ = 85.41,
				maxZ = 87.01,
			},
			restrict = {
				jobs = { "lasttrain" },
			},
			data = {
				business = "lasttrain",
			},
		},
	},
})
