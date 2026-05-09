-- RegisterNetEvent("Confirm:Client:Test", function()
-- 	exports['pulsar-hud']:ConfirmShow(
-- 		"Test Input",
-- 		{
-- 			yes = "Confirm:Test:Yes",
-- 			no = "Confirm:Test:No",
-- 		},
-- 		"This is a test confirm dialog, neat",
-- 		{
-- 			test = "penis",
-- 		}
-- 	)
-- end)

-- AddEventHandler("Confirm:Test:Yes", function(data)
-- 	print("Confirm: Yes")
-- end)

-- AddEventHandler("Confirm:Test:No", function(data)
-- 	print("Confirm: No")
-- end)

RegisterNUICallback("Confirm:Yes", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	if data.event then
		TriggerEvent(data.event, data.data)
	end
	exports['pulsar-hud']:ConfirmClose()
	cb("ok")
end)

RegisterNUICallback("Confirm:No", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	if data and data.event then
		TriggerEvent(data.event, data.data)
	end
	exports['pulsar-hud']:ConfirmClose()
	cb("ok")
end)

exports("ConfirmShow", function(title, events, description, data, denyLabel, acceptLabel)
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "SHOW_CONFIRM",
		data = {
			title = title,
			yes = events.yes,
			no = events.no,
			description = description,
			data = data,
			denyLabel = denyLabel,
			acceptLabel = acceptLabel,
		},
	})
end)

exports("ConfirmClose", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "CLOSE_CONFIRM",
	})
end)
