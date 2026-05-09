_state = false
_rate = GetResourceKvpInt("TAXI_RATE") or 10

exports('HudShow', function()
	local veh = GetVehiclePedIsIn(LocalPlayer.state.ped)
	if _models[GetEntityModel(veh)] and GetPedInVehicleSeat(veh, -1) == LocalPlayer.state.ped then
		_inVeh = veh

		_state = true
		DoTaxiThread(veh)
		SendNUIMessage({
			type = "APP_SHOW",
			data = {
				rate = _rate,
			},
		})
	end
end)

exports('HudHide', function()
	_state = false
	SendNUIMessage({
		type = "APP_HIDE",
	})
end)

exports('HudReset', function()
	_state = false
	SendNUIMessage({
		type = "APP_RESET",
	})
end)

exports('HudToggle', function()
	if _state then
		exports['pulsar-taxi']:HudHide()
	else
		exports['pulsar-taxi']:HudShow()
	end
end)

exports('RateIncrease', function()
	if _rate < 1000 then
		_rate = _rate + 1
		SetResourceKvpInt("TAXI_RATE", _rate)
		SendNUIMessage({
			type = "SET_RATE",
			data = {
				rate = _rate,
			},
		})
	else
		exports["pulsar-hud"]:Notification("error", "Rate Cannot Go Higher")
	end
end)

exports('RateDecrease', function()
	if _rate > 0 then
		_rate = _rate - 1
		SetResourceKvpInt("TAXI_RATE", _rate)
		SendNUIMessage({
			type = "SET_RATE",
			data = {
				rate = _rate,
			},
		})
	else
		exports["pulsar-hud"]:Notification("error", "Rate Cannot Go Lower")
	end
end)

exports('TripReset', function()
	SendNUIMessage({
		type = "RESET_TRIP",
	})
end)

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-kbs"]:Add("taxi_increase_rate", "", "keyboard", "Taxi - Increase Rate", function()
			exports['pulsar-taxi']:RateIncrease()
		end)

		exports["pulsar-kbs"]:Add("taxi_decrease_rate", "", "keyboard", "Taxi - Decrease Rate", function()
			exports['pulsar-taxi']:RateDecrease()
		end)

		exports["pulsar-kbs"]:Add("taxi_reset_trip", "", "keyboard", "Taxi - Reset Trip", function()
			exports['pulsar-taxi']:TripReset()
		end)

		exports["pulsar-kbs"]:Add("taxi_toggle_hud", "", "keyboard", "Taxi - Toggle HUD", function()
			exports['pulsar-taxi']:HudToggle()
		end)
	end
end)

local _threading = false
function DoTaxiThread(veh)
	if _threading then
		return
	end
	_threading = true

	local prevLocation = GetEntityCoords(veh)
	CreateThread(function()
		while LocalPlayer.state.loggedIn and _inVeh == veh and _state do
			local currLocation = GetEntityCoords(veh)
			local dist = #(currLocation - prevLocation)
			SendNUIMessage({
				type = "UPDATE_TRIP",
				data = {
					trip = dist,
				},
			})
			prevLocation = currLocation
			Wait(1000)
		end
		_threading = false
	end)
end
