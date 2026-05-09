local characterLoaded = false
local addedZones = {}
local wCombozone

local polyDebug = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterClientCallback("Polyzone:GetZoneAtCoords", function(data, cb)
			cb(exports['pulsar-polyzone']:GetZoneAtCoords(data))
		end)

		exports["pulsar-core"]:RegisterClientCallback("Polyzone:GetZonePlayerIn", function(data, cb)
			local c = GetEntityCoords(LocalPlayer.state.ped)
			cb(exports['pulsar-polyzone']:GetZoneAtCoords(vector3(c.x, c.y, c.z)))
		end)

		exports["pulsar-core"]:RegisterClientCallback("Polyzone:GetAllZonesAtCoords", function(data, cb)
			cb(exports['pulsar-polyzone']:GetAllZonesAtCoords(data))
		end)

		exports["pulsar-core"]:RegisterClientCallback("Polyzone:GetAllZonesPlayerIn", function(data, cb)
			local c = GetEntityCoords(LocalPlayer.state.ped)
			cb(exports['pulsar-polyzone']:GetAllZonesAtCoords(vector3(c.x, c.y, c.z)))
		end)

		exports["pulsar-core"]:RegisterClientCallback("Polyzone:IsCoordsInZone", function(data, cb)
			cb(exports['pulsar-polyzone']:IsCoordsInZone(data.coords, data.id, data.key, data.val))
		end)
	end
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	characterLoaded = true
	InitWrapperZones()
end)

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
	characterLoaded = false
	for k, v in pairs(addedZones) do
		TriggerEvent("Polyzone:Exit", k, false, false, v.data or {})
	end
	polyDebug = false
	TriggerEvent("Targeting:Client:PolyzoneDebug", false)
	if wCombozone then
		wCombozone:destroy()
		wCombozone = nil
		exports['pulsar-core']:LoggerTrace("Polyzone", "Destroyed All Polyzones (Character Logout)")
	end
end)

function CreateZoneForCombo(id, data)
	local options = data.options
	options.name = id
	options.data = (type(data.data) == "table" and data.data or {})
	options.data.id = id

	if data.type == "circle" then
		return CircleZone:Create(data.center, data.radius, data.options)
	elseif data.type == "poly" then
		return PolyZone:Create(data.points, data.options)
	elseif data.type == "box" then
		return BoxZone:Create(data.center, data.length, data.width, data.options)
	end
end

function InitWrapperZones()
	if wCombozone then
		return
	end

	local createdZones = {}

	for k, v in pairs(addedZones) do
		local zone = CreateZoneForCombo(k, v)
		table.insert(createdZones, zone)
	end

	exports['pulsar-core']:LoggerTrace("Polyzone", string.format("Initialized %s Simple Polyzones", #createdZones))

	wCombozone = ComboZone:Create(createdZones, {
		name = "wrapper_combo",
	})

	wCombozone:onPlayerInOutExhaustive(function(isPointInside, testedPoint, insideZones, enteredZones, leftZones)
		if not characterLoaded then
			return
		end

		if enteredZones then
			for id, zone in ipairs(enteredZones) do
				if zone.data and zone.data.id then
					TriggerEvent("Polyzone:Enter", zone.data.id, testedPoint, insideZones, zone.data)
				end
			end
		end

		if leftZones then
			for id, zone in ipairs(leftZones) do
				if zone.data and zone.data.id then
					TriggerEvent("Polyzone:Exit", zone.data.id, testedPoint, insideZones, zone.data)
				end
			end
		end
	end)
end

function AddZoneAfterCreation(id, zoneData)
	if not wCombozone then
		return
	end
	local zone = CreateZoneForCombo(id, zoneData)
	wCombozone:AddZone(zone)
end

exports("CreateBox", function(id, center, length, width, options, data)
	local existingZone = addedZones[id]

	if existingZone and wCombozone then
		exports['pulsar-polyzone']:Remove(id)
		Wait(100)
	end

	addedZones[id] = {
		id = id,
		type = "box",
		center = center,
		width = width,
		length = length,
		options = options,
		data = data,
	}

	AddZoneAfterCreation(id, addedZones[id])
end)

exports("CreatePoly", function(id, points, options, data)
	local existingZone = addedZones[id]

	if existingZone and wCombozone then
		exports['pulsar-polyzone']:Remove(id)
		Wait(100)
	end

	addedZones[id] = {
		id = id,
		type = "poly",
		points = points,
		options = options,
		data = data,
	}

	AddZoneAfterCreation(id, addedZones[id])
end)

exports("CreateCircle", function(id, center, radius, options, data)
	local existingZone = addedZones[id]

	if existingZone and wCombozone then
		exports['pulsar-polyzone']:Remove(id)
		Wait(100)
	end

	addedZones[id] = {
		id = id,
		type = "circle",
		center = center,
		radius = radius,
		options = options,
		data = data,
	}

	AddZoneAfterCreation(id, addedZones[id])
end)

exports("Remove", function(id)
	if addedZones[id] then
		if wCombozone then
			wCombozone:RemoveZone(id)
			TriggerEvent("Polyzone:Exit", id, false, false, addedZones[id].data or {})
		end
		addedZones[id] = nil
	end
	return false
end)

exports("Get", function(id)
	return addedZones[id]
end)

-- !! WARNING WON'T WORK FOR OVERLAPPING ZONES SO BETTER OFF NOT USING IT !!
exports("GetZoneAtCoords", function(coords)
	if not wCombozone then
		return false
	end
	local isInside, insideZone = wCombozone:isPointInside(coords)
	if isInside and insideZone and insideZone.data then
		return insideZone.data
	end
	return false
end)

exports("GetAllZonesAtCoords", function(coords)
	local withinZonesData = {}
	local isInside, insideZones = wCombozone:isPointInsideExhaustive(coords)
	if isInside and insideZones and #insideZones > 0 then
		for k, v in ipairs(insideZones) do
			table.insert(withinZonesData, v.data)
		end
	end
	return withinZonesData
end)

exports("IsCoordsInZone", function(coords, id, key, val)
	local isInside, insideZones = wCombozone:isPointInsideExhaustive(coords)
	if isInside and insideZones and #insideZones > 0 then
		for k, v in ipairs(insideZones) do
			if
				(not id or v.data.id == id)
				and (not key or ((val == nil and v.data[key]) or (val ~= nil and v.data[key] == val)))
			then
				return v.data
			end
		end
	end
	return false
end)

RegisterNetEvent("Polyzone:Client:ToggleDebug", function()
	polyDebug = not polyDebug

	TriggerEvent("Targeting:Client:PolyzoneDebug", polyDebug)
	if polyDebug and LocalPlayer.state.isAdmin then
		exports['pulsar-core']:LoggerWarn("Polyzone", "Polyzone Debug Enabled")
		CreateThread(function()
			while polyDebug do
				if wCombozone then
					wCombozone:draw()
				else
					Wait(500)
				end
				Wait(0)
			end
		end)
	end
end)
