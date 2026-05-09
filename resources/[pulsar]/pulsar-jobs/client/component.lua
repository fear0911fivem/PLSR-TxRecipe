exports("GetJobs", function()
	local char = LocalPlayer.state.Character
	if char then
		local jobs = char:GetData("Jobs") or {}
		return jobs
	end
	return false
end)

exports("HasJob", function(jobId, workplaceId, gradeId, gradeLevel, checkDuty, permissionKey)
	local jobs = exports['pulsar-jobs']:GetJobs()
	for k, v in ipairs(jobs) do
		if v.Id == jobId then
			if not workplaceId or (v.Workplace and v.Workplace.Id == workplaceId) then
				if not gradeId or (v.Grade.Id == gradeId) then
					if not gradeLevel or (v.Grade.Level and v.Grade.Level >= gradeLevel) then
						if not checkDuty or (checkDuty and exports['pulsar-jobs']:DutyGet(jobId)) then
							if
								not permissionKey
								or (permissionKey and exports['pulsar-jobs']:HasPermissionInJob(jobId, permissionKey))
							then
								return v
							end
						end
					end
				end
			end
			break
		end
	end
	return false
end)

exports("GetPermissionsFromJob", function(jobId, workplaceId)
	local jobData = exports['pulsar-jobs']:HasJob(jobId, workplaceId)
	if jobData then
		local perms = GlobalState[string.format(
			"JobPerms:%s:%s:%s",
			jobData.Id,
			(jobData.Workplace and jobData.Workplace.Id or false),
			jobData.Grade.Id
		)]
		if perms then
			return perms
		end
	end
	return false
end)

exports("HasPermissionInJob", function(jobId, permissionKey)
	local permissionsInJob = exports['pulsar-jobs']:GetPermissionsFromJob(jobId)
	if permissionsInJob then
		if permissionsInJob[permissionKey] then
			return true
		end
	end
	return false
end)

exports("HasPermission", function(permissionKey)
	local jobs = exports['pulsar-jobs']:GetJobs()
	if jobs then
		for k, v in ipairs(jobs) do
			if exports['pulsar-jobs']:HasPermissionInJob(v.Id, permissionKey) then
				return true
			end
		end
	end
	return false
end)

exports("DutyOn", function(jobId, cb)
	if jobId then
		if exports['pulsar-jobs']:DutyGet(jobId) then
			exports["pulsar-hud"]:Notification("error", "Already On Duty as that Job")
			if cb then
				cb(false)
			end
			return
		end
	end

	exports["pulsar-core"]:ServerCallback("Jobs:OnDuty", jobId, function(success)
		if cb then
			cb(success)
		end
	end)
end)

exports("DutyOff", function(jobId, cb)
	exports["pulsar-core"]:ServerCallback("Jobs:OffDuty", jobId, function(success)
		if cb then
			cb(success)
		end
	end)
end)

exports("DutyGet", function(jobId)
	if LocalPlayer.state.onDuty then
		if (not jobId) or (jobId == LocalPlayer.state.onDuty) then
			return LocalPlayer.state.onDuty
		end
	end
	return false
end)
