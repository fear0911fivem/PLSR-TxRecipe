local _hungerTicks = 0
local _stressTicks = 0

AddEventHandler("Characters:Client:Spawn", function()
	CreateThread(function()
		local effectCount = 0
		while LocalPlayer.state.loggedIn do
			local player = PlayerPedId()
			if not LocalPlayer.state.isDead then
				local val = exports['pulsar-status']:GetSingle("PLAYER_THIRST").value or 100
				if val <= 25 then
					SetPlayerSprint(PlayerId(), false)
					if val == 0 and effectCount >= 500 then
						ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.4)
						local luck = math.random(100)
						if luck <= 20 then
							SetPedToRagdoll(player, 1500, 2000, 3, true, true, false)
						end
						exports['pulsar-damage']:ApplyStandardDamage(3, false)
						effectCount = 0
					elseif effectCount >= 1000 then
						ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.2)
						effectCount = 0
					else
						effectCount = effectCount + 1
					end
				else
					SetPlayerSprint(PlayerId(), true)
					if val - 25 > 0 then
						Wait(60000)
						effectCount = 0
					end
				end
				Wait(100)
			else
				Wait(1000)
			end
		end
	end)

	CreateThread(function()
		local effectCount = 0
		while LocalPlayer.state.loggedIn do
			local player = PlayerPedId()
			if not LocalPlayer.state.isDead then
				local val = exports['pulsar-status']:GetSingle("PLAYER_STRESS").value or 0
				local level = math.floor(val / 25)

				if val >= 40 then
					TriggerScreenblurFadeIn(200.0 * level)

					if level == 1 then
						Wait(600)
					elseif level == 2 then
						Wait(1200)
					elseif level == 3 then
						Wait(1800)
					else
						Wait(2500)
					end

					TriggerScreenblurFadeOut(200.0 * level)
					Wait(30000 - (1000 * (15 - (level * 2))))
				else
					Wait(10000)
				end
			else
				Wait(1000)
			end
		end
	end)
end)

RegisterNetEvent("Status:Client:updateStatus", function(need, action, amount)
	if action then
		exports['pulsar-status']:Add(need, tonumber(amount or 0), 2)
	else
		exports['pulsar-status']:Remove(need, tonumber(amount or 0))
	end
end)

-- Dear lua, die.
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local _strTickRunning = false

local _stressListener = nil
local _hpListener = nil

RegisterNetEvent("Status:Client:Ticks:Stress", function()
	if LocalPlayer.state.stressTicks ~= nil then
		exports['pulsar-hud']:ApplyBuff("stress_ticks", #(LocalPlayer.state.stressTicks or {}), false, {
			customMax = #(LocalPlayer.state.stressTicks or {}),
		})
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	CreateThread(function()
		if _strTickRunning then
			exports['pulsar-core']:LoggerTrace("Status", "Stress Thread Running, Skipping Creation")
			return
		end

		_strTickRunning = true
		while LocalPlayer.state.loggedIn do
			if LocalPlayer.state.stressTicks ~= nil then
				local cst = exports['pulsar-status']:GetSingle("PLAYER_STRESS").value
				local max = 0

				if cst <= max then
					LocalPlayer.state:set("stressTicks", nil, true)
				else
					local gen = LocalPlayer.state.stressTicks[1] or 0
					if cst - gen < max then
						gen = cst
					end

					if cst - gen >= max then
						exports['pulsar-core']:LoggerTrace(
							"Status",
							string.format("Stress Tick: %s (Original: %s)", gen, LocalPlayer.state.stressTicks[1])
						)
						exports['pulsar-status']:Remove("PLAYER_STRESS", tonumber(gen or 0), true)
					end

					local t = LocalPlayer.state.stressTicks
					table.remove(t, 1)
					if #t > 0 then
						LocalPlayer.state:set("stressTicks", t, true)
					else
						LocalPlayer.state:set("stressTicks", nil, true)
					end
				end
				Wait(10000)
			else
				Wait(1000)
			end
		end
		_strTickRunning = false
	end)
end)

function RegisterStatuses()
	exports['pulsar-status']:Register("PLAYER_THIRST", 100, "whiskey-glass", "#07bdf0", true, function(change)
		if LocalPlayer.state.ignorePLAYER_THIRST then
			if LocalPlayer.state.ignorePLAYER_THIRST - 1 > 0 then
				LocalPlayer.state:set("ignorePLAYER_THIRST", LocalPlayer.state.ignorePLAYER_THIRST - 1)
			else
				LocalPlayer.state:set("ignorePLAYER_THIRST", nil)
			end
			return
		end

		local player = PlayerPedId()
		if IsEntityDead(player) or LocalPlayer.state.isDead then
			return
		end
		if change == nil then
			change = -1
		end

		local val = exports['pulsar-status']:GetSingle("PLAYER_THIRST").value or 100
		if val + change > 100 then
			val = 100
		elseif val + change < 0 then
			val = 0
		else
			val = val + change
		end

		exports['pulsar-status']:SetSingle("PLAYER_THIRST", val)
		TriggerEvent("Status:Client:Update", "PLAYER_THIRST", val)
		thirstTick = 0
	end, {
		id = 3,
		hideHigh = true,
		order = 6,
	})

	exports['pulsar-status']:Register("PLAYER_HUNGER", 100, "drumstick-bite", "#ca5fe8", true, function(change)
		if LocalPlayer.state.ignorePLAYER_HUNGER then
			if LocalPlayer.state.ignorePLAYER_HUNGER - 1 > 0 then
				LocalPlayer.state:set("ignorePLAYER_HUNGER", LocalPlayer.state.ignorePLAYER_HUNGER - 1)
			else
				LocalPlayer.state:set("ignorePLAYER_HUNGER", nil)
			end
			return
		end

		local player = PlayerPedId()
		if IsEntityDead(player) or LocalPlayer.state.isDead then
			return
		end

		if change == nil then
			change = -1
		end

		local val = exports['pulsar-status']:GetSingle("PLAYER_HUNGER").value or 100
		if val + change > 100 then
			val = 100
		elseif val + change < 0 then
			val = 0
		else
			val = val + change
		end
		exports['pulsar-status']:SetSingle("PLAYER_HUNGER", val)
		TriggerEvent("Status:Client:Update", "PLAYER_HUNGER", val)

		if val <= 25 then
			if val > 10 then
				if (GetEntityHealth(player) - 100) > 11 then
					exports['pulsar-damage']:ApplyStandardDamage(10, false)
				end
			else
				if (GetEntityHealth(player) - 100) > 1 then
					exports['pulsar-damage']:ApplyStandardDamage(1, false)
				else
					if _hungerTicks <= 10 then
						SetFlash(0, 0, 100, 10000, 100)
						_hungerTicks = _hungerTicks + 1
					else
						-- Kill Player
					end
				end
			end
		end

		hungerTick = 0
	end, {
		id = 2,
		hideHigh = true,
		order = 5,
	})

	exports['pulsar-status']:Register("PLAYER_STRESS", 0, "face-dizzy", "#de3333", false, function(change, force)
		if _stressTicks > 1 or force then
			if LocalPlayer.state.ignorePLAYER_STRESS then
				if LocalPlayer.state.ignorePLAYER_STRESS - 1 > 0 then
					LocalPlayer.state:set("ignorePLAYER_STRESS", LocalPlayer.state.ignorePLAYER_STRESS - 1)
				else
					LocalPlayer.state:set("ignorePLAYER_STRESS", nil)
				end
				return
			end

			_stressTicks = 0

			local player = PlayerPedId()
			if IsEntityDead(player) or LocalPlayer.state.isDead then
				return
			end

			if change == nil then
				change = -1
			end

			local val = exports['pulsar-status']:GetSingle("PLAYER_STRESS").value or 0
			if val + change > 100 then
				val = 100
			elseif val + change < 0 then
				val = 0
			else
				val = val + change
			end
			exports['pulsar-status']:SetSingle("PLAYER_STRESS", val)
			TriggerEvent("Status:Client:Update", "PLAYER_STRESS", val)
		else
			_stressTicks = _stressTicks + 1
		end
	end, {
		id = 4,
		inverted = true,
		hideZero = true,
		noReset = true,
		order = 4,
	})

	exports['pulsar-status']:Register("PLAYER_DRUNK", 0, "champagne-glasses", "#9D4C0B", false, function(change, force)
		local player = PlayerPedId()
		if IsEntityDead(player) or LocalPlayer.state.isDead then
			return
		end

		local val = exports['pulsar-status']:GetSingle("PLAYER_DRUNK").value or 0

		if change == nil then
			if val and val >= 25 then
				change = -10
			else
				change = -6
			end
		end

		if val + change > 100 then
			val = 100
		elseif val + change < 0 then
			val = 0
		else
			val = val + change
		end

		if val >= 10 then
			LocalPlayer.state:set("isDrunk", val, true)
		end

		exports['pulsar-status']:SetSingle("PLAYER_DRUNK", val)
		TriggerEvent("Status:Client:Update", "PLAYER_DRUNK", val)
	end, {
		id = 5,
		inverted = true,
		hideZero = true,
		noReset = true,
		order = 7,
	})

	exports['pulsar-status']:Register("PLAYER_DEV", 0, "fas fa-terminal", "#000000", false, function(change)
		-- We don't need to do anything here
	end, {
		id = 7,
		hideZero = true,
		order = 8,
		noReset = true,
	})
end

-- RegisterCommand('testdrunk', function(src, args)
-- 	exports['pulsar-status']:SetSingle("PLAYER_DRUNK", tonumber(args[1]))
-- end)

function LoadAnimSet(animSet)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)
		while not HasAnimSetLoaded(animSet) do
			Wait(50)
		end
	end
end

function LoadAnimSets(animSets)
	for k, v in ipairs(animSets) do
		LoadAnimSet(v)
	end
end
