RegisterNetEvent("Phone:Client:SetData", function(type, data, options)
	exports['pulsar-phone']:DataSet(type, data)
end)

RegisterNetEvent("Phone:Client:SetDataMulti", function(data)
	for k, v in ipairs(data) do
		exports['pulsar-phone']:DataSet(v.type, v.data)
	end
end)

RegisterNetEvent("Phone:Client:AddData", function(type, data, id)
	exports['pulsar-phone']:DataAdd(type, data, id)
end)

RegisterNetEvent("Phone:Client:UpdateData", function(type, id, data)
	exports['pulsar-phone']:DataUpdate(type, id, data)
end)

RegisterNetEvent("Phone:Client:RemoveData", function(type, id)
	exports['pulsar-phone']:DataRemove(type, id)
end)

RegisterNetEvent("Phone:Client:ResetData", function()
	exports['pulsar-phone']:DataReset()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	SendNUIMessage({ type = "PHONE_NOT_VISIBLE" })
	exports['pulsar-phone']:DataReset()
	exports['pulsar-phone']:NotificationReset()
	exports['pulsar-phone']:ResetRoute()
end)
