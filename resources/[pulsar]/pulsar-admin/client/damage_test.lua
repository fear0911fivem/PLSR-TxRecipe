local registeredPeds, distances = {}, { 15, 25, 50, 100, 150, 200, 250, 300, 350, 400 }

local startPos = nil
local _loggedIn = false
local _running = false

local function startWeaponTest(bone)
	local playerPed = PlayerPedId()

	startPos = GetEntityCoords(playerPed)

	SetEntityCoords(playerPed, -412.83, -904.36, 37.32, false, false, false, true)
	SetEntityHeading(playerPed, 180.24)
	SetPedInfiniteAmmoClip(playerPed, true)

	Wait(500)

	local coords = GetEntityCoords(playerPed)

	for index, distance in pairs(distances) do
		local targetPed = CreatePed(0, `mp_m_freemode_01`, coords.x, coords.y - distance, coords.z, 0, false, false)

		while not DoesEntityExist(targetPed) do
			Wait(1)
		end

		registeredPeds[index] = targetPed

		Wait(500)

		FreezeEntityPosition(targetPed, true)
		SetBlockingOfNonTemporaryEvents(targetPed, true)
		SetPedArmour(targetPed, 0)

		local bonePosition = GetPedBoneCoords(targetPed, bone, 0, 0, 0)

		Wait(500)

		SetPedShootsAtCoord(playerPed, bonePosition.x, bonePosition.y, bonePosition.z, true)

		Wait(500)

		local hitCount, weaponDamage = 1, 100 - GetPedArmour(targetPed)

		while true do
			Wait(500)

			if not HasEntityBeenDamagedByAnyPed(targetPed) and hitCount > 5 then
				exports["pulsar-hud"]:Notification("info",
					("Weapon didn't reach the target, distance: %s"):format(distance))
				print(("Weapon didn't reach the target, distance: %s"):format(distance))
				return
			end

			if IsEntityDead(targetPed) then
				exports["pulsar-hud"]:Notification("info",
					("hitCount: %s | weaponDamage: %s | distance: %s"):format(hitCount, weaponDamage, distance)
				)
				print(("hitCount: %s | weaponDamage: %s | distance: %s"):format(hitCount, weaponDamage, distance))
				break
			end

			SetPedShootsAtCoord(playerPed, bonePosition.x, bonePosition.y, bonePosition.z, true)

			hitCount = hitCount + 1
		end
	end
end

local function cleanPeds()
	for index, targetPed in pairs(registeredPeds) do
		DeleteEntity(targetPed)
	end

	registeredPeds = {}
end

RegisterNetEvent("Admin:Client:DamageTest", function(mode)
	if LocalPlayer.state.isAdmin then
		local isArmed, hash = GetCurrentPedWeapon(LocalPlayer.state.ped)
		if not isArmed then
			exports["pulsar-hud"]:Notification("error", "You Don't Have A Weapon Equipped, Idiot")
			return
		end

		_running = true

		LocalPlayer.state.wepTest = true

		if #registeredPeds > 0 then
			return cleanPeds()
		end

		CreateThread(function()
			while _loggedIn and _running do
				Wait(0)

				SetVehicleDensityMultiplierThisFrame(0.0)
				SetPedDensityMultiplierThisFrame(0.0)
				SetRandomVehicleDensityMultiplierThisFrame(0.0)
				SetParkedVehicleDensityMultiplierThisFrame(0.0)
				SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

				SetGarbageTrucks(false)
				SetRandomBoats(false)
			end

			SetVehicleDensityMultiplierThisFrame(0.3)
			SetPedDensityMultiplierThisFrame(0.8)
			SetRandomVehicleDensityMultiplierThisFrame(0.4)
			SetParkedVehicleDensityMultiplierThisFrame(0.5)
			SetScenarioPedDensityMultiplierThisFrame(0.8, 0.8)

			SetGarbageTrucks(true)
			SetRandomBoats(true)
		end)

		startWeaponTest(mode and `SKEL_Head` or 0)

		_running = false
		LocalPlayer.state.wepTest = false

		SetEntityCoords(LocalPlayer.state.ped, startPos, false, false, false, true)
		startPos = nil
	end
end)

RegisterNetEvent("Characters:Client:Spawned", function()
	_loggedIn = true
	LocalPlayer.state.wepTest = false
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_loggedIn = false
	_running = false
	LocalPlayer.state.wepTest = false
	cleanPeds()
end)
