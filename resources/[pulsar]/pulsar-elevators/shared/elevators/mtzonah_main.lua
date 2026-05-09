local hospitalRoofRestriction = {
	{ type = "job", job = "police", workplace = false, level = 0, jobPermission = false, reqDuty = true },
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

local hospitalLocking = {
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

-- Mt Zonah Main Elevator
local mtZonahMainElevator = {
	name = "Mt Zonah - Elevator",
	canLock = hospitalLocking,
	floors = {
		[-5] = {
			defaultLocked = true,
			name = "Basement - Operations & Laboratory",
			coords = vector4(-452.626, -288.444, -130.841, 117.326),
			zone = {
				center = vector3(-453.9, -289.04, -130.88),
				length = 2.4,
				width = 0.8,
				heading = 22,
				minZ = -131.88,
				maxZ = -129.48,
			},
		},
		[-1] = {
			name = "Underground Parking",
			coords = vector4(-495.383, -372.737, 24.231, 288.445),
			zone = {
				center = vector3(-494.06, -372.31, 24.23),
				length = 0.8,
				width = 2.4,
				heading = 290,
				minZ = 23.23,
				maxZ = 25.63,
			},
		},
		[1] = {
			name = "Ground Floor - Emergency Department",
			coords = vector4(-452.381, -288.393, 34.950, 117.890),
			zone = {
				center = vector3(-453.9, -289.05, 34.91),
				length = 2.4,
				width = 0.8,
				heading = 22,
				minZ = 33.91,
				maxZ = 36.31,
			},
		},
		[11] = {
			name = "Intensive Care Unit",
			coords = vector4(-452.779, -288.538, 69.539, 115.790),
			zone = {
				center = vector3(-453.97, -289.07, 69.54),
				length = 2.4,
				width = 0.8,
				heading = 22,
				minZ = 68.54,
				maxZ = 70.94,
			},
		},
		[13] = {
			defaultLocked = true,
			name = "Roof - Helipad",
			coords = vector4(-439.719, -335.733, 78.301, 87.790),
			bypassLock = hospitalRoofRestriction,
			zone = {
				center = vector3(-441.42, -337.66, 78.32),
				length = 6.6,
				width = 0.8,
				heading = 352,
				minZ = 77.32,
				maxZ = 79.72,
			},
		},
	},
}

addElevatorsToConfig({mtZonahMainElevator})