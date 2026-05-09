local _st = RobberyConfig.store
local _models = {
	303280717,
}

local _inPoly = nil
local _polys = {}
AddEventHandler("Robbery:Client:Setup", function()
	_polys = {}
	while not GlobalState["StoreRobberies"] do
		Wait(10)
	end
	for k, v in pairs(GlobalState["StoreRobberies"]) do
		exports['pulsar-polyzone']:CreateBox(v.id, v.coords, v.width, v.length, v.options)
		_polys[v.id] = true
	end

	for k, v in ipairs(GlobalState["StoreSafes"]) do
		exports.ox_target:addBoxZone({
			id = v.id,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-unlock",
					label = "Crack Safe",
					item = _st.items.safeCrack,
					onSelect = function()
						TriggerEvent("Robbery:Client:Store:ActualCrackSafe", v.data)
					end,
					canInteract = function()
						return (
							not GlobalState["StoreAntiShitlord"]
							or GetCloudTimeAsInt() > GlobalState["StoreAntiShitlord"]
						) and GlobalState[string.format("Safe:%s", v.data.id)] == nil
					end,
				},
				{
					icon = "fas fa-terminal",
					label = "Use Sequencer",
					item = _st.items.sequencer,
					onSelect = function()
						TriggerEvent("Robbery:Client:Store:SequenceSafe", v.data)
					end,
					canInteract = function()
						return (
							not GlobalState["StoreAntiShitlord"]
							or GetCloudTimeAsInt() > GlobalState["StoreAntiShitlord"]
						) and GlobalState[string.format("Safe:%s", v.data.id)] == nil
					end,
				},
				{
					icon = "fas fa-fingerprint",
					label = "Open Safe",
					onSelect = function()
						TriggerEvent("Robbery:Client:Store:OpenSafe", v.data)
					end,
					canInteract = function()
						local safeData = GlobalState[string.format("Safe:%s", v.data.id)]
						return safeData ~= nil and safeData.state == 2
					end,
				},
				{
					icon = "fas fa-shield-keyhole",
					label = "Secure Safe",
					groups = { "police" },
					onSelect = function()
						TriggerEvent("Robbery:Client:Store:SecureSafe", v.data)
					end,
					canInteract = function()
						local safeData = GlobalState[string.format("Safe:%s", v.data.id)]
						return safeData ~= nil and safeData.state ~= 4
					end,
				},
			}
		})
	end

	exports["pulsar-core"]:RegisterClientCallback("Robbery:Store:DoSafeCrack", function(data, cb)
		_memPass = 1
		DoMemory(data.passes, data.config, data.data, function(isSuccess, extra)
			cb(isSuccess, extra)
		end)
	end)
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if _polys[id] and GlobalState[id] == nil then
		LocalPlayer.state:set("storePoly", id, true)
		_inPoly = id
		for k, v in ipairs(_models) do
			exports.ox_target:removeModel(v)
			exports.ox_target:addModel(v, {
				{
					icon = "fas fa-cash-register",
					label = "Lockpick Register",
					item = _st.items.register,
					onSelect = function(data)
						TriggerEvent("Robbery:Client:Store:LockpickRegister", data)
					end,
					canInteract = function(entity)
						local coords = GetEntityCoords(entity)
						return _polys[id]
							and (
								not GlobalState[string.format("Register:%s:%s", coords.x, coords.y)]
								or (
									GlobalState[string.format("Register:%s:%s", coords.x, coords.y)]
									and GlobalState[string.format("Register:%s:%s", coords.x, coords.y)].expires
									< GetCloudTimeAsInt()
								)
							)
					end,
				},
			})
		end
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if _polys[id] then
		if LocalPlayer.state.storePoly ~= nil then
			LocalPlayer.state:set("storePoly", nil, true)
		end

		_inPoly = nil
		for k, v in ipairs(_models) do
			exports.ox_target:removeModel(v)
		end
	end
end)

local _timer = 50
local _lpPass = 1
function LPScan(coords)
	if not _inPoly then
		return
	end
	exports['pulsar-games']:MinigamePlayScanner(5, _timer, 5000 - (750 * _lpPass), 20, 1, true, {
		onSuccess = "Robbery:Client:Store:LockpickSuccess",
		onFail = "Robbery:Client:Store:LockpickFail",
	}, {
		playableWhileDead = false,
		animation = {
			animDict = "veh@break_in@0h@p_m_one@",
			anim = "low_force_entry_ds",
			flags = 17,
		},
	}, coords)
end

local _scPass = 1
function SCSeq(id)
	if not _inPoly then
		return
	end
	exports['pulsar-games']:MinigamePlaySequencer(5, 500, 7500 - (500 * _scPass), 2 + _scPass, true, {
		onSuccess = "Robbery:Client:Store:SafeCrackSuccess",
		onFail = "Robbery:Client:Store:SafeCrackFail",
	}, {
		playableWhileDead = false,
		animation = {
			animDict = "anim@heists@ornate_bank@hack",
			anim = "hack_loop",
			flags = 49,
		},
	}, id)
end

AddEventHandler("Robbery:Client:Store:LockpickRegister", function(entity, data)
	if not entity or not _inPoly then
		return
	end
	local coords = GetEntityCoords(entity.entity)
	if
		not GlobalState[string.format("Register:%s:%s", coords.x, coords.y)]
		or (
			GlobalState[string.format("Register:%s:%s", coords.x, coords.y)]
			and GlobalState[string.format("Register:%s:%s", coords.x, coords.y)].expires < GetCloudTimeAsInt()
		)
	then
		exports["pulsar-core"]:ServerCallback("Robbery:Store:StartLockpick", coords, function(s)
			if s then
				if exports.ox_inventory:ItemsHas("lockpick", 1) then
					_lpPass = 1
					LPScan(coords)
				end
			end
		end)
	end
end)

AddEventHandler("Robbery:Client:Store:LockpickSuccess", function(data)
	if not _inPoly then
		return
	end

	if _lpPass then
		if _lpPass >= 4 then
			_lpPass = false
			exports["pulsar-core"]:ServerCallback("Robbery:Store:Register", {
				results = true,
				coords = data,
				store = _inPoly,
			}, function(s) end)
		else
			_lpPass = _lpPass + 1
			Wait(800)
			LPScan(data)
		end
	end
end)

AddEventHandler("Robbery:Client:Store:LockpickFail", function(data)
	if not _inPoly then
		return
	end
	exports["pulsar-core"]:ServerCallback("Robbery:Store:Register", {
		results = false,
		coords = data,
		store = _inPoly,
	}, function(s) end)
end)

AddEventHandler("Robbery:Client:Store:ActualCrackSafe", function(data)
	if not _inPoly then
		return
	end
	if GlobalState[string.format("Safe:%s", data.id)] == nil then
		exports["pulsar-core"]:ServerCallback("Robbery:Store:StartSafeCrack", data, function(s) end)
	end
end)

AddEventHandler("Robbery:Client:Store:SequenceSafe", function(data)
	if not _inPoly then
		return
	end
	if GlobalState[string.format("Safe:%s", data.id)] == nil then
		exports["pulsar-core"]:ServerCallback("Robbery:Store:StartSafeSequence", {}, function(r)
			if r then
				if exports.ox_inventory:ItemsHas("sequencer", 1) then
					_scPass = 1
					SCSeq(data)
				end
			end
		end)
	end
end)

AddEventHandler("Robbery:Client:Store:OpenSafe", function(data)
	if not _inPoly then
		return
	end
	data.store = _inPoly
	exports["pulsar-core"]:ServerCallback("Robbery:Store:LootSafe", data, function(s) end)
end)

AddEventHandler("Robbery:Client:Store:SecureSafe", function(data)
	if not _inPoly then
		return
	end

	exports['pulsar-hud']:Progress({
		name = "secure_safe",
		duration = 5000,
		label = "Securing",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "cop3",
		},
	}, function(status)
		if not status then
			data.store = _inPoly
			exports["pulsar-core"]:ServerCallback("Robbery:Store:SecureSafe", data, function(s) end)
		end
	end)
end)

AddEventHandler("Robbery:Client:Store:SafeCrackSuccess", function(data)
	if not _inPoly then
		return
	end

	if _scPass >= 3 then
		_scPass = 1
		data.results = true
		data.store = _inPoly
		exports["pulsar-core"]:ServerCallback("Robbery:Store:Safe", data, function(s) end)
	else
		_scPass = _scPass + 1
		Wait(1500)
		SCSeq(data)
	end
end)

AddEventHandler("Robbery:Client:Store:SafeCrackFail", function(data)
	if not _inPoly then
		return
	end
	data.results = false
	data.store = _inPoly
	exports["pulsar-core"]:ServerCallback("Robbery:Store:Safe", data, function(s) end)
end)

