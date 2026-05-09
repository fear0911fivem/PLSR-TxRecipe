local cam = nil

local foTo = 0
function FadeOutWithTimeout(time, timeOut)
	DoScreenFadeOut(time or 500)
	foTo = 0
	while IsScreenFadingOut() and foTo < (timeOut or 3000) do
		foTo += 1
		Wait(1)
	end
end

local fiTo = 0
function FadeInWithTimeout(time, timeOut)
	DoScreenFadeIn(time or 500)
	fiTo = 0
	while IsScreenFadingIn() and fiTo < (timeOut or 3000) do
		fiTo += 1
		Wait(1)
	end
end

exports('SpawnInitCamera', function()
	if not IsScreenFadedOut() then
		FadeOutWithTimeout(500)
	end

	local ped = PlayerPedId()
	SetEntityCoords(ped, -972.756, -2701.553, 41.45)
	FreezeEntityPosition(ped, true)
	SetEntityVisible(ped, false)
	SetPlayerVisibleLocally(ped, false)

	TransitionToBlurred(500)
	cam = CreateCamWithParams(
		"DEFAULT_SCRIPTED_CAMERA",
		-972.756,
		-2701.553,
		41.45,
		-12.335,
		0.000,
		118.395,
		100.00,
		false,
		0
	)
	SetCamActiveWithInterp(cam, true, 900, true, true)
	RenderScriptCams(true, false, 1, true, true)
	DisplayRadar(false)
end)

exports('SpawnInit', function()
	DoScreenFadeOut(500)
	exports['pulsar-characters']:DefaultSpawnCoords()

	ShutdownLoadingScreenNui()
	ShutdownLoadingScreen()

	DoScreenFadeIn(500)

	while not IsScreenFadingIn() do
		Wait(10)
	end

	FadeInWithTimeout(500)
	Wait(500)
	SetNuiFocus(true, true)
	SendNUIMessage({ type = "APP_SHOW" })
end)

exports('SpawnToWorld', function(data, cb)
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end

	local pedData = LocalPlayer.state.Character:GetData("Ped")

	if pedData then
		data.Ped = pedData
		exports['pulsar-ped']:PlacePedIntoWorld(data)
	else
		exports["pulsar-core"]:ServerCallback("Ped:CheckPed", {}, function(hasPed)
			data.Ped = hasPed.ped
			if LocalPlayer.state.Character then
				LocalPlayer.state.Character:SetData("Ped", hasPed.ped)
			end

			if not hasPed.existed then
				cb()
				exports['pulsar-ped']:CreatorStart(data)
			else
				cb()
				exports['pulsar-ped']:PlacePedIntoWorld(data)
			end
		end)
	end
end)

exports('PlacePedIntoWorld', function(data)
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end

	local player = PlayerPedId()
	SetTimecycleModifier("default")

	local model = `mp_f_freemode_01`
	if tonumber(data.Gender) == 0 then
		model = `mp_m_freemode_01`
	end

	if data.Ped.model ~= "" then
		model = GetHashKey(data.Ped.model)
	end

	RequestModel(model)

	while not HasModelLoaded(model) do
		Wait(500)
	end
	SetPlayerModel(PlayerId(), model)

	if model == `sandbox_k9_shepherd` then
		LocalPlayer.state.isK9Ped = true
	else
		LocalPlayer.state.isK9Ped = false
	end
	player = PlayerPedId()
	LocalPlayer.state.ped = player
	SetPedDefaultComponentVariation(player)
	SetEntityAsMissionEntity(player, true, true)
	SetModelAsNoLongerNeeded(model)

	DestroyAllCams(true)
	RenderScriptCams(false, true, 1, true, true)

	NetworkSetEntityInvisibleToNetwork(player, false)
	SetEntityVisible(player, true)
	SetPlayerInvincible(player, false)

	cam = nil

	SetCanAttackFriendly(player, true, true)
	NetworkSetFriendlyFireOption(true)

	SetEntityMaxHealth(PlayerPedId(), 200)
	SetEntityHealth(PlayerPedId(), data.HP or 200)
	DisplayHud(true)
	SetNuiFocus(false, false)

	local LocalPed = data.Ped
	if LocalPed then
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end

	if data.action ~= nil then
		FreezeEntityPosition(player, false)
		TriggerEvent(data.action, data.data)
	else
		SetEntityCoords(
			player,
			data.spawn.location.x + 0.0,
			data.spawn.location.y + 0.0,
			data.spawn.location.z + 0.0
		)

		Wait(200)
		SetEntityHeading(player, data.spawn.location.h)

		local time = GetGameTimer()
		while not HasCollisionLoadedAroundEntity(player) and (GetGameTimer() - time) < 10000 do
			Wait(100)
		end

		FreezeEntityPosition(player, false)

		DoScreenFadeIn(500)
	end

	SetTimeout(500, function()
		SetPedArmour(player, data.Armor)
	end)

	TriggerScreenblurFadeOut(500)
end)
