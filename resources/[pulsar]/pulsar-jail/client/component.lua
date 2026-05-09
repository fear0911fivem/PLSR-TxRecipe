_inPickup = false
_inLogout = false
_doingMugshot = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-blips"]:Add("prison", "Bolingbroke Penitentiary", vector3(1852.444, 2585.973, 45.672), 188, 65,
			0.8)

		exports['pulsar-polyzone']:CreatePoly("prison", Config.Prison.points, Config.Prison.options)
		exports['pulsar-polyzone']:CreatePoly("prison-logout", Config.Logout.points, Config.Logout.options)
		exports['pulsar-polyzone']:CreateBox(
			"prison-pickup",
			Config.Pickup.coords,
			Config.Pickup.length,
			Config.Pickup.width,
			Config.Pickup.options
		)

		exports.ox_target:addBoxZone({
			id = string.format("bb-retreive", aptId),
			coords = Config.Retreival.coords,
			size = vector3(Config.Retreival.length, Config.Retreival.width, 2.0),
			rotation = Config.Retreival.options.heading or 0,
			debug = false,
			minZ = Config.Retreival.options.minZ,
			maxZ = Config.Retreival.options.maxZ,
			options = {
				{
					icon = "hand-holding",
					label = "Retrieve Items",
					event = "Jail:Client:RetreiveItems",
					canInteract = function()
						return _inPickup
					end,
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = string.format("prison-inmates-list"),
			coords = Config.VisitorLog.coords,
			size = vector3(Config.VisitorLog.length, Config.VisitorLog.width, 2.0),
			rotation = Config.VisitorLog.options.heading or 0,
			debug = false,
			minZ = Config.VisitorLog.options.minZ,
			maxZ = Config.VisitorLog.options.maxZ,
			options = {
				{
					icon = "users-viewfinder",
					label = "View Inmates",
					event = "Jail:Client:ViewInmates",
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = "prison-check",
			coords = Config.Payphone.coords,
			size = vector3(Config.Payphone.length, Config.Payphone.width, 2.0),
			rotation = Config.Payphone.options.heading or 0,
			debug = false,
			minZ = Config.Payphone.options.minZ,
			maxZ = Config.Payphone.options.maxZ,
			options = {
				{
					icon = "stopwatch",
					label = "Check Remaining Sentence",
					event = "Jail:Client:CheckSentence",
					canInteract = function()
						return exports['pulsar-jail']:IsJailed()
					end,
				},
				{
					icon = "door-open",
					label = "Process Release",
					event = "Jail:Client:Released",
					canInteract = function()
						return exports['pulsar-jail']:IsJailed() and exports['pulsar-jail']:IsReleaseEligible()
					end,
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = "prison-food",
			coords = Config.Cafeteria.Food.coords,
			size = vector3(Config.Cafeteria.Food.length, Config.Cafeteria.Food.width, 2.0),
			rotation = Config.Cafeteria.Food.options.heading or 0,
			debug = false,
			minZ = Config.Cafeteria.Food.options.minZ,
			maxZ = Config.Cafeteria.Food.options.maxZ,
			options = {
				{
					icon = "utensils",
					label = "Make Food",
					event = "Jail:Client:MakeFood",
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = "prison-drink",
			coords = Config.Cafeteria.Drink.coords,
			size = vector3(Config.Cafeteria.Drink.length, Config.Cafeteria.Drink.width, 2.0),
			rotation = Config.Cafeteria.Drink.options.heading or 0,
			debug = false,
			minZ = Config.Cafeteria.Drink.options.minZ,
			maxZ = Config.Cafeteria.Drink.options.maxZ,
			options = {
				{
					icon = "mug-hot",
					label = "Make Drink",
					event = "Jail:Client:MakeDrink",
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = "prison-juice",
			coords = Config.Cafeteria.Juice.coords,
			size = vector3(Config.Cafeteria.Juice.length, Config.Cafeteria.Juice.width, 2.0),
			rotation = Config.Cafeteria.Juice.options.heading or 0,
			debug = false,
			minZ = Config.Cafeteria.Juice.options.minZ,
			maxZ = Config.Cafeteria.Juice.options.maxZ,
			options = {
				{
					icon = "mug-hot",
					label = "Make Fruit Punch",
					event = "Jail:Client:MakeJuice",
				},
				{
					icon = "mug-hot",
					label = "Make BerryRazz",
					event = "Jail:Client:MakeJuice",
				},
			}
		})

		exports.ox_target:addBoxZone({
			id = "prison-payphone",
			coords = Config.Payphones.coords,
			size = vector3(Config.Payphones.length, Config.Payphones.width, 2.0),
			rotation = Config.Payphones.options.heading or 0,
			debug = false,
			minZ = Config.Payphones.options.minZ,
			maxZ = Config.Payphones.options.maxZ,
			options = {
				{
					icon = "phone",
					label = "Use Payphone",
					event = "Phone:Client:OpenLimited",
				},
			}
		})

		exports['pulsar-pedinteraction']:Add("PrisonJobs", `csb_janitor`, Config.Foreman.coords, Config.Foreman.heading,
			25.0, {
				{
					icon = "clipboard-check",
					text = "Start Work",
					event = "Jail:Client:StartWork",
					data = {},
					isEnabled = function()
						return LocalPlayer.state.Character:GetData("TempJob") == nil
					end,
				},
				{
					icon = "clipboard",
					text = "Quit Work",
					event = "Jail:Client:QuitWork",
					tempjob = "Prison",
					data = {},
				},
			}, "user-helmet-safety", "WORLD_HUMAN_JANITOR")

		exports["pulsar-core"]:RegisterClientCallback("Jail:DoMugshot", function(data, cb)
			_disabled = true
			_doingMugshot = true

			exports['pulsar-phone']:Close()
			exports['pulsar-hud']:InteractionHide()
			exports.ox_inventory:CloseAll()

			DoScreenFadeOut(1000)
			while not IsScreenFadedOut() do
				Wait(10)
			end

			exports['pulsar-animations']:EmotesPlay("mugshot", false, -1, true)

			DoBoardShit(data.jailer, data.duration, data.date)
			DisableControls()
			SetEntityCoords(
				LocalPlayer.state.ped,
				Config.Mugshot.coords.x,
				Config.Mugshot.coords.y,
				Config.Mugshot.coords.z,
				0,
				0,
				0,
				false
			)
			Wait(100)
			SetEntityHeading(LocalPlayer.state.ped, Config.Mugshot.headings[1])
			FreezeEntityPosition(LocalPlayer.state.ped, true)

			DoScreenFadeIn(1000)
			while not IsScreenFadedIn() do
				Wait(10)
			end

			exports["pulsar-sounds"]:PlayOne("mugshot.ogg", 0.2)
			Wait(2000)
			for i = 2, #Config.Mugshot.headings do
				if LocalPlayer.state.loggedIn then
					SetEntityHeading(LocalPlayer.state.ped, Config.Mugshot.headings[i])
					Wait(1000)
					exports["pulsar-sounds"]:PlayOne("mugshot.ogg", 0.2)
					Wait(3000)
				end
			end

			SetEntityHeading(LocalPlayer.state.ped, Config.Mugshot.headings[1])
			exports["pulsar-sounds"]:PlayOne("mugshot.ogg", 0.2)
			Wait(2000)

			exports['pulsar-animations']:EmotesForceCancel()
			_doingMugshot = false

			DoScreenFadeOut(1000)
			while not IsScreenFadedOut() do
				Wait(10)
			end

			FreezeEntityPosition(LocalPlayer.state.ped, false)
			cb()
		end)
	end
end)

exports('IsJailed', function()
	if LocalPlayer.state.Character == nil then
		return false
	else
		local jailed = LocalPlayer.state.Character:GetData("Jailed")
		if jailed and not jailed.Released then
			return true
		else
			return false
		end
	end
end)

exports('IsReleaseEligible', function()
	local jailed = LocalPlayer.state.Character:GetData("Jailed")
	if jailed and jailed.Duration < 9999 and GetCloudTimeAsInt() >= (jailed.Release or 0) then
		return true
	else
		return false
	end
end)
