local _fookinLasers = {}

function InitWrapperLasers()
	for k, v in pairs(_fookinLasers) do
		v.laser = Laser.new(v.originPoint, v.targetPoints, v.options)
		v.laser.onPlayerHit(v.onHit)

		if v.startEnabled then
			v.laser.setActive(true)
		else
			v.laser.setActive(false)
		end
	end
end

function DeleteLasers()
	for k, v in pairs(_fookinLasers) do
		if v.laser ~= nil then
			v.laser.setActive(false)
			_fookinLasers[k] = nil
		end
	end
end

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterClientCallback("Lasers:Create:Start", function()
			creationEnabled = true
			inOriginMode = true
			startCreation()
		end)

		exports["pulsar-core"]:RegisterClientCallback("Lasers:Create:End", function()
			creationEnabled = false
		end)

		exports["pulsar-core"]:RegisterClientCallback("Lasers:Create:Save", function()
			if not originPoints or not targetPoints then
				return
			end
			local name = GetUserInput("Enter name of laser:", "", 30)
			if name == nil then
				return
			end
			local laser = {
				name = name,
				originPoints = originPoints,
				targetPoints = targetPoints,
				travelTimeBetweenTargets = { 1.0, 1.0 },
				waitTimeAtTargets = { 0.0, 0.0 },
				randomTargetSelection = true,
			}
			TriggerServerEvent("Lasers:Server:Save", laser)
			creationEnabled = false
		end)
	end
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	InitWrapperLasers()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	DeleteLasers()
end)

exports('Create', function(id, originPoint, targetPoints, options, startEnabled, onHit)
	_fookinLasers[id] = {
		originPoint = originPoint,
		targetPoints = targetPoints,
		options = options,
		startEnabled = startEnabled,
		onHit = onHit,
	}
end)

exports('GetLaser', function(id)
	return _fookinLasers[id].laser or nil
end)

exports('GetActive', function(id)
	if _fookinLasers[id] ~= nil then
		return _fookinLasers[id].laser.getActive()
	else
		return false
	end
end)

exports('GetVisible', function(id)
	if _fookinLasers[id] ~= nil then
		return _fookinLasers[id].laser.getVisible()
	else
		return false
	end
end)

exports('GetMoving', function(id)
	if _fookinLasers[id] ~= nil then
		return _fookinLasers[id].laser.getMoving()
	else
		return false
	end
end)

exports('GetColor', function(id)
	if _fookinLasers[id] ~= nil then
		return _fookinLasers[id].laser.getColor()
	else
		return false
	end
end)

exports('SetActive', function(id, state)
	if _fookinLasers[id] ~= nil and _fookinLasers[id].laser ~= nil then
		_fookinLasers[id].laser.setActive(state)
	end
end)

exports('SetVisible', function(id, state)
	if _fookinLasers[id] ~= nil and _fookinLasers[id].laser ~= nil then
		_fookinLasers[id].laser.setVisible(state)
	end
end)

exports('SetMoving', function(id, state)
	if _fookinLasers[id] ~= nil and _fookinLasers[id].laser ~= nil then
		_fookinLasers[id].laser.setMoving(state)
	end
end)

exports('SetColor', function(id, r, g, b, a)
	if _fookinLasers[id] ~= nil and _fookinLasers[id].laser ~= nil then
		_fookinLasers[id].laser.setColor(r, g, b, a)
	end
end)
