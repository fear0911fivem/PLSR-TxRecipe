local _mdtProp = false
local _badgeOpen = false

local badgeIdOpen = false

local _sendEventOnClose = false

exports("Open", function()
	if not _mdtOpen then
		_mdtOpen = true
		SendNUIMessage({ type = "APP_SHOW" })
		SetNuiFocus(true, true)

		exports['pulsar-animations']:EmotesForceCancel()
		TriggerEvent('ox_inventory:disarm', LocalPlayer.state.ped, true)

		CreateThread(function()
			local playerPed = PlayerPedId()
			LoadAnim("amb@code_human_in_bus_passenger_idles@female@tablet@base")
			LoadModel(`prop_cs_tablet`)

			_mdtProp = CreateObject(`prop_cs_tablet`, GetEntityCoords(playerPed), 1, 1, 0)
			SetEntityCollision(_mdtProp, false, true)
			AttachEntityToEntity(
				_mdtProp,
				playerPed,
				GetPedBoneIndex(playerPed, 60309),
				0.02,
				-0.01,
				-0.03,
				0.0,
				0.0,
				-10.0,
				1,
				0,
				0,
				0,
				2,
				1
			)

			while _mdtOpen and _loggedIn do
				if
					not IsEntityPlayingAnim(
						playerPed,
						"amb@code_human_in_bus_passenger_idles@female@tablet@base",
						"base",
						3
					)
				then
					TaskPlayAnim(
						playerPed,
						"amb@code_human_in_bus_passenger_idles@female@tablet@base",
						"base",
						3.0,
						3.0,
						-1,
						49,
						0,
						false,
						false,
						false
					)
				end
				Wait(250)
			end

			StopAnimTask(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0)
			DeleteEntity(_mdtProp)
		end)
	end
end)

exports("Close", function()
	if _mdtOpen then
		_mdtOpen = false
		_openCd = false
		SendNUIMessage({ type = "APP_HIDE" })
		SetNuiFocus(false, false)

		DeleteEntity(_mdtProp)

		if _sendEventOnClose then
			_sendEventOnClose = false
			TriggerServerEvent("MDT:Server:CloseMDT")
		end

		exports['pulsar-mdt']:DataSet("prison", false)
	end
end)

exports("DataSet", function(key, data)
	SendNUIMessage({ type = "SET_DATA", data = { type = key, data = data } })
end)

exports("DataAdd", function(type, data, key)
	SendNUIMessage({ type = "ADD_DATA", data = { type = type, data = data, key = key } })
end)

exports("DataUpdate", function(type, id, data)
	SendNUIMessage({ type = "UPDATE_DATA", data = { type = type, id = id, data = data } })
end)

exports("DataRemove", function(key, id)
	SendNUIMessage({ type = "REMOVE_DATA", data = { type = key, id = id } })
end)

exports("DataReset", function()
	SendNUIMessage({ type = "RESET_DATA" })
end)

exports("BadgesOpen", function(data)
	if data and data.First and data.Last and data.Department and data.SID then
		-- Dumb But Yeah
		if data.Title == "Asst. District Attorney" then
			data.Title = "ADA"
		elseif data.Title == "Chief Public Defender" then
			data.Title = "Chf. Pub. Defender"
		elseif data.Title == "Superior Court Judge" then
			data.Title = "Superior Judge"
		elseif data.Title == "Probationary Officer" then
			data.Title = "Prob. Officer"
		elseif data.Title == "Probationary Deputy" then
			data.Title = "Prob. Deputy"
		elseif data.Title == "Probationary Trooper" then
			data.Title = "Prob. Trooper"
		elseif data.Title == "Emergency Medical Technician" then
			data.Title = "EMT"
		elseif data.Title == "Senior Emergency Medical Technician" then
			data.Title = "Senior EMT"
		end

		SendNUIMessage({
			type = "SHOW_GOV_ID",
			data = data,
		})
		_badgeOpen = true
		badgeIdOpen = data.SID

		SetTimeout(9000, function()
			if _badgeOpen and badgeIdOpen == data.SID then
				exports['pulsar-mdt']:BadgesClose()
			end
		end)
	end
end)

exports("BadgesClose", function()
	if _badgeOpen then
		SendNUIMessage({ type = "HIDE_GOV_ID" })
		_badgeOpen = false
		badgeIdOpen = false
	end
end)

exports("LicensesOpen", function(data)
	if data and data.Name and data.SID then
		SendNUIMessage({
			type = "SHOW_DRIVER_LICENSE",
			data = data,
		})
		_badgeOpen = true
		badgeIdOpen = data.SID

		SetTimeout(9000, function()
			if _badgeOpen and badgeIdOpen == data.SID then
				exports['pulsar-mdt']:LicensesClose()
			end
		end)
	end
end)

exports("LicensesClose", function()
	if _badgeOpen then
		SendNUIMessage({ type = "HIDE_DRIVER_LICENSE" })
		_badgeOpen = false
		badgeIdOpen = false
	end
end)

RegisterNetEvent("MDT:Client:Toggle", function(eventOnClose)
	_sendEventOnClose = eventOnClose
	if _mdtOpen then
		exports['pulsar-mdt']:Close()
		exports['pulsar-mdt']:EmergencyAlertsClose()
	else
		exports['pulsar-mdt']:Open()
	end
end)

RegisterNetEvent("MDT:Client:Open", function()
	exports['pulsar-mdt']:Open()
end)

RegisterNetEvent("MDT:Client:Close", function()
	exports['pulsar-mdt']:Close()
	exports['pulsar-mdt']:EmergencyAlertsClose()
end)

RegisterNUICallback("Close", function(data, cb)
	cb("OK")
	exports['pulsar-mdt']:Close()
	exports['pulsar-mdt']:EmergencyAlertsClose()
end)

AddEventHandler("Ped:Client:Died", function()
	exports['pulsar-mdt']:Close()
	exports['pulsar-mdt']:EmergencyAlertsClose()
end)

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function LoadModel(hash)
	while not HasModelLoaded(hash) do
		RequestModel(hash)
		Wait(10)
	end
end
