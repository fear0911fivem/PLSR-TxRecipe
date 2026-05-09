AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		TriggerEvent("Labor:Client:Setup")
	end
end)

function Draw3DText(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())

	SetTextScale(0.25, 0.25)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 245)
	SetTextOutline(true)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
end

function PedFaceCoord(pPed, pCoords)
	TaskTurnPedToFaceCoord(pPed, pCoords.x, pCoords.y, pCoords.z)

	Wait(100)

	while GetScriptTaskStatus(pPed, 0x574bb8f5) == 1 do
		Wait(0)
	end
end

AddEventHandler("Labor:Client:AcceptRequest", function(data)
	exports["pulsar-core"]:ServerCallback("Labor:AcceptRequest", data)
end)

AddEventHandler("Labor:Client:DeclineRequest", function(data)
	exports["pulsar-core"]:ServerCallback("Labor:DeclineRequest", data)
end)

exports('GetJobs', function()
	local p = promise.new()
	exports["pulsar-core"]:ServerCallback("Labor:GetJobs", {}, function(jobs)
		p:resolve(jobs)
	end)
	return Citizen.Await(p)
end)

exports('GetGroups', function()
	local p = promise.new()
	exports["pulsar-core"]:ServerCallback("Labor:GetGroups", {}, function(groups)
		p:resolve(groups)
	end)
	return Citizen.Await(p)
end)

exports('GetReputations', function()
	local p = promise.new()
	exports["pulsar-core"]:ServerCallback("Labor:GetReputations", {}, function(jobs)
		p:resolve(jobs)
	end)
	return Citizen.Await(p)
end)
