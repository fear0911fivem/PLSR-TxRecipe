_mdtOpen = false
_openCd = false -- Prevents spamm open/close
_settings = {}
_perms = {}
_loggedIn = false
_mdtLoggedIn = false

local _bodycam = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-kbs"]:Add("gov_mdt", "", "keyboard", "Gov - Open MDT", function()
			ToggleMDT()
		end)

		RegisterBadgeCallbacks()
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	_loggedIn = true
	_mdtLoggedIn = false
end)

local usefulData = {
	Callsign = true,
	Qualifications = true,
	MDTSystemAdmin = true,
}

AddEventHandler("Characters:Client:Updated", function(key)
	if key == -1 or usefulData[key] then
		if not LocalPlayer.state.Character then
			return
		end

		local char = LocalPlayer.state.Character:GetData()
		SendNUIMessage({
			type = "SET_USER",
			data = {
				user = char,
			},
		})
	end
end)

RegisterNetEvent("MDT:Client:Login", function(points, job, jobPermissions, attorney, data)
	_mdtLoggedIn = true

	if data then
		for k, v in pairs(data) do
			exports['pulsar-mdt']:DataSet(k, v)
		end
	end

	SendNUIMessage({
		type = "JOB_LOGIN",
		data = {
			points = points,
			job = job,
			jobPermissions = jobPermissions,
			attorney = attorney,
		},
	})
end)

RegisterNetEvent("MDT:Client:Logout", function()
	_mdtLoggedIn = false
	SendNUIMessage({
		type = "JOB_LOGOUT",
		data = nil,
	})
end)

RegisterNetEvent("MDT:Client:UpdateJobData", function(job, jobPermissions)
	SendNUIMessage({
		type = "JOB_UPDATE",
		data = {
			job = job,
			jobPermissions = jobPermissions,
		},
	})
end)

RegisterNetEvent("Characters:Client:Logout", function()
	exports['pulsar-mdt']:Close()
	exports['pulsar-mdt']:BadgesClose()
	exports['pulsar-mdt']:EmergencyAlertsClose()

	SendNUIMessage({
		type = "LOGOUT",
		data = nil,
	})
	SendNUIMessage({
		type = "SET_BODYCAM",
		data = {
			state = false,
		},
	})

	_bodycam = false
	_mdtLoggedIn = false
	_loggedIn = false
end)

RegisterNetEvent("UI:Client:Reset", function(manual)
	exports['pulsar-mdt']:Close()
	exports['pulsar-mdt']:BadgesClose()
	exports['pulsar-mdt']:EmergencyAlertsClose()
	SendNUIMessage({
		type = "SET_BODYCAM",
		data = {
			state = _bodycam,
		},
	})

	if _bodycam and manual then
		exports["pulsar-sounds"]:PlayDistance(15, "bodycam.ogg", 0.1)
	end
end)

AddEventHandler("MDT:Client:ToggleBodyCam", function()
	SendNUIMessage({
		type = "TOGGLE_BODYCAM",
		data = nil,
	})

	_bodycam = not _bodycam
	if _bodycam then
		exports["pulsar-sounds"]:PlayDistance(15, "bodycam.ogg", 0.05)
	end
end)

function ToggleMDT()
	if not _openCd and _mdtLoggedIn then
		if not _mdtOpen then
			_openCd = true
			exports['pulsar-mdt']:Open()

			CreateThread(function()
				Wait(2000)
				_openCd = false
			end)
		else
			exports['pulsar-mdt']:Close()
		end
	end
end

AddEventHandler("Government:Client:AccessPublicRecords", function()
	Wait(250)
	TriggerServerEvent("MDT:Server:OpenPublicRecords")
end)
