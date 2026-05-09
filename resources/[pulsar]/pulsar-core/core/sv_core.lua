exports("Shutdown", function(reason)
	exports['pulsar-core']:LoggerCritical("Core", "Shutting Down Core, Reason: " .. reason, {
		console = true,
		file = true,
	})
	Wait(1000) -- Need wait period so logging can finish
	StopResource(GetCurrentResourceName())
end)

exports("DropAll", function()
	for k, v in pairs(exports["pulsar-core"]:GetAllPlayers()) do
		if v ~= nil then
			DropPlayer(
				v:GetData("Source"),
				"⛔ Server Restarting ⛔ Due to a pending restart, you've been dropped from the server. Please ❗❗❗RESTART FIVEM❗❗❗ and reconnect in a few minutes."
			)
		end
	end
end)

AddEventHandler("Core:Server:ForceAllSave", function()
	exports['pulsar-queue']:CloseAndDrop()
	exports["pulsar-core"]:DropAll()
	TriggerEvent("Core:Server:ForceSave")
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
	if eventData.secondsRemaining <= 60 then
		exports['pulsar-queue']:CloseAndDrop()
		exports["pulsar-core"]:DropAll()
		TriggerEvent("Core:Server:ForceSave")
	elseif not GlobalState["RestartLockdown"] and eventData.secondsRemaining <= (60 * 30) then
		GlobalState["RestartLockdown"] = true
	end

	-- exports["pulsar-chat"]:SendSystemBroadcast( -- TX Admin Sends them
	-- 	string.format("Server Restart In %s Minutes", math.floor(eventData.secondsRemaining / 60))
	-- )
end)

AddEventHandler("Core:Server:StartupReady", function()
	SetupAPIHandler()
end)

-- CreateThread(function()
-- 	while true do
-- 		GlobalState["OS:Time"] = os.time()
-- 		Wait(1000)
-- 	end
-- end)

RegisterNetEvent("Core:Server:ResourceStopped", function(resource)
	local src = source
	if resource == "pulsar-pwnzor" then
		exports['pulsar-core']:PunishmentBanSource(src, -1, "Pwnzor Resource Stopped", "Pwnzor")
	end
end)

RegisterCommand("rcondisablelockdown", function()
	GlobalState["RestartLockdown"] = false
end, true)
