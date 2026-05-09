function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Jail:SpawnJailed", function(source, data, cb)
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		TriggerClientEvent("Jail:Client:EnterJail", source)
		cb(true)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:Validate", function(source, data, cb)
		if not exports['pulsar-jail']:IsJailed(source) then
			cb(false)
		else
			if data.type == "logout" then
				cb(true)
			else
				cb(false)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:RetreiveItems", function(source, data, cb)
		exports.ox_inventory:HoldingTake(source)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:Release", function(source, data, cb)
		cb(exports['pulsar-jail']:Release(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:StartWork", function(source, data, cb)
		exports['pulsar-labor']:OnDuty("Prison", source, false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:QuitWork", function(source, data, cb)
		exports['pulsar-labor']:OffDuty("Prison", source, false, false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:MakeItem", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if data == "food" or data == "drink" then
			exports.ox_inventory:AddItem(char:GetData("SID"), string.format("prison_%s", data), 1, {}, 1)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:MakeJuice", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and data then
			exports.ox_inventory:AddItem(char:GetData("SID"), data, 1, {}, 1)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jail:Server:ExploitAttempt", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			if data == 1 then
				exports['pulsar-core']:LoggerInfo(
					"Jail",
					string.format(
						"%s %s (%s) attempted to exploit out of prison in a trunk",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID")
					),
					{
						console = true,
						file = true,
						database = true,
						discord = {
							embed = true,
							type = "info",
							webhook = GetConvar("discord_log_webhook", ""),
						},
					}
				)
			elseif data == 2 then
				exports['pulsar-core']:LoggerInfo(
					"Jail",
					string.format(
						"%s %s (%s) attempted to exploit out of prison by being escorted out",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID")
					),
					{
						console = true,
						file = true,
						database = true,
						discord = {
							embed = true,
							type = "info",
							webhook = GetConvar("discord_log_webhook", ""),
						},
					}
				)
			end
		end
	end)
end
