local hospitalLocking = {
	{ type = "job", job = "ems", workplace = false, level = 0, jobPermission = false, reqDuty = true },
}

-- Mt Zonah Pharmacy Elevator 1
local mtZonahPharmacyElevator1 = {
	name = "Mt Zonah - Elevator",
	canLock = hospitalLocking,
	floors = {
		[2] = {
			name = "2nd Floor - Pharmacy",
			coords = vector4(-487.534, -327.838, 42.308, 167.233),
			zone = {
				center = vector3(-487.75, -329.51, 42.32),
				length = 0.8,
				width = 2.4,
				heading = 350,
				minZ = 41.32,
				maxZ = 43.72,
			},
		},
		[11] = {
			name = "Intensive Care Unit",
			coords = vector4(-487.595, -328.015, 69.505, 174.213),
			zone = {
				center = vector3(-487.7, -329.48, 69.5),
				length = 0.8,
				width = 2.4,
				heading = 351,
				minZ = 68.5,
				maxZ = 70.9,
			},
		},
	},
}

addElevatorsToConfig({mtZonahPharmacyElevator1})