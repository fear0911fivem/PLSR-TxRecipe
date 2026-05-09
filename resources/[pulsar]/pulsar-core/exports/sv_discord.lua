exports('DiscordRequest', function(method, endpoint, jsondata)
	local data = nil
	PerformHttpRequest(
		"https://discordapp.com/api/" .. endpoint,
		function(errorCode, resultData, resultHeaders)
			data = {
				data = resultData,
				code = errorCode,
				headers = resultHeaders,
			}

			if data.code ~= nil and data.code ~= 200 then
				exports['pulsar-core']:LoggerError("Discord", "Error: " .. data.code, { console = true })
			end

			if data.data ~= nil then
				data.data = json.decode(data.data)
			end
		end,
		method,
		#jsondata > 0 and json.encode(jsondata) or "",
		{
			["Content-Type"] = "application/json",
			["Authorization"] = "Bot " .. exports["pulsar-core"]:GetDiscordBotToken(),
		}
	)

	while data == nil do
		Wait(0)
	end

	return data
end)

exports('DiscordGetMember', function(discord)
	local endpoint = ("guilds/%s/members/%s"):format(exports['pulsar-core']:ConfigGetServer().ID, discord)
	return exports['pulsar-core']:DiscordRequest('GET', endpoint, {})
end)

CreateThread(function()
	while true do
		GlobalState["PlayerCount"] = exports['pulsar-core']:FetchCount()
		Wait(30000)
	end
end)
