local _lb = RobberyConfig.lombank

_lbInUse = {
	lobbyGate = false,
	vaultGate = false,
	upperVaultDoor = false,
	upperVaultGate = false,
	lowerVaultGate = false,
	lowerVaultDoor = false,
	lowerVaultRoom1 = false,
	lowerVaultRoom2 = false,
	lowerVaultRoom3 = false,
	lowerVaultRoom4 = false,
	vaultPower = false,
	powerBoxes = {},
	carts = {},
	drillPoints = {},
}

_unlockingDoors = {}
_lootedTrollys = {}
_lbVaultPower = false
_lbGlobalReset = nil

local _heistCoin = false
local _trolleysLooted = 1
local _yellowDongie = false

function LombankClearSourceInUse(source)
	for k, v in pairs(_lbInUse) do
		if v == source then
			_lbInUse[k] = nil
		elseif type(v) == "table" then
			for k2, v2 in pairs(v) do
				if v2 == source then
					_lbInUse[k][k2] = nil
				end
			end
		end
	end
end

function IsLBPowerDisabled()
	for k, v in ipairs(_lb.powerBoxes) do
		if
			GlobalState[string.format("Lombank:Power:%s", v.data.boxId)] == nil
			or os.time() > GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
		then
			return false
		end
	end
	return true
end

function LombankDisablePower(source)
	if not _lbGlobalReset or os.time() > _lbGlobalReset then
		_lbGlobalReset = os.time() + _lb.resetTime
	end
	for k, v in ipairs(_lb.powerBoxes) do
		GlobalState[string.format("Lombank:Power:%s", v.data.boxId)] = _lbGlobalReset
	end

	exports['pulsar-robbery']:TriggerPDAlert(source, vector3(77.775, -869.549, 31.398), "10-33",
		"Minor Power Grid Disruption", {
			icon = 354,
			size = 0.9,
			color = 31,
			duration = (60 * 5),
		}, {
			icon = "bolt-slash",
			details = "Pillbox Hill",
		}, false, 50.0)
	GlobalState["Fleeca:Disable:lombank_legion"] = true

	exports['ox_doorlock']:SetLock("lombank_hidden_entrance", false)
	exports['ox_doorlock']:SetLock("lombank_front_gate", false)
	exports['ox_doorlock']:SetLock("lombank_upper_gate", false)
	exports['ox_doorlock']:SetLock("lombank_lower_gate", false)
	exports['ox_doorlock']:SetLock("lombank_lasers", false)
end

function AreRequirementsUnlocked(reqs)
	for k, v in ipairs(reqs or {}) do
		if exports['ox_doorlock']:IsLocked(v) then
			return false
		end
	end
	return true
end

function ResetLombank()
	for k, v in pairs(_lb.powerBoxes) do
		GlobalState[string.format("Lombank:Power:%s", v.data.boxId)] = nil
	end

	for k, v in pairs(_lb.upperVaultPoints) do
		GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)] = nil
	end

	exports['ox_doorlock']:SetLock("lombank_lasers", true)
	exports['pulsar-cctv']:StateGroupOnline("lombank")
	for k, v in pairs(_lb.thermitePoints) do
		exports['ox_doorlock']:SetLock(v.door, true)
	end

	for k, v in pairs(_lb.hackPoints) do
		exports['ox_doorlock']:SetLock(v.door, true)
	end

	if #_lootedTrollys > 0 then
		for k, v in ipairs(_lootedTrollys) do
			GlobalState[string.format("Lombank:VaultRoom:%s:%s", v.room, v.val)] = nil
		end
		_lootedTrollys = {}
	end

	_yellowDongie = false

	_lbAlerted = false
	_lbPowerAlerted = false

	_heistCoin = false
	_trolleysLooted = 1

	GlobalState["Fleeca:Disable:lombank_legion"] = false
	GlobalState["LombankInProgress"] = false
	GlobalState["Lombank:Secured"] = false
end

function SecureLombank()
	_lbGlobalReset = os.time() + _lb.resetTime

	for k, v in pairs(_lb.powerBoxes) do
		GlobalState[string.format("Lombank:Power:%s", v.data.boxId)] = nil
	end

	for k, v in pairs(_lb.upperVaultPoints) do
		GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)] = nil
	end

	exports['ox_doorlock']:SetLock("lombank_lasers", true)
	exports['pulsar-cctv']:StateGroupOnline("lombank")
	for k, v in pairs(_lb.thermitePoints) do
		exports['ox_doorlock']:SetLock(v.door, true)
	end

	for k, v in pairs(_lb.hackPoints) do
		exports['ox_doorlock']:SetLock(v.door, true)
	end

	if #_lootedTrollys > 0 then
		for k, v in ipairs(_lootedTrollys) do
			GlobalState[string.format("Lombank:VaultRoom:%s:%s", v.room, v.val)] = nil
		end
		_lootedTrollys = {}
	end

	_heistCoin = false
	_trolleysLooted = 1

	GlobalState["Fleeca:Disable:lombank_legion"] = false
	GlobalState["LombankInProgress"] = false
	GlobalState["Lombank:Secured"] = true
end

local _lbUpperLoot = {
	{ 98, { name = "moneyband", min = 80, max = 90 } },
	{ 2,  { name = "moneybag", min = 1, max = 1, metadata = { CustomAmt = { Min = 65000, Random = 15000 } } } },
}

local _lbLoot = {
	{ 98, { name = "moneyband", min = 55, max = 75 } },
	{ 2,  { name = "moneybag", min = 1, max = 1, metadata = { CustomAmt = { Min = 450000, Random = 15000 } } } },
}

_lbAlerted = false
_lbPowerAlerted = false

AddEventHandler("Characters:Server:PlayerLoggedOut", LombankClearSourceInUse)
AddEventHandler("Characters:Server:PlayerDropped", LombankClearSourceInUse)

AddEventHandler("Robbery:Server:Setup", function()
	RegisterLBItemUses()
	StartLombankThreads()

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:SecureBank", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if Player(source).state.onDuty == "police" then
				SecureLombank()
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:Vault:StartLootTrolley", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inLombank then
			if
				GlobalState[string.format(
					"Lombank:VaultRoom:%s:%s:%s",
					pState.lombankRoom,
					math.ceil(data.coords.x),
					math.ceil(data.coords.y)
				)]
				== nil
				and not _lbInUse.carts[string.format("%s-%s", math.ceil(data.coords.x), math.ceil(data.coords.y))]
				and not exports['ox_doorlock']:IsLocked(_lb.thermitePoints[string.format("lowerVaultRoom%s", pState.lombankRoom)].door)
			then
				GlobalState["LombankInProgress"] = true
				exports['pulsar-core']:LoggerInfo(
					"Robbery",
					string.format(
						"%s %s (%s) Started Looting Lombank Cart %s-%s In Room %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						math.ceil(data.coords.x),
						math.ceil(data.coords.y),
						pState.lombankRoom
					)
				)

				if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
					GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
				end
				GlobalState["Fleeca:Disable:lombank_legion"] = true
				_lbInUse.carts[string.format("%s-%s", math.ceil(data.coords.x), math.ceil(data.coords.y))] = source
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:Vault:FinishLootTrolley", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inLombank then
			if
				GlobalState[string.format(
					"Lombank:VaultRoom:%s:%s:%s",
					pState.lombankRoom,
					math.ceil(data.coords.x),
					math.ceil(data.coords.y)
				)]
				== nil
				and _lbInUse.carts[string.format("%s-%s", math.ceil(data.coords.x), math.ceil(data.coords.y))] == source
				and not exports['ox_doorlock']:IsLocked(_lb.thermitePoints[string.format("lowerVaultRoom%s", pState.lombankRoom)].door)
			then
				exports.ox_inventory:LootCustomWeightedSetWithCount(_lbLoot, char:GetData("SID"), 1)

				if math.random(100) <= (7 * _trolleysLooted) and not _heistCoin then
					_heistCoin = true
					exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
						CryptoCoin = "HEIST",
						Quantity = 8,
					}, 1)
				else
					_trolleysLooted += 1
				end

				exports['pulsar-core']:LoggerInfo(
					"Robbery",
					string.format(
						"%s %s (%s) Finished Looting Lombank Cart %s-%s In Room %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						math.ceil(data.coords.x),
						math.ceil(data.coords.y),
						pState.lombankRoom
					)
				)

				table.insert(_lootedTrollys, {
					room = pState.lombankRoom,
					val = string.format("%s-%s", math.ceil(data.coords.x), math.ceil(data.coords.y)),
				})

				_lbInUse.carts[string.format("%s-%s", math.ceil(data.coords.x), math.ceil(data.coords.y))] = nil
				GlobalState[string.format(
					"Lombank:VaultRoom:%s:%s:%s",
					pState.lombankRoom,
					math.ceil(data.coords.x),
					math.ceil(data.coords.y)
				)] = os.time()
					+ (60 * 60 * 6)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:ElectricBox:Hack", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["LombankInProgress"]
				) and not GlobalState["Lombank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _lb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["LombankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"Network Offline For A Storm, Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _lb.requiredPolice
					and not GlobalState["LombankInProgress"]
				then
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
				elseif
					GlobalState[string.format("Lombank:Power:%s", data.boxId)] ~= nil
					and GlobalState[string.format("Lombank:Power:%s", data.boxId)] > os.time()
				then
					exports['pulsar-hud']:Notification(source, "error",
						"Electric Box Already Disabled", 6000)
					return
				end

				if not _lbInUse.powerBoxes[data.boxId] then
					_lbInUse.powerBoxes[data.boxId] = source
					GlobalState["LombankInProgress"] = true

					if exports.ox_inventory:ItemsHas(char:GetData("SID"), "adv_electronics_kit", 1) then
						local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
							"adv_electronics_kit", 1)
						local itemData = exports.ox_inventory:ItemsGetData("adv_electronics_kit")

						if itemData ~= nil then
							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Started hacking Lombank Power Box %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data.boxId
								)
							)
							exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Hack", {
								config = {
									countdown = 3,
									timer = 5,
									limit = 16000,
									delay = 2000,
									difficulty = 8,
									chances = 6,
									anim = false,
								},
								data = {},
							}, function(success)
								local newValue = slot.CreateDate - (60 * 60 * 24)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
								end
								if type(itemData.durability) == 'number' and os.time() - itemData.durability >= newValue then
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
								else
									exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
								end

								if success then
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Successfully Hacked Lombank Power Box %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											data.boxId
										)
									)
									if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									if not _lbGlobalReset or os.time() > _lbGlobalReset then
										_lbGlobalReset = os.time() + _lb.resetTime
									end

									GlobalState[string.format("Lombank:Power:%s", data.boxId)] = _lbGlobalReset
									TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
									if IsLBPowerDisabled() then
										exports['ox_doorlock']:SetLock("lombank_hidden_entrance", false)
										exports['pulsar-cctv']:StateGroupOffline("lombank")
										exports["pulsar-sounds"]:PlayLocation(
											source,
											data.ptFxPoint,
											15.0,
											"power_small_complete_off.ogg",
											0.1
										)
										exports['pulsar-robbery']:TriggerPDAlert(
											source,
											vector3(77.775, -869.549, 31.398),
											"10-33",
											"Minor Power Grid Disruption",
											{
												icon = 354,
												size = 0.9,
												color = 31,
												duration = (60 * 5),
											},
											{
												icon = "bolt-slash",
												details = "Pillbox Hill",
											},
											false,
											50.0
										)
										GlobalState["Fleeca:Disable:lombank_legion"] = true
									else
										exports['ox_doorlock']:SetLock("lombank_hidden_entrance", true)
										exports['ox_doorlock']:SetLock("lombank_lasers", true)
										exports["pulsar-sounds"]:PlayLocation(source, data.ptFxPoint, 15.0,
											"power_small_off.ogg", 0.25)
										if not _lbPowerAlerted or os.time() > _lbPowerAlerted then
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												GetEntityCoords(GetPlayerPed(source)),
												"10-33",
												"Attack on Power Grid",
												{
													icon = 354,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "bolt-slash",
													details = "Pillbox Hill",
												},
												false,
												false
											)
											_lbPowerAlerted = os.time() + (60 * 10)
										end
									end
								end

								_lbInUse.powerBoxes[data.boxId] = false
							end, string.format("lombank_power_%s", data.boxId))
						else
							_lbInUse.powerBoxes[data.boxId] = false
						end
					else
						_lbInUse.powerBoxes[data.boxId] = false
					end
				else
					exports['pulsar-hud']:Notification(source, "error",
						"Someone Is Already Interacting With This", 6000)
				end

				return
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:ElectricBox:Thermite", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["LombankInProgress"]
				) and not GlobalState["Lombank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _lb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["LombankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _lb.requiredPolice
					and not GlobalState["LombankInProgress"]
				then
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
				elseif
					GlobalState[string.format("Lombank:Power:%s", data.boxId)] ~= nil
					and GlobalState[string.format("Lombank:Power:%s", data.boxId)] > os.time()
				then
					exports['pulsar-hud']:Notification(source, "error",
						"Electric Box Already Disabled", 6000)
					return
				end

				local myPos = GetEntityCoords(GetPlayerPed(source))

				if
					#(
						vector3(data.thermitePoint.coords.x, data.thermitePoint.coords.y, data.thermitePoint.coords.z)
						- myPos
					) <= 3.5
				then
					if not _lbInUse.powerBoxes[data.boxId] then
						_lbInUse.powerBoxes[data.boxId] = source
						GlobalState["LombankInProgress"] = true

						if exports.ox_inventory:ItemsHas(char:GetData("SID"), "thermite", 1) then
							if exports.ox_inventory:Remove(char:GetData("SID"), 1, "thermite", 1) then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started Thermiting Lombank Power Box %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										data.boxId
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
									passes = 1,
									location = data.thermitePoint,
									duration = 25000,
									config = {
										countdown = 3,
										preview = 1500,
										timer = 9000,
										passReduce = 500,
										base = 16,
										cols = 6,
										rows = 6,
										anim = false,
									},
									data = {},
								}, function(success)
									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Thermited Lombank Power Box %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												data.boxId
											)
										)
										if
											not GlobalState["AntiShitlord"]
											or os.time() >= GlobalState["AntiShitlord"]
										then
											GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
										end

										if not _lbGlobalReset or os.time() > _lbGlobalReset then
											_lbGlobalReset = os.time() + _lb.resetTime
										end

										GlobalState[string.format("Lombank:Power:%s", data.boxId)] = _lbGlobalReset
										TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
										if IsLBPowerDisabled() then
											exports['ox_doorlock']:SetLock("lombank_hidden_entrance", false)
											exports['pulsar-cctv']:StateGroupOffline("lombank")
											exports["pulsar-sounds"]:PlayLocation(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_complete_off.ogg",
												0.1
											)
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												vector3(77.775, -869.549, 31.398),
												"10-33",
												"Minor Power Grid Disruption",
												{
													icon = 354,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "bolt-slash",
													details = "Pillbox Hill",
												},
												false,
												50.0
											)
											GlobalState["Fleeca:Disable:lombank_legion"] = true
										else
											exports['ox_doorlock']:SetLock("lombank_hidden_entrance", true)
											exports['ox_doorlock']:SetLock("lombank_lasers", true)
											exports["pulsar-sounds"]:PlayLocation(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_off.ogg",
												0.25
											)
											if not _lbPowerAlerted or os.time() > _lbPowerAlerted then
												exports['pulsar-robbery']:TriggerPDAlert(
													source,
													GetEntityCoords(GetPlayerPed(source)),
													"10-33",
													"Attack on Power Grid",
													{
														icon = 354,
														size = 0.9,
														color = 31,
														duration = (60 * 5),
													},
													{
														icon = "bolt-slash",
														details = "Pillbox Hill",
													},
													false,
													false
												)
												_lbPowerAlerted = os.time() + (60 * 10)
											end
										end
									end

									_lbInUse.powerBoxes[data.boxId] = false
								end, string.format("lombank_power_%s", data.boxId))
							else
								_lbInUse.powerBoxes[data.boxId] = false
							end
						else
							_lbInUse.powerBoxes[data.boxId] = false
							exports['pulsar-hud']:Notification(source, "error", "You Need Thermite",
								6000)
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end

					return
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Lombank:Drill", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["LombankInProgress"]
				) and not GlobalState["Lombank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _lb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["LombankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _lb.requiredPolice
					and not GlobalState["LombankInProgress"]
				then
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
				elseif
					GlobalState[string.format("Lombank:Upper:Wall:%s", data)] ~= nil
					and GlobalState[string.format("Lombank:Upper:Wall:%s", data)] > os.time()
				then
					exports['pulsar-hud']:Notification(source, "error",
						"Electric Box Already Disabled", 6000)
					return
				end
				if not _lbInUse.drillPoints[data] then
					_lbInUse.drillPoints[data] = source
					GlobalState["LombankInProgress"] = true

					if exports.ox_inventory:ItemsHas(char:GetData("SID"), "drill", 1) then
						local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "drill", 1)
						local itemData = exports.ox_inventory:ItemsGetData("drill")

						if slot ~= nil then
							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Started Drilling Vault Box: %s",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID"),
									data
								)
							)
							exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Drill", {
								passes = 1,
								duration = 25000,
								config = {},
								data = {},
							}, function(success)
								local newValue = slot.CreateDate - (60 * 60 * 24)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
								end
								if type(itemData.durability) == 'number' and os.time() - itemData.durability >= newValue then
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
								else
									exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
								end

								if success then
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Successfully Drilled Vault Box: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											data
										)
									)
									if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									if not _lbGlobalReset or os.time() > _lbGlobalReset then
										_lbGlobalReset = os.time() + _lb.resetTime
									end

									exports.ox_inventory:LootCustomWeightedSetWithCount(_lbUpperLoot,
										char:GetData("SID"), 1)

									GlobalState[string.format("Lombank:Upper:Wall:%s", data)] = _lbGlobalReset
									GlobalState["Fleeca:Disable:lombank_legion"] = true
								end

								_lbInUse.drillPoints[data] = false
							end, string.format("lombank_drill_%s", data))
						else
							_lbInUse.drillPoints[data] = false
						end
					else
						_lbInUse.drillPoints[data] = false
						exports['pulsar-hud']:Notification(source, "error", "You Need A Drill", 6000)
					end
				else
					exports['pulsar-hud']:Notification(source, "error",
						"Someone Is Already Interacting With This", 6000)
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)
end)
