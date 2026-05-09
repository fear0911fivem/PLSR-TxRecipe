AddEventHandler("Vehicles:Client:StartUp", function()
	exports["pulsar-core"]:RegisterClientCallback("Vehicles:UseCamberController", function(data, cb)
		local vehEnt = Entity(VEHICLE_INSIDE)
		if
			VEHICLE_INSIDE
			and DoesEntityExist(VEHICLE_INSIDE)
			and IsEntityAVehicle(VEHICLE_INSIDE)
			and GetPedInVehicleSeat(VEHICLE_INSIDE, -1) == LocalPlayer.state.ped
		then
			if exports['pulsar-police']:IsPdCar(VEHICLE_INSIDE) or exports['pulsar-police']:IsEMSCar(VEHICLE_INSIDE) then
				exports["pulsar-hud"]:Notification("error", "How About No")
				cb(false)
				return
			end

			local vehModel = GetEntityModel(VEHICLE_INSIDE)

			if
				IsThisModelABike(vehModel)
				or IsThisModelABicycle(vehModel)
				or IsThisModelAPlane(vehModel)
				or IsThisModelAHeli(vehModel)
				or IsThisModelABoat(vehModel)
			then
				cb(false)
				return
			end

			exports['pulsar-hud']:Progress({
				name = "vehicle_camber_controller",
				duration = 5000,
				label = "Plugging In Controller",
				useWhileDead = false,
				canCancel = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = false,
				},
				animation = {
					anim = "mechanic2",
				},
			}, function(cancelled)
				if not cancelled and VEHICLE_INSIDE then
					cb(VehToNet(VEHICLE_INSIDE))
				else
					cb(false)
				end
			end)
		else
			cb(false)
		end
	end)
end)
