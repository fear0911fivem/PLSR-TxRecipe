RegisterNetEvent("Hud:Client:GiveCash", function(hitting, data)
	local tSid = Player(hitting.serverId).state.SID

	exports['pulsar-hud']:InputShow(
		"Give Cash",
		"Amount To Give",
		{
			{
				id = "target",
				label = "Target",
				type = "number",
				options = {
					disabled = true,
					value = tSid,
				},
			},
			{
				id = "amount",
				type = "number",
				options = {
					inputProps = {
						min = 1,
						max = 9999999,
					},
				},
			},
		},
		"Hud:Client:DoGiveCash",
		{
			target = tSid,
		}
	)
end)

AddEventHandler("Hud:Client:DoGiveCash", function(values, data)
	exports["pulsar-core"]:ServerCallback("Wallet:GiveCash", {
		target = data.target,
		amount = values.amount,
	})
end)

-- RegisterNetEvent("Input:Client:Test", function()
-- 	exports['pulsar-hud']:InputShow(
-- 		"Test Input",
-- 		"Input Label",
-- 		{
-- 			{
-- 				id = "test",
-- 				type = "text",
-- 				options = {
-- 					inputProps = {
-- 						maxLength = 2,
-- 					},
-- 				},
-- 			},
-- 			{
-- 				id = "test2",
-- 				type = "number",
-- 				options = {
-- 					inputProps = {
-- 						maxLength = 2,
-- 					},
-- 				},
-- 			},
-- 			{
-- 				id = "test3",
-- 				type = "multiline",
-- 				options = {},
-- 			},
-- 		},
-- 		"Input:Client:InputTest",
-- 		{
-- 			test = "penis",
-- 		}
-- 	)
-- end)

-- AddEventHandler("Input:Client:InputTest", function(values, data)
-- 	print(json.encode(values))
-- 	print(json.encode(data))
-- end)

RegisterNUICallback("Input:Submit", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	TriggerEvent(data.event, data.values, data.data)
	exports['pulsar-hud']:InputClose()
	cb("ok")
end)

RegisterNUICallback("Input:Close", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	exports['pulsar-hud']:InputClose()
	TriggerEvent("Input:Closed", data.event, data.data)
	cb("ok")
end)

exports("InputShow", function(title, label, inputs, event, data)
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "SHOW_INPUT",
		data = {
			title = title,
			label = label,
			inputs = inputs,
			event = event,
			data = data,
		},
	})
end)

exports("InputClose", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "CLOSE_INPUT",
	})
end)
