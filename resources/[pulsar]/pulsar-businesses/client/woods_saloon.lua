AddEventHandler("Businesses:Client:Startup", function()
	exports.ox_target:addBoxZone({
		id = "woods-saloon-clockinoff",
		coords = vector3(-307.4, 6268.38, 31.53),
		size = vector3(1.0, 1.0, 0.8),
		rotation = 314,
		debug = false,
		minZ = 31.48,
		maxZ = 32.28,
		options = GetBusinessClockInMenu("woods_saloon")
	})

	exports.ox_target:addBoxZone({
		id = "woods-saloon-clockinoff2",
		coords = vector3(-302.77, 6272.48, 31.53),
		size = vector3(1.0, 1.0, 0.8),
		rotation = 313,
		debug = false,
		minZ = 31.48,
		maxZ = 32.28,
		options = GetBusinessClockInMenu("woods_saloon")
	})
end)
