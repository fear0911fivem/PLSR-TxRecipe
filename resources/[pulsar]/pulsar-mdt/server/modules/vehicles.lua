function GetVehicleOwnerData(sid)
	local result = MySQL.single.await('SELECT First, Last, SID FROM characters WHERE SID = ?', { sid })
	return result
end

local function DecodeJsonField(field, defaultValue)
	if field and type(field) == "string" then
		local success, decoded = pcall(json.decode, field)
		if success and decoded then
			return decoded
		end
	end
	return defaultValue or {}
end

local function DecodeVehicleJsonFields(vehicle)
	vehicle.Properties = DecodeJsonField(vehicle.Properties, {})
	vehicle.Damage = DecodeJsonField(vehicle.Damage, {})
	vehicle.DamagedParts = DecodeJsonField(vehicle.DamagedParts, {})
	vehicle.Polish = DecodeJsonField(vehicle.Polish, {})
	vehicle.PurgeColor = DecodeJsonField(vehicle.PurgeColor, {})
	vehicle.WheelFitment = DecodeJsonField(vehicle.WheelFitment, {})

	if vehicle.Properties and type(vehicle.Properties) == "table" then
		if vehicle.Properties.Strikes and type(vehicle.Properties.Strikes) == "string" then
			local success, strikes = pcall(json.decode, vehicle.Properties.Strikes)
			if success and strikes and type(strikes) == "table" then
				vehicle.Properties.Strikes = strikes
			else
				vehicle.Properties.Strikes = {}
			end
		elseif not vehicle.Properties.Strikes then
			vehicle.Properties.Strikes = {}
		end

		if vehicle.Properties.Flags and type(vehicle.Properties.Flags) == "string" then
			local success, flags = pcall(json.decode, vehicle.Properties.Flags)
			if success and flags and type(flags) == "table" then
				local isArray = false
				for k, v in pairs(flags) do
					if type(k) == "number" then
						isArray = true
						break
					end
				end

				if not isArray then
					vehicle.Properties.Flags = { flags }
				else
					vehicle.Properties.Flags = flags
				end
			else
				vehicle.Properties.Flags = {}
			end
		elseif not vehicle.Properties.Flags then
			vehicle.Properties.Flags = {}
		end

		if vehicle.Properties.GovAssigned then
			if type(vehicle.Properties.GovAssigned) == "string" then
				local success, govAssigned = pcall(json.decode, vehicle.Properties.GovAssigned)
				if success and govAssigned and type(govAssigned) == "table" then
					vehicle.Properties.GovAssigned = govAssigned
				else
					vehicle.Properties.GovAssigned = nil
				end
			end
		end

		vehicle.Strikes = vehicle.Properties.Strikes or {}
		vehicle.Flags = vehicle.Properties.Flags or {}
		vehicle.GovAssigned = vehicle.Properties.GovAssigned or nil
	end
end

exports('VehiclesSearch', function(term, page, perPage)
	page = page or 1
	perPage = perPage or 10

	page = tonumber(page) or 1
	perPage = tonumber(perPage) or 10

	page = math.max(1, page)
	perPage = math.max(1, perPage)

	local skip = 0
	if page > 1 then
		skip = perPage * (page - 1)
	end

	local query = ""
	local params = {}

	if term and term:sub(1, 5) == "SID: " then
		local sid = tonumber(term:sub(6, #term))
		if sid then
			query = "WHERE OwnerType = ? AND OwnerId = ?"
			params = { 0, sid }
		end
	else
		query = "WHERE (VIN LIKE ? OR RegisteredPlate LIKE ? OR CONCAT(Make, ' ', Model) LIKE ?)"
		params = { "%" .. (term or "") .. "%", "%" .. (term or "") .. "%", "%" .. (term or "") .. "%" }
	end

	local finalParams = {}
	for i = 1, #params do
		table.insert(finalParams, params[i])
	end
	table.insert(finalParams, perPage + 1)
	table.insert(finalParams, skip)

	local results = MySQL.query.await(
		"SELECT * FROM vehicles " .. query .. " ORDER BY Created DESC LIMIT ? OFFSET ?",
		finalParams
	)

	if not results then
		return {
			data = {},
			pages = nil,
		}
	end

	local processedResults = {}
	for i = 1, #results do
		local vehicle = results[i]
		if vehicle then
			DecodeVehicleJsonFields(vehicle)

			vehicle.Type = vehicle.Type or 0
			vehicle.Make = vehicle.Make or "Unknown"
			vehicle.Model = vehicle.Model or "Unknown"
			vehicle.RegisteredPlate = vehicle.RegisteredPlate or "N/A"
			vehicle.OwnerType = vehicle.OwnerType or 0
			vehicle.OwnerId = vehicle.OwnerId or 0
			vehicle.VIN = vehicle.VIN or "N/A"
			vehicle.Class = vehicle.Class or "Unknown"
			vehicle.ModelType = vehicle.ModelType or "automobile"
			vehicle.Fuel = vehicle.Fuel or 100.0
			vehicle.Mileage = vehicle.Mileage or 0.0
			vehicle.Value = vehicle.Value or 0
			vehicle.FirstSpawn = vehicle.FirstSpawn or 0
			vehicle.FakePlate = vehicle.FakePlate or 0
			if vehicle.OwnerType == 0 then
				vehicle.Owner = {
					Type = vehicle.OwnerType,
					Id = vehicle.OwnerId,
					Person = GetVehicleOwnerData(vehicle.OwnerId)
				}
			elseif vehicle.OwnerType == 1 or vehicle.OwnerType == 2 then
				local jobData = exports['pulsar-jobs']:DoesExist(vehicle.OwnerId, vehicle.OwnerWorkplace)
				if jobData then
					local jobName = jobData.Name
					if jobData.Workplace then
						jobName = string.format('%s (%s)', jobData.Name, jobData.Workplace.Name)
					end
					if vehicle.OwnerType == 2 then
						jobName = jobName .. " (Dealership Buyback)"
					end
					vehicle.Owner = {
						Type = vehicle.OwnerType,
						Id = vehicle.OwnerId,
						Workplace = vehicle.OwnerWorkplace,
						JobName = jobName
					}
				else
					vehicle.Owner = {
						Type = vehicle.OwnerType,
						Id = vehicle.OwnerId,
						Workplace = vehicle.OwnerWorkplace,
						JobName = "Unknown Organization"
					}
				end
			else
				vehicle.Owner = {
					Type = vehicle.OwnerType,
					Id = vehicle.OwnerId,
					Workplace = vehicle.OwnerWorkplace
				}
			end

			if vehicle.StorageType ~= nil then
				local storageName = nil
				if vehicle.StorageType == 0 then
					storageName = exports['pulsar-vehicles']:GaragesImpound().name
				elseif vehicle.StorageType == 1 then
					local garage = exports['pulsar-vehicles']:GaragesGet(vehicle.StorageId)
					storageName = garage and garage.name or nil
				elseif vehicle.StorageType == 2 then
					local prop = exports['pulsar-properties']:Get(vehicle.StorageId)
					storageName = prop and prop.label or nil
				end

				if storageName then
					vehicle.Storage = {
						Type = vehicle.StorageType,
						Id = vehicle.StorageId,
						Name = storageName
					}
				end
			end

			table.insert(processedResults, vehicle)
		end
	end

	local pageCount = nil
	if #processedResults > perPage then
		table.remove(processedResults)
		pageCount = page + 1
	end

	return {
		data = processedResults,
		pages = pageCount,
	}
end)

exports('VehiclesView', function(VIN)
	local vehicle = MySQL.single.await(
		"SELECT * FROM vehicles WHERE VIN = ?",
		{ VIN }
	)

	if not vehicle then
		return false
	end

	DecodeVehicleJsonFields(vehicle)

	if vehicle.OwnerType == 0 then
		vehicle.Owner = {
			Type = vehicle.OwnerType,
			Id = vehicle.OwnerId,
			Person = GetVehicleOwnerData(vehicle.OwnerId)
		}
	elseif vehicle.OwnerType == 1 or vehicle.OwnerType == 2 then
		local jobData = exports['pulsar-jobs']:DoesExist(vehicle.OwnerId, vehicle.OwnerWorkplace)
		if jobData then
			local jobName = jobData.Name
			if jobData.Workplace then
				jobName = string.format('%s (%s)', jobData.Name, jobData.Workplace.Name)
			end
			if vehicle.OwnerType == 2 then
				jobName = jobName .. " (Dealership Buyback)"
			end
			vehicle.Owner = {
				Type = vehicle.OwnerType,
				Id = vehicle.OwnerId,
				Workplace = vehicle.OwnerWorkplace,
				JobName = jobName
			}
		end
	end

	if vehicle.StorageType ~= nil then
		local storageName = nil
		if vehicle.StorageType == 0 then
			storageName = exports['pulsar-vehicles']:GaragesImpound().name
		elseif vehicle.StorageType == 1 then
			local garage = exports['pulsar-vehicles']:GaragesGet(vehicle.StorageId)
			storageName = garage and garage.name or nil
		elseif vehicle.StorageType == 2 then
			local prop = exports['pulsar-properties']:Get(vehicle.StorageId)
			storageName = prop and prop.label or nil
		end

		if storageName then
			vehicle.Storage = {
				Type = vehicle.StorageType,
				Id = vehicle.StorageId,
				Name = storageName
			}
		end
	end

	if vehicle.RegisteredPlate then
		local flagged = exports['pulsar-radar']:CheckPlate(vehicle.RegisteredPlate)
		if flagged ~= "Vehicle Flagged in MDT" then
			vehicle.RadarFlag = flagged
		end
	end

	return vehicle
end)

exports('VehiclesFlagsAdd', function(VIN, data, plate)
	local success = MySQL.update.await(
		"UPDATE vehicles SET Properties = JSON_SET(COALESCE(Properties, '{}'), '$.Flags', ?) WHERE VIN = ?",
		{ json.encode(data), VIN }
	)

	if success and plate then
		exports['pulsar-radar']:AddFlaggedPlate(plate, data)
	end

	return success
end)

exports('VehiclesFlagsRemove', function(VIN, plate)
	local success = MySQL.update.await(
		"UPDATE vehicles SET Properties = JSON_REMOVE(Properties, '$.Flags') WHERE VIN = ?",
		{ VIN }
	)

	if success and plate then
		exports['pulsar-radar']:RemoveFlaggedPlate(plate)
	end

	return success
end)

exports('VehiclesUpdateStrikes', function(VIN, strikes)
	local success = MySQL.update.await(
		"UPDATE vehicles SET Properties = JSON_SET(COALESCE(Properties, '{}'), '$.Strikes', ?) WHERE VIN = ?",
		{ json.encode(strikes), VIN }
	)

	return success
end)

exports('VehiclesGetStrikes', function(VIN)
	local vehicle = MySQL.single.await(
		"SELECT VIN, Properties, RegisteredPlate FROM vehicles WHERE VIN = ?",
		{ VIN }
	)

	if not vehicle then
		return 0
	end

	DecodeVehicleJsonFields(vehicle)

	local strikes = 0
	if vehicle.Strikes and type(vehicle.Strikes) == "table" and #vehicle.Strikes > 0 then
		strikes = #vehicle.Strikes
	end

	return strikes
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("MDT:Search:vehicle", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			local term = data.term or ""
			local page = data.page or 1
			local perPage = data.perPage or 10

			page = tonumber(page) or 1
			perPage = tonumber(perPage) or 10

			cb(exports['pulsar-mdt']:VehiclesSearch(term, page, perPage))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:View:vehicle", function(source, data, cb)
		if CheckMDTPermissions(source, false) then
			cb(exports['pulsar-mdt']:VehiclesView(data))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Create:vehicle-flag", function(source, data, cb)
		if CheckMDTPermissions(source, false, 'police') then
			cb(exports['pulsar-mdt']:VehiclesFlagsAdd(data.parent, data.doc, data.plate))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Delete:vehicle-flag", function(source, data, cb)
		if CheckMDTPermissions(source, false, 'police') then
			cb(exports['pulsar-mdt']:VehiclesFlagsRemove(data.parent, data.id, data.plate, data.removeRadarFlag))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:Update:vehicle-strikes", function(source, data, cb)
		if CheckMDTPermissions(source, false, 'police') then
			cb(exports['pulsar-mdt']:VehiclesUpdateStrikes(data.VIN, data.strikes))
		else
			cb(false)
		end
	end)
end)
