Callbacks = nil
Status = nil
Hud = nil

local _statuses = {}
local _recentCd = {}
local _noResets = {}
local _statusCount = 0
local isEnabled = true

local _statusVals = {}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterStatuses()
		RegisterOxygenCallbacks()
		RegisterOxygenMenus()
		CreateStressPolys()
		RegisterDrunkCallbacks()

		exports["pulsar-core"]:RegisterClientCallback("Status:Modify", function(data, cb)
			if data.value > 0 then
				exports['pulsar-status']:Add(data.name, data.value, data.addCd, data.isForced)
			else
				exports['pulsar-status']:Remove(data.name, data.value, data.addCd, data.isForced)
			end
		end)

		exports["pulsar-core"]:RegisterClientCallback("Status:StoreValues", function(data, cb)
			cb(_statusVals)
		end)
	end
end)

exports('Register', function(name, max, icon, color, flash, modify, options)
	local update = false
	if _statuses[name] ~= nil then
		update = true
	end

	_statuses[name] = {
		name = name,
		max = max,
		icon = icon,
		color = color,
		flash = flash,
		modify = modify,
		options = options,
	}

	if options ~= nil and options.noReset then
		_noResets[name] = true
	end

	if not update then
		_statusCount = _statusCount + 1
	end
end)

exports('GetRegistered', function()
	return _statuses
end)

exports('GetAll', function()
	for k, v in pairs(_statuses) do
		local statuses = _statuses
		for k, v in pairs(_statuses) do
			statuses[k].value = _statusVals[v.name]
		end
		return statuses
	end
end)

exports('GetSingle', function(name)
	local statuses = _statuses
	for k, v in pairs(_statuses) do
		if v.name == name then
			statuses[k].value = _statusVals[v.name]
			return statuses[k]
		end
	end
end)

-- Really much more performant to just interact directly with Decor natives ... but available just in case?
exports('SetAll', function(entity, value)
	for k, v in pairs(_statuses) do
		_statusVals[v.name] = value
		TriggerEvent("Status:Client:Update", v.name, value)
	end
end)

exports('SetSingle', function(name, value)
	if _statuses[name] ~= nil then
		_statusVals[name] = value
		TriggerEvent("Status:Client:Update", name, value)
	end
end)

exports('Reset', function(entity, value)
	for k, v in pairs(_statuses) do
		if not _noResets[v.name] then
			_statusVals[v.name] = v.max
			TriggerEvent("Status:Client:Update", v.name, v.max)
		end
	end
end)

exports('Add', function(status, value, addCd, force)
	if _statuses[status] ~= nil then
		if
			_statuses[status].max <= 0
			and (
				LocalPlayer.state[string.format("ignore%s", status)] ~= nil
				and LocalPlayer.state[string.format("ignore%s", status)] > 0
			)
		then
			return
		end

		_statuses[status].modify(math.abs(value), force)

		if addCd then
			_recentCd[status] = 1
		end
	else
		exports['pulsar-core']:LoggerError("Status", "Attempt To Add To Non-Existent Status")
	end
end)

exports('Remove', function(status, value, force)
	if
		_statuses[status].max >= 0
		and (
			LocalPlayer.state[string.format("ignore%s", status)] ~= nil
			and LocalPlayer.state[string.format("ignore%s", status)] > 0
		)
	then
		return
	end

	if _statuses[status] ~= nil then
		_statuses[status].modify(-(math.abs(value)), force)
	else
		exports['pulsar-core']:LoggerError("Status", "Attempt To Remove From Non-Existent Status")
	end
end)

exports('Toggle', function()
	isEnabled = not isEnabled
end)

exports('Check', function()
	return isEnabled
end)

local spawned = false

RegisterNetEvent("Status:Client:Reset", function()
	exports["pulsar-core"]:ServerCallback("Commands:ValidateAdmin", {}, function(isAdmin)
		if isAdmin then
			for k, v in pairs(_statuses) do
				exports['pulsar-status']:SetSingle(v.name, v.max)
			end
		end
	end)
end)

local _ts = nil
RegisterNetEvent("Characters:Client:Spawn", function()
	spawned = true
	isEnabled = true

	local ffs = GetCloudTimeAsInt()
	_ts = ffs

	exports["pulsar-core"]:ServerCallback("Status:Get", {}, function(results)
		results = results or {}
		for k, v in pairs(exports['pulsar-status']:GetRegistered()) do
			local val = results[v.name] or v.max
			_statusVals[v.name] = val
			exports['pulsar-hud']:RegisterStatus(v.name, val, v.max, v.icon, v.color, v.flash, false, v.options)
		end
	end)

	CreateThread(function()
		Wait(60000)
		while LocalPlayer.state.loggedIn and _ts == ffs do
			TriggerServerEvent("Status:Server:StoreAll", _statusVals)
			Wait(60000)
		end
	end)

	--Spawn Tick Thread
	CreateThread(function()
		Wait(300000) -- Wait 5 mins before we start ticks
		while LocalPlayer.state.loggedIn and _ts == ffs do
			if isEnabled then
				for k, v in pairs(_statuses) do
					if _recentCd[v.name] == nil or _recentCd[v.name] > 10 then
						_recentCd[v.name] = nil
						v.modify()
					else
						_recentCd[v.name] = _recentCd[v.name] + 1
					end
					Wait((100000 / _statusCount)) -- Split tick events across the second-long tick to try to avoid spiking
				end
			end
			Wait(0) -- Im just here so you dont crash
		end
	end)

	CreateStressBlips()
end)

AddEventHandler("UI:Client:ResetFinished", function(manual)
	if manual then
		exports["pulsar-core"]:ServerCallback("Status:Get", {}, function(results)
			for k, v in pairs(exports['pulsar-status']:GetRegistered()) do
				local val = results[v.name] or v.max

				_statusVals[v.name] = val
				exports['pulsar-hud']:RegisterStatus(v.name, val, v.max, v.icon, v.color, v.flash, false, v.options)
			end
		end)
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_ts = nil
	spawned = false
	isEnabled = true
	exports['pulsar-hud']:ResetStatus()
	_statusVals = {}
end)
