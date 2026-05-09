_tabletProp = nil

exports('Open', function()
	exports.ox_inventory:closeInventory()
	exports['pulsar-animations']:EmotesForceCancel()
	exports['pulsar-hud']:InteractionHide()
	LocalPlayer.state.laptopOpen = true
	DisplayRadar(true)
	exports['pulsar-hud']:ShiftLocation(true)
	SendNUIMessage({ type = "LAPTOP_VISIBLE" })
	SetNuiFocus(true, true)

	CreateThread(function()
		local playerPed = PlayerPedId()
		LoadAnim("amb@code_human_in_bus_passenger_idles@female@tablet@base")
		LoadModel(`prop_cs_tablet`)

		local _tabletProp = CreateObject(`prop_cs_tablet`, GetEntityCoords(playerPed), 1, 1, 0)
		AttachEntityToEntity(
			_tabletProp,
			playerPed,
			GetPedBoneIndex(playerPed, 60309),
			0.02,
			-0.01,
			-0.03,
			0.0,
			0.0,
			-10.0,
			1,
			0,
			0,
			0,
			2,
			1
		)

		while LocalPlayer.state.laptopOpen and _loggedIn do
			if
				not IsEntityPlayingAnim(
					playerPed,
					"amb@code_human_in_bus_passenger_idles@female@tablet@base",
					"base",
					3
				)
			then
				TaskPlayAnim(
					playerPed,
					"amb@code_human_in_bus_passenger_idles@female@tablet@base",
					"base",
					3.0,
					3.0,
					-1,
					49,
					0,
					false,
					false,
					false
				)
			end
			Wait(250)
		end

		StopAnimTask(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0)
		DeleteEntity(_tabletProp)
	end)
end)

exports('Close', function(forced)
	LocalPlayer.state.laptopOpen = false
	exports['pulsar-laptop']:ResetRoute()

	if forced then
		SendNUIMessage({ type = "LAPTOP_NOT_VISIBLE_FORCED" })
	end

	SendNUIMessage({ type = "ALERTS_RESET" })

	if not IsPedInAnyVehicle(PlayerPedId(), true) then
		DisplayRadar(LocalPlayer.state.Character and hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
	end

	exports['pulsar-hud']:ShiftLocation(LocalPlayer.state.Character and
		hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
	SetNuiFocus(false, false)
end)

exports('IsOpen', function()
	return LocalPlayer.state.laptopOpen
end)

exports('ResetRoute', function()
	SendNUIMessage({ type = "CLEAR_HISTORY" })
end)

exports('LoadPermissions', function(p)
	SendNUIMessage({
		type = "LOAD_PERMS",
		data = p,
	})
end)

exports('IsAppUsable', function(app)
	if type(app) == "table" then
		return true
	else
		local appdata = LAPTOP_APPS[app]

		if appdata and hasValue(LocalPlayer.state.Character:GetData("LaptopApps").installed, app) then
			if appdata.restricted then
				for k, v in pairs(appdata.restricted) do
					if v then
						if k == "state" then
							if type(v) == "string" then
								if not hasValue(LocalPlayer.state.Character:GetData("States"), v) then
									return false
								end
							else
								for j, b in ipairs(v) do
									if not hasValue(LocalPlayer.state.Character:GetData("States"), b) then
										return false
									end
								end
							end
						elseif k == "job" then
							if not exports['pulsar-jobs']:HasJob(v) then
								return false
							end
						elseif k == "laptopPermission" then
							if not exports['pulsar-laptop']:HasPermission(v.app, v.permission) then
								return false
							end
						elseif k == "reputation" then
							if not exports['pulsar-characters']:RepHasLevel(v.repuation, appdata.restricted.repuationAmount or 0) then
								return false
							end
						end
					end
				end
				return true
			else
				return true
			end
		end
		return false
	end
end)

exports('SetData', function(key, data)
	SendNUIMessage({ type = "SET_DATA", data = { type = key, data = data } })
end)

exports('AddData', function(type, data, key)
	SendNUIMessage({ type = "ADD_DATA", data = { type = type, data = data, key = key } })
end)

exports('UpdateData', function(type, id, data)
	SendNUIMessage({ type = "UPDATE_DATA", data = { type = type, id = id, data = data } })
end)

exports('RemoveData', function(key, id)
	SendNUIMessage({ type = "REMOVE_DATA", data = { type = key, id = id } })
end)

exports('ResetData', function()
	SendNUIMessage({ type = "RESET_DATA" })
end)

exports('AddNotification', function(title, description, time, duration, app, actions, notifData)
	if
		not LocalPlayer.state.loggedIn or not (exports.ox_inventory:Search('count', 'laptop') == 0)
	then
		return
	end

	local appUsable = exports['pulsar-laptop']:IsAppUsable(app)
	if
		_settings.notifications
		and (type(app) == "table" or (appUsable and not _settings.appNotifications[app]))
		and not exports['pulsar-jail']:IsJailed()
	then
		SendNUIMessage({
			type = "NOTIF_ADD",
			data = {
				notification = {
					title = title,
					description = description,
					time = (time - 1000),
					duration = duration,
					app = app,
					action = actions,
					data = notifData,
					show = true,
				},
			},
		})

		exports["pulsar-sounds"]:PlayOne("notification1.ogg", 0.1 * (_settings.volume / 100))
	end
end)

exports('AddNotificationWithId', function(id, title, description, time, duration, app, actions, notifData)
	SendNUIMessage({
		type = "NOTIF_ADD",
		data = {
			notification = {
				_id = id,
				title = title,
				description = description,
				time = (time - 1000),
				duration = duration,
				app = app,
				action = actions,
				data = notifData,
				show = true,
			},
		},
	})

	if not LocalPlayer.state.laptopOpen then
		exports["pulsar-sounds"]:PlayOne("notification1.ogg", 0.1 * (_settings.volume / 100))
	end
end)

exports('UpdateNotification', function(id, title, description, skipSound)
	SendNUIMessage({
		type = "NOTIF_UPDATE",
		data = {
			id = id,
			title = title,
			description = description,
		},
	})

	if not skipSound and not LocalPlayer.state.laptopOpen then
		exports["pulsar-sounds"]:PlayOne("notification1.ogg", 0.1 * (_settings.volume / 100))
	end
end)

exports('RemoveNotification', function(id)
	SendNUIMessage({
		type = "NOTIF_HIDE",
		data = {
			id = id,
		},
	})
end)

exports('ResetNotifications', function()
	SendNUIMessage({ type = "NOTIF_DISMISS_ALL" })
end)

exports('HasPermission', function(app, permission)
	local myPerms = LocalPlayer.state.Character:GetData("LaptopPermissions")
	if not app or not permission then
		return false
	else
		return LaptopPermissions[app][permission]
	end
end)

RegisterNetEvent("Laptop:Client:Close", function()
	exports['pulsar-laptop']:Close()
end)

RegisterNUICallback("CloseLaptop", function(data, cb)
	cb("OK")
	exports['pulsar-laptop']:Close()
end)

RegisterNetEvent(
	"Laptop:Client:Notifications:Add",
	function(title, description, time, duration, app, actions, notifData)
		exports['pulsar-laptop']:AddNotification(title, description, time, duration, app, actions, notifData)
	end
)

RegisterNetEvent(
	"Laptop:Client:Notifications:AddWithId",
	function(id, title, description, time, duration, app, actions, notifData)
		exports['pulsar-laptop']:AddNotificationWithId(id, title, description, time, duration, app, actions, notifData)
	end
)

RegisterNetEvent("Laptop:Client:Notifications:Update", function(id, title, description)
	exports['pulsar-laptop']:UpdateNotification(id, title, description)
end)

RegisterNetEvent("Laptop:Client:Notifications:Remove", function(id)
	exports['pulsar-laptop']:RemoveNotification(id)
end)

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function LoadModel(hash)
	while not HasModelLoaded(hash) do
		RequestModel(hash)
		Wait(10)
	end
end
