function RegisterTasks()
	exports['pulsar-core']:TasksRegister('mdt_warrants', 30, function()
		exports['pulsar-core']:LoggerTrace('MDT', 'Expiring Warrants')

		-- Set Expired Active Warrants to Expired
		local r = MySQL.query.await("UPDATE mdt_warrants SET state = ? WHERE state = ? AND expires < NOW()", {
			"expired",
			"active"
		})
	end)
end
