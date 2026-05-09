_alertsPermMap = {
	[1] = "police_alerts",
	[2] = "ems_alerts",
	[3] = "tow_alerts",
	[4] = "doc_alerts",
}

_alertValidTypes = {
	police = {
		"car",
		"motorcycle",
		"air1",
	},
	ems = {
		"bus",
		"car",
		"lifeflight",
	},
	tow = {
		"truck-tow",
	},
	prison = {
		"car",
	},
}

_alertTypeNames = {
	car = "Ground",
	motorcycle = "Motorcycle",
	air1 = "Air",
	bus = "Ambo",
	lifeflight = "Life Flight",
}

_alertsDefaultType = {
	police = _alertValidTypes.police[1],
	ems = _alertValidTypes.ems[1],
	tow = _alertValidTypes.tow[1],
	prison = _alertValidTypes.prison[1],
}

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterEACallbacks()
		StartAETrackingThreads()
	end
end)

emergencyAlertsData = {}

exports("EmergencyAlertsCreate",
	function(code, title, type, location, description, isPanic, blip, styleOverride, isArea, camera)
		TriggerEvent("ws:mdt-alerts:createAlert", code, title, type, location, description, isPanic, blip, styleOverride,
			isArea, camera)
	end)

exports("EmergencyAlertsOnDuty", function(dutyData, source, stateId, callsign)
	if
		dutyData
		and (dutyData.Id == "police" or dutyData.Id == "ems" or dutyData.Id == "tow" or dutyData.Id == "prison")
	then
		local alertPermissions = {}
		local allJobPermissions = exports['pulsar-jobs']:GetPermissionsFromJob(source, dutyData.Id)
		for k, v in pairs(_alertsPermMap) do
			if allJobPermissions[v] then
				alertPermissions[v] = true
			end
		end

		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		emergencyAlertsData[source] = {
			SID = stateId,
			Source = source,
			Job = dutyData.Id,
			Workplace = dutyData.WorkplaceId,
			Callsign = callsign,
			Phone = char:GetData("Phone"),
			AlertPermissions = alertPermissions,
			First = dutyData.First,
			Last = dutyData.Last,
			Coords = GetEntityCoords(GetPlayerPed(source)),
		}

		exports['pulsar-mdt']:EmergencyAlertsSendMemberUpdates()

		-- if the default "localhost" is used, it is actually replaced with the real server endpoint for the client on the client side (since the endpoint isn't known here)
		local url = GetConvar("WS_MDT_ALERTS", "http://localhost:4002/mdt-alerts")
		local token = exports["pulsar-ws"]:generateSocketToken("mdt-alerts", {
			source = source,
			job = dutyData.Id,
			callsign = dutyData.Id == "tow" and string.format("TOW-%s", stateId) or callsign,
		})

		TriggerClientEvent("EmergencyAlerts:Client:Connect", source, url, token)

		if Player(source).state.trackerDisabled then
			Player(source).state.trackerDisabled = false
		end

		if dutyData.Id == "police" or dutyData.Id == "prison" then
			TriggerEvent("ws:mdt-alerts:addDispatchLog", "dutyChange", nil, string.format(
				"[%s] %s. %s is 10-41 (On Duty)",
				char:GetData("Callsign"),
				char:GetData("First"):sub(1, 1),
				char:GetData("Last")
			), nil, dutyData.Id)
		end
	end
end)

exports("EmergencyAlertsGetUnitData", function(source, job)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local alertPermissions = {}
		local allJobPermissions = exports['pulsar-jobs']:GetPermissionsFromJob(source, job)
		if allJobPermissions then
			for k, v in pairs(_alertsPermMap) do
				if allJobPermissions[v] then
					table.insert(alertPermissions, v)
				end
			end
		end

		return {
			character = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
				Phone = char:GetData("Phone"),
			},
			alerts = alertPermissions
		}
	end
end)

exports("EmergencyAlertsOffDuty", function(dutyData, source, stateId)
	local emergencyMember = emergencyAlertsData[source]
	if emergencyMember then
		TriggerClientEvent("EmergencyAlerts:Client:Disconnect", source)

		local c = exports['pulsar-characters']:FetchCharacterSource(source)
		if c and dutyData and dutyData.Id == "police" or dutyData.Id == "prison" then
			TriggerEvent("ws:mdt-alerts:addDispatchLog", "dutyChange", nil, string.format(
				"[%s] %s. %s is 10-42 (Off Duty)",
				c:GetData("Callsign"),
				c:GetData("First"):sub(1, 1),
				c:GetData("Last")
			), nil, dutyData.Id)
		end

		emergencyAlertsData[source] = nil

		exports['pulsar-mdt']:EmergencyAlertsSendMemberUpdates()
	end
end)

exports("EmergencyAlertsDisableTracker", function(source, state)
	local emergencyMember = emergencyAlertsData[source]
	if
		emergencyMember
		and (emergencyMember.Job == "police" or emergencyMember.Job == "prison" or emergencyMember.Job == "ems")
		and emergencyMember.TrackerDisabled ~= state
	then
		emergencyAlertsData[source].TrackerDisabled = state

		exports['pulsar-mdt']:EmergencyAlertsSendOnDutyEvent("EmergencyAlerts:Client:UpdateMember",
			emergencyAlertsData[source])
	end
end)

exports("EmergencyAlertsRefreshCallsign", function(stateId, newCallsign)
	for k, v in pairs(emergencyAlertsData) do
		if v.SID == stateId then
			emergencyAlertsData[k].Callsign = newCallsign
		end
	end
end)

exports("EmergencyAlertsSendMemberUpdates", function()
	exports['pulsar-mdt']:EmergencyAlertsSendOnDutyEvent("EmergencyAlerts:Client:UpdateMembers", emergencyAlertsData)
end)

exports("EmergencyAlertsSendOnDutyEvent", function(event, data)
	for k, v in pairs(emergencyAlertsData) do
		TriggerClientEvent(event, k, data)
	end
end)
