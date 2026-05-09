local _mb        = RobberyConfig.mazebank
local _threading = false

function StartMazeBankThreads()
	if _threading then return end
	_threading = true


	CreateThread(function()
		while _threading do
			if _mbGlobalReset ~= nil then
				if os.time() > _mbGlobalReset then
					exports['pulsar-core']:LoggerInfo("Robbery", "Maze Bank Heist Has Been Reset")
					ResetMazeBank()
				end
			end
			Wait(30000)
		end
	end)

	CreateThread(function()
		while _threading do
		local powerDisabled = IsMBPowerDisabled()
		if not powerDisabled and not exports['ox_doorlock']:IsLocked("pulsar_mazebank_offices") then
			exports['ox_doorlock']:SetLock("pulsar_mazebank_offices", true)
			for k, v in ipairs(_mb.officeDoors) do
				exports['ox_doorlock']:SetLock(v.door, true)
			end
		elseif powerDisabled and exports['ox_doorlock']:IsLocked("pulsar_mazebank_offices") then
			exports['ox_doorlock']:SetLock("pulsar_mazebank_offices", false)
			end
			Wait((1000 * 60) * 1)
		end
	end)

	CreateThread(function()
		while _threading do
			for k, v in pairs(_mb.hacks) do
				if
					GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)] ~= nil
					and GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].state == 2
					and GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].expires < os.time()
				then
					exports['pulsar-core']:LoggerInfo("Robbery", string.format("Maze Bank Door %s Opening", v.doorId))
					GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)] = {
						state = 3,
					}
					TriggerClientEvent("Robbery:Client:MazeBank:OpenVaultDoor", -1, v)
				end
			end

			Wait(30000)
		end
	end)
end
