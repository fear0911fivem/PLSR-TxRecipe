local _inVeh = nil

AddEventHandler("Vehicles:Client:EnterVehicle", function(currentVehicle, currentSeat)
	if currentSeat == -1 and _models[GetEntityModel(currentVehicle)] then
		exports['pulsar-taxi']:HudShow()
	end
end)

AddEventHandler("Vehicles:Client:ExitVehicle", function()
	_inVeh = nil
	exports['pulsar-taxi']:HudHide()
end)

RegisterNetEvent("UI:Client:Reset", function(force)
	_inVeh = nil
	exports['pulsar-taxi']:HudReset()
end)
