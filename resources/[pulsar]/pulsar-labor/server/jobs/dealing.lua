local _JOB = "CornerDealing"

local _joiners = {}
local _sellers = {}

local _cornerCds = {}

local _repLvls = {
	[0] = 0.8,
	[1] = 0.85,
	[2] = 0.9,
	[3] = 0.95,
	[4] = 1.0,
	[5] = 1.05,
	[6] = 1.1,
	[7] = 1.15,
	[8] = 1.2,
	[9] = 1.25,
	[10] = 1.3,
}

local _toolsForSale = {
	{ id = 1, item = "meth_pipe", price = 500, qty = 100, vpn = false },
}

AddEventHandler("Labor:Server:Startup", function()
	exports['pulsar-pedinteraction']:VendorCreate("CornerDealer", false, "Unknown", false, {}, _toolsForSale,
		"fas fa-money-bill", "View Offers", false, false,
		true)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:Enable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if not hasValue(states, "SCRIPT_CORNER_DEALING") then
			table.insert(states, "SCRIPT_CORNER_DEALING")
			char:SetData("States", states)
			exports['pulsar-phone']:NotificationAdd(
				source,
				"New Job Available",
				"A new job is available, check it out.",
				os.time(),
				6000,
				"labor",
				{}
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:Disable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if hasValue(states, "SCRIPT_CORNER_DEALING") then
			for k, v in ipairs(states) do
				if v == "SCRIPT_CORNER_DEALING" then
					table.remove(states, k)
					char:SetData("States", states)
					break
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:SyncPed", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]].state == 1 then
					_sellers[_joiners[source]].pedNet = data

					local ent = NetworkGetEntityFromNetworkId(data)
					SetEntityDistanceCullingRadius(ent, 5000.0)

					exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
						string.format("CornerDealing:Client:%s:SyncPed", _joiners[source]), data)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:SyncEvent", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]].state == 0 then
					TriggerClientEvent(
						"CornerDealing:Client:DoSequence",
						NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(data.netId)),
						data.event,
						data.netId,
						data.coords
					)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:CheckCorner", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)

			if char ~= nil then
				for k, v in ipairs(_cornerCds) do
					if os.time() < v.expires and #(data.coords - v.coords) < 100.0 then
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Has Recently Sold Around Here")
						return cb(false)
					end
				end

				table.insert(_cornerCds, {
					expires = os.time() + (60 * 60 * 2),
					coords = data.coords,
				})

				return cb(true)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:StartCornering", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)

			if char ~= nil then
				if _sellers[_joiners[source]].state == 0 then
					_sellers[_joiners[source]].state = 1
					_sellers[_joiners[source]].netId = data.netId
					_sellers[_joiners[source]].corner = data.corner
					exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Sell Product", 10)
					exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
						string.format("CornerDealing:Client:%s:StartSelling", _joiners[source]), data.netId, data.corner)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:StopCornering", function(source, data, cb)
		if _joiners[source] ~= nil then
			exports['pulsar-labor']:FailOffer(_joiners[source], _JOB)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:GetSaleMenu", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)

			if char ~= nil then
				if
					_sellers[_joiners[source]].state == 1
					and _sellers[_joiners[source]].pedNet ~= nil
					and _sellers[_joiners[source]].pedNet == data.netId
				then
					local ent = NetworkGetEntityFromNetworkId(data.netId)
					local entState = Entity(ent).state

					if not entState.seller or entState.seller == source then
						entState.seller = source
						local items = {}

						local weedCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "weed_baggy")
						if weedCount > 0 then
							table.insert(items, {
								label = "Sell Weed",
								description = "Requires 1x Baggy of Weed",
								event = "CornerDealing:Client:Sell",
								data = "weed_baggy",
							})
						end

						local oxyCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "oxy")
						if oxyCount > 0 then
							table.insert(items, {
								label = "Sell Oxy",
								description = "Requires 1x OxyContin",
								event = "CornerDealing:Client:Sell",
								data = "oxy",
							})
						end

						local methCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "meth_bag")
						if methCount > 0 then
							table.insert(items, {
								label = "Sell Meth",
								description = "Requires 1x Bag of Meth",
								event = "CornerDealing:Client:Sell",
								data = "meth_bag",
							})
						end

						local cokeCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "coke_bag")
						if cokeCount > 0 then
							table.insert(items, {
								label = "Sell Cocaine",
								description = "Requires 1x Bag of Coke",
								event = "CornerDealing:Client:Sell",
								data = "coke_bag",
							})
						end

						cb(items)
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

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:DoSale", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if
					_sellers[_joiners[source]].state == 1
					and _sellers[_joiners[source]].pedNet ~= nil
					and _sellers[_joiners[source]].pedNet == data.netId
				then
					local ent = NetworkGetEntityFromNetworkId(data.netId)
					local entState = Entity(ent).state

					if entState?.seller == source then
						local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), data.item, 1)
						if slot ~= nil then
							if exports.ox_inventory:RemoveId(char:GetData("SID"), 1, slot) then
								local itemData = exports.ox_inventory:ItemsGetData(data.item)

								exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
									string.format("CornerDealing:Client:%s:Action", _joiners[source]))

								local repLevel = exports['pulsar-characters']:RepGetLevel(source, "CornerDealing") or 0
								local calcLvl = repLevel
								if calcLvl < 1 then
									calcLvl = 1
								end

								local repAdd = 50
								if data.item == "weed_baggy" then
									repAdd = 25
								end

								if data.item == "meth_bag" or data.item == "coke_bag" then
									local cashAdd = (itemData.price + (60 * calcLvl)) * (slot.Quality / 100)
									-- print((itemData.price + (60 * calcLvl)), (slot.Quality / 100), cashAdd)
									exports['pulsar-finance']:WalletModify(source, cashAdd)
								else
									local rand = math.random(100)
									if rand >= (55 - (2 * calcLvl)) then
										local lower, higher = calcLvl, calcLvl * 2
										if data.item == "weed_baggy" then
											lower = math.ceil((itemData.price * (2 + calcLvl)) / 100)
											higher = math.ceil((itemData.price * (4 + calcLvl)) / 100)
										end
										exports.ox_inventory:AddItem(char:GetData("SID"), "moneyroll",
											math.random(lower, higher),
											{}, 1)
									else
										local cashAdd = itemData.price + (60 * calcLvl)
										if data.item == "weed_baggy" then
											cashAdd = (itemData.price * 2) + (60 * calcLvl)
										end

										exports['pulsar-finance']:WalletModify(source, cashAdd)
									end
								end

								exports['pulsar-characters']:RepAdd(source, _JOB, repAdd)

								exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
									string.format("CornerDealing:Client:%s:RemoveTargetting", _joiners[source]))

								if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
									if _sellers[_joiners[source]].pedNet ~= nil then
										local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pedNet)
										if DoesEntityExist(ent) then
											SetEntityDistanceCullingRadius(ent, 0.0)
											Entity(ent).state.cornering = false
										end
									end
									_sellers[_joiners[source]].state = 0
									_sellers[_joiners[source]].pedNet = nil
									_sellers[_joiners[source]].netId = nil
									exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Find A Corner")
									SetTimeout(5000, function()
										exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
											string.format("CornerDealing:Client:%s:EndSelling", _joiners[source]))
									end)
								else
									SetTimeout((math.random(15, 30) + 30) * 1000, function()
										if _joiners[source] ~= nil then
											exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
												string.format("CornerDealing:Client:%s:SoldToPed", _joiners[source]))
										end
									end)
								end

								entState.seller = nil
								cb(true)
							else
								cb(false)
							end
						else
							cb(false)
						end
					else
						cb(false)
					end
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:NoPeds", function(source, data, cb)
		if _joiners[source] ~= nil and _sellers[_joiners[source]] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]]?.state == 1 then
					-- This shouldn't be possible, but yano yeah
					if _sellers[_joiners[source]].pedNet ~= nil then
						local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pedNet)
						if DoesEntityExist(ent) then
							SetEntityDistanceCullingRadius(ent, 0.0)
							Entity(ent).state.cornering = false
						end
					end

					_sellers[_joiners[source]].state = 0
					_sellers[_joiners[source]].pedNet = nil
					_sellers[_joiners[source]].netId = nil
					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Find A Corner")
					exports['pulsar-phone']:NotificationAdd(
						source,
						"New Corner",
						"Seems this corner dried up, find something else.",
						os.time(),
						6000,
						"labor",
						{}
					)
					exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
						string.format("CornerDealing:Client:%s:EndSelling", _joiners[source]))
				end
			end
		end
	end)

	-- exports["pulsar-core"]:RegisterServerCallback("CornerDealing:PedDied", function(source, data, cb)
	-- 	if _joiners[source] ~= nil then
	-- 		local plyr = exports['pulsar-core']:FetchSource(source)
	-- 		if plyr ~= nil then
	-- 			local char = plyr:GetData("Character")
	-- 			if char ~= nil then
	-- 				if _sellers[_joiners[source]].state == 1 then
	-- 					_sellers[_joiners[source]].pedNet = nil
	-- 					TriggerClientEvent(string.format("CornerDealing:Client:%s:PedDied", _joiners[source]), -1)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:DestroyVehicle", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]].state == 1 then
					if _sellers[_joiners[source]].pedNet ~= nil then
						local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pedNet)
						if DoesEntityExist(ent) then
							SetEntityDistanceCullingRadius(ent, 0.0)
							Entity(ent).state.cornering = false
						end
					end

					_sellers[_joiners[source]].state = 0
					_sellers[_joiners[source]].pedNet = nil
					_sellers[_joiners[source]].netId = nil
					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Find A Corner")
					exports['pulsar-phone']:NotificationAdd(
						source,
						"New Corner",
						"Your vehicle was destroyed, find something new and head to a new corner.",
						os.time(),
						6000,
						"labor",
						{}
					)
					TriggerClientEvent(string.format("CornerDealing:Client:%s:EndSelling", _joiners[source]), -1)
					cb(true)
				else
					cb(false)
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:PedTimeout", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]].state == 1 then
					if _sellers[_joiners[source]].pedNet ~= nil then
						local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pedNet)
						if DoesEntityExist(ent) then
							SetEntityDistanceCullingRadius(ent, 0.0)
						end
					end

					_sellers[_joiners[source]].pedNet = nil
					TriggerClientEvent(string.format("CornerDealing:Client:%s:PedTimeout", _joiners[source]), -1)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("CornerDealing:LeaveArea", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if _sellers[_joiners[source]].state == 1 then
					if _sellers[_joiners[source]].pedNet ~= nil then
						local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pedNet)
						if DoesEntityExist(ent) then
							SetEntityDistanceCullingRadius(ent, 0.0)
							Entity(ent).state.cornering = false
						end
					end
					_sellers[_joiners[source]].state = 0
					_sellers[_joiners[source]].pedNet = nil
					_sellers[_joiners[source]].netId = nil
					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Find A Corner")
					exports['pulsar-phone']:NotificationAdd(
						source,
						"New Corner",
						"Your vehicle got too far from the corner, find another place to sell.",
						os.time(),
						6000,
						"labor",
						{}
					)
					TriggerClientEvent(string.format("CornerDealing:Client:%s:EndSelling", _joiners[source]), -1)
				end
			end
		end
	end)
end)

AddEventHandler("CornerDealing:Server:OnDuty", function(joiner, members, isWorkgroup)
	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	if char == nil then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		return
	end

	_joiners[joiner] = joiner
	_sellers[joiner] = {
		joiner = joiner,
		members = members,
		isWorkgroup = isWorkgroup,
		started = os.time(),
		state = 0,
	}

	char:SetData("TempJob", _JOB)
	TriggerClientEvent("CornerDealing:Client:OnDuty", joiner, joiner, os.time())

	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			TriggerClientEvent("CornerDealing:Client:OnDuty", v.ID, joiner, os.time())
		end
	end

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Find A Corner")
end)

AddEventHandler("CornerDealing:Server:OffDuty", function(source, joiner)
	_joiners[source] = nil
	TriggerClientEvent("CornerDealing:Client:OffDuty", source)
end)

AddEventHandler("CornerDealing:Server:FinishJob", function(joiner)
	if _sellers[joiner] ~= nil then
		if _sellers[joiner].netId ~= nil then
			Entity(NetworkGetEntityFromNetworkId(_sellers[joiner].netId)).state.cornering = false
		end
	end
end)

AddEventHandler("CornerDealing:Server:CancelJob", function(joiner)
	if _sellers[joiner] ~= nil then
		if _sellers[joiner].netId ~= nil then
			Entity(NetworkGetEntityFromNetworkId(_sellers[joiner].netId)).state.cornering = false
		end
	end
end)
