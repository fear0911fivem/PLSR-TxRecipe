local hospitalLocking = {
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

-- Mt Zonah Pharmacy Elevator 3
local mtZonahPharmacyElevator3 = {
	name = "Mt Zonah - Elevator",
	canLock = hospitalLocking,
	floors = {
		[2] = {
			name = "2nd Floor - Pharmacy",
			coords = vector4(-493.556, -327.225, 42.307, 168.865),
			zone = {
				center = vector3(-493.57, -328.62, 42.32),
				length = 0.8,
				width = 2.4,
				heading = 351,
				minZ = 41.32,
				maxZ = 43.72,
			},
		},
		[11] = {
			name = "Intensive Care Unit",
			coords = vector4(-493.476, -327.028, 69.505, 177.761),
			zone = {
				center = vector3(-493.64, -328.65, 69.52),
				length = 2.4,
				width = 0.8,
				heading = 261,
				minZ = 68.52,
				maxZ = 70.72,
			},
		},
	},
}

addElevatorsToConfig({mtZonahPharmacyElevator3})