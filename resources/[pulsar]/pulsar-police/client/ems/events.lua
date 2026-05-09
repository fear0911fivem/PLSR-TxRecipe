AddEventHandler("EMS:Client:OnDuty", function()
	if exports['pulsar-jobs']:HasJob("ems", "safd") and not LocalPlayer.state.Character:GetData("Callsign") then
		exports["pulsar-hud"]:Notification("error", "Callsign Not Set, Unable To Go On Duty")
		return
	end

	local susp = LocalPlayer.state.Character:GetData("MDTSuspension")
	if susp and susp.ems and susp.ems.Expires > GetCloudTimeAsInt() then
		local tr = GetFormattedTimeFromSeconds(susp.ems.Expires - GetCloudTimeAsInt())
		exports["pulsar-hud"]:Notification("error",
			string.format("You Have Been Suspended (%s Remaining), Unable To Go On Duty",
				tr))
		return
	end

	exports['pulsar-jobs']:DutyOn("ems")
end)

AddEventHandler("EMS:Client:OffDuty", function()
	exports['pulsar-jobs']:DutyOff("ems")
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_evald = {}
end)

AddEventHandler("EMS:Client:Evaluate", function(entity, data)
	if not entity then
		return
	end

	exports['pulsar-hud']:ProgressWithStartEvent({
		name = "ems_eval",
		duration = 6000,
		label = "Evaluating Patient",
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "amb@medic@standing@tendtodead@idle_a",
			anim = "idle_b",
			flags = 9,
		},
	}, function() end, function(cancelled)
		if not cancelled then
			BuildTreatmentMenu(entity.serverId)
		end
	end)
end)

AddEventHandler("EMS:Client:DrugTest", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "drug_test_action",
		duration = 6000,
		label = "Performing Drug Test",
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
			task = "WORLD_HUMAN_STAND_MOBILE",
		},
	}, function(cancelled)
		if not cancelled then
			exports["pulsar-core"]:ServerCallback("EMS:DrugTest", entity.serverId, function() end)
		end
	end)
end)

AddEventHandler("EMS:Client:DismissTreatment", function()
	exports['pulsar-hud']:ListMenuClose()
end)

AddEventHandler("EMS:Client:CheckICUPatients", function()
	TriggerServerEvent("EMS:Server:CheckICUPatients")
end)

AddEventHandler("EMS:Client:Stabilize", function(target, idk)
	if exports.ox_inventory:ItemsHas("traumakit", 1) then
		exports['pulsar-hud']:ProgressWithStartEvent({
			name = "ems_eval",
			duration = 10000,
			label = "Stabilizing",
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@medic@standing@tendtodead@idle_a",
				anim = "idle_b",
				flags = 9,
			},
		}, function() end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("EMS:Stabilize", target, function(res)
					if not res.error then
						exports["pulsar-hud"]:Notification("success", "Patient Stabilized")
					else
						if res.code == 2 then
							exports["pulsar-hud"]:Notification("error", "Need A Trauma Kit")
						else
							exports["pulsar-hud"]:Notification("error", "Unable To Stabilize Patient")
						end
					end
				end)
			end
		end)
	else
		exports["pulsar-hud"]:Notification("error", "Need A Trauma Kit")
	end
end)

-- AddEventHandler("EMS:Client:ApplyTourniquet", function(data)
-- 	if exports.ox_inventory:ItemsHas("tourniquet", 1) then
-- 		exports['pulsar-hud']:ProgressWithStartEvent({
-- 			name = "ems_eval",
-- 			duration = 4000,
-- 			label = "Applying Tourniquet",
-- 			canCancel = true,
-- 			controlDisables = {
-- 				disableMovement = true,
-- 				disableCarMovement = true,
-- 				disableMouse = false,
-- 				disableCombat = true,
-- 			},
-- 			animation = {
-- 				animDict = "amb@medic@standing@tendtodead@idle_a",
-- 				anim = "idle_b",
-- 				flags = 9,
-- 			},
-- 		}, function() end, function(cancelled)
-- 			if not cancelled then
-- 				exports["pulsar-core"]:ServerCallback("EMS:ApplyTourniquet", data, function(res)
-- 					if not res.error then
-- 						exports["pulsar-hud"]:Notification("success", "Tourniquet Applied")
-- 					else
-- 						if res.code == 2 then
-- 							exports["pulsar-hud"]:Notification("error", "Need A Tourniquet")
-- 						else
-- 							exports["pulsar-hud"]:Notification("error", "Unable To Apply Tourniquet")
-- 						end
-- 					end
-- 				end)
-- 			end
-- 		end)
-- 	else
-- 		exports["pulsar-hud"]:Notification("error", "Need A Tourniquet")
-- 	end
-- end)

AddEventHandler("EMS:Client:FieldTreatWounds", function(data)
	if exports.ox_inventory:ItemsHas("traumakit", 1) then
		exports['pulsar-hud']:ProgressWithStartEvent({
			name = "ems_eval",
			duration = 4000,
			label = "Treating Wounds",
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@medic@standing@tendtodead@idle_a",
				anim = "idle_b",
				flags = 9,
			},
		}, function() end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("EMS:FieldTreatWounds", data, function(res)
					if not res.error then
						local ped = GetPlayerPed(GetPlayerFromServerId(tonumber(data)))
						local mHp = GetEntityHealth(ped) - 100
						SetEntityHealth(ped, (mHp / 2))
						exports["pulsar-hud"]:Notification("success", "Wounds Treated")
					else
						if res.code == 2 then
							exports["pulsar-hud"]:Notification("error", "Need A Trauma Kit")
						else
							exports["pulsar-hud"]:Notification("error", "Unable To Treat Patient")
						end
					end
				end)
			end
		end)
	else
		exports["pulsar-hud"]:Notification("error", "Need A Trauma Kit")
	end
end)

AddEventHandler("EMS:Client:ApplyBandage", function(data)
	if exports.ox_inventory:ItemsHas("bandage", 1) then
		exports['pulsar-hud']:ProgressWithStartEvent({
			name = "ems_eval",
			duration = 3000,
			label = "Applying Bandage",
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@medic@standing@tendtodead@idle_a",
				anim = "idle_b",
				flags = 9,
			},
		}, function() end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("EMS:ApplyBandage", data, function(res)
					if not res.error then
						exports["pulsar-hud"]:Notification("success", "Bandage Applied")
					else
						if res.code == 2 then
							exports["pulsar-hud"]:Notification("error", "Need A Trauma Kit")
						else
							exports["pulsar-hud"]:Notification("error", "Unable To Apply Bandage")
						end
					end
				end)
			end
		end)
	else
		exports["pulsar-hud"]:Notification("error", "Need A Bandage")
	end
end)

AddEventHandler("EMS:Client:ApplyMorphine", function(data)
	if exports.ox_inventory:ItemsHas("morphine", 1) then
		exports['pulsar-hud']:ProgressWithStartEvent({
			name = "ems_eval",
			duration = 3000,
			label = "Administering Morphine",
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@medic@standing@tendtodead@idle_a",
				anim = "idle_b",
				flags = 9,
			},
		}, function() end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("EMS:ApplyMorphine", data, function(res)
					if not res.error then
						exports["pulsar-hud"]:Notification("success", "Morphine Administered")
					else
						if res.code == 2 then
							exports["pulsar-hud"]:Notification("error", "Need A Morphine Vial")
						else
							exports["pulsar-hud"]:Notification("error", "Unable To Administer Morphine")
						end
					end
				end)
			end
		end)
	else
		exports["pulsar-hud"]:Notification("error", "Need A Morphine Vial")
	end
end)

RegisterNetEvent("EMS:Client:TreatWounds", function(data)
	if Player(data).state.isHospitalized then
		exports['pulsar-animations']:EmotesForceCancel()
		exports['pulsar-hud']:ProgressWithStartEvent({
			name = "ems_eval",
			duration = 20000,
			label = "Treating Patient",
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@medic@standing@tendtodead@idle_a",
				anim = "idle_b",
				flags = 9,
			},
		}, function() end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("EMS:TreatWounds", data, function(res)
					if res.error then
						exports["pulsar-hud"]:Notification("error", "Unable To Treat Patient")
					end
				end)
			end
		end)
	else
		exports["pulsar-hud"]:Notification("error", "Patient Is Not Hospitalized")
	end
end)
