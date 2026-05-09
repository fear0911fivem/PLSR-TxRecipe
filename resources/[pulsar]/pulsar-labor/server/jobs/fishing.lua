local _JOB = "Fishing"
local _joiners = {}
local _fishing = {}

local _fishingCooldowns = {}

AddEventHandler("Labor:Server:Startup", function()
	RegisterFishingItems()

	exports["pulsar-core"]:RegisterServerCallback("Fishing:Catch", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char and data?.toolUsed and data?.zone and data?.difficulty and _fishingZoneBasicBait[data.zone] and (not _fishingCooldowns[source] or _fishingCooldowns[source] <= GetGameTimer()) then
			local toolUsedCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1,
				"fishing_" .. data.toolUsed) or 0
			local correctBaitCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1,
					_fishingZoneBasicBait[data.zone]) or
				0
			local lootTable = {}

			if toolUsedCount > 0 and data.difficulty > 0 then
				local fishLoot = GetFishingLootForZone(data.toolUsed, data.zone)
				local filteredLoot = {}

				for k, v in ipairs(fishLoot) do
					if data.difficulty >= v[3] and (not v[4] or (v[4] and correctBaitCount > 0)) and (not v[5] or (v[5] and data.toolUsed == "net")) then
						table.insert(filteredLoot, v)
					end
				end

				if #filteredLoot > 0 then
					local lootItem = exports.ox_inventory:LootCustomWeightedSetWithCount(filteredLoot, 0, 0, true)
					if lootItem then
						if FishingConfig.FishItems[lootItem.name] then
							if char:GetData("TempJob") == _JOB and _joiners[source] ~= nil and _fishing[_joiners[source]] ~= nil and (_fishing[_joiners[source]].tool == data.toolUsed) then
								if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, lootItem.count, true) then
									_fishing[_joiners[source]].state = 2

									exports['pulsar-labor']:SendWorkgroupEvent(
										_joiners[source],
										string.format("Fishing:Client:%s:FinishJob", _joiners[source])
									)
									exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
								end
							end

							if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, _fishingZoneBasicBait[data.zone], 1) then
								exports.ox_inventory:Remove(char:GetData("SID"), 1,
									_fishingZoneBasicBait[data.zone], 1)
							end
						end

						exports.ox_inventory:AddItem(char:GetData("SID"), lootItem.name, lootItem.count, {}, 1)

						if lootItem.count > 0 then
							local hasToolItem = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
								"fishing_" .. data
								.toolUsed, 1)
							local mult = 6
							if data.toolUsed == "net" then
								mult = 3
							end

							if hasToolItem then
								local toolData = exports.ox_inventory:ItemsGetData(hasToolItem.Name)
								local newValue = hasToolItem.CreateDate - (60 * 60 * mult * lootItem.count)
								if (os.time() - toolData.durability >= newValue) then
									exports.ox_inventory:RemoveId(char:GetData("SID"), 1, hasToolItem)
								else
									exports.ox_inventory:SetItemCreateDate(
										hasToolItem.id,
										newValue
									)
								end
							end
						end
					end

					_fishingCooldowns[source] = GetGameTimer() + 20000

					cb(true)
				else
					cb(false)
				end
			else
				cb(false, true)
			end
		else
			cb(false, true)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Fishing:Sell", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		local itemData = exports.ox_inventory:ItemsGetData(data)

		if char and itemData then
			local count = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, itemData.name) or 0
			if (count) > 0 then
				if exports.ox_inventory:Remove(char:GetData("SID"), 1, itemData.name, count) then
					if Player(char:GetData('Source')).state.onDuty == 'police' or Player(char:GetData('Source')).state.onDuty == 'ems' then
						exports['pulsar-hud']:Notification(source, "success",
							"Thanks for the donation! No money for you kek")
					else
						exports['pulsar-finance']:WalletModify(source, itemData.price * count)
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "You Have No " .. itemData.label)
			end
		end
	end)
end)

function RegisterFishingItems()
	exports.ox_inventory:RegisterUse("fishing_rod", "Labor", function(source, itemData)
		if _joiners[source] and _fishing[_joiners[source]] ~= nil and _fishing[_joiners[source]].state == 0 then
			_fishing[_joiners[source]].state = 1
			_fishing[_joiners[source]].tool = "rod"
			exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Catch Fish", 30)
			exports['pulsar-labor']:SendWorkgroupEvent(
				_joiners[source],
				string.format("Fishing:Client:%s:Startup", _joiners[source])
			)
		end

		TriggerClientEvent("Fishing:Client:StartFishing", source, "rod")
	end)

	exports.ox_inventory:RegisterUse("fishing_net", "Labor", function(source, itemData)
		local repLvl = exports['pulsar-characters']:RepGetLevel(source, _JOB)

		if repLvl < 3 then
			exports['pulsar-hud']:Notification(source, "error",
				"Your Net is Tangled and You Don't Know What to Do...")
			return
		end

		if _joiners[source] and _fishing[_joiners[source]] ~= nil and _fishing[_joiners[source]].state == 0 then
			_fishing[_joiners[source]].state = 1
			_fishing[_joiners[source]].tool = "net"
			exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Catch Fish", 40)
			exports['pulsar-labor']:SendWorkgroupEvent(
				_joiners[source],
				string.format("Fishing:Client:%s:Startup", _joiners[source])
			)
		end

		TriggerClientEvent("Fishing:Client:StartFishing", source, "net")
	end)

	exports.ox_inventory:RegisterUse("fishing_boot", "Fishing", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char and exports.ox_inventory:Remove(char:GetData("SID"), 1, item.Name, 1) then
			exports.ox_inventory:LootCustomWeightedSetWithCount({
				{ 35, { name = "scrapmetal", min = 1, max = 2 } },
				{ 20, { name = "rubber", min = 1, max = 3 } },
				{ 15, { name = "goldcoins", min = 3, max = 7 } },
				{ 1,  { name = "diamond", min = 1, max = 1 } },
				{ 1,  { name = "opal", min = 1, max = 1 } },
				{ 10, { name = "ring", min = 2, max = 5 } },
			}, char:GetData("SID"), 1)
		end
	end)

	exports.ox_inventory:RegisterUse("fishing_chest", "Fishing", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and exports.ox_inventory:Remove(char:GetData("SID"), 1, item.Name, 1) then
			exports.ox_inventory:LootCustomWeightedSetWithCount({
				{ 35, { name = "goldcoins", min = 7, max = 15 } },
				{ 25, { name = "ring", min = 6, max = 12 } },
				{ 18, { name = "goldbar", min = 1, max = 3 } },
				{ 13, { name = "house_art", min = 1, max = 1 } },
				{ 9,  { name = "opal", min = 1, max = 2 } },
				{ 7,  { name = "valuegoods", min = 1, max = 1 } },
				{ 1,  { name = "diamond", min = 1, max = 1 } },
				{ 5,  { name = "amethyst", min = 1, max = 2 } },
			}, char:GetData("SID"), 1)
		end
	end)
end

AddEventHandler("Fishing:Server:OnDuty", function(joiner, members, isWorkgroup)
	_joiners[joiner] = joiner
	_fishing[joiner] = {
		joiner = joiner,
		isWorkgroup = isWorkgroup,
		started = os.time(),
		state = 0,
	}

	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	char:SetData("TempJob", _JOB)
	exports['pulsar-phone']:NotificationAdd(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor",
		{})
	TriggerClientEvent("Fishing:Client:OnDuty", joiner, joiner, os.time())

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Buy Fishing Equipment & Start Fishing")
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			exports['pulsar-phone']:NotificationAdd(v.ID, "Job Activity", "You started a job", os.time(), 6000,
				"labor", {})
			TriggerClientEvent("Fishing:Client:OnDuty", v.ID, joiner, os.time())
		end
	end
end)

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterFishingItems()
	end
end)

AddEventHandler("Fishing:Server:OffDuty", function(source, joiner)
	_joiners[source] = nil
	TriggerClientEvent("Fishing:Client:OffDuty", source)
end)

AddEventHandler("Fishing:Server:FinishJob", function(joiner)
	_fishing[joiner] = nil
end)
