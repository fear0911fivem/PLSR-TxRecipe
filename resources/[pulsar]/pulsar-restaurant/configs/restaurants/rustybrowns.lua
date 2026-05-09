table.insert(Config.Restaurants, {
	Name = "Rusty Browns",
	Job = "rustybrowns",
	Pickups = {
		{
			id = "rustybrowns-pickup-1",
			coords = vector3(153.85, 249.28, 107.05),
			width = 1.4,
			length = 1.2,
			options = {
				heading = 340,
				--debugPoly=true,
				minZ = 105.85,
				maxZ = 107.85,
			},
			data = {
				business = "rustybrowns",
			},
		},
		{
			id = "rustybrowns-pickup-2",
			coords = vector3(153.15, 247.51, 107.05),
			width = 1.8,
			length = 1.2,
			options = {
				heading = 340,
				--debugPoly=true,
				minZ = 105.85,
				maxZ = 107.85,
			},
			data = {
				business = "rustybrowns",
			},
		},
	},
	Warmers = {
		{
			id = "rustybrowns-warmer-1",
			coords = vector3(157.38, 249.11, 107.05),
			length = 0.6,
			width = 1.6,
			options = {
				heading = 340,
				--debugPoly=true,
				minZ = 104.65,
				maxZ = 108.65,
			},
			restrict = {
				jobs = { "rustybrowns" },
			},
			data = {
				business = "rustybrowns",
			},
		},
		{
			id = "rustybrowns-warmer-2",
			coords = vector3(156.79, 247.61, 107.05),
			width = 1.6,
			length = 0.6,
			options = {
				heading = 340,
				--debugPoly=true,
				minZ = 104.65,
				maxZ = 108.65,
			},
			restrict = {
				jobs = { "rustybrowns" },
			},
			data = {
				business = "rustybrowns",
			},
		},
	},
})
