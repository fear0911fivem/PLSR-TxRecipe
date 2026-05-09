function HandcuffItems()
	-- exports.ox_inventory:RegisterUse("pdhandcuffs", "Handcuffs", function(source, item)
	-- 	exports["pulsar-core"]:ClientCallback(source, "Handcuffs:VehCheck", {}, function(inVeh)
	-- 		if not inVeh then
	-- 			exports['pulsar-police']:ToggleCuffs(source)
	-- 		end
	-- 	end)
	-- end)

	-- exports.ox_inventory:RegisterUse("handcuffs", "Handcuffs", function(source, item)
	-- 	exports["pulsar-core"]:ClientCallback(source, "Handcuffs:VehCheck", {}, function(inVeh)
	-- 		if not inVeh then
	-- 			exports['pulsar-police']:ToggleCuffs(source)
	-- 		end
	-- 	end)
	-- end)

	-- exports.ox_inventory:RegisterUse("fluffyhandcuffs", "Handcuffs", function(source, item)
	-- 	exports["pulsar-core"]:ClientCallback(source, "Handcuffs:VehCheck", {}, function(inVeh)
	-- 		if not inVeh then
	-- 			exports['pulsar-police']:ToggleCuffs(source)
	-- 		end
	-- 	end)
	-- end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		HandcuffItems()
	end
end)
