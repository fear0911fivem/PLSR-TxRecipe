local hospitalLocking = {
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

-- Mt Zonah Pharmacy Elevator 2
local mtZonahPharmacyElevator2 = {
	name = "Mt Zonah - Elevator",
	canLock = hospitalLocking,
	floors = {
		[2] = {
			name = "2nd Floor - Pharmacy",
			coords = vector4(-487.534, -327.838, 42.308, 167.233),
			zone = {
				center = vector3(-490.8, -329.18, 69.52),
				length = 0.8,
				width = 2.4,
				heading = 351,
				minZ = 41.32,
				maxZ = 43.72,
			},
		},
		[11] = {
			name = "Intensive Care Unit",
			coords = vector4(-487.595, -328.015, 69.505, 174.213),
			zone = {
				center = vector3(-490.71, -329.08, 69.52),
				length = 2.4,
				width = 0.8,
				heading = 260,
				minZ = 68.52,
				maxZ = 70.72,
			},
		},
	},
}

addElevatorsToConfig({mtZonahPharmacyElevator2})