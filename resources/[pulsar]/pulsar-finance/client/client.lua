local inBank = true

function TableLength(tbl)
	local c = 0
	for k, v in pairs(tbl) do
		c += 1
	end
	return c
end

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RunBankingStartup()

		exports['pulsar-pedinteraction']:Add("paycheck", `ig_bankman`, vector3(253.193, 216.434, 105.282), 339.578, 25.0,
			{
				{
					icon = "fas fa-hand-holding-dollar",
					text = "Get Paycheck",
					event = "Finance:Client:Paycheck",
					isEnabled = function()
						return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
					end,
				},
			}, "money-check-dollar")

		-- exports.ox_target:addBoxZone({ -- not sure why??
		-- 	id = "paycheck",
		-- 	coords = vector3(254.53, 216.58, 106.28),
		-- 	size = vector3(0.8, 3.6, 3.0),
		-- 	rotation = 340,
		-- 	debug = false,
		-- 	minZ = 105.28,
		-- 	maxZ = 108.28,
		-- 	options = {
		-- 		{
		-- 			icon = "fas fa-hand-holding-dollar",
		-- 			label = "Get Paycheck",
		-- 			event = "Finance:Client:Paycheck",
		-- 			canInteract = function()
		-- 				return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
		-- 			end,
		-- 		},
		-- 	}
		-- })

		exports['pulsar-pedinteraction']:Add("paycheck-2", `ig_bankman`, vector3(17.568, -927.223, 28.903), 111.958,
			25.0, {
				{
					icon = "fas fa-hand-holding-dollar",
					text = "Get Paycheck",
					event = "Finance:Client:Paycheck",
					isEnabled = function()
						return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
					end,
				},
			}, "money-check-dollar")

		-- exports.ox_target:addBoxZone({ -- not sure why??
		-- 	id = "paycheck-2",
		-- 	coords = vector3(16.72, -927.74, 29.9),
		-- 	size = vector3(2.0, 1.0, 1.6),
		-- 	rotation = 15,
		-- 	debug = false,
		-- 	minZ = 29.7,
		-- 	maxZ = 31.3,
		-- 	options = {
		-- 		{
		-- 			icon = "fas fa-hand-holding-dollar",
		-- 			label = "Get Paycheck",
		-- 			event = "Finance:Client:Paycheck",
		-- 			canInteract = function()
		-- 				return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
		-- 			end,
		-- 		},
		-- 	}
		-- })

		exports['pulsar-pedinteraction']:Add("paycheck-3", `ig_bankman`, vector3(-108.997, 6471.589, 30.634), 224.685,
			25.0, {
				{
					icon = "fas fa-hand-holding-dollar",
					text = "Get Paycheck",
					event = "Finance:Client:Paycheck",
					isEnabled = function()
						return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
					end,
				},
			}, "money-check-dollar")

		-- exports.ox_target:addBoxZone({ -- not sure why??
		-- 	id = "paycheck-3",
		-- 	coords = vector3(-109.04, 6471.68, 31.63),
		-- 	size = vector3(1.6, 1.2, 4.0),
		-- 	rotation = 315,
		-- 	debug = false,
		-- 	minZ = 28.83,
		-- 	maxZ = 32.83,
		-- 	options = {
		-- 		{
		-- 			icon = "fas fa-hand-holding-dollar",
		-- 			label = "Get Paycheck",
		-- 			event = "Finance:Client:Paycheck",
		-- 			canInteract = function()
		-- 				return TableLength(LocalPlayer.state.Character:GetData("Salary") or {}) > 0
		-- 			end,
		-- 		},
		-- 	}
		-- })

		exports['pulsar-hud']:InteractionRegisterMenu("cash", "Show Cash", "dollar-sign", function()
			TriggerServerEvent("Wallet:ShowCash")
			exports['pulsar-hud']:InteractionHide()
		end)
	end
end)

RegisterNetEvent("UI:Client:Reset", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "APP_HIDE",
		data = {},
	})
end)

AddEventHandler("Finance:Client:Paycheck", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Finance:Paycheck", {}, function(s)
		if s.total > 0 then
			exports["pulsar-hud"]:Notification("success",
				string.format("You Received $%s For %s Total Minutes Worked", s.total,
					s.minutes))
		else
			exports["pulsar-hud"]:Notification("error", "You Need To Work To Earn A Paycheck")
		end
	end)
end)

RegisterNUICallback("Close", function(data, cb)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "APP_HIDE",
	})

	if not inBank then
		exports['pulsar-hud']:Progress({
			name = "atm_removing",
			duration = 1500,
			label = "Removing Card",
			useWhileDead = false,
			canCancel = false,
			ignoreModifier = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@prop_human_atm@male@idle_a",
				anim = "idle_b",
				flags = 49,
			},
			disarm = true,
		}, function(cancelled) end)
	end

	inBank = false
end)

RegisterNetEvent("Finance:Client:OpenUI", function()
	inBank = true
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "SET_APP",
		data = {
			brand = "fleeca",
			app = "BANK",
		},
	})
end)

AddEventHandler("Characters:Client:Updated", function(key)
	if key == "Cash" then
		SendNUIMessage({
			type = "SET_DATA",
			data = {
				type = "character",
				data = {
					ID = LocalPlayer.state.Character:GetData("ID"),
					SID = LocalPlayer.state.Character:GetData("SID"),
					First = LocalPlayer.state.Character:GetData("First"),
					Last = LocalPlayer.state.Character:GetData("Last"),
					Cash = LocalPlayer.state.Character:GetData("Cash"),
				},
			},
		})
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	SendNUIMessage({
		type = "SET_DATA",
		data = {
			type = "character",
			data = {
				ID = LocalPlayer.state.Character:GetData("ID"),
				SID = LocalPlayer.state.Character:GetData("SID"),
				First = LocalPlayer.state.Character:GetData("First"),
				Last = LocalPlayer.state.Character:GetData("Last"),
				Cash = LocalPlayer.state.Character:GetData("Cash"),
			},
		},
	})
end)

RegisterNetEvent("Finance:Client:HandOffCash", function()
	loadAnimDict("mp_safehouselost@")
	TaskPlayAnim(LocalPlayer.state.ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
end)
