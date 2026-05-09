table.insert(Config.Restaurants, {
	Name = "Casino",
	Job = "casino",
	Pickups = {
		{
			id = "casino-pickup-1",
			coords = vector3(976.83, 23.73, 71.46),
			width = 1.2,
			length = 1.2,
			options = {
				heading = 4,
				--debugPoly=true,
				minZ = 71.26,
				maxZ = 72.46,
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-pickup-2",
			coords = vector3(981.32, 21.82, 71.46),
			width = 1.2,
			length = 1.2,
			options = {
				heading = 314,
				--debugPoly=true,
				minZ = 71.26,
				maxZ = 72.46,
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-pickup-3",
			coords = vector3(980.92, 26.13, 71.46),
			width = 1.2,
			length = 1.2,
			options = {
				heading = 328,
				--debugPoly=true,
				minZ = 71.26,
				maxZ = 72.46,
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-pickup-4",
			coords = vector3(946.51, 16.47, 116.16),
			width = 1.2,
			length = 1.2,
			options = {
				heading = 328,
				--debugPoly=true,
				minZ = 115.96,
				maxZ = 117.16,
			},
			data = {
				business = "casino",
			},
		},
		-- nightclub
		{
			id = "casino-pickup-5",
			coords = vector3(984.24, 72.33, -76.01),
			width = 1.2,
			length = 1.4,
			options = {
				heading = 17,
				--debugPoly=true,
				minZ = -77.81,
				maxZ = -75.41,
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-pickup-6",
			coords = vector3(981.25, 73.27, -76.01),
			width = 1.2,
			length = 2.4,
			options = {
				heading = 324,
				--debugPoly=true,
				minZ = -77.81,
				maxZ = -75.41,
			},
			data = {
				business = "casino",
			},
		},

		{
			id = "casino-pickup-7",
			coords = vector3(978.59, 76.18, -76.01),
			width = 1.2,
			length = 1.2,
			options = {
				heading = 273,
				--debugPoly=true,
				minZ = -77.81,
				maxZ = -75.41,
			},
			data = {
				business = "casino",
			},
		},
	},
	Fridges = {
		{
			id = "casino-fridge-1",
			coords = vector3(948.9, 17.21, 116.16),
			width = 1.2,
			length = 2.2,
			options = {
				heading = 328,
				--debugPoly=true,
				minZ = 115.16,
				maxZ = 116.96,
			},
			restrict = {
				jobs = { "casino" },
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-fridge-2",
			coords = vector3(978.32, 21.99, 71.46),
			width = 1.2,
			length = 2.2,
			options = {
				heading = 328,
				--debugPoly=true,
				minZ = 70.46,
				maxZ = 72.26,
			},
			restrict = {
				jobs = { "casino" },
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-fridge-3",
			coords = vector3(1003.71, 56.35, 75.06),
			width = 1.2,
			length = 2.2,
			options = {
				heading = 238,
				--debugPoly=true,
				minZ = 74.06,
				maxZ = 75.86,
			},
			restrict = {
				jobs = { "casino" },
			},
			data = {
				business = "casino",
			},
		},
		{
			id = "casino-fridge-4",
			coords = vector3(984.03, 75.97, -76.01),
			width = 2.8,
			length = 0.6,
			options = {
				heading = 235,
				--debugPoly=true,
				minZ = -77.01,
				maxZ = -76.01,
			},
			restrict = {
				jobs = { "casino" },
			},
			data = {
				business = "casino",
			},
		},
	},
})
