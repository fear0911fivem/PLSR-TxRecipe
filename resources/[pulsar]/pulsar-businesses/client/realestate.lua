AddEventHandler('Businesses:Client:Startup', function()
	exports.ox_target:addBoxZone({
		id = "realestate-clockinoff",
		coords = vector3(-700.38, 268.23, 83.15),
		size = vector3(1.0, 2.2, 1.6),
		rotation = 25,
		debug = false,
		minZ = 82.15,
		maxZ = 83.75,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				event = "Restaurant:Client:ClockIn",
				groups = { "realestate" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				event = "Restaurant:Client:ClockOut",
				groups = { "realestate" },
				reqDuty = true,
			},
		}
	})
end)
