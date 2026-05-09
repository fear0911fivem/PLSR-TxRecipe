_evald = {}

local _calledForHelp = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports['pulsar-hud']:InteractionRegisterMenu("call-911", "Call For Help", "siren-on", function(data)
			exports['pulsar-hud']:InteractionHide()
			TriggerServerEvent("EMS:Server:RequestHelp")
			_calledForHelp = GetCloudTimeAsInt() + (60 * 5)
		end, function()
			return LocalPlayer.state.onDuty ~= "ems"
				and LocalPlayer.state.onDuty ~= "police"
				and LocalPlayer.state.isDead
				and GetCloudTimeAsInt() > LocalPlayer.state.isDeadTime + (60 * 2)
				and (not _calledForHelp or GetCloudTimeAsInt() > _calledForHelp)
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("ems", false, "siren-on", function(data)
			exports['pulsar-hud']:InteractionShowMenu({
				{
					icon = "siren-on",
					label = "13-A",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerServerEvent("EMS:Server:Panic", true)
					end,
					shouldShow = function()
						return LocalPlayer.state.isDead
					end,
				},
				{
					icon = "siren",
					label = "13-B",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerServerEvent("EMS:Server:Panic", false)
					end,
					shouldShow = function()
						return LocalPlayer.state.isDead
					end,
				},
			})
		end, function()
			return LocalPlayer.state.onDuty == "ems" and LocalPlayer.state.onDuty and LocalPlayer.state.isDead
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("ems-utils", "EMS Utilities", "tablet-rugged", function(data)
			exports['pulsar-hud']:InteractionShowMenu({
				{
					icon = "tablet-screen-button",
					label = "MDT",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerEvent("MDT:Client:Toggle")
					end,
					shouldShow = function()
						return LocalPlayer.state.onDuty == "ems"
					end,
				},
				{
					icon = "video",
					label = "Toggle Body Cam",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerEvent("MDT:Client:ToggleBodyCam")
					end,
					shouldShow = function()
						return LocalPlayer.state.onDuty == "ems"
					end,
				},
			})
		end, function()
			return LocalPlayer.state.onDuty == "ems"
		end)

		exports["pulsar-core"]:RegisterClientCallback("EMS:ApplyBandage", function(data, cb)
			SetEntityHealth(LocalPlayer.state.ped, GetEntityHealth(LocalPlayer.state.ped) + 10)
			cb(true)
		end)

		exports["pulsar-core"]:RegisterClientCallback("EMS:Heal", function(data, cb)
			SetEntityHealth(LocalPlayer.state.ped, GetEntityHealth(LocalPlayer.state.ped) + data)
			cb(true)
		end)
	end
end)

exports('HaveEvaluated', function(id)
	return _evald[id] ~= nil and _evald[id] > GetGameTimer()
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	for k, v in ipairs(Config.HospitalBlips) do
		exports["pulsar-blips"]:Add("hospital_" .. k, v.label, v.coords, 61, 42, 0.8)
	end
end)
