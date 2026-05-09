-- Triad Records Elevator 1 (Right)
local triadElevator1 = {
	name = "Triad Records - Elevator 1",
	canLock = {
		{ type = "job", job = "triad", workplace = false, level = 0, jobPermission = false, reqDuty = false },
	},
	floors = {
		[-1] = {
			defaultLocked = true,
			name = "Basement",
			coords = vector4(-817.305, -709.485, 23.781, 90.442),
			zone = {
				center = vector3(-817.85, -709.53, 23.78),
				length = 3.0,
				width = 3.8,
				heading = 0,
				--debugPoly=true,
				minZ = 22.78,
				maxZ = 25.58,
			},
		},
		[1] = {
			name = "Ground Floor",
			coords = vector4(-817.609, -709.467, 28.062, 90.153),
			zone = {
				center = vector3(-817.84, -709.51, 28.06),
				length = 3.0,
				width = 3.8,
				heading = 0,
				--debugPoly=true,
				minZ = 27.06,
				maxZ = 29.86,
			},
		},
		[2] = {
			name = "Floor 2",
			coords = vector4(-817.434, -709.519, 32.343, 85.856),
			zone = {
				center = vector3(-817.84, -709.5, 32.34),
				length = 3.0,
				width = 3.8,
				heading = 0,
				--debugPoly=true,
				minZ = 31.34,
				maxZ = 34.14,
			},
		},
	},
}

addElevatorsToConfig({triadElevator1})