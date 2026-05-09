table.insert(Config.Businesses, {
	Job = "jewel",
	Name = "The Jeweled Dragon",
	Pickups = {
		{
			id = "jewel-pickup-1",
			coords = vector3(-712.705, -895.634, 23.795),
			width = 1.0,
			length = 2.0,
			options = {
				heading = 90,
				--debugPoly=true,
				minZ = 22.795,
				maxZ = 24.795,
			},
			data = {
				business = "jewel",
			},
		},
		{
			id = "jewel-pickup-2",
			coords = vector3(-705.103, -895.943, 23.795),
			width = 1.0,
			length = 2.0,
			options = {
				heading = 270.0,
				--debugPoly=true,
				minZ = 22.795,
				maxZ = 24.795,
			},
			data = {
				business = "jewel",
			},
		},
	},
})
