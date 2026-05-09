function SetupTree(treeData, hasLooted)
	if _existingTree ~= nil then
		DeleteEntity(_existingTree.entity)
		exports.ox_target:removeEntity(_existingTree.entity)
		exports["pulsar-blips"]:Remove("xmas_tree")
		_existingTree = nil
	end

	loadModel(treeData.model)

	local obj =
		CreateObject(treeData.model, treeData.location.x, treeData.location.y, treeData.location.z, false, true, true)
	PlaceObjectOnGroundProperly(obj)
	FreezeEntityPosition(obj, true)
	SetCanClimbOnEntity(obj, false)

	exports.ox_target:addEntity(obj, {
		{
			icon = "gift",
			label = "Pickup Gift",
			event = "Xmas:Client:Tree",
			canInteract = function()
				return _existingTree ~= nil and not _existingTree.hasLooted
			end,
		},
	})

	exports["pulsar-blips"]:Add(
		"xmas_tree",
		"Christmas Tree",
		vector3(treeData.location.x, treeData.location.y, treeData.location.z),
		36,
		25,
		0.85
	)

	SetModelAsNoLongerNeeded(treeData.model)

	_existingTree = treeData
	_existingTree.hasLooted = hasLooted
	_existingTree.entity = obj
end

AddEventHandler("Xmas:Client:RegisterStartups", function()
	exports['pulsar-hud']:InteractionRegisterMenu("pickup-snowball", "Pickup Snowball", "snowflake", function(data)
		exports['pulsar-hud']:InteractionHide()
		exports['pulsar-xmas']:SnowballsPickup()
	end, function()
		return exports['pulsar-xmas']:SnowballsCanPickup()
	end)
end)

exports("SnowballsPickup", function()
	exports['pulsar-hud']:Progress({
		name = "snowball_pickup",
		duration = 5000,
		label = "Making a snowball",
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "anim@mp_snowball",
			anim = "pickup_snowball",
			flags = 49,
		},
	}, function(cancelled)
		if not cancelled then
			exports["pulsar-core"]:ServerCallback("Xmas:Server:PickupSnowball", {}, function(s) end)
		end
	end)
end)

exports("SnowballsCanPickup", function()
	return _isChristmasMonth and CheckZone()
end)
