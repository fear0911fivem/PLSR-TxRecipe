DRIVING_VEHICLE, VEHICLE_INSIDE = nil, nil

local _fueling = false
local _lowtick = 0
local _engineShutoff = false

local pumpModels = {
	`prop_gas_pump_1a`,
	`prop_gas_pump_1b`,
	`prop_gas_pump_1c`,
	`prop_gas_pump_1d`,
	`prop_vintage_pump`,
	`prop_gas_pump_old2`,
	`prop_gas_pump_old3`,
	`tstudio_mrpd_asset_gas_pump`,
	-- MODEL HASHES
	`165803071`,
    `-164877493`,
    `-469694731`,
    `-462817101`,
    `-2007231801`,
    `1933174915`,
    `1694452750`,
    `1339433404`,
	`486135101`, -- LTD Grove Gabz
	`165803071`, -- TStudio Pump
}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		CreateFuelStationPolyzones()

		for k, v in ipairs(pumpModels) do
			exports.ox_target:addModel(v, {
				{
					label = function()
						local current = GetAmmoInPedWeapon(LocalPlayer.state.ped, `WEAPON_PETROLCAN`)
						local pct = current / 4500
						return string.format(
							"Refill Petrol Can ($%s)",
							math.ceil(CalculateFuelCost(0, math.floor(100 - (pct * 100))))
						)
					end,
					icon = "gas-pump",
					event = "Fuel:Client:FillCan",
					distance = 3.0,
					canInteract = function()
						local isArmed, hash = GetCurrentPedWeapon(LocalPlayer.state.ped)
						local current = GetAmmoInPedWeapon(LocalPlayer.state.ped, `WEAPON_PETROLCAN`)
						local pct = current / 4500
						local cCost = CalculateFuelCost(0, math.floor(100 - (pct * 100)))
						if cCost then
							local cost = math.ceil(cCost)
							return (
								isArmed
								and hash == `WEAPON_PETROLCAN`
								and GetAmmoInPedWeapon(LocalPlayer.state.ped, `WEAPON_PETROLCAN`) < 4500
								and LocalPlayer.state.Character:GetData("Cash") >= cost
							)
						end
					end,
				},
			})
		end
	end
end)

function CreateFuelStationPolyzones()
	for k, v in ipairs(Config.FuelStations) do
		exports['pulsar-polyzone']:CreateBox("fuel_" .. k, v.center, v.length, v.width, {
			heading = v.heading,
			minZ = v.minZ,
			maxZ = v.maxZ,
		}, {
			fuel = true,
			restricted = v.restricted,
			id = k,
		})
	end
end

AddEventHandler("Characters:Client:Spawn", function()
	if not Config.EnableBlips then return end
	for k, v in ipairs(Config.FuelStations) do
		if not v.restricted and v.blip ~= false then
			exports["pulsar-blips"]:Add('fuel-station-'..k, 'Fuel Station', v.center, 361, 64, 0.4)
		end
	end
end)

AddEventHandler("Fuel:Client:FillCan", function()
	local current = GetAmmoInPedWeapon(LocalPlayer.state.ped, `WEAPON_PETROLCAN`)
	local pct = current / 4500

	exports['pulsar-hud']:Progress({
		name = "fill_petrol_can",
		duration = math.min(math.ceil(10 - (10 * pct)), 2) * 10000,
		label = "Filling Petrol Can",
		canCancel = true,
		disarm = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = nil,
	}, function(cancelled)
		if not cancelled then
			exports["pulsar-core"]:ServerCallback("Fuel:FillCan", {
				current = current,
				pct = pct,
			}, function(s)
				if s then
					SetPedAmmo(LocalPlayer.state.ped, `WEAPON_PETROLCAN`, 5000)
				end
			end)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	DRIVING_VEHICLE = nil
	VEHICLE_INSIDE = nil
end)

AddEventHandler("Vehicles:Client:BecameDriver", function(veh, seat, class)
	DRIVING_VEHICLE = veh
	local vehState = Entity(veh).state
	if vehState.VIN and vehState.Fuel ~= nil and class ~= 13 then
		TriggerEvent("Vehicles:Client:Fuel", vehState.Fuel, false)
		CreateThread(function()
			while LocalPlayer.state.loggedIn and DRIVING_VEHICLE do
				if GetPedInVehicleSeat(DRIVING_VEHICLE, -1) == LocalPlayer.state.ped then
					RunFuelTick(DRIVING_VEHICLE)
				end
				Wait(3000)
			end
		end)
	else
		TriggerEvent("Vehicles:Client:Fuel", 0, true)
	end
end)

AddEventHandler("Vehicles:Client:EnterVehicle", function(veh)
	VEHICLE_INSIDE = veh

	CreateThread(function()
		Wait(500)
		while VEHICLE_INSIDE and not DRIVING_VEHICLE do
			if DoesEntityExist(VEHICLE_INSIDE) then
				local vehEntity = Entity(VEHICLE_INSIDE)
				if vehEntity and vehEntity.state and type(vehEntity.state.Fuel) == "number" then
					TriggerEvent("Vehicles:Client:Fuel", vehEntity.state.Fuel)
				end
			end
			Wait(3000)
		end
	end)
end)

AddEventHandler("Vehicles:Client:ExitVehicle", function()
	DRIVING_VEHICLE = nil
	VEHICLE_INSIDE = nil
end)

AddEventHandler("Vehicles:Client:SwitchVehicleSeat", function(veh, seat)
	if seat ~= -1 then
		DRIVING_VEHICLE = nil
	end
end)

local lastReplicated = GetGameTimer()

function RunFuelTick(veh)
	if veh and IsVehicleEngineOn(veh) then
		local vehState = Entity(veh).state
		if type(vehState.Fuel) == "number" then
			local vehRPM = exports['pulsar-core']:UtilsRound(GetVehicleCurrentRpm(veh), 1)
			local classUsage = Config.Classes[GetVehicleClass(veh)] or 1.0

			local consumption = ((Config.Usage * Config.FuelUsage[vehRPM]) * classUsage) / 10

			if GetVehiclePetrolTankHealth(veh) <= 650 then
				consumption = consumption + 3.0
			end

			local newVal = exports['pulsar-core']:UtilsRound(vehState.Fuel - consumption, 2)

			if newVal <= 0.0 then
				newVal = 0.0
				exports['pulsar-vehicles']:EngineForce(veh, false)
			elseif newVal <= 5.0 then
				if _lowtick >= 3 then
					_lowtick = 0
					LowFuelEffects(veh)
				else
					_lowtick = _lowtick + 1
				end
			end

			TriggerEvent("Vehicles:Client:Fuel", newVal)
			if (GetGameTimer() - lastReplicated) > 60000 then
				lastReplicated = GetGameTimer()
				vehState:set("Fuel", newVal, true)
			else
				vehState:set("Fuel", newVal, false)
			end
		end
	end
end

function LowFuelEffects(veh)
	if _engineShutoff then
		return
	end

	_engineShutoff = true
	SetTimeout(2000, function()
		_engineShutoff = false
	end)

	CreateThread(function()
		while _engineShutoff do
			SetVehicleEngineOn(veh, false, true)
			Wait(1)
		end
	end)
end

AddEventHandler("Vehicles:Client:StartFueling", function(data)
	local entState = Entity(data.entity).state
	entState:set("beingFueled", GetPlayerServerId(LocalPlayer.state.PlayerID), true)

	local fuelData = exports['pulsar-fuel']:CanBeFueled(data.entity)
	if not fuelData then
		return
	end

	if not fuelData.needsFuel then
		exports["pulsar-hud"]:Notification("error", "Vehicle Does Not Need Refueling")
		return
	end

	if data.bank then
		local p = promise.new()
		exports["pulsar-core"]:ServerCallback("Fuel:CheckBank", fuelData, function(res)
			p:resolve(res)
		end)
		local canAfford = Citizen.Await(p)

		if not canAfford then
			exports["pulsar-hud"]:Notification("error", "Insufficient Bank Balance")
			return
		end
	else
		if LocalPlayer.state.Character:GetData("Cash") < fuelData.cost then
			exports["pulsar-hud"]:Notification("error", "Not Enough Cash to Refuel")
			return
		end
	end

	local secondsElapsed = 0
	local time = math.min(math.ceil(fuelData.requiredFuel / 2), 40)
	TaskTurnPedToFaceEntity(LocalPlayer.state.ped, data.entity, 3000)
	Wait(2000)
	exports['pulsar-animations']:EmotesPlay("fuel", false, nil, true)
	exports['pulsar-hud']:ProgressWithStartAndTick({
		name = "idle",
		duration = time * 1000,
		label = "Refueling Vehicle",
		canCancel = true,
		tickrate = 1000,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {},
		prop = {},
		disarm = true,
	}, function()
		_fueling = true
	end, function()
		secondsElapsed = secondsElapsed + 1

		local entState = Entity(data.entity).state
		if entState.beingFueled ~= nil and entState.beingFueled ~= GetPlayerServerId(LocalPlayer.state.PlayerID) then
			exports['pulsar-hud']:ProgressCancel()
		end

		local playerCoords = GetEntityCoords(LocalPlayer.state.ped)
		local vehicleCoords = GetEntityCoords(data.entity)
		if
			not LocalPlayer.state.loggedIn
			or not DoesEntityExist(data.entity)
			or IsEntityDead(data.entity)
			or #(playerCoords - vehicleCoords) > 5.0
		then
			exports['pulsar-animations']:EmotesForceCancel()
			exports['pulsar-hud']:ProgressCancel()
			return
		end

		if GetIsVehicleEngineRunning(data.entity) then
			math.randomseed(GetGameTimer())
			local chance = math.random(0, 200)
			if chance == 69 then
				local _fuelFires = {}
				table.insert(_fuelFires, StartScriptFire(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 25, true))

				for i = 1, 5, 1 do
					local offsetX = math.random(-5, 5) + 0.0
					local offsetY = math.random(-5, 5) + 0.0
					local fireCoords = GetOffsetFromEntityInWorldCoords(nearPump, offsetX, offsetY, 0)
					table.insert(_fuelFires, StartScriptFire(fireCoords.x, fireCoords.y, fireCoords.z, 25, true))
				end

				-- For Good Measure 🙂
				if NetworkHasControlOfEntity(data.entity) then
					NetworkExplodeVehicle(data.entity, true, true, true)
				end

				exports["pulsar-hud"]:Notification("info", "Nice One Champ")

				SetTimeout(60000, function()
					for k, v in ipairs(_fuelFires) do
						RemoveScriptFire(v)
					end
					_fuelFires = nil
				end)

				exports['pulsar-animations']:EmotesForceCancel()
				exports['pulsar-hud']:ProgressCancel()
				return
			end
		end
	end, function(wasCancelled)
		_fueling = false
		exports['pulsar-animations']:EmotesForceCancel()
		local fuelAmount = fuelData.requiredFuel
		if wasCancelled then
			fuelAmount = math.ceil(fuelData.requiredFuel * (secondsElapsed / time))
		end

		local entState = Entity(data.entity).state
		entState:set("beingFueled", nil, true)

		exports["pulsar-core"]:ServerCallback("Fuel:CompleteFueling", {
			vehNet = VehToNet(data.entity),
			vehClass = GetVehicleClass(data.entity),
			fuelAmount = fuelAmount,
			useBank = data.bank,
		}, function(success, amount)
			if success and amount then
				exports["pulsar-hud"]:Notification("success", string.format("Refueled Vehicle for $%d", amount))
			else
				exports["pulsar-hud"]:Notification("error", "Error Refueling")
			end
		end)
	end)
end)

AddEventHandler("Vehicles:Client:StartJerryFueling", function(entityData)
    local vehicle = entityData.entity
    
    if not DoesEntityExist(vehicle) or GetVehicleClass(vehicle) == 13 then
        return
    end
    
    local vehState = Entity(vehicle).state
    if not vehState.VIN or vehState.Fuel == nil then
        return
    end
    
    local requiredFuel = 100 - vehState.Fuel
    if not requiredFuel or requiredFuel <= 1 then
        return exports["pulsar-hud"]:Notification("error", "Vehicle Does Not Need Refueling")
    end
    
    local hasWeapon, weapon = GetCurrentPedWeapon(LocalPlayer.state.ped)
    if not hasWeapon or weapon ~= `WEAPON_PETROLCAN` then
        return
    end
    
    local ammoAmount = GetAmmoInPedWeapon(LocalPlayer.state.ped, `WEAPON_PETROLCAN`)
    if ammoAmount <= 0 then
        return exports["pulsar-hud"]:Notification("error", "The Petrol Can Is Empty")
    end
    
    local currentFuel = ammoAmount
    local fuelAmount = math.min(requiredFuel, ammoAmount)
    local fuelAmountAfterUse = currentFuel - fuelAmount
    local time = math.max(math.ceil(fuelAmount / 2), 2)
    local secondsElapsed = 0
    
    exports['pulsar-hud']:ProgressWithStartAndTick({
        name = "idle",
        duration = time * 1000,
        label = "Refueling Vehicle",
        canCancel = true,
        tickrate = 1000,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "weapons@misc@jerrycan@",
            anim = "fire",
            flags = 49,
        },
        disarm = false,
    }, function()
        _fueling = true
    end, function()
        secondsElapsed = secondsElapsed + 1
        
        local playerCoords = GetEntityCoords(LocalPlayer.state.ped)
        local vehicleCoords = GetEntityCoords(entityData.entity)
        local hasWeapon, weapon = GetCurrentPedWeapon(LocalPlayer.state.ped)
        
        if not LocalPlayer.state.loggedIn
            or not hasWeapon
            or weapon ~= `WEAPON_PETROLCAN`
            or not DoesEntityExist(entityData.entity)
            or IsEntityDead(entityData.entity)
            or #(playerCoords - vehicleCoords) > 5.0
        then
            exports['pulsar-hud']:ProgressCancel()
            return
        end
        
        if GetIsVehicleEngineRunning(entityData.entity) then
            math.randomseed(GetGameTimer())
            local chance = math.random(0, 200)
            
            if chance == 69 then
                local _fuelFires = {}
                
                table.insert(_fuelFires, StartScriptFire(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 25, true))
                
                for i = 1, 5 do
                    local offsetX = math.random(-5, 5) + 0.0
                    local offsetY = math.random(-5, 5) + 0.0
                    local fireCoords = GetOffsetFromEntityInWorldCoords(vehicle, offsetX, offsetY, 0)
                    table.insert(_fuelFires, StartScriptFire(fireCoords.x, fireCoords.y, fireCoords.z, 25, true))
                end
                
                if NetworkHasControlOfEntity(entityData.entity) then
                    NetworkExplodeVehicle(entityData.entity, true, true, true)
                end
                
                exports["pulsar-hud"]:Notification("info", "Nice One Champ")
                
                SetTimeout(60000, function()
                    for k, v in ipairs(_fuelFires) do
                        RemoveScriptFire(v)
                    end
                    _fuelFires = nil
                end)
                
                exports['pulsar-hud']:ProgressCancel()
                return
            end
        end
    end, function(wasCancelled)
        _fueling = false
        
        if wasCancelled then
            fuelAmount = math.ceil(fuelAmount * (secondsElapsed / time))
            fuelAmountAfterUse = currentFuel - fuelAmount
        end
        
        SetPedAmmo(LocalPlayer.state.ped, `WEAPON_PETROLCAN`, math.floor(fuelAmountAfterUse))
        
        exports["pulsar-core"]:ServerCallback("Fuel:CompleteJerryFueling", {
            vehNet = VehToNet(entityData.entity),
            newAmount = math.ceil(vehState.Fuel + fuelAmount),
            fuelUsed = fuelAmount,
        }, function(success)
            if success then
                exports["pulsar-hud"]:Notification("success", "Refueled Vehicle")
            else
                exports["pulsar-hud"]:Notification("error", "Error Refueling")
            end
        end)
    end)
end)

-- TODO: Add Fuel Can