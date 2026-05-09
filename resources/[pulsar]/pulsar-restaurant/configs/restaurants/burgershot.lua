table.insert(Config.Restaurants, {
	Name = "Burger Shot",
	Job = "burgershot",
	Pickups = {
		{ -- Burger Shot
			id = "burgershot-pickup-1",
			coords = vector3(-1191.38, -896.1, 13.8),
			width = 0.6,
			length = 1,
			options = {
				heading = 34,
				--debugPoly=true,
				minZ = 12.8,
				maxZ = 14.2,
			},
			data = {
				business = "burgershot",
			},
		},
		{ -- Burger Shot
			id = "burgershot-pickup-2",
			coords = vector3(-1189.83, -895.03, 13.8),
			width = 0.6,
			length = 1,
			options = {
				heading = 34,
				--debugPoly=true,
				minZ = 12.8,
				maxZ = 14.2,
			},
			data = {
				business = "burgershot",
			},
		},
		{ -- Burger Shot
			id = "burgershot-pickup-3",
			coords = vector3(-1188.25, -893.98, 13.8),
			width = 0.6,
			length = 1.2,
			options = {
				heading = 34,
				--debugPoly=true,
				minZ = 12.8,
				maxZ = 14.2,
			},
			data = {
				business = "burgershot",
			},
		},
		{ -- Burger Shot
			id = "burgershot-pickup-4",
			driveThru = true,
			coords = vector3(-1194.52, -905.37, 13.8),
			width = 1.2,
			length = 2.2,
			options = {
				heading = 349,
				--debugPoly=true,
				minZ = 13.6,
				maxZ = 15.6,
			},
			data = {
				business = "burgershot",
			},
		},
	},
	Warmers = {
		{ -- Burger Shot
			id = "burgershot-warmer-1",
			coords = vector3(-1187.61, -896.94, 13.79),
			length = 0.8,
			width = 1.6,
			options = {
				heading = 306,
				--debugPoly=true,
				minZ = 13.79,
				maxZ = 15.19,
			},
			restrict = {
				jobs = { "burgershot" },
			},
			data = {
				business = "burgershot",
			},
		},
		{ -- Burger Shot
			id = "burgershot-warmer-2",
			coords = vector3(-1191.11, -903.78, 13.8),
			length = 1.6,
			width = 1,
			options = {
				heading = 305,
				--debugPoly=true,
				minZ = 13.95,
				maxZ = 15.15,
			},
			restrict = {
				jobs = { "burgershot" },
			},
			data = {
				business = "burgershot",
			},
		},
	},
	Fridges = {
		{
			id = "burgershot-fridge-1",
			coords = vector3(-1183.35, -900.94, 13.8),
			width = 2.6,
			length = 0.8,
			options = {
				heading = 304,
				--debugPoly=true,
				minZ = 12.8,
				maxZ = 15.2,
			},
			restrict = {
				jobs = { "burgershot" },
			},
			data = {
				business = "burgershot",
			},
		},
	},
})
