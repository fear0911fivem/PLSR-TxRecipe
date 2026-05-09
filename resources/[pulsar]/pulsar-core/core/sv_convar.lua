exports("GetEnvironment", function()
	return GetConvar("sv_environment", "DEV")
end)

exports("GetAccessRole", function()
	return GetConvar("sv_access_role", 0)
end)

exports("GetApiAddress", function()
	return GetConvar('api_address', 'CONVAR_DEFAULT')
end)

exports("GetApiId", function()
	return GetConvar('api_id', 'CONVAR_DEFAULT')
end)

exports("GetApiSecret", function()
	return GetConvar('api_secret', 'CONVAR_DEFAULT')
end)

exports("GetLogging", function()
	return tonumber(GetConvar("log_level", 0))
end)

exports("GetPlsfwVersion", function()
	return GetConvar("plsfw_version", "UNKNOWN")
end)

-- exports("GetDiscordBotToken", function()
-- 	return GetConvar('discord_bot_token', 'CONVAR_DEFAULT')
-- end)

CreateThread(function()
	ENVIRONMENT = GetConvar("sv_environment", "DEV")
	ACCESS_ROLE = GetConvar("sv_access_role", 0)

	API_ADDRESS = GetConvar('api_address', 'CONVAR_DEFAULT')
	API_ID = GetConvar('api_id', 'CONVAR_DEFAULT')
	API_SECRET = GetConvar('api_secret', 'CONVAR_DEFAULT')

	--BOT_TOKEN = GetConvar('discord_bot_token', 'CONVAR_DEFAULT')
	LOGGING = tonumber(GetConvar("log_level", 0))
	PLSFW_VERSION = GetConvar("plsfw_version", "UNKNOWN")
end)

AddEventHandler("Core:Shared:Watermark", function()
	GlobalState.IsProduction = (exports["pulsar-core"]:GetEnvironment():upper()) ~= "DEV"

	local convarChecks = {
		{ key = "sv_environment", value = exports["pulsar-core"]:GetEnvironment(),       stop = true },
		{ key = "sv_access_role", value = exports["pulsar-core"]:GetAccessRole(),        stop = false },
		{ key = "api_address",    value = exports["pulsar-core"]:GetApiAddress(),        stop = false },
		{ key = "api_id",         value = exports["pulsar-core"]:GetApiId(),             stop = false },
		{ key = "api_secret",     value = exports["pulsar-core"]:GetApiSecret(),         stop = false },
		--{ key = "discord_bot_token",     value = exports["pulsar-core"]:GetDiscordBotToken(),   stop = true },
		{ key = "log_level",      value = tostring(exports["pulsar-core"]:GetLogging()), stop = false },
		{ key = "PLSFW_VERSION",   value = exports["pulsar-core"]:GetPlsfwVersion(),       stop = false },
	}

	for k, v in pairs(convarChecks) do
		if v.value == "CONVAR_DEFAULT" then
			exports['pulsar-core']:LoggerError("Convar", "Missing Convar " .. v.key, {
				console = true,
				file = true,
			})

			if v.stop then
				exports["pulsar-core"]:Shutdown("Missing Convar " .. v.key)
				return
			end
		end
	end

	TriggerEvent("Core:Server:StartupReady")
end)
