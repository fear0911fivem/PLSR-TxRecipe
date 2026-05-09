local _POLYID = "mining-zone"
local _joiner = nil
local _working = false
local _state = 0
local _blips = {}
local eventHandlers = {}

local _objs = {}
local _nodes = nil

local _sellers = {
	{
		coords = vector3(-619.496, -225.697, 37.057),
		heading = 130.523,
		model = `a_f_y_clubcust_02`,
	},
	-- {
	-- 	coords = vector3(244.655, 374.674, 105.738),
	-- 	heading = 162.529,
	-- 	model = `csb_popov`,
	-- },
}

local function SpawnOres()
	if _nodes then
		for k, v in ipairs(_nodes) do
			RequestModel(v.ore.object)
			while not HasModelLoaded(v.ore.object) do
				Wait(5)
			end

			local o = CreateObject(v.ore.object, v.location.x, v.location.y, v.location.z - 1.4, false, true, false)
			PlaceObjectOnGroundProperly(o)
			FreezeEntityPosition(o, true)
			Wait(100)
			exports.ox_target:addLocalEntity(o, {
				{
					label = string.format("Mine %s", v.ore.label),
					icon = "pickaxe",
					event = string.format("Mining:Client:%s:Action", _joiner),
					distance = 3.0,
					data = v,
					canInteract = function()
						return _working and _state == 1 and _nodes ~= nil
					end,
				},
			})
			local b = exports["pulsar-blips"]:Add(string.format("MiningNode-%s", k), "Mining Node", v.location, 594, 0,
				0.8)

			table.insert(_objs, {
				ent = o,
				data = v,
				blip = b,
				blipId = string.format("MiningNode-%s", k),
			})
		end
	end
end

local function DeleteNode(location)
	if _objs and #_objs > 0 then
		for k, v in ipairs(_objs) do
			if
				vector3(v.data.location.x, v.data.location.y, v.data.location.z)
				== vector3(location.x, location.y, location.z)
			then
				exports.ox_target:removeLocalEntity(v.ent)
				DeleteObject(v.ent)
				exports["pulsar-blips"]:Remove(v.blipId)

				table.remove(_objs, k)
				break
			end
		end

		for k, v in ipairs(_nodes) do
			if v.location == location then
				table.remove(_nodes, k)
				break
			end
		end
	end
end

local function DespawnOres()
	if _objs and #_objs > 0 then
		for i = #_objs, 0, -1 do
			local v = _objs[i]

			if v then
				exports.ox_target:removeLocalEntity(v.ent)
				DeleteObject(v.ent)
				exports["pulsar-blips"]:Remove(v.blipId)
			end

			table.remove(_objs, i)
		end
	end
end

AddEventHandler("Labor:Client:Setup", function()
	exports['pulsar-polyzone']:CreateCircle(_POLYID, vector3(2885.78, 2803.96, 54.76), 350.0, {
		name = _POLYID,
		useZ = false,
		--debugPoly=true
	})

	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("GemSeller%s", k), v.model, v.coords, v.heading, 25.0, {
			{
				icon = "sack-dollar",
				text = "Sell Diamonds",
				event = "Mining:Client:SellGem",
				data = "diamond",
				item = "diamond",
				rep = { id = "Mining", level = 5 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Emeralds",
				event = "Mining:Client:SellGem",
				data = "emerald",
				item = "emerald",
				rep = { id = "Mining", level = 5 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Sapphire",
				event = "Mining:Client:SellGem",
				data = "sapphire",
				item = "sapphire",
				rep = { id = "Mining", level = 4 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Ruby",
				event = "Mining:Client:SellGem",
				data = "ruby",
				item = "ruby",
				rep = { id = "Mining", level = 3 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Amethyst",
				event = "Mining:Client:SellGem",
				data = "amethyst",
				item = "amethyst",
				rep = { id = "Mining", level = 2 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Citrine",
				event = "Mining:Client:SellGem",
				data = "citrine",
				item = "citrine",
				rep = { id = "Mining", level = 1 },
			},
			{
				icon = "sack-dollar",
				text = "Sell Opal",
				event = "Mining:Client:SellGem",
				data = "opal",
				item = "opal",
				rep = { id = "Mining", level = 1 },
			},
		}, "gem")
	end

	exports['pulsar-pedinteraction']:Add("MiningJob", `s_m_y_construct_02`, vector3(2741.874, 2791.691, 34.214), 155.045,
		25.0, {
			{
				icon = "face-tongue-money",
				text = "Sell Crushed Stone ($3/per)",
				event = "Mining:Client:SellStone",
			},
			{
				icon = "helmet-safety",
				text = "Start Work",
				event = "Mining:Client:StartJob",
				tempjob = "Mining",
				isEnabled = function()
					return not _working
				end,
			},
		}, "helmet-safety")
end)

local attempt = 0
RegisterNetEvent("Mining:Client:OnDuty", function(joiner, time)
	_joiner = joiner
	DeleteWaypoint()
	SetNewWaypoint(2741.874, 2791.691)
	_node = 0

	eventHandlers["startup"] = RegisterNetEvent(string.format("Mining:Client:%s:Startup", joiner), function(nodes)
		if _nodes ~= nil then
			return
		end
		_working = true
		_nodes = nodes
		_state = 1

		SpawnOres()
	end)

	eventHandlers["actions"] = RegisterNetEvent(string.format("Mining:Client:%s:Action", joiner), function(response)
		attempt = 0
		local data = response.data
		if data and data.luck <= 10 then
			CreateThread(function()
				local p = promise.new()
				while attempt < 3 do
					local p2 = promise.new()
					exports['pulsar-games']:MinigamePlayRoundSkillbar(
						(data?.ore?.factor or 0.75) * (data?.ore?.scale or 1.15),
						(data?.ore?.size or 6) - attempt, {
							onSuccess = function()
								Wait(400)
								attempt += 1
								p2:resolve(true)

								if attempt >= 3 then
									p:resolve(true)
								end
							end,
							onFail = function()
								data.failed = true
								p:resolve(false)
								p2:resolve(true)
								attempt = 3
							end,
						}, {
							useWhileDead = false,
							vehicle = false,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
							animation = {
								anim = "mining",
							},
						})

					Citizen.Await(p2)
				end

				local r = Citizen.Await(p)
				exports["pulsar-core"]:ServerCallback("Mining:Server:MineNode", data)
			end)
		else
			exports['pulsar-hud']:Progress({
				name = "mining_action",
				duration = math.random(40, 55) * 1000,
				label = "Mining",
				useWhileDead = false,
				canCancel = true,
				vehicle = false,
				animation = {
					anim = "mining",
				},
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableCombat = true,
				},
			}, function(cancelled)
				if not cancelled then
					exports["pulsar-core"]:ServerCallback("Mining:Server:MineNode", data)
				end
			end)
		end
	end)

	eventHandlers["remove-node"] = RegisterNetEvent(
		string.format("Mining:Client:%s:RemoveNode", joiner),
		function(location)
			DeleteNode(location)
		end
	)

	eventHandlers["enter-poly"] = AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
		if id ~= _POLYID or not _nodes or #_nodes == 0 then
			return
		end

		_inPoly = true
		if _state == 1 then
			SpawnOres()
		end
	end)

	eventHandlers["exit-poly"] = AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
		if id == _POLYID then
			_inPoly = false
			DespawnOres()
		end
	end)
end)

AddEventHandler("Mining:Client:SellStone", function()
	exports["pulsar-core"]:ServerCallback("Mining:SellStone", {})
end)

AddEventHandler("Mining:Client:PuchaseAxe", function()
	exports["pulsar-core"]:ServerCallback("Mining:PurchasePickaxe", {})
end)

AddEventHandler("Mining:Client:TurnIn", function()
	exports["pulsar-core"]:ServerCallback("Mining:TurnIn", _joiner)
end)

AddEventHandler("Mining:Client:SellGem", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Mining:SellGem", data)
end)

AddEventHandler("Mining:Client:StartJob", function()
	exports["pulsar-core"]:ServerCallback("Mining:StartJob", _joiner, function(state)
		if not state then
			exports["pulsar-hud"]:Notification("error", "Unable To Start Job")
		end
	end)
end)

RegisterNetEvent("Mining:Client:OffDuty", function(time)
	for k, v in pairs(eventHandlers) do
		RemoveEventHandler(v)
	end

	DespawnOres()

	eventHandlers = {}
	_joiner = nil
	_working = false
	_nodes = nil
end)
