-- Triad Records Elevator 2 (Left)
local triadElevator2 = {
	name = "Triad Records - Elevator 2",
	canLock = {
		{ type = "job", job = "triad", workplace = false, level = 0, jobPermission = false, reqDuty = false },
	},
	floors = {
		[-1] = {
			defaultLocked = true,
			name = "Basement",
			coords = vector4(-818.091, -705.504, 23.777, 89.689),
			zone = {
				center = vector3(-817.77, -705.47, 23.78),
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
			coords = vector4(-817.671, -705.504, 28.062, 91.055),
			restricted = false,
			zone = {
				center = vector3(-817.86, -705.5, 28.06),
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
			coords = vector4(-817.668, -705.485, 32.343, 93.975),
			restricted = false,
			zone = {
				center = vector3(-817.81, -705.51, 32.34),
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

addElevatorsToConfig({triadElevator2})