AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-kbs"]:Add("admin_menu", "HOME", "keyboard", "[Admin] Open Admin Menu", function()
			exports['pulsar-admin']:OpenMenu()
		end)

		exports["pulsar-kbs"]:Add("admin_noclip", "END", "keyboard", "[Admin] Toggle NoClip", function()
			if LocalPlayer.state.isStaff then
				exports["pulsar-core"]:ServerCallback("Admin:NoClip", {
					active = not exports['pulsar-admin']:NoClipIsActive(),
				}, function(isAdmin)
					if isAdmin then
						exports['pulsar-admin']:NoClipToggle()
					end
				end)
			end
		end)

		exports["pulsar-kbs"]:Add("admin_debug1", "", "keyboard", "[Admin] Debug 1", function()
			DoAdminVehicleAction("repair_engine")
		end)

		exports["pulsar-kbs"]:Add("admin_debug2", "", "keyboard", "[Admin] Debug 2", function()
			DoAdminVehicleAction("repair")
		end)

		exports["pulsar-kbs"]:Add("admin_debug3", "", "keyboard", "[Admin] Debug IDs", function()
			if LocalPlayer.state.isStaff then
				ToggleAdminPlayerIDs()
			end
		end)
	end
end)

exports("OpenMenu", function()
	OpenMenu()
end)

exports("CopyClipboard", function(txt)
	CopyClipboard(txt)
end)

RegisterNetEvent("Admin:Client:CopyClipboard", function(data)
	CopyClipboard(data)
end)

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
	exports['pulsar-admin']:NoClipStop()
	_drawingCoords = false
end)

function DrawShittyText(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(4)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end

RegisterNetEvent("Admin:Client:Marker", function(x, y)
	SetNewWaypoint(x, y)
end)

RegisterNetEvent("Admin:Client:CopyCoords", function(action)
	local ped = PlayerPedId()
	local pedCoords = GetEntityCoords(ped)
	local pedHeading = GetEntityHeading(ped)
	local petRotation = GetEntityRotation(ped)

	if action == "vec4" then
		CopyClipboard(
			string.format("vector4(%.3f, %.3f, %.3f, %.3f)", pedCoords.x, pedCoords.y, pedCoords.z, pedHeading)
		)
	elseif action == "vec2" then
		CopyClipboard(string.format("vector2(%.3f, %.3f)", pedCoords.x, pedCoords.y))
	elseif action == "z" then
		CopyClipboard(string.format("%.3f", pedCoords.z))
	elseif action == "h" then
		CopyClipboard(string.format("%.3f", pedHeading))
	elseif action == "table" then
		CopyClipboard(string.format(
			[[
            x = %.3f,
            y = %.3f,
            z = %.3f,
            h = %.3f,]],
			pedCoords.x,
			pedCoords.y,
			pedCoords.z,
			pedHeading
		))
	elseif action == "rot" then
		CopyClipboard(string.format("vector3(%.3f, %.3f, %.3f)", petRotation.x, petRotation.y, petRotation.z))
	elseif action == "cctv" then
		CopyClipboard(
			string.format(
				"x = %.3f, y = %.3f, z = %.3f, r = { x = %.3f, y = %.3f, z = %.3f }",
				pedCoords.x,
				pedCoords.y,
				pedCoords.z,
				petRotation.x,
				petRotation.y,
				petRotation.z
			)
		)
	else
		CopyClipboard(string.format("vector3(%.3f, %.3f, %.3f)", pedCoords.x, pedCoords.y, pedCoords.z))
	end
end)

RegisterNetEvent("Admin:Client:Recording", function(action)
	if action == "record" then
		StartRecording(1)
	elseif action == "stop" then
		StopRecordingAndSaveClip()
	elseif action == "delete" then
		StopRecordingAndDiscardClip()
	elseif action == "editor" then
		NetworkSessionLeaveSinglePlayer()
		ActivateRockstarEditor()
	end
end)

RegisterNetEvent("Admin:Client:ChangePed", function(model)
	local hash = GetHashKey(model)
	if IsModelValid(hash) then
		if not HasModelLoaded(hash) then
			RequestModel(hash)
			while not HasModelLoaded(hash) do
				Wait(100)
			end
		end

		SetPlayerModel(PlayerId(), hash)
		SetPedDefaultComponentVariation(PlayerPedId())
		SetModelAsNoLongerNeeded(hash)
	end
end)

function DoAdminVehicleAction(action)
	local insideVehicle = GetVehiclePedIsIn(LocalPlayer.state.ped, false)
	if
		LocalPlayer.state.isDev
		and insideVehicle
		and insideVehicle > 0
		and DoesEntityExist(insideVehicle)
		and NetworkHasControlOfEntity(insideVehicle)
	then
		exports["pulsar-core"]:ServerCallback("Admin:CurrentVehicleAction", { action = action }, function(canDo)
			if canDo then
				if action == "repair" then
					if exports['pulsar-vehicles']:RepairNormal(insideVehicle) then
					end
				elseif action == "repair_full" then
					if exports['pulsar-vehicles']:RepairFull(insideVehicle) then
					end
				elseif action == "repair_engine" then
					if exports['pulsar-vehicles']:RepairEngine(insideVehicle) then
					end
				end
			end
		end)
	end
end

local stateBagLog
RegisterNetEvent("Admin:Client:StateBagLog", function()
	if stateBagLog then
		RemoveStateBagChangeHandler(stateBagLog)
		stateBagLog = nil
	else
		stateBagLog = AddStateBagChangeHandler(nil, nil, function(bagName, key, value, reserved, replicated)
			local player = GetPlayerFromStateBagName(bagName)
			if replicated or bagName == "global" or (player and PlayerId() ~= player) then
				print(bagName, key, value, replicated, #json.encode(value), json.encode(value))
			end
		end)
	end
end)
