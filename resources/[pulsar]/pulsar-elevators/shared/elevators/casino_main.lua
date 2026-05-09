-- Diamond Casino Main Elevator
local casinoMainElevator = {
	name = "Diamond Casino Main Elevator",
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
			name = "Nightclub Staff Only",
			coords = vector4(958.203, 49.725, -75.205, 243.310),
			zone = {
				center = vector3(957.76, 50.05, -75.21),
				length = 2.8,
				width = 1.0,
				heading = 144,
				--debugPoly=true,
				minZ = -76.21,
				maxZ = -73.61,
			},
		},
		[0] = {
			defaultLocked = true,
			name = "Rear Entrance",
			coords = vector4(976.777, 16.366, 80.990, 238.062),
			zone = {
				center = vector3(976.19, 17.3, 80.99),
				length = 2.4,
				width = 2.0,
				heading = 328,
				--debugPoly=true,
				minZ = 79.99,
				maxZ = 82.39,
			},
		},
		[1] = {
			name = "Main Floor",
			coords = vector4(960.210, 43.188, 71.701, 278.518),
			zone = {
				center = vector3(959.87, 43.14, 71.7),
				length = 2.4,
				width = 0.4,
				heading = 12,
				--debugPoly=true,
				minZ = 70.7,
				maxZ = 73.1,
			},
		},
		[8] = {
			defaultLocked = true,
			name = "Roof - Rear",
			coords = vector4(953.516, 4.249, 111.259, 240.528),
			zone = {
				center = vector3(953.06, 4.53, 111.26),
				length = 2.8,
				width = 1.0,
				heading = 145,
				--debugPoly=true,
				minZ = 110.26,
				maxZ = 112.86,
			},
		},
		[9] = {
			defaultLocked = true,
			name = "Roof - Main Terrace",
			coords = vector4(964.800, 58.576, 112.553, 60.625),
			zone = {
				center = vector3(965.14, 58.39, 112.55),
				length = 2.4,
				width = 0.6,
				heading = 328,
				--debugPoly=true,
				minZ = 111.55,
				maxZ = 113.95,
			},
		},
		[10] = {
			defaultLocked = true,
			name = "Penthouse Suite",
			coords = vector4(980.747, 56.650, 116.164, 61.786),
			zone = {
				center = vector3(980.99, 56.39, 116.16),
				length = 2.4,
				width = 0.6,
				heading = 328,
				--debugPoly=true,
				minZ = 115.16,
				maxZ = 117.56,
			},
		},
	},
}

addElevatorsToConfig({casinoMainElevator})