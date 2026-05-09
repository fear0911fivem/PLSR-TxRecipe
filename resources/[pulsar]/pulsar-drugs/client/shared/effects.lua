local _runSpeedTime = 0
RegisterNetEvent("Drugs:Effects:RunSpeed", function(quality)
	if _runSpeedTime > 0 then
		return
	end

	local addiction = LocalPlayer.state.Character:GetData("Addiction")?.Coke?.Factor or 0.0
	_runSpeedTime = 60 * (1.0 - (addiction / 100))

	local ped = PlayerPedId()
	local pId = PlayerId()
	local loops = 0

	local speedMod = 0.49 * (quality / 100)
	if speedMod > 0.49 then
		speedMod = 0.49
	end

	local total = 1.0 + speedMod

	LocalPlayer.state.drugsRunSpeed = true
	StartScreenEffect("DrugsMichaelAliensFight", 3.0, 0)
	SetRunSprintMultiplierForPlayer(pId, total)
	SetSwimMultiplierForPlayer(pId, total)

	StatSetInt(`MP0_STAMINA`, 100, true)
	exports['pulsar-hud']:ApplyBuff("speed", _runSpeedTime, false)
	while _runSpeedTime > 0 and not LocalPlayer.state.isDead do
		total = 1.0 + (speedMod * (1.0 - (loops / 100)))

		SetRunSprintMultiplierForPlayer(pId, total)
		SetSwimMultiplierForPlayer(pId, total)

		loops = loops + 1
		Wait(1000)
		RestorePlayerStamina(pId, 1.0)
		_runSpeedTime = _runSpeedTime - 1
		if IsPedRagdoll(ped) then
			SetPedToRagdoll(ped, math.random(5), math.random(5), 3, 0, 0, 0)
		end
	end
	exports['pulsar-hud']:RemoveBuff("speed")
	StopScreenEffect("DrugsMichaelAliensFight")
	_runSpeedTime = 0
	SetRunSprintMultiplierForPlayer(pId, 1.0)
	SetSwimMultiplierForPlayer(pId, 1.0)
	StatSetInt(`MP0_STAMINA`, 25, true)
	LocalPlayer.state.drugsRunSpeed = false
end)

local _armorTime = 0
RegisterNetEvent("Drugs:Effects:Armor", function(quality)
	-- TriggerEvent("addiction:drugTaken", "meth")
	if _armorTime > 0 then
		return
	end

	local addiction = LocalPlayer.state.Character:GetData("Addiction")?.Meth?.Factor or 0.0

	_armorTime = 0
	local drugEffectApplyArmorMulti = 0.0
	local drugEffectQualityMulti = 1.0
	local sprintEffectFactor = 1.0
	local drugEffectQuality = quality and quality or 20
	if drugEffectQuality > 25 and drugEffectQuality <= 50 then
		drugEffectQualityMulti = 2.0
		drugEffectApplyArmorMulti = 1.0
	elseif drugEffectQuality > 50 and drugEffectQuality <= 62.5 then
		drugEffectQualityMulti = 3.0
		drugEffectApplyArmorMulti = 1.0
	elseif drugEffectQuality > 62.5 and drugEffectQuality <= 75 then
		drugEffectQualityMulti = 6.0
		drugEffectApplyArmorMulti = 1.0
	elseif drugEffectQuality > 75 and drugEffectQuality <= 90 then
		drugEffectQualityMulti = 12.0
		drugEffectApplyArmorMulti = 1.0
	elseif drugEffectQuality > 90 and drugEffectQuality <= 99 then
		drugEffectQualityMulti = 18.0
		drugEffectApplyArmorMulti = 2.0
	elseif drugEffectQuality > 99 then
		drugEffectQualityMulti = 30.0
		drugEffectApplyArmorMulti = 3.0
	end

	_armorTime = (drugEffectQualityMulti * 6) * (1.0 - (addiction / 100))

	local loops = 0
	exports['pulsar-hud']:ApplyBuff("armor", _armorTime, false)
	while _armorTime > 0 and not LocalPlayer.state.isDead do
		loops = loops + 1
		Wait(1000)
		_armorTime = _armorTime - 1
		if IsPedRagdoll(PlayerPedId()) then
			SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
		end
		if drugEffectApplyArmorMulti > 0 then
			local armor = GetPedArmour(PlayerPedId())
			SetPedArmour(PlayerPedId(), math.floor(armor + drugEffectApplyArmorMulti))
		end
	end
	_armorTime = 0
	exports['pulsar-hud']:RemoveBuff("armor")
end)

local _healTime = 0
RegisterNetEvent("Drugs:Effects:Heal", function(quality)
	-- TriggerEvent("addiction:drugTaken", "meth")
	if _healTime > 0 then
		return
	end

	local addiction = LocalPlayer.state.Character:GetData("Addiction")?.Moonshine?.Factor or 0.0

	_healTime = 0
	local drugEffectApplyHealthMulti = 0.0
	local drugEffectQualityMulti = 1.0
	local drugEffectQuality = quality and quality or 20
	if drugEffectQuality > 25 and drugEffectQuality <= 50 then
		drugEffectQualityMulti = 2.0
		drugEffectApplyHealthMulti = 1.0
	elseif drugEffectQuality > 50 and drugEffectQuality <= 62.5 then
		drugEffectQualityMulti = 3.0
		drugEffectApplyHealthMulti = 1.0
	elseif drugEffectQuality > 62.5 and drugEffectQuality <= 75 then
		drugEffectQualityMulti = 6.0
		drugEffectApplyHealthMulti = 1.0
	elseif drugEffectQuality > 75 and drugEffectQuality <= 90 then
		drugEffectQualityMulti = 12.0
		drugEffectApplyHealthMulti = 1.0
	elseif drugEffectQuality > 90 and drugEffectQuality <= 99 then
		drugEffectQualityMulti = 18.0
		drugEffectApplyHealthMulti = 2.0
	elseif drugEffectQuality > 99 then
		drugEffectQualityMulti = 30.0
		drugEffectApplyHealthMulti = 3.0
	end

	exports['pulsar-status']:Add("PLAYER_DRUNK", math.ceil(10 * (1.0 + (drugEffectQuality / 100))))
	_healTime = math.ceil(30 * (1.0 + (drugEffectQuality / 100)) * (1.0 - (addiction / 100)))
	local loops = 0
	exports['pulsar-hud']:ApplyBuff("heal", _healTime, false)
	while _healTime > 0 and not LocalPlayer.state.isDead do
		local ped = PlayerPedId()
		loops = loops + 1
		Wait(1000)
		_healTime = _healTime - 1

		local maxHp = GetEntityMaxHealth(ped)
		local currHp = GetEntityHealth(ped)

		local adding = math.floor(5 * (1.0 + (drugEffectQuality / 100)))
		if currHp + adding <= maxHp then
			SetEntityHealth(ped, currHp + adding)
		elseif currHp < maxHp then
			SetEntityHealth(ped, maxHp)
		end
	end
	_healTime = 0
	exports['pulsar-hud']:RemoveBuff("heal")
end)

-- Recipe-based moonshine effects
RegisterNetEvent("Drugs:Effects:Moonshine", function(quality, recipeId)
	if _healTime > 0 then
		return
	end

	local addiction = LocalPlayer.state.Character:GetData("Addiction")?.Moonshine?.Factor or 0.0
	
	-- Get recipe effects from config
	local recipe = nil
	for k, v in ipairs(_moonshineRecipes) do
		if v.id == recipeId then
			recipe = v
			break
		end
	end
	
	-- Fallback to classic if recipe not found
	if not recipe or not recipe.effects then
		recipe = {
			effects = {
				drunkAmount = 10,
				healAmount = 5,
				healDuration = 30,
				stressRelief = 5,
			}
		}
	end
	
	local effects = recipe.effects
	
	-- Apply quality multiplier to effects (higher quality = better effects)
	local qualityMultiplier = 1.0 + (quality / 100)
	
	-- Calculate drunk amount (base from recipe, modified by quality)
	local drunkAmount = math.ceil(effects.drunkAmount * qualityMultiplier)
	exports['pulsar-status']:Add("PLAYER_DRUNK", drunkAmount)
	
	-- Apply stress relief
	if effects.stressRelief and effects.stressRelief > 0 then
		exports['pulsar-status']:Remove("PLAYER_STRESS", effects.stressRelief * qualityMultiplier, true)
	end
	
	-- Calculate heal duration (reduced by addiction)
	_healTime = math.ceil(effects.healDuration * qualityMultiplier * (1.0 - (addiction / 100)))
	local healAmount = math.floor(effects.healAmount * qualityMultiplier)
	
	exports['pulsar-hud']:ApplyBuff("heal", _healTime, false)
	
	-- Show notification with recipe name
	local recipeLabel = recipe.label or "Moonshine"
	exports['pulsar-hud']:Notification("success", string.format("Drank %s! Quality: %d/100", recipeLabel, quality))
	
	-- Healing loop
	while _healTime > 0 and not LocalPlayer.state.isDead do
		local ped = PlayerPedId()
		Wait(1000)
		_healTime = _healTime - 1

		local maxHp = GetEntityMaxHealth(ped)
		local currHp = GetEntityHealth(ped)

		if currHp + healAmount <= maxHp then
			SetEntityHealth(ped, currHp + healAmount)
		elseif currHp < maxHp then
			SetEntityHealth(ped, maxHp)
		end
	end
	_healTime = 0
	exports['pulsar-hud']:RemoveBuff("heal")
end)

RegisterNetEvent("Characters:Client:Spawned", function()
	exports['pulsar-hud']:RegisterBuff("speed", "bolt-lightning", "#8419C2", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("armor", "shield-halved", "#4056b3", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("heal", "trash-can", "#52984a", -1, "timed")
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_armorTime = 0
	_runSpeedTime = 0

	exports['pulsar-hud']:RemoveBuff("speed")
	exports['pulsar-hud']:RemoveBuff("armor")
end)

AddEventHandler("Damage:Client:Triggers:EntityDamaged", function(victim, attacker, pWeapon, isMelee)
	if victim ~= PlayerPedId() then return end

	if _armorTime > 0 and not Config.Weapons[pWeapon]?.isMinor then
		_armorTime = 0
		exports['pulsar-hud']:RemoveBuff("armor")
	end

	if _healTime > 0 and not Config.Weapons[pWeapon]?.isMinor then
		_healTime = 0
		exports['pulsar-hud']:RemoveBuff("heal")
	end
end)
