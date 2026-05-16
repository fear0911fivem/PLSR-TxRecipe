local _blacklistedClientEvents = {
	"esx:getSharedObject",
	"ambulancier:selfRespawn",
	"bank:transfer",
	"esx_ambulancejob:revive",
	"esx-qalle-jail:openJailMenu",
	"esx_jailer:wysylandoo",
	"esx_society:openBossMenu",
	"esx:spawnVehicle",
	"esx_status:set",
	"HCheat:TempDisableDetection",
	"UnJP",
}

local afkCodes = {}

local _blacklistedCommands = {
	"brutan",
	"chocolate",
	"haha",
	"killmenu",
	"KP",
	"lol",
	"lynx",
	"opk",
	--"panic",
	"panickey",
	"panik",
	-- "pk",
	"FunCtionOk",
	"porcodiooo",
	"demmerda",
	"puzzi",
	"jolmany",
}

local _retrieved = {}

function RegisterCallbacks()
	exports["pulsar-chat"]:RegisterStaffCommand("toggleafk", function(source, args, rawCommand)
		local disabled = GlobalState["DisableAFK"] or false
		GlobalState["DisableAFK"] = not disabled

		exports["pulsar-chat"]:SendSystemSingle(
			source,
			string.format("AFK Kicking %s", GlobalState["DisableAFK"] and "Disabled" or "Enabled")
		)
	end, {
		help = "Enabled/Disable AFK Kicks",
	}, 0)

	-- exports["pulsar-chat"]:RegisterAdminCommand("pwnzorban", function(source, args, rawCommand)
	-- 	local player = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
	-- 	if player ~= nil then
	-- 		exports['pulsar-core']:PunishmentBanSource(player:GetData("Source"), -1, args[2], "Pwnzor")
	-- 	end
	-- end, {
	-- 	help = "Fake Pwnzor Ban",
	-- 	params = {
	-- 		{
	-- 			name = "Target",
	-- 			help = "State ID of Who You Want To Ban",
	-- 		},
	-- 		{
	-- 			name = "Reason",
	-- 			help = "Reason For The Ban",
	-- 		},
	-- 	},
	-- }, 2)

	-- exports["pulsar-chat"]:RegisterAdminCommand("pwnzorsource", function(source, args, rawCommand)
	-- 	local player = exports['pulsar-core']:FetchSource(tonumber(args[1]))
	-- 	if player ~= nil then
	-- 		exports['pulsar-core']:PunishmentBanSource(tonumber(args[1]), -1, args[2], "Pwnzor")
	-- 	end
	-- end, {
	-- 	help = "Ban Player From Server",
	-- 	params = {
	-- 		{
	-- 			name = "Target",
	-- 			help = "Source of Who You Want To Ban",
	-- 		},
	-- 		{
	-- 			name = "Reason",
	-- 			help = "Reason For The Ban",
	-- 		},
	-- 	},
	-- }, 2)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:GetEvents", function(source, data, cb)
		exports['pulsar-pwnzor']:Set(source, "GetEvents")
		cb(_blacklistedClientEvents)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:GetCommands", function(source, data, cb)
		exports['pulsar-pwnzor']:Set(source, "GetCommands")
		cb(_blacklistedCommands)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:AFK", function(source, data, cb)
		if Config.Components.AFK.Enabled then
			exports['pulsar-core']:PunishmentKick(source, "You Were Kicked For Being AFK", "Pwnzor", true)
		end
	end)

	local _fovScreenshotLast = {}

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:FOV", function(source, data, cb)
		if Config.Components.FOV.Enabled then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			local fov = data.fov
			if char then
				if not _fovScreenshotLast[source] or (GetGameTimer() - _fovScreenshotLast[source]) > 30000 then
					_fovScreenshotLast[source] = GetGameTimer()
					exports['pulsar-pwnzor']:Screenshot(char:GetData("SID"),
						string.format("Detected Modified FOV: %s", fov))
				end

				exports['pulsar-core']:LoggerWarn(
					"Pwnzor",
					string.format(
						"%s %s (%s) Detected Modified FOV: %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						fov
					),
					{
						console = true,
						file = false,
						database = true,
						discord = {
							embed = true,
							type = "error",
							webhook = GetConvar("discord_pwnzor_webhook", ""),
						},
					}
				)

				if Config.Components.FOV.Options.KickPlayer then
					Wait(5000) -- need time to process screenshot

					exports['pulsar-core']:PunishmentKick(src, string.format("Detected Modified FOV: %s", fov), "Pwnzor",
						true)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:AspectRatio", function(source, data, cb)
		if Config.Components.AspectRatio.Enabled then
			local src = source
			local char = exports['pulsar-characters']:FetchCharacterSource(src)
			if char then
				exports['pulsar-pwnzor']:Screenshot(char:GetData("SID"), "Detected Unusual Resolution")

				exports['pulsar-core']:LoggerWarn(
					"Pwnzor",
					string.format(
						"%s %s (%s) Detected Unusual Resolution",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID")
					),
					{
						console = true,
						file = false,
						database = true,
						discord = {
							embed = true,
							type = "error",
							webhook = GetConvar("discord_pwnzor_webhook", ""),
						},
					}
				)

				if Config.Components.AspectRatio.Options.KickPlayer then
					Wait(5000) -- need time to process screenshot

					exports['pulsar-core']:PunishmentKick(src, "Detected Unusual Resolution", "Pwnzor", true)
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:Trigger", function(source, data, cb)
		cb("💙 From Pwnzor 🙂")
		if not exports['pulsar-core']:FetchSource(source).Permissions:IsAdmin() then
			exports['pulsar-core']:LoggerInfo(
				"Pwnzor",
				string.format("Pwnzor Trigger For %s: %s (check) %s (match)", source, data.check, data.match),
				{
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
						type = "error",
						webhook = GetConvar("discord_pwnzor_webhook", ""),
					},
				}
			)
			exports['pulsar-core']:PunishmentBanSource(
				source,
				-1,
				string.format("Pwnzor Trigger: %s (check) %s (match)", data.check, data.match),
				"Pwnzor"
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:GetCode", function(source, data, cb)
		afkCodes[source] = exports['pulsar-core']:GeneratorHackerIngVerb()
		cb(afkCodes[source])
	end)

	exports["pulsar-core"]:RegisterServerCallback("Pwnzor:EnterCode", function(source, data, cb)
		if afkCodes[source] ~= nil then
			if afkCodes[source] == data then
				afkCodes[source] = nil
				cb(true)
			else
				exports['pulsar-hud']:Notification(source, "error", "Incorrect AFK Code")
				cb(false)
			end
		else
			cb(false)
		end
	end)
end
