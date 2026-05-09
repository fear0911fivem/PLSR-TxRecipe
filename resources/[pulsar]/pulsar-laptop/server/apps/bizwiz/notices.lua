exports('BizWizNoticesCreate', function(source, job, data)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local p = promise.new()

		data.job = job
		data.author = {
			SID = char:GetData("SID"),
			First = char:GetData("First"),
			Last = char:GetData("Last"),
		}

		local authorJson = json.encode(data.author)

		exports.oxmysql:execute(
			'INSERT INTO business_notices (job, title, content, author) VALUES (?, ?, ?, ?)',
			{ data.job, data.title, data.content, authorJson },
			function(result)
				if result and result.insertId then
					data._id = result.insertId
					table.insert(_businessNotices, data)

					local jobDutyData = exports['pulsar-jobs']:DutyGetDutyData(job)
					if jobDutyData and jobDutyData.DutyPlayers then
						for k, v in ipairs(jobDutyData.DutyPlayers) do
							TriggerClientEvent("Laptop:Client:AddData", v, "businessNotices", data)
						end
					end

					p:resolve(result.insertId)
				else
					p:resolve(false)
				end
			end
		)
		return Citizen.Await(p)
	end
	return false
end)

exports('BizWizNoticesDelete', function(job, id)
	local p = promise.new()
	exports.oxmysql:execute('DELETE FROM business_notices WHERE id = ? AND job = ?', { id, job }, function(affectedRows)
		if affectedRows > 0 then
			for k, v in ipairs(_businessNotices) do
				if v._id == id then
					table.remove(_businessNotices, k)
					break
				end
			end

			local jobDutyData = exports['pulsar-jobs']:DutyGetDutyData(job)
			if jobDutyData and jobDutyData.DutyPlayers then
				for k, v in ipairs(jobDutyData.DutyPlayers) do
					TriggerClientEvent("Laptop:Client:RemoveData", v, "businessNotices", id)
				end
			end

			p:resolve(true)
		else
			p:resolve(false)
		end
	end)
	return Citizen.Await(p)
end)

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
	exports.oxmysql:execute('SELECT * FROM business_notices', {}, function(results)
		if results then
			for i, notice in ipairs(results) do
				if notice.author then
					notice.author = json.decode(notice.author)
				end
				notice._id = notice.id
			end

			exports['pulsar-core']:LoggerTrace("Laptop", "[BizWiz] Loaded ^2" .. #results .. "^7 Business Notices",
				{ console = true })
			_businessNotices = results
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Notice:Create", function(source, data, cb)
		local job = CheckBusinessPermissions(source, "TABLET_CREATE_NOTICE")
		if job then
			cb(exports['pulsar-laptop']:BizWizNoticesCreate(source, job, data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Notice:Delete", function(source, data, cb)
		local job = CheckBusinessPermissions(source, "TABLET_DELETE_NOTICE")
		if job then
			cb(exports['pulsar-laptop']:BizWizNoticesDelete(job, data.id))
		else
			cb(false)
		end
	end)
end)
