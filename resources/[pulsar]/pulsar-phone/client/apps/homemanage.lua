RegisterNUICallback("Home:GetMyProperties", function(data, cb)
	local props = exports['pulsar-properties']:GetPropertiesWithAccess() or {}

	local upgrades = exports['pulsar-properties']:GetUpgradesConfig()

	cb({
		properties = props,
		upgrades = upgrades,
	})
end)

RegisterNUICallback("Home:StartPlacement", function(data, cb)
	cb(false)
end)

RegisterNUICallback("Home:CreateDigiKey", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Home:CreateDigiKey", data, cb)
end)

RegisterNUICallback("Home:RevokeDigiKey", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Home:RevokeDigiKey", data, cb)
end)

RegisterNUICallback("Home:RemoveMyKey", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Home:RemoveMyKey", data, cb)
end)

RegisterNUICallback("Home:LockProperty", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:Home:LockProperty", data, cb)
end)

RegisterNUICallback("Home:EditMode", function(data, cb)
	exports['pulsar-properties']:EditMode()
	cb("OK")
end)

RegisterNUICallback("Home:GetCurrentFurniture", function(data, cb)
	local p = exports['pulsar-properties']:GetCurrent(data.property)
	cb(p)
end)

RegisterNUICallback("Home:PlaceFurniture", function(data, cb)
	-- model, category
	cb(exports['pulsar-properties']:Place(data.model, data.category))
end)

RegisterNUICallback("Home:EditFurniture", function(data, cb)
	cb(exports['pulsar-properties']:Move(data.id))
end)

RegisterNUICallback("Home:DeleteFurniture", function(data, cb)
	cb(exports['pulsar-properties']:Delete(data.id))
end)

RegisterNUICallback("Home:HighlightFurniture", function(data, cb)
	cb(false)
	--cb(Properties.Furniture:Find(data.id))
end)

RegisterNUICallback("PurchasePropertyInterior", function(data, cb)
	-- data.int
	exports["pulsar-core"]:ServerCallback("Properties:ChangeInterior", data, cb)
end)

RegisterNUICallback("PurchasePropertyUpgrade", function(data, cb)
	-- data.upgrade
	exports["pulsar-core"]:ServerCallback("Properties:Upgrade", data, cb)
end)

RegisterNUICallback("PreviewPropertyInterior", function(data, cb)
	-- data.int
	cb("OK")
	exports['pulsar-properties']:Preview(data.int)
end)
