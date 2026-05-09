SLIM_JIM_ATTEMPTS = {}

local _actionShowing = false

_vehicleClasses = {
	X = {
		value = 2000000,
		lockpick = {
			exterior = { stages = { 2, 3, 4, 5, 6, 7, 8 }, base = 5 },
			interior = { stages = { 2, 3, 4, 5, 6, 7, 8 }, base = 5 },
		},
		advLockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2, 1.4, 1.6 }, base = 5 },
			interior = { stages = { 0.8, 1.0, 1.2, 1.4, 1.6 }, base = 5 },
		},
		hack = {
			exterior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
			interior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
		},
		advHack = {
			exterior = { rows = 10, length = 5, duration = 15000, charSize = 2 },
			interior = { rows = 10, length = 5, duration = 15000, charSize = 2 },
		},
	},
	S = {
		value = 1000000,
		lockpick = {
			exterior = { stages = { 2, 3, 4, 5, 6 }, base = 5 },
			interior = { stages = { 2, 3, 4, 5, 6 }, base = 5 },
		},
		advLockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2, 1.4 }, base = 5 },
			interior = { stages = { 0.8, 1.0, 1.2, 1.4 }, base = 5 },
		},
		hack = {
			exterior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
			interior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
		},
		advHack = {
			exterior = { rows = 9, length = 4, duration = 20000, charSize = 2 },
			interior = { rows = 9, length = 4, duration = 20000, charSize = 2 },
		},
		topSpeed = 160.0, -- IN MPH (IS CONVERTED LATER)
	},
	A = {
		value = 500000,
		lockpick = {
			exterior = { stages = { 2, 3, 4, 5 }, base = 5 },
			interior = { stages = { 2, 3, 4, 5 }, base = 5 },
		},
		advLockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2 }, base = 5 },
			interior = { stages = { 0.8, 1.0, 1.2 }, base = 5 },
		},
		hack = {
			exterior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
			interior = { rows = 14, length = 8, duration = 18000, charSize = 2 },
		},
		advHack = {
			exterior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
			interior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
		},
		topSpeed = 150.0,
	},
	B = {
		value = 350000,
		lockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2, 1.4, 1.6 }, base = 6 },
			interior = { stages = { 0.8, 1.0, 1.2, 1.4, 1.6 }, base = 6 },
		},
		advLockpick = {
			exterior = { stages = { 0.4, 0.5 }, base = 4 },
			interior = { stages = { 0.4, 0.5 }, base = 4 },
		},
		hack = {
			exterior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
			interior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
		},
		advHack = {
			exterior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
			interior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
		},
		topSpeed = 140.0,
	},
	C = {
		value = 250000,
		lockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2, 1.4 }, base = 6 },
			interior = { stages = { 0.8, 1.0, 1.2, 1.4 }, base = 6 },
		},
		advLockpick = {
			exterior = { stages = { 0.4, 0.5 }, base = 5 },
			interior = { stages = { 0.4, 0.5 }, base = 5 },
		},
		hack = {
			exterior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
			interior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
		},
		advHack = {
			exterior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
			interior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
		},
		topSpeed = 120.0,
	},
	D = {
		value = 150000,
		lockpick = {
			exterior = { stages = { 0.8, 1.0, 1.2 }, base = 6 },
			interior = { stages = { 0.8, 1.0, 1.2 }, base = 6 },
		},
		advLockpick = {
			exterior = { stages = { 0.4, 0.5 }, base = 5 },
			interior = { stages = { 0.4, 0.5 }, base = 5 },
		},
		hack = {
			exterior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
			interior = { rows = 8, length = 4, duration = 30000, charSize = 2, charSet = "alphanumer" },
		},
		advHack = {
			exterior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
			interior = { rows = 6, length = 3, duration = 20000, charSize = 1, charSet = "alphanumer" },
		},
		topSpeed = 110.0,
	},
}

exports("EngineForce", function(veh, state)
	local vehState = Entity(veh).state

	if state and vehState.Fuel and vehState.Fuel <= 0.0 then
		state = false
		exports["pulsar-hud"]:Notification("error", 'Vehicle Out of Fuel', 2500, 'gas-pump')
	end

	if state and GetVehicleEngineHealth(veh) <= -2000.0 then
		state = false
		exports["pulsar-hud"]:Notification("error", 'Vehicle Engine Damaged', 2500, 'engine-warning')
	end

	if state then
		if not vehState.VEH_IGNITION then
			vehState:set('VEH_IGNITION', true, true)
		end
		SetVehicleEngineOn(veh, true, false, true)
		SetVehicleUndriveable(veh, false)

		if _actionShowing then
			exports['pulsar-hud']:ActionHide('engine')
			_actionShowing = false
		end
	else
		if vehState.VEH_IGNITION then
			vehState:set('VEH_IGNITION', false, true)
		end
		SetVehicleEngineOn(veh, false, true, true)
		SetVehicleUndriveable(veh, true)
	end

	TriggerEvent('Vehicles:Client:Ignition', state)
end)

exports("EngineOff", function(customMessage)
	local vehEnt = Entity(VEHICLE_INSIDE)
	exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, false)
	exports["pulsar-hud"]:Notification("info", customMessage and customMessage or 'Engine Turned Off', 1500, 'car')

	if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
		exports['pulsar-hud']:ActionShow('engine', '{keybind}toggle_engine{/keybind} Turn Engine On')
		_actionShowing = true
	end
end)

exports("EngineOn", function()
	local vehEnt = Entity(VEHICLE_INSIDE)

	if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
		exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, true)
		exports["pulsar-hud"]:Notification("info", 'Engine Turned On', 1500, 'car-on')
	else
		exports["pulsar-hud"]:Notification("error", 'You Don\'t Have Keys For This Vehicle', 3000, 'key')
	end
end)

exports("EngineCheckKeys", function()
	local vehEnt = Entity(VEHICLE_INSIDE)

	if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
		return true
	else
		exports["pulsar-hud"]:Notification("error", 'You Don\'t Have Keys For This Vehicle', 3000, 'key')
		return false
	end
end)

exports("EngineToggle", function()
	local vehEnt = Entity(VEHICLE_INSIDE)

	if vehEnt.state.VEH_IGNITION then
		exports['pulsar-vehicles']:EngineOff()
	else
		exports['pulsar-vehicles']:EngineOn()
	end
end)

exports("SlimJim", function(vehicle)
	local vehEnt = Entity(vehicle)
	local val = GetVehicleHandlingInt(vehicle, "CHandlingData", "nMonetaryValue")

	if not vehEnt.state.towObjective then
		if vehEnt and vehEnt.state and vehEnt.state.VIN and not exports['pulsar-vehicles']:HasAccess(vehicle) then
			local vVIN = vehEnt.state.VIN

			if SLIM_JIM_ATTEMPTS[vVIN] and SLIM_JIM_ATTEMPTS[vVIN] > 3 then
				exports["pulsar-hud"]:Notification("error", "You Have Tried This Vehicle Enough Already")
				return
			end

			local setToFail = false
			if vehEnt.state.Owned or val > 100000 then
				setToFail = true
			end

			local randomValue = math.random(0, 60)
			if randomValue <= 20 and randomValue >= 5 then
				setToFail = true
			end

			local startCoords = GetEntityCoords(GLOBAL_PED)
			TaskTurnPedToFaceEntity(GLOBAL_PED, vehicle, 500)

			local dumbAnim = true

			RequestAnimDict("veh@break_in@0h@p_m_one@")
			while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
				Wait(5)
			end

			CreateThread(function()
				while dumbAnim do
					TaskPlayAnim(
						GLOBAL_PED,
						"veh@break_in@0h@p_m_one@",
						"low_force_entry_ds",
						1.0,
						1.0,
						1.0,
						16,
						0.0,
						0,
						0,
						0
					)
					Wait(1000)

					if math.random(100) <= 50 then
						SetVehicleAlarm(VEHICLE_INSIDE, true)
						SetVehicleAlarmTimeLeft(VEHICLE_INSIDE, 1000)
						StartVehicleAlarm(VEHICLE_INSIDE)
					end
				end
			end)

			exports['pulsar-games']:MinigamePlayRoundSkillbar(12, 3, {
				onSuccess = function()
					dumbAnim = false
					ClearPedTasks(GLOBAL_PED)
					if not SLIM_JIM_ATTEMPTS[vVIN] then
						SLIM_JIM_ATTEMPTS[vVIN] = 1
					else
						SLIM_JIM_ATTEMPTS[vVIN] = SLIM_JIM_ATTEMPTS[vVIN] + 1
					end

					if setToFail then
						exports["pulsar-hud"]:Notification("error", "It Was too Difficult and It Didn't Work")
					else
						if #(startCoords - GetEntityCoords(GLOBAL_PED)) <= 2.0 then
							SetVehicleHasBeenOwnedByPlayer(vehicle, true)
							SetEntityAsMissionEntity(vehicle, true, true)
							exports["pulsar-core"]:ServerCallback("Vehicles:BreakOpenLock", {
								netId = VehToNet(vehicle),
							}, function(success)
								exports["pulsar-hud"]:Notification("success", "You Managed to Unlock the Vehicle", 3000,
									"key")
							end)
						else
							exports["pulsar-hud"]:Notification("error", "Too Far")
						end
					end
				end,
				onFail = function()
					dumbAnim = false
					ClearPedTasks(GLOBAL_PED)
					if not SLIM_JIM_ATTEMPTS[vVIN] then
						SLIM_JIM_ATTEMPTS[vVIN] = 1
					else
						SLIM_JIM_ATTEMPTS[vVIN] = SLIM_JIM_ATTEMPTS[vVIN] + 1
					end
					exports["pulsar-hud"]:Notification("error", "It Was too Difficult and It Didn't Work")
				end,
			}, {
				useWhileDead = false,
				vehicle = false,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
			})
		end
	else
		exports["pulsar-hud"]:Notification("error", "You Cannot Slimjim This Vehicle", 3000, 'key')
	end
end)

exports("LockpickExterior", function(config, canUnlockOwned, vehicle, cb)
	local vehEnt = Entity(vehicle)
	local val = GetVehicleHandlingInt(vehicle, "CHandlingData", "nMonetaryValue")

	local team = LocalPlayer.state.Character:GetData("Team")

	if
		not vehEnt.state.towObjective
		and not exports['pulsar-police']:IsPdCar(vehicle)
		and not vehEnt.state.noLockpick
		and (not vehEnt.state.boostVehicle or vehEnt.state.boostVehicle == team)
	then
		if vehEnt and vehEnt.state and vehEnt.state.VIN then
			local vVIN = vehEnt.state.VIN

			if exports['pulsar-vehicles']:KeysHas(vVIN, vehEnt.state.GroupKeys) then
				return cb(false)
			end

			if not vehEnt.state.Locked then
				return cb(false)
			end

			local alerted = false
			local startCoords = GetEntityCoords(GLOBAL_PED)
			TaskTurnPedToFaceEntity(GLOBAL_PED, vehicle, 500)

			local dumbAnim = true
			RequestAnimDict("veh@break_in@0h@p_m_one@")
			while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
				Wait(5)
			end

			TriggerEvent("Laptop:Client:LSUnderground:Boosting:AttemptExterior", vehicle)

			CreateThread(function()
				while dumbAnim do
					TaskPlayAnim(
						GLOBAL_PED,
						"veh@break_in@0h@p_m_one@",
						"low_force_entry_ds",
						1.0,
						1.0,
						1.0,
						16,
						0.0,
						0,
						0,
						0
					)
					Wait(1000)
				end
			end)

			local wasFailed = false
			for k, v in ipairs(config.stages) do
				local alarmRoll = math.random(100)
				if alarmRoll <= 20 then
					SetVehicleAlarm(vehicle, true)
					SetVehicleAlarmTimeLeft(vehicle, math.random(25, 40) * 100)
					StartVehicleAlarm(vehicle)
					if not alerted and not Entity(vehicle).state.boostVehicle then
						exports['pulsar-mdt']:EmergencyAlertsCreateIfReported(200.0, "lockpickext", true)
						alerted = true
					end
				end

				local stageComplete = false
				if wasFailed then
					break
				end

				exports['pulsar-games']:MinigamePlayRoundSkillbar(v, config.base - k, {
					onSuccess = function()
						Wait(400)
						stageComplete = true
					end,
					onFail = function()
						wasFailed = true
						stageComplete = true
					end,
				}, {
					useWhileDead = false,
					vehicle = false,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
					animation = {
						animDict = "veh@break_in@0h@p_m_one@",
						anim = "low_force_entry_ds",
						flags = 16,
					},
				})

				while not stageComplete do
					Wait(1)
				end
			end

			dumbAnim = false
			ClearPedTasks(GLOBAL_PED)

			if not wasFailed then
				if #(startCoords - GetEntityCoords(GLOBAL_PED)) <= 2.0 and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 5.0 then
					SetVehicleHasBeenOwnedByPlayer(vehicle, true)
					SetEntityAsMissionEntity(vehicle, true, true)
					if vehEnt.state.Owned and not canUnlockOwned then
						exports["pulsar-hud"]:Notification("error", "It Was Too Hard", 3000, 'key')
						return cb(true, false)
					end

					exports["pulsar-core"]:ServerCallback("Vehicles:BreakOpenLock", {
						netId = VehToNet(vehicle),
					}, function(success)
						if success then
							exports["pulsar-hud"]:Notification("success", "Vehicle Unlocked", 3000, "key")
						end
					end)

					cb(true, true)
				else
					exports["pulsar-hud"]:Notification("error", "Too Far")

					cb(false, false)
				end
			else
				cb(true, false)
			end
		end
	else
		exports["pulsar-hud"]:Notification("error", "You Cannot Lockpick This Vehicle", 3000, 'key')
	end
end)

exports("Lockpick", function(config, canUnlockOwned, cb)
	local vehEnt = Entity(VEHICLE_INSIDE)
	local team = LocalPlayer.state.Character:GetData("Team")

	if
		not vehEnt.state.towObjective
		and not vehEnt.state.noLockpick
		and (not vehEnt.state.boostVehicle or vehEnt.state.boostVehicle == team)
	then
		if vehEnt and vehEnt.state and vehEnt.state.VIN then
			local vVIN = vehEnt.state.VIN

			if exports['pulsar-vehicles']:KeysHas(vVIN, vehEnt.state.GroupKeys) then
				return cb(false, false)
			end

			local alerted = false
			local wasFailed = false

			for k, v in ipairs(config.stages) do
				local alarmRoll = math.random(100)
				if alarmRoll <= 20 then
					SetVehicleAlarm(VEHICLE_INSIDE, true)
					SetVehicleAlarmTimeLeft(VEHICLE_INSIDE, math.random(15, 30) * 100)
					StartVehicleAlarm(VEHICLE_INSIDE)
					if not alerted and not Entity(VEHICLE_INSIDE).state.boostVehicle then
						if exports['pulsar-mdt']:EmergencyAlertsCreateIfReported(200.0, "lockpickint", true) then
							TriggerServerEvent('Radar:Server:StolenVehicle',
								GetVehicleNumberPlateText(VEHICLE_INSIDE))
						end
						alerted = true
					end
				end

				local stageComplete = false
				if wasFailed then
					break
				end

				exports['pulsar-games']:MinigamePlayRoundSkillbar(v, config.base - k, {
					onSuccess = function()
						Wait(400)
						stageComplete = true
					end,
					onFail = function()
						wasFailed = true
						stageComplete = true
					end,
				}, {
					useWhileDead = false,
					vehicle = true,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
					animation = {
						animDict = "veh@break_in@0h@p_m_one@",
						anim = "low_force_entry_ds",
						flags = 16,
					},
				})

				while not stageComplete do
					Wait(1)
				end
			end

			if not wasFailed then
				if VEHICLE_INSIDE and VEHICLE_SEAT == -1 then
					SetVehicleHasBeenOwnedByPlayer(VEHICLE_INSIDE, true)
					SetEntityAsMissionEntity(VEHICLE_INSIDE, true, true)
					if vehEnt.state.Owned and not canUnlockOwned then
						exports["pulsar-hud"]:Notification("error", "It Was Too Hard", 3000, 'key')
						return cb(true, false)
					end

					exports["pulsar-core"]:ServerCallback("Vehicles:GetKeys", vehEnt.state.VIN, function(success)
						exports["pulsar-hud"]:Notification("success", "Lockpicked Vehicle Ignition", 3000, 'key')
						exports['pulsar-hud']:ActionShow('engine', '{keybind}toggle_engine{/keybind} Turn Engine On')
						_actionShowing = true

						TriggerEvent("Laptop:Client:LSUnderground:Boosting:SuccessIgnition", VEHICLE_INSIDE)
					end)

					cb(true, true)
				else
					cb(true, false)
				end
			else
				cb(true, false)
			end
		end
	else
		exports["pulsar-hud"]:Notification("error", "You Cannot Lockpick This Vehicle", 3000, 'key')
	end
end)

exports("HackExterior", function(hackData, canUnlockOwned, vehicle, cb)
	local vehEnt = Entity(vehicle)
	local val = GetVehicleHandlingInt(vehicle, "CHandlingData", "nMonetaryValue")
	local team = LocalPlayer.state.Character:GetData("Team")

	if
		not vehEnt.state.towObjective
		and not vehEnt.state.noLockpick
		and (not vehEnt.state.boostVehicle or vehEnt.state.boostVehicle == team)
	then
		if vehEnt and vehEnt.state and vehEnt.state.VIN then
			local startCoords = GetEntityCoords(GLOBAL_PED)
			TaskTurnPedToFaceEntity(GLOBAL_PED, vehicle, 500)
			TriggerEvent("Laptop:Client:LSUnderground:Boosting:AttemptExterior", vehicle)

			exports['pulsar-games']:MinigamePlayPattern(
				3,
				hackData.duration,
				hackData.rows,
				hackData.length,
				hackData.charSize,
				hackData.charSet or false, {
					onSuccess = function()
						if #(startCoords - GetEntityCoords(GLOBAL_PED)) <= 2.0 then
							SetVehicleHasBeenOwnedByPlayer(vehicle, true)
							SetEntityAsMissionEntity(vehicle, true, true)

							exports["pulsar-core"]:ServerCallback("Vehicles:BreakOpenLock", {
								netId = VehToNet(vehicle),
							}, function(success)
								if success then
									exports["pulsar-hud"]:Notification("success", "Vehicle Unlocked", 3000, "key")
								end
							end)

							cb(true, true)
						else
							exports["pulsar-hud"]:Notification("error", "Too Far")

							cb(false, false)
						end
					end,
					onFail = function()
						cb(true, false)
					end,
				}, {
					useWhileDead = false,
					vehicle = false,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
					animation = {
						animDict = "amb@medic@standing@kneel@base",
						anim = "base",
						flags = 16,
					},
				})
		end
	else
		exports["pulsar-hud"]:Notification("error", "You Cannot Lockpick This Vehicle", 3000, 'key')
	end
end)

exports("Hack", function(hackData, canUnlockOwned, cb)
	local vehEnt = Entity(VEHICLE_INSIDE)
	local val = GetVehicleHandlingInt(VEHICLE_INSIDE, "CHandlingData", "nMonetaryValue")
	local team = LocalPlayer.state.Character:GetData("Team")

	if
		not vehEnt.state.towObjective
		and not vehEnt.state.noLockpick
		and (not vehEnt.state.boostVehicle or vehEnt.state.boostVehicle == team)
	then
		if vehEnt and vehEnt.state and vehEnt.state.VIN then
			local startCoords = GetEntityCoords(GLOBAL_PED)
			TaskTurnPedToFaceEntity(GLOBAL_PED, VEHICLE_INSIDE, 500)

			exports['pulsar-games']:MinigamePlayPattern(
				3,
				hackData.duration,
				hackData.rows,
				hackData.length,
				hackData.charSize,
				hackData.charSet or false, {
					onSuccess = function()
						if VEHICLE_INSIDE and VEHICLE_SEAT == -1 then
							SetVehicleHasBeenOwnedByPlayer(VEHICLE_INSIDE, true)
							SetEntityAsMissionEntity(VEHICLE_INSIDE, true, true)
							if vehEnt.state.Owned and not canUnlockOwned then
								exports["pulsar-hud"]:Notification("error", "It Was Too Hard", 3000, 'key')
								return cb(true, false)
							end

							exports["pulsar-core"]:ServerCallback("Vehicles:GetKeys", vehEnt.state.VIN,
								function(success)
									exports["pulsar-hud"]:Notification("success", "Vehicle Ignition Bypassed", 3000,
										'key')
									exports['pulsar-hud']:ActionShow('engine',
										'{keybind}toggle_engine{/keybind} Turn Engine On')
									_actionShowing = true

									TriggerEvent("Laptop:Client:LSUnderground:Boosting:SuccessIgnition",
										VEHICLE_INSIDE)
								end)

							cb(true, true)
						else
							cb(true, false)
						end
					end,
					onFail = function()
						cb(true, false)
					end,
				}, {
					useWhileDead = false,
					vehicle = true,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
					animation = {
						animDict = "veh@break_in@0h@p_m_one@",
						anim = "low_force_entry_ds",
						flags = 16,
					},
				})
		end
	else
		exports["pulsar-hud"]:Notification("error", "You Cannot Lockpick This Vehicle", 3000, 'key')
	end
end)

exports("CanBeStored", function(vehicle)
	local vehicleCoords = GetEntityCoords(vehicle)
	local inVehicleStorageZone, vehicleStorageZoneId = GetVehicleStorageAtCoords(vehicleCoords)
	return inVehicleStorageZone or exports['pulsar-properties']:GetNearHouseGarage(vehicleCoords)
end)

exports("PropertiesGet", function(vehicle)
	return GetVehicleProperties(vehicle)
end)

exports("PropertiesSet", function(vehicle, data)
	return SetVehicleProperties(vehicle, data)
end)

exports("UtilsIsCloseToRearOfVehicle", function(vehicle, coords)
	if not coords then
		coords = LocalPlayer.state.myPos
	end

	return IsCloseToFrontOfVehicle(vehicle, coords)
end)

exports("UtilsIsCloseToFrontOfVehicle", function(vehicle, coords)
	if not coords then
		coords = LocalPlayer.state.myPos
	end

	return IsCloseToRearOfVehicle(vehicle, coords)
end)

exports("UtilsIsCloseToVehicle", function(vehicle, coords)
	if not coords then
		coords = LocalPlayer.state.myPos
	end

	return IsCloseToVehicle(vehicle, coords)
end)

exports("ClassGet", function(entity)
	if GetVehicleClass(entity) == 15 or GetVehicleClass(entity) == 16 or GetVehicleClass(entity) == 19 then
		return "S"
	end

	local value = GetVehicleHandlingInt(entity, "CHandlingData", "nMonetaryValue")
	for k, v in pairs(_vehicleClasses) do
		if value == v.value then
			return k
		end
	end

	return "D"
end)

exports("IsClass", function(entity, class)
	local entClass = exports['pulsar-vehicles']:ClassGet(entity)
	return entClass == class
end)

exports("IsClassOrHigher", function(entity, class)
	return _vehicleClasses[exports['pulsar-vehicles']:ClassGet(entity)].value >=
		(_vehicleClasses[class] and _vehicleClasses[class].value or 10000)
end)

AddEventHandler("Vehicles:Client:EnterVehicle", function(veh)
	local vehEnt = Entity(VEHICLE_INSIDE)

	TriggerEvent("Vehicles:Client:Seatbelt", false)

	Wait(1000)

	TriggerEvent("Vehicles:Client:Ignition", vehEnt.state.VEH_IGNITION)
end)

AddEventHandler('Vehicles:Client:BecameDriver', function(veh, seat)
	local vehClass = exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)
	local vehEnt = Entity(VEHICLE_INSIDE)

	if vehEnt.state.VEH_IGNITION == nil then
		exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, GetIsVehicleEngineRunning(VEHICLE_INSIDE))
	else
		exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, vehEnt.state.VEH_IGNITION)
	end

	if GetVehicleClass(VEHICLE_INSIDE) == 13 then
		exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, true)
	end

	while IsVehicleNeedsToBeHotwired(VEHICLE_INSIDE) do
		Wait(0)
		SetVehicleNeedsToBeHotwired(VEHICLE_INSIDE, false)
	end

	SetVehRadioStation(VEHICLE_INSIDE, "OFF")

	if vehEnt.state.VEH_IGNITION then
		if not vehEnt.state.PlayerDriven then -- It was stolen directly with a ped in it, get keys
			exports['pulsar-vehicles']:EngineForce(VEHICLE_INSIDE, true)
			exports["pulsar-core"]:ServerCallback('Vehicles:GetKeys', vehEnt.state.VIN, function(success)
				if success then
					exports["pulsar-hud"]:Notification("success", 'You found the keys in the vehicle', 3000, 'key')
				else
					exports["pulsar-hud"]:Notification("error", 'Couldn\'t find keys in the vehicle', 3000)
				end
			end)
		end
	else
		if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
			exports['pulsar-hud']:ActionShow('engine', '{keybind}toggle_engine{/keybind} Turn Engine On')
			_actionShowing = true
		end
	end

	if not vehEnt.state.PlayerDriven then
		vehEnt.state:set('PlayerDriven', true, true)
	end

	vehEnt.state:set('LastDriven', GetCloudTimeAsInt(), true)
end)

AddEventHandler('Vehicles:Client:ExitVehicle', function(veh)
	if _actionShowing then
		exports['pulsar-hud']:ActionHide('engine')
		_actionShowing = false
	end

	if veh and DoesEntityExist(veh) then
		local sb = Entity(veh).state
		if sb and sb.VEH_IGNITION then
			SetVehicleEngineOn(veh, true, true, true)
		else
			SetVehicleEngineOn(veh, false, true, true)
		end
	end
end)

AddEventHandler("Vehicles:Client:InspectVIN", function(entityData)
	if entityData and entityData.entity then
		if exports['pulsar-vehicles']:HasAccess(entityData.entity) then
			exports['pulsar-hud']:Progress({
				name = "inspect_vin",
				duration = 4000,
				label = "Inspecting VIN",
				useWhileDead = false,
				canCancel = true,
				ignoreModifier = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					anim = "tablet2",
				},
			}, function(cancelled)
				if not cancelled then
					TriggerServerEvent("Vehicle:Server:InspectVIN", VehToNet(entityData.entity))
				end
			end)
		end
	end
end)

RegisterNetEvent("Vehicles:Client:ViewVIN", function(VIN)
	exports['pulsar-hud']:ListMenuShow({
		main = {
			label = 'VIN Inspection',
			items = {
				{
					label = 'Vehicle Identification Number',
					description = VIN,
				},
			},
		},
	})
end)

RegisterNetEvent("Vehicles:Client:AttemptSlimJim", function()
	if not VEHICLE_INSIDE and _characterLoaded then
		local playerCoords = GetEntityCoords(PlayerPedId())
		local maxDistance = 2.0
		local includePlayerVehicle = true

		local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
		if
			vehicle
			and DoesEntityExist(vehicle)
			and IsEntityAVehicle(vehicle)
			and IsThisModelACar(GetEntityModel(vehicle))
			and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
		then
			exports['pulsar-vehicles']:SlimJim(vehicle)
		end
	end
end)

AddEventHandler("Vehicles:Client:StartUp", function()
	exports["pulsar-core"]:RegisterClientCallback("Vehicles:Slimjim", function(data, cb)
		print("Vehicles:Slimjim")
		if _characterLoaded and LocalPlayer.state.onDuty == "police" then
			if not VEHICLE_INSIDE then
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				if
					vehicle
					and DoesEntityExist(vehicle)
					and IsEntityAVehicle(vehicle)
					and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
				then
					local vehClass = _vehicleClasses.C
					if vehClass and vehClass.advLockpick then
						exports['pulsar-vehicles']:LockpickExterior(vehClass.advLockpick.exterior, data, vehicle,
							cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Slimjim This Vehicle")
					end
				else
					print('nope2')
					cb(false, false)
				end
			end
		else
			print('nope')
			cb(false, false)
		end
	end)

	exports["pulsar-core"]:RegisterClientCallback("Vehicles:Lockpick", function(data, cb)
		if _characterLoaded then
			if VEHICLE_INSIDE then
				if VEHICLE_SEAT == -1 then
					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)]
					local boostOverride = Entity(VEHICLE_INSIDE).state.boostForceHack

					if vehClass and vehClass.lockpick and not boostOverride then
						exports['pulsar-vehicles']:Lockpick(vehClass.lockpick.interior, data, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
						cb(false, false)
					end
				else
					cb(false, false)
				end
			else
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				
				if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
					local distance = #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED))
					
					if distance <= 2.0 then
						-- Request VIN generation if vehicle doesn't have one
						local vehEnt = Entity(vehicle)
						
						if not vehEnt.state.VIN then
							TriggerServerEvent("Vehicles:Server:RequestGenerateVehicleInfo", VehToNet(vehicle))
							-- Wait for the server to generate and sync the VIN
							local attempts = 0
							while not vehEnt.state.VIN and attempts < 20 do
								Wait(100)
								attempts = attempts + 1
							end
							
							if not vehEnt.state.VIN then
								exports["pulsar-hud"]:Notification("error", "Failed to Initialize Vehicle", 3000)
								return cb(false, false)
							end
						end

						local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(vehicle)]
						local boostOverride = Entity(vehicle).state.boostForceHack

						if vehClass and vehClass.lockpick and not boostOverride then
							exports['pulsar-vehicles']:LockpickExterior(vehClass.lockpick.exterior, data, vehicle, cb)
						else
							exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
							cb(false, false)
						end
					else
						cb(false, false)
					end
				else
					cb(false, false)
				end
			end
		else
			cb(false, false)
		end
	end)

	exports["pulsar-core"]:RegisterClientCallback("Vehicles:AdvLockpick", function(data, cb)
		if _characterLoaded then
			if VEHICLE_INSIDE then
				if VEHICLE_SEAT == -1 then
					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)]

					local boostOverride = Entity(VEHICLE_INSIDE).state.boostForceHack

					if vehClass and vehClass.advLockpick and not boostOverride then
						exports['pulsar-vehicles']:Lockpick(vehClass.advLockpick.interior, data, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
					end
				else
					cb(false, false)
				end
			else
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				if
					vehicle
					and DoesEntityExist(vehicle)
					and IsEntityAVehicle(vehicle)
					and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
				then
					-- Request VIN generation if vehicle doesn't have one
					local vehEnt = Entity(vehicle)
					if not vehEnt.state.VIN then
						TriggerServerEvent("Vehicles:Server:RequestGenerateVehicleInfo", VehToNet(vehicle))
						local attempts = 0
						while not vehEnt.state.VIN and attempts < 20 do
							Wait(100)
							attempts = attempts + 1
						end
						
						if not vehEnt.state.VIN then
							exports["pulsar-hud"]:Notification("error", "Failed to Initialize Vehicle", 3000)
							return cb(false, false)
						end
					end

					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(vehicle)]
					local boostOverride = Entity(vehicle).state.boostForceHack

					if vehClass and vehClass.advLockpick and not boostOverride then
						exports['pulsar-vehicles']:LockpickExterior(vehClass.advLockpick.exterior, data, vehicle,
							cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
					end
				else
					cb(false, false)
				end
			end
		else
			cb(false, false)
		end
	end)

	exports["pulsar-core"]:RegisterClientCallback("Vehicles:PDLockpick", function(data, cb)
		if _characterLoaded then
			if not (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison") then
				exports["pulsar-hud"]:Notification("error", "You cannot do this you criminal!", 3000)
				return cb(false, false)
			end
			if VEHICLE_INSIDE then
				if VEHICLE_SEAT == -1 then
					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)]

					local boostOverride = Entity(VEHICLE_INSIDE).state.boostForceHack

					if vehClass and vehClass.advLockpick and not boostOverride then
						exports['pulsar-vehicles']:Lockpick(vehClass.advLockpick.interior, data, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
					end
				else
					cb(false, false)
				end
			else
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				if
					vehicle
					and DoesEntityExist(vehicle)
					and IsEntityAVehicle(vehicle)
					and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
				then
					-- Request VIN generation if vehicle doesn't have one
					local vehEnt = Entity(vehicle)
					if not vehEnt.state.VIN then
						TriggerServerEvent("Vehicles:Server:RequestGenerateVehicleInfo", VehToNet(vehicle))
						local attempts = 0
						while not vehEnt.state.VIN and attempts < 20 do
							Wait(100)
							attempts = attempts + 1
						end
						
						if not vehEnt.state.VIN then
							exports["pulsar-hud"]:Notification("error", "Failed to Initialize Vehicle", 3000)
							return cb(false, false)
						end
					end

					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(vehicle)]
					local boostOverride = Entity(vehicle).state.boostForceHack

					if vehClass and vehClass.advLockpick and not boostOverride then
						exports['pulsar-vehicles']:LockpickExterior(vehClass.advLockpick.exterior, data, vehicle,
							cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Lockpick This Vehicle")
					end
				else
					cb(false, false)
				end
			end
		else
			cb(false, false)
		end
	end)

	exports["pulsar-core"]:RegisterClientCallback("Vehicles:Hack", function(data, cb)
		if _characterLoaded then
			if VEHICLE_INSIDE then
				if VEHICLE_SEAT == -1 then
					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)]
					if vehClass and vehClass.hack then
						exports['pulsar-vehicles']:Hack(vehClass.hack.interior, data, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Hack This Vehicle")
					end
				else
					cb(false, false)
				end
			else
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				if
					vehicle
					and DoesEntityExist(vehicle)
					and IsEntityAVehicle(vehicle)
					and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
				then
					-- Request VIN generation if vehicle doesn't have one
					local vehEnt = Entity(vehicle)
					if not vehEnt.state.VIN then
						TriggerServerEvent("Vehicles:Server:RequestGenerateVehicleInfo", VehToNet(vehicle))
						local attempts = 0
						while not vehEnt.state.VIN and attempts < 20 do
							Wait(100)
							attempts = attempts + 1
						end
						
						if not vehEnt.state.VIN then
							exports["pulsar-hud"]:Notification("error", "Failed to Initialize Vehicle", 3000)
							return cb(false, false)
						end
					end

					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(vehicle)]
					if vehClass and vehClass.hack then
						exports['pulsar-vehicles']:HackExterior(vehClass.hack.exterior, data, vehicle, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Hack This Vehicle")
					end
				else
					cb(false, false)
				end
			end
		else
			cb(false, false)
		end
	end)

	exports["pulsar-core"]:RegisterClientCallback("Vehicles:AdvHack", function(data, cb)
		if _characterLoaded then
			if VEHICLE_INSIDE then
				if VEHICLE_SEAT == -1 then
					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(VEHICLE_INSIDE)]
					if vehClass and vehClass.advHack then
						exports['pulsar-vehicles']:Hack(vehClass.advHack.interior, data, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Hack This Vehicle")
					end
				else
					cb(false, false)
				end
			else
				local playerCoords = GetEntityCoords(PlayerPedId())
				local maxDistance = 2.0
				local includePlayerVehicle = true

				local vehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
				if
					vehicle
					and DoesEntityExist(vehicle)
					and IsEntityAVehicle(vehicle)
					and #(GetEntityCoords(vehicle) - GetEntityCoords(GLOBAL_PED)) <= 2.0
				then
					-- Request VIN generation if vehicle doesn't have one
					local vehEnt = Entity(vehicle)
					if not vehEnt.state.VIN then
						TriggerServerEvent("Vehicles:Server:RequestGenerateVehicleInfo", VehToNet(vehicle))
						local attempts = 0
						while not vehEnt.state.VIN and attempts < 20 do
							Wait(100)
							attempts = attempts + 1
						end
						
						if not vehEnt.state.VIN then
							exports["pulsar-hud"]:Notification("error", "Failed to Initialize Vehicle", 3000)
							return cb(false, false)
						end
					end

					local vehClass = _vehicleClasses[exports['pulsar-vehicles']:ClassGet(vehicle)]
					if vehClass and vehClass.advHack then
						exports['pulsar-vehicles']:HackExterior(vehClass.advHack.exterior, data, vehicle, cb)
					else
						exports["pulsar-hud"]:Notification("error", "Cannot Hack This Vehicle")
					end
				else
					cb(false, false)
				end
			end
		else
			cb(false, false)
		end
	end)
end)
