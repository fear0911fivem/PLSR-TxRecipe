local _threading = false

function StartPaletoThreads()
	if _threading then
		return
	end
	_threading = true

	CreateThread(function()
		while _threading do
			if _pbGlobalReset ~= nil then
				if os.time() > _pbGlobalReset then
					exports['pulsar-core']:LoggerInfo("Robbery", "Paleto Bank Heist Has Been Reset")
					ResetPaleto()
				end
			end
			Wait(30000)
		end
	end)
end

local _powerThreading = false
function RestorePowerThread()
	if IsPaletoPowerDisabled() then
		if _powerThreading then
			return
		end
		_powerThreading = true

		CreateThread(function()
			exports['pulsar-core']:LoggerInfo("Robbery", "Paleto Blackout Started")
			GlobalState["Sync:PaletoBlackout"] = true
			Wait(1000 * (60 * 30))
			GlobalState["Sync:PaletoBlackout"] = false
			_powerThreading = false
			exports['pulsar-core']:LoggerInfo("Robbery", "Paleto Blackout Ended")
		end)
	end
end
