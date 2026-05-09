AddEventHandler("Businesses:Client:Startup", function()
	exports.ox_target:addBoxZone({
		id = "lsfc-clockinoff-1",
		coords = vector3(1617.97, 4832.24, 33.14),
		size = vector3(1.6, 0.8, 1.2),
		rotation = 10.0,
		debug = false,
		minZ = 32.14,
		maxZ = 33.34,
		options = {
			{
				icon = "fas fa-clipboard-check",
				label = "Clock In",
				event = "Restaurant:Client:ClockIn",
				groups = { "lsfc" },
				reqOffDuty = true,
			},
			{
				icon = "fas fa-clipboard",
				label = "Clock Out",
				event = "Restaurant:Client:ClockOut",
				groups = { "lsfc" },
				reqDuty = true,
			},
		}
	})
end)
