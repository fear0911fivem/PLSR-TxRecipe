AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		TriggerEvent("Businesses:Client:Startup")
	end
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	--  self, id, name, coords, sprite, colour, scale, display, category, flashes
	--exports["pulsar-blips"]:Add("shopping-mall", "Shopping Mall", vector3(-555.491, -597.852, 34.682), 59, 50, 0.6)
	exports["pulsar-blips"]:Add("black_woods_saloon", "Black Woods Saloon", vector3(-305.136078, 6264.041016, 31.526928), 93, 31, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("redline-performance", "Mechanic: Redline Performance", vector3(-600.028, -929.695, 23.866), 483, 59, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("pizza_this", "Pizza This", vector3(793.905, -758.289, 26.779), 267, 52, 0.5, 2, 11)
	exports["pulsar-blips"]:Add("uwu_cafe", "UwU Cafe", vector3(-581.098, -1070.048, 22.330), 621, 34, 0.6, 2, 11)
	--exports["pulsar-blips"]:Add("arcade", "Business: Arcade", vector3(-1651.675, -1082.294, 13.156), 484, 58, 0.8, 2, 11)
	exports["pulsar-blips"]:Add("cloud9_drift", "Business: Cloud9 Drift", vector3(-27.3694, -2544.8574, 6.0120), 315, 77, 0.5, 2, 11)

	exports["pulsar-blips"]:Add("tuna", "Business: Tuner Shop", vector3(161.992, -3036.946, 6.683), 611, 83, 0.6, 2, 11)
	exports["pulsar-blips"]:Add("triad", "Triad Records", vector3(-832.578, -698.627, 27.280), 614, 76, 0.5, 2, 11)

	exports["pulsar-blips"]:Add("mba", "Maze Bank Arena", vector3(-284.307, -1920.541, 29.946), 675, 50, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("bballs", "Bobs Balls", vector3(756.944, -768.288, 26.337), 536, 23, 0.4, 2, 11)

	--exports["pulsar-blips"]:Add("cabco", "Business: Downtown Cab Co.", vector3(908.036, -160.553, 74.142), 198, 5, 0.4, 2, 11)

	--exports["pulsar-blips"]:Add("tirenutz", "Mechanic: Tire Nutz", vector3(-73.708, -1338.770, 29.257), 488, 62, 0.7, 2, 11)
	--exports["pulsar-blips"]:Add("atomic", "Mechanic: Atomic Mechanics", vector3(482.176, -1889.637, 26.095), 544, 33, 1.0, 2, 11)
	exports["pulsar-blips"]:Add("hayes", "Hayes Autos", vector3(-1418.532, -445.162, 35.910), 544, 63, 1.0, 2, 11)
	exports["pulsar-blips"]:Add("autoexotics", "Auto Exotics", vector3(539.754, -182.979, 54.487), 488, 68, 0.7, 2, 11)
	exports["pulsar-blips"]:Add("harmony", "Harmony Repairs", vector3(1176.567, 2657.295, 37.972), 542, 7, 0.5, 2, 11)

	exports["pulsar-blips"]:Add("bakery", "Bakery", vector3(-1255.273, -293.090, 37.383), 106, 31, 0.5, 2, 11)
	--exports["pulsar-blips"]:Add("noodle", "Noodle Exchange", vector3(-1194.746, -1161.401, 7.692), 414, 6, 0.5, 2, 11)
	exports["pulsar-blips"]:Add("burgershot", "Burger Shot", vector3(-1183.511, -884.722, 13.800), 106, 6, 0.5, 2, 11)

	exports["pulsar-blips"]:Add("rustybrowns", "Rusty Browns", vector3(148.068, 238.705, 106.983), 270, 8, 0.65, 2, 11)

	--exports["pulsar-blips"]:Add("lasttrain", "Last Train Diner", vector3(-361.137, 275.310, 86.422), 208, 6, 0.5, 2, 11)
	exports["pulsar-blips"]:Add("beanmachine", "Business: Bean Machine", vector3(116.985, -1039.424, 29.278), 536, 52, 0.5, 2, 11)

	exports["pulsar-blips"]:Add("tequila", "Tequi-la-la", vector3(-564.575, 276.170, 83.119), 93, 81, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("dyn8", "Dynasty 8 Real Estate", vector3(-708.271, 268.543, 83.147), 374, 52, 0.65, 2)

	exports["pulsar-blips"]:Add("unicorn", "Vanilla Unicorn", vector3(110.380, -1313.496, 29.210), 121, 48, 0.7, 2, 11)

	exports["pulsar-blips"]:Add("bahama", "Bahama Mamas", vector3(-1388.605, -586.612, 30.219), 93, 61, 0.7, 2, 11)

	exports["pulsar-blips"]:Add("smokeonwater", "Smoke on the Water", vector3(-1169.751, -1571.643, 4.667), 140, 52, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("digitalden", "Digital Den", vector3(1137.494, -470.840, 66.659), 355, 58, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("rockford_records", "Rockford Records", vector3(-1007.658, -267.795, 39.040), 614, 63, 0.5, 2, 11)

	--exports["pulsar-blips"]:Add("gruppe6", "Gruppe 6 Security", vector3(22.813, -123.661, 55.978), 487, 24, 0.8, 2, 11)

	exports["pulsar-blips"]:Add("pepega_pawn", "Pepega Pawn", vector3(-296.300, -106.232, 47.051), 605, 1, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("garcon_pawn", "Garcon Pawn", vector3(-231.868, 6235.155, 31.496), 605, 1, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("ottos_autos", "Ottos Autos", vector3(946.128, -988.302, 39.178), 483, 25, 0.8, 2, 11)

	--exports["pulsar-blips"]:Add("fightclub", "The Fightclub", vector3(1059.197, -2409.773, 29.928), 311, 8, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("jewel", "The Jeweled Dragon", vector3(-708.910, -886.714, 23.804), 674, 5, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("vangelico", "Vangelico Paleto", vector3(-384.467, 6041.473, 31.500), 617, 53, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("vangelico_grapeseed", "Vangelico Grapeseed", vector3(1655.029, 4883.049, 41.969), 617, 53, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("sagma", "San Andreas Gallery of Modern Art", vector3(-424.835, 21.379, 46.269), 674, 5, 0.6, 2, 11)

	exports["pulsar-blips"]:Add("bennys", "Benny's Mechanics", vector3(-211.4965, -1326.7563, 31.3005), 544, 63, 1.0, 2, 11)

	exports["pulsar-blips"]:Add("taco", "Taco Shop", vector3(8.572, -1609.225, 29.296), 52, 43, 0.6, 2, 11)

	--exports["pulsar-blips"]:Add("prego", "Cafe Prego", vector3(-1114.819, -1452.965, 5.147), 267, 6, 0.7, 2, 11)

	--exports["pulsar-blips"]:Add("white_law", "White & Associates", vector3(-1370.389, -502.949, 33.158), 457, 10, 0.7, 2, 11)

	exports["pulsar-blips"]:Add("paleto_tuners", "Paleto Tuners", vector3(160.253, 6386.286, 31.343), 544, 43, 1.0, 2, 11)

	exports["pulsar-blips"]:Add("dreamworks", "Dreamworks Mechanics", vector3(-739.396, -1514.290, 5.055), 524, 6, 0.7, 2, 11)
end)

RegisterNetEvent("Businesses:Client:CreatePoly", function(pickups, onSpawn)
	for k, v in ipairs(pickups) do
		local data = GlobalState[string.format("Businesses:Pickup:%s", v)]
		if data ~= nil then
			exports.ox_target:addBoxZone({
				id = data.id,
				coords = data.coords,
				size = vector3(data.width, data.length, 2.0),
				rotation = data.options.heading or 0,
				debug = false,
				minZ = data.options.minZ,
				maxZ = data.options.maxZ,
				options = {
					{
						icon = "fas fa-box-open",
						label = string.format("Pickup Order (#%s)", data.num),
						onSelect = function()
							TriggerEvent("Businesses:Client:Pickup", data.data)
						end,
					},
					{
						icon = "fas fa-money-check-dollar",
						label = "Set Contactless Payment",
						onSelect = function()
							TriggerEvent("Businesses:Client:CreateContactlessPayment", data)
						end,
						groups = { data.job },
						reqDuty = true,
						canInteract = function()
							return not GlobalState[string.format("PendingContactless:%s", data.id)]
						end,
					},
					{
						icon = "fas fa-money-check-dollar",
						label = "Clear Contactless Payment",
						onSelect = function()
							TriggerEvent("Businesses:Client:ClearContactlessPayment", data)
						end,
						groups = { data.job },
						reqDuty = true,
						canInteract = function()
							return GlobalState[string.format("PendingContactless:%s", data.id)]
						end,
					},
					{
						icon = "fas fa-money-check-dollar",
						label = "Pay Contactless Payment",
						onSelect = function()
							TriggerEvent("Businesses:Client:PayContactlessPayment", data)
						end,
						item = "phone",
						distance = data.driveThru and 5.0 or 2.0,
						canInteract = function()
							return GlobalState[string.format("PendingContactless:%s", data.id)] and
								GlobalState[string.format("PendingContactless:%s", data.id)] > 0
						end,
					},
				}
			})
		end
	end
end)

AddEventHandler("Businesses:Client:Pickup", function(data)
	if data.inventory then
		exports.ox_inventory:openInventory(data.inventory, data.inventoryId)
	end
end)
function GetBusinessClockInMenu(businessName)
	return {
		{
			icon = "fas fa-clipboard-check",
			label = "Clock In",
			onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = businessName })
			end,
			groups = { businessName },
			reqOffDuty = true,
		},
		{
			icon = "fas fa-clipboard",
			label = "Clock Out",
			onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = businessName })
			end,
			groups = { businessName },
			reqDuty = true,
		},
	}
end

function GetBusinessClockInMenuWithTV(businessName)
	return {
		{
			icon = "fas fa-clipboard-check",
			label = "Clock In",
			onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = businessName })
			end,
			groups = { businessName },
			reqOffDuty = true,
		},
		{
			icon = "fas fa-clipboard",
			label = "Clock Out",
			onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = businessName })
			end,
			groups = { businessName },
			reqDuty = true,
		},
		{
			icon = "fas fa-tv",
			label = "Set TV Link",
			onSelect = function()
					TriggerEvent("Billboards:Client:SetLink", { job = businessName })
			end,
			groups = { businessName },
			reqDuty = true,
		},
	}
end

AddEventHandler("Businesses:Client:Startup", function()
	exports.ox_target:addBoxZone({
		id = "digitalden-clockinoff",
		coords = vector3(384.17, -830.31, 29.3),
		size = vector3(1.2, 0.8, 1.6),
		rotation = 0,
		debug = false,
		minZ = 28.7,
		maxZ = 30.3,
		options = GetBusinessClockInMenu("digitalden")
	})

	exports.ox_target:addBoxZone({
		id = "securoserv-clockinoff",
		coords = vector3(19.99, -119.98, 56.22),
		size = vector3(2.0, 1.0, 2.2),
		rotation = 340,
		debug = false,
		minZ = 55.22,
		maxZ = 57.42,
		options = GetBusinessClockInMenu("securoserv")
	})

	exports.ox_target:addBoxZone({
		id = "pepega_pawn-clockinoff",
		coords = vector3(-328.13, -90.89, 47.05),
		size = vector3(2.6, 0.6, 2.2),
		rotation = 340,
		debug = false,
		minZ = 45.65,
		maxZ = 47.85,
		options = GetBusinessClockInMenu("pepega_pawn")
	})

	exports.ox_target:addBoxZone({
		id = "garcon_pawn-clockinoff",
		coords = vector3(-216.49, 6231.88, 31.79),
		size = vector3(1.8, 1.0, 4.0),
		rotation = 315,
		debug = false,
		minZ = 28.39,
		maxZ = 32.39,
		options = GetBusinessClockInMenu("garcon_pawn")
	})

	exports.ox_target:addBoxZone({
		id = "sagma-clockinoff",
		coords = vector3(-422.48, 31.83, 46.23),
		size = vector3(1.0, 1.0, 1.2),
		rotation = 8,
		debug = false,
		minZ = 46.03,
		maxZ = 47.23,
		options = GetBusinessClockInMenu("sagma")
	})

	exports.ox_target:addBoxZone({
		id = "sagma-clockinoff2",
		coords = vector3(-491.26, 31.8, 46.3),
		size = vector3(1.0, 1.0, 1.0),
		rotation = 355,
		debug = false,
		minZ = 46.1,
		maxZ = 47.1,
		options = GetBusinessClockInMenu("sagma")
	})

	exports.ox_target:addBoxZone({
		id = "jewel-clockinoff",
		coords = vector3(-708.553, -900.005, 23.819),
		size = vector3(0.5, 0.5, 1.0),
		rotation = 356,
		debug = false,
		minZ = 23.219,
		maxZ = 24.219,
		options = GetBusinessClockInMenu("jewel")
	})

	exports.ox_target:addBoxZone({
		id = "vangelico-clockinoff",
		coords = vector3(-382.69, 6046.2, 31.51),
		size = vector3(0.6, 0.4, 0.75),
		rotation = 45,
		debug = false,
		minZ = 31.16,
		maxZ = 31.91,
		options = GetBusinessClockInMenu("vangelico")
	})

	exports.ox_target:addBoxZone({
		id = "vangelico_grapeseed-clockinoff",
		coords = vector3(1651.47, 4880.55, 42.16),
		size = vector3(0.6, 0.4, 4.0),
		rotation = 8,
		debug = false,
		minZ = 38.56,
		maxZ = 42.56,
		options = GetBusinessClockInMenu("vangelico_grapeseed")
	})

	exports.ox_target:addBoxZone({
		id = "tuner-tvs",
		coords = vector3(125.35, -3014.88, 7.04),
		size = vector3(0.8, 2.0, 1.0),
		rotation = 0,
		debug = false,
		minZ = 6.64,
		maxZ = 7.64,
		options = {
			{
				icon = "fas fa-tv",
				label = "Set TV Link",
				onSelect = function()
						TriggerEvent("Billboards:Client:SetLink", { job = "tuna" })
				end,
				groups = { "tuna" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "paleto_tuners-clockinoff",
		coords = vector3(178.55, 6382.73, 31.27),
		size = vector3(2.0, 1.4, 1.8),
		rotation = 28,
		debug = false,
		minZ = 30.27,
		maxZ = 32.07,
		options = GetBusinessClockInMenu("paleto_tuners")
	})

	exports.ox_target:addBoxZone({
		id = "paleto_tuners-clockinoff2",
		coords = vector3(149.34, 6378.17, 31.27),
		size = vector3(1.4, 1.8, 1.6),
		rotation = 26,
		debug = false,
		minZ = 30.27,
		maxZ = 31.87,
		options = GetBusinessClockInMenuWithTV("paleto_tuners")
	})

	exports.ox_target:addBoxZone({
		id = "blackline-clockinoff",
		coords = vector3(946.64, -1744.41, 21.03),
		size = vector3(2.2, 2.2, 2.4),
		rotation = 0,
		debug = false,
		minZ = 20.03,
		maxZ = 22.43,
		options = GetBusinessClockInMenu("blackline")
	})
end)

AddEventHandler("Businesses:Client:ClockIn", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOn(data.job)
	end
end)

AddEventHandler("Businesses:Client:ClockOut", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOff(data.job)
	end
end)