PHONE_APPS = {}
local usedNumbersCache = {}

exports("UpdateJobData", function(source, returnValues)
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
			table.insert(jobData, exports['pulsar-jobs']:Get(v.Id))
		end
	end

	if returnValues then
		return {
			charJobPerms = charJobPerms,
			jobData = jobData,
		}
	end

	TriggerLatentClientEvent("Phone:Client:SetDataMulti", source, 50000, {
		{
			type = "JobPermissions",
			data = charJobPerms,
		},
		{
			type = "JobData",
			data = jobData,
		},
	})
end)

exports("NotificationAdd", function(source, title, description, time, duration, app, actions, notifData)
	TriggerClientEvent(
		"Phone:Client:Notifications:Add",
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

exports("NotificationAddWithId", function(source, id, title, description, time, duration, app, actions, notifData)
	TriggerClientEvent(
		"Phone:Client:Notifications:AddWithId",
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

exports("NotificationUpdate", function(source, id, title, description)
	TriggerClientEvent("Phone:Client:Notifications:Update", source, id, title, description)
end)

exports("NotificationRemoveById", function(source, id)
	TriggerClientEvent("Phone:Client:Notifications:Remove", source, id)
end)

exports("GeneratePhoneNumber", function()
	local pNumber = GeneratePhoneNumber()
	while IsNumberInUse(pNumber) do
		pNumber = GeneratePhoneNumber()
	end

	usedNumbersCache[pNumber] = true

	return pNumber
end)

function IsNumberInUse(number)
	if _bizPhoneNumbersCheck[number] or usedNumbersCache[number] then
		return true
	end

	local result = MySQL.single.await([[SELECT `Phone` FROM `characters` WHERE `Phone` = @Phone]],
		{ ["@Phone"] = number })
	if result == nil then
		return false
	end
	return true
end

function GeneratePhoneNumber()
	local phone = ""

	for i = 1, 10, 1 do
		local d = math.random(0, 9)
		phone = phone .. d

		if i == 3 or i == 6 then
			phone = phone .. "-"
		end
	end

	return phone
end

-- Media
_limitCount = 10

exports("PhotosCreate", function(source, photo)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil and type(photo) == "table" then
		photo.sid = char:GetData("SID")
		photo.time = os.time()
		photo.id = MySQL.insert.await("INSERT INTO character_photos (sid, image_url) VALUES(?, ?)", {
			char:GetData("SID"),
			photo.image_url,
		})

		return photo
	end
	return false
end)

exports("PhotosFetch", function(source)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local retval =
			MySQL.rawExecute.await("SELECT * FROM character_photos WHERE sid = ? ORDER BY time DESC LIMIT ?", {
				char:GetData("SID"),
				_limitCount,
			})

		return retval
	end
	return false
end)

exports("PhotosDelete", function(source, id)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local retval = MySQL.rawExecute.await("DELETE FROM character_photos WHERE id = ?", {
			id,
		})
		if retval then
			-- print("deleted", id)
			--TriggerClientEvent("Phone:Client:Documents:Deleted", char:GetData("Source"), id)
		end
		return true
	end
	return false
end)
