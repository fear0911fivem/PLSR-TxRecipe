local _JOB = "WeedRun"

local _joiners = {}
local _sellers = {}

AddEventHandler("Labor:Server:Startup", function()
	exports['pulsar-core']:WaitListCreate("weedrun", "individual_time", {
		event = "Labor:Server:WeedRun:Queue",
		delay = (1000 * 60) * 3,
	})

	exports["pulsar-core"]:RegisterServerCallback("WeedRun:Enable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if not hasValue(states, "SCRIPT_WEED_RUN") then
			table.insert(states, "SCRIPT_WEED_RUN")
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

	exports["pulsar-core"]:RegisterServerCallback("WeedRun:Disable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if hasValue(states, "SCRIPT_WEED_RUN") then
			for k, v in ipairs(states) do
				if v == "SCRIPT_WEED_RUN" then
					table.remove(states, k)
					char:SetData("States", states)
					break
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("WeedRun:StartDropoff", function(source, data, cb)
		if _joiners[source] ~= nil then
			TriggerEvent("EmergencyAlerts:Server:ServerDoPredefined", source, "oxysale")
			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("WeedRun:DoDropoff", function(source, data, cb)
		if _joiners[source] ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if exports.ox_inventory:Remove(char:GetData("SID"), 1, "weed_brick", 1) then
					local repLevel = exports['pulsar-characters']:RepGetLevel(source, "WeedRun") or 0
					local calcLvl = repLevel
					if calcLvl < 1 then
						calcLvl = 1
					end

					local itemData = exports.ox_inventory:ItemsGetData("weed_brick")

					local rand = math.random(100)
					if rand >= (100 - (3 * calcLvl)) then
						exports.ox_inventory:AddItem(char:GetData("SID"), "moneyband",
							math.random(8, 10 + calcLvl), {}, 1)
					elseif rand >= (55 - (2 * calcLvl)) then
						exports.ox_inventory:AddItem(
							char:GetData("SID"),
							"moneyroll",
							math.random(90, 100 + (2 * calcLvl)),
							{},
							1
						)
					else
						exports['pulsar-finance']:WalletModify(source, itemData.price + (30 * calcLvl))
					end

					_sellers[_joiners[source]].state = 2
					_offers[_joiners[source]].noExpire = true

					for k, v in pairs(_Jobs[_JOB].OnDuty) do
						if v.Joiner == _joiners[source] then
							if v.Group then
								for k2, v2 in pairs(_Groups) do
									if v2.Creator.ID == _joiners[source] then
										for k3, v3 in ipairs(v2.Members) do
											exports['pulsar-labor']:CompleteOffer(v3.ID, _JOB)
										end
									end
								end
							end

							exports['pulsar-labor']:CompleteOffer(_joiners[source], _JOB)
						end
					end

					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Wait For Next Delivery")
					exports['pulsar-core']:WaitListInteractInactive("weedrun", _joiners[source])

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
end)

AddEventHandler("WeedRun:Server:OnDuty", function(joiner, members, isWorkgroup)
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

	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	char:SetData("TempJob", _JOB)
	TriggerClientEvent("WeedRun:Client:OnDuty", joiner, joiner, os.time())

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Wait For A Delivery")
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			TriggerClientEvent("WeedRun:Client:OnDuty", v.ID, joiner, os.time())
		end
	end

	_offers[joiner].noExpire = true
	exports['pulsar-core']:WaitListInteractAdd("weedrun", joiner, {
		joiner = joiner,
	})
end)

AddEventHandler("WeedRun:Server:OffDuty", function(source, joiner)
	exports['pulsar-core']:WaitListInteractRemove("weedrun", _joiners[source])
	_joiners[source] = nil
	TriggerClientEvent("WeedRun:Client:OffDuty", source)
end)

AddEventHandler("Labor:Server:WeedRun:Queue", function(source, data)
	if _joiners[source] ~= nil then
		_sellers[_joiners[source]].state = 1
		_sellers[_joiners[source]].location = _weedSaleLocations[math.random(#_weedSaleLocations)]
		_offers[_joiners[source]].noExpire = false
		exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Deliver The Package")
		exports['pulsar-labor']:SendWorkgroupEvent(
			_joiners[source],
			string.format("WeedRun:Client:%s:Receive", _joiners[source]),
			_sellers[_joiners[source]].location,
			PedModels[math.random(#PedModels)]
		)
	end

	exports['pulsar-core']:WaitListInteractActive("weedrun", _joiners[source])
end)
