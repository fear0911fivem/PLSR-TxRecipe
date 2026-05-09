_properties = {}
_myPropertyKeys = {}

_propertiesLoaded = false

_insideProperty = false
_insideInterior = false
_insideFurniture = {}
_AllHousesBlips = {}

_furnitureCategory = {}
_furnitureCategoryCurrent = 1

_placingFurniture = false

_allowBrowse = true
_skipPhone = false

_placingSearchItem = nil

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		CreatePropertyDoor(false)
		CreatePropertyDoor(true)

		exports['pulsar-hud']:InteractionRegisterMenu("house-exit", "Exit", "door-open", function(data)
			exports['pulsar-hud']:InteractionHide()
			ExitProperty(data, data == 'back')
		end, function()
			if _insideProperty and _insideInterior then
				local interior = PropertyInteriors[_insideInterior]

				if interior then
					local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.front.coords)

					if dist <= 2.0 then
						return 'front'
					elseif interior.locations.back then
						backDist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.back.coords)
						if backDist <= 2.0 then
							return 'back'
						end
					end
				end
			end

			return false
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("house-lock", "Lock", "lock", function(data)
			exports['pulsar-hud']:InteractionHide()
			exports["pulsar-core"]:ServerCallback("Properties:ChangeLock", {
				id = data,
				state = true,
			}, function(state)
				if state then
					exports["pulsar-hud"]:Notification("success", "Property Locked")
				else
					exports["pulsar-hud"]:Notification("error", "Unable to Lock Property")
				end
			end)
		end, function()
			if _insideProperty and _insideInterior and _propertiesLoaded then
				if _properties[_insideProperty.id].locked then
					return false
				end

				local interior = PropertyInteriors[_insideInterior]

				local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.front.coords)
				local backDist
				if interior.locations.back then
					backDist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.back.coords)
				end

				if (dist <= 2.0 or (backDist and backDist <= 2.0)) then
					return _insideProperty.id
				end
			end

			return false
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("house-unlock", "Unlock", "unlock", function(data)
			exports['pulsar-hud']:InteractionHide()
			exports["pulsar-core"]:ServerCallback("Properties:ChangeLock", {
				id = data,
				state = false,
			}, function(state)
				if state then
					exports["pulsar-hud"]:Notification("success", "Property Unlocked")
				else
					exports["pulsar-hud"]:Notification("error", "Unable to Unlock Property")
				end
			end)
		end, function()
			if _insideProperty and _insideInterior and _propertiesLoaded then
				local property = _properties[_insideProperty.id]
				if
					property.locked
					and (
						(property.keys ~= nil and property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil)
						or (
							not property.sold
							and LocalPlayer.state.onDuty == "realestate"
							and exports['pulsar-jobs']:HasPermissionInJob("realestate", "JOB_DOORS")
						)
					)
				then
					local interior = PropertyInteriors[_insideInterior]
					local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.front.coords)
					local backDist
					if interior.locations.back then
						backDist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - interior.locations.back.coords)
					end

					if (dist <= 2.0 or (backDist and backDist <= 2.0)) then
						return _insideProperty.id
					end
				else
					return false
				end
			else
				return false
			end

			return false
		end)

		for k, v in pairs(PropertyInteriors) do
			if v.zone then
				exports['pulsar-polyzone']:CreateBox(
					string.format("property-int-zone-%s", k),
					v.zone.center,
					v.zone.length,
					v.zone.width,
					v.zone.options,
					{
						PROPERTY_INTERIOR_ZONE = true,
					}
				)
			end
		end

		exports["pulsar-kbs"]:Add("furniture_prev", "LEFT", "keyboard", "Furniture - Previous Item", function()
			if _placingFurniture then
				CycleFurniture()
			elseif _previewingInterior and not _previewingInteriorSwitching then
				PrevPreview()
			end
		end)

		exports["pulsar-kbs"]:Add("furniture_next", "RIGHT", "keyboard", "Furniture - Next Item", function()
			if _placingFurniture then
				CycleFurniture(true)
			elseif _previewingInterior and not _previewingInteriorSwitching then
				NextPreview()
			end
		end)
	end
end)

function CreatePropertyDoor(isBackdoor)
	exports['pulsar-hud']:InteractionRegisterMenu(isBackdoor and "property-backdoor" or "property",
		isBackdoor and "Property Backdoor" or "Property", isBackdoor and "house-window" or "house", function(data)
			local pMenu = {
				{
					icon = "door-open",
					label = isBackdoor and "Enter Backdoor" or "Enter",
					action = function()
						EnterProperty(data, isBackdoor)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end

						local prop = _properties[data.propertyId]
						return ((prop.keys ~= nil and prop.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil)
							or (not prop.sold and LocalPlayer.state.onDuty == "realestate" and exports['pulsar-jobs']:HasPermissionInJob(
								"realestate",
								"JOB_DOORS"
							))
							or not prop.locked) and not prop.foreclosed
					end,
				},
				{
					icon = "lock-open",
					label = "Unlock",
					action = function()
						exports["pulsar-core"]:ServerCallback("Properties:ChangeLock", {
							id = data.propertyId,
							state = false,
						}, function(state)
							if state then
								exports["pulsar-hud"]:Notification("success", "Property Unlocked")
							else
								exports["pulsar-hud"]:Notification("error", "Unable to Unlock Property")
							end
							exports['pulsar-hud']:InteractionHide()
						end)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end
						local prop = _properties[data.propertyId]
						if
							((prop.keys ~= nil and prop.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil)
								or (
									not prop.sold
									and LocalPlayer.state.onDuty == "realestate"
									and exports['pulsar-jobs']:HasPermissionInJob("realestate", "JOB_DOORS")
								)) and not prop.foreclosed
						then
							return prop.locked
						else
							return false
						end
					end,
				},
				{
					icon = "lock",
					label = "Lock",
					action = function()
						exports["pulsar-core"]:ServerCallback("Properties:ChangeLock", {
							id = data.propertyId,
							state = true,
						}, function(state)
							if state then
								exports["pulsar-hud"]:Notification("success", "Property Locked")
							else
								exports["pulsar-hud"]:Notification("error", "Unable to Unlock Property")
							end
							exports['pulsar-hud']:InteractionHide()
						end)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end
						local prop = _properties[data.propertyId]

						if
							((prop.keys ~= nil and prop.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil)
								or (
									not prop.sold
									and LocalPlayer.state.onDuty == "realestate"
									and exports['pulsar-jobs']:HasPermissionInJob("realestate", "JOB_DOORS")
								)) and not prop.foreclosed
						then
							return not prop.locked
						else
							return false
						end
					end,
				},
				{
					icon = "house-chimney-crack",
					label = "Property is Foreclosed",
					action = function()
						exports["pulsar-hud"]:Notification("error",
							'This Property Has Been Foreclosed! This is why you should pay your property loans...', 10000)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end
						local prop = _properties[data.propertyId]
						return prop.foreclosed
					end,
				},
			}

			if not isBackdoor then
				table.insert(pMenu, {
					icon = "bells",
					label = "Ring Doorbell",
					action = function()
						exports["pulsar-core"]:ServerCallback("Properties:RingDoorbell", data.propertyId, function()
							exports["pulsar-sounds"]:PlayOne("doorbell.ogg", 0.75)
						end)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end
						local prop = _properties[data.propertyId]
						return prop.sold and not prop.foreclosed and prop.type == "house"
					end,
				})

				table.insert(pMenu, {
					icon = "sign-hanging",
					label = "Request Agent",
					action = function()
						exports["pulsar-core"]:ServerCallback("Properties:RequestAgent", data.propertyId,
							function(state)
								if state then
									exports["pulsar-hud"]:Notification("success", "Notification Sent")
								else
									exports["pulsar-hud"]:Notification("error", "Unable To Send Notification")
								end
								exports['pulsar-hud']:InteractionHide()
							end)
					end,
					shouldShow = function()
						if not _propertiesLoaded then
							return false
						end
						local prop = _properties[data.propertyId]
						return prop and not prop.sold
					end,
				})
			end

			exports['pulsar-hud']:InteractionShowMenu(pMenu)
		end, function()
			if not _propertiesLoaded then
				return false
			end

			if isBackdoor then
				return exports['pulsar-properties']:GetNearHouseBackdoor()
			else
				return exports['pulsar-properties']:GetNearHouse()
			end
		end, function()
			if not _propertiesLoaded then
				return false
			end
			if isBackdoor then
				local prop = exports['pulsar-properties']:GetNearHouseBackdoor()
				return type(prop) == "table" and _properties[prop.propertyId]?.label or 'Property'
			else
				local prop = exports['pulsar-properties']:GetNearHouse()
				return type(prop) == "table" and _properties[prop.propertyId]?.label or 'Property'
			end
		end)
end

RegisterNetEvent("Properties:Client:Load", function(props, myKeys)
	_properties = props
	_myPropertyKeys = myKeys or {}

	_propertiesLoaded = true
end)

RegisterNetEvent("Properties:Client:Update", function(id, data)
	if _properties and _propertiesLoaded then
		_properties[id] = data
	end
end)

RegisterNetEvent("Properties:Client:SetLocks", function(id, state)
	if _properties and _propertiesLoaded and _properties[id] then
		_properties[id].locked = state
	end
end)

local showingAllPropsBlips = false
RegisterNetEvent("Properties:Client:ShowAllPropertyBlips", function(show)
	if showingAllPropsBlips then
		exports["pulsar-hud"]:Notification("info", "Property Blips Hidden")
		for k, v in ipairs(_AllHousesBlips) do
			RemoveBlip(v)
		end
		_AllHousesBlips = {}
		showingAllPropsBlips = false
	else
		exports["pulsar-hud"]:Notification("info", "Property Blips Enabled")
		showingAllPropsBlips = true
		AddTextEntry("PROPERTYBLIP", "Properties Available")
		AddTextEntry("PROPERTYBLIPS", "Properties Sold")

		for k, v in pairs(_properties) do
			local coords = v.location
			if v.sold then
				local HouseBlip = AddBlipForCoord(coords.front.x, coords.front.y, coords.front.z)
				SetBlipSprite(HouseBlip, 375)
				SetBlipColour(HouseBlip, 1)
				SetBlipScale(HouseBlip, 0.45)
				SetBlipAsShortRange(HouseBlip, true)
				BeginTextCommandSetBlipName("PROPERTYBLIPS")
				EndTextCommandSetBlipName(HouseBlip)
				table.insert(_AllHousesBlips, HouseBlip)
			else
				local HouseBlip = AddBlipForCoord(coords.front.x, coords.front.y, coords.front.z)
				SetBlipSprite(HouseBlip, 375)
				SetBlipColour(HouseBlip, 2)
				SetBlipScale(HouseBlip, 0.65)
				SetBlipAsShortRange(HouseBlip, true)
				BeginTextCommandSetBlipName("PROPERTYBLIP")
				EndTextCommandSetBlipName(HouseBlip)

				table.insert(_AllHousesBlips, HouseBlip)
			end
		end
	end
	if show then

	else

	end
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
	_propertiesLoaded = false
	_properties = {}

	collectgarbage()

	DestroyFurniture()

	_insideProperty = false
	_insideInterior = false

	_placingFurniture = false
	LocalPlayer.state.placingFurniture = false
	LocalPlayer.state.furnitureEdit = false

	if #_AllHousesBlips > 0 then
		for k, v in ipairs(_AllHousesBlips) do
			RemoveBlip(v)
		end

		_AllHousesBlips = {}
	end
end)

exports('Enter', function(id)
	EnterProperty({
		propertyId = id,
	}, false)
end)

exports('GetProperties', function()
	if _propertiesLoaded then
		return _properties
	end
	return false
end)

exports('GetPropertiesWithAccess', function()
	if LocalPlayer.state.loggedIn and _propertiesLoaded then
		local props = {}
		for k, v in pairs(_properties) do
			if v and v.keys and v.keys[LocalPlayer.state.Character:GetData("ID")] then
				table.insert(props, v)
			end
		end

		return props
	end
	return false
end)

exports('Get', function(pId)
	return _properties[pId]
end)

exports('GetUpgradesConfig', function()
	return PropertyUpgrades
end)

exports('GetNearHouse', function()
	if LocalPlayer.state.currentRoute ~= 0 or not _propertiesLoaded then
		return false
	end

	local myPos = GetEntityCoords(LocalPlayer.state.ped)
	local closest = nil
	for k, v in pairs(_properties) do
		local dist = #(myPos - vector3(v.location.front.x, v.location.front.y, v.location.front.z))
		if dist < 3.0 and (not closest or dist < closest.dist) then
			closest = {
				dist = dist,
				propertyId = v.id,
			}
		end
	end
	return closest
end)

exports('GetNearHouseBackdoor', function()
	if LocalPlayer.state.currentRoute ~= 0 or not _propertiesLoaded then
		return false
	end

	local myPos = GetEntityCoords(LocalPlayer.state.ped)
	local closest = nil
	for k, v in pairs(_properties) do
		if v.location.backdoor then
			local dist = #(myPos - vector3(v.location.backdoor.x, v.location.backdoor.y, v.location.backdoor.z))
			if dist < 3.0 and (not closest or dist < closest.dist) then
				closest = {
					dist = dist,
					propertyId = v.id,
				}
			end
		end
	end
	return closest
end)

exports('GetNearHouseGarage', function(coordOverride)
	if LocalPlayer.state.currentRoute ~= 0 or not _propertiesLoaded then
		return false
	end

	local myPos = GetEntityCoords(LocalPlayer.state.ped)
	local closest = nil
	for k, v in pairs(_properties) do
		if v.location.garage then
			local dist = #(myPos - vector3(v.location.garage.x, v.location.garage.y, v.location.garage.z))
			if dist < 3.0 and (not closest or dist < closest.dist) then
				closest = {
					coords = v.location.garage,
					dist = dist,
					propertyId = v.id,
				}
			end
		end
	end
	return closest
end)

exports('GetInside', function()
	return _insideProperty
end)

exports('Stash', function()
	exports["pulsar-core"]:ServerCallback("Properties:Validate", {
		id = GlobalState[string.format("%s:Property", LocalPlayer.state.ID)],
		type = "stash",
	})
end)

exports('Closet', function()
	exports["pulsar-core"]:ServerCallback("Properties:Validate", {
		id = GlobalState[string.format("%s:Property", LocalPlayer.state.ID)],
		type = "closet",
	}, function(state)
		if state then
			exports['pulsar-ped']:WardrobeShow()
		end
	end)
end)

exports('Logout', function()
	exports["pulsar-core"]:ServerCallback("Properties:Validate", {
		id = GlobalState[string.format("%s:Property", LocalPlayer.state.ID)],
		type = "logout",
	}, function(state)
		if state then
			exports['pulsar-characters']:Logout()
		end
	end)
end)

exports('HasAccessWithData', function(key, value)
	if LocalPlayer.state.loggedIn and _propertiesLoaded then
		for _, propertyId in ipairs(_myPropertyKeys) do
			local property = _properties[propertyId]
			if property and property.data and ((value == nil and property.data[key]) or property.data[key] == value) then
				return property.id
			end
		end
	end
	return false
end)

exports('GetCurrent', function(property)
	if _insideProperty and _insideProperty.id == property._id then
		for k, v in ipairs(_insideFurniture) do
			v.dist = #(GetEntityCoords(LocalPlayer.state.ped) - vector3(v.coords.x, v.coords.y, v.coords.z))
		end
		return {
			success = true,
			furniture = _insideFurniture,
			catalog = FurnitureConfig,
			categories = FurnitureCategories,
		}
	end

	return {
		err = "Must be Inside the Property!"
	}
end)

exports('EditMode', function(state)
	if state == nil then
		state = not LocalPlayer.state.furnitureEdit
	end

	if _insideProperty then
		SetFurnitureEditMode(state)
	end
end)

exports('Place', function(model, category, metadata, blockBrowse, skipPhone, startCoords, startRot)
	if not _insideProperty then
		return false
	end

	if not category then
		category = FurnitureConfig[model].cat
	end

	if category == "search" then
		_placingSearchItem = model
	end

	_allowBrowse = not blockBrowse

	_placingFurniture = true
	LocalPlayer.state.placingFurniture = true

	_furnitureCategory = {}
	for k, v in pairs(FurnitureConfig) do
		if v.cat == category then
			table.insert(_furnitureCategory, k)
		end
	end

	table.sort(_furnitureCategory, function(a, b)
		return (FurnitureConfig[a]?.id or 1) < (FurnitureConfig[b]?.id or 1)
	end)

	for k, v in ipairs(_furnitureCategory) do
		if v == model then
			_furnitureCategoryCurrent = k
		end
	end

	local fData = FurnitureConfig[model]
	if fData then
		exports['pulsar-hud']:InfoOverlayShow(fData.name,
			string.format("Category: %s | Model: %s", FurnitureCategories[fData.cat]?.name or "Unknown", model))
	end

	exports['pulsar-objects']:PlacerStart(GetHashKey(model), "Furniture:Client:Place", metadata, tru,
		"Furniture:Client:Cancel",
		true, true, startCoords, nil, startRot)
	if not skipPhone then
		exports['pulsar-phone']:Close(true, true)
	end
	_skipPhone = skipPhone

	DisablePauseMenu(true)

	return true
end)

exports('Move', function(id, skipPhone)
	if not _insideProperty then
		return false
	end

	_furnitureCategoryCurrent = nil

	for k, v in ipairs(_insideFurniture) do
		if v.id == id then
			furn = v
		end
	end

	if not furn then
		return false
	end

	_placingFurniture = true
	LocalPlayer.state.placingFurniture = true

	local ns = {}
	for k, v in ipairs(_spawnedFurniture) do
		if v.id == id then
			DeleteEntity(v.entity)
			exports.ox_target:removeEntity(v.entity)
		else
			table.insert(ns, v)
		end
	end
	_spawnedFurniture = ns

	local fData = FurnitureConfig[model]

	exports['pulsar-objects']:PlacerStart(GetHashKey(furn.model), "Furniture:Client:Move", { id = id }, true,
		"Furniture:Client:CancelMove", true, true, furn.coords, furn.heading, furn.rotation)
	if not skipPhone then
		exports['pulsar-phone']:Close(true, true)
	end
	_skipPhone = skipPhone

	DisablePauseMenu(true)

	return true
end)

exports('Delete', function(id)
	if not _insideProperty then
		return false
	end

	local catCounts = {
		["storage"] = 0,
	}
	local fData
	for k, v in ipairs(_insideFurniture) do
		if v.id == id then
			fData = FurnitureConfig[v.model]
		else
			local d = FurnitureConfig[v.model]
			if not catCounts[d.cat] then
				catCounts[d.cat] = 0
			end

			catCounts[d.cat] += 1
		end
	end

	if fData and fData.cat == "storage" and catCounts["storage"] < 1 then
		exports["pulsar-hud"]:Notification("error", "You Are Required to Have At Least One Storage Container!")
		return false
	end

	local p = promise.new()

	exports["pulsar-core"]:ServerCallback("Properties:DeleteFurniture", {
		id = id,
	}, function(success, furniture)
		if success then
			exports["pulsar-hud"]:Notification("success", "Deleted Item")
			for k, v in ipairs(furniture) do
				v.dist = #(GetEntityCoords(LocalPlayer.state.ped) - vector3(v.coords.x, v.coords.y, v.coords.z))
			end
			p:resolve(furniture)
		else
			p:resolve(false)
			exports["pulsar-hud"]:Notification("error", "Unable to Delete Furniture")
		end
	end)

	return Citizen.Await(p)
end)

exports('Preview', function(int)
	StartPreview(int)
end)

RegisterNetEvent("Properties:Client:Enter", function(id)
	exports['pulsar-properties']:EnterProperty(id)
end)

AddEventHandler("RealEstate:Client:AcceptTransfer", function()
	TriggerServerEvent("RealEstate:Server:AcceptTransfer")
end)

AddEventHandler("RealEstate:Client:DenyTransfer", function()
	TriggerServerEvent("RealEstate:Server:DenyTransfer")
end)
