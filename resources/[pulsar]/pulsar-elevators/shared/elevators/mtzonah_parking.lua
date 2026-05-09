local hospitalRoofRestriction = {
	{ type = "job", job = "police", workplace = false, level = 0, jobPermission = false, reqDuty = true },
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

local hospitalLocking = {
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

-- Mt Zonah Parking Elevator
local mtZonahParkingElevator = {
	name = "Mt Zonah - Elevator",
	canLock = hospitalLocking,
	floors = {
		[-1] = {
			name = "Underground Parking",
			coords = vector4(-419.076, -344.817, 24.231, 110.590),
			zone = {
				center = vector3(-420.32, -345.16, 24.23),
				length = 0.8,
				width = 2.4,
				heading = 290,
				minZ = 23.23,
				maxZ = 25.63,
			},
		},
		[1] = {
			name = "Ground Floor - Emergency Department",
			coords = vector4(-436.105, -359.731, 34.950, 352.303),
			zone = {
				center = vector3(-435.89, -358.23, 34.91),
				length = 0.8,
				width = 2.4,
				heading = 352,
				minZ = 33.91,
				maxZ = 36.31,
			},
		},
		[13] = {
			defaultLocked = true,
			name = "Roof - Helipad",
			coords = vector4(-449.041, -334.642, 78.301, 264.699),
			bypassLock = hospitalRoofRestriction,
			zone = {
				center = vector3(-447.73, -336.86, 78.32),
				length = 6.6,
				width = 0.8,
				heading = 352,
				minZ = 77.32,
				maxZ = 79.72,
			},
		},
	},
}

addElevatorsToConfig({mtZonahParkingElevator})