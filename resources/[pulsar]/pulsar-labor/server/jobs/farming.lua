local _JOB = "Farming"

local _joiners = {}
local _farming = {}

AddEventHandler("Labor:Server:Startup", function()
	exports["pulsar-core"]:RegisterServerCallback("Farming:StartJob", function(source, data, cb)
		if _farming[data] ~= nil and _farming[data].state == 0 then
			local randJob = math.random(#availableJobs)

			_farming[data].job = deepcopy(availableJobs[randJob])
			_farming[data].jobs = deepcopy(availableJobs)
			_farming[data].tasks = 0
			_farming[data].nodes =
				deepcopy(availableJobs[randJob].locationSets[math.random(#availableJobs[randJob].locationSets)])

			table.remove(_farming[data].jobs, randJob)
			_farming[data].job.locationSets = nil

			exports['pulsar-labor']:StartOffer(data, _JOB, _farming[data].job.objective, #_farming[data].nodes)
			exports['pulsar-labor']:SendWorkgroupEvent(
				data,
				string.format("Farming:Client:%s:Startup", data),
				_farming[data].nodes,
				_farming[data].job.action,
				_farming[data].job.durationBase,
				_farming[data].job.animation
			)

			_farming[data].state = 1
			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Farming:CompleteNode", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char:GetData("TempJob") == _JOB and _joiners[source] ~= nil and _farming[_joiners[source]] ~= nil then
			for k, v in ipairs(_farming[_joiners[source]].nodes) do
				if v.id == data then
					exports.ox_inventory:LootCustomSetWithCount(_farming[_joiners[source]].job.loot,
						char:GetData("SID"), 1)
					exports['pulsar-labor']:SendWorkgroupEvent(
						_joiners[source],
						string.format("Farming:Client:%s:Action", _joiners[source]),
						data
					)
					table.remove(_farming[_joiners[source]].nodes, k)
					if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
						_farming[_joiners[source]].tasks = _farming[_joiners[source]].tasks + 1

						if _farming[_joiners[source]].tasks < 2 then
							local randJob = math.random(#_farming[_joiners[source]].jobs)
							_farming[_joiners[source]].job = deepcopy(_farming[_joiners[source]].jobs[randJob])
							_farming[_joiners[source]].nodes = deepcopy(
								_farming[_joiners[source]].job.locationSets[math.random(
									#_farming[_joiners[source]].job.locationSets
								)]
							)
							table.remove(_farming[_joiners[source]].jobs, randJob)
							_farming[_joiners[source]].job.locationSets = nil
							exports['pulsar-labor']:StartOffer(
								_joiners[source],
								_JOB,
								_farming[_joiners[source]].job.objective,
								#_farming[_joiners[source]].nodes
							)
							exports['pulsar-labor']:SendWorkgroupEvent(
								_joiners[source],
								string.format("Farming:Client:%s:NewTask", _joiners[source]),
								_farming[_joiners[source]].nodes,
								_farming[_joiners[source]].job.action,
								_farming[_joiners[source]].job.durationBase,
								_farming[_joiners[source]].job.animation
							)
						else
							exports['pulsar-labor']:SendWorkgroupEvent(
								_joiners[source],
								string.format("Farming:Client:%s:EndFarming", _joiners[source])
							)
							_farming[_joiners[source]].state = 2
							exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Return To The Farm Supervisor")
						end
					end
					return
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Farming:TurnIn", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _farming[_joiners[source]] ~= nil
			and _farming[_joiners[source]].state == 2
		then
			_farming[_joiners[source]].state = 3

			exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
			cb(true)
		else
			exports['pulsar-hud']:Notification(source, "error", "Unable To Turn In Farm")
			cb(false)
		end
	end)
end)

AddEventHandler("Farming:Server:OnDuty", function(joiner, members, isWorkgroup)
	_joiners[joiner] = joiner
	_farming[joiner] = {
		joiner = joiner,
		isWorkgroup = isWorkgroup,
		started = os.time(),
		state = 0,
	}

	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
	char:SetData("TempJob", _JOB)
	exports['pulsar-phone']:NotificationAdd(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor",
		{})
	TriggerClientEvent("Farming:Client:OnDuty", joiner, joiner, os.time())

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Speak With The Farm Supervisor")
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner

			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			exports['pulsar-phone']:NotificationAdd(v.ID, "Job Activity", "You started a job", os.time(), 6000,
				"labor", {})
			TriggerClientEvent("Farming:Client:OnDuty", v.ID, joiner, os.time())
		end
	end
end)

AddEventHandler("Farming:Server:OffDuty", function(source, joiner)
	_joiners[source] = nil
	TriggerClientEvent("Farming:Client:OffDuty", source)
end)

AddEventHandler("Farming:Server:FinishJob", function(joiner)
	_farming[joiner] = nil
end)
