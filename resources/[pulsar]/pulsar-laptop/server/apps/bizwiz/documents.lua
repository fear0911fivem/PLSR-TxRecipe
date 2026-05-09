exports('BizWizDocumentsSearch', function(jobId, term)
	if not term then term = '' end
	local p = promise.new()

	local query =
	'SELECT * FROM business_documents WHERE job = ? AND (title LIKE ? OR CONCAT(JSON_UNQUOTE(JSON_EXTRACT(author, "$.First")), " ", JSON_UNQUOTE(JSON_EXTRACT(author, "$.Last")), " ", JSON_UNQUOTE(JSON_EXTRACT(author, "$.SID"))) LIKE ?)'
	local searchTerm = '%' .. term .. '%'

	exports.oxmysql:execute(query, { jobId, searchTerm, searchTerm }, function(results)
		if results then
			for i, doc in ipairs(results) do
				if doc.author then
					doc.author = json.decode(doc.author)
				end
				if doc.history then
					doc.history = json.decode(doc.history)
				end
				if doc.lastUpdated then
					doc.lastUpdated = json.decode(doc.lastUpdated)
				end
				doc._id = doc.id
			end
			p:resolve(results)
		else
			p:resolve(false)
		end
	end)
	return Citizen.Await(p)
end)

exports('BizWizDocumentsView', function(jobId, id)
	local p = promise.new()
	exports.oxmysql:execute('SELECT * FROM business_documents WHERE job = ? AND id = ?', { jobId, id }, function(results)
		if results and #results > 0 then
			local doc = results[1]
			if doc.author then
				doc.author = json.decode(doc.author)
			end
			if doc.history then
				doc.history = json.decode(doc.history)
			end
			if doc.lastUpdated then
				doc.lastUpdated = json.decode(doc.lastUpdated)
			end
			doc._id = doc.id
			p:resolve(doc)
		else
			p:resolve(false)
		end
	end)
	return Citizen.Await(p)
end)

exports('BizWizDocumentsCreate', function(jobId, data)
	local p = promise.new()

	local authorJson = data.author and json.encode(data.author) or nil
	local historyJson = data.history and json.encode(data.history) or nil
	local lastUpdatedJson = data.lastUpdated and json.encode(data.lastUpdated) or nil

	exports.oxmysql:execute(
		'INSERT INTO business_documents (job, title, content, author, history, lastUpdated) VALUES (?, ?, ?, ?, ?, ?)',
		{ jobId, data.title, data.content, authorJson, historyJson, lastUpdatedJson },
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

exports('BizWizDocumentsUpdate', function(jobId, id, char, report)
	local p = promise.new()

	exports.oxmysql:execute('SELECT history FROM business_documents WHERE id = ? AND job = ?', { id, jobId },
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
				local historyJson = json.encode(currentHistory)
				local lastUpdatedJson = report.lastUpdated and json.encode(report.lastUpdated) or nil

				local updateFields = {}
				local params = {}

				if report.title then
					table.insert(updateFields, "title = ?")
					table.insert(params, report.title)
				end
				if report.content then
					table.insert(updateFields, "content = ?")
					table.insert(params, report.content)
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

				local query = 'UPDATE business_documents SET ' ..
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

exports('BizWizDocumentsDelete', function(jobId, id)
	local p = promise.new()

	exports.oxmysql:execute('DELETE FROM business_documents WHERE id = ? AND job = ?', { id, jobId },
		function(affectedRows)
			p:resolve(affectedRows > 0)
		end)
	return Citizen.Await(p)
end)

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Document:Search", function(source, data, cb)
		local job = CheckBusinessPermissions(source, 'TABLET_VIEW_DOCUMENT')
		if job then
			cb(exports['pulsar-laptop']:BizWizDocumentsSearch(job, data.term))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Document:Create", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local job = CheckBusinessPermissions(source, 'TABLET_CREATE_DOCUMENT')
		if job then
			data.doc.author = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}
			cb(exports['pulsar-laptop']:BizWizDocumentsCreate(job, data.doc))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Document:Update", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local job = CheckBusinessPermissions(source, 'TABLET_CREATE_DOCUMENT')
		if char and job then
			data.Report.lastUpdated = {
				Time = (os.time() * 1000),
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}
			cb(exports['pulsar-laptop']:BizWizDocumentsUpdate(job, data.id, char, data.Report))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Document:Delete", function(source, data, cb)
		local job = CheckBusinessPermissions(source, 'TABLET_DELETE_DOCUMENT')
		if job then
			cb(exports['pulsar-laptop']:BizWizDocumentsDelete(job, data.id))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Laptop:BizWiz:Document:View", function(source, data, cb)
		local job = CheckBusinessPermissions(source, 'TABLET_VIEW_DOCUMENT')
		if job then
			cb(exports['pulsar-laptop']:BizWizDocumentsView(job, data))
		else
			cb(false)
		end
	end)
end)
