local _mb = RobberyConfig.mazebank

function RegisterMBItemUses()
	exports.ox_inventory:RegisterUse("thermite", "MazeBankRobbery", function(source, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inMazeBank then
			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["MazeBankInProgress"]
				) and not GlobalState["MazeBank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _mb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["MazeBankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _mb.requiredPolice
					and not GlobalState["MazeBankInProgress"]
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

				for k, v in pairs(_mb.doors) do
					if exports['ox_doorlock']:IsLocked(v.door) and #(v.coords - myPos) <= 1.5 then
						if AreRequirementsUnlocked(v.requiredDoors) then
							if not _mbInUse[k] then
								_mbInUse[k] = source
								GlobalState["MazeBankInProgress"] = true

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
											"%s %s (%s) Started Thermiting Maze Bank Door: %s",
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
											timer = 7500,
											passReduce = 500,
											base = 16,
											cols = 5,
											rows = 5,
											anim = false,
										},
										data = {},
									}, function(success)
										if success then
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Successfully Thermited Maze Bank Door: %s",
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

											_mbGlobalReset = os.time() + _mb.resetTime
											exports['ox_doorlock']:SetLock(v.door, false)
											if not _mbAlerted or os.time() > _mbAlerted then
												exports['pulsar-robbery']:TriggerPDAlert(
													source,
													vector3(-1332.651, -846.451, 17.080),
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
														details = "Bay City Maze Bank",
													},
													"mazebank"
												)
												GlobalState["Fleeca:Disable:mazebank_baycity"] = true
												_mbAlerted = os.time() + (60 * 10)
												exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
											end
										else
											_mbGlobalReset = os.time() + _mb.resetTime
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
										end

										_mbInUse[k] = false
									end, v.door)
									break
								else
									_mbInUse[k] = false
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
		end
	end)

	exports.ox_inventory:RegisterUse("red_laptop", "MazeBankRobbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inMazeBank then
			local ped = GetPlayerPed(source)
			local myCoords = GetEntityCoords(ped)

			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["MazeBankInProgress"]
				) and not GlobalState["MazeBank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _mb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["MazeBankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _mb.requiredPolice
					and not GlobalState["MazeBankInProgress"]
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

				for k, v in pairs(_mb.hacks) do
					if #(v.coords - myCoords) <= 1.5 then
						if
							GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)] == nil
							or GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].state == 4
							and os.time() > GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].expires
						then
							if AreRequirementsUnlocked(v.requiredDoors) then
								if not _mbInUse[k] then
									_mbInUse[k] = source
									exports['pulsar-core']:LoggerInfo(
										"Robbery",
										string.format(
											"%s %s (%s) Started Hacking Maze Bank Door: %s",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID"),
											v.doorId
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
													"%s %s (%s) Successfully Hacked Maze Bank Door: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.doorId
												)
											)

											local timer = math.random(2, 4)

											exports['pulsar-hud']:Notification(source, "success",
												string.format("Time Lock Disengaging, Please Wait %s Minutes", timer),
												6000
											)

											exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot,
												1)
											_mbGlobalReset = os.time() + _mb.resetTime
											GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)] = {
												state = 2,
												expires = os.time() + (60 * timer),
											}

											GlobalState["Fleeca:Disable:mazebank_baycity"] = true
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
										else
											exports['pulsar-core']:LoggerInfo(
												"Robbery",
												string.format(
													"%s %s (%s) Failed Hacking Maze Bank Door: %s",
													char:GetData("First"),
													char:GetData("Last"),
													char:GetData("SID"),
													v.doorId
												)
											)

											local newValue = slot.CreateDate - (60 * 60 * 24)
											if type(itemData.durability) == 'number' and os.time() - itemData.durability >= newValue then
												exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
											else
												exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
											end

											_mbGlobalReset = os.time() + _mb.resetTime
											exports['pulsar-status']:Add(source, "PLAYER_STRESS", 6)
										end
										_mbInUse[k] = false
									end)
								else
									exports['pulsar-hud']:Notification(source, "error",
										"Someone Else Is Already Doing A Thing",
										6000
									)
								end
							else
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

	exports.ox_inventory:RegisterUse("adv_lockpick", "MazeBankRobbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pState = Player(source).state

		if pState.inMazeBank then
			local ped = GetPlayerPed(source)
			local myCoords = GetEntityCoords(ped)

			if
				(
					not GlobalState["AntiShitlord"]
					or os.time() > GlobalState["AntiShitlord"]
					or GlobalState["MazeBankInProgress"]
				) and not GlobalState["MazeBank:Secured"]
			then
				if
					GlobalState["RestartLockdown"] ~= false
					and (
						GetGameTimer() < _mb.serverStartWait
						or (GlobalState["RestartLockdown"] and not GlobalState["MazeBankInProgress"])
					)
				then
					exports['pulsar-hud']:Notification(source, "error",
						"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
						6000
					)
					return
				elseif
					(GlobalState["Duty:police"] or 0) < _mb.requiredPolice
					and not GlobalState["MazeBankInProgress"]
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

				for k, v in ipairs(_mb.officeDoors) do
					if #(v.coords - myCoords) <= 1.5 then
						if AreRequirementsUnlocked(v.requiredDoors) then
							if not _mbInUse[v.door] then
								_mbInUse[v.door] = source
								exports['pulsar-core']:LoggerInfo(
									"Robbery",
									string.format(
										"%s %s (%s) Started Lock Picking Maze Bank Door: %s",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										v.door
									)
								)
								exports["pulsar-core"]:ClientCallback(source, "Robbery:Games:Lockpick", {
									config = 0.75,
									data = {
										stages = 4,
									},
								}, function(success, data)
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
												"%s %s (%s) Successfully Lock Picked Maze Bank Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												v.door
											)
										)

										GlobalState["Fleeca:Disable:mazebank_baycity"] = true
										_mbGlobalReset = os.time() + _mb.resetTime
										exports['ox_doorlock']:SetLock(v.door, false)
										exports['pulsar-status']:Add(source, "PLAYER_STRESS", 3)
									else
										exports['pulsar-core']:LoggerInfo(
											"Robbery",
											string.format(
												"%s %s (%s) Failed Lock Picking Maze Bank Door: %s",
												char:GetData("First"),
												char:GetData("Last"),
												char:GetData("SID"),
												v.door
											)
										)

										_mbGlobalReset = os.time() + _mb.resetTime
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
									_mbInUse[v.door] = false
								end)
							else
								exports['pulsar-hud']:Notification(source, "error",
									"Someone Else Is Already Doing A Thing",
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
		end
	end)
end
