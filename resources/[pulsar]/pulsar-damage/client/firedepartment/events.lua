local safdCheckin = {
	{
		coords = vector3(1188.29, -1468.48, 34.86),
		length = 1.2,
		width = 1.2,
		options = {
			heading = 128.0,
			debugPoly = false,
			minZ = 33.23,
			maxZ = 35.23,
		},
	},
	{
		coords = vector3(199.38, -1639.41, 29.80),
		length = 1.2,
		width = 1.2,
		options = {
			heading = 85.0,
			debugPoly = false,
			minZ = 28.23,
			maxZ = 30.23,
		},
	},
}

function SAFDInit()
	-- exports['pulsar-pedinteraction']:Add(
	-- 	"hospital-check-in",
	-- 	`u_f_m_miranda_02`,
	-- 	vector3(-437.484, -323.269, 33.911),
	-- 	162.630,
	-- 	25.0,
	-- 	hospitalCheckin,
	-- 	"notes-medical",
	-- 	"WORLD_HUMAN_CLIPBOARD"
	-- )

	for k, v in ipairs(safdCheckin) do
		exports.ox_target:addBoxZone({
			id = "safd-checkin-" .. k,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading,
			debug = v.options.debugPoly,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-clipboard-check",
					label = "Go On Duty",
					event = "EMS:Client:OnDuty",
					groups = { "ems" },
					reqOffDuty = true,
				},
				{
					icon = "fas fa-clipboard",
					label = "Go Off Duty",
					event = "EMS:Client:OffDuty",
					groups = { "ems" },
					reqDuty = true,
				},
			}
		})
	end
end

RegisterNetEvent("Characters:Client:Spawn", function()
	for k, v in ipairs(safdCheckin) do
		exports["pulsar-blips"]:Add("safd-office-" .. k, "Fire & Medical", v.coords, 648, 1, 0.8)
	end
end)
