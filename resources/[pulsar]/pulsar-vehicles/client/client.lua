_characterLoaded, GLOBAL_PED = false, nil

VEHICLE_INSIDE = nil
VEHICLE_SEAT = nil
VEHICLE_CLASS = nil

VEHICLE_TOP_SPEED = nil

VEHICLE_SEATBELT = false
VEHICLE_HARNESS = false

local vehicleDoorNames = {
	[0] = "Driver",
	[1] = "Passenger",
	[2] = "Rear Driver",
	[3] = "Rear Passenger",
	[4] = "Hood",
	[5] = "Trunk",
}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterCallbacks()

		TriggerEvent("Vehicles:Client:StartUp")

		exports["pulsar-kbs"]:Add("toggle_engine", "IOM_WHEEL_UP", "MOUSE_WHEEL", "Vehicle - Toggle Engine",
			function()
				if VEHICLE_INSIDE and VEHICLE_SEAT == -1 then
					if IsPauseMenuActive() ~= 1 then
						exports['pulsar-vehicles']:EngineToggle()
					end
				end
			end)
		exports['pulsar-hud']:InteractionRegisterMenu("veh_quick_actions", "Open Vehicle Menu", "car", function()
			if VEHICLE_INSIDE then
				local vehEnt = Entity(VEHICLE_INSIDE)
				local subMenu = {}
				local seatAmount = GetVehicleModelNumberOfSeats(GetEntityModel(VEHICLE_INSIDE))
				exports['pulsar-hud']:InteractionShowMenu({
					{
						icon = "key",
						label = "Give Keys",
						shouldShow = function()
							return VEHICLE_INSIDE and
								exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys)
						end,
						action = function()
							if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
								if IsPedInAnyVehicle(LocalPlayer.state.ped, true) then
									local sids = {}
									for i = -1, GetVehicleModelNumberOfSeats(VEHICLE_INSIDE), 1 do
										local ped = GetPedInVehicleSeat(VEHICLE_INSIDE, i)
										if ped ~= 0 and ped ~= LocalPlayer.state.ped then
											table.insert(sids, GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)))
										end
									end
									exports["pulsar-core"]:ServerCallback("Vehicles:GiveKeys", {
										netId = VehToNet(VEHICLE_INSIDE),
										sids = sids,
									})
								end
							end

							exports['pulsar-hud']:InteractionHide()
						end,
					},
					{
						icon = "chair",
						label = "Seats",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if GetVehicleModelNumberOfSeats(GetEntityModel(VEHICLE_INSIDE)) > 1 then
									return true
								end
							end
							return false
						end,
						action = function()
							local seats = {}
							local seatAmount = GetVehicleModelNumberOfSeats(GetEntityModel(VEHICLE_INSIDE))
							for i = 1, seatAmount do
								local actualSeatNumber = i - 2
								if GetPedInVehicleSeat(VEHICLE_INSIDE, actualSeatNumber) == 0 then
									table.insert(seats, {
										icon = "chair",
										label = actualSeatNumber == -1 and "Driver's Seat" or "Seat #" .. i,
										action = function()
											TriggerEvent("Vehicles:Client:Actions:SwitchSeat", actualSeatNumber)
											exports['pulsar-hud']:InteractionHide()
										end,
									})
								end
							end

							if #seats > 0 then
								exports['pulsar-hud']:InteractionShowMenu(seats)
							else
								exports["pulsar-hud"]:Notification("error", "No Seats Free")
							end
						end,
					},
					{
						icon = "car-side",
						label = "Doors",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if GetNumberOfVehicleDoors(VEHICLE_INSIDE) >= 1 then
									return true
								end
							end
							return false
						end,
						action = function()
							local doors = {}
							for doorId, doorName in pairs(vehicleDoorNames) do
								if GetIsDoorValid(VEHICLE_INSIDE, doorId) then
									table.insert(doors, {
										icon = "car-side",
										label = doorName,
										action = function()
											TriggerEvent("Vehicles:Client:Actions:ToggleDoor", doorId)
										end,
									})
								end
							end

							exports['pulsar-hud']:InteractionShowMenu(doors)
						end,
					},
					{
						icon = "car-side",
						label = "Close All Doors",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if GetNumberOfVehicleDoors(VEHICLE_INSIDE) >= 1 then
									return true
								end
							end
							return false
						end,
						action = function()
							if VEHICLE_INSIDE then
								TriggerEvent("Vehicles:Client:Actions:ToggleDoor", "shut")
							end
						end,
					},
					{
						icon = "car-side",
						label = "Open All Doors",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if GetNumberOfVehicleDoors(VEHICLE_INSIDE) >= 1 then
									return true
								end
							end
							return false
						end,
						action = function()
							if VEHICLE_INSIDE then
								TriggerEvent("Vehicles:Client:Actions:ToggleDoor", "open")
							end
						end,
					},
					{
						icon = "fa-window-maximize",
						label = "Windows",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if GetNumberOfVehicleDoors(VEHICLE_INSIDE) >= 1 then
									return true
								end
							end
							return false
						end,
						action = function()
							local doors = {}
							table.insert(doors, {
								icon = "window-maximize",
								label = "Driver Window",
								action = function()
									TriggerEvent("Vehicles:Client:Actions:ToggleWindow", 0)
								end,
							})

							table.insert(doors, {
								icon = "window-maximize",
								label = "Passenger Window",
								action = function()
									TriggerEvent("Vehicles:Client:Actions:ToggleWindow", 1)
								end,
							})

							table.insert(doors, {
								icon = "window-maximize",
								label = "Close All",
								action = function()
									TriggerEvent("Vehicles:Client:Actions:ToggleWindow", "shut")
								end,
							})

							table.insert(doors, {
								icon = "window-maximize",
								label = "Open All",
								action = function()
									TriggerEvent("Vehicles:Client:Actions:ToggleWindow", "open")
								end,
							})

							exports['pulsar-hud']:InteractionShowMenu(doors)
						end,
					},
					{
						icon = "gauge",
						label = "Check Mileage",
						action = function()
							if VEHICLE_INSIDE then
								local vehEnt = Entity(VEHICLE_INSIDE)
								if vehEnt and vehEnt.state and vehEnt.state.Mileage then
									exports["pulsar-hud"]:Notification("info",
										"This Vehicle Has " .. vehEnt.state.Mileage .. " Miles on the Odometer",
										10000
									)
								end

								exports['pulsar-hud']:InteractionHide()
							end
						end,
					},
					{
						icon = "fire",
						label = "Check Nitrous Levels",
						shouldShow = function()
							if VEHICLE_INSIDE then
								if exports['pulsar-police']:IsPdCar(VEHICLE_INSIDE) or exports['pulsar-police']:IsEMSCar(VEHICLE_INSIDE) then
									return false
								end
								local vehEnt = Entity(VEHICLE_INSIDE)
								if vehEnt and vehEnt.state and vehEnt.state.Nitrous then
									return true
								end
							end
							return false
						end,
						action = function()
							if VEHICLE_INSIDE then
								local vehEnt = Entity(VEHICLE_INSIDE)
								if vehEnt and vehEnt.state and vehEnt.state.Nitrous then
									exports["pulsar-hud"]:Notification("standard",
										"Nitrous Remaining: " ..
										exports['pulsar-core']:UtilsRound(vehEnt.state.Nitrous, 2) .. "%",
										10000
									)
								end
								exports['pulsar-hud']:InteractionHide()
							end
						end,
					},
					{
						icon = "rocket",
						label = "Remove Nitrous",
						shouldShow = function()
							if VEHICLE_INSIDE and GetPedInVehicleSeat(VEHICLE_INSIDE, -1) == LocalPlayer.state.ped then
								if exports['pulsar-police']:IsPdCar(VEHICLE_INSIDE) or exports['pulsar-police']:IsEMSCar(VEHICLE_INSIDE) then
									return false
								end
								local vehEnt = Entity(VEHICLE_INSIDE)
								if vehEnt and vehEnt.state and vehEnt.state.Nitrous then
									return true
								end
							end
							return false
						end,
						action = function()
							if VEHICLE_INSIDE then
								local vehEnt = Entity(VEHICLE_INSIDE)
								if vehEnt and vehEnt.state and vehEnt.state.Nitrous then
									TriggerEvent("Vehicles:Client:RemoveNitrous")
								end
							end
						end,
					},
					-- {
					-- 	icon = "print-magnifying-glass",
					-- 	label = "Inspect VIN",
					-- 	shouldShow = function()
					-- 		return (LocalPlayer.state.onDuty ~= "police" and exports['pulsar-vehicles']:HasAccess(VEHICLE_INSIDE))
					-- 			or (LocalPlayer.state.onDuty == "police" and LocalPlayer.state.inPdStation)
					-- 	end,
					-- 	action = function()
					-- 		if
					-- 			VEHICLE_INSIDE
					-- 			and (
					-- 				(LocalPlayer.state.onDuty ~= "police" and exports['pulsar-vehicles']:HasAccess(VEHICLE_INSIDE))
					-- 				or (LocalPlayer.state.onDuty == "police" and LocalPlayer.state.inPdStation)
					-- 			)
					-- 		then
					--             exports['pulsar-hud']:ListMenuClose()
					-- 			TriggerServerEvent("Vehicle:Server:InspectVIN", VehToNet(VEHICLE_INSIDE))
					-- 		end
					-- 	end,
					-- },
					{
						icon = "lightbulb-on",
						label = "Neons",
						shouldShow = function()
							if VEHICLE_INSIDE and exports['pulsar-vehicles']:SyncNeonsHas() and not exports['pulsar-police']:IsPdCar(VEHICLE_INSIDE) then
								return true
							end
						end,
						action = function()
							if VEHICLE_INSIDE then
								exports['pulsar-vehicles']:SyncNeonsToggle()
							end
						end,
					},
				})
			end
		end, function()
			if VEHICLE_INSIDE then
				return true
			end
			return false
		end)
	end
end)

AddEventHandler("Vehicles:Client:GiveKeys", function(entityData, data)
	local vehEnt = Entity(entityData.entity)

	if exports['pulsar-vehicles']:KeysHas(vehEnt.state.VIN, vehEnt.state.GroupKeys) then
		local myCoords = GetEntityCoords(LocalPlayer.state.ped)
		local peds = GetGamePool("CPed")
		local sids = {}
		for _, ped in ipairs(peds) do
			if ped ~= LocalPlayer.state.ped and IsPedAPlayer(ped) then
				local entCoords = GetEntityCoords(ped)
				if #(entCoords - myCoords) <= 4.0 then
					table.insert(sids, GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)))
				end
			end
		end
		exports["pulsar-core"]:ServerCallback("Vehicles:GiveKeys", {
			netId = VehToNet(entityData.entity),
			sids = sids,
		})
	end
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	_characterLoaded = true
	TriggerEvent("Vehicles:Client:CharacterLogin")
end)

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
	_characterLoaded = false

	TriggerEvent("Vehicles:Client:CharacterLogout")
end)

RegisterNetEvent("Vehicles:Client:Actions:SwitchSeat")
AddEventHandler("Vehicles:Client:Actions:SwitchSeat", function(seatNum)
	if not VEHICLE_INSIDE then
		return
	end
	if GetPedInVehicleSeat(VEHICLE_INSIDE, seatNum) == 0 then
		SetPedIntoVehicle(GLOBAL_PED, VEHICLE_INSIDE, seatNum)
	else
		exports["pulsar-hud"]:Notification("error", "Seat Occupied")
	end
end)

RegisterNetEvent("Vehicles:Client:Actions:ToggleDoor")
AddEventHandler("Vehicles:Client:Actions:ToggleDoor", function(doorNum)
	local vehicle = VEHICLE_INSIDE

	if not vehicle then
		local playerCoords = GetEntityCoords(PlayerPedId())
		local maxDistance = 2.0
		local includePlayerVehicle = true

		local targetVehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
		if
			targetVehicle
			and DoesEntityExist(targetVehicle)
			and GetEntitySpeed(targetVehicle) <= 2.0
			and GetPedInVehicleSeat(targetVehicle, -1) == 0
			and GetVehicleDoorLockStatus(targetVehicle) == 1
		then
			vehicle = targetVehicle
		else
			return
		end
	end

	if doorNum == "shut" or doorNum == "close" then
		exports['pulsar-vehicles']:SyncDoorsShut(vehicle, "all", false)
	elseif doorNum == "open" then
		exports['pulsar-vehicles']:SyncDoorsOpen(vehicle, "all", false, false)
	else
		if GetVehicleDoorAngleRatio(vehicle, doorNum) > 0.0 then
			exports['pulsar-vehicles']:SyncDoorsShut(vehicle, doorNum, false)
		else
			exports['pulsar-vehicles']:SyncDoorsOpen(vehicle, doorNum, false, false)
		end
	end
end)

RegisterNetEvent("Vehicles:Client:Actions:ToggleWindow")
AddEventHandler("Vehicles:Client:Actions:ToggleWindow", function(winNum)
	local vehicle = VEHICLE_INSIDE

	if not vehicle then
		local playerCoords = GetEntityCoords(PlayerPedId())
		local maxDistance = 2.0
		local includePlayerVehicle = true

		local targetVehicle = lib.getClosestVehicle(playerCoords, maxDistance, includePlayerVehicle)
		if
			targetVehicle
			and DoesEntityExist(targetVehicle)
			and GetEntitySpeed(targetVehicle) <= 2.0
			and GetPedInVehicleSeat(targetVehicle, -1) == 0
		then
			vehicle = targetVehicle
		else
			return
		end
	end

	if winNum == "shut" or winNum == "close" then
		for i = 0, 4 do
			RollUpWindow(vehicle, i)
		end
	elseif winNum == "open" then
		for i = 0, 4 do
			RollDownWindows(vehicle, i)
		end
	else
		if IsVehicleWindowIntact(vehicle, winNum) then
			RollDownWindows(vehicle, winNum)
		else
			RollUpWindow(vehicle, winNum)
		end
	end
end)
