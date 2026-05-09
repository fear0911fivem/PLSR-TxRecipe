local _pb = RobberyConfig.paleto

function RegisterPBItems()
	exports.ox_inventory:RegisterUse("thermite", "PaletoRobbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inSubStation then
			local subStationId = pState.inSubStation
			local substation = _pb.subStations[subStationId]
			if substation ~= nil then
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
								"Substation Security Measures Still Engaged, This Would Not Be Effective",
								6000
							)
							return
						elseif (_bankStates.paleto.substations[subStationId] or 0) > os.time() then
							exports['pulsar-hud']:Notification(source, "error",
								"This Substation Is Already Disabled", 6000)
							return
						end
						local myPos = GetEntityCoords(GetPlayerPed(source))
						if #(substation.thermite.coords - myPos) <= 1.5 then
							if not _pbInUse.substations[subStationId] then
								_pbInUse.substations[subStationId] = source
								GlobalState["PaletoInProgress"] = true

								if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Started Thermiting Paleto Sub Station #%s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											subStationId
										)
									)
									exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
										passes = 1,
										location = substation.thermite,
										duration = 25000,
										config = {
											countdown = 3,
											preview = 2000,
											timer = 20000,
											passReduce = 500,
											base = 22,
											cols = 6,
											rows = 6,
											strikes = 5,
											anim = false,
										},
										data = {},
									}, function(success)
										if success then
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Successfully Thermited Paleto Sub Station #%s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													subStationId
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
											exports['pulsar-robbery']:StateUpdate("paleto", subStationId, _pbGlobalReset,
												"substations")

											TriggerEvent("Particles:Server:DoFx", substation.thermite.coords, "spark")

											for k, v in ipairs(substation.explosions) do
												TriggerClientEvent("Robbery:Client:BombFx", source, v)
											end

											if IsPaletoPowerDisabled() then
												exports["pulsar-sounds"]:PlayLocation(
													source,
													substation.thermite.coords,
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

												exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", false)
												exports['pulsar-cctv']:StateGroupOffline("paleto")
											else
												exports["pulsar-sounds"]:PlayLocation(
													source,
													substation.thermite.coords,
													15.0,
													"power_small_complete_off.ogg",
													0.1
												)
												exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", true)
												exports['pulsar-cctv']:StateGroupOnline("paleto")
											end

											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
											GlobalState["Fleeca:Disable:savings_paleto"] = true
										else
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Failed Thermiting Paleto Sub Station #%s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													subStationId
												)
											)
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
										end

										_pbInUse.substations[subStationId] = false
									end, string.format("paleto_substation_%s", subStationId))
								else
									_pbInUse.substations[subStationId] = false
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
			end
		elseif pState.inPaletoBank then
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
							"Substation Security Measures Still Engaged, This Would Not Be Effective",
							6000
						)
						return
					elseif not IsPaletoPowerDisabled() then
						exports['pulsar-hud']:Notification(source, "error",
							"Regional Power Is Still Active", 6000)
						return
					end

					local ped = GetPlayerPed(source)
					local myCoords = GetEntityCoords(ped)

					for k, v in ipairs(_pb.doorThermite) do
						if exports['ox_doorlock']:IsLocked(v.door) then
							if #(v.coords - myCoords) <= 1.5 then
								if AreRequirementsUnlocked(v.requiredDoors) then
									if not _pbInUse[v.door] then
										_pbInUse[v.door] = source
										GlobalState["PaletoInProgress"] = true

										if
											exports.ox_inventory:RemoveSlot(
												slot.Owner,
												slot.Name,
												1,
												slot.Slot,
												slot.invType
											)
										then
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Started Hacking Paleto Door: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.door
												)
											)
											exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
												passes = 1,
												location = v,
												duration = 25000,
												config = {
													countdown = 3,
													preview = 2000,
													timer = 20000,
													passReduce = 500,
													base = 18,
													cols = 7,
													rows = 7,
													strikes = 5,
													anim = false,
												},
												data = {},
											}, function(success)
												if success then
													exports['pulsar-core']:LoggerInfo(
														"Robbery",
														string.format(
															"%s %s (%s) Successfully Thermited Paleto Door: %s",
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
														GlobalState["AntiShitlord"] = os.time() +
															(60 * math.random(10, 15))
													end

													exports['ox_doorlock']:SetLock(v.door, false)
													GlobalState["Fleeca:Disable:savings_paleto"] = true
													if not _pbAlerted or os.time() > _pbAlerted then
														exports['pulsar-robbery']:TriggerPDAlert(
															source,
															vector3(-111.092, 6462.361, 31.643),
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

												_pbInUse[v.door] = false
											end, string.format("paleto_doorshit_%s", v.door))

											return
										else
											_pbInUse[v.door] = false
										end
									else
										exports['pulsar-hud']:Notification(source, "error",
											"Someone Else Is Already Doing A Thing",
											6000
										)
									end

									return
								end
							end
						end
					end

					if exports['ox_doorlock']:IsLocked("pulsar_bank_savings_paleto_security") then
						for k, v in ipairs(_pb.securityPower) do
							if #(v.coords - myCoords) <= 1.5 then
								if AreRequirementsUnlocked(v.requiredDoors) then
									if not _pbInUse.securityAccess[v.powerId] then
										_pbInUse.securityAccess[v.powerId] = source
										GlobalState["PaletoInProgress"] = true

										if
											exports.ox_inventory:RemoveSlot(
												slot.Owner,
												slot.Name,
												1,
												slot.Slot,
												slot.invType
											)
										then
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Started Thermiting Paleto Security Power: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.powerId
												)
											)
											exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Thermite", {
												passes = 1,
												location = v,
												duration = 25000,
												config = {
													countdown = 3,
													preview = 2000,
													timer = 20000,
													passReduce = 500,
													base = 24,
													cols = 7,
													rows = 7,
													strikes = 5,
													anim = false,
												},
												data = {},
											}, function(success)
												if success then
													exports['pulsar-core']:LoggerInfo(
														"Robbery",
														string.format(
															"%s %s (%s) Successfully Thermited Paleto Security Power: %s",
															char:GetData("First"),
															char:GetData("Last"),
															char:GetData("SID"),
															v.powerId
														)
													)
													if
														not GlobalState["AntiShitlord"]
														or os.time() >= GlobalState["AntiShitlord"]
													then
														GlobalState["AntiShitlord"] = os.time() +
															(60 * math.random(10, 15))
													end

													for k2, v2 in ipairs(v.ptfx) do
														TriggerEvent("Particles:Server:DoFx", v2, "spark")
													end

													if not _pbGlobalReset or os.time() > _pbGlobalReset then
														_pbGlobalReset = os.time() + _pb.resetTime
													end
													exports['pulsar-robbery']:StateUpdate(
														"paleto",
														v.powerId,
														_pbGlobalReset,
														"securityPower"
													)

												if IsSecurityAccessible() then
													exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_security",
														false)
												else
													exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_security",
														true)
												end													GlobalState["Fleeca:Disable:savings_paleto"] = true
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

												_pbInUse.securityAccess[v.powerId] = false
											end, string.format("paleto_security_%s", v.powerId))

											return
										else
											_pbInUse.securityAccess[v.powerId] = false
										end
									else
										exports['pulsar-hud']:Notification(source, "error",
											"Someone Else Is Already Doing A Thing",
											6000
										)
									end
								end
							end
						end
					end
				end
			end
		end
	end)

	exports.ox_inventory:RegisterUse("yellow_laptop", "PaletoRobbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inPaletoBank then
			local ped = GetPlayerPed(source)
			local myCoords = GetEntityCoords(ped)

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
							"Network Firewalls Still Active, Cannot Do This Yet",
							6000
						)
						return
					elseif not _bankStates.paleto.vaultTerminal then
						exports['pulsar-hud']:Notification(source, "error",
							"Terminal Security Override Still Enganged, Find A Way To Disable This",
							6000
						)
						return
					end

					for k, v in pairs(_pb.hackPoints) do
						if #(v.coords - myCoords) <= 1.5 then
							if AreRequirementsUnlocked(v.requiredDoors) then
								if not _pbInUse[k] then
									_pbInUse[k] = source
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Started Hacking Paleto Door: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											v.door
										)
									)
									exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Captcha", {
										location = {
											coords = v.coords,
											heading = v.heading,
										},
										passes = 3,
										config = {
											preview = 3,
											timer = 1500,
											limit = 10000,
											difficulty = 4,
											difficulty2 = 2,
											anim = {
												anim = "type",
											},
										},
										data = {},
									}, function(success, data)
										if success then
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Successfully Hacked Paleto Door: %s",
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

											exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot,
												1)
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
											GlobalState["Fleeca:Disable:savings_paleto"] = true
										else
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Failed Hacking Paleto Door: %s",
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
										_pbInUse[k] = false
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
