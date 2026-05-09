LAPTOP_APPS = {}

exports('UpdateJobData', function(source, returnValues)
	local charJobs = exports['pulsar-jobs']:GetJobs(source)
	local charJobPerms = {}
	local jobData = {}
	if charJobs and #charJobs > 0 then
		for k, v in ipairs(charJobs) do
			local perms = GlobalState[string.format(
				"JobPerms:%s:%s:%s",
				v.Id,
				(v.Workplace and v.Workplace.Id or false),
				v.Grade.Id
			)]
			if perms then
				charJobPerms[v.Id] = perms
			end
			local jobInfo = exports['pulsar-jobs']:Get(v.Id)
			if jobInfo then
				table.insert(jobData, jobInfo)
			end
		end
	end

	if returnValues then
		return {
			charJobPerms = charJobPerms,
			jobData = jobData,
		}
	end

	TriggerClientEvent("Laptop:Client:SetData", source, "JobPermissions", charJobPerms)
	TriggerClientEvent("Laptop:Client:SetData", source, "JobData", jobData)
end)

exports('AddNotification', function(source, title, description, time, duration, app, actions, notifData)
	TriggerClientEvent(
		"Laptop:Client:Notifications:Add",
		source,
		title,
		description,
		time,
		duration,
		app,
		actions,
		notifData
	)
end)

exports('AddNotificationWithId', function(source, id, title, description, time, duration, app, actions, notifData)
	TriggerClientEvent(
		"Laptop:Client:Notifications:AddWithId",
		source,
		id,
		title,
		description,
		time,
		duration,
		app,
		actions,
		notifData
	)
end)

exports('UpdateNotification', function(source, id, title, description, skipSound)
	TriggerClientEvent("Laptop:Client:Notifications:Update", source, id, title, description, skipSound)
end)

exports('RemoveNotificationById', function(source, id)
	TriggerClientEvent("Laptop:Client:Notifications:Remove", source, id)
end)
