exports("GetDiscordApp", function()
	return GetConvar("discord_app", "")
end)

exports("GetMaxClients", function()
	return tonumber(GetConvar("sv_maxclients", "32"))
end)

exports("GetLogging", function()
	return tonumber(GetConvar("log_level", 0))
end)

exports("GetPlsfwVersion", function()
	return GetConvar("plsfw_version", "UNKNOWN")
end)
