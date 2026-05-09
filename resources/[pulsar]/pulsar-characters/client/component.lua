RegisterNetEvent("Characters:Client:SetData", function(key, data, cb)
	if key ~= -1 then
		LocalPlayer.state.Character:SetData(key, data)
	else
		LocalPlayer.state.Character =
			exports["pulsar-core"]:CreateStore(1, "Character", data)
	end

	exports["pulsar-core"]:SetPlayerData("Character", LocalPlayer.state.Character)
	TriggerEvent("Characters:Client:Updated", key)

	if cb then
		cb()
	end
end)

exports("Logout", function()
	DoScreenFadeOut(500)
	while IsScreenFadingOut() do
		Wait(1)
	end
	exports["pulsar-core"]:ServerCallback("Characters:Logout", {}, function()
		LocalPlayer.state.Char = nil
		LocalPlayer.state.Character = nil
		LocalPlayer.state.loggedIn = false
		LocalPlayer.state:set('SID', nil, true)
		exports['pulsar-hud']:ActionHide()
		exports["pulsar-characters"]:SpawnInitCamera()
		SendNUIMessage({
			type = "APP_RESET",
		})
		Wait(500)
		exports['pulsar-characters']:SpawnInit()
	end)
end)

RegisterNetEvent("Characters:Client:Logout:Event", function()
	exports['pulsar-characters']:Logout()
end)
