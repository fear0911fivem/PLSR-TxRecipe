local _timeout = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-kbs"]:Add("escort", "k", "keyboard", "Escort", function()
			if _timeout then
				--exports["pulsar-hud"]:Notification("error", "Stop spamming you pepega.")
				return
			end
			_timeout = true
			DoEscort()
			SetTimeout(1000, function()
				_timeout = false
			end)
		end)

		exports["pulsar-core"]:RegisterClientCallback("Escort:StopEscort", function(data, cb)
			DetachEntity(LocalPlayer.state.ped, true, true)
			cb(true)
		end)
	end
end)

exports("DoEscort", function(target, tPlayer)
	if target ~= nil then
		if LocalPlayer.state.AllowEscorting == false then
			exports["pulsar-hud"]:Notification("error", "Unable to escort in this location.")
			return
		end
		exports["pulsar-core"]:ServerCallback("Escort:DoEscort", {
			target = target,
			inVeh = IsPedInAnyVehicle(GetPlayerPed(tPlayer)),
			isSwimming = IsPedSwimming(LocalPlayer.state.ped),
		}, function(state)
			if state then
				StartEscortThread(tPlayer)
			end
		end)
	end
end)

exports("StopEscort", function()
	exports["pulsar-core"]:ServerCallback("Escort:StopEscort", function() end)
end)

AddEventHandler("Interiors:Exit", function()
	if LocalPlayer.state.isEscorting ~= nil then
		exports['pulsar-escort']:EscortStopEscort()
	end
end)

--[[ TODO
Add Dragging When Dead
Place In vehicle while Dead Slump Animation
Police Drag Maybe Cuff Also
Get In Trunk or Place in trunk???
]]
