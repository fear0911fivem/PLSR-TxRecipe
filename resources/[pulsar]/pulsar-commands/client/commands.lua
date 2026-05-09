AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterClientCallback("Commands:SS", function(d, cb)
			TriggerServerEvent("Commands:Server:CaptureScreenshot", d, cb)
		end)
	end
end)

RegisterNetEvent("Commands:Client:TeleportToMarker", function()
	local WaypointHandle = GetFirstBlipInfoId(8)
	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
				break
			end

			Wait(5)
		end
		exports["pulsar-hud"]:Notification("success", "Teleported")
	else
		exports["pulsar-hud"]:Notification("error", "Please place your waypoint.")
	end
end)
