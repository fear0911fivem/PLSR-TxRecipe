local _weatherState = "EXTRASUNNY"
local _timeHour = 12
local _timeMinute = 0
local _blackoutState = false
local isTransionHappening = false
local _isStopped = true
local _isStoppedForceTime = 20

local _inCayo = false
local _inCayoStorm = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		if GlobalState["Sync:Winter"] then
			SetForceVehicleTrails(true)
			SetForcePedFootstepsTracks(true)
			ForceSnowPass(true)

			RequestScriptAudioBank("ICE_FOOTSTEPS", false)
			RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
		else
			SetForceVehicleTrails(false)
			SetForcePedFootstepsTracks(false)
			ForceSnowPass(false)

			ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
			ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
		end
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	exports["pulsar-sync"]:Start()
	-- CreateThread(function()
	-- 	SwitchTrainTrack(0, true)
	-- 	SwitchTrainTrack(3, true)
	-- 	SetTrainTrackSpawnFrequency(0, 60 * 240 * 1000) -- 240 minutes in milliseconds
	-- 	SetRandomTrains(1)
	-- 	-- turn off/On doors opening
	-- 	SetTrainsForceDoorsOpen(false)
	-- end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	exports["pulsar-sync"]:Stop()
end)

exports("Start", function()
	exports['pulsar-core']:LoggerTrace("Sync", "Starting Time and Weather Sync")
	_isStopped = false

	_weatherState = GlobalState["Sync:Weather"]
	_blackoutState = GlobalState["Sync:Blackout"]
	local timeState = GlobalState["Sync:Time"]
	_timeHour = timeState.hour
	_timeMinute = timeState.minute

	SetRainFxIntensity(-1.0)

	if
		_weatherState == "XMAS"
		or _weatherState == "BLIZZARD"
		or _weatherState == "SNOW"
		or GlobalState["Sync:Winter"]
	then
		SetForceVehicleTrails(true)
		SetForcePedFootstepsTracks(true)
		ForceSnowPass(true)

		RequestScriptAudioBank("ICE_FOOTSTEPS", false)
		RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
	else
		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
		ForceSnowPass(false)

		ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
		ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
	end
end)

exports("Stop", function(hour)
	exports['pulsar-core']:LoggerTrace("Sync", "Stopping Time and Weather Sync")
	_isStopped = true

	if not hour then
		_isStoppedForceTime = 20
	else
		_isStoppedForceTime = hour
	end
end)

exports("IsSyncing", function()
	return not _isStopped
end)

exports("GetTime", function()
	return {
		hour = _timeHour,
		minute = _timeMinute,
	}
end)

exports("GetWeather", function()
	return _weatherState
end)

CreateThread(function()
	StartSyncThreads()
end)

function StartSyncThreads()
	CreateThread(function()
		while GlobalState["Sync:Time"] == nil do
			Wait(1)
		end

		local hour = 0
		local minute = 0
		while true do
			if not _isStopped then
				local timeState = GlobalState["Sync:Time"]
				_timeHour = timeState.hour
				_timeMinute = timeState.minute
			else
				_timeHour = _isStoppedForceTime
				_timeMinute = 0
			end

			Wait(2500)
		end
	end)

	CreateThread(function()
		while true do
			NetworkOverrideClockTime(_timeHour, _timeMinute, 0)
			if _blackoutState then
				SetArtificialLightsStateAffectsVehicles(false)
			end
			Wait(50)
		end
	end)

	CreateThread(function()
		while true do
			if not _isStopped then
				if _inCayo or _inCayoStorm then
					local lazyNick = "THUNDER"
					if _inCayo then
						lazyNick = "EXTRASUNNY"
					end
					SetArtificialLightsState(false)

					ClearOverrideWeather()
					ClearWeatherTypePersist()
					SetWeatherTypeOvertimePersist(lazyNick, 1.0)
					Wait(1000)

					SetWeatherTypePersist(lazyNick)
					SetWeatherTypeNow(lazyNick)
					SetWeatherTypeNowPersist(lazyNick)
				else
					_blackoutState = GlobalState["Sync:Blackout"]
						or (LocalPlayer.state.inPaletoPower and GlobalState["Sync:PaletoBlackout"])
					SetArtificialLightsState(_blackoutState) -- Blackout
					SetArtificialLightsStateAffectsVehicles(false)

					if _weatherState ~= GlobalState["Sync:Weather"] then
						local _prevWeather = _weatherState
						if not isTransionHappening then
							isTransionHappening = true
							_weatherState = GlobalState["Sync:Weather"]
							exports['pulsar-core']:LoggerTrace("Sync", "Transitioning to Weather: " .. _weatherState)
							ClearOverrideWeather()
							ClearWeatherTypePersist()
							SetWeatherTypeOvertimePersist(_weatherState, 15.0)
							Wait(15000)
							exports['pulsar-core']:LoggerTrace("Sync",
								"Finished Transitioning to Weather: " .. _weatherState)
							isTransionHappening = false
						end

						if
							_weatherState == "XMAS"
							or _weatherState == "BLIZZARD"
							or _weatherState == "SNOW"
							or GlobalState["Sync:Winter"]
						then
							SetForceVehicleTrails(true)
							SetForcePedFootstepsTracks(true)
							ForceSnowPass(true)

							RequestScriptAudioBank("ICE_FOOTSTEPS", false)
							RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
						else
							SetForceVehicleTrails(false)
							SetForcePedFootstepsTracks(false)
							ForceSnowPass(false)

							ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
							ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
						end
					end

					SetWeatherTypePersist(_weatherState)
					SetWeatherTypeNow(_weatherState)
					SetWeatherTypeNowPersist(_weatherState)
				end

				Wait(750)
			else
				SetRainFxIntensity(0.0)
				SetWeatherTypeNowPersist("EXTRASUNNY")
				Wait(2000)
			end
		end
	end)
end

AddEventHandler("Polyzone:Enter", function(id, point, insideZone, data)
	if id == "cayo_perico" and not _inCayo then
		_inCayo = true
		LocalPlayer.state.inCayo = true

		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
		ForceSnowPass(false)

		ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
		ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
	end

	if id == "cayo_perico_weather" and not _inCayoStorm then
		_inCayoStorm = true

		SetRainFxIntensity(0.0)

		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
		ForceSnowPass(false)

		ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
		ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
	end
end)

AddEventHandler("Polyzone:Exit", function(id, point, insideZone, data)
	if id == "cayo_perico" and _inCayo then
		_inCayo = false
		LocalPlayer.state.inCayo = false
	end

	if id == "cayo_perico_weather" and _inCayoStorm then
		_inCayoStorm = false

		SetRainFxIntensity(-1.0)
	end

	if
		_weatherState == "XMAS"
		or _weatherState == "BLIZZARD"
		or _weatherState == "SNOW"
		or GlobalState["Sync:Winter"]
	then
		SetForceVehicleTrails(true)
		SetForcePedFootstepsTracks(true)
		ForceSnowPass(true)

		RequestScriptAudioBank("ICE_FOOTSTEPS", false)
		RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
	end
end)
