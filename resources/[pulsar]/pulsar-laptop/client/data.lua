RegisterNetEvent("Laptop:Client:SetData", function(type, data, options)
	exports['pulsar-laptop']:SetData(type, data)
end)

RegisterNetEvent("Laptop:Client:AddData", function(type, data, id)
	exports['pulsar-laptop']:AddData(type, data, id)
end)

RegisterNetEvent("Laptop:Client:UpdateData", function(type, id, data)
	exports['pulsar-laptop']:UpdateData(type, id, data)
end)

RegisterNetEvent("Laptop:Client:RemoveData", function(type, id)
	exports['pulsar-laptop']:RemoveData(type, id)
end)

RegisterNetEvent("Laptop:Client:ResetData", function()
	exports['pulsar-laptop']:ResetData()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	SendNUIMessage({ type = "LAPTOP_NOT_VISIBLE" })
	exports['pulsar-laptop']:ResetData()
	exports['pulsar-laptop']:ResetNotifications()
	exports['pulsar-laptop']:ResetRoute()
	SendNUIMessage({ type = "CLOSE_ALL_APPS" })
end)
