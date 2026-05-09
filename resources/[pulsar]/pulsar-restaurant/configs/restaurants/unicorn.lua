table.insert(Config.Restaurants, {
	Name = "Vanilla Unicorn",
	Job = "unicorn",
	Pickups = {
		{
			id = "unicorn-pickup-1",
			coords = vector3(129.3, -1285.58, 29.27),
			width = 0.8,
			length = 1.0,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 28.87,
				maxZ = 29.87,
			},
			data = {
				business = "unicorn",
			},
		},
		{
			id = "unicorn-pickup-2",
			coords = vector3(127.97, -1283.19, 29.27),
			width = 0.8,
			length = 1.0,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 28.87,
				maxZ = 29.87,
			},
			data = {
				business = "unicorn",
			},
		},
		{
			id = "unicorn-pickup-3",
			coords = vector3(127.0, -1281.7, 29.27),
			width = 0.8,
			length = 1.0,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 28.87,
				maxZ = 29.87,
			},
			data = {
				business = "unicorn",
			},
		},
	},
	Fridges = {
		{
			id = "unicorn-fridge-1",
			coords = vector3(130.02, -1280.64, 29.27),
			width = 1.2,
			length = 1.0,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 28.27,
				maxZ = 29.47,
			},
			restrict = {
				jobs = { "unicorn" },
			},
			data = {
				business = "unicorn",
			},
		},
		{
			id = "unicorn-fridge-2",
			coords = vector3(132.77, -1285.38, 29.27),
			width = 1.2,
			length = 1.0,
			options = {
				heading = 30,
				--debugPoly=true,
				minZ = 28.27,
				maxZ = 29.47,
			},
			restrict = {
				jobs = { "unicorn" },
			},
			data = {
				business = "unicorn",
			},
		},
	},
})
