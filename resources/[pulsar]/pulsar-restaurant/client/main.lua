AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		Startup()
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

function Startup()
	exports.ox_target:addBoxZone({
		id = "burgershot-clockinoff",
		coords = vector3(-1177.08, -896.98, 13.79),
		size = vector3(0.4, 0.4, 2.0),
		rotation = 35,
		debug = false,
		minZ = 13.39,
		maxZ = 14.59,
		options = GetBusinessClockInMenu("burgershot")
	})

	exports.ox_target:addBoxZone({
		id = "rustybrowns-clockinoff",
		coords = vector3(164.9, 247.96, 107.05),
		size = vector3(1, 0.8, 2.0),
		rotation = 340,
		debug = false,
		minZ = 103.65,
		maxZ = 107.65,
		options = GetBusinessClockInMenu("rustybrowns")
	})

	exports.ox_target:addBoxZone({
		id = "lasttrain-clockinoff",
		coords = vector3(-384.8, 268.03, 86.46),
		size = vector3(1, 0.8, 2.0),
		rotation = 305,
		debug = false,
		minZ = 86.41,
		maxZ = 87.41,
		options = GetBusinessClockInMenuWithTV("lasttrain")
	})

	exports.ox_target:addBoxZone({
		id = "triad-clockinoff",
		coords = vector3(-830.56, -730.64, 28.06),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 27.06,
		maxZ = 28.66,
		options = GetBusinessClockInMenu("triad")
	})

	exports.ox_target:addBoxZone({
		id = "uwu-clockinoff",
		coords = vector3(-593.97, -1053.52, 22.34),
		size = vector3(0.6, 2.8, 2.0),
		rotation = 90,
		debug = false,
		minZ = 21.94,
		maxZ = 23.94,
		options = GetBusinessClockInMenu("uwu")
	})

	exports.ox_target:addBoxZone({
		id = "pizza_this-clockinoff",
		coords = vector3(804.4, -760.87, 31.27),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 30.27,
		maxZ = 32.07,
		options = GetBusinessClockInMenu("pizzathis")
	})

	exports.ox_target:addBoxZone({
		id = "avast_arcade-clockinoff",
		coords = vector3(-1659.51, -1061.26, 12.16),
		size = vector3(1, 1, 2.0),
		rotation = 46,
		debug = false,
		minZ = 11.56,
		maxZ = 13.36,
		options = GetBusinessClockInMenu("avast_arcade")
	})

	exports.ox_target:addBoxZone({
		id = "bballs-clockinoff",
		coords = vector3(755.73, -775.51, 26.34),
		size = vector3(1.0, 0.6, 2.0),
		rotation = 0,
		debug = false,
		minZ = 26.34,
		maxZ = 27.14,
		options = {
			{
				icon = "clipboard-check",
				label = "Clock In",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockIn", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqOffDuty = true,
			},
			{
				icon = "clipboard",
				label = "Clock Out",
				onSelect = function()
					TriggerEvent("Restaurant:Client:ClockOut", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "tv",
				label = "Set TV Link",
				onSelect = function()
					TriggerEvent("Bowling:Client:SetTV")
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "bowling-pins",
				label = "Reset All Lanes",
				onSelect = function()
					TriggerEvent("Bowling:Client:ResetAll", { job = "bowling" })
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
			{
				icon = "bowling-pins",
				label = "Clear Pins",
				onSelect = function()
					TriggerEvent("Bowling:Client:ClearPins")
				end,
				groups = { "bowling" },
				reqDuty = true,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "beanmachine-clockinoff",
		coords = vector3(126.86, -1035.47, 29.28),
		size = vector3(2.0, 0.4, 2.0),
		rotation = 340,
		debug = false,
		minZ = 28.48,
		maxZ = 31.48,
		options = GetBusinessClockInMenu("beanmachine")
	})

	exports.ox_target:addBoxZone({
		id = "vu-clockinoff",
		coords = vector3(133.06, -1286.17, 29.27),
		size = vector3(0.9, 0.7, 2.0),
		rotation = 30,
		debug = false,
		minZ = 29.07,
		maxZ = 30.07,
		options = GetBusinessClockInMenu("unicorn")
	})

	exports.ox_target:addBoxZone({
		id = "vu-clockinoff2",
		coords = vector3(102.0, -1299.66, 28.77),
		size = vector3(1, 1, 2.0),
		rotation = 30,
		debug = false,
		minZ = 28.37,
		maxZ = 30.77,
		options = GetBusinessClockInMenu("unicorn")
	})

	exports.ox_target:addBoxZone({
		id = "bahama-clockinoff",
		coords = vector3(-1398.88, -600.11, 30.32),
		size = vector3(0.6, 0.6, 2.0),
		rotation = 11,
		debug = false,
		minZ = 29.32,
		maxZ = 31.32,
		options = GetBusinessClockInMenu("bahama")
	})

	exports.ox_target:addBoxZone({
		id = "bahama-clockinoff2",
		coords = vector3(-1402.88, -602.59, 30.32),
		size = vector3(0.6, 0.4, 2.0),
		rotation = 145.994,
		debug = false,
		minZ = 29.32,
		maxZ = 31.32,
		options = GetBusinessClockInMenu("bahama")
	})

	exports.ox_target:addBoxZone({
		id = "bakery-clockinoff",
		coords = vector3(-1264.53, -291.36, 37.39),
		size = vector3(0.6, 1, 2.0),
		rotation = 20,
		debug = false,
		minZ = 36.39,
		maxZ = 37.99,
		options = GetBusinessClockInMenu("bakery")
	})

	exports.ox_target:addBoxZone({
		id = "noodle-clockinoff",
		coords = vector3(-1185.77, -1149.25, 7.67),
		size = vector3(0.8, 2, 2.0),
		rotation = 15,
		debug = false,
		minZ = 6.67,
		maxZ = 8.87,
		options = GetBusinessClockInMenu("noodle")
	})

	exports.ox_target:addBoxZone({
		id = "tequila-clockinoff",
		coords = vector3(-562.95, 283.25, 82.18),
		size = vector3(1, 1, 2.0),
		rotation = 0,
		debug = false,
		minZ = 81.58,
		maxZ = 83.38,
		options = GetBusinessClockInMenu("tequila")
	})

	exports.ox_target:addBoxZone({
		id = "rockford_records-clockinoff",
		coords = vector3(-1004.61, -269.61, 39.04),
		size = vector3(1.2, 2.2, 2.0),
		rotation = 20,
		debug = false,
		minZ = 38.44,
		maxZ = 40.24,
		options = GetBusinessClockInMenu("rockford_records")
	})

	exports.ox_target:addBoxZone({
		id = "rockford_records-clockinoff2",
		coords = vector3(-990.76, -279.55, 38.2),
		size = vector3(0.8, 3.0, 2.0),
		rotation = 25,
		debug = false,
		minZ = 37.6,
		maxZ = 39.4,
		options = GetBusinessClockInMenu("rockford_records")
	})

	exports.ox_target:addBoxZone({
		id = "prego-clockinoff",
		coords = vector3(-1122.19, -1456.06, 5.11),
		size = vector3(0.6, 1.6, 2.0),
		rotation = 35,
		debug = false,
		minZ = 4.71,
		maxZ = 6.71,
		options = GetBusinessClockInMenu("prego")
	})
end

RegisterNetEvent("Restaurant:Client:CreatePoly", function(pickups, warmersList, fridgesList, onSpawn)
	for k, v in ipairs(pickups) do
		local data = GlobalState[string.format("Restaurant:Pickup:%s", v)]
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
							TriggerEvent("Restaurant:Client:Pickup", data.data)
						end,
						distance = data.driveThru and 5.0 or 2.0,
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

	if warmersList then
		for k, v in ipairs(warmersList) do
			for _, warmerId in ipairs(v) do
				local data = GlobalState[string.format("Restaurant:Warmers:%s", warmerId)]
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
								icon = "oven",
								label = "Open Warmer",
								onSelect = function()
									TriggerEvent("Restaurant:Client:Pickup", data.data)
								end,
								groups = data.restrict and data.restrict.jobs or nil,
								reqDuty = true,
							},
						}
					})
				end
			end
		end
	end

	if fridgesList then
		for k, v in ipairs(fridgesList) do
			for _, fridgeId in ipairs(v) do
				local data = GlobalState[string.format("Restaurant:Fridges:%s", fridgeId)]
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
								icon = "refrigerator",
								label = "Open Fridge",
								onSelect = function()
									TriggerEvent("Restaurant:Client:Pickup", data.data)
								end,
								groups = data.restrict and data.restrict.jobs or nil,
								reqDuty = true,
							},
						}
					})
				end
			end
		end
	end
end)

AddEventHandler("Restaurant:Client:Pickup", function(data)
	if data.inventory then
		exports.ox_inventory:openInventory(data.inventory, data.inventoryId)
	end
end)

AddEventHandler("Restaurant:Client:ClockIn", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOn(data.job)
	end
end)

AddEventHandler("Restaurant:Client:ClockOut", function(data)
	if data and data.job then
		exports['pulsar-jobs']:DutyOff(data.job)
	end
end)