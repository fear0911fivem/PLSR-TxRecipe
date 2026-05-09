local _tasks = {}
local started = false

AddEventHandler("Proxy:Shared:RegisterReady", function()
	if not started then
		started = true
		TaskTick()
	end
end)

function TaskTick()
	for k, v in pairs(_tasks) do
		if v.pause or v.skip then
			if v.skip then
				v.skip = false
			end
		else
			if v.tick >= (v.timer - 1) then
				v.callback(v.data)
				v.tick = 0
			else
				v.tick = v.tick + 1
			end
		end
	end

	SetTimeout(60000, TaskTick)
end

exports("TasksRegister", function(id, timer, cb, data, firstTick)
	if _tasks[id] ~= nil then
		exports['pulsar-core']:LoggerWarn("Tasks", "Overriding Already Existing Task: " .. id)
	else
		exports['pulsar-core']:LoggerTrace(
			"Tasks",
			"Registering New Task: ^2" .. id .. "^7 To Execute Every ^3" .. timer .. " Minutes^7"
		)
	end

	_tasks[id] = {
		id = id,
		timer = timer,
		tick = firstTick or 0,
		pause = false,
		skip = false,
		callback = cb,
		data = data,
	}
end)

exports("TasksDelete", function(id)
	if _tasks[id] ~= nil then
		_tasks[id] = nil
	else
		exports['pulsar-core']:LoggerWarn("Tasks", "Attempt To Delete Non-Existing Task: " .. id)
	end
end)

exports("TasksPause", function(id)
	if _tasks[id] ~= nil then
		_tasks[id].pause = true
	else
		exports['pulsar-core']:LoggerWarn("Tasks", "Attempt To Pause Non-Existing Task: " .. id)
	end
end)

exports("TasksResume", function(id)
	if _tasks[id] ~= nil then
		_tasks[id].pause = false
	else
		exports['pulsar-core']:LoggerWarn("Tasks", "Attempt To Resume Non-Existing Task: " .. id)
	end
end)

exports("TasksSkip", function(id)
	if _tasks[id] ~= nil then
		_tasks[id].skip = false
		_tasks[id].pause = false
	else
		exports['pulsar-core']:LoggerWarn("Tasks", "Attempt To Skip Non-Existing Task: " .. id)
	end
end)
