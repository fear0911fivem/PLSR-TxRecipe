_limited = false
_payphone = false

local disabling = false
local function DisableKeys()
	if disabling then return end
	disabling = true
	CreateThread(function()
		while disabling do
			DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
			DisableControlAction(0, 0, true) -- LookLeftRight
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 24, true) -- disable attack
			DisableControlAction(0, 25, true) -- disable aim
			DisableControlAction(0, 37, true) -- disable weapon select
			DisableControlAction(0, 47, true) -- disable weapon
			DisableControlAction(0, 58, true) -- disable weapon
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 142, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 177, true) -- disable melee
			DisableControlAction(0, 199, true) -- disable melee
			DisableControlAction(0, 200, true) -- disable melee
			DisableControlAction(0, 201, true) -- disable melee
			DisableControlAction(0, 245, true) -- disable melee
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 322, true) -- disable melee
			Wait(1)
		end
	end)
end

exports("Open", function()
	_limited = false
	_payphone = false
	exports.ox_inventory:closeInventory()
	exports['pulsar-hud']:InteractionHide()
	LocalPlayer.state.phoneOpen = true
	DisplayRadar(true)
	exports['pulsar-hud']:ShiftLocation(true)
	PhonePlayIn()
	SendNUIMessage({ type = "PHONE_VISIBLE" })
	SetNuiFocus(true, true)
end)

exports("OpenLimited", function()
	_limited = true
	_payphone = false
	exports.ox_inventory:closeInventory()
	exports['pulsar-hud']:InteractionHide()
	LocalPlayer.state.phoneOpen = true
	PhonePlayIn()
	SendNUIMessage({ type = "PHONE_VISIBLE_LIMITED" })
	SetNuiFocus(true, true)
end)

exports("OpenPayphone", function()
	_limited = true
	_payphone = true
	exports.ox_inventory:closeInventory()
	exports['pulsar-hud']:InteractionHide()
	LocalPlayer.state.phoneOpen = true
	PhonePlayIn()
	SendNUIMessage({ type = "PHONE_VISIBLE_LIMITED" })
	SetNuiFocus(true, true)
end)

exports("Close", function(forced, doJankyStuff)
	LocalPlayer.state.phoneOpen = false
	_openCd = true
	if not doJankyStuff then
		exports['pulsar-phone']:ResetRoute()
	end
	if forced then
		SendNUIMessage({ type = "PHONE_NOT_VISIBLE_FORCED" })
	end
	if _limited then
		exports['pulsar-phone']:CallEnd()
	end
	SendNUIMessage({ type = "ALERTS_RESET" })
	if not IsPedInAnyVehicle(PlayerPedId(), true) then
		DisplayRadar(LocalPlayer.state.Character and hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
	end
	exports['pulsar-hud']:ShiftLocation(LocalPlayer.state.Character and
		hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
	if not exports['pulsar-phone']:CallStatus() or _limited then
		PhonePlayOut()
	end
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	TriggerEvent("UI:Client:Close", "phone")

	_limited = false
end)

exports("IsOpen", function()
	return LocalPlayer.state.phoneOpen
end)

exports("ResetRoute", function()
	SendNUIMessage({ type = "CLEAR_HISTORY" })
end)

exports("ReceiveShare", function(data)
	SendNUIMessage({ type = "RECEIVE_SHARE", data = data })
end)

exports("PermissionsLoad", function(p)
	SendNUIMessage({
		type = "LOAD_PERMS",
		data = p,
	})
end)

exports("IsAppUsable", function(app)
	if type(app) == "table" then
		return true
	elseif PHONE_APPS == nil then
		return false
	else
		local appdata = PHONE_APPS[app]
		return appdata ~= nil
			and hasValue(LocalPlayer.state.Character:GetData("Apps").installed, app)
			and (
				not appdata.restricted
				or (
					(
						appdata.restricted.job
						and exports['pulsar-jobs']:HasJob(
							appdata.restricted.job,
							appdata.restricted.workplace,
							appdata.restricted.grade
						)
					)
					or (appdata.restricted.state and hasValue(
						LocalPlayer.state.Character:GetData("States"),
						appdata.restricted.state
					))
					or (appdata.restricted.jobPermission and exports['pulsar-jobs']:HasJob(
						appdata.restricted.job,
						appdata.restricted.workplace,
						appdata.restricted.grade,
						nil,
						false,
						appdata.restricted.jobPermission
					))
					or (appdata.restricted.phonePermission and exports['pulsar-phone']:PermissionsHasPermission(
						appdata.restricted.phonePermission.app,
						appdata.restricted.phonePermission.permission
					))
					or (
						appdata.restricted.repuation
						and exports['pulsar-characters']:RepHasLevel(
							appdata.restricted.repuation,
							appdata.restricted.repuationAmount or 0
						)
					)
				)
			)
	end
end)

exports("DataSet", function(key, data)
	SendNUIMessage({ type = "SET_DATA", data = { type = key, data = data } })
end)

exports("DataAdd", function(type, data, key)
	SendNUIMessage({ type = "ADD_DATA", data = { type = type, data = data, key = key } })
end)

exports("DataUpdate", function(type, id, data)
	SendNUIMessage({ type = "UPDATE_DATA", data = { type = type, id = id, data = data } })
end)

exports("DataRemove", function(key, id)
	SendNUIMessage({ type = "REMOVE_DATA", data = { type = key, id = id } })
end)

exports("DataReset", function()
	SendNUIMessage({ type = "RESET_DATA" })
end)

exports("NotificationAdd", function(title, description, time, duration, app, actions, notifData)
	if not LocalPlayer.state.loggedIn or exports.ox_inventory:GetItemCount('phone') == 0 then
		return
	end

	local appUsable = exports['pulsar-phone']:IsAppUsable(app)
	if
		_settings.notifications
		and (type(app) == "table" or (appUsable and not _settings.appNotifications[app]) or app == "comanager")
		and not exports['pulsar-jail']:IsJailed()
	then
		SendNUIMessage({
			type = "NOTIF_ADD",
			data = {
				notification = {
					title = title,
					description = description,
					time = time,
					duration = duration,
					app = app,
					action = actions,
					data = notifData,
					show = true,
				},
			},
		})

		if not LocalPlayer.state.phoneOpen and (exports['pulsar-phone']:IsAppUsable(app)) then
			exports["pulsar-sounds"]:PlayOne(_settings.texttone, 0.1 * (_settings.volume / 100))
		end
	end
end)

exports("NotificationAddWithId", function(id, title, description, time, duration, app, actions, notifData)
	SendNUIMessage({
		type = "NOTIF_ADD",
		data = {
			notification = {
				id = id,
				title = title,
				description = description,
				time = time,
				duration = duration,
				app = app,
				action = actions,
				data = notifData,
				show = true,
			},
		},
	})
end)

exports("NotificationUpdate", function(id, title, description)
	SendNUIMessage({
		type = "NOTIF_UPDATE",
		data = {
			id = id,
			title = title,
			description = description,
		},
	})
end)

exports("NotificationRemove", function(id)
	SendNUIMessage({
		type = "NOTIF_HIDE",
		data = {
			id = id,
		},
	})
end)

exports("NotificationReset", function()
	SendNUIMessage({ type = "NOTIF_DISMISS_ALL" })
end)

exports("SetExpanded", function(state)
	SendNUIMessage({
		type = "SET_EXPANDED",
		data = {
			expanded = state,
		},
	})
end)

exports("PermissionsHasPermission", function(app, permission)
	local myPerms = LocalPlayer.state.Character:GetData("PhonePermissions")
	if not app or not permission then
		return false
	else
		return PhonePermissions[app][permission]
	end
end)

RegisterNetEvent("Phone:Client:Close", function()
	exports['pulsar-phone']:Close()
end)

RegisterNUICallback("ClosePhone", function(data, cb)
	cb("OK")
	exports['pulsar-phone']:Close()
end)

RegisterNetEvent("Phone:Client:Notifications:Add", function(title, description, time, duration, app, actions, notifData)
	exports['pulsar-phone']:NotificationAdd(title, description, time, duration, app, actions, notifData)
end)

RegisterNetEvent(
	"Phone:Client:Notifications:AddWithId",
	function(id, title, description, time, duration, app, actions, notifData)
		exports['pulsar-phone']:NotificationAddWithId(id, title, description, time, duration, app, actions,
			notifData)
	end
)

RegisterNetEvent("Phone:Client:Notifications:Update", function(id, title, description)
	exports['pulsar-phone']:NotificationUpdate(id, title, description)
end)

RegisterNetEvent("Phone:Client:Notifications:Remove", function(id)
	exports['pulsar-phone']:NotificationRemove(id)
end)
