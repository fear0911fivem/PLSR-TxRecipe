AddEventHandler("Phone:Server:RegisterMiddleware", function()
	exports['pulsar-core']:MiddlewareAdd("Phone:Spawning", function(source, char)
		return {
			{
				type = "jobs",
				data = exports['pulsar-labor']:GetJobs(),
			},
			{
				type = "workGroups",
				data = exports['pulsar-labor']:GetGroups(),
			},
		}
	end)
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:CreateWorkgroup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local myDuty = Player(source).state.onDuty

		if myDuty and (myDuty == "police" or myDuty == "ems") then
			exports['pulsar-core']:LoggerTrace(
				"Labor",
				string.format(
					"%s %s (%s) Attempted To Create Workgroup (%s)",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					myDuty
				)
			)
			-- DropPlayer(
			-- 	source,
			-- 	string.format("%s", "Double dipping jobs is not allowed. Don't do it again - instead, go off duty.")
			-- )
			exports['pulsar-hud']:Notification(source, "error",
				'Double dipping jobs is not allowed. Instead, go off duty.')
			cb(false)
		else
			if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
				cb(false)
			else
				cb(exports['pulsar-labor']:CreateWorkgroup(source))
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:DisbandWorkgroup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
			cb(false)
		else
			cb(exports['pulsar-labor']:DisbandWorkgroup(source, true))
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:JoinWorkgroup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local myDuty = Player(source).state.onDuty
		if myDuty and (myDuty == "police" or myDuty == "ems") then
			exports['pulsar-core']:LoggerTrace(
				"Labor",
				string.format(
					"%s %s (%s) Attempted To Join Workgroup (%s)",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					myDuty
				)
			)
			-- DropPlayer(
			-- 	source,
			-- 	string.format("%s", "Double dipping jobs is not allowed. Don't do it again - instead, go off duty.")
			-- )
			exports['pulsar-hud']:Notification(source, "error",
				'Double dipping jobs is not allowed. Instead, go off duty.')
			cb(false)
		else
			if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
				cb(false)
			else
				cb(exports['pulsar-labor']:RequestWorkgroup(data, source))
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:LeaveWorkgroup", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
			cb(false)
		else
			cb(exports['pulsar-labor']:LeaveWorkgroup(data, source))
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:StartLaborJob", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local myDuty = Player(source).state.onDuty
		if myDuty and (myDuty == "police" or myDuty == "ems") then
			exports['pulsar-core']:LoggerTrace(
				"Labor",
				string.format(
					"%s %s (%s) Attempted To Double Dip Jobs (%s and %s)",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					myDuty,
					data.job
				)
			)
			-- DropPlayer(
			-- 	source,
			-- 	string.format("%s", "Double dipping jobs is not allowed. Don't do it again - instead, go off duty.")
			-- )
			exports['pulsar-hud']:Notification(source, "error",
				'Double dipping jobs is not allowed. Instead, go off duty.')
			cb(false)
		else
			if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
				cb(false)
			else
				cb(exports['pulsar-labor']:OnDuty(data.job, source, data.isWorkgroup))
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Labor:QuitLaborJob", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
			cb(false)
		else
			cb(exports['pulsar-labor']:OffDuty(data, source))
		end
	end)
end)
