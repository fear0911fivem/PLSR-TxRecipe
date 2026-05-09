_placedProps = {}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterClientCallback("Objects:StartPlacement", function(data, cb)
			exports['pulsar-objects']:PlacerStart(data.model, "Objects:Client:FinishPlacement", data.data, true, nil,
				true)
			cb()
		end)
	end
end)

AddEventHandler("Objects:Client:FinishPlacement", function(data, endCoords)
	TriggerServerEvent("Objects:Server:Create", data, endCoords)
end)

RegisterNetEvent("Objects:Client:SetupObjects", function(objs)
	for k, v in pairs(objs) do
		exports['pulsar-objects']:Create(k, v.type, v.creator, v.model, v.coords, v.heading, v.rotation, v.isFrozen,
			v.nameOverride)
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	for k, v in pairs(_placedProps) do
		exports['pulsar-objects']:Delete(k)
	end
end)

RegisterNetEvent("Objects:Client:Create",
	function(id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
		exports['pulsar-objects']:Create(id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
	end)

RegisterNetEvent("Objects:Client:Delete", function(id)
	exports['pulsar-objects']:Delete(id)
end)

exports('Create', function(id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
	loadModel(model)
	local obj = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)

	if rotation and rotation.x then
		SetEntityRotation(obj, rotation.x, rotation.y, rotation.z)
	elseif heading then
		SetEntityHeading(obj, heading + 0.0)
	end

	FreezeEntityPosition(obj, isFrozen)
	while not DoesEntityExist(obj) do
		Wait(1)
	end

	local entState = Entity(obj).state
	entState.isPlacedProp = true
	entState.objectId = id

	_placedProps[id] = {
		id = id,
		type = type,
		creator = creator,
		entity = obj,
		model = model,
		coords = coords,
		heading = heading,
		rotation = rotation,
		isFrozen = isFrozen,
		nameOverride = nameOverride,
	}

	exports.ox_target:addEntity(obj, {
		{
			icon = "eye",
			label = "Open",
			event = "Objects:Client:OpenInventory",
			distance = 3.0,
			canInteract = function(entity)
				local eState = Entity(entity).state
				return eState.isPlacedProp and _placedProps[entState.objectId].type == 1
			end,
		},
		{
			icon = "trash",
			label = "Delete Object",
			event = "Objects:Client:DeleteObject",
			distance = 3.0,
			canInteract = function(entity)
				local eState = Entity(entity).state
				return eState.isPlacedProp
					and (LocalPlayer.state.IsStaff or LocalPlayer.state.isAdmin or LocalPlayer.state.Character:GetData(
						"SID"
					) == _placedProps[entState.objectId].creator)
					and _placedProps[entState.objectId].type ~= 2
			end,
		},
		{
			icon = "info",
			label = "View Object Details",
			event = "Objects:Client:ViewData",
			distance = 3.0,
			canInteract = function(entity)
				local eState = Entity(entity).state
				return eState.isPlacedProp
					and (LocalPlayer.state.isStaff or LocalPlayer.state.isAdmin)
					and _placedProps[entState.objectId].type ~= 2
			end,
		},
	})
end)

exports('Delete', function(id)
	if _placedProps[id] ~= nil then
		DeleteEntity(_placedProps[id].entity)
		_placedProps[id] = nil
	else
		return false
	end
end)

AddEventHandler("Objects:Client:DeleteObject", function(entity, data)
	if Entity(entity).state.isPlacedProp then
		TriggerServerEvent("Objects:Server:Delete", Entity(entity).state.objectId)
	end
end)

AddEventHandler("Objects:Client:ViewData", function(entity, data)
	TriggerServerEvent("Objects:Server:View", Entity(entity).state.objectId)
end)

AddEventHandler("Objects:Client:OpenInventory", function(entity, data)
	exports.ox_inventory:DumbfuckOpen({
		invType = 138,
		owner = Entity(entity).state.objectId,
	})
end)
