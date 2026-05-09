local _buffDefs = {}
local _buffVals  = {}

local _effects = {
	stoned = function(intensity)
		if intensity <= 0 then
			ClearTimecycleModifier()
			AnimpostfxStopAll()
			return
		end
		local strength = (intensity / 100) * 0.15
		if intensity >= 70 then
			SetTimecycleModifier("drug_flying_01")
			SetTimecycleModifierStrength(strength)
			AnimpostfxPlay("DrugsMichaelAliensFight", 5000, false)
		elseif intensity >= 40 then
			SetTimecycleModifier("drug_flying_base")
			SetTimecycleModifierStrength(strength * 0.8)
		else
			SetTimecycleModifier("drug_flying_base")
			SetTimecycleModifierStrength(strength * 0.5)
		end
	end,
}

local function applyEffect(buffId, intensity)
	local def = _buffDefs[buffId]
	if not def or not def.effect then return end
	local preset = _effects[def.effect]
	if preset then
		preset(intensity)
	elseif intensity > 0 then
		AnimpostfxPlay(def.effect, 0, true)
	else
		AnimpostfxStop(def.effect)
	end
end

exports("RegisterBuff", function(id, icon, color, duration, type, effect)
	_buffDefs[id] = {
		icon   = icon,
		color  = color,
		duration = duration,
		type   = type,
		effect = effect,
	}
	SendNUIMessage({
		type = "REGISTER_BUFF",
		data = {
			id   = id,
			data = {
				icon     = icon,
				color    = color,
				duration = duration,
				type     = type,
			},
		},
	})
end)

exports("ApplyBuff", function(buffId, val, override)
	local v = math.ceil(val or 0)
	_buffVals[buffId] = v
	SendNUIMessage({
		type = "BUFF_APPLIED_UNIQUE",
		data = {
			instance = {
				buff      = buffId,
				override  = override,
				val       = v,
				startTime = GetCloudTimeAsInt(),
			},
		},
	})
	applyEffect(buffId, v)
end)

exports("UpdateBuff", function(buffId, val, override)
	local resolved = val
	if type(val) == "string" then
		local sign, num = val:match("^([%+%-])(%d+%.?%d*)$")
		local cur = _buffVals[buffId] or 0
		if sign == "+" then
			resolved = cur + tonumber(num)
		elseif sign == "-" then
			resolved = math.max(0, cur - tonumber(num))
		end
	end
	if resolved then
		_buffVals[buffId] = math.ceil(resolved)
	end
	SendNUIMessage({
		type = "BUFF_UPDATED",
		data = {
			buff     = buffId,
			val      = resolved and math.ceil(resolved),
			override = override,
		},
	})
	if resolved then applyEffect(buffId, resolved) end
end)

exports("RemoveBuff", function(buffId)
	_buffVals[buffId] = nil
	SendNUIMessage({
		type = "REMOVE_BUFF_BY_TYPE",
		data = { type = buffId },
	})
	applyEffect(buffId, 0)
end)

exports("ClearBuffs", function()
	for buffId in pairs(_buffVals) do
		SendNUIMessage({
			type = "REMOVE_BUFF_BY_TYPE",
			data = { type = buffId },
		})
		applyEffect(buffId, 0)
	end
	_buffVals = {}
end)

RegisterNetEvent("Characters:Client:Spawned", function()
	exports['pulsar-hud']:RegisterBuff("prog_mod",    "mug-hot",          "#D6451A", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("stress_ticks","joint",             "#de3333", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("heal_ticks",  "suitcase-medical", "#52984a", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("armor_ticks", "dumbbell",         "#4056b3", -1, "timed")
	exports['pulsar-hud']:RegisterBuff("stoned",      "joint",            "#4a9e5c", -1, "value", "stoned")
end)

RegisterNetEvent("Characters:Client:Logout", function()
	exports['pulsar-hud']:RemoveBuff("prog_mod")
	exports['pulsar-hud']:RemoveBuff("stress_ticks")
	exports['pulsar-hud']:RemoveBuff("heal_ticks")
	exports['pulsar-hud']:RemoveBuff("armor_ticks")
	exports['pulsar-hud']:RemoveBuff("stoned")
end)
