function RegisterChatCommands()
	exports["pulsar-chat"]:RegisterAdminCommand("setcallsign", function(source, args, rawCommand)
		local newCallsign = args[2]
		local target = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
		if target ~= nil then
			if
				exports['pulsar-jobs']:HasJob(target:GetData("Source"), "police")
				or exports['pulsar-jobs']:HasJob(target:GetData("Source"), "ems")
			then
				if exports['pulsar-mdt']:PeopleUpdate(-1, target:GetData("SID"), "Callsign", newCallsign) then
					exports["pulsar-chat"]:SendSystemSingle(source, "Updated Callsign")
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "Error Updating Callsign")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Target is not Emergency Personnel")
			end
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Invalid State ID")
		end
	end, {
		help = "Assign a callsign to an emergency worker",
		params = {
			{
				name = "Target",
				help = "State ID",
			},
			{
				name = "Callsign",
				help = "The callsign you want to assign to the player. This must be unique",
			},
		},
	}, 2)

	exports["pulsar-chat"]:RegisterAdminCommand("reclaimcallsign", function(source, args, rawCommand)
		local callsign = args[1]
		local result = MySQL.Sync.fetchAll('SELECT SID, User, First, Last FROM characters WHERE Callsign = @callsign', {
			['@callsign'] = callsign
		})

		if result and #result > 0 then
			local char = result[1]
			MySQL.Sync.execute('UPDATE characters SET Callsign = @newCallsign WHERE Callsign = @callsign', {
				['@newCallsign'] = false,
				['@callsign'] = callsign
			})

			local fetchedChar = exports['pulsar-characters']:FetchBySID(char.SID)
			if fetchedChar then
				fetchedChar:SetData("Callsign", false)
			end

			exports["pulsar-chat"]:SendSystemSingle(source,
				string.format("Callsign Reclaimed From %s %s (%s)", char.First, char.Last, char.SID))
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Nobody With That Callsign")
		end
	end, {
		help = "Force Reclaim a Callsign",
		params = {
			{
				name = "Callsign",
				help = "The callsign you want to reclaim.",
			},
		},
	}, 1)

	exports["pulsar-chat"]:RegisterCommand(
		"mdt",
		function(source, args, rawCommand)
			TriggerClientEvent("MDT:Client:Toggle", source)
		end,
		{
			help = "Open MDT",
		},
		0,
		{
			{
				Id = "police",
			},
			{
				Id = "government",
			},
			{
				Id = "ems",
			},
			{
				Id = "prison",
			},
		}
	)

	exports["pulsar-chat"]:RegisterAdminCommand("addmdtsysadmin", function(source, args, rawCommand)
		local targetStateId = math.tointeger(args[1])
		local success = exports['pulsar-mdt']:PeopleUpdate(-1, targetStateId, "MDTSystemAdmin", true)
		if success then
			exports["pulsar-chat"]:SendSystemSingle(source, "Granted System Admin to State ID: " .. targetStateId)
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Error Granting System Admin")
		end
	end, {
		help = "Grant MDT System Admin [Danger!]",
		params = {
			{
				name = "Target State ID",
				help = "State ID of Character",
			},
		},
	}, 1)

	exports["pulsar-chat"]:RegisterAdminCommand("removemdtsysadmin", function(source, args, rawCommand)
		local targetStateId = math.tointeger(args[1])
		local success = exports['pulsar-mdt']:PeopleUpdate(-1, targetStateId, "MDTSystemAdmin", false)
		if success then
			exports["pulsar-chat"]:SendSystemSingle(source, "Revoked System Admin from State ID: " .. targetStateId)
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Error Revoking System Admin")
		end
	end, {
		help = "Revoke MDT System Admin",
		params = {
			{
				name = "Target State ID",
				help = "State ID of Character",
			},
		},
	}, 1)

	exports["pulsar-chat"]:RegisterCommand(
		"clearblips",
		function(source, args, rawCommand)
			TriggerClientEvent("EmergencyAlerts:Client:Clear", source)
		end,
		{
			help = "Clear Emergency Alert Blips",
		},
		0,
		{
			{
				Id = "police",
			},
			{
				Id = "ems",
			},
			{
				Id = "tow",
			}
		}
	)
end
