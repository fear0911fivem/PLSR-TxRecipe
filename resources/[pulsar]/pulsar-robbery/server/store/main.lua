local _st = RobberyConfig.store

local _storeLocs    = _st.locations
local _safes        = _st.safes
local _registerLoot = _st.registerLoot
local _safeLoot     = _st.safeLoot

_storeAlerts = {}
_registers = {}
_robbedSafes = {}

local _storeInUse = {}

local _run = false
function Threads()
	if _run then
		return
	end
	_run = true

	CreateThread(function()
		while true do
			exports['pulsar-core']:LoggerTrace("Robbery", "Resetting Store Alert States With Expired Emergency Alerts")
			for k, v in pairs(_storeAlerts) do
				if v < os.time() then
					_storeAlerts[k] = nil
				end
			end
			Wait((1000 * 60) * 2)
		end
	end)
end

local _cRegisterCooldowns = {}

AddEventHandler("Robbery:Server:Setup", function()
	GlobalState["StoreRobberies"] = _storeLocs
	GlobalState["StoreSafes"] = _safes

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:Register", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		local d = GlobalState[string.format("Register:%s:%s", data.coords[1], data.coords[2])]
		if
			char
			and d ~= nil
			and d.source == source
			and (not _cRegisterCooldowns[source] or os.time() > _cRegisterCooldowns[source])
		then
			_cRegisterCooldowns[source] = os.time() + 5
			if data.results then
				exports.ox_inventory:LootCustomWeightedSetWithCount(_registerLoot, char:GetData("SID"), 1)
				exports['pulsar-finance']:WalletModify(source, (math.random(150) + 100))
				cb(true)
			else
				exports.ox_inventory:Remove(char:GetData("SID"), 1, "lockpick", 1)

				local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "lockpick", 1)
				if slot ~= nil then
					local itemData = exports.ox_inventory:ItemsGetData("lockpick")
					if type(itemData.durability) == 'number' then
						local newValue = slot.CreateDate - math.ceil(itemData.durability / 2)
						if success then
							newValue = slot.CreateDate - math.ceil(itemData.durability / 8)
						end
						if os.time() - itemData.durability >= newValue then
							exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
						else
							exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
						end
					end
				end

				if _storeAlerts[data.store] == nil or _storeAlerts[data.store] < os.time() then
					_storeAlerts[data.store] = (os.time() + (60 * 5))
					exports['pulsar-robbery']:TriggerPDAlert(source, _storeLocs[data.store].coords, "10-90",
						"Store Robbery", {
							icon = 628,
							size = 0.9,
							color = 31,
							duration = (60 * 5),
						}, {
							icon = "shop",
							details = "24/7",
						}, data.store)
				end
				cb(true)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:StartSafeCrack", function(source, data, cb)
		local pState = Player(source).state

		if pState.storePoly ~= nil then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char ~= nil then
				if
					GlobalState[string.format("Safe:%s", data.id)] == nil
					or os.time() > GlobalState[string.format("Safe:%s", data.id)].expires
				then
					if GlobalState["RestartLockdown"] ~= false and GetGameTimer() < _st.serverStartWait then
						exports['pulsar-hud']:Notification(source, "error",
							"You Notice The Register Has An Extra Lock On It Securing It For A Storm, Maybe Check Back Later",
							6000
						)
						return cb(false)
					elseif (GlobalState["Duty:police"] or 0) < _st.requiredPolice then
						exports['pulsar-hud']:Notification(source, "error",
							"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
							6000
						)
						return cb(false)
					elseif GlobalState["RobberiesDisabled"] then
						exports['pulsar-hud']:Notification(source, "error",
							"Temporarily Disabled, Please See City Announcements",
							6000
						)
						return cb(false)
					end

					if not _storeInUse[pState.storePoly] then
						_storeInUse[pState.storePoly] = source
						local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "safecrack_kit", 1)

						if slot ~= nil then
							local itemData = exports.ox_inventory:ItemsGetData(slot.Name)

							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Started Store Robbery (Safe) At Store %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									pState.storePoly
								)
							)

							exports["pulsar-core"]:ClientCallback(source, "Robbery:Store:DoSafeCrack", {
								passes = 1,
								config = {
									countdown = 3,
									preview = 2500,
									timer = 10000,
									passReduce = 300,
									base = 8,
									cols = 5,
									rows = 5,
									anim = false,
								},
								data = {},
							}, function(isSuccess, extra)
								local itemData = exports.ox_inventory:ItemsGetData("safecrack_kit")

								if type(itemData.durability) == 'number' then
									local newValue = slot.CreateDate - math.ceil(itemData.durability / 2)
									if os.time() - itemData.durability >= newValue then
										exports.ox_inventory:RemoveId(char:GetData("SID"), 1, slot)
									else
										exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
									end
								end

								if isSuccess then
									if
										_storeAlerts[pState.storePoly] == nil
										or _storeAlerts[pState.storePoly] < os.time()
									then
										_storeAlerts[pState.storePoly] = (os.time() + (60 * 5))
										exports['pulsar-robbery']:TriggerPDAlert(
											source,
											_storeLocs[pState.storePoly].coords,
											"10-90",
											"Store Robbery",
											{
												icon = 628,
												size = 0.9,
												color = 31,
												duration = (60 * 5),
											},
											{
												icon = "shop",
												details = "24/7",
											},
											pState.storePoly
										)
									end
									local obj = {
										expires = os.time() + (60 * math.random(3, 5)),
										id = data.id,
										poly = pState.storePoly,
										coords = data.coords,
										source = source,
										state = 1,
									}
									exports['pulsar-core']:LoggerTrace(
										"Robbery",
										string.format("Safe %s Will Unlock At %s", data.id, obj.expires)
									)
									_robbedSafes[data.id] = obj
									GlobalState[string.format("Safe:%s", data.id)] = obj
									GlobalState["StoreAntiShitlord"] = os.time() + (60 * math.random(5, 10))

									exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
									exports['pulsar-hud']:Notification(source, "success",
										"Lock Disengage Initiated, Please Stand By",
										6000
									)
								else
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
								end

								_storeInUse[data.id] = nil
							end)
						else
							_storeInUse[data.id] = nil
							exports['pulsar-hud']:Notification(source, "error",
								"Unable To Crack Safe, Do you have a working safe cracking kit?",
								6000
							)
						end
					else
						_storeInUse[data.id] = nil
						exports['pulsar-hud']:Notification(source, "error",
							"Unable To Crack Safe, Is Someone Already Doing It?",
							6000
						)
					end
				else
					exports['pulsar-hud']:Notification(source, "error", "Unable To Crack Safe", 6000)
				end
			end
		end

		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:StartSafeSequence", function(source, data, cb)
		if GlobalState["RestartLockdown"] ~= false and GetGameTimer() < _st.serverStartWait then
			exports['pulsar-hud']:Notification(source, "error",
				"You Notice The Register Has An Extra Lock On It Securing It For A Storm, Maybe Check Back Later",
				6000
			)
			return cb(false)
		elseif (GlobalState["Duty:police"] or 0) < _st.requiredPolice then
			exports['pulsar-hud']:Notification(source, "error",
				"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
				6000
			)
			return cb(false)
		elseif GlobalState["RobberiesDisabled"] then
			exports['pulsar-hud']:Notification(source, "error",
				"Temporarily Disabled, Please See City Announcements", 6000)
			return cb(false)
		end

		cb(true)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:StartLockpick", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				GlobalState[string.format("Register:%s:%s", data.x, data.y)] == nil
				and not GlobalState["RestartLockdown"]
			then
				if GlobalState["RestartLockdown"] ~= false and GetGameTimer() < _st.serverStartWait then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Register Has An Extra Lock On It Securing It For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif (GlobalState["Duty:police"] or 0) < _st.requiredPolice then
					exports['pulsar-hud']:Notification(source, "error",
						"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
						6000
					)
					return
				elseif GlobalState["RobberiesDisabled"] then
					exports['pulsar-hud']:Notification(source, "error",
						"Temporarily Disabled, Please See City Announcements",
						6000
					)
					return
				end

				local obj = {
					expires = (os.time() + 60 * math.random(20, 40)),
					coords = data,
					source = source,
				}
				exports['pulsar-core']:LoggerInfo(
					"Robbery",
					string.format(
						"%s %s (%s) Started Store Robbery (Register) At Store %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						Player(source).state.storePoly
					)
				)
				table.insert(_registers, obj)
				GlobalState[string.format("Register:%s:%s", data.x, data.y)] = obj
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:Safe", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if GlobalState[string.format("Safe:%s", data.id)] == nil and not GlobalState["RestartLockdown"] then
			if GlobalState["RestartLockdown"] ~= false and GetGameTimer() < _st.serverStartWait then
				exports['pulsar-hud']:Notification(source, "error",
					"You Notice The Register Has An Extra Lock On It Securing It For A Storm, Maybe Check Back Later",
					6000
				)
				return
			elseif (GlobalState["Duty:police"] or 0) < _st.requiredPolice then
				exports['pulsar-hud']:Notification(source, "error",
					"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
					6000
				)
				return
			elseif GlobalState["RobberiesDisabled"] then
				exports['pulsar-hud']:Notification(source, "error",
					"Temporarily Disabled, Please See City Announcements",
					6000
				)
				return
			elseif GlobalState["StoreAntiShitlord"] ~= nil and GlobalState["StoreAntiShitlord"] > os.time() then
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Security Measures Engaged, Come Back Later",
					6000
				)
				return
			end

			local state = -1
			if data.results then
				state = 1
				cb(true)
				exports['pulsar-hud']:Notification(source, "success",
					"Lock Disengage Initiated, Please Stand By", 6000)
			else
				-- Do something?
				cb(true)
				exports['pulsar-hud']:Notification(source, "error",
					"You've Damaged The Electronics On The Lock", 6000)
			end
			if _storeAlerts[data.store] == nil or _storeAlerts[data.store] < os.time() then
				exports['pulsar-core']:LoggerInfo(
					"Robbery",
					string.format(
						"%s %s (%s) Started Store Robbery (Safe) At Store %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						data.store
					)
				)
				_storeAlerts[data.store] = (os.time() + (60 * 5))
				exports['pulsar-robbery']:TriggerPDAlert(source, _storeLocs[data.store].coords, "10-90", "Store Robbery",
					{
						icon = 628,
						size = 0.9,
						color = 31,
						duration = (60 * 5),
					}, {
						icon = "shop",
						details = "24/7",
					}, data.store)
			end
			local obj = {
				expires = (os.time() + 60 * 5),
				id = data.id,
				poly = string.format("store%s", data.id),
				coords = data.coords,
				source = source,
				state = state,
			}
			exports['pulsar-core']:LoggerTrace("Robbery",
				string.format("Safe %s Will Unlock At %s", data.id, obj.expires))
			_robbedSafes[data.id] = obj
			GlobalState[string.format("Safe:%s", data.id)] = obj
			GlobalState["StoreAntiShitlord"] = os.time() + (60 * math.random(5, 10))
		else
			exports['pulsar-core']:LoggerError("Robbery", string.format("Safe %s Was Already Cracked", data.id))
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:LootSafe", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if _robbedSafes[data.id] ~= nil and _robbedSafes[data.id].state == 2 then
			_robbedSafes[data.id].state = 3
			_robbedSafes[data.id].expires = (os.time() + 60 * math.random(30, 60))
			GlobalState[string.format("Safe:%s", data.id)] = _robbedSafes[data.id]

			exports.ox_inventory:LootCustomWeightedSetWithCount(_safeLoot, char:GetData("SID"), 1)

			if math.random(100) <= 5 then
				exports.ox_inventory:AddItem(char:GetData("SID"), "green_dongle", 1, {}, 1)
				exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
					CryptoCoin = "HEIST",
					Quantity = 2,
				}, 1)
			elseif math.random(100) <= 15 then
				exports.ox_inventory:AddItem(char:GetData("SID"), "gps_tracker", 1, {}, 1)
			end

			exports['pulsar-core']:LoggerInfo(
				"Robbery",
				string.format(
					"%s %s (%s) Looted %s Safe",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					data.id
				)
			)
			exports['pulsar-finance']:WalletModify(source, (math.random(3000) + 2000))
			exports["pulsar-sounds"]:StopLocation(_robbedSafes[data.id].source, _robbedSafes[data.id].coords, "alarm")
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Store:SecureSafe", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local myDuty = Player(source).state.onDuty

			if myDuty and myDuty == "police" then
				if _robbedSafes[data.id] ~= nil and _robbedSafes[data.id].state ~= 4 then
					if _robbedSafes[data.id].state == 1 then
						exports["pulsar-chat"]:SendServerSingle(source,
							"Safe Was Cracked, But Timelock Was Still Engaged")
					elseif _robbedSafes[data.id].state == 2 then
						exports["pulsar-chat"]:SendServerSingle(source, "Safe Was Cracked, And Timelock Disengaged")
					elseif _robbedSafes[data.id].state == 3 then
						exports["pulsar-chat"]:SendServerSingle(source, "Safe Was Cracked and looted")
					end

					_robbedSafes[data.id].state = 4
					_robbedSafes[data.id].expires = (os.time() + 60 * math.random(30, 60))
					exports['pulsar-core']:LoggerInfo(
						"Robbery",
						string.format(
							"%s %s (%s) Secured %s Safe",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID"),
							data.id
						)
					)
					GlobalState[string.format("Safe:%s", data.id)] = _robbedSafes[data.id]
					exports["pulsar-sounds"]:StopLocation(_robbedSafes[data.id].source, _robbedSafes[data.id].coords,
						"alarm")
				end
			end
		end
	end)
end)

CreateThread(function()
	while true do
		for k, v in pairs(_robbedSafes) do
			if v.expires < os.time() then
				if v.state == 1 then
					exports['pulsar-core']:LoggerTrace("Robbery",
						string.format("Safe %s Expired While State 1, Updating To State 2", k))
					_robbedSafes[k].expires = (os.time() + 60 * math.random(30, 60))
					_robbedSafes[k].state = 2
					GlobalState[string.format("Safe:%s", k)] = _robbedSafes[k]
					exports["pulsar-sounds"]:PlayLocation(v.source, v.coords, 10, "alarm.ogg", 0.15)
					-- Do something to alert
				else
					exports['pulsar-core']:LoggerTrace("Robbery",
						string.format("Safe %s Expired While State 2, Resetting", k))
					_robbedSafes[k] = nil
					GlobalState[string.format("Safe:%s", k)] = nil
				end
			end
		end
		Wait(30000)
	end
end)
