local _blacklistedJobs = { "police", "ems", "government" }
local _tabletJobs = {
	"pdm",
	"realestate",
	"redline",
	"hayes",
	"ottos",
	"autoexotics",
	"autocare",
	"securoserv",
	"bennys",
	"casino",
	"burgershot",
	"rustybrowns",
	"demonetti_storage",
	"tuna",
	"pepega_pawn",
	"garcon_pawn",
	"harmony",
	"mba",
	"paleto_tuners",
	"pizza_this",
	"beanmachine",
	"cloud9",
	"uwu",
	"jewel",
	"vangelico",
	"vangelico_grapeseed",
	"tequila",
	"prego",
	"bakery",
	"noodle",
	"lasttrain",
	"rockford_records",
	"tacoshop",
	"unicorn",
	"bowling",
	"dreamworks",
}

local _jobPerms = {
	JOB_MANAGEMENT = {
		name = "Manage Company",
		restricted = false, -- Array of Jobs (or false)
	},
	JOB_MANAGE_EMPLOYEES = {
		name = "Manage/Promote Employees",
		restricted = false,
	},
	JOB_FIRE = {
		name = "Fire Employees",
		restricted = false,
	},
	JOB_HIRE = {
		name = "Hire Employees",
		restricted = false,
	},
	JOB_STORAGE = {
		name = "Access Company Storage",
		restricted = false,
	},
	JOB_ACCESS_SAFE = {
		name = "Access Safe",
		restricted = false,
	},
	JOB_CRAFTING = {
		name = "Access Crafting",
		restricted = false,
	},
	JOB_SHOP = {
		name = "Stock Business Shop",
		restricted = false,
	},
	JOB_SHOP_CONTROL = {
		name = "Open/Close Business Shop",
		restricted = false,
	},
	BANK_ACCOUNT_BILL = {
		name = "Bank Account - Send Bills",
		restricted = false,
	},
	BANK_ACCOUNT_MANAGE = {
		name = "Bank Account - Manage",
		restricted = false,
	},
	BANK_ACCOUNT_WITHDRAW = {
		name = "Bank Account - Withdraw",
		restricted = false,
	},
	BANK_ACCOUNT_DEPOSIT = {
		name = "Bank Account - Deposit",
		restricted = false,
	},
	BANK_ACCOUNT_TRANSACTIONS = {
		name = "Bank Account - View Transactions",
		restricted = false,
	},
	BANK_ACCOUNT_BALANCE = {
		name = "Bank Account - View Balance",
		restricted = false,
	},
	FLEET_VEHICLES_0 = {
		name = "Access Fleet Vehicles",
		restrict = false,
	},
	-- FLEET_VEHICLES_1 = {
	-- 	name = "Fleet Vehicles Level 2",
	-- 	restrict = false,
	-- },
	-- FLEET_VEHICLES_2 = {
	-- 	name = "Fleet Vehicles Level 3",
	-- 	restrict = false,
	-- },
	-- FLEET_VEHICLES_3 = {
	-- 	name = "Fleet Vehicles Level 4",
	-- 	restrict = false,
	-- },
	-- FLEET_VEHICLES_4 = {
	-- 	name = "Fleet Vehicles Level 5",
	-- 	restrict = false,
	-- },
	FLEET_MANAGEMENT = {
		name = "Manage Vehicle Fleet",
		restrict = false,
	},

	dealership_stock = {
		name = "Dealership - Stocks",
		restricted = { "pdm", "redline", "tuna" },
	},
	dealership_showroom = {
		name = "Dealership - Showroom",
		restricted = { "pdm", "redline", "tuna" },
	},
	dealership_sell = {
		name = "Dealership - Sales",
		restricted = { "pdm", "redline", "tuna" },
	},
	dealership_testdrive = {
		name = "Dealership - Test Drive",
		restricted = { "pdm", "redline", "tuna" },
	},
	dealership_manage = {
		name = "Dealership - Manage",
		restricted = { "pdm", "redline", "tuna" },
	},
	dealership_buyback = {
		name = "Dealership - Buy Back Vehicle",
		restricted = { "pdm", "redline", "tuna" },
	},
	JOB_USE_WHOLESALER = {
		name = "Access Food Wholesaler",
		restricted = {
			"uwu",
			"pizza_this",
			"burgershot",
			"rustybrowns",
			"bowling",
			"beanmachine",
			"lasttrain",
			"tequila",
			"unicorn",
			"bahama",
			"dgang",
			"bakery",
			"noodle",
			"triad",
			"prego",
			"mba",
			"casino",
			"rockford_records",
			"woods_saloon",
		},
	},
	JOB_DOORS = {
		name = "Access Doors",
		restricted = {
			"realestate",
			"unicorn",
			"bahama",
			"lsfc",
		},
	},
	JOB_DRIFT_LICENSE = {
		name = "Manage Drift Licenses",
		restricted = {
			"cloud9",
		},
	},
	STRIP_POLE = {
		name = "Use Strip Pole",
		restricted = {
			"unicorn",
			"bahama",
		},
	},
	JOB_SELL = {
		name = "Sell Property",
		restricted = {
			"realestate",
		},
	},
	JOB_USE_GEM_TABLE = {
		name = "Use Gem Table",
		restricted = {
			"sagma",
			"jewel",
			"vangelico",
			"vangelico_grapeseed",
		},
	},
	JOB_USE_JEWELRY_CRAFTING = {
		name = "Use Jewelry Crafting",
		restricted = {
			"sagma",
			"jewel",
			"vangelico",
			"vangelico_grapeseed",
		},
	},
	JOB_SELL_GEMS = {
		name = "Use Gem Seller",
		restricted = {
			"sagma",
			"jewel",
			"vangelico",
			"vangelico_grapeseed",
		},
	},
	JOB_SET_MBA = {
		name = "Set Mazebank Interior",
		restricted = {
			"mba",
		},
	},
	TABLET_CREATE_NOTICE = {
		name = "Tablet - Create Notice",
		restricted = _tabletJobs,
	},
	TABLET_DELETE_NOTICE = {
		name = "Tablet - Delete Notice",
		restricted = _tabletJobs,
	},
	TABLET_CREATE_DOCUMENT = {
		name = "Tablet - Create Document",
		restricted = _tabletJobs,
	},
	TABLET_VIEW_DOCUMENT = {
		name = "Tablet - View Document",
		restricted = _tabletJobs,
	},
	TABLET_PIN_DOCUMENT = {
		name = "Tablet - Pin Document",
		restricted = _tabletJobs,
	},
	TABLET_DELETE_DOCUMENT = {
		name = "Tablet - Delete Document",
		restricted = _tabletJobs,
	},
	TABLET_CREATE_RECEIPT = {
		name = "Tablet - Create Receipt",
		restricted = _tabletJobs,
	},
	TABLET_MANAGE_RECEIPT = {
		name = "Tablet - Manage Receipts",
		restricted = _tabletJobs,
	},
	TABLET_CLEAR_RECEIPT = {
		name = "Tablet - Clear All Receipts",
		restricted = _tabletJobs,
	},
	TABLET_TWEET = {
		name = "Business Tweet",
		restricted = false,
	},
	CASINO_LOCK_DOORS = {
		name = "Casino - Lock Doors",
		restricted = { "casino" },
	},
	CASINO_LOCK_ELEVATOR = {
		name = "Casino - Lock Elevators",
		restricted = { "casino" },
	},
	PREGO_BASEMENT = {
		name = "Cafe Prego - Access Basement",
		restricted = { "prego" },
	},
	UNIT_SELL = {
		name = "Storage Units - Sell",
		restricted = { "dgang", "demonetti_storage" },
	},

	SECONDARY_BANK_ACCOUNT_BILL = {
		name = "2nd Bank Account - Send Bills",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
	SECONDARY_BANK_ACCOUNT_MANAGE = {
		name = "2nd Bank Account - Manage",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
	SECONDARY_BANK_ACCOUNT_WITHDRAW = {
		name = "2nd Bank Account - Withdraw",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
	SECONDARY_BANK_ACCOUNT_DEPOSIT = {
		name = "2nd Bank Account - Deposit",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
	SECONDARY_BANK_ACCOUNT_TRANSACTIONS = {
		name = "2nd Bank Account - View Transactions",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
	SECONDARY_BANK_ACCOUNT_BALANCE = {
		name = "2nd Bank Account - View Balance",
		restricted = { "pepega_pawn", "garcon_pawn", "paleto_tuners" },
	},
}

local _pendingHires = {}
local _pendingXfers = {}

exports("CoManagerFetchAllAccessibleRosters", function(source)
	local success, result = pcall(function()
		local playersJobs = exports['pulsar-jobs']:GetJobs(source)
		local fetchedRosterData = {}
		local fetchingJobs = {}
		for k, v in ipairs(playersJobs) do
			if not hasValue(_blacklistedJobs, v.Id) then
				fetchingJobs[v.Id] = true
				fetchedRosterData[v.Id] = {}
			end
		end

		local onlineCharacters = {}
		for _, char in pairs(exports['pulsar-characters']:FetchAllCharacters()) do
			if char ~= nil then
				table.insert(onlineCharacters, char:GetData("SID"))
				local jobs = char:GetData("Jobs")
				if jobs and #jobs > 0 then
					for k, v in ipairs(jobs) do
						if fetchingJobs[v.Id] then
							table.insert(fetchedRosterData[v.Id], {
								Source = char:GetData("Source"),
								SID = char:GetData("SID"),
								First = char:GetData("First"),
								Last = char:GetData("Last"),
								Phone = char:GetData("Phone"),
								JobData = v,
							})
						end
					end
				end
			end
		end

		local results
		if #onlineCharacters > 0 then
			local placeholders = {}
			for i = 1, #onlineCharacters do
				table.insert(placeholders, "?")
			end
			local query = 'SELECT SID, First, Last, Phone, Jobs FROM characters WHERE SID NOT IN (' ..
				table.concat(placeholders, ',') .. ')'
			results = MySQL.Sync.fetchAll(query, onlineCharacters)
		else
			results = MySQL.Sync.fetchAll('SELECT SID, First, Last, Phone, Jobs FROM characters')
		end

		if results and #results > 0 then
			for _, c in ipairs(results) do
				local jobs = {}
				if c.Jobs and c.Jobs ~= "" then
					local success, decoded = pcall(json.decode, c.Jobs)
					if success and decoded then
						jobs = decoded
					else
						jobs = {}
					end
				end

				if jobs and #jobs > 0 then
					for _, job in ipairs(jobs) do
						if fetchingJobs[job.Id] then
							if not fetchedRosterData[job.Id] then
								fetchedRosterData[job.Id] = {}
							end

							table.insert(fetchedRosterData[job.Id], {
								Source = false,
								SID = c.SID,
								First = c.First,
								Last = c.Last,
								Phone = c.Phone,
								JobData = job,
							})
						end
					end
				end
			end
		end

		local hasData = false
		for jobId, roster in pairs(fetchedRosterData) do
			if #roster > 0 then
				hasData = true
				break
			end
		end

		if hasData then
			return fetchedRosterData
		else
			return false
		end
	end)

	if success then
		return result
	else
		return false
	end
end)

exports("CoManagerFetchTimeWorked", function(source, jobId)
	local jobData = exports['pulsar-jobs']:HasJob(source, jobId, false, false, false, false, "JOB_MANAGEMENT")
	if jobData then
		local onlineCharacters = {}

		local onlineShit = {}

		for _, char in pairs(exports['pulsar-characters']:FetchAllCharacters()) do
			if char ~= nil then
				table.insert(onlineCharacters, char:GetData("SID"))
				local jobs = char:GetData("Jobs")
				if jobs and #jobs > 0 then
					for k, v in ipairs(jobs) do
						if v.Id == jobId then
							table.insert(onlineShit, {
								Source = char:GetData("Source"),
								SID = char:GetData("SID"),
								First = char:GetData("First"),
								Last = char:GetData("Last"),
								Phone = char:GetData("Phone"),
								LastClockOn = char:GetData("LastClockOn"),
								TimeClockedOn = char:GetData("TimeClockedOn"),
							})
						end
					end
				end
			end
		end

		local results
		if #onlineCharacters > 0 then
			local placeholders = {}
			for i = 1, #onlineCharacters do
				table.insert(placeholders, "?")
			end
			local query =
				'SELECT SID, First, Last, Phone, LastClockOn, TimeClockedOn, Jobs FROM characters WHERE SID NOT IN (' ..
				table.concat(placeholders, ',') .. ')'
			results = MySQL.Sync.fetchAll(query, onlineCharacters)
		else
			results = MySQL.Sync.fetchAll(
				'SELECT SID, First, Last, Phone, LastClockOn, TimeClockedOn, Jobs FROM characters')
		end

		if results and #results > 0 then
			for _, c in ipairs(results) do
				local jobs = {}
				if c.Jobs and c.Jobs ~= "" then
					local success, decoded = pcall(json.decode, c.Jobs)
					if success and decoded then
						jobs = decoded
					else
						jobs = {}
					end
				end
				if jobs and #jobs > 0 then
					for _, job in ipairs(jobs) do
						if job.Id == jobId then
							table.insert(onlineShit, {
								Source = false,
								SID = c.SID,
								First = c.First,
								Last = c.Last,
								Phone = c.Phone,
								LastClockOn = c.LastClockOn,
								TimeClockedOn = c.TimeClockedOn,
							})
						end
					end
				end
			end
		end

		if #onlineShit > 0 then
			return onlineShit
		else
			return false
		end
	else
		return false
	end
end)

function GetOfflineCharacter(stateId)
	local p = promise.new()

	MySQL.Async.fetchAll('SELECT * FROM characters WHERE SID = @stateId', {
		['@stateId'] = stateId
	}, function(results)
		if results[1] then
			p:resolve(results[1])
		else
			p:resolve(false)
		end
	end)

	local res = Citizen.Await(p)
	return res
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	local data = _pendingHires[cData.SID]
	if data then
		TriggerClientEvent("Phone:Client:CoManager:GetOfferResult", data.HiredBy, os.time(), false)
		_pendingHires[cData.SID] = nil
	end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	local data = _pendingHires[cData.SID]
	if data then
		TriggerClientEvent("Phone:Client:CoManager:GetOfferResult", data.HiredBy, os.time(), false)
		_pendingHires[cData.SID] = nil
	end
end)

AddEventHandler("Phone:Server:RegisterMiddleware", function()
	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if _pendingHires[char:GetData("SID")] ~= nil then
			local data = _pendingHires[char:GetData("SID")]
			TriggerClientEvent("Phone:Client:CoManager:GetJobOffer", source, data.time, data.NewJob)
		end
	end, 2)
	exports['pulsar-core']:MiddlewareAdd("Phone:Spawning", function(source, char)
		return {
			{
				type = "externalJobs",
				data = _blacklistedJobs,
			},
			{
				type = "NamedJobPermissions",
				data = _jobPerms,
			},
		}
	end)
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:QuitJob", function(source, data, cb)
		local jobId = data.JobId

		if jobId and not hasValue(_blacklistedJobs, jobId) then
			if exports['pulsar-jobs']:IsOwner(source, jobId) then
				return cb({ success = false, code = "IS_OWNER" })
			else
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if char then
					local success = exports['pulsar-jobs']:RemoveJob(char:GetData("SID"), jobId)
					if success then
						return cb({ success = true, code = "ERROR" })
					end
				end
			end
		end
		return cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:FetchRoster", function(source, data, cb)
		if data.ReqUpdate then
			local updatedJobData = exports['pulsar-phone']:UpdateJobData(source, true)
			cb({
				jobData = updatedJobData.jobData,
				rosterData = exports['pulsar-phone']:CoManagerFetchAllAccessibleRosters(source),
			})
		else
			cb({
				rosterData = exports['pulsar-phone']:CoManagerFetchAllAccessibleRosters(source),
			})
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:FetchTimeWorked", function(source, data, cb)
		cb(exports['pulsar-phone']:CoManagerFetchTimeWorked(source, data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:RenameCompany", function(source, data, cb)
		local jobId, newName = data.JobId, data.NewName

		if jobId and newName and not hasValue(_blacklistedJobs, jobId) then
			if exports['pulsar-jobs']:IsOwner(source, jobId) then
				local res = exports['pulsar-jobs']:ManagementEdit(jobId, {
					Name = newName,
				})

				cb(res)
			else
				cb({ success = false, code = "INVALID_PERMISSIONS" })
			end
		else
			cb({ success = false, code = "ERROR" })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:HireEmployee", function(source, data, cb)
		local stateId, jobId, workplace, grade =
			math.tointeger(data.SID), data.Job.Id, data.Job.Workplace, data.Job.Grade

		if
			(not workplace or (workplace and workplace.Id))
			and grade
			and grade.Id
			and exports['pulsar-jobs']:DoesExist(jobId, (workplace and workplace.Id or false), grade.Id)
		then
			local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
			local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
			local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)
			if (playerJobPerms and (playerJobPerms.JOB_HIRE or playerJobPerms.JOB_MANAGEMENT)) or playerIsOwner then
				if (playerJobData.Grade.Level > grade.Level) or playerIsOwner then
					local targetChar = exports['pulsar-characters']:FetchBySID(stateId)

					if targetChar then
						local time = os.time()
						local stateId = targetChar:GetData("SID")

						local targetCharJobs = targetChar:GetData("Jobs")

						if targetCharJobs and #targetCharJobs > 0 then
							for k, v in ipairs(targetCharJobs) do
								if v.Id == jobId then
									return cb({ success = false, code = "ERROR" })
								end
							end
						end

						if not _pendingHires[stateId] or (os.time() - _pendingHires[stateId].time) >= 300 then
							local hireData = {
								time = time,
								HiredBy = source,
								NewJob = {
									Id = playerJobData.Id,
									Name = playerJobData.Name,
									Workplace = workplace,
									Grade = grade,
								},
							}

							_pendingHires[stateId] = hireData

							TriggerClientEvent(
								"Phone:Client:CoManager:GetJobOffer",
								targetChar:GetData("Source"),
								time,
								hireData.NewJob
							)
							cb({ success = true })
						else
							return cb({ success = false, code = "OUTSTANDING_OFFER" })
						end
					end
					return cb({ success = false, code = "INVALID_TARGET" })
				end
			end
			return cb({ success = false, code = "INVALID_PERMISSIONS" })
		end
		return cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:FireEmployee", function(source, data, cb)
		local stateId, jobId = math.tointeger(data.SID), data.Job.Id

		if stateId and jobId then
			local job = exports['pulsar-jobs']:Get(jobId)
			local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
			local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
			local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)
			if (playerJobPerms and (playerJobPerms.JOB_FIRE or playerJobPerms.JOB_MANAGEMENT)) or playerIsOwner then
				if job.Owner and job.Owner == stateId then
					return cb({ success = false, code = "INVALID_PERMISSIONS" })
				end

				local targetJobData = false
				local targetChar = exports['pulsar-characters']:FetchBySID(stateId)

				if targetChar then
					targetJobData = targetChar:GetData("Jobs")
				else
					local offlineChar = GetOfflineCharacter(stateId)
					if offlineChar then
						targetJobData = offlineChar.Jobs
					end
				end

				if targetJobData then
					local canRemoveJob = false
					for k, v in ipairs(targetJobData) do
						if v.Id == playerJobData.Id then
							if v.Grade.Level < playerJobData.Grade.Level then
								canRemoveJob = true
							end
							break
						end
					end

					if canRemoveJob then
						local success = exports['pulsar-jobs']:RemoveJob(stateId, playerJobData.Id)
						return cb({ success = success, code = "ERROR" })
					else
						return cb({ success = false, code = "INVALID_PERMISSIONS" })
					end
				else
					return cb({ success = false, code = "INVALID_TARGET" })
				end
			end
			return cb({ success = false, code = "INVALID_PERMISSIONS" })
		end
		return cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:UpdateEmployee", function(source, data, cb)
		local stateId, jobId, workplace, grade =
			math.tointeger(data.SID), data.Job.Id, data.Job.Workplace, data.Job.Grade
		if
			(not workplace or (workplace and workplace.Id) and grade and grade.Id)
			and exports['pulsar-jobs']:DoesExist(jobId, (workplace and workplace.Id or false), grade.Id)
		then
			local job = exports['pulsar-jobs']:Get(jobId)
			local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
			local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
			local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)
			if
				(playerJobPerms and (playerJobPerms.JOB_MANAGE_EMPLOYEES or playerJobPerms.JOB_MANAGEMENT))
				or playerIsOwner
			then
				if job.Owner and job.Owner == stateId then
					return cb({ success = false, code = "INVALID_PERMISSIONS" })
				end

				if (playerJobData.Grade.Level > grade.Level) or playerIsOwner then
					local targetChar = exports['pulsar-characters']:FetchBySID(stateId)
					local targetJobData = false

					if targetChar then
						targetJobData = targetChar:GetData("Jobs")
					else
						local offlineChar = GetOfflineCharacter(stateId)
						if offlineChar then
							targetJobData = offlineChar.Jobs
						end
					end

					if targetJobData then
						local canChangeJob = false
						for k, v in ipairs(targetJobData) do
							if v.Id == playerJobData.Id then
								if (v.Grade.Level < playerJobData.Grade.Level) or playerIsOwner then
									canChangeJob = true
								end
								break
							end
						end

						if canChangeJob then
							local success =
								exports['pulsar-jobs']:GiveJob(stateId, playerJobData.Id,
									(workplace and workplace.Id or false), grade.Id)
							return cb({ success = success, code = "ERROR" })
						else
							return cb({ success = false, code = "INVALID_PERMISSIONS" })
						end
					end

					return cb({ success = false, code = "INVALID_TARGET" })
				end
			end
			return cb({ success = false, code = "INVALID_PERMISSIONS" })
		end
		return cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:EditWorkplace", function(source, data, cb)
		local jobId, workplaceId, newName = data.JobId, data.WorkplaceId, data.NewName

		if jobId and newName and not hasValue(_blacklistedJobs, jobId) then
			if exports['pulsar-jobs']:IsOwner(source, jobId) then
				local res = exports['pulsar-jobs']:ManagementWorkplaceEdit(jobId, workplaceId, newName)
				cb(res)
			else
				cb({ success = false, code = "INVALID_PERMISSIONS" })
			end
		else
			cb({ success = false, code = "ERROR" })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:CreateGrade", function(source, data, cb)
		local jobId, workplaceId, gradeName, gradeLevel, gradePermissions =
			data.JobId, data.WorkplaceId, data.Name, math.tointeger(data.Level), data.Permissions
		if jobId and gradeName and gradeLevel and gradePermissions and not hasValue(_blacklistedJobs, jobId) then
			local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
			local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
			local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)

			for k, v in pairs(gradePermissions) do
				if v and (not playerJobPerms[k] and not playerIsOwner) then
					gradePermissions[k] = false
				end
			end

			if
				((playerJobPerms and playerJobPerms.JOB_MANAGEMENT) and gradeLevel < playerJobData.Grade.Level)
				or playerIsOwner
			then
				local res = exports['pulsar-jobs']:ManagementGradesCreate(jobId, workplaceId, gradeName, gradeLevel,
					gradePermissions)
				return cb(res)
			else
				return cb({ success = false, code = "INVALID_PERMISSIONS" })
			end
		end
		cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:EditGrade", function(source, data, cb)
		local jobId, workplaceId, gradeId, gradeName, gradeLevel, gradePermissions =
			data.JobId, data.WorkplaceId, data.Id, data.Name, tonumber(data.Level), data.Permissions
		if jobId and gradeId and not hasValue(_blacklistedJobs, jobId) then
			local existingGrade = exports['pulsar-jobs']:DoesExist(jobId, workplaceId, gradeId)
			if existingGrade then
				local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
				local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
				local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)

				for k, v in pairs(gradePermissions) do
					if v and (not playerJobPerms[k] and not playerIsOwner) then
						gradePermissions[k] = false
					end
				end

				if
					(
						(playerJobPerms and playerJobPerms.JOB_MANAGEMENT)
						and existingGrade.Grade.Level < playerJobData.Grade.Level
						and gradeLevel < playerJobData.Grade.Level
					) or playerIsOwner
				then
					local res = exports['pulsar-jobs']:ManagementGradesEdit(jobId, workplaceId, gradeId, {
						Name = gradeName,
						Level = gradeLevel,
						Permissions = gradePermissions,
					})

					return cb(res)
				else
					return cb({ success = false, code = "INVALID_PERMISSIONS" })
				end
			end
		end
		cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:DeleteGrade", function(source, data, cb)
		local jobId, workplaceId, gradeId = data.JobId, data.WorkplaceId, data.Id
		if jobId and gradeId and not hasValue(_blacklistedJobs, jobId) then
			local existingGrade = exports['pulsar-jobs']:DoesExist(jobId, workplaceId, gradeId)
			if existingGrade then
				local playerJobData = exports['pulsar-jobs']:HasJob(source, jobId)
				local playerJobPerms = exports['pulsar-jobs']:GetPermissionsFromJob(source, jobId)
				local playerIsOwner = exports['pulsar-jobs']:IsOwner(source, jobId)
				if
					(
						(playerJobPerms and playerJobPerms.JOB_MANAGEMENT)
						and existingGrade.Grade.Level < playerJobData.Grade.Level
					) or playerIsOwner
				then
					local res = exports['pulsar-jobs']:ManagementGradesDelete(jobId, workplaceId, gradeId)
					return cb(res)
				else
					return cb({ success = false, code = "INVALID_PERMISSIONS" })
				end
			end
		end
		cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:PurchaseUpgrade", function(source, data, cb)
		-- TODO
		cb({ success = false, code = "ERROR" })
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:AcceptHire", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			local stateId = char:GetData("SID")
			local data = _pendingHires[stateId]
			if data then
				local success = exports['pulsar-jobs']:GiveJob(
					stateId,
					data.NewJob.Id,
					(data.NewJob.Workplace and data.NewJob.Workplace.Id or false),
					data.NewJob.Grade.Id
				)
				TriggerClientEvent("Phone:Client:CoManager:GetOfferResult", data.HiredBy, os.time(), success)
				_pendingHires[stateId] = nil
				return cb(os.time(), success)
			end
		end
		return cb(os.time(), false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:DeclineHire", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			local stateId = char:GetData("SID")
			local data = _pendingHires[stateId]
			if data then
				TriggerClientEvent("Phone:Client:CoManager:GetOfferResult", data.HiredBy, os.time(), false)
				_pendingHires[stateId] = nil
			end
		end
		cb(os.time())
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:CoManager:DisbandCompany", function(source, data, cb)
		-- ! Disabled
		cb({ success = false, code = "ERROR" })
	end)
end)
