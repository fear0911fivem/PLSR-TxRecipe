local _JOB = "OxyRun"

local _joiners = {}
local _sellers = {}
local _cooldowns = {}

local _oxyCars = {}

local _loot = {}

local _wasDoingIllegalShit = {}

local _availableRuns = 10
CreateThread(function()
	while true do
		Wait(1000 * 60 * 60)
		_availableRuns += math.random(2, 5)
	end
end)

AddEventHandler("Labor:Server:Startup", function()
	exports['pulsar-core']:WaitListCreate("oxyrun", "individual_time", {
		event = "Labor:Server:OxyRun:Queue",
		delay = (1000 * 60) * 5,
		-- min = 10000,
		-- max = 12000,
	})

	exports["pulsar-chat"]:RegisterAdminCommand("addoxyrun", function(source, args, rawCommand)
		if tonumber(args[1]) then
			_availableRuns = _availableRuns + tonumber(args[1])
		else
			return exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Amount")
		end
	end, {
		help = "Add Available Oxy Runs",
		params = {
			{
				name = "Number",
				help = "Number of Oxy Runs To Add To Available Pool",
			},
		},
	}, 1)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:Enable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if not hasValue(states, "SCRIPT_OXY_RUN") then
			table.insert(states, "SCRIPT_OXY_RUN")
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

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:Disable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if hasValue(states, "SCRIPT_OXY_RUN") then
			for k, v in ipairs(states) do
				if v == "SCRIPT_OXY_RUN" then
					table.remove(states, k)
					char:SetData("States", states)
					break
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:EnteredCar", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state == 1
		then
			if not exports['pulsar-vehicles']:OwnedGetActive(data.VIN) then
				if #exports.ox_inventory:GetFreeSlotNumbers(data.VIN, 4, data.Class, data.Model) >= 10 then
					local exp = os.time() + (60 * 20)
					_cooldowns[char:GetData("ID")] = exp
					if isWorkgroup then
						if #members > 0 then
							for k, v in ipairs(members) do
								_cooldowns[v.CharID] = exp
							end
						end
					end

					_sellers[_joiners[source]].vehicle = data
					_sellers[_joiners[source]].state = 2
					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Go To The Pickup Location")

					CreateThread(function()
						local ending = false
						local ent = NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].vehicle.NetId)
						while _sellers[_joiners[source]] ~= nil do
							if not ending then
								if ent ~= nil and not DoesEntityExist(ent) then
									exports['pulsar-core']:LoggerTrace("OxyRun", "Vehicle No Longer Exists")
									ending = true
									exports['pulsar-labor']:SendWorkgroupEvent(
										_joiners[source],
										string.format("OxyRun:Client:%s:VehiclePoofed", _joiners[source])
									)
								end
							end
							Wait(10)
						end
					end)

					exports['pulsar-labor']:SendWorkgroupEvent(
						_joiners[source],
						string.format("OxyRun:Client:%s:StartPickup", _joiners[source]),
						_oxyPickups[_selectedOxyPickup],
						data
					)
				else
					exports['pulsar-phone']:NotificationAdd(
						_joiners[source],
						"Job Activity",
						"Not Enough Room In This Vehicles Trunk",
						os.time(),
						6000,
						"labor",
						{}
					)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:EnteredPickup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and (_sellers[_joiners[source]].state == 2 or _sellers[_joiners[source]].state == 3)
		then
			if _sellers[_joiners[source]].state == 2 then
				_sellers[_joiners[source]].state = 3
				exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Receive Product", 10)
			end
			exports['pulsar-labor']:SendWorkgroupEvent(
				_joiners[source],
				string.format("OxyRun:Client:%s:EligiblePickup", _joiners[source])
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:CancelPickup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("TempJob") == _JOB and _joiners[source] ~= nil and _sellers[_joiners[source]] ~= nil then
			exports.ox_inventory:Remove(_sellers[_joiners[source]].vehicle.VIN, 4, "contraband", false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:CheckPickup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state == 3
		then
			if
				#exports.ox_inventory:GetFreeSlotNumbers(
					_sellers[_joiners[source]].vehicle.VIN,
					4,
					_sellers[_joiners[source]].vehicle.Class,
					_sellers[_joiners[source]].vehicle.Model
				) >= 10
			then
				cb(true)
			else
				cb(false)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:PickupProduct", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state == 3
		then
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			local vEnt = Entity(veh).state
			if
				#exports.ox_inventory:GetFreeSlotNumbers(
					vEnt.VIN,
					4,
					_sellers[_joiners[source]].vehicle.Class,
					_sellers[_joiners[source]].vehicle.Model
				) >= 1
			then
				exports.ox_inventory:AddItem(
					vEnt.VIN,
					"contraband",
					1,
					{},
					4,
					_sellers[_joiners[source]].vehicle.Class,
					_sellers[_joiners[source]].vehicle.Model,
					veh
				)

				local exp = os.time() + (60 * 20)
				_cooldowns[char:GetData("ID")] = exp
				if _sellers[_joiners[source]].isWorkgroup then
					if #_sellers[_joiners[source]].members > 0 then
						for k, v in ipairs(_sellers[_joiners[source]].members) do
							_cooldowns[v.CharID] = exp
						end
					end
				end

				if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
					_sellers[_joiners[source]].state = 4
					local rand = math.random(#_oxyLocations)
					_sellers[_joiners[source]].location = rand

					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Head To The Sale Spot")
					exports['pulsar-labor']:SendWorkgroupEvent(
						_joiners[source],
						string.format("OxyRun:Client:%s:StartSale", _joiners[source]),
						_oxyLocations[rand]
					)
				end
			else
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:EnteredArea", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state == 4
		then
			_sellers[_joiners[source]].state = 5
			exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Wait For Buyers", 10)
			exports['pulsar-labor']:SendWorkgroupEvent(
				_joiners[source],
				string.format("OxyRun:Client:%s:Near", _joiners[source])
			)

			CreateThread(function()
				Wait(math.random(1, 2) * 60000)
				while
					_joiners[source] ~= nil
					and _sellers[_joiners[source]] ~= nil
					and _sellers[_joiners[source]].state == 5
				do
					if not _sellers[_joiners[source]].pending then
						local p = promise.new()

						local randPed = math.random(#PedModels)
						exports["pulsar-core"]:ClientCallback(_joiners[source], "OxyRun:GetSpawn", {
							veh = exports['pulsar-vehicles']:RandomModelDClass(),
							ped = PedModels[randPed],
						}, function(veh, ped)
							if veh then
								Entity(NetworkGetEntityFromNetworkId(veh)).state.oxyBuying = _joiners[source]
								_sellers[_joiners[source]].pending = {
									veh = veh,
									ped = ped,
								}
								exports['pulsar-labor']:SendWorkgroupEvent(
									_joiners[source],
									string.format("OxyRun:Client:%s:Spawn", _joiners[source]),
									_sellers[_joiners[source]].pending
								)
							else
								_sellers[_joiners[source]].pending = nil

								if ped and DoesEntityExist(ped) then
									DeleteEntity(NetworkGetNetworkIdFromEntity(ped))
								end
							end

							p:resolve(veh ~= nil)
						end)
						if Citizen.Await(p) then
							Wait(math.random(30) * 1000)
						else
							Wait(2000)
						end
					else
						Wait(5000)
					end
				end
			end)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:DeleteShit", function(source, data, cb)
		if _joiners[source] and _sellers[_joiners[source]].pending ~= nil then
			_sellers[_joiners[source]].cars[_sellers[_joiners[source]].pending.veh] = false
			DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.ped))
			DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.veh))
			_sellers[_joiners[source]].pending = nil
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:SellProduct", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state == 5
			and _sellers[_joiners[source]].pending ~= nil
			and not _sellers[_joiners[source]].cars[data]
		then
			_sellers[_joiners[source]].cars[data] = true

			local exp = os.time() + (60 * 20)
			_cooldowns[char:GetData("ID")] = exp
			if _sellers[_joiners[source]].isWorkgroup then
				if #_sellers[_joiners[source]].members > 0 then
					for k, v in ipairs(_sellers[_joiners[source]].members) do
						_cooldowns[v.CharID] = exp
					end
				end
			end

			if exports.ox_inventory:Remove(char:GetData("SID"), 1, "contraband", 1) then
				exports['pulsar-labor']:SendWorkgroupEvent(
					_joiners[source],
					string.format("OxyRun:Client:%s:Action", _joiners[source])
				)
				local c = deepcopy(_sellers[_joiners[source]].pending)
				Entity(NetworkGetEntityFromNetworkId(c.veh)).state.oxyBuying = nil

				local cashAdd = math.random(200) + 200

				if math.random(100) >= 80 then
					exports.ox_inventory:AddItem(char:GetData("SID"), "oxy", math.random(3), {}, 1)
				end

				local repLevel = exports['pulsar-characters']:RepGetLevel(source, "OxyRun") or 0
				local chance = 90

				if repLevel >= 5 then
					chance = 50
					if math.random(200) <= 1 then
						exports.ox_inventory:AddItem(char:GetData("SID"), "vpn", 1, {}, 1)
					end
				elseif repLevel >= 3 then
					chance = 70
				elseif repLevel >= 1 then
					chance = 82
				end

				local calcLvl = repLevel
				if calcLvl < 1 then
					calcLvl = 1
				end

				local rollCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "moneyroll")
				if rollCount > 0 then
					local rb = math.random(100)
					if rb >= chance then
						local take = math.random(2, (3 * calcLvl))
						if rollCount <= 5 or take > rollCount then
							take = rollCount
						end
						local itemData = exports.ox_inventory:ItemsGetData("moneyroll")

						if itemData and exports.ox_inventory:Remove(char:GetData("SID"), 1, "moneyroll", take) then
							cashAdd += (itemData.price * take)
						end
					end
				end

				local bandCount = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, "moneyband")
				if bandCount > 0 then
					local bb = math.random(100)
					if bb >= chance then
						local take = math.random(1, (2 * calcLvl))
						if bandCount <= 3 or take > bandCount then
							take = bandCount
						end
						local itemData = exports.ox_inventory:ItemsGetData("moneyband")

						if itemData and exports.ox_inventory:Remove(char:GetData("SID"), 1, "moneyband", take) then
							cashAdd += (itemData.price * take)
						end
					end
				end

				exports['pulsar-finance']:WalletModify(source, math.floor(cashAdd * 0.7))

				if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
					_sellers[_joiners[source]].state = 6
					exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Dump & Destroy The Vehicle")
					exports['pulsar-labor']:SendWorkgroupEvent(
						_joiners[source],
						string.format("OxyRun:Client:%s:EndSale", _joiners[source])
					)
				end

				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:DestroyVehicle", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("TempJob") == _JOB and _joiners[source] ~= nil and _sellers[_joiners[source]] ~= nil then
			if _sellers[_joiners[source]].state == 6 then
				_sellers[_joiners[source]].state = 7
				exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
			else
				exports['pulsar-phone']:NotificationAdd(
					_joiners[source],
					"Job Activity",
					"Vehicle Was Destroyed",
					os.time(),
					6000,
					"labor",
					{}
				)

				if _sellers[_joiners[source]].isWorkgroup then
					if #_sellers[_joiners[source]].members > 0 then
						for k, v in ipairs(_sellers[_joiners[source]].members) do
							exports['pulsar-phone']:NotificationAdd(
								v.ID,
								"Job Activity",
								"Vehicle Was Destroyed",
								os.time(),
								6000,
								"labor",
								{}
							)
						end
					end
				end

				exports['pulsar-labor']:FailOffer(_joiners[source], _JOB)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:VehiclePoofed", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("TempJob") == _JOB and _joiners[source] ~= nil and _sellers[_joiners[source]] ~= nil then
			if _sellers[_joiners[source]].state == 6 then
				_sellers[_joiners[source]].state = 7
				exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
			else
				exports['pulsar-phone']:NotificationAdd(
					_joiners[source],
					"Job Activity",
					"Vehicle Was Lost",
					os.time(),
					6000,
					"labor",
					{}
				)

				if _sellers[_joiners[source]].isWorkgroup then
					if #_sellers[_joiners[source]].members > 0 then
						for k, v in ipairs(_sellers[_joiners[source]].members) do
							exports['pulsar-phone']:NotificationAdd(
								v.ID,
								"Job Activity",
								"Vehicle Was Lost",
								os.time(),
								6000,
								"labor",
								{}
							)
						end
					end
				end

				if _sellers[_joiners[source]].pending ~= nil then
					_sellers[_joiners[source]].cars[NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.veh)] = false
					DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.ped))
					DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.veh))
				end

				exports['pulsar-labor']:FailOffer(_joiners[source], _JOB)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("OxyRun:LeftZone", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _joiners[source] == source
			and _sellers[_joiners[source]] ~= nil
			and _sellers[_joiners[source]].state < 6
		then
			exports['pulsar-phone']:NotificationAdd(
				_joiners[source],
				"Job Activity",
				"You Left The Sale Area",
				os.time(),
				6000,
				"labor",
				{}
			)

			if _sellers[_joiners[source]].isWorkgroup then
				if #_sellers[_joiners[source]].members > 0 then
					for k, v in ipairs(_sellers[_joiners[source]].members) do
						exports['pulsar-phone']:NotificationAdd(
							v.ID,
							"Job Activity",
							"You Left The Sale Area",
							os.time(),
							6000,
							"labor",
							{}
						)
					end
				end
			end

			if _sellers[_joiners[source]].pending ~= nil then
				_sellers[_joiners[source]].cars[NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.veh)] = false
				DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.ped))
				DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[_joiners[source]].pending.veh))
			end

			exports['pulsar-labor']:FailOffer(_joiners[source], _JOB)
		end
	end)
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	if _wasDoingIllegalShit[source] then
		if cData ~= nil then
			exports.ox_inventory:Remove(cData.SID, 1, "contraband", false, true)
		end
		_wasDoingIllegalShit[source] = nil
	end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	if _wasDoingIllegalShit[source] then
		if cData ~= nil then
			exports.ox_inventory:Remove(cData.SID, 1, "contraband", false, true)
		end
		_wasDoingIllegalShit[source] = nil
	end
end)

AddEventHandler("Labor:Server:OxyRun:Queue", function(source, data)
	if _joiners[source] ~= nil then
		if _availableRuns <= 0 then
			exports['pulsar-labor']:CancelOffer(_joiners[source], _JOB)
			exports['pulsar-labor']:OffDuty(_JOB, _joiners[source], false, true)
			exports['pulsar-phone']:NotificationAdd(
				_joiners[source],
				"Job Activity",
				"Sorry, ran out of jobs",
				os.time(),
				6000,
				"labor",
				{}
			)
			if isWorkgroup then
				if #_sellers[_joiners[source]].members > 0 then
					for k, v in ipairs(members) do
						exports['pulsar-phone']:NotificationAdd(
							v.ID,
							"Job Activity",
							"Sorry, ran out of jobs",
							os.time(),
							6000,
							"labor",
							{}
						)
					end
				end
			end
			return
		end

		_sellers[_joiners[source]].state = 1
		_offers[_joiners[source]].noExpire = false
		exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Find A Vehicle")
		TriggerClientEvent(string.format("OxyRun:Client:%s:Receive", _joiners[source]), -1)
	end

	exports['pulsar-core']:WaitListInteractRemove("oxyrun", source)
end)

AddEventHandler('entityRemoved', function(entity)
	if GetEntityType(entity) == 2 then
		local ent = Entity(entity)
		if ent?.state?.oxyBuying and _sellers[ent?.state?.oxyBuying]?.pending then
			exports['pulsar-core']:LoggerWarn("Vehicles",
				string.format("Oxy Vehicle For %s Deleted Unexpectedly, Clearing To Spawn New Vehicle",
					ent?.state?.oxyBuying))
			_sellers[_joiners[source]].cars[NetworkGetEntityFromNetworkId(_sellers[ent?.state?.oxyBuying].pending.veh)] = false
			DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[ent?.state?.oxyBuying].pending.ped))
			DeleteEntity(NetworkGetEntityFromNetworkId(_sellers[ent?.state?.oxyBuying].pending.veh))
			_sellers[ent?.state?.oxyBuying].pending = nil
		end
	end
end)

AddEventHandler("OxyRun:Server:OnDuty", function(joiner, members, isWorkgroup)
	if _availableRuns <= 0 then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		exports['pulsar-phone']:NotificationAdd(joiner, "Job Activity", "No Jobs Available", os.time(), 6000,
			"labor", {})
		if isWorkgroup then
			if #members > 0 then
				for k, v in ipairs(members) do
					exports['pulsar-phone']:NotificationAdd(
						v.ID,
						"Job Activity",
						"No Jobs Available",
						os.time(),
						6000,
						"labor",
						{}
					)
				end
			end
		end
		return
	end

	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	if char == nil then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		return
	end

	if (_cooldowns[char:GetData("ID")] or 0) > os.time() then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		exports['pulsar-phone']:NotificationAdd(
			joiner,
			"Job Activity",
			"Not Eligible For Another Run",
			os.time(),
			6000,
			"labor",
			{}
		)
		if isWorkgroup then
			if #members > 0 then
				for k, v in ipairs(members) do
					exports['pulsar-phone']:NotificationAdd(
						v.ID,
						"Job Activity",
						"Your Group Is Not Eligible For Another Run. Please Wait",
						os.time(),
						6000,
						"labor",
						{}
					)
				end
			end
		end

		return
	elseif isWorkgroup then
		if #members > 0 then
			for k, v in ipairs(members) do
				if (_cooldowns[v.CharID] or 0) > os.time() then
					exports['pulsar-labor']:CancelOffer(joiner, _JOB)
					exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
					exports['pulsar-phone']:NotificationAdd(
						joiner,
						"Job Activity",
						"Cannot Give You A Job With This Group. Please Wait",
						os.time(),
						6000,
						"labor",
						{}
					)
					if isWorkgroup then
						if #members > 0 then
							for k2, v2 in ipairs(members) do
								if v.ID == v2.ID then
									exports['pulsar-phone']:NotificationAdd(
										v2.ID,
										"Job Activity",
										"Not Eligible For Another Run. Please Wait",
										os.time(),
										6000,
										"labor",
										{}
									)
								else
									exports['pulsar-phone']:NotificationAdd(
										v2.ID,
										"Job Activity",
										"Your Group Is Not Eligible For Another Run. Please Wait",
										os.time(),
										6000,
										"labor",
										{}
									)
								end
							end
						end
					end

					return
				end
			end
		end
	end

	_joiners[joiner] = joiner
	_sellers[joiner] = {
		joiner = joiner,
		members = members,
		isWorkgroup = isWorkgroup,
		started = os.time(),
		cars = {},
		state = 0,
	}

	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	char:SetData("TempJob", _JOB)
	TriggerClientEvent("OxyRun:Client:OnDuty", joiner, joiner, os.time())
	_wasDoingIllegalShit[joiner] = true

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Wait For A Job")
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			TriggerClientEvent("OxyRun:Client:OnDuty", v.ID, joiner, os.time())
			_wasDoingIllegalShit[v.ID] = true
		end
	end

	_offers[joiner].noExpire = true
	exports['pulsar-core']:WaitListInteractAdd("oxyrun", joiner, {
		joiner = joiner,
	})
end)

AddEventHandler("OxyRun:Server:OffDuty", function(source, joiner)
	exports['pulsar-core']:WaitListInteractRemove("oxyrun", _joiners[source])
	_joiners[source] = nil
	TriggerClientEvent("OxyRun:Client:OffDuty", source)
end)

function Cleanup(src)
	local joiner = src
	if _sellers[joiner] ~= nil then
		if _sellers[joiner].isWorkgroup then
			if #_sellers[joiner].members > 0 then
				for k, v in ipairs(_sellers[joiner].members) do
					local mChar = exports['pulsar-characters']:FetchCharacterSource(v.ID)
					if mChar ~= nil then
						exports.ox_inventory:Remove(mChar:GetData("SID"), 1, "contraband", false)
					end
				end
			end
		end

		local jChar = exports['pulsar-characters']:FetchCharacterSource(joiner)
		if jChar ~= nil then
			exports.ox_inventory:Remove(jChar:GetData("SID"), 1, "contraband", false)
		end

		if _sellers[joiner].vehicle ~= nil then
			exports.ox_inventory:Remove(_sellers[joiner].vehicle.VIN, 4, "contraband", false)
		end

		_availableRuns = _availableRuns - 1
		_sellers[joiner] = nil
	end
end

AddEventHandler("OxyRun:Server:FinishJob", Cleanup)
AddEventHandler("OxyRun:Server:CancelJob", Cleanup)
