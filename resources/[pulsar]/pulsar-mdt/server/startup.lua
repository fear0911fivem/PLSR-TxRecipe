_warrants = {}
_charges = {}
_notices = {}

function Startup()
	RegisterTasks()

	-- Set Expired Active Warrants to Expired
	MySQL.query.await("UPDATE mdt_warrants SET state = ? WHERE state = ? AND expires < NOW()", {
		"expired",
		"active",
	})

	_charges = MySQL.query.await("SELECT * from mdt_charges")
	exports['pulsar-core']:LoggerTrace("MDT", "Loaded ^2" .. #_charges .. "^7 Charges", { console = true })

	local flaggedVehicles = MySQL.query.await(
		"SELECT Type, VIN, Properties, RegisteredPlate FROM vehicles WHERE JSON_EXTRACT(Properties, '$.Flags') IS NOT NULL"
	)

	if flaggedVehicles then
		for k, v in ipairs(flaggedVehicles) do
			if v.RegisteredPlate and v.Type == 0 then
				exports['pulsar-radar']:AddFlaggedPlate(v.RegisteredPlate, "Vehicle Flagged in MDT")
			end
		end
	end

	-- SetHttpHandler(function(req, res)
	-- 	if req.path == '/charges' then
	-- 		res.send(json.encode(_charges))
	-- 	end
	-- end)

	local thirtyDaysAgo = (os.time() * 1000) - (60 * 60 * 24 * 30 * 1000)

	local vehiclesWithOldStrikes = MySQL.query.await(
		"SELECT VIN, Properties FROM vehicles WHERE JSON_EXTRACT(Properties, '$.Strikes') IS NOT NULL"
	)

	if vehiclesWithOldStrikes then
		for k, vehicle in ipairs(vehiclesWithOldStrikes) do
			if vehicle.Properties then
				local properties = json.decode(vehicle.Properties)
				if properties and properties.Strikes then
					local updatedStrikes = {}
					local hasRecentStrikes = false

					for _, strike in ipairs(properties.Strikes) do
						if strike.Date and strike.Date > thirtyDaysAgo then
							table.insert(updatedStrikes, strike)
							hasRecentStrikes = true
						end
					end

					if #updatedStrikes ~= #properties.Strikes then
						properties.Strikes = updatedStrikes
						MySQL.update.await(
							"UPDATE vehicles SET Properties = ? WHERE VIN = ?",
							{ json.encode(properties), vehicle.VIN }
						)
					end
				end
			end
		end
	end
end
