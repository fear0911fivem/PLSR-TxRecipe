function RegisterItems()
	exports.ox_inventory:RegisterUse("present", "Xmas", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local sid = char:GetData("SID")
			exports.ox_inventory:RemoveId(sid, 1, item)
			exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(_xmasConfig.Loot.present, sid, 1, 1,
				false)
		end
	end)

	exports.ox_inventory:RegisterUse("present_daily", "Xmas", function(source, item)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local sid = char:GetData("SID")
			exports.ox_inventory:RemoveId(sid, 1, item)
			exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(_xmasConfig.Loot.daily, sid, 1, 1,
				false)
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItems()
	end
end)
