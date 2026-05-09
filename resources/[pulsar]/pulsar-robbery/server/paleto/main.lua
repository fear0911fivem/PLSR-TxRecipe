local _pb = RobberyConfig.paleto

_pbInUse = {
	workstation = false,
	officeSafe = false,
	pcHacks = {},
	officeHacks = {},
	substations = {},
	powerHacks = {},
	vaultPower = false,
	powerBoxes = {},
	drillPoints = {},
	securityAccess = {},
	searchPoints = {},
}

_pbVaultPower = false
_pbGlobalReset = nil
_pbAlerted = false

local _mintDongie = false
local _pbLoot = {
	{ 98, { name = "moneyband", min = 125, max = 150 } },
	{ 2,  { name = "moneybag", min = 1, max = 1, metadata = { CustomAmt = { Min = 250000, Random = 50000 } } } },
}
local _pbSearchLoot = {
	{ 98, { name = "moneyband", min = 125, max = 150 } },
	{ 2,  { name = "moneybag", min = 1, max = 1, metadata = { CustomAmt = { Min = 250000, Random = 50000 } } } },
}

AddEventHandler("Characters:Server:PlayerLoggedOut", PaletoClearSourceInUse)
AddEventHandler("Characters:Server:PlayerDropped", PaletoClearSourceInUse)

AddEventHandler("Robbery:Server:Setup", function()
	RegisterPBItems()
	StartPaletoThreads()

	for k, v in ipairs(_pb.doorIds) do
		exports['ox_doorlock']:SetLock(v, true)
	end

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:SecureBank", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if Player(source).state.onDuty == "police" then
				SecurePaleto()
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:DisableAlarm", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if Player(source).state.onDuty == "police" then
				if _bankStates.paleto.fookinLasers then
					TriggerClientEvent(
						"Sounds:Client:Stop:Distance",
						-1,
						_bankStates.paleto.fookinLasers,
						"bank_alarm.ogg"
					)
					exports['pulsar-robbery']:StateUpdate("paleto", "fookinLasers", false)
					_pbAlerted = false
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:TriggeredLaser", function(source, data, cb)
		if not _bankStates.paleto.fookinLasers then
			exports['pulsar-robbery']:StateUpdate("paleto", "fookinLasers", source)
			exports["pulsar-sounds"]:LoopLocation(source, vector3(-104.552, 6469.050, 35.981), 50.0, "bank_alarm.ogg",
				0.15)
			GlobalState["Fleeca:Disable:savings_paleto"] = true
			if not _pbAlerted or os.time() > _pbAlerted then
				exports['pulsar-robbery']:TriggerPDAlert(source, vector3(-111.130, 6462.485, 31.643), "10-33",
					"Bank Alarm Triggered", {
						icon = 137,
						size = 0.9,
						color = 31,
						duration = (60 * 5),
					}, {
						icon = "building-columns",
						details = "Blaine County Savings Bank",
					}, "paleto")
				_pbAlerted = os.time() + (60 * 10)
				exports['pulsar-status']:Add(source, "PLAYER_STRESS", 15)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:GetDoors", function(source, data, cb)
		local its = {}

		table.insert(its, {
			label = "Vault Terminal Override",
			data = {},
			disabled = _bankStates.paleto.vaultTerminal or 0 > os.time(),
			event = "Robbery:Client:Paleto:VaultTerminal",
		})

		for k, v in ipairs(_pb.doorsGarbage) do
			table.insert(its, {
				label = v.label,
				data = v.data,
				disabled = not exports['ox_doorlock']:IsLocked(v.doorId),
				event = exports['ox_doorlock']:IsLocked(v.doorId) and "Robbery:Client:Paleto:Door" or nil,
			})
		end
		cb(its)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:VaultTerminal", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if not IsPaletoExploitInstalled() then
						exports['pulsar-hud']:Notification(source, "error",
							"Bank Firewalls Still Active, Cannot Do This Yet",
							6000
						)
						return
					end

					if not _bankStates.paleto.vaultTerminal or os.time() > _bankStates.paleto.vaultTerminal then
						if not _pbGlobalReset or os.time() > _pbGlobalReset then
							_pbGlobalReset = os.time() + _pb.resetTime
						end
						exports['pulsar-robbery']:StateUpdate("paleto", "vaultTerminal", _pbGlobalReset)
					end
				else
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:UnlockDoor", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if not IsPaletoExploitInstalled() then
						exports['pulsar-hud']:Notification(source, "error",
							"Bank Firewalls Still Active, Cannot Do This Yet",
							6000
						)
						return
					end

					if data.data.id ~= nil then
						if
							not _pb.doorsGarbage[data.data.id].requireCode
							or (
								data.data.officeId
								and (
									_accessCodes.paleto[data.data.officeId] == nil
									or _accessCodes.paleto[data.data.officeId].code == tonumber(data.code)
								)
							)
						then
							exports['ox_doorlock']:SetLock(data.data.door, false)
							exports['pulsar-hud']:Notification(source, "success", "Door Unlocked")

							if _pb.doorsGarbage[data.data.id].requireCode then
								exports.ox_inventory:RemoveAll(char:GetData("SID"), 1, "paleto_access_codes")
							end
						else
							exports['ox_doorlock']:SetLock(data.data.door, true)
							exports['pulsar-hud']:Notification(source, "error", "Invalid Access Code")
							exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
						end
					else
						cb(false)
					end
				else
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:ElectricBox:Hack", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if not IsPaletoExploitInstalled() then
						exports['pulsar-hud']:Notification(source, "error",
							"Power Grid Firewalls Still Active, Cannot Do This Yet",
							6000
						)
						return
					end

					if not _pbInUse.powerBoxes[data.boxId] then
						_pbInUse.powerBoxes[data.boxId] = source
						GlobalState["PaletoInProgress"] = true

						if exports.ox_inventory:ItemsHas(char:GetData("SID"), "adv_electronics_kit", 1) then
							local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
								"adv_electronics_kit", 1)
							local itemData = exports.ox_inventory:ItemsGetData("adv_electronics_kit")

							if itemData ~= nil then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started hacking Paleto Electrical Box %s",
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
										limit = 14000,
										delay = 2000,
										difficulty = 8,
										chances = 6,
										anim = false,
									},
									data = {},
								}, function(success)
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)

									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Paleto Electrical Box %s",
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

										if not _pbGlobalReset or os.time() > _pbGlobalReset then
											_pbGlobalReset = os.time() + _pb.resetTime
										end

										exports['pulsar-robbery']:StateUpdate("paleto", data.boxId, _pbGlobalReset,
											"electricalBoxes")
										TriggerEvent("Particles:Server:DoFx", data.ptFxPoint, "spark")
										if IsPaletoPowerDisabled() then
											exports["pulsar-sounds"]:PlayLocation(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_complete_off.ogg",
												0.1
											)
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												vector3(-195.586, 6338.740, 31.515),
												"10-33",
												"Regional Power Grid Disruption",
												{
													icon = 354,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "bolt-slash",
													details = "Paleto",
												},
												false,
												250.0
											)
											GlobalState["Fleeca:Disable:savings_paleto"] = true
											exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", false)
											RestorePowerThread()
										else
											exports["pulsar-sounds"]:PlayLocation(
												source,
												data.ptFxPoint,
												15.0,
												"power_small_complete_off.ogg",
												0.1
											)
											exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", true)
										end
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
									else
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
									end

									_pbInUse.powerBoxes[data.boxId] = false
								end, string.format("paleeto_power_%s", data.boxId))
							else
								_pbInUse.powerBoxes[data.boxId] = false
							end
						else
							_pbInUse.powerBoxes[data.boxId] = false
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:PC:Hack", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if
						_bankStates.paleto.exploits[data.pcId] ~= nil
						and _bankStates.paleto.exploits[data.pcId] > os.time()
					then
						exports['pulsar-hud']:Notification(source, "error",
							"Electric Box Already Disabled", 6000)
						return
					end

					if not _pbInUse.pcHacks[data.pcId] then
						_pbInUse.pcHacks[data.pcId] = source
						GlobalState["PaletoInProgress"] = true

						if exports.ox_inventory:ItemsHas(char:GetData("SID"), "adv_electronics_kit", 1) then
							local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
								"adv_electronics_kit", 1)
							local itemData = exports.ox_inventory:ItemsGetData("adv_electronics_kit")

							if itemData ~= nil then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started hacking Paleto PC %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										data.pcId
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Tracking", {
									config = {
										countdown = 3,
										delay = 2000,
										limit = 14000,
										difficulty = 4 + CountPaletoExploits(),
										anim = false,
									},
									data = {},
								}, function(success)
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)

									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Paleto PC %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												data.pcId
											)
										)
										if not _pbGlobalReset or os.time() > _pbGlobalReset then
											_pbGlobalReset = os.time() + _pb.resetTime
										end

										exports['pulsar-robbery']:StateUpdate("paleto", data.pcId, _pbGlobalReset,
											"exploits")
										if IsPaletoExploitInstalled() then
											exports['pulsar-phone']:EmailSend(
												source,
												"ghost@ls.undg",
												os.time(),
												"Exploit Fully Uploaded",
												string.format(
													[[
															Nicely done %s<br /><br />
															Those exploits got us in and my hackers have managed to disable security measures at various substations around the region.
															You need to attack those, doing so should bring down Paleto Banks more advanced security measures.
														]],
													char:GetData("First")
												)
											)
										else
											local count = CountPaletoExploits()
											exports['pulsar-phone']:EmailSend(
												source,
												"ghost@ls.undg",
												os.time(),
												string.format(
													"Paleto Power Grid Exploits: %s/%s",
													count,
													#_pb.pcHackAreas
												),
												string.format(
													[[
															Good Work %s<br /><br />
															In order to expose the power grid in paleto enough that we can actually attack it you need to install a total of %s exploits.
															There's workstations setup around the region that are good for installing 1 exploit.
														]],
													char:GetData("First"),
													#_pb.pcHackAreas
												)
											)
										end
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
									else
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
									end

									_pbInUse.pcHacks[data.pcId] = false
								end, string.format("paleeto_pc_%s", data.pcId))
							else
								_pbInUse.pcHacks[data.pcId] = false
							end
						else
							_pbInUse.pcHacks[data.pcId] = false
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:Workstation", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if not IsPaletoExploitInstalled() then
						exports['pulsar-hud']:Notification(source, "error",
							"Network Firewalls Still Active", 6000)
						return
					elseif _bankStates.paleto.workstation and _bankStates.paleto.workstation > os.time() then
						exports['pulsar-hud']:Notification(source, "error",
							"Workstation Has Already Been Hacked", 6000)
						return
					end

					if not _pbInUse.workstation then
						_pbInUse.workstation = source
						GlobalState["PaletoInProgress"] = true

						if
							exports.ox_inventory:ItemsHas(char:GetData("SID"), 'vpn', 1)
							and exports.ox_inventory:ItemsHas(char:GetData("SID"), "adv_electronics_kit", 1)
						then
							local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
								"adv_electronics_kit", 1)
							local itemData = exports.ox_inventory:ItemsGetData("adv_electronics_kit")

							if itemData ~= nil then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started hacking Paleto Lobby Workstation",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID")
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:AimHack", {
									config = {
										countdown = 3,
										limit = 15750,
										timer = 500,
										startSize = 20,
										maxSize = 75,
										growthRate = 20,
										accuracy = 75,
										isMoving = true,
										anim = false,
									},
									data = {},
								}, function(success, data)
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)

									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Paleto Lobby Workstation",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID")
											)
										)
										if not _pbGlobalReset or os.time() > _pbGlobalReset then
											_pbGlobalReset = os.time() + _pb.resetTime
										end

										exports['pulsar-robbery']:StateUpdate("paleto", "workstation", _pbGlobalReset)
										exports.ox_inventory:AddItem(char:GetData("SID"), "paleto_access_codes",
											1, {
												AccessCodes = { _accessCodes.paleto[1] },
											}, 1)

										GlobalState["Fleeca:Disable:savings_paleto"] = true
										if not _pbAlerted or os.time() > _pbAlerted then
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												vector3(-111.130, 6462.485, 31.643),
												"10-90",
												"Armed Robbery",
												{
													icon = 586,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "building-columns",
													details = "Blaine County Savings Bank",
												},
												"paleto"
											)
											_pbAlerted = os.time() + (60 * 10)
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
										end
									else
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
									end

									_pbInUse.workstation = false
								end, "paleto_workstation")
							else
								_pbInUse.workstation = false
							end
						else
							_pbInUse.workstation = false
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:OfficeHack", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if
						_bankStates.paleto.officeHacks[data.officeId] ~= nil
						and _bankStates.paleto.officeHacks[data.officeId] > os.time()
					then
						exports['pulsar-hud']:Notification(source, "error",
							"This Workstation Has Already Been Comprimised",
							6000
						)
						return
					end

					if not _pbInUse.officeHacks[data.officeId] then
						_pbInUse.officeHacks[data.officeId] = source
						GlobalState["PaletoInProgress"] = true

						if exports.ox_inventory:ItemsHas(char:GetData("SID"), "adv_electronics_kit", 1) then
							local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"),
								"adv_electronics_kit", 1)
							local itemData = exports.ox_inventory:ItemsGetData("adv_electronics_kit")

							if itemData ~= nil then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started hacking Paleto Office %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										data.officeId
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Tracking", {
									config = {
										countdown = 3,
										delay = 2000,
										limit = 14000,
										difficulty = 6,
										anim = false,
									},
									data = {},
								}, function(success)
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)

									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Paleto Office %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												data.officeId
											)
										)
										if not _pbGlobalReset or os.time() > _pbGlobalReset then
											_pbGlobalReset = os.time() + _pb.resetTime
										end

										exports['pulsar-robbery']:StateUpdate("paleto", data.officeId, _pbGlobalReset,
											"officeHacks")

										if _accessCodes.paleto[data.officeId + 1] ~= nil then
											exports.ox_inventory:AddItem(char:GetData("SID"),
												"paleto_access_codes", 1, {
													AccessCodes = { _accessCodes.paleto[data.officeId + 1] },
												}, 1)
										end

										exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
											CryptoCoin = "MALD",
											Quantity = math.random(200, 400),
										}, 1)

										GlobalState["Fleeca:Disable:savings_paleto"] = true
										if not _pbAlerted or os.time() > _pbAlerted then
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												vector3(-111.130, 6462.485, 31.643),
												"10-90",
												"Armed Robbery",
												{
													icon = 586,
													size = 0.9,
													color = 31,
													duration = (60 * 5),
												},
												{
													icon = "building-columns",
													details = "Blaine County Savings Bank",
												},
												"paleto"
											)
											_pbAlerted = os.time() + (60 * 10)
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
										end
									else
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
									end

									_pbInUse.officeHacks[data.officeId] = false
								end, string.format("paleto_office_%s", data.officeId))
							else
								_pbInUse.officeHacks[data.officeId] = false
							end
						else
							_pbInUse.officeHacks[data.officeId] = false
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:Drill", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, false) then
					if
						_bankStates.paleto.drillPoints[data] ~= nil
						and _bankStates.paleto.officeHacks[data] > os.time()
					then
						exports['pulsar-hud']:Notification(source, "error",
							"This Workstation Has Already Been Comprimised",
							6000
						)
						return
					elseif exports['ox_doorlock']:IsLocked("pulsar_bank_savings_paleto_vault") then
						return
					end
					if not _pbInUse.drillPoints[data] then
						_pbInUse.drillPoints[data] = source
						GlobalState["PaletoInProgress"] = true

						if exports.ox_inventory:ItemsHas(char:GetData("SID"), "drill", 1) then
							local slot = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "drill", 1)
							local itemData = exports.ox_inventory:ItemsGetData("drill")

							if slot ~= nil then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started Drilling Paleto Vault Box: %s",
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
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)

									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Drilled Paleto Vault Box: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												data
											)
										)
										if
											not GlobalState["AntiShitlord"]
											or os.time() >= GlobalState["AntiShitlord"]
										then
											GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
										end

										if not _pbGlobalReset or os.time() > _pbGlobalReset then
											_pbGlobalReset = os.time() + _pb.resetTime
										end

										exports.ox_inventory:LootCustomWeightedSetWithCount(_pbLoot,
											char:GetData("SID"), 1)

										Robber.State:Update("paleto", data, _pbGlobalReset, "drillPoints")
										GlobalState["Fleeca:Disable:savings_paleto"] = true
									end

									_pbInUse.drillPoints[data] = false
								end, string.format("paleto_drill_%s", data))
							else
								_pbInUse.drillPoints[data] = false
							end
						else
							_pbInUse.drillPoints[data] = false
							exports['pulsar-hud']:Notification(source, "error", "You Need A Drill",
								6000)
						end
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				else
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:Search", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, false) then
					if
						_bankStates.paleto.officeSearch[data.searchId] ~= nil
						and _bankStates.paleto.officeSearch[data.searchId] > os.time()
					then
						exports['pulsar-hud']:Notification(source, "error",
							"This Workstation Has Already Been Comprimised",
							6000
						)
						return
					elseif exports['ox_doorlock']:IsLocked(data.door) then
						return
					end
					if not _pbInUse.searchPoints[data.searchId] then
						_pbInUse.searchPoints[data.searchId] = source
						GlobalState["PaletoInProgress"] = true

						exports['pulsar-core']:LoggerInfo(
							"Robbery",
							string.format(
								"%s %s (%s) Started Drilling Paleto Vault Box: %s",
								char:GetData("First"),
								char:GetData("Last"),
								char:GetData("SID"),
								data.searchId
							)
						)
						exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Lockpick", {
							config = 0.75,
							data = {
								stages = 3,
							},
						}, function(success)
							if success then
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Successfully Drilled Paleto Vault Box: %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										data.searchId
									)
								)
								if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
									GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
								end

								if not _pbGlobalReset or os.time() > _pbGlobalReset then
									_pbGlobalReset = os.time() + _pb.resetTime
								end

								exports.ox_inventory:LootCustomWeightedSetWithCount(_pbSearchLoot,
									char:GetData("SID"), 1)

								exports['pulsar-robbery']:StateUpdate("paleto", data.searchId, _pbGlobalReset,
									"officeSearch")
								GlobalState["Fleeca:Disable:savings_paleto"] = true
							end

							_pbInUse.searchPoints[data.searchId] = false
						end, string.format("paleto_search_%s", data.searchId))
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				else
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:StartSafe", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if _bankStates.paleto.officeSafe and _bankStates.paleto.officeSafe > os.time() then
						exports['pulsar-hud']:Notification(source, "error",
							"Safe Has Already Been Looted", 6000)
						return
					end

					if not _pbInUse.officeSafe then
						_pbInUse.officeSafe = source
						exports['pulsar-core']:LoggerInfo(
							"Robbery",
							string.format(
								"%s %s (%s) Started Accessing Paleto Office Safe",
								char:GetData("First"),
								char:GetData("Last"),
								char:GetData("SID")
							)
						)
						GlobalState["PaletoInProgress"] = true
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
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Paleto:Safe", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["PaletoInProgress"]
				) and not GlobalState["Paleto:Secured"]
			then
				if PaletoIsGloballyReady(source, true) then
					if _bankStates.paleto.officeSafe and _bankStates.paleto.officeSafe > os.time() then
						exports['pulsar-hud']:Notification(source, "error",
							"Safe Has Already Been Looted", 6000)
						return
					end

					if _pbInUse.officeSafe == source then
						if data.code ~= false and _accessCodes.paleto[4].code == tonumber(data.code) then
							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Successfully Accessed Paleto Office Safe",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID")
								)
							)

							exports.ox_inventory:RemoveAll(char:GetData("SID"), 1, "paleto_access_codes")
							if not _pbGlobalReset or os.time() > _pbGlobalReset then
								_pbGlobalReset = os.time() + _pb.resetTime
							end

							exports['pulsar-robbery']:StateUpdate("paleto", "officeSafe", _pbGlobalReset)

							exports.ox_inventory:LootCustomWeightedSetWithCount(_pbLoot, char:GetData("SID"), 1)
							exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
								CryptoCoin = "MALD",
								Quantity = math.random(200, 400),
							}, 1)

							exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
								CryptoCoin = "HEIST",
								Quantity = 12,
							}, 1)

							GlobalState["Fleeca:Disable:savings_paleto"] = true
							if not _pbAlerted or os.time() > _pbAlerted then
								exports['pulsar-robbery']:TriggerPDAlert(
									source,
									vector3(-111.130, 6462.485, 31.643),
									"10-90",
									"Armed Robbery",
									{
										icon = 586,
										size = 0.9,
										color = 31,
										duration = (60 * 5),
									},
									{
										icon = "building-columns",
										details = "Blaine County Savings Bank",
									},
									"paleto"
								)
								_pbAlerted = os.time() + (60 * 10)
								exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
							end

							_pbInUse.officeSafe = false
							GlobalState["PaletoInProgress"] = true
						else
							_pbInUse.officeSafe = false
							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Failed Accessing Paleto Office Safe",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID")
								)
							)
						end
					else
						_pbInUse.officeSafe = false
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Is Already Interacting With This",
							6000
						)
					end
				else
					_pbInUse.officeSafe = false
				end
			else
				_pbInUse.officeSafe = false
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		end
	end)
end)
