local DISCORD_NAME = "Logger Bot"
local DISCORD_IMAGE = "https://i.ibb.co/bzct884/logo.png"
local logWebhook = GetConvar("discord_log_webhook", "NOT SET")

local colors = {
	trace = 11908533,
	info = 3844857,
	success = 6750003,
	warning = 16776960,
	error = 16711680,
	critical = 16711782,
}

local levelColors = {
	[1] = "trace",
	[2] = "info",
	[3] = "warn",
	[4] = "error",
	[5] = "critical",
}

exports('LoggerTrace', function(component, log, flags, data)
	doLog(1, component, log, flags, data)
end)

exports('LoggerInfo', function(component, log, flags, data)
	doLog(2, component, log, flags, data)
end)

exports('LoggerWarn', function(component, log, flags, data)
	doLog(3, component, log, flags, data)
end)

exports('LoggerError', function(component, log, flags, data)
	doLog(4, component, log, flags, data)
end)

exports('LoggerCritical', function(component, log, flags, data)
	doLog(5, component, log, flags, data)
end)

function doLog(level, component, log, flags, data)
	CreateThread(function()
		local prefix = "[LOG]"
		local mPrefix = "[LOG]"

		if level > 0 then
			if level == 1 then
				prefix = "[TRACE]"
				mPrefix = "[TRACE]"
			elseif level == 2 then
				prefix = "[^5INFO^7] "
				mPrefix = "[INFO]"
			elseif level == 3 then
				prefix = "[^3WARN^7] "
				mPrefix = "[WARN]"
			elseif level == 4 then
				prefix = "[^1ERROR^7]"
				mPrefix = "[ERROR]"
			elseif level == 5 then
				prefix = "[^9CRITICAL^7]"
				mPrefix = "[CRITICAL]"
			end
		end

		if flags == nil then
			flags = { console = true }
		end

		local loggingLevel = 0
		loggingLevel = exports["pulsar-core"]:GetLogging()

		if flags.console and level >= loggingLevel then
			local formattedLog = string.format("%s\t[^6%s^7] %s", prefix, component, log)
			print(formattedLog)
		end

		if flags.file then
			local currDate = os.date("%Y-%m-%d")
			local timestamp = os.date("%I:%M:%S %p")
			os.execute("mkdir logs")
			os.execute(('mkdir "logs/%s"'):format(component))
			local logFile, errorReason = io.open(("logs/%s/%s.log"):format(component, currDate), "a")
			if not logFile then
				return print(errorReason)
			end
			local formattedLog = string.format("%s  [%s]    %s", mPrefix, timestamp, log)
			logFile:write(formattedLog .. "\n")
			logFile:close()
		end


		if GlobalState.IsProduction and flags.database then
			exports.oxmysql:insert('INSERT INTO logs (date, level, component, log, data) VALUES (?, ?, ?, ?, ?)', {
				os.time(),
				level,
				component,
				log,
				json.encode(data or {})
			})
		end

		if GlobalState.IsProduction and flags.discord then
			if logWebhook ~= "NOT SET" then
				if type(flags.discord) == "table" then
					if flags.discord.embed then
						local data = {
							embeds = {
								{
									["color"] = colors[levelColors[level]] or colors[flags.discord.type],
									["description"] = log,
									["footer"] = {
										["text"] = "Component: " .. component,
									},
								},
							},
						}

						if flags.discord.title then
							data.embeds.title = flags.discord.title
							if flags.discord.description then
								data.embeds.description = flags.discord.description
							else
								data.embeds.description = nil
							end
						end

						if flags.discord.content then
							data.content = flags.discord.content
						end

						PerformHttpRequest(
							flags.discord.webhook or logWebhook,
							function(err, text, headers) end,
							"POST",
							json.encode(data),
							{
								["Content-Type"] = "application/json",
							}
						)
					else
						PerformHttpRequest(
							flags.discord.webhook or logWebhook,
							function(err, text, headers) end,
							"POST",
							json.encode({
								content = ("%s [%s] %s\n%s"):format(
									mPrefix,
									component,
									log,
									flags.discord.content
								),
							}),
							{ ["Content-Type"] = "application/json" }
						)
					end
				else
					PerformHttpRequest(
						logWebhook,
						function(err, text, headers) end,
						"POST",
						json.encode({ content = ("%s [^5%s^7]\n\n%s"):format(mPrefix, component, log) }),
						{ ["Content-Type"] = "application/json" }
					)
				end
			end
		end
	end)
end
