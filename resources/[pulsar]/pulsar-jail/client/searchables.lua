_CURRENT_SEARCH = false

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	while not GlobalState.JailSearchLocations do
		Wait(100)
	end

	if GlobalState.JailSearchLocations ~= nil then
		for key, data in ipairs(GlobalState.JailSearchLocations) do
			exports.ox_target:addBoxZone({
				id = string.format("prison_search_%s", key),
				coords = data.coords,
				size = vector3(data.width, data.length, 2.0),
				rotation = data.options.heading or 0,
				debug = false,
				minZ = data.options.minZ,
				maxZ = data.options.maxZ,
				options = {
					{
						icon = "magnifying-glass",
						label = "Search",
						event = "Prison:Client:Target:Search",
						canInteract = function(_, entity)
							local jailed = LocalPlayer.state.Character:GetData("Jailed")
							return jailed or (jailed and GlobalState["OS:Time"] < jailed.Release)
						end,
					},
				}
			})
		end
	end
end)

AddEventHandler("Prison:Client:Target:Search", function(entity, data)
	_CURRENT_SEARCH = true

	if LocalPlayer.state.isK9Ped then
		exports['pulsar-animations']:EmotesPlay("searchk9", false, nil, true)
	else
		exports['pulsar-animations']:EmotesPlay("mechanic2", false, nil, true) -- or search
	end
	exports['pulsar-hud']:Progress({
		name = "prison_target_search",
		duration = math.random(12000, 18000),
		label = "Searching Hidden Location",
		useWhileDead = false,
		canCancel = false,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
	}, function(cancelled)
		if not cancelled and _CURRENT_SEARCH then
			exports["pulsar-core"]:ServerCallback("Prison:Searchable:GetLootShit", {}, function(success)
				-- if success then
				-- 	print("success")
				-- 	-- exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "PURCHASE", "HUD_LIQUOR_STORE_SOUNDSET")
				-- else
				-- 	print("failed")
				-- end
				exports['pulsar-animations']:EmotesForceCancel()
				_CURRENT_SEARCH = false
			end)
		else
			_CURRENT_SEARCH = false
		end
	end)
end)

AddEventHandler("Characters:Client:Logout", function()
	_CURRENT_SEARCH = false
end)

AddEventHandler("playerDropped", function()
	_CURRENT_SEARCH = false
end)
