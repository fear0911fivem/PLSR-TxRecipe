_myTeam = nil

RegisterNetEvent("Laptop:Client:Teams:Set", function(teamData)
	_myTeam = teamData

	exports['pulsar-laptop']:SetData("myGroup", _myTeam)
end)

RegisterNUICallback("GetTeams", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:Get", {}, cb)
end)

RegisterNUICallback("GetTeamRequests", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:GetRequests", {}, cb)
end)

RegisterNUICallback("CreateTeam", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:Create", data, cb)
end)

RegisterNUICallback("InviteTeamMember", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:Members:Invite", data, cb)
end)

RegisterNUICallback("RemoveTeamMember", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:Members:Remove", data, cb)
end)

RegisterNUICallback("RequestTeamInvite", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:RequestInvite", data, cb)
end)

RegisterNUICallback("DeleteTeam", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:Delete", data, cb)
end)

RegisterNUICallback("TeamRequest", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Laptop:Teams:ActionRequest", data, function()
		cb('OK')
	end)
end)

AddEventHandler("Laptop:Client:Teams:RequestNotifAccept", function(data)
	if not data.request then
		return
	end

	exports["pulsar-core"]:ServerCallback("Laptop:Teams:ActionRequest", {
		id = data.request,
		action = "accept",
	})
end)

AddEventHandler("Laptop:Client:Teams:RequestNotifDeny", function(data)
	if not data.request then
		return
	end

	exports["pulsar-core"]:ServerCallback("Laptop:Teams:ActionRequest", {
		id = data.request,
		action = "deny",
	})
end)
