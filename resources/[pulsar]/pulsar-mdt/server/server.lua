_bolos = {}
_breakpoints = {
	reduction = 50,
	license = 20,
}

local governmentJobs = {
	police = true,
	government = true,
	ems = true,
	tow = true,
	prison = true,
}

_onDutyUsers = {}
_onDutyLawyers = {}

_dojWorkers = {}

_governmentJobData = {}

local sentencedSuspects = {}

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterMiddleware()
		Startup()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-mdt')
		TriggerEvent("MDT:Server:RegisterCallbacks")

		Wait(2500)
		UpdateMDTJobsData()
		RegisterChatCommands()
	end
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	_onDutyLawyers[source] = nil
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	_onDutyLawyers[source] = nil
end)

function RegisterMiddleware()
	exports['pulsar-core']:MiddlewareAdd('Characters:Spawning', function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and char:GetData("Attorney") then
			SetTimeout(5000, function()
				TriggerClientEvent("MDT:Client:Login", source, nil, nil, nil, true, {
					governmentJobs = _governmentJobs,
					charges = _charges,
					governmentJobsData = _governmentJobData,
				})
				_onDutyLawyers[source] = char:GetData('SID')
			end)
		end
	end, 50)
end

function UpdateMDTJobsData()
	local newData = {}
	local allJobData = exports['pulsar-jobs']:GetAll()
	for k, v in ipairs(_governmentJobs) do
		newData[v] = allJobData[v]
	end

	_governmentJobData = newData
	TriggerClientEvent("MDT:Client:SetData", -1, "governmentJobsData", _governmentJobData)
end

AddEventHandler('Jobs:Server:UpdatedCache', function(job)
	if job == -1 or governmentJobs[job] then
		UpdateMDTJobsData()
	end
end)

AddEventHandler('Job:Server:DutyAdd', function(dutyData, source, SID)
	if governmentJobs[dutyData.Id] then
		local job = exports['pulsar-jobs']:HasJob(source, dutyData.Id)
		if job then
			_onDutyUsers[source] = job.Id
			local permissions = exports['pulsar-jobs']:GetPermissionsFromJob(source, job.Id)

			TriggerClientEvent("MDT:Client:Login", source, _breakpoints, job, permissions, false, {
				governmentJobs = _governmentJobs,
				charges = _charges,
				governmentJobsData = _governmentJobData,
				permissions = _permissions,
				qualifications = _qualifications,
				bolos = _bolos,
			})

			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char and job.Id == "government" then
				_dojWorkers[source] = {
					First = char:GetData("First"),
					Last = char:GetData("Last"),
					SID = char:GetData("SID"),
					Phone = char:GetData("Phone"),

					Job = job.Name,
					Workplace = job.Workplace.Name,
					Grade = job.Grade.Name,
				}
			end
		end
	end
end)

AddEventHandler('Jobs:Server:JobUpdate', function(source)
	local dutyData = exports['pulsar-jobs']:DutyGet(source)
	if dutyData and governmentJobs[dutyData.Id] then
		local job = exports['pulsar-jobs']:HasJob(source, dutyData.Id)
		if job then
			local permissions = exports['pulsar-jobs']:GetPermissionsFromJob(source, job.Id)
			TriggerClientEvent('MDT:Client:UpdateJobData', source, job, permissions)
		end
	end
end)

AddEventHandler('Job:Server:DutyRemove', function(dutyData, source, SID)
	if governmentJobs[dutyData.Id] then
		_onDutyUsers[source] = nil
		_dojWorkers[source] = nil
		TriggerClientEvent("MDT:Client:Logout", source)
	end
end)

function CheckMDTPermissions(source, permission, jobId)
	local mdtUser = _onDutyUsers[source]
	if mdtUser and (not jobId or jobId == mdtUser or (type(jobId) == 'table' and jobId[mdtUser])) then
		if not permission then
			return true
		end

		if type(permission) == 'string' then
			local hasPerm = exports['pulsar-jobs']
			exports['pulsar-jobs']:HasPermissionInJob(source, mdtUser, permission)
			if hasPerm then
				return true, mdtUser
			end
		elseif type(permission) == 'table' then
			local jobPermissions = exports['pulsar-jobs']:GetPermissionsFromJob(source, mdtUser)
			for k, v in ipairs(permission) do
				if jobPermissions[v] then
					return true, mdtUser
				end
			end
		end

		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData('MDTSystemAdmin') then -- They have all permissions
			return true, mdtUser
		end
	end
	return false
end

RegisterNetEvent('MDT:Server:OpenPublicRecords', function()
	local src = source
	local dutyData = exports['pulsar-jobs']:DutyGet(src)

	if not _onDutyUsers[src] then
		TriggerClientEvent("MDT:Client:SetMultipleData", src, {
			governmentJobs = _governmentJobs,
			charges = _charges,
			governmentJobsData = _governmentJobData,
			prison = false,
		})
	end

	TriggerClientEvent('MDT:Client:Toggle', src)
end)

RegisterNetEvent('MDT:Server:OpenDOCPublic', function()
	local src = source
	if not _onDutyUsers[src] then
		TriggerClientEvent("MDT:Client:SetMultipleData", src, {
			governmentJobs = _governmentJobs,
			charges = _charges,
			prison = true,
		})
	else
		TriggerClientEvent("MDT:Client:SetMultipleData", src, {
			prison = true,
		})
	end

	TriggerClientEvent('MDT:Client:Toggle', src)
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("MDT:GetHomeData", function(source, data, cb)
		local gJob = _onDutyUsers[source]
		local warrants = MySQL.query.await(
			"SELECT id, state, report, suspect, title, creatorSID, creatorName, creatorCallsign, issued, expires FROM mdt_warrants WHERE state = ? AND expires > NOW() ORDER BY issued DESC LIMIT 5",
			{
				"active"
			})

		local notices
		if gJob then
			notices = MySQL.query.await("SELECT `id`, title, created FROM mdt_notices WHERE restricted IN (?, ?, ?)", {
				"public",
				"government",
				gJob,
			})
		else
			notices = MySQL.query.await("SELECT `id`, title, created FROM mdt_notices WHERE restricted = ?", {
				"public",
			})
		end

		local gWorkers = {}
		for k, v in pairs(_dojWorkers) do
			table.insert(gWorkers, v)
		end

		cb({
			warrants = warrants,
			notices = notices,
			govWorkers = gWorkers,
		})
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:IssueWarrant", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char and CheckMDTPermissions(source, false) and data.report and data.suspect and data.suspect.id then
			local id = exports['pulsar-mdt']:WarrantsCreate(data.report, data.suspect, data.notes, {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
				Callsign = char:GetData("Callsign"),
			})

			if id then
				MySQL.query.await("UPDATE mdt_reports_people SET warrant = ? WHERE type = ? AND SID = ? AND report = ?",
					{
						id,
						"suspect",
						data.suspect.SID,
						data.report,
					})

				cb(true)
				return
			end
		end

		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:SentencePlayer", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if CheckMDTPermissions(source, false) and data.report and not data.data.sentenced then
			if not sentencedSuspects[data.report] then
				sentencedSuspects[data.report] = {}
			end
			local transactions = {}

			if data.data.SID and not sentencedSuspects[data.report][data.data.SID] then
				table.insert(transactions, {
					query =
					"UPDATE mdt_reports_people SET sentenced = ?, sentencedAt = NOW(), points = ?, fine = ?, jail = ?, parole = ?, reduction = ?, revoked = ?, doc = ? WHERE type = ? AND SID = ? AND report = ? AND sentenced = ?",
					values = {
						1,
						data.points,
						data.fine,
						data.jail,
						data.parole and data.parole.parole or 0,
						json.encode({
							type = data.sentence.type,
							value = data.sentence.value,
						}),
						json.encode(data.sentence.revoke),
						data.sentence.doc and 1 or 0,

						"suspect",
						data.data.SID,
						data.report,
						0
					}
				})

				if data.parole ~= nil then
					table.insert(transactions, {
						query =
						"INSERT INTO character_parole (SID, end, total, parole, sentence, fine) VALUES (?, FROM_UNIXTIME(?), ?, ?, ?, ?) ON DUPLICATE KEY UPDATE end = VALUES(end), total = VALUES(total), parole = VALUES(parole), sentence = VALUES(sentence), fine = VALUES(fine)",
						values = {
							data.data.SID,
							math.ceil(data.parole["end"]),
							data.parole.total,
							data.parole.parole,
							data.parole.sentence,
							data.parole.fine
						}
					})
				end

				table.insert(transactions, {
					query = "UPDATE mdt_warrants SET state = ? WHERE report = ? AND suspect = ?",
					values = {
						"served",
						data.report,
						data.data.id,
					}
				})

				MySQL.transaction.await(transactions)

				if data.sentence.revoke or data.points > 0 then
					local character = MySQL.single.await('SELECT Licenses FROM characters WHERE SID = ?',
						{ data.data.SID })
					if character then
						local licenses = json.decode(character.Licenses) or {}

						if data.points > 0 then
							licenses.Drivers = licenses.Drivers or {}
							licenses.Drivers.Points = (licenses.Drivers.Points or 0) + data.points
						end

						if data.sentence.revoke then
							for k, v in pairs(data.sentence.revoke) do
								if v then
									licenses[k] = licenses[k] or {}
									if k == 'drivers' then
										licenses.Drivers = licenses.Drivers or {}
										licenses.Drivers.Active = false
										licenses.Drivers.Suspended = true
									elseif k == 'weapons' then
										licenses.Weapons = licenses.Weapons or {}
										licenses.Weapons.Active = false
										licenses.Weapons.Suspended = true
									elseif k == 'hunting' then
										licenses.Hunting = licenses.Hunting or {}
										licenses.Hunting.Active = false
										licenses.Hunting.Suspended = true
									elseif k == 'fishing' then
										licenses.Fishing = licenses.Fishing or {}
										licenses.Fishing.Active = false
										licenses.Fishing.Suspended = true
									end
								end
							end
						end

						MySQL.update.await('UPDATE characters SET Licenses = ? WHERE SID = ?', {
							json.encode(licenses),
							data.data.SID
						})

						local char = exports['pulsar-characters']:FetchBySID(data.data.SID)
						if char then
							char:SetData('Licenses', licenses)
						end
					end
				end
				cb(true)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:OverturnSentence", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if CheckMDTPermissions(source, "DOJ_OVERTURN_CHARGES") and data.report and data.SID then
			exports['pulsar-core']:LoggerWarn(
				"MDT",
				string.format(
					"%s %s (%s) Overturned Charges From State ID %s on Report %s",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					data.SID,
					data.report
				),
				{
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
					},
				}
			)

			MySQL.query.await(
				"UPDATE mdt_reports_people SET type = ? WHERE report = ? AND type = ? AND SID = ? AND sentenced = ?", {
					"suspectOverturned",
					data.report,
					"suspect",
					data.SID,
					1
				})

			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:RosterView", function(source, data, cb)
		local query = [[
			SELECT Mugshot, First, Last, SID, Callsign, Jobs
			FROM characters
		]]

		MySQL.Async.fetchAll(query, {}, function(results)
			if results then
				local formattedResults = {}
				for _, result in ipairs(results) do
					local jobs = json.decode(result.Jobs)
					for _, job in ipairs(jobs) do
						if job.Id == data.job then
							table.insert(formattedResults, {
								Mugshot = result.Mugshot,
								First = result.First,
								Last = result.Last,
								SID = result.SID,
								Callsign = result.Callsign,
								Jobs = jobs
							})
							break
						end
					end
				end
				cb(formattedResults)
			else
				cb({})
			end
		end)
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:RosterSelect", function(source, data, cb)
		local query = [[
			SELECT Mugshot, First, Last, SID, Callsign, MDTSuspension, MDTSystemAdmin, Qualifications, Phone, TimeClockedOn, LastClockOn, Jobs
			FROM characters
			WHERE SID = @sid
		]]

		local params = {
			['@sid'] = data.person
		}

		MySQL.Async.fetchAll(query, params, function(results)
			if results and #results > 0 then
				local character = results[1]
				local jobs = json.decode(character.Jobs)
				local jobFound = false

				if character.Qualifications then
					character.Qualifications = json.decode(character.Qualifications)
					if type(character.Qualifications) == "table" and not character.Qualifications[1] then
						local quals = {}
						for k, v in pairs(character.Qualifications) do
							table.insert(quals, k)
						end
						character.Qualifications = quals
					elseif type(character.Qualifications) ~= "table" then
						character.Qualifications = {}
					end
				end

				for _, job in ipairs(jobs) do
					if job.Id == data.job then
						jobFound = job
						break
					end
				end

				if jobFound then
					character.Jobs = { jobFound }
					cb(character)
				else
					cb(false)
				end
			else
				cb(false)
			end
		end)
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:RevokeLicenseSuspension", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if CheckMDTPermissions(source, 'REVOKE_LICENSE_SUSPENSIONS') then
			local character = MySQL.single.await('SELECT Licenses FROM characters WHERE SID = ?', { data.SID })
			if character then
				local licenses = json.decode(character.Licenses) or {}
				local canUpdate = false

				for k, v in pairs(data.unsuspend) do
					if v then
						canUpdate = true
						licenses[k] = licenses[k] or {}
						licenses[k].Active = false
						licenses[k].Suspended = false

						if k == 'Drivers' then
							licenses.Drivers = licenses.Drivers or {}
							licenses.Drivers.Active = true
							licenses.Drivers.Points = 0
						end
					end
				end

				if canUpdate then
					exports['pulsar-core']:LoggerWarn(
						"MDT",
						string.format(
							"%s %s (%s) Revoked License Suspensions: %s From State ID %s",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID"),
							json.encode(data.unsuspend),
							data.SID
						),
						{
							console = true,
							file = true,
							database = true,
							discord = {
								embed = true,
							},
						}
					)

					MySQL.update.await('UPDATE characters SET Licenses = ? WHERE SID = ?', {
						json.encode(licenses),
						data.SID
					})

					local char = exports['pulsar-characters']:FetchBySID(data.SID)
					if char then
						char:SetData('Licenses', licenses)
					end
					cb(licenses)
				else
					cb(false)
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:RemoveLicensePoints", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if CheckMDTPermissions(source, 'REVOKE_LICENSE_SUSPENSIONS') and data.SID and data.newPoints then
			exports['pulsar-core']:LoggerWarn(
				"MDT",
				string.format(
					"%s %s (%s) Changed License Points of State ID %s to %s",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID"),
					data.SID,
					data.newPoints
				),
				{
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
					},
				}
			)

			local character = MySQL.single.await('SELECT Licenses FROM characters WHERE SID = ?', { data.SID })
			if character then
				local licenses = json.decode(character.Licenses) or {}
				licenses.Drivers = licenses.Drivers or {}
				licenses.Drivers.Points = data.newPoints

				MySQL.update.await('UPDATE characters SET Licenses = ? WHERE SID = ?', {
					json.encode(licenses),
					data.SID
				})

				local char = exports['pulsar-characters']:FetchBySID(data.SID)
				if char then
					char:SetData('Licenses', licenses)
				end
				cb(licenses)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:ClearCriminalRecord", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char and CheckMDTPermissions(source, 'EXPUNGEMENT') and data.SID then
			local u = MySQL.query.await(
				"UPDATE mdt_reports_people SET expunged = ? WHERE type = ? AND sentenced = ? AND SID = ?", {
					1,
					"suspect",
					1,
					data.SID
				})

			if u and u.affectedRows > 0 then
				exports['pulsar-core']:LoggerWarn(
					"MDT",
					string.format(
						"%s %s (%s) Expunged %s Incidents From State ID %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						u.affectedRows,
						data.SID
					),
					{
						console = true,
						file = true,
						database = true,
						discord = {
							embed = true,
						},
					}
				)
			end
			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:OpenEvidenceLocker", function(source, reportId, cb)
	    local char = exports['pulsar-characters']:FetchCharacterSource(source)
	    if char and (
	        exports['pulsar-jobs']:HasJob(source, 'police', nil, nil, nil, true) or
	        exports['pulsar-jobs']:HasJob(source, 'ems', nil, nil, nil, true) or
	        exports['pulsar-jobs']:HasJob(source, 'prison', nil, nil, nil, true)
	    ) then
	        exports.ox_inventory:forceOpenInventory(source, 'policeevidence', reportId)
	        cb(true)
	    else
	        cb(false)
	    end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:OpenPersonalLocker", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and (exports['pulsar-jobs']:HasJob(source, 'police') or exports['pulsar-jobs']:HasJob(source, 'ems') or exports['pulsar-jobs']:HasJob(source, 'prison')) then
			cb(true)

			exports["pulsar-core"]:ClientCallback(source, "Inventory:Compartment:Open", {
				invType = 45,
				owner = ("pdlocker:%s"):format(char:GetData('SID')),
			}, function()
				exports.ox_inventory:OpenSecondary(source, 45, ("pdlocker:%s"):format(char:GetData('SID')))
			end)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:DOCGetPrisoners", function(source, data, cb)
		cb(exports['pulsar-jail']:GetPrisoners())
	end)

	exports["pulsar-core"]:RegisterServerCallback("MDT:DOCReduceSentence", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and CheckMDTPermissions(source, 'DOC_REDUCTION') and data.reduction then
			local target = exports['pulsar-characters']:FetchBySID(data.SID)
			if target then
				if exports['pulsar-jail']:Reduce(target:GetData("Source"), data.reduction) then
					exports['pulsar-core']:LoggerWarn(
						"MDT",
						string.format(
							"%s %s (%s) Reduced %s %s (%s) Prison Sentence By %s Months",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID"),
							target:GetData("First"),
							target:GetData("Last"),
							target:GetData("SID"),
							data.reduction
						),
						{
							console = true,
							file = true,
							database = true,
							discord = {
								embed = true,
							},
						}
					)
					cb(true)
				else
					cb(false)
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	local vCooldowns = {}
	exports["pulsar-core"]:RegisterServerCallback("MDT:DOCRequestVisitation", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and (vCooldowns[source] == nil or vCooldowns[source] <= os.time()) and data.SID then
			local target = exports['pulsar-characters']:FetchBySID(data.SID)
			if target then
				local jailed = target:GetData("Jailed")
				if jailed and not jailed.Released then
					local dutyData = exports['pulsar-jobs']:DutyGetDutyData("prison")
					if dutyData and dutyData.Count > 0 then
						exports['pulsar-mdt']:EmergencyAlertsCreate(
							"DOC",
							"Visition Request from Lobby",
							"doc_alerts",
							{
								street1 = "Bolingbroke Penitentiary",
								x = 1852.444,
								y = 2585.973,
								z = 45.672
							},
							{
								details = string.format("Request to Visit %s %s (%s)", target:GetData("First"),
									target:GetData("Last"), target:GetData("SID")),
								icon = "info",
							},
							false,
							false,
							nil,
							false
						)
						vCooldowns[source] = os.time() + (3 * 60)
						cb({ success = true })
					else
						cb({
							success = false,
							message = "No DOC Available"
						})
					end
				else
					cb({ success = false })
				end
			else
				cb({ success = false })
			end
		else
			cb({
				success = false,
				message = "Please Wait Before Requesting Again"
			})
		end
	end)
end)

exports.ox_inventory:registerHook('buyItem', function(payload)
	if payload.itemName and payload.metadata.serial and (payload.metadata.registered or payload.fromSlot.metadata.registered) then
		local char = exports['pulsar-characters']:FetchCharacterSource(payload.source)

		if char then
			local firstName = char:GetData('First')
			local lastName = char:GetData('Last')
			local sid = char:GetData('SID')

			exports['pulsar-mdt']:FirearmRegister(
				payload.metadata.serial,
				payload.itemName,
				sid,
				firstName .. ' ' .. lastName
			)
		end
	end

	return true
end)

exports.ox_inventory:registerHook('createItem', function(payload)
	if payload.item.name:find('WEAPON_') and payload.metadata.serial then
		local char = exports['pulsar-characters']:FetchCharacterSource(payload.inventoryId)

		if char then
			local firstName = char:GetData('First')
			local lastName = char:GetData('Last')
			local sid = char:GetData('SID')

			exports['pulsar-mdt']:FirearmRegister(
				payload.metadata.serial,
				payload.item.name,
				sid,
				firstName .. ' ' .. lastName
			)
		end
	end

	return true
end)
