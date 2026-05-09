table.insert(Config.Restaurants, {
	Name = "Black Woods Saloon",
	Job = "woods_saloon",
	Pickups = {
		{
			id = "woods-saloon-pickup-1",
			coords = vector3(-302.18, 6270.04, 31.53),
			width = 1.2,
			length = 1.0,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 30.28,
				maxZ = 32.48,
			},
			data = {
				business = "woods_saloon",
			},
		},
		{
			id = "woods-saloon-pickup-2",
			coords = vector3(-304.37, 6268.08, 31.53),
			width = 1.2,
			length = 1.0,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 30.28,
				maxZ = 32.48,
			},
			data = {
				business = "woods_saloon",
			},
		},
		{
			id = "woods-saloon-pickup-3",
			coords = vector3(-305.99, 6266.54, 31.53),
			width = 1.2,
			length = 1.0,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 30.28,
				maxZ = 32.48,
			},
			data = {
				business = "woods_saloon",
			},
		},
	},
	Fridges = {
		{
			fridge = true,
			id = "woods-saloon-fridge-1",
			coords = vector3(-305.84, 6269.73, 31.53),
			width = 0.8,
			length = 2.2,
			options = {
				heading = 43,
				--debugPoly=true,
				minZ = 29.93,
				maxZ = 32.33,
			},
			restrict = {
				jobs = { "woods_saloon" },
			},
			data = {
				business = "woods_saloon",
			},
		},
	},
})
