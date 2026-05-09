RegisterNUICallback("Search", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Search:" .. data.type, data, cb)
end)

RegisterNUICallback("InputSearch", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:InputSearch:" .. data.type, data, cb)
end)

RegisterNUICallback("InputSearchSID", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:InputSearchSID", data, cb)
end)

RegisterNUICallback("View", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:View:" .. data.type, data.id, cb)
end)

RegisterNUICallback("Create", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Create:" .. data.type, data, cb)
end)

RegisterNUICallback("Update", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Update:" .. data.type, data, cb)
end)

RegisterNUICallback("Delete", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Delete:" .. data.type, data, cb)
end)

RegisterNUICallback("SentencePlayer", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:SentencePlayer", data, cb)
end)

RegisterNUICallback("IssueWarrant", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:IssueWarrant", data, cb)
end)

RegisterNUICallback("ManageEmployment", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:ManageEmployment", data, cb)
end)

RegisterNUICallback("HireEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Hire", data, cb)
end)

RegisterNUICallback("FireEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Fire", data, cb)
end)

RegisterNUICallback("SuspendEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Suspend", data, cb)
end)

RegisterNUICallback("UnsuspendEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:Unsuspend", data, cb)
end)

RegisterNUICallback("CheckCallsign", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:CheckCallsign", data, cb)
end)

RegisterNUICallback("RosterView", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:RosterView", data, cb)
end)

RegisterNUICallback("RosterSelect", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:RosterSelect", data, cb)
end)

RegisterNUICallback("GetProperties", function(data, cb)
	local properties = exports['pulsar-properties']:GetProperties()

	local data = {}
	if properties then
		for k, v in pairs(properties) do
			table.insert(data, v)
		end
	end

	cb(data)
end)

RegisterNUICallback("FindProperty", function(data, cb)
	local prop = exports['pulsar-properties']:Get(data)
	if prop ~= nil then
		ClearGpsPlayerWaypoint()
		SetNewWaypoint(prop.location.front.x, prop.location.front.y)
		cb(true)
	else
		cb(false)
	end
end)

RegisterNUICallback("EvidenceLocker", function(data, cb)
    exports["pulsar-core"]:ServerCallback("MDT:OpenEvidenceLocker", data, cb)
end)

RegisterNUICallback("PrintBadge", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:PrintBadge", data, cb)
end)

RegisterNUICallback("RevokeSuspension", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:RevokeLicenseSuspension", data, cb)
end)

RegisterNUICallback("ClearRecord", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:ClearCriminalRecord", data, cb)
end)

RegisterNUICallback("RemovePoints", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:RemoveLicensePoints", data, cb)
end)

RegisterNUICallback("OverturnSentence", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:OverturnSentence", data, cb)
end)

RegisterNUICallback("ViewVehicleFleet", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:ViewVehicleFleet", data, cb)
end)

RegisterNUICallback("SetAssignedDrivers", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:SetAssignedDrivers", data, cb)
end)

RegisterNUICallback("TrackFleetVehicle", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:TrackFleetVehicle", data, function(data)
		if data then
			DeleteWaypoint()
			SetNewWaypoint(data.x, data.y)
			cb(true)
		else
			cb(false)
		end
	end)
end)

RegisterNUICallback("GetHomeData", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:GetHomeData", data, cb)
end)

RegisterNUICallback("GetLibraryDocuments", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:GetLibraryDocuments", data, cb)
end)

RegisterNUICallback("AddLibraryDocument", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:AddLibraryDocument", data, cb)
end)

RegisterNUICallback("RemoveLibraryDocument", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:RemoveLibraryDocument", data, cb)
end)

RegisterNUICallback("DOCGetPrisoners", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:DOCGetPrisoners", data, cb)
end)

RegisterNUICallback("DOCReduceSentence", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:DOCReduceSentence", data, cb)
end)

RegisterNUICallback("DOCRequestVisitation", function(data, cb)
	exports["pulsar-core"]:ServerCallback("MDT:DOCRequestVisitation", data, cb)
end)
