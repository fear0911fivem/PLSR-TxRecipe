exports("RegisterCommand", function(command, callback, suggestion, arguments, job)
	if job ~= nil then
		if type(job) == "table" and #job > 0 then
			for k, v in pairs(job) do
				if v.Id == nil then
					return
				end
				if v.Level == nil then
					v.Level = 1
				end
			end
		end
	end

	commands[command] = {
		cb = callback,
		args = (arguments or -1),
		job = job,
	}

	if suggestion ~= nil then
		if not suggestion.params or not type(suggestion.params) == "table" then
			suggestion.params = {}
		end
		if not suggestion.help or not type(suggestion.help) == "string" then
			suggestion.help = ""
		end

		commandSuggestions[command] = suggestion
	end

	RegisterCommand(command, function(source, args, rawCommand)
		local pData = exports['pulsar-core']:FetchSource(source)
		if pData ~= nil then
			-- TODO : Implement character specific data for commands (IE Jobs)
			local myDuty = Player(source).state.onDuty

			local argsStr = ""
			if #args > 0 then
				argsStr = "\n\nArguments:\n"
			end
			for k, v in ipairs(args) do
				argsStr = argsStr .. string.format("%s\n", v)
			end

			if commands[command].job ~= nil then
				for k, v in pairs(commands[command].job) do
					if myDuty and myDuty == v.Id then
						if exports['pulsar-jobs']:HasJob(source, v.Id, v.Workplace, v.Grade, v.Level) then
							if
								(#args <= commands[command].args and #args == commands[command].args)
								or commands[command].args == -1
							then
								local char = exports['pulsar-characters']:FetchCharacterSource(source)
								exports['pulsar-core']:LoggerInfo(
									"Commands",
									string.format(
										"%s (%s [%s]) Used A Job Command: %s.%s",
										char
										and string.format(
											"%s %s (SID %s)",
											char:GetData("First"),
											char:GetData("Last"),
											char:GetData("SID")
										)
										or "No Character",
										pData:GetData("Name"),
										pData:GetData("AccountID"),
										command,
										argsStr
									),
									{
										console = false,
										file = true,
										database = true,
									},
									{
										args = args,
									}
								)

								callback(source, args, rawCommand)
							else
								exports["pulsar-chat"]:SendServerSingle(source, "Invalid Number Of Arguments")
							end
						end
					end
				end
			else
				if
					(#args <= commands[command].args and #args == commands[command].args)
					or commands[command].args == -1
				then
					local char = exports['pulsar-characters']:FetchCharacterSource(source)
					exports['pulsar-core']:LoggerInfo(
						"Commands",
						string.format(
							"%s (%s [%s]) Used A Command: %s.%s",
							char
							and string.format(
								"%s %s (SID %s)",
								char:GetData("First"),
								char:GetData("Last"),
								char:GetData("SID")
							)
							or "No Character",
							pData:GetData("Name"),
							pData:GetData("AccountID"),
							command,
							argsStr
						),
						{
							console = false,
							file = true,
							database = true,
						},
						{
							args = args,
						}
					)

					callback(source, args, rawCommand)
				else
					exports["pulsar-chat"]:SendServerSingle(source, "Invalid Number Of Arguments")
				end
			end
		end
	end, false)
end)

exports("RegisterAdminCommand", function(command, callback, suggestion, arguments)
	commands[command] = {
		cb = callback,
		args = (arguments or -1),
		admin = true,
	}

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then
			suggestion.params = {}
		end
		if not suggestion.help or not type(suggestion.help) == "string" then
			suggestion.help = ""
		end

		commandSuggestions[command] = suggestion
	end

	RegisterCommand(command, function(source, args, rawCommand)
		local player = exports['pulsar-core']:FetchSource(source)
		if player ~= nil then
			local argsStr = ""
			if #args > 0 then
				argsStr = "\n\nArguments:\n"
			end
			for k, v in ipairs(args) do
				argsStr = argsStr .. string.format("%s\n", v)
			end

			if player.Permissions:IsAdmin() then
				if
					(#args <= commands[command].args and #args == commands[command].args)
					or commands[command].args == -1
				then
					exports['pulsar-core']:LoggerInfo(
						"Pwnzor",
						string.format(
							"%s (%s) Used An Admin Command: %s.%s",
							player:GetData("Name"),
							player:GetData("AccountID"),
							command,
							argsStr
						),
						{
							console = false,
							file = false,
							database = true,
							discord = {
								embed = true,
								type = "error",
								webhook = GetConvar("discord_admin_webhook", ""),
							},
						},
						{
							args = args,
						}
					)
					callback(source, args, rawCommand)
				else
					exports["pulsar-chat"]:SendServerSingle(source, "Invalid Number Of Arguments")
				end
			else
				exports['pulsar-core']:LoggerInfo(
					"Pwnzor",
					string.format(
						"%s (%s) Attempted To Use An Admin Command: %s.%s",
						player:GetData("Name"),
						player:GetData("AccountID"),
						command,
						argsStr
					),
					{
						console = false,
						file = true,
						database = true,
						discord = {
							embed = true,
							type = "error",
							webhook = GetConvar("discord_admin_webhook", ""),
						},
					},
					{
						args = args,
					}
				)
			end
		end
	end, false)
end)

exports("RegisterStaffCommand", function(command, callback, suggestion, arguments)
	commands[command] = {
		cb = callback,
		args = (arguments or -1),
		staff = true,
	}

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then
			suggestion.params = {}
		end
		if not suggestion.help or not type(suggestion.help) == "string" then
			suggestion.help = ""
		end

		commandSuggestions[command] = suggestion
	end

	RegisterCommand(command, function(source, args, rawCommand)
		local player = exports['pulsar-core']:FetchSource(source)
		if player ~= nil then
			local argsStr = ""
			if #args > 0 then
				argsStr = "\n\nArguments:\n"
			end
			for k, v in ipairs(args) do
				argsStr = argsStr .. string.format("%s\n", v)
			end

			if player.Permissions:IsStaff() then
				if
					(#args <= commands[command].args and #args == commands[command].args)
					or commands[command].args == -1
				then
					exports['pulsar-core']:LoggerInfo(
						"Pwnzor",
						string.format(
							"%s (%s) Used A Staff Command: %s.%s",
							player:GetData("Name"),
							player:GetData("AccountID"),
							command,
							argsStr
						),
						{
							console = false,
							file = true,
							database = true,
							discord = {
								embed = true,
								type = "error",
								webhook = GetConvar("discord_admin_webhook", ""),
							},
						},
						{
							args = args,
						}
					)
					callback(source, args, rawCommand)
				else
					exports["pulsar-chat"]:SendServerSingle(source, "Invalid Number Of Arguments")
				end
			else
				exports['pulsar-core']:LoggerInfo(
					"Pwnzor",
					string.format(
						"%s (%s) Attempted To Use A Staff Command: %s.%s",
						player:GetData("Name"),
						player:GetData("AccountID"),
						command,
						argsStr
					),
					{
						console = false,
						file = true,
						database = true,
						discord = {
							embed = true,
							type = "error",
							webhook = GetConvar("discord_admin_webhook", ""),
						},
					},
					{
						args = args,
					}
				)
			end
		end
	end, false)
end)
