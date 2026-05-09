_isEntering = false

RegisterNetEvent("Properties:Client:Doorbell", function(propertyId)
	if _insideProperty and propertyId == _insideProperty.id then
		exports["pulsar-sounds"]:PlayOne("doorbell.ogg", 0.75)
	end
end)

RegisterNetEvent("Properties:Client:InnerStuff", function(propertyData, int, furniture)
	_insideProperty = propertyData
	_insideInterior = int
	_isEntering = true

	local interior = PropertyInteriors[int]

	TriggerEvent("Interiors:Enter", interior.locations.front.coords, propertyData.id, int, propertyData.data)

	-- if wakeUp and intr.locations.wakeup then
	-- 	SetTimeout(250, function()
	-- 		exports['pulsar-animations']:EmotesWakeUp(intr.locations.wakeup)
	-- 	end)
	-- end

	exports["pulsar-sync"]:Stop(1)

	CreatePropertyZones(propertyData.id, int)

	CreateFurniture(furniture)

	_isEntering = false

	Wait(500)
	exports["pulsar-sync"]:Stop(1)
end)

---- TARGETTING EVENTS ----
AddEventHandler("Properties:Client:Stash", function(data)
	exports['pulsar-properties']:Stash()
end)

AddEventHandler("Properties:Client:Closet", function(data)
	exports['pulsar-properties']:Closet()
end)

AddEventHandler("Properties:Client:Logout", function(data)
	exports['pulsar-properties']:Logout()
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if LocalPlayer.state.loggedIn and data.PROPERTY_INTERIOR_ZONE and _insideProperty and not _isEntering then
		print("Exit Property By Leaving Polyzone")
		ExitProperty()
	end
end)

AddEventHandler("Properties:Client:Exit", function(data)
	ExitProperty(data.property, data.backdoor)
end)

AddEventHandler("Properties:Client:Crafting", function(data)
	exports.ox_inventory:CraftingBenchesOpen('property-' .. data)
end)

AddEventHandler("Properties:Client:Duty", function(data)
	if not _propertiesLoaded then
		return
	end

	local property = _properties[data]
	if property?.data?.jobDuty then
		if LocalPlayer.state.onDuty == property?.data?.jobDuty then
			exports['pulsar-jobs']:DutyOff(property?.data?.jobDuty)
		else
			exports['pulsar-jobs']:DutyOn(property?.data?.jobDuty)
		end
	end
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	TriggerEvent("Properties:Client:AddBlips")
end)

RegisterNetEvent("Properties:Client:AddBlips", function()
	while LocalPlayer.state.Character == nil or not _propertiesLoaded or not LocalPlayer.state.loggedIn do
		Wait(100)
	end

	local ownedProps = exports['pulsar-properties']:GetPropertiesWithAccess()

	if ownedProps then
		for k, v in ipairs(ownedProps) do
			if v.type == 'house' then
				exports["pulsar-blips"]:Add('property-' .. v.id, 'House: ' .. v.label,
					vector3(v.location.front.x, v.location.front.y, v.location.front.z), 40, 53, 0.6, 2)
			elseif v.type == 'office' then
				exports["pulsar-blips"]:Add('property-' .. v.id, 'Office: ' .. v.label,
					vector3(v.location.front.x, v.location.front.y, v.location.front.z), 475, 53, 0.6, 2)
			elseif v.type == 'warehouse' then
				exports["pulsar-blips"]:Add('property-' .. v.id, 'Warehouse: ' .. v.label,
					vector3(v.location.front.x, v.location.front.y, v.location.front.z), 473, 53, 0.6, 2)
			end
		end
	end
end)
