local _pb = RobberyConfig.paleto

function PaletoIsGloballyReady(source, isHack)
	if
		GlobalState["RestartLockdown"] ~= false
		and (
			GetGameTimer() < _pb.serverStartWait
			or (GlobalState["RestartLockdown"] and not GlobalState["PaletoInProgress"])
		)
	then
		if isHack then
			exports['pulsar-hud']:Notification(source, "error",
				"Network Offline For A Storm, Check Back Later", 6000)
		else
			exports['pulsar-hud']:Notification(source, "error",
				"You Notice The Door Is Barricaded For A Storm, Maybe Check Back Later",
				6000
			)
		end
		return false
	elseif (GlobalState["Duty:police"] or 0) < _pb.requiredPolice and not GlobalState["PaletoInProgress"] then
		exports['pulsar-hud']:Notification(source, "error",
			"Enhanced Security Measures Enabled, Maybe Check Back Later When Things Feel Safer",
			6000
		)
		return false
	elseif GlobalState["RobberiesDisabled"] then
		exports['pulsar-hud']:Notification(source, "error",
			"Temporarily Disabled, Please See City Announcements", 6000)
		return false
	end

	return true
end

function DisablePaletoPower(source)
	if not _pbGlobalReset or os.time() > _pbGlobalReset then
		_pbGlobalReset = os.time() + _pb.resetTime
	end

	for k, v in ipairs(_pb.pcHackAreas) do
		exports['pulsar-robbery']:StateUpdate("paleto", v.data.pcId, _pbGlobalReset, "exploits")
	end

	for k, v in ipairs(_pb.subStations) do
		exports['pulsar-robbery']:StateUpdate("paleto", k, _pbGlobalReset, "substations")
	end

	for k, v in ipairs(_pb.powerHacks) do
		exports['pulsar-robbery']:StateUpdate("paleto", v.data.boxId, _pbGlobalReset, "electricalBoxes")
	end

	exports['pulsar-cctv']:StateGroupOffline("paleto")

	exports['pulsar-robbery']:TriggerPDAlert(source, vector3(-195.586, 6338.740, 31.515), "10-33",
		"Regional Power Grid Disruption", {
			icon = 354,
			size = 0.9,
			color = 31,
			duration = (60 * 5),
		}, {
			icon = "bolt-slash",
			details = "Paleto",
		}, false, 250.0)

	GlobalState["Fleeca:Disable:savings_paleto"] = true
	exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", false)
	RestorePowerThread()
end

function PaletoClearSourceInUse(source)
	for k, v in pairs(_pbInUse) do
		if v == source then
			_pbInUse[k] = nil
		elseif type(v) == "table" then
			for k2, v2 in pairs(v) do
				if v2 == source then
					_pbInUse[k][k2] = nil
				end
			end
		end
	end
end

function ResetPaleto()
	if _bankStates.paleto.fookinLasers then
		TriggerClientEvent("Sounds:Client:Stop:Distance", -1, _bankStates.paleto.fookinLasers, "bank_alarm.ogg")
	end

	for k, v in ipairs(_pb.doorIds) do
		exports['ox_doorlock']:SetLock(v, true)
	end

	exports['pulsar-robbery']:StateSet("paleto", {
		fookinLasers = false,
		workstation = false,
		vaultTerminal = false,
		exploits = {},
		securityPower = {},
		electricalBoxes = {},
		substations = {},
		officeHacks = {},
		drillPoints = {},
	})
	_pbGlobalReset = os.time() + _pb.resetTime

	exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", true)
	exports['pulsar-cctv']:StateGroupOnline("paleto")

	TriggerClientEvent("Robbery:Client:Paleto:ResetLasers", -1)

	GlobalState["Fleeca:Disable:savings_paleto"] = false
	GlobalState["PaletoInProgress"] = false
	GlobalState["Paleto:Secured"] = false
	GlobalState["Sync:PaletoBlackout"] = false
end

function SecurePaleto()
	if _bankStates.paleto.fookinLasers then
		TriggerClientEvent("Sounds:Client:Stop:Distance", -1, _bankStates.paleto.fookinLasers, "bank_alarm.ogg")
	end

	for k, v in ipairs(_pb.doorIds) do
		exports['ox_doorlock']:SetLock(v, true)
	end

	exports['pulsar-robbery']:StateSet("paleto", {
		fookinLasers = false,
		workstation = false,
		vaultTerminal = false,
		exploits = {},
		securityPower = {},
		electricalBoxes = {},
		substations = {},
		officeHacks = {},
		drillPoints = {},
	})
	_pbGlobalReset = os.time() + _pb.resetTime

	exports['ox_doorlock']:SetLock("pulsar_bank_savings_paleto_gate", true)
	exports['pulsar-cctv']:StateGroupOnline("paleto")

	TriggerClientEvent("Robbery:Client:Paleto:ResetLasers", -1)

	GlobalState["Fleeca:Disable:savings_paleto"] = false
	GlobalState["PaletoInProgress"] = false
	GlobalState["Paleto:Secured"] = _pbGlobalReset
end

function IsSecurityAccessible()
	for k, v in ipairs(_pb.securityPower) do
		if
			not _bankStates.paleto.securityPower[v.powerId]
			or os.time() > _bankStates.paleto.securityPower[v.powerId]
		then
			return false
		end
	end
	return true
end
