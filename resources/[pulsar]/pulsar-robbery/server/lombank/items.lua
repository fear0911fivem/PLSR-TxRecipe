local _lb = RobberyConfig.lombank

function RegisterLBItemUses()
	exports.ox_inventory:RegisterUse("thermite", "LombankRobbery", function(source, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inLombank then
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
				end

				local myPos = GetEntityCoords(GetPlayerPed(source))

				for k, v in pairs(_lb.thermitePoints) do
					if exports['ox_doorlock']:IsLocked(v.door) and #(v.coords - myPos) <= 1.5 then
						if AreRequirementsUnlocked(v.requiredDoors) then
							if not _lbInUse[k] then
								_lbInUse[k] = source
								GlobalState["LombankInProgress"] = true

								if
									exports.ox_inventory:RemoveSlot(
										itemData.Owner,
										itemData.Name,
										1,
										itemData.Slot,
										itemData.invType
									)
								then
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Started Thermiting Lombank Door: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											v.door
										)
									)
									exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
										passes = 1,
										location = v,
										duration = 11000,
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
													"%s %s (%s) Successfully Thermited Lombank Door: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.door
												)
											)
											if
												not GlobalState["AntiShitlord"]
												or os.time() >= GlobalState["AntiShitlord"]
											then
												GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
											end

											exports['ox_doorlock']:SetLock(v.door, false)
											GlobalState["Fleeca:Disable:lombank_legion"] = true
											if not _lbAlerted or os.time() > _lbAlerted then
												exports['pulsar-robbery']:TriggerPDAlert(
													source,
													vector3(8.976, -932.315, 29.903),
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
														details = "Legion Square Lombank",
													},
													"lombank"
												)
												_lbAlerted = os.time() + (60 * 10)
											end
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
										else
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
										end

										_lbInUse[k] = false
									end, v.door)

									break
								else
									_lbInUse[k] = false
								end
							else
								exports['pulsar-hud']:Notification(source, "error",
									"Someone Is Already Interacting With This",
									6000
								)
							end
						end
					end
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"Temporary Emergency Systems Enabled, Check Beck In A Bit",
					6000
				)
			end
		elseif pState.inLombankPower and not exports['ox_doorlock']:IsLocked("lombank_hidden_entrance") and IsLBPowerDisabled() then
			local pos = {
				coords = vector3(50.79477, -818.1543, 31.59213),
				heading = 253.851,
			}

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
				end

				local myPos = GetEntityCoords(GetPlayerPed(source))

				if #(pos.coords - myPos) <= 3.5 then
					if not _lbInUse.vaultPower then
						_lbInUse.vaultPower = source
						GlobalState["LombankInProgress"] = true

						if
							exports.ox_inventory:RemoveSlot(
								itemData.Owner,
								itemData.Name,
								1,
								itemData.Slot,
								itemData.invType
							)
						then
							exports['pulsar-core']:LoggerInfo(
								"Robbery",
								string.format(
									"%s %s (%s) Started Thermiting Lombank Vault Power",
									char:GetData("First"),
									char:GetData("Last"),
									char:GetData("SID")
								)
							)
							exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
								passes = 1,
								location = pos,
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
											"%s %s (%s) Successfully Thermited Lombank Vault Power",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID")
										)
									)
									if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
										GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
									end

									TriggerEvent("Particles:Server:DoFx", pos.coords, "spark")
									exports["pulsar-sounds"]:PlayLocation(source, pos.coords, 15.0,
										"power_small_complete_off.ogg", 0.1)

									exports['ox_doorlock']:SetLock("lombank_lasers", false)
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
									GlobalState["Fleeca:Disable:lombank_legion"] = true
									if not _lbAlerted or os.time() > _lbAlerted then
										exports['pulsar-robbery']:TriggerPDAlert(
											source,
											vector3(8.976, -932.315, 29.903),
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
												details = "Legion Square Lombank",
											},
											"lombank"
										)
										_lbAlerted = os.time() + (60 * 10)
									end
								else
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
								end

								_lbInUse.vaultPower = false
							end, "lombank_vault_power")
						else
							_lbInUse.vaultPower = false
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

	exports.ox_inventory:RegisterUse("purple_laptop", "LombankRobbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inLombank then
			local ped = GetPlayerPed(source)
			local myCoords = GetEntityCoords(ped)

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
				end

				for k, v in pairs(_lb.hackPoints) do
					if #(v.coords - myCoords) <= 1.5 then
						if AreRequirementsUnlocked(v.requiredDoors) then
							if not _lbInUse[k] then
								_lbInUse[k] = source
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started Hacking Lombank Door: %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										v.door
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Laptop", {
									location = {
										coords = v.coords,
										heading = v.heading,
									},
									config = v.config,
									data = {},
								}, function(success, data)
									if success then
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Successfully Hacked Lombank Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												v.door
											)
										)

										local timer = math.random(2, 4)

										exports['pulsar-hud']:Notification(source, "success",
											string.format("Time Lock Disengaging, Please Wait %s Minutes", timer),
											6000
										)
										table.insert(_unlockingDoors, {
											door = v.door,
											forceOpen = v.forceOpen,
											source = source,
											expires = os.time() + (60 * timer),
										})

										exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1)
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
										GlobalState["Fleeca:Disable:lombank_legion"] = true
										if not _lbAlerted or os.time() > _lbAlerted then
											exports['pulsar-robbery']:TriggerPDAlert(
												source,
												vector3(8.976, -932.315, 29.903),
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
													details = "Legion Square Lombank",
												},
												"lombank"
											)
											_lbAlerted = os.time() + (60 * 10)
										end
									else
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Failed Hacking Lombank Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												v.door
											)
										)
										exports['ox_doorlock']:SetLock(v.door, true)
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)

										if type(itemData.durability) == 'number' then
											local newValue = slot.CreateDate - math.ceil(itemData.durability / 4)
											if os.time() - itemData.durability >= newValue then
												exports.ox_inventory:RemoveId(char:GetData("SID"), 1, slot)
											else
												exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
											end
										end
									end
									_lbInUse[k] = false
								end)
							else
								exports['pulsar-hud']:Notification(source, "error",
									"Someone Else Is Already Doing A Thing",
									6000
								)
							end
						else
						end
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
end
