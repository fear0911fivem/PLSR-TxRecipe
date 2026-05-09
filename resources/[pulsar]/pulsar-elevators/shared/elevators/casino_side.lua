-- Diamond Casino Side Elevator
local casinoSideElevator = {
	name = "Diamond Casino Side Elevator",
	canLock = {
		{
			type = "job",
			job = "casino",
			workplace = false,
			level = 0,
			jobPermission = "CASINO_LOCK_ELEVATOR",
			reqDuty = false,
		},
	},
	floors = {
		[-5] = {
			defaultLocked = true,
			name = "Nightclub Entrance",
			coords = vector4(994.411, 84.381, -74.406, 54.885),
			zone = {
				center = vector3(994.78, 84.08, -74.41),
				length = 2.2,
				width = 1.0,
				heading = 324,
				--debugPoly=true,
				minZ = -75.41,
				maxZ = -72.81,
			},
		},
		[0] = {
			name = "Side Door",
			coords = vector4(987.570, 79.664, 80.991, 327.664),
			zone = {
				center = vector3(987.24, 79.25, 80.99),
				length = 2.8,
				width = 1,
				heading = 239,
				--debugPoly=true,
				minZ = 79.99,
				maxZ = 82.59,
			},
		},
		[2] = {
			defaultLocked = true,
			name = "Management Office",
			coords = vector4(994.114, 56.084, 75.060, 235.408),
			zone = {
				center = vector3(993.75, 56.22, 75.06),
				length = 2.4,
				width = 0.6,
				heading = 148,
				--debugPoly=true,
				minZ = 74.06,
				maxZ = 76.46,
			},
		},
		[9] = {
			defaultLocked = true,
			name = "Roof - Main Terrace",
			coords = vector4(936.930, 14.168, 112.554, 64.480),
			zone = {
				center = vector3(937.21, 13.81, 112.55),
				length = 2.4,
				width = 0.6,
				heading = 328,
				--debugPoly=true,
				minZ = 111.55,
				maxZ = 113.95,
			},
		},
		[11] = {
			defaultLocked = true,
			name = "Roof - Helipad",
			coords = vector4(959.669, 32.471, 120.226, 142.133),
			zone = {
				center = vector3(959.82, 32.67, 120.23),
				length = 2.4,
				width = 0.6,
				heading = 238,
				--debugPoly=true,
				minZ = 119.23,
				maxZ = 121.63,
			},
		},
	},
}

addElevatorsToConfig({casinoSideElevator})