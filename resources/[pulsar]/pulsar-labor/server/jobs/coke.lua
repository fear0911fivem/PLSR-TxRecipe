local _JOB = "Coke"

local _joiners = {}
local _active = nil

local _guns = {
	`WEAPON_APPISTOL`,
	`WEAPON_MG`,
	`WEAPON_COMBATMG`,
	`WEAPON_ASSAULTRIFLE`,
	`WEAPON_COMPACTRIFLE`,
	`WEAPON_SMG`,
	`WEAPON_ASSAULTSHOTGUN`,
	`WEAPON_SAWNOFFSHOTGUN`,

	--`WEAPON_PUMPSHOTGUN`,
}

local _pedModels = {
	`A_M_Y_MexThug_01`,
	`CSB_Ramp_mex`,
	`G_M_Y_MexGang_01`,
	`G_M_Y_MexGoon_01`,
	`G_M_Y_MexGoon_02`,
	`G_M_Y_MexGoon_03`,
	`IG_Ramp_Mex`,
	`A_M_M_MexLabor_01`,
}

local function SpawnPeds(source, coords)
	if _pedsSpawned then
		return
	end
	_pedsSpawned = true

	local peds = {}

	for k, v in ipairs(coords) do
		local p = CreatePed(5, _pedModels[math.random(#_pedModels)], v[1], v[2], v[3], math.random(360), true, true)
		local w = _guns[math.random(#_guns)]

		local entState = Entity(p).state

		entState.cokePed = _active.joiner
		entState.crimePed = true
		GiveWeaponToPed(p, w, 99999, false, true, true)
		SetCurrentPedWeapon(p, w, true)
		SetPedArmour(p, 600)
		--TaskCombatPed(p, GetPlayerPed(source), 0, 16)

		table.insert(peds, NetworkGetNetworkIdFromEntity(p))
		Wait(3)
	end

	Wait(1000)

	return peds
end

AddEventHandler("Labor:Server:Startup", function()
	GlobalState["CokeRuns"] = vector4(-1207.469, -961.961, 1.150, 120.127)
	GlobalState["CokeRunActive"] = false
	GlobalState["CokeRunCD"] = false

	exports['pulsar-core']:WaitListCreate("coke_import", "individual_time", {
		event = "Labor:Server:Coke:Queue",
		--delay = (1000 * 60) * 5,
		delay = 10000,
	})

	exports["pulsar-core"]:RegisterServerCallback("Coke:StartWork", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if exports['pulsar-finance']:WalletHas(source, 100000) then
				if not GlobalState["CokeRunActive"] and _active == nil then
					if not GlobalState["CokeRunCD"] or os.time() > GlobalState["CokeRunCD"] then
						exports['pulsar-labor']:OnDuty("Coke", source, true)
					else
						exports['pulsar-hud']:Notification(source, "error",
							"Someone Has Already Done This Recently")
					end
				else
					exports['pulsar-hud']:Notification(source, "error",
						"Someone Else Is Already Doing This")
				end
			else
				exports['pulsar-hud']:Notification(source, "error",
					"You Don't Have Enough Cash, Come Back When You Do")
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:Abort", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _active ~= nil and _active.joiner == source then
				if _active.state == 0 then
					exports['pulsar-labor']:OffDuty("Coke", source, false, false)
					exports['pulsar-finance']:WalletModify(source, 100000)

					GlobalState["CokeRunActive"] = false
					GlobalState["CokeRunCD"] = false
					char:SetData("CokeCD", os.time())
					_active = nil
				else
					exports['pulsar-hud']:Notification(source, "error",
						"Too Late, You Cannot Cancel This Now")
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:ArriveAtCayo", function(source, data, cb)
		if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 1 then
			_active.state = 2
			exports['pulsar-vehicles']:SpawnTemp(source, `squaddie`, 'automobile', vector3(4504.899, -4510.600, 4.367),
				19.409,
				function(veh)
					exports['pulsar-vehicles']:KeysAdd(_joiners[source], Entity(veh).state.VIN)
					if _active.isWorkgroup then
						if #_active.members > 0 then
							for k, v in ipairs(_active.members) do
								exports['pulsar-vehicles']:KeysAdd(v.ID, Entity(veh).state.VIN)
							end
						end
					end
				end)

			exports['pulsar-vehicles']:SpawnTemp(
				source,
				_active.drop.vehicle,
				'automobile',
				vector3(_active.drop.coords[1], _active.drop.coords[2], _active.drop.coords[3]),
				_active.drop.coords[4],
				function(veh)
					Entity(veh).state.Locked = false
					Entity(veh).state.noLockpick = true
					SetVehicleDoorsLocked(veh, 1)
					_active.entity = veh
					_active.VIN = Entity(veh).state.VIN
					exports.ox_inventory:AddItem(_active.VIN, "coke_brick", 4, {}, 4)
					exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
						string.format("Coke:Client:%s:GoTo", _joiners[source]))
				end
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:StartHeist", function(source, data, cb)
		if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 2 then
			_active.state = 3
			exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Locate The Target Vehicle", {
				title = "Unknown",
				label = "Unknown",
				icon = "block-question",
				color = "transparent",
			})
			exports['pulsar-labor']:SendWorkgroupEvent(
				_joiners[source],
				string.format("Coke:Client:%s:SetupHeist", _joiners[source]),
				_active.drop
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:ArrivedAtPoint", function(source, data, cb)
		if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 3 then
			_active.state = 4
			exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Retreive Contraband From Vehicle", {
				title = "Unknown",
				label = "Unknown",
				icon = "block-question",
				color = "transparent",
			})
			exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
				string.format("Coke:Client:%s:DoShit", _joiners[source]))

			if not _active.pedsSpawned then
				_active.pedsSpawned = true
				exports["pulsar-core"]:ClientCallback(source, "Labor:Coke:GetSpawnCoords", _active.drop,
					function(coords)
						local peds = SpawnPeds(source, coords)
						cb(peds)
					end)
			else
				cb(false)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:LeftCayo", function(source, data, cb)
		if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 5 then
			_active.state = 6

			DeleteEntity(_active.entity)
			exports['pulsar-vehicles']:SpawnTemp(source, `bison`, 'automobile', vector3(1293.300, -3168.405, 4.906),
				61.642, function(veh)
					Entity(veh).state.Locked = false
					Entity(veh).state.noLockpick = true
					SetVehicleDoorsLocked(veh, 1)
					_active.entity = veh
					exports['pulsar-labor']:SendWorkgroupEvent(
						_joiners[source],
						string.format("Coke:Client:%s:SetupFinish", _joiners[source])
					)
				end)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Coke:Finish", function(source, data, cb)
		if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 6 then
			DeleteEntity(_active.entity)
			exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
		end
	end)
end)

AddEventHandler("Inventory:Server:Opened", function(source, owner, type)
	if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 4 then
		if owner == _active.VIN and type == 4 then
			_active.state = 5
			exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Meet Contact Back In Los Santos", {
				title = "Unknown",
				label = "Unknown",
				icon = "block-question",
				color = "transparent",
			})
			exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
				string.format("Coke:Client:%s:GoBack", _joiners[source]))
		end
	end
end)

AddEventHandler("Labor:Server:Coke:Queue", function(source, data)
	if _joiners[source] ~= nil and _active.joiner == _joiners[source] and _active.state == 0 then
		_active.state = 1
		_active.drop = cokeDrops[math.random(#cokeDrops)]

		exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
			string.format("Coke:Client:%s:Receive", _joiners[source]))

		exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Speak To The Contact At Cayo Perico", {
			title = "Unknown",
			label = "Unknown",
			icon = "block-question",
			color = "transparent",
		})
	end
end)

AddEventHandler("Coke:Server:OnDuty", function(joiner, members, isWorkgroup)
	if _active ~= nil then
		exports['pulsar-phone']:NotificationAdd(joiner, "Unknown", "No Jobs Available", os.time(), 6000, {
			title = "Unknown",
			label = "Unknown",
			icon = "block-question",
			color = "transparent",
		})
	else
		local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
		if char ~= nil then
			local cd = char:GetData("CokeCD") or os.time()
			if cd > os.time() then
				exports['pulsar-phone']:NotificationAdd(joiner, "Unknown",
					"Your Group Is Not Eligible. Please Wait", os.time(), 6000, {
						title = "Unknown",
						label = "Unknown",
						icon = "block-question",
						color = "transparent",
					})

				if isWorkgroup then
					if #members > 0 then
						for k, v in ipairs(members) do
							exports['pulsar-phone']:NotificationAdd(
								v.ID,
								"Unknown",
								"Your Group Is Not Eligible. Please Wait",
								os.time(),
								6000,
								{
									title = "Unknown",
									label = "Unknown",
									icon = "block-question",
									color = "transparent",
								}
							)
						end
					end
				end
				return
			end
		else
			return
		end

		exports['pulsar-finance']:WalletModify(joiner, -100000)
		GlobalState["CokeRunCD"] = os.time() + (60 * 60 * 6)
		_joiners[joiner] = joiner
		_active = {
			joiner = joiner,
			isWorkgroup = isWorkgroup,
			members = members,
			started = os.time(),
			state = 0,
		}
		GlobalState["CokeRunActive"] = true

		local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
		char:SetData("TempJob", _JOB)
		char:SetData("CokeCD", os.time() + (60 * 60 * 24 * 3))

		TriggerClientEvent("Coke:Client:OnDuty", joiner, joiner, os.time())
		if #members > 0 then
			for k, v in ipairs(members) do
				_joiners[v.ID] = joiner
				local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
				member:SetData("TempJob", _JOB)
				TriggerClientEvent("Coke:Client:OnDuty", v.ID, joiner, os.time())
			end
		end

		exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Wait For Contact", {
			title = "Unknown",
			label = "Unknown",
			icon = "block-question",
			color = "transparent",
		})

		exports['pulsar-core']:WaitListInteractAdd("coke_import", joiner, {
			joiner = joiner,
		})
	end
end)

AddEventHandler("Coke:Server:OffDuty", function(source, joiner)
	_joiners[source] = nil
	TriggerClientEvent("Coke:Client:OffDuty", source)
	exports['pulsar-core']:WaitListInteractRemove("coke_import", source)
end)

AddEventHandler("Coke:Server:FinishJob", function(joiner)
	_active = nil
	GlobalState["CokeRunActive"] = false
end)
