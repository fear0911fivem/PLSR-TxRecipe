local eventHandlers = {}
local _working = false
local _state = 0              -- 0 is no pickup | 1 active pickup
local _activeDropoffState = 0 -- 0 not actively working | 1 actively working
local _dropOffBlip = nil
local _dropOffBlipCfg = nil
local _deliveryCounter = nil   -- set counter to nil
local _currentCookItem = nil   -- unset current cook item
local _gracePeriod = 30 * 1000 -- in ms
local _lastDelivery = GetGameTimer() - _gracePeriod
local _lastCook = GetGameTimer() - _gracePeriod
local _durationThread = false
local _durationTimer = (60 * 1000) * 20
local _durationCheck = 0

AddEventHandler("Businesses:Client:Startup", function()
	-- Setup Zones
	exports['pulsar-polyzone']:CreateBox("TacoPickup", _tacoPickUp.coords, _tacoPickUp.length, _tacoPickUp.width,
		_tacoPickUp.options)
	exports['pulsar-polyzone']:CreateBox("TacoQueue", _tacoQueue.coords, _tacoQueue.length, _tacoQueue.width,
		_tacoQueue.options)

	exports['pulsar-polyzone']:CreateBox("TacoShop_DriveThru", vector3(17.11, -1595.12, 29.28), 6.6, 3.8, {
		heading = 50,
		--debugPoly=true,
		minZ = 28.28,
		maxZ = 32.28,
	})

	exports.ox_target:addBoxZone({
		id = "TacoShop_SelfServe",
		coords = vector3(15.38, -1599.99, 29.38),
		size = vector3(1.3, 0.6, 4.0),
		rotation = 320,
		debug = false,
		minZ = 25.78,
		maxZ = 29.78,
		options = {
			{
				icon = "store",
				label = "Shop Taco Ingredients",
				event = "Taco:Client:TacoShop",
			},
		}
	})

	-- Setup Pickup
	for k, v in pairs(_tacoConfig.sharedPickup) do
		exports.ox_target:addBoxZone({
			id = string.format("TacoSharedPickup-%s", k),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "box-open",
					label = "Order Pickup",
					event = "Businesses:Client:Pickup",
					canInteract = function()
						-- Check if player is in vehicle and driveThru is enabled
						if v.driveThru then
							return IsPedInAnyVehicle(LocalPlayer.state.ped, false)
						end
						return true
					end,
				},
			}
		})
	end

	-- Setup Event Handlers
	eventHandlers["poly-enter"] = AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
		if id == "TacoPickup" and LocalPlayer.state.loggedIn then
			ShowTacoPickup()
		elseif id == "TacoQueue" and LocalPlayer.state.loggedIn then
			ShowTacoQueue()
		elseif id == "TacoShop_DriveThru" then
			exports["pulsar-sounds"]:PlayDistance(25, "bell.ogg", 0.3)
		end
	end)

	eventHandlers["poly-exit"] = AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
		if id == "TacoPickup" and LocalPlayer.state.loggedIn then
			LocalPlayer.state.TacoPickup = false
			exports['pulsar-hud']:ActionHide("tacopickup")
		elseif id == "TacoQueue" and LocalPlayer.state.loggedIn then
			LocalPlayer.state.TacoQueue = false
			exports['pulsar-hud']:ActionHide("tacoqueue")
		end
	end)

	eventHandlers["primary_action"] = AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
		if
			_state == 0
			and _activeDropoffState == 0
			and LocalPlayer.state.TacoPickup
			and not LocalPlayer.state.doingAction
		then
			if _deliveryCounter > 0 then
				exports['pulsar-hud']:ActionHide("tacopickup")
				if _lastCook + _gracePeriod > GetGameTimer() then
					exports["pulsar-hud"]:Notification("error",
						string.format(
							"You must wait to swap to deliveries! (%s seconds)",
							math.floor((_lastCook + _gracePeriod - GetGameTimer()) / 1000)
						)
					)
					ShowTacoPickup()
					return
				end
				exports["pulsar-core"]:ServerCallback("Taco:SetState", { state = 1 }, function()
					-- if not LocalPlayer.state.TacoPickup or not LocalPlayer.state.TacoQueue then
					-- 	return
					-- end
					exports['pulsar-hud']:Progress({
						name = "taco_pickup",
						duration = 2500,
						label = "Picking up delivery.",
						useWhileDead = false,
						canCancel = false,
						ignoreModifier = true,
						disarm = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							anim = "handoff",
						},
					}, function(status)
						exports["pulsar-core"]:ServerCallback("Tacos:Pickup", {}, function(s)
							if s then
								exports["pulsar-core"]:ServerCallback("Taco:SetState", { state = 0 }, function()
									FetchDropOffLocation()
									_activeDropoffState = 1
									exports['pulsar-hud']:ActionHide("tacopickup")
									_lastDelivery = GetGameTimer()
								end)
							end
						end)
					end)
				end)
			else
				exports['pulsar-hud']:ActionHide("tacopickup")
				ShowTacoPickup()
			end
		elseif _activeDropoffState == 0 and LocalPlayer.state.TacoQueue and LocalPlayer.state.loggedIn then
			if _deliveryCounter < _tacoQueue.maxQueue then
				exports['pulsar-hud']:ActionHide("tacoqueue")
				if _lastDelivery + _gracePeriod > GetGameTimer() then
					exports["pulsar-hud"]:Notification("error",
						string.format(
							"You must wait to swap to start prepping food! (%s seconds)",
							math.floor((_lastDelivery + _gracePeriod - GetGameTimer()) / 1000)
						)
					)
					ShowTacoQueue()
					return
				end
				if exports.ox_inventory:CheckPlayerHasItem(_tacoFoodItems[_currentCookItem].item, 1) then
					exports['pulsar-hud']:Progress({
						name = "taco_queue",
						duration = 2500,
						label = string.format("Placing %s in bag.", _tacoFoodItems[_currentCookItem].label),
						useWhileDead = false,
						canCancel = false,
						ignoreModifier = true,
						disarm = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							anim = "handoff",
						},
					}, function(status)
						exports["pulsar-core"]:ServerCallback(
							"Tacos:AddToQueue",
							{ item = _tacoFoodItems[_currentCookItem].item },
							function(s)
								if s then
									GetNewQueueItem()
									_lastCook = GetGameTimer()
								else
									exports["pulsar-hud"]:Notification("error",
										"You do not have the proper item to bag.")
									ShowTacoQueue()
								end
							end
						)
					end)
				else
					exports["pulsar-hud"]:Notification("error", "You do not have the proper item to bag.")
					ShowTacoQueue()
				end
			else
				exports["pulsar-hud"]:Notification("error", "The queue is full.")
				exports['pulsar-hud']:ActionHide("tacoqueue")
				ShowTacoQueue()
			end
		end
	end)
end)

RegisterNetEvent("Taco:SetQueue", function(data)
	_deliveryCounter = data.counter
	_currentCookItem = data.item
	if LocalPlayer.state.TacoQueue then
		ShowTacoQueue()
	end
	if LocalPlayer.state.TacoPickup then
		ShowTacoPickup()
	end
end)

RegisterNetEvent("Taco:PickupState", function(data)
	_state = data.state
end)

function GetNewQueueItem()
	exports["pulsar-core"]:ServerCallback("Taco:GetNewQueueItem", {}, function() end)
end

function ShowTacoPickup()
	if _activeDropoffState == 0 and _deliveryCounter ~= nil then
		LocalPlayer.state.TacoPickup = true
		if _deliveryCounter > 0 then
			exports['pulsar-hud']:ActionShow("tacopickup", "{keybind}primary_action{/keybind} Grab Delivery")
		else
			exports['pulsar-hud']:ActionShow("tacopickup", "No deliveries available.")
		end
	end
end

function ShowTacoQueue()
	if _activeDropoffState == 0 and _deliveryCounter ~= nil then
		if _deliveryCounter >= _tacoQueue.maxQueue then
			exports['pulsar-hud']:ActionShow("tacoqueue", "We require food to be delivered")
		else
			exports['pulsar-hud']:ActionShow(
				"tacoqueue",
				string.format(
					"{keybind}primary_action{/keybind} We require a %s to be delivered.",
					_tacoFoodItems[_currentCookItem].label
				)
			)
			LocalPlayer.state.TacoQueue = true
		end
	end
end

function FetchDropOffLocation()
	local _randomDropoff = math.random(#_tacoDropOffs)
	_dropOffBlipCfg = _tacoConfig.dropOffInfo

	if _tacoDropOffs[_randomDropoff] then
		local _dropOffCoords = _tacoDropOffs[_randomDropoff].coords
		local _gameTimer = GetGameTimer()
		_dropOffBlipCfg.coords = _dropOffCoords
		_dropOffBlipCfg.id = string.format("taco_dropoff_blip_%s", _gameTimer)
		_dropOffBlipCfg.zoneId = string.format("TacoDropOffZone-%s", _gameTimer)
		_dropOffBlip = exports["pulsar-blips"]:Add(
			_dropOffBlipCfg.id,
			_dropOffBlipCfg.name,
			vector3(_dropOffBlipCfg.coords.x, _dropOffBlipCfg.coords.y, _dropOffBlipCfg.coords.z),
			_dropOffBlipCfg.sprite,
			_dropOffBlipCfg.colour,
			_dropOffBlipCfg.scale
		)

		if not _durationThread then
			_durationThread = true
			_durationCheck = _durationTimer
			CreateThread(function()
				while _activeDropoffState == 1 and _durationCheck > 0 do
					_durationCheck = _durationCheck - 5
					DrawMarker(
						1,
						_dropOffBlipCfg.coords.x,
						_dropOffBlipCfg.coords.y,
						_dropOffBlipCfg.coords.z - 1.0,
						0,
						0,
						0,
						0,
						0,
						0,
						0.5,
						0.5,
						1.0,
						250,
						250,
						250,
						250,
						false,
						false,
						2,
						false,
						false,
						false,
						false
					)
					if _durationCheck <= 0 then
						_durationCheck = 0
						exports["pulsar-hud"]:Notification("error", "You failed to deliver the order in time.")
						RunCleanUp()
						return
					end
					Wait(5)
				end
			end)
		end

		exports.ox_target:addBoxZone({
			id = _dropOffBlipCfg.zoneId,
			coords = _tacoDropOffs[_randomDropoff].coords,
			size = vector3(_tacoDropOffs[_randomDropoff].length, _tacoDropOffs[_randomDropoff].width, 2.0),
			rotation = _tacoDropOffs[_randomDropoff].options.heading or 0,
			debug = false,
			minZ = _tacoDropOffs[_randomDropoff].options.minZ,
			maxZ = _tacoDropOffs[_randomDropoff].options.maxZ,
			options = {
				{
					icon = "box",
					label = "Deliver Order",
					event = "Tacos:DeliverOrder",
				},
			}
		})
	end
end

AddEventHandler("Taco:Client:TacoShop", function()
	exports.ox_inventory:ShopOpen("taco-shop-self")
end)

AddEventHandler("Tacos:DeliverOrder", function(data)
	exports['pulsar-hud']:Progress({
		name = "taco_dropoff",
		duration = 3000,
		label = "Dropping off delivery.",
		useWhileDead = false,
		canCancel = false,
		ignoreModifier = true,
		disarm = false,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "pickfromground",
		},
	}, function(status)
		exports["pulsar-core"]:ServerCallback("Tacos:Dropoff", {}, function(s)
			if s then
				exports["pulsar-blips"]:Remove(data.blipConfig.id)
				_activeDropoffState = 0
				_dropOffBlipCfg = nil
				_dropOffBlip = nil
				_durationThread = false
				_durationCheck = _durationTimer
				if exports.ox_target:zoneExists(data.blipConfig.zoneId) then
					exports.ox_target:removeZone(data.blipConfig.zoneId)
				end
			end
		end)
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	RunCleanUp()
end)

function RunCleanUp()
	LocalPlayer.state.TacoQueue = false
	LocalPlayer.state.TacoPickup = false
	if _dropOffBlipCfg ~= nil then
		exports["pulsar-blips"]:Remove(_dropOffBlipCfg.id)
		if exports.ox_target:zoneExists(_dropOffBlipCfg.zoneId) then
			exports.ox_target:removeZone(_dropOffBlipCfg.zoneId)
		end
	end
	_activeDropoffState = 0
	_dropOffBlipCfg = nil
	_dropOffBlip = nil
	_durationThread = false
	_durationCheck = _durationTimer
end
