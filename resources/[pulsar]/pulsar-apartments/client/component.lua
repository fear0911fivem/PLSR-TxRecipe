local RESOURCE = GetCurrentResourceName()
local _roomZones = {}
local _elevatorZones = {}
local _interiorZones = {}
local _receptionPeds = {}
local _nearApartment = nil
local _insideApartment = nil
local _showerParticles = {}
local _isShowering = false
local _spawnedFurniture = {}
local _apartmentBlips = {}

local function SpawnRoomFurniture(furniture)
	if not furniture then return end
	for _, prop in ipairs(furniture) do
		local model = prop.model
		RequestModel(model)
		local t = 0
		while not HasModelLoaded(model) and t < 50 do Wait(10); t = t + 1 end
		if HasModelLoaded(model) then
			local obj = CreateObjectNoOffset(model, prop.x, prop.y, prop.z, false, false, false)
			if obj and obj ~= 0 then
				SetEntityHeading(obj, prop.h or 0.0)
				FreezeEntityPosition(obj, true)
				SetEntityInvincible(obj, true)
				table.insert(_spawnedFurniture, obj)
			end
			SetModelAsNoLongerNeeded(model)
		end
	end
end

local function ClearRoomFurniture()
	for _, obj in ipairs(_spawnedFurniture) do
		if DoesEntityExist(obj) then DeleteObject(obj) end
	end
	_spawnedFurniture = {}
end

local function Notify(type, message)
	exports["pulsar-hud"]:Notification(type, message)
end

local function Character()
	return LocalPlayer.state.Character
end

local function CharacterApartment()
	local char = Character()
	return char and tonumber(char:GetData("Apartment")) or nil
end

local function CharacterSID()
	local char = Character()
	return char and tonumber(char:GetData("SID")) or nil
end

local function RemoveZone(zoneId)
	if zoneId and exports.ox_target:zoneExists(zoneId) then
		exports.ox_target:removeZone(zoneId)
	end
end

local function ClearInteriorZones()
	for _, zoneId in pairs(_interiorZones) do
		RemoveZone(zoneId)
	end
	_interiorZones = {}
end

local function ZoneHeight(options)
	if options and options.minZ and options.maxZ then
		return math.abs(options.maxZ - options.minZ)
	end
	return 2.0
end

local function AddBoxTarget(name, zone, options)
	if not zone or not zone.coords then
		return nil
	end

	return exports.ox_target:addBoxZone({
		name = name,
		coords = zone.coords,
		size = vec3(zone.width or 1.0, zone.length or 1.0, ZoneHeight(zone.options)),
		rotation = zone.options and zone.options.heading or 0.0,
		debug = zone.options and zone.options.debugPoly or false,
		options = options,
	})
end

local function BuildRoomTargets()
	for _, zoneId in pairs(_roomZones) do
		RemoveZone(zoneId)
	end
	_roomZones = {}

	local apartments = GlobalState["Apartments"] or {}
	for _, aptId in ipairs(apartments) do
		local apt = GlobalState[string.format("Apartment:%s", aptId)]
		if apt and apt.coords then
			local zoneId = exports.ox_target:addBoxZone({
				name = string.format("apt-%s", aptId),
				coords = apt.coords,
				size = vec3(apt.width or 1.0, apt.length or 1.0, ZoneHeight(apt.options)),
				rotation = apt.options and apt.options.heading or 0.0,
				debug = apt.options and apt.options.debugPoly or false,
				options = {
					{
						name = string.format("apt_%s_request", aptId),
						label = "Request Entry",
						icon = "fas fa-bell",
						distance = 2.0,
						canInteract = function()
							return not LocalPlayer.state.isDead and CharacterApartment() ~= aptId
						end,
						onSelect = function()
							exports["pulsar-core"]:ServerCallback("Apartment:RequestEntry", {
								aptId = aptId,
							}, function(success)
								Notify(success and "success" or "error", success and "Entry request sent" or "Unable to request entry")
							end)
						end,
					},
					{
						name = string.format("apt_%s_raid", aptId),
						label = "Raid Apartment",
						icon = "fas fa-shield-halved",
						distance = 2.0,
						canInteract = function()
							return LocalPlayer.state.onDuty == "police" and not LocalPlayer.state.isDead
						end,
						onSelect = function()
							exports["pulsar-core"]:ServerCallback("Apartment:StartRaid", {
								apartmentId = aptId,
							}, function(success)
								Notify(success and "success" or "error", success and "Apartment door forced open" or "Unable to raid this apartment")
							end)
						end,
					},
				},
			})
			_roomZones[aptId] = zoneId
		end
	end
end

local function OpenElevatorMenu(buildingName, currentFloor)
	local elevatorFloors = Config.HotelElevators and Config.HotelElevators[buildingName]
	if not elevatorFloors then
		return
	end

	local options = {}
	local descriptions = Config.HotelElevatorsDesc and Config.HotelElevatorsDesc[buildingName] or {}
	for floor, floorData in pairs(elevatorFloors) do
		if type(floor) == "number" and floor ~= currentFloor and floorData[1] and floorData[1].pos then
			table.insert(options, {
				title = descriptions[floor] or string.format("Floor %s", floor),
				icon = "elevator",
				floor = floor,
				onSelect = function()
					TriggerEvent("Apartment:Client:UseElevator", {
						buildingName = buildingName,
						floor = floor,
					})
				end,
			})
		end
	end

	table.sort(options, function(a, b)
		return a.floor < b.floor
	end)

	lib.registerContext({
		id = string.format("apt_elevator_%s", buildingName),
		title = "Elevator",
		options = options,
	})
	lib.showContext(string.format("apt_elevator_%s", buildingName))
end

local function BuildElevatorTargets()
	for _, zoneId in pairs(_elevatorZones) do
		RemoveZone(zoneId)
	end
	_elevatorZones = {}

	if not Config.HotelElevators then
		return
	end

	for buildingName, floors in pairs(Config.HotelElevators) do
		for floor, elevators in pairs(floors) do
			if type(floor) == "number" then
				for elevatorIndex, elevator in pairs(elevators) do
					if type(elevatorIndex) == "number" and elevator.poly then
						local zoneId = exports.ox_target:addBoxZone({
							name = string.format("apt-elevator-%s-%s-%s", buildingName, floor, elevatorIndex),
							coords = elevator.poly.center,
							size = vec3(elevator.poly.width or 2.0, elevator.poly.length or 2.0, ZoneHeight(elevator.poly.options)),
							rotation = elevator.poly.options and elevator.poly.options.heading or 0.0,
							debug = elevator.poly.options and elevator.poly.options.debugPoly or false,
							options = {
								{
									name = "apt_elevator",
									label = "Use Elevator",
									icon = "fas fa-elevator",
									distance = 2.0,
									onSelect = function()
										OpenElevatorMenu(buildingName, floor)
									end,
								},
							},
						})
						table.insert(_elevatorZones, zoneId)
					end
				end
			end
		end
	end
end

local function BuildReceptionTarget()
	for _, ped in ipairs(_receptionPeds) do
		if DoesEntityExist(ped) then
			exports.ox_target:removeLocalEntity(ped)
			DeleteEntity(ped)
		end
	end
	_receptionPeds = {}

	if not Config.ReceptionPeds then return end

	local targetOptions = {
		{
			name = "apt_reception_room",
			label = "Get My Room",
			icon = "fas fa-key",
			distance = 2.0,
			onSelect = function()
				exports["pulsar-core"]:ServerCallback("Apartment:GetMyRoom", {}, function(result)
					if result and result.success then
						Notify("info", string.format("%s, Room %s, Floor %s", result.buildingName, result.roomLabel, result.floor))
					else
						Notify("error", result and result.message or "No apartment assigned")
					end
				end)
			end,
		},
		{
			name = "apt_reception_request",
			label = "Request Apartment",
			icon = "fas fa-building",
			distance = 2.0,
			onSelect = function()
				exports["pulsar-core"]:ServerCallback("Apartment:RequestApartment", {}, function(result)
					if result and result.success then
						Notify("success", string.format("Assigned Room %s", result.roomLabel))
					else
						Notify("error", result and result.message or "Unable to assign apartment")
					end
				end)
			end,
		},
	}

	for _, pedConfig in ipairs(Config.ReceptionPeds) do
		local modelHash = GetHashKey(pedConfig.model)
		RequestModel(modelHash)
		local t = 0
		while not HasModelLoaded(modelHash) and t < 50 do Wait(10); t = t + 1 end
		if HasModelLoaded(modelHash) then
			local c = pedConfig.coords
			local ped = CreatePed(4, modelHash, c.x, c.y, c.z, c.w, false, false)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetPedCanRagdoll(ped, false)
			FreezeEntityPosition(ped, true)
			SetModelAsNoLongerNeeded(modelHash)
			exports.ox_target:addLocalEntity(ped, targetOptions)
			table.insert(_receptionPeds, ped)
		end
	end
end

local function ClearApartmentBlips()
	for aptId, blipId in pairs(_apartmentBlips) do
		exports["pulsar-blips"]:Remove(blipId)
	end
	_apartmentBlips = {}
end

local function BuildApartmentBlips()
	ClearApartmentBlips()

	local apartments = GlobalState["Apartments"] or {}
	local seenBuildings = {}

	for _, aptId in ipairs(apartments) do
		local apt = GlobalState[string.format("Apartment:%s", aptId)]
		if apt and apt.coords and apt.buildingName and not seenBuildings[apt.buildingName] then
			local blipId = string.format("building_%s", apt.buildingName)
			local label = apt.buildingName
			if Config.HotelRooms and Config.HotelRooms[apt.buildingName] and Config.HotelRooms[apt.buildingName].label then
				label = Config.HotelRooms[apt.buildingName].label
			end
			exports["pulsar-blips"]:Add(blipId, label, apt.coords, 475, 2, 0.8, 2, "apartments")
			_apartmentBlips[apt.buildingName] = blipId
			seenBuildings[apt.buildingName] = true
		end
	end
end

local function BuildWorldTargets()
	BuildRoomTargets()
	BuildElevatorTargets()
	BuildReceptionTarget()
end

local function StartShowerParticle(showerHeadPos, aptId)
	RequestNamedPtfxAsset("core")
	while not HasNamedPtfxAssetLoaded("core") do
		Wait(10)
	end

	UseParticleFxAssetNextCall("core")
	local particle = StartParticleFxLoopedAtCoord(
		"ent_sht_water",
		showerHeadPos.x,
		showerHeadPos.y,
		showerHeadPos.z,
		0.0,
		0.0,
		0.0,
		1.0,
		false,
		false,
		false,
		false
	)
	TriggerServerEvent("Apartment:Server:StartShowerParticle", showerHeadPos, aptId)
	return particle
end

local function TakeShower(aptId)
	if _isShowering then
		Notify("error", "You are already showering")
		return
	end

	local apt = GlobalState[string.format("Apartment:%s", aptId)]
	if not apt or not apt.interior or not apt.interior.locations or not apt.interior.locations.shower then
		Notify("error", "This apartment has no shower")
		return
	end

	_isShowering = true
	local showerPos = apt.interior.locations.shower.coords
	local showerHeadPos = vector3(showerPos.x, showerPos.y, showerPos.z + 1.0)
	local particle = StartShowerParticle(showerHeadPos, aptId)

	exports["pulsar-hud"]:Progress({
		name = string.format("apartment_shower_%s", aptId),
		duration = 30000,
		label = "Showering",
		useWhileDead = false,
		canCancel = true,
		animation = {
			animDict = "anim@mp_yacht@shower@male@",
			anim = "male_shower_idle_d",
			flags = 1,
		},
	}, function(cancelled)
		if particle then
			StopParticleFxLooped(particle, false)
		end
		TriggerServerEvent("Apartment:Server:StopShowerParticle")
		_isShowering = false
		if not cancelled then
			Notify("success", "You feel refreshed")
		end
	end)
end

local function BuildInteriorTargets(aptId, unit)
	ClearInteriorZones()

	local apt = GlobalState[string.format("Apartment:%s", aptId)]
	if not apt or not apt.interior or not apt.interior.locations then
		return
	end

	local locations = apt.interior.locations

	_interiorZones.stash = AddBoxTarget(string.format("apt-%s-stash", aptId), locations.stash, {
		{
			name = "apt_stash",
			label = "Stash",
			icon = "fas fa-box",
			distance = 2.0,
			onSelect = function()
				exports[RESOURCE]:ExtrasStash()
			end,
		},
	})

	_interiorZones.wardrobe = AddBoxTarget(string.format("apt-%s-wardrobe", aptId), locations.wardrobe, {
		{
			name = "apt_wardrobe",
			label = "Wardrobe",
			icon = "fas fa-shirt",
			distance = 2.0,
			canInteract = function()
				return CharacterSID() == tonumber(unit)
			end,
			onSelect = function()
				exports[RESOURCE]:ExtrasWardrobe()
			end,
		},
	})

	_interiorZones.logout = AddBoxTarget(string.format("apt-%s-logout", aptId), locations.logout, {
		{
			name = "apt_logout",
			label = "Switch Characters",
			icon = "fas fa-bed",
			distance = 2.0,
			canInteract = function()
				return CharacterSID() == tonumber(unit)
			end,
			onSelect = function()
				exports[RESOURCE]:ExtrasLogout()
			end,
		},
	})

	_interiorZones.shower = AddBoxTarget(string.format("apt-%s-shower", aptId), locations.shower, {
		{
			name = "apt_shower",
			label = "Shower",
			icon = "fas fa-shower",
			distance = 2.0,
			canInteract = function()
				return CharacterSID() == tonumber(unit)
			end,
			onSelect = function()
				TakeShower(aptId)
			end,
		},
	})
end

RegisterNetEvent("Apartment:Client:InnerStuff", function(aptId, unit, wakeUp)
	_insideApartment = {
		aptId = aptId,
		unit = unit,
	}

	local apt = GlobalState[string.format("Apartment:%s", aptId)]
	if not apt then
		return
	end

	TriggerEvent("Interiors:Enter", vector3(apt.interior.spawn.x, apt.interior.spawn.y, apt.interior.spawn.z))
	BuildInteriorTargets(aptId, unit)

	local rooms = Config.HotelRooms[apt.buildingName]
	if rooms then
		local roomData = rooms[apt.roomIndex]
		if roomData and roomData.furniture then
			CreateThread(function()
				Wait(500)
				SpawnRoomFurniture(roomData.furniture)
			end)
		end
	end

	if wakeUp and apt.interior.wakeup then
		SetTimeout(250, function()
			exports["pulsar-animations"]:EmotesWakeUp(apt.interior.wakeup)
		end)
	end

	Wait(1000)
	exports["pulsar-sync"]:Stop(1)
end)

RegisterNetEvent("Apartment:Client:Enter", function(targetType, target, wakeUp)
	exports[RESOURCE]:Enter(targetType, target, wakeUp)
end)

RegisterNetEvent("Apartment:Client:StartShowerParticle", function(source, showerHeadPos, aptId)
	if source == GetPlayerServerId(PlayerId()) then
		return
	end

	RequestNamedPtfxAsset("core")
	while not HasNamedPtfxAssetLoaded("core") do
		Wait(10)
	end

	UseParticleFxAssetNextCall("core")
	_showerParticles[source] = StartParticleFxLoopedAtCoord(
		"ent_sht_water",
		showerHeadPos.x,
		showerHeadPos.y,
		showerHeadPos.z,
		0.0,
		0.0,
		0.0,
		1.0,
		false,
		false,
		false,
		false
	)
end)

RegisterNetEvent("Apartment:Client:StopShowerParticle", function(source)
	if _showerParticles[source] then
		StopParticleFxLooped(_showerParticles[source], false)
		_showerParticles[source] = nil
	end
end)

RegisterNetEvent("Apartment:Client:SelectBuilding", function()
	exports["pulsar-core"]:ServerCallback("Apartment:GetAvailableBuildings", {}, function(buildings)
		if not buildings or #buildings == 0 then
			Notify("error", "No apartments are currently available")
			return
		end

		SetNuiFocus(true, true)
		SendNuiMessage(json.encode({ action = "show", buildings = buildings }))
	end)
end)

RegisterNuiCallback("selectBuilding", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Apartment:SelectBuilding", { buildingName = data.buildingName }, function(result)
		cb(result)

		if not result or not result.success then
			Notify("error", result and result.message or "Assignment failed")
			return
		end

		SetNuiFocus(false, false)
		SendNuiMessage(json.encode({ action = "hide" }))

		Notify("success", string.format(
			"Welcome home! %s — Room %s, Floor %s. Check your phone for details.",
			result.buildingName, result.roomLabel, result.floor
		))

		CreateThread(function()
			DoScreenFadeOut(500)
			while not IsScreenFadedOut() do Wait(10) end

			exports["pulsar-core"]:ServerCallback("Apartment:SpawnInside", {}, function(spawnResult)
				Wait(500)
				DoScreenFadeIn(1000)
				if not spawnResult then
					Notify("error", "Could not enter apartment — use the elevator in the lobby")
				end
			end)
		end)
	end)
end)

RegisterNetEvent("Apartment:Client:ExitElevator", function()
	TriggerEvent("Interiors:Exit")
	exports["pulsar-sync"]:Start()
	ClearInteriorZones()
	ClearRoomFurniture()
	_insideApartment = nil
end)

RegisterNetEvent("Apartment:Client:RaidStateChanged", function(aptId, isRaided)
	if _nearApartment and _nearApartment.id == aptId then
		Notify(isRaided and "warning" or "info", isRaided and "Apartment raid started" or "Apartment raid ended")
	end
end)

AddEventHandler("Apartment:Client:DoRequestEntry", function(values, data)
	exports["pulsar-core"]:ServerCallback("Apartment:RequestEntry", {
		target = tonumber(values.unit),
		inZone = data,
	}, function(success)
		Notify(success and "success" or "error", success and "Entry request sent" or "Unable to request entry")
	end)
end)

AddEventHandler("Apartment:Client:DoRaid", function(values, data)
	exports["pulsar-core"]:ServerCallback("Apartment:StartRaid", {
		apartmentId = data.apartmentId,
		unit = tonumber(values.unit),
	}, function(success)
		if success then
			exports[RESOURCE]:Enter(data.apartmentId, tonumber(values.unit))
		else
			Notify("error", "Unable to raid this apartment")
		end
	end)
end)

AddEventHandler("Apartment:Client:UseElevator", function(data)
	local elevatorFloors = Config.HotelElevators and Config.HotelElevators[data.buildingName]
	local floorData = elevatorFloors and elevatorFloors[data.floor]
	local elevator = floorData and floorData[1]
	if not elevator or not elevator.pos then
		return
	end

	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end

	SetEntityCoords(PlayerPedId(), elevator.pos.x, elevator.pos.y, elevator.pos.z, false, false, false, false)
	SetEntityHeading(PlayerPedId(), elevator.pos.w or 0.0)

	TriggerServerEvent("Apartment:Server:ElevatorFloorChanged", data.buildingName, data.floor)

	Wait(250)
	DoScreenFadeIn(500)
end)

exports("Enter", function(tier, id, wakeUp)
	exports["pulsar-core"]:ServerCallback("Apartment:Enter", {
		tier = tier,
		id = id or -1,
	}, function(result)
		if not result then
			Notify("error", "Unable to enter apartment")
			return
		end

		local apt = GlobalState[string.format("Apartment:%s", result)]
		if not apt then
			return
		end

		exports["pulsar-sounds"]:PlayOne("door_open.ogg", 0.15)
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Wait(10)
		end

		FreezeEntityPosition(PlayerPedId(), true)
		SetEntityCoords(PlayerPedId(), apt.interior.spawn.x, apt.interior.spawn.y, apt.interior.spawn.z, false, false, false, false)
		Wait(100)
		SetEntityHeading(PlayerPedId(), apt.interior.spawn.h or 0.0)
		FreezeEntityPosition(PlayerPedId(), false)

		DoScreenFadeIn(1000)
	end)
end)

exports("Exit", function()
	local state = LocalPlayer.state.inApartment or _insideApartment
	if not state then
		return
	end

	local aptId = state.type or state.aptId
	local apt = GlobalState[string.format("Apartment:%s", aptId)]
	if not apt then
		return
	end

	exports["pulsar-core"]:ServerCallback("Apartment:Exit", {}, function()
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Wait(10)
		end

		TriggerEvent("Interiors:Exit")
		exports["pulsar-sync"]:Start()
		exports["pulsar-sounds"]:PlayOne("door_close.ogg", 0.3)
		ClearInteriorZones()
		ClearRoomFurniture()
		_insideApartment = nil

		SetEntityCoords(PlayerPedId(), apt.coords.x, apt.coords.y, apt.coords.z, false, false, false, false)
		SetEntityHeading(PlayerPedId(), apt.heading or 0.0)

		DoScreenFadeIn(1000)
	end)
end)

exports("GetNearApartment", function()
	return _nearApartment
end)

exports("ExtrasStash", function()
	local state = LocalPlayer.state.inApartment or _insideApartment
	if not state then
		return
	end

	exports.ox_inventory:openInventory("stash", {
		id = string.format("apartment_%s", state.type or state.aptId),
	})
end)

exports("ExtrasWardrobe", function()
	exports["pulsar-core"]:ServerCallback("Apartment:Validate", {
		type = "wardrobe",
	}, function(valid)
		if valid then
			exports["pulsar-ped"]:WardrobeShow()
		end
	end)
end)

exports("ExtrasLogout", function()
	exports["pulsar-core"]:ServerCallback("Apartment:Validate", {
		type = "logout",
	}, function(valid)
		if valid then
			TriggerServerEvent("Apartment:Server:LogoutCleanup")
			exports["pulsar-characters"]:Logout()
		end
	end)
end)

AddEventHandler("onClientResourceStart", function(resource)
	if resource == RESOURCE then
		Wait(1500)
		BuildWorldTargets()
		BuildApartmentBlips()
	end
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	Wait(1000)
	BuildWorldTargets()
	BuildApartmentBlips()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	ClearInteriorZones()
	ClearRoomFurniture()
	ClearApartmentBlips()
	_insideApartment = nil
	_nearApartment = nil
end)

CreateThread(function()
	while true do
		local closest = nil
		local closestDist = 999.0
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local apartments = GlobalState["Apartments"] or {}

		for _, aptId in ipairs(apartments) do
			local apt = GlobalState[string.format("Apartment:%s", aptId)]
			if apt and apt.coords then
				local dist = #(coords - apt.coords)
				if dist < closestDist and dist <= 3.0 then
					closest = apt
					closestDist = dist
				end
			end
		end

		_nearApartment = closest
		Wait(1000)
	end
end)
