AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterGamesCallbacks()
		TriggerEvent("Robbery:Client:Setup")

		CreateThread(function()
			exports['pulsar-pedinteraction']:Add(
				"RobToolsPickup",
				GetHashKey("csb_anton"),
				vector3(1129.422, -476.236, 65.485),
				300.00,
				25.0,
				{
					{
						icon = "fas fa-hand-paper",
						text = "Pickup Items",
						event = "Robbery:Client:PickupItems",
					},
				},
				"box-dollar"
			)
		end)
	end
end)

AddEventHandler("Robbery:Client:PickupItems", function()
	exports["pulsar-core"]:ServerCallback("Robbery:Pickup", {})
end)

RegisterNetEvent("Robbery:Client:State:Init", function(states)
	_bankStates = states

	for k, v in pairs(states) do
		TriggerEvent(string.format("Robbery:Client:Update:%s", k))
	end
end)

RegisterNetEvent("Robbery:Client:State:Set", function(bank, state)
	_bankStates[bank] = state
	TriggerEvent(string.format("Robbery:Client:Update:%s", bank))
end)

RegisterNetEvent("Robbery:Client:State:Update", function(bank, key, value, tableId)
	print("Heist State Debug: ", bank, key, value, tableId)
	if tableId then
		_bankStates[bank][tableId] = _bankStates[bank][tableId] or {}
		_bankStates[bank][tableId][key] = value
	else
		_bankStates[bank][key] = value
	end
	TriggerEvent(string.format("Robbery:Client:Update:%s", bank))
end)

RegisterNetEvent("Robbery:Client:PrintState", function(heistId)
	if heistId ~= nil and _bankStates[heistId] ~= nil then
		print(json.encode(_bankStates[heistId], { indent = true }))
	else
		print(json.encode(_bankStates, { indent = true }))
	end
end)

AddEventHandler("Robbery:Client:Holdup:Do", function(entity, data)
	exports['pulsar-hud']:ProgressWithTickEvent({
		name = "holdup",
		duration = 5000,
		label = "Robbing",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "random@shop_robbery",
			anim = "robbery_action_b",
			flags = 49,
		},
	}, function()
		if
			#(
				GetEntityCoords(LocalPlayer.state.ped)
				- GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(entity.serverId)))
			) <= 3.0
		then
			return
		end
		exports['pulsar-hud']:ProgressCancel()
	end, function(cancelled)
		if not cancelled then
			exports.ox_inventory:openNearbyInventory()
		end
	end)
end)
