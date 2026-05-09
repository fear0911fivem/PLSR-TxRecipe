local _packagesAvailable = 5
local _weedBuyers = {}

function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Weed:CheckPlant", function(source, pid, cb)
		if pid ~= nil and _plants[pid] then
			if checkNearPlant(source, pid) then
				cb({
					plant = _plants[pid].plant,
					ground = GroundTypes[Materials[_plants[pid].plant.material].groundType],
				})
			else
				cb(nil)
			end
		else
			cb(nil)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:WaterPlant", function(source, pid, cb)
		if pid ~= nil and _plants[pid] then
			if checkNearPlant(source, pid) then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if char ~= nil then
					if _plants[pid] ~= nil then
						if _plants[pid].plant.water < 100 then
							if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, "water", 1) then
								exports.ox_inventory:Remove(char:GetData("SID"), 1, "water", 1)
								local amt = 10.0
								if 100 - _plants[pid].plant.water < 10 then
									amt = (100 - _plants[pid].plant.water) + 0.0
								end
								_plants[pid].plant.water = _plants[pid].plant.water + amt
							else
								exports['pulsar-hud']:Notification(source, "error",
									"You Don't Have Water")
							end
						else
							exports['pulsar-hud']:Notification(source, "error",
								"Plant Is Already Watered")
						end
					else
						exports['pulsar-hud']:Notification(source, "error", "Invalid Plant")
					end
				end
			else
				cb(nil)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:FertilizePlant", function(source, data, cb)
		if data and data.id and _plants[data.id] then
			if checkNearPlant(source, data.id) then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if char ~= nil then
					if _plants[data.id] ~= nil then
						if _plants[data.id].plant.fertilizer == nil then
							if
								exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, string.format("fertilizer_%s", data.type), 1)
							then
								exports.ox_inventory:Remove(
									char:GetData("SID"),
									1,
									string.format("fertilizer_%s", data.type),
									1
								)
								_plants[data.id].plant.fertilizer = {
									type = data.type,
									time = Config.Fertilizer[data.type].time,
									value = Config.Fertilizer[data.type].value,
								}
							else
								exports['pulsar-hud']:Notification(source, "error",
									"You Don't Have Fertilizer")
							end
						else
							exports['pulsar-hud']:Notification(source, "error",
								"Plant Is Already Fertilized")
						end
					else
						exports['pulsar-hud']:Notification(source, "error", "Invalid Plant")
					end
				end
			else
				cb(nil)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:HarvestPlant", function(source, pid, cb)
		if pid then
			if checkNearPlant(source, pid) then
				if _plants[pid] ~= nil then
					local char = exports['pulsar-characters']:FetchCharacterSource(source)
					if char ~= nil then
						local stage = Plants[getStageByPct(_plants[pid].plant.growth)]
						if stage.harvestable then
							if _plants[pid].plant.isMale then
								local luck = math.random(100)
								local giving = "weedseed_male"
								if luck >= (100 - Config.FemSeedChance) then
									giving = "weedseed_female"
								end
								if
									exports.ox_inventory:AddItem(
										char:GetData("SID"),
										giving,
										math.random(math.ceil(_plants[pid].plant.output / 16)),
										{},
										1
									)
								then
									exports['pulsar-weed']:PlantingDelete(pid)
									exports['pulsar-core']:LoggerInfo(
										"Weed",
										string.format(
											"%s %s (%s) Harvested A Weed Plant",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID")
										)
									)
									cb(true)
								else
									cb(false)
								end
							else
								local t = math.random(math.ceil((_plants[pid].plant.output / 4)))
								if t < 1 then
									t = 3
								end

								if exports.ox_inventory:AddItem(char:GetData("SID"), "weed_bud", t, {}, 1) then
									exports['pulsar-weed']:PlantingDelete(pid)
									cb(true)
								else
									cb(false)
								end
							end
						else
							cb(nil)
						end
					else
						cb(nil)
					end
				else
					cb(nil)
				end
			else
				cb(nil)
			end
		else
			cb(nil)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:DestroyPlant", function(source, pid, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if pid and _plants[pid] then
				if checkNearPlant(source, pid) then
					exports['pulsar-weed']:PlantingDelete(pid)
					exports['pulsar-core']:LoggerInfo(
						"Weed",
						string.format(
							"%s %s (%s) Destroyed A Weed Plant",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID")
						)
					)
					exports['pulsar-hud']:Notification(source, "success", "Plant Has Been Destroyed")
				else
					cb(nil)
				end
			else
				cb(nil)
			end
		else
			cb(nil)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:PDDestroyPlant", function(source, pid, cb)
		if pid and _plants[pid] then
			if checkNearPlant(source, pid) then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if char ~= nil then
					if Player(source).state.onDuty == "police" then
						exports['pulsar-weed']:PlantingDelete(pid)
						exports['pulsar-core']:LoggerInfo(
							"Weed",
							string.format(
								"%s %s (%s) PD Destroyed A Weed Plant",
								char:GetData("First"),
								char:GetData("Last"),
								char:GetData("SID")
							)
						)
						exports['pulsar-hud']:Notification(source, "success",
							"Plant Has Been Destroyed")
					else
						cb(nil)
					end
				else
					cb(nil)
				end
			else
				cb(nil)
			end
		else
			cb(nil)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Weed:BuyPackage", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char ~= nil then
			if _packagesAvailable > 0 and not _weedBuyers[char:GetData("ID")] then
				if exports['pulsar-finance']:WalletModify(source, -Config.PackagePrice) then
					exports['pulsar-core']:LoggerInfo(
						"Weed",
						string.format(
							"%s %s (%s) Bought Weed Package",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID")
						)
					)
					_packagesAvailable -= 1
					_weedBuyers[char:GetData("ID")] = true

					local luck = math.random(100)
					local giving = "weedseed_male"
					local giving2 = "fertilizer_nitrogen"
					if luck >= 95 then
						giving = "weedseed_female"
					end

					if luck >= 66 then
						giving2 = "fertilizer_phosphorus"
					elseif luck >= 33 then
						giving2 = "fertilizer_potassium"
					end

					--exports['pulsar-characters']:RepAdd(source, "weed", 1000)
					exports.ox_inventory:AddItem(char:GetData("SID"), giving, 2, {}, 1)
					exports.ox_inventory:AddItem(char:GetData("SID"), giving2, 2, {}, 1)
				else
					exports['pulsar-core']:LoggerInfo(
						"Weed",
						string.format(
							"%s %s (%s) Bought Weed Package",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID")
						)
					)
					exports['pulsar-hud']:Notification(source, "error", "Dont Have Enough Cash")
					cb(false)
				end
			else
				exports['pulsar-core']:LoggerInfo(
					"Weed",
					string.format(
						"%s %s (%s) Bought Weed Package",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID")
					)
				)
				if _packagesAvailable > 0 then
					exports['pulsar-hud']:Notification(source, "error",
						"You've Already Bought A Package")
				else
					exports['pulsar-hud']:Notification(source, "error", "No Packages Available")
				end
				cb(false)
			end
		else
			cb(false)
		end
	end)
end
