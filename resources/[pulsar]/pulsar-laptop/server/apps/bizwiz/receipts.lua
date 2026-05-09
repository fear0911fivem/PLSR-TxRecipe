exports('BizWizReceiptsSearch', function(jobId, term)
	if not term then term = '' end
	local p = promise.new()

	local query =
	'SELECT * FROM business_receipts WHERE job = ? AND (customerName LIKE ? OR CONCAT(JSON_UNQUOTE(JSON_EXTRACT(author, "$.First")), " ", JSON_UNQUOTE(JSON_EXTRACT(author, "$.Last")), " ", JSON_UNQUOTE(JSON_EXTRACT(author, "$.SID"))) LIKE ?)'
	local searchTerm = '%' .. term .. '%'

	exports.oxmysql:execute(query, { jobId, searchTerm, searchTerm }, function(results)
		if results then
			for i, receipt in ipairs(results) do
				if receipt.author then
					receipt.author = json.decode(receipt.author)
				end
				if receipt.items then
					receipt.items = json.decode(receipt.items)
				end
				if receipt.history then
					receipt.history = json.decode(receipt.history)
				end
				if receipt.lastUpdated then
					receipt.lastUpdated = json.decode(receipt.lastUpdated)
				end
				receipt._id = receipt.id
			end
			p:resolve(results)
		else
			p:resolve(false)
		end
	end)
	return Citizen.Await(p)
end)

exports('BizWizReceiptsView', function(jobId, id)
	local p = promise.new()
	exports.oxmysql:execute('SELECT * FROM business_receipts WHERE job = ? AND id = ?', { jobId, id }, function(results)
		if results and #results > 0 then
			local receipt = results[1]
			if receipt.author then
				receipt.author = json.decode(receipt.author)
			end
			if receipt.items then
				receipt.items = json.decode(receipt.items)
			end
			if receipt.history then
				receipt.history = json.decode(receipt.history)
			end
			if receipt.lastUpdated then
				receipt.lastUpdated = json.decode(receipt.lastUpdated)
			end
			receipt._id = receipt.id
			p:resolve(receipt)
		else
			p:resolve(false)
		end
	end)
	return Citizen.Await(p)
end)

exports('BizWizReceiptsCreate', function(jobId, data)
	if not _bizWizConfig[jobId] then
		return false
	end

	local p = promise.new()

	local authorJson = data.author and json.encode(data.author) or nil
	local itemsJson = data.items and json.encode(data.items) or nil
	local historyJson = data.history and json.encode(data.history) or nil
	local lastUpdatedJson = data.lastUpdated and json.encode(data.lastUpdated) or nil

	exports.oxmysql:execute(
		'INSERT INTO business_receipts (job, customerName, amount, items, author, history, lastUpdated) VALUES (?, ?, ?, ?, ?, ?, ?)',
		{ jobId, data.customerName, data.amount or 0, itemsJson, authorJson, historyJson, lastUpdatedJson },
		function(result)
			if result and result.insertId then
				p:resolve({
					_id = result.insertId,
				})
			else
				p:resolve(false)
			end
		end
	)

	return Citizen.Await(p)
end)

exports('BizWizReceiptsUpdate', function(jobId, id, char, report)
	local p = promise.new()

	exports.oxmysql:execute('SELECT history FROM business_receipts WHERE id = ? AND job = ?', { id, jobId },
		function(results)
			if results and #results > 0 then
				local currentHistory = results[1].history and json.decode(results[1].history) or {}

				table.insert(currentHistory, {
					Time = (os.time() * 1000),
					Char = char:GetData("SID"),
					Log = string.format(
						"%s Updated Report",
						char:GetData("First") .. " " .. char:GetData("Last")
					),
				})

				local authorJson = report.author and json.encode(report.author) or nil
				local itemsJson = report.items and json.encode(report.items) or nil
				local historyJson = json.encode(currentHistory)
				local lastUpdatedJson = report.lastUpdated and json.encode(report.lastUpdated) or nil

				local updateFields = {}
				local params = {}

				if report.customerName then
					table.insert(updateFields, "customerName = ?")
					table.insert(params, report.customerName)
				end
				if report.amount then
					table.insert(updateFields, "amount = ?")
					table.insert(params, report.amount)
				end
				if itemsJson then
					table.insert(updateFields, "items = ?")
					table.insert(params, itemsJson)
				end
				if authorJson then
					table.insert(updateFields, "author = ?")
					table.insert(params, authorJson)
				end
				if lastUpdatedJson then
					table.insert(updateFields, "lastUpdated = ?")
					table.insert(params, lastUpdatedJson)
				end

				table.insert(updateFields, "history = ?")
				table.insert(params, historyJson)
				table.insert(params, id)
				table.insert(params, jobId)

				local query = 'UPDATE business_receipts SET ' ..
					table.concat(updateFields, ', ') .. ' WHERE id = ? AND job = ?'

				exports.oxmysql:execute(query, params, function(affectedRows)
					p:resolve(affectedRows > 0)
				end)
			else
				p:resolve(false)
			end
		end)
	return Citizen.Await(p)
end)

exports('BizWizReceiptsDelete', function(jobId, id)
	local p = promise.new()

	exports.oxmysql:execute('DELETE FROM business_receipts WHERE id = ? AND job = ?', { id, jobId },
		function(affectedRows)
			p:resolve(affectedRows > 0)
		end)
	return Citizen.Await(p)
end)

exports('BizWizReceiptsDeleteAll', function(jobId)
	if not jobId then return false; end

	local p = promise.new()

	exports.oxmysql:execute('DELETE FROM business_receipts WHERE job = ?', { jobId }, function(affectedRows)
		p:resolve(affectedRows >= 0)
	end)
	return Citizen.Await(p)
end)

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:Search", function(source, data, cb)
		local job = CheckBusinessPermissions(source)
		if job then
			cb(exports['pulsar-laptop']:BizWizReceiptsSearch(job, data.term))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:Create", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local job = CheckBusinessPermissions(source, 'TABLET_CREATE_RECEIPT')
		if job then
			data.doc.author = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}
			cb(exports['pulsar-laptop']:BizWizReceiptsCreate(job, data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:Update", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local job = CheckBusinessPermissions(source, 'TABLET_MANAGE_RECEIPT')
		if char and job then
			data.Report.lastUpdated = {
				Time = (os.time() * 1000),
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}
			cb(exports['pulsar-laptop']:BizWizReceiptsUpdate(job, data.id, char, data.Report))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:Delete", function(source, data, cb)
		local job = CheckBusinessPermissions(source, 'TABLET_MANAGE_RECEIPT')
		if job then
			cb(exports['pulsar-laptop']:BizWizReceiptsDelete(job, data.id))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:DeleteAll", function(source, data, cb)
		local job = CheckBusinessPermissions(source, 'TABLET_CLEAR_RECEIPT')
		if job then
			cb(exports['pulsar-laptop']:BizWizReceiptsDeleteAll(job))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Receipt:View", function(source, data, cb)
		local job = CheckBusinessPermissions(source)
		if job then
			cb(exports['pulsar-laptop']:BizWizReceiptsView(job, data))
		else
			cb(false)
		end
	end)
end)
