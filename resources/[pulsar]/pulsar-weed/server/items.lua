function RegisterItems()
	exports.ox_inventory:RegisterUse("weedseed_male", "Weed", function(source, item)
		if GlobalState[string.format("%s:House", source)] == nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			if veh == 0 then
				exports["pulsar-core"]:ClientCallback(source, "Weed:PlantingAnim", {}, function(data)
					if data.error == nil then
						exports.ox_inventory:RemoveList(char:GetData("SID"), 1,
							{ { name = "weedseed_male", count = 1 } })
						local plant = exports['pulsar-weed']:PlantingCreate(
							true,
							{ x = data.coords.x, y = data.coords.y, z = data.coords.z },
							data.material
						)

						_plants[plant._id] = {
							plant = plant,
						}

						exports['pulsar-weed']:PlantingSet(plant._id, false)
					else
						if data.error == 2 then
							exports['pulsar-hud']:Notification(source, "error", "Need Better Soil")
						elseif data.error == 3 then
							exports['pulsar-hud']:Notification(source, "error", "Too Close")
						end
					end
				end)
			else
				exports['pulsar-hud']:Notification(source, "error", "Can't Plan While In A Vehicle")
			end
		else
			exports['pulsar-hud']:Notification(source, "error", "Plant Needs Natural Light")
		end
	end)

	exports.ox_inventory:RegisterUse("weedseed_female", "Weed", function(source, item)
		if GlobalState[string.format("%s:House", source)] == nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			if veh == 0 then
				exports["pulsar-core"]:ClientCallback(source, "Weed:PlantingAnim", {}, function(data)
					if data.error == nil then
						exports.ox_inventory:RemoveList(char:GetData("SID"), 1,
							{ { name = "weedseed_female", count = 1 } })
						local plant = exports['pulsar-weed']:PlantingCreate(
							false,
							{ x = data.coords.x, y = data.coords.y, z = data.coords.z },
							data.material
						)

						_plants[plant._id] = {
							plant = plant,
						}

						exports['pulsar-weed']:PlantingSet(plant._id, false)
					else
						if data.error == 2 then
							exports['pulsar-hud']:Notification(source, "error", "Need Better Soil")
						elseif data.error == 3 then
							exports['pulsar-hud']:Notification(source, "error", "Too Close")
						end
					end
				end)
			else
				exports['pulsar-hud']:Notification(source, "error", "Can't Plan While In A Vehicle")
			end
		else
			exports['pulsar-hud']:Notification(source, "error", "Plant Needs Natural Light")
		end
	end)

	exports.ox_inventory:RegisterUse("rolling_paper", "Weed", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, "weed_bud", 1) then
			exports["pulsar-core"]:ClientCallback(source, "Weed:RollingAnim", {}, function(success)
				if success then
					exports.ox_inventory:RemoveList(
						char:GetData("SID"),
						1,
						{ { name = "rolling_paper", count = 1 }, { name = "weed_bud", count = 1 } }
					)
					exports.ox_inventory:AddItem(char:GetData("SID"), "weed_joint", 2, {}, 1)
				end
			end)
		else
			exports['pulsar-hud']:Notification(source, "error", "You need bud to do this")
		end
	end)

	exports.ox_inventory:RegisterUse("weed_joint", "Weed", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		exports["pulsar-core"]:ClientCallback(source, "Weed:SmokingAnim", {}, function(success, count)
			exports.ox_inventory:RemoveList(char:GetData("SID"), 1, { { name = "weed_joint", count = 1 } })

			local stressTicks = {}
			for i = 0, count do
				table.insert(stressTicks, "3")
			end
			--Player(source).state.armorTicks = { "2", "2", "2", "2", "2" }
			--TriggerClientEvent("Damage:Client:Ticks:Armor", source)
			Player(source).state.stressTicks = stressTicks
		end)
	end)

	exports.ox_inventory:RegisterUse("weed_brick", "Weed", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, "weed_brick", 1) then
			exports["pulsar-core"]:ClientCallback(source, "Weed:MakingBrick", {
				label = "Unpacking Brick",
				time = 10,
			}, function(success)
				if success then
					exports.ox_inventory:RemoveList(char:GetData("SID"), 1,
						{ { name = "weed_brick", count = 1 } })
					exports.ox_inventory:AddItem(char:GetData("SID"), "weed_bud", 200, {}, 1)
				end
			end)
		else
			exports['pulsar-hud']:Notification(source, "error", "You need 200 bud to do this")
		end
	end)

	exports.ox_inventory:RegisterUse("weed_baggy", "Weed", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, "weed_baggy", 1) then
			exports["pulsar-core"]:ClientCallback(source, "Weed:MakingBrick", {
				label = "Removing Bud",
				time = 3,
			}, function(success)
				if success then
					exports.ox_inventory:RemoveList(char:GetData("SID"), 1,
						{ { name = "weed_baggy", count = 1 } })
					exports.ox_inventory:AddItem(char:GetData("SID"), "weed_bud", 2, {}, 1)
				end
			end)
		else
			exports['pulsar-hud']:Notification(source, "error", "You need 200 bud to do this")
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItems()
	end
end)
