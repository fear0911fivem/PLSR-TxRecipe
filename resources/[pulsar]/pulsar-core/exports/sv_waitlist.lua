local _queues = {}
local started = false

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	for k, v in pairs(_queues) do
		exports['pulsar-core']:WaitListInteractRemove(k, source)
	end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source)
	for k, v in pairs(_queues) do
		exports['pulsar-core']:WaitListInteractRemove(k, source)
	end
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	if not started then
		started = true
		for k, v in pairs(_queues) do
			CreateQueue(k)
		end
	end
end)

local _reqOpts = {
	time = { "event", "delay" },
	concurrent = { "event", "max" },
	random = { "event", "min", "max" },
	individual_time = { "event", "delay" },
}

function ValidateOptions(type, opts)
	if _reqOpts[type] ~= nil then
		for k, v in ipairs(_reqOpts[type]) do
			if opts[v] == nil then
				return false
			end
		end
		return true
	else
		return false
	end
end

function CountAvailable(id)
	if _queues[id] ~= nil then
		local c = 0
		for k, v in ipairs(_queues[id].queue) do
			if not v.active then
				c = c + 1
			end
		end
		return c
	else
		return false
	end
end

function CountActive(id)
	if _queues[id] ~= nil then
		local c = 0
		for k, v in ipairs(_queues[id].queue) do
			if v.active then
				c = c + 1
			end
		end
		return c
	else
		return false
	end
end

function CreateQueue(id)
	local time = os.time()
	if _queues[id] ~= nil then
		_queues[id].started = time
		CreateThread(function()
			while _queues[id].started == time and _queues[id] ~= nil do
				if not _queues[id].paused and #_queues[id].queue > 0 then
					if _queues[id].type == "time" then
						if type(_queues[id].options.delay) == "function" then
							Wait(_queues[id].options.delay())
						else
							Wait(_queues[id].options.delay)
						end
						TriggerEvent(_queues[id].options.event, _queues[id].queue[1].source, _queues[id].queue[1].data)
						exports['pulsar-core']:WaitListInteractActive(id, _queues[id].queue[1].source)
					elseif _queues[id].type == "concurrent" then
						for k, v in ipairs(_queues[id].queue) do
							if #_queues[id].active < _queues[id].options.max then
								TriggerEvent(_queues[id].options.event, v.source, v.data)
								exports['pulsar-core']:WaitListInteractActive(id, v.source)
							else
								break
							end
						end
					elseif _queues[id].type == "random" then
						Wait(
							math.random((_queues[id].options.max - _queues[id].options.min)) + _queues[id].options.min
						)
						if _queues[id].queue[1] ~= nil then
							TriggerEvent(
								_queues[id].options.event,
								_queues[id].queue[1].source,
								_queues[id].queue[1].data
							)

							if _queues[id].queue[1] ~= nil then
								exports['pulsar-core']:WaitListInteractActive(id, _queues[id].queue[1].source)
							end
						end
					elseif _queues[id].type == "individual_time" then
						for k, v in ipairs(_queues[id].queue) do
							if v.started + (_queues[id].options.delay / 1000) <= os.time() then
								TriggerEvent(_queues[id].options.event, v.source, v.data)
								exports['pulsar-core']:WaitListInteractActive(id, v.source)
							end
						end
					end
					Wait(1000)
				else
					Wait(20000)
				end
			end
		end)
	end
end

exports("WaitListPrintQueue", function(id)
	if _queues[id] ~= nil then
		for k, v in ipairs(_queues[id].queue) do
			local char = exports['pulsar-characters']:FetchCharacterSource(v.source)
			if char ~= nil then
				print(
					string.format(
						"Waitlist %s #%s, %s %s (%s)",
						id,
						k,
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID")
					)
				)
			else
				print(string.format("nil player in waitlist: %s", id))
			end
		end
	end
end)

exports("WaitListCreate", function(id, type, options)
	if ValidateOptions(type, options) then
		exports['pulsar-core']:LoggerTrace("WaitList",
			string.format("Creating New WaitList ^2%s^7 (^3%s^7)", id, type))
		_queues[id] = {
			id = id,
			type = type,
			options = options,
			queue = {},
			active = {},
		}
		CreateQueue(id)
	else
		exports['pulsar-core']:LoggerError(
			"WaitList",
			string.format(
				"Attempted To Register New WaitList ^2%s^7 With Invalid Options For Type: ^3%s^7",
				id,
				type
			)
		)
	end
end)

exports("WaitListPause", function(id)
	if _queues[id] ~= nil then
		exports['pulsar-core']:LoggerInfo("WaitList", string.format("^2%s^7 WaitList Process Paused", id))
		_queues[id].paused = true
	end
end)

exports("WaitListUnpause", function(id)
	if _queues[id] ~= nil then
		exports['pulsar-core']:LoggerInfo("WaitList",
			string.format("^2%s^7 WaitList Process Unpaused", id))
		_queues[id].paused = false
	end
end)

exports("WaitListInteractAdd", function(id, source, data)
	if _queues[id] ~= nil then
		exports['pulsar-core']:LoggerTrace("WaitList",
			string.format("^2%s^7 Added To ^3%s^7", source, id))
		Player(source).state[string.format("WaitList:%s", id)] = {
			waiting = true,
		}
		table.insert(_queues[id].queue, {
			source = source,
			data = data,
			started = os.time(),
		})
	end
end)

exports("WaitListInteractRemove", function(id, source)
	if source == nil then
		return
	end
	if _queues[id] ~= nil then
		Player(source).state[string.format("WaitList:%s", id)] = nil
		for k, v in ipairs(_queues[id].queue) do
			if v.source == source then
				exports['pulsar-core']:LoggerTrace(
					"WaitList",
					string.format("^2%s^7 Removed From ^3%s^7 Queue", source, id)
				)
				table.remove(_queues[id].queue, k)
				break
			end
		end

		for k, v in ipairs(_queues[id].active) do
			if v.source == source then
				exports['pulsar-core']:LoggerTrace(
					"WaitList",
					string.format("^2%s^7 Removed From ^3%s^7 Active", source, id)
				)
				table.remove(_queues[id].active, k)
				break
			end
		end
	end
end)

exports("WaitListInteractPop", function(id)
	if _queues[id] ~= nil then
		exports['pulsar-core']:LoggerTrace("WaitList",
			string.format("Removed First Person From ^2%s^7 ", id))
		table.remove(_queues[id].queue, 1)
	end
end)

exports("WaitListInteractInactive", function(id, source)
	if _queues[id] ~= nil then
		for k, v in ipairs(_queues[id].active) do
			if v.source == source then
				exports['pulsar-core']:LoggerTrace("WaitList",
					string.format("^2%s^7 Went Inactive In ^3%s^7", source, id))
				Player(source).state[string.format("WaitList:%s", id)] = {
					waiting = true,
				}
				v.started = os.time()
				table.insert(_queues[id].queue, v)
				table.remove(_queues[id].active, k)
				return
			end
		end
	end
end)

exports("WaitListInteractActive", function(id, source)
	if _queues[id] ~= nil then
		for k, v in ipairs(_queues[id].queue) do
			if v.source == source then
				exports['pulsar-core']:LoggerTrace("WaitList",
					string.format("^2%s^7 Went Active In ^3%s^7", source, id))
				Player(source).state[string.format("WaitList:%s", id)] = {
					waiting = false,
				}
				table.insert(_queues[id].active, v)
				table.remove(_queues[id].queue, k)
				return
			end
		end
	end
end)
