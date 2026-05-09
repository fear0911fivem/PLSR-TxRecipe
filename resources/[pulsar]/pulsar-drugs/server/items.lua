_effectCds = {
	meth = {},
	coke = {},
	adrenaline = {},
	moonshine = {},
}

function RegisterItemUse()
	exports.ox_inventory:RegisterUse("meth_table", "DrugShit", function(source, slot, itemData)
		exports['pulsar-drugs']:StorePlacementData(source, slot)
		exports["pulsar-core"]:ClientCallback(source, "Drugs:Meth:PlaceTable", slot.slot, function() end)
	end)

	exports.ox_inventory:RegisterUse("moonshine_still", "DrugShit", function(source, slot, itemData)
		exports['pulsar-drugs']:StorePlacementData(source, slot)
		exports["pulsar-core"]:ClientCallback(source, "Drugs:Moonshine:PlaceStill", slot.slot, function() end)
	end)

	exports.ox_inventory:RegisterUse("moonshine_barrel", "DrugShit", function(source, slot, itemData)
		exports['pulsar-drugs']:StorePlacementData(source, slot)
		exports["pulsar-core"]:ClientCallback(source, "Drugs:Moonshine:PlaceBarrel", slot.slot, function() end)
	end)

	exports.ox_inventory:RegisterUse("adrenaline", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _effectCds.adrenaline[char:GetData("SID")] == nil or os.time() > _effectCds.adrenaline[char:GetData("SID")] then
				_effectCds.adrenaline[char:GetData("SID")] = os.time() + (60 * 1)
				if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1) then
					exports["pulsar-core"]:ClientCallback(source, "Drugs:Adrenaline:Use", 100, function(s)
						if s then
							TriggerClientEvent("Drugs:Effects:Armor", source, 100)
						end
					end)
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "Cannot Use That Yet")
			end
		end
	end)

	exports.ox_inventory:RegisterUse("meth_pipe", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _effectCds.meth[char:GetData("SID")] == nil or os.time() > _effectCds.meth[char:GetData("SID")] then
				local methItem = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "meth_bag", 1)
				if methItem?.id ~= nil then
					_effectCds.meth[char:GetData("SID")] = os.time() + (60 * 1)
					if exports.ox_inventory:RemoveId(char:GetData("SID"), 1, methItem) then
						exports["pulsar-core"]:ClientCallback(source, "Drugs:Meth:Use", methItem.Quality, function(s)
							if s then
								exports['pulsar-drugs']:AddictionAdd(source, "Meth", 0.25)
								local drugStates = char:GetData("DrugStates") or {}
								drugStates["meth"] = {
									item = "meth_bag",
									expires = os.time() + (60 * 60),
								}
								char:SetData("DrugStates", drugStates)
								TriggerClientEvent("Drugs:Effects:Armor", source, methItem.Quality)
							end
						end)
					end
				else
					exports['pulsar-hud']:Notification(source, "error", "You Need Meth To Smoke")
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "Cannot Use That Yet")
			end
		end
	end)

	exports.ox_inventory:RegisterUse("meth_brick", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if os.time() >= slot.MetaData.Finished then
			if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
				exports.ox_inventory:AddItem(
					char:GetData("SID"),
					"meth_bag",
					10,
					{},
					1,
					false,
					false,
					false,
					false,
					false,
					false,
					slot.Quality
				)
			end
		else
			exports['pulsar-hud']:Notification(source, "error", "Not Ready Yet", 6000)
		end
	end)

	-- exports.ox_inventory:RegisterUse("meth_bag", "DrugShit", function(source, slot, itemData)
	-- 	local plyr = exports['pulsar-core']:FetchSource(source)
	-- 	if plyr ~= nil then
	-- 		local char = plyr:GetData("Character")
	-- 		if char ~= nil then
	-- 			if _effectCds.meth[char:GetData("SID")] == nil or os.time() > _effectCds.meth[char:GetData("SID")] then
	-- 				_effectCds.meth[char:GetData("SID")] = os.time() + (60 * 1)
	-- 				if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
	-- 					exports["pulsar-core"]:ClientCallback(source, "Drugs:Meth:Use", slot.Quality, function(s)
	-- 						if s then
	-- 							exports['pulsar-drugs']:AddictionAdd(source, "Meth", 0.25)
	-- 							TriggerClientEvent("Drugs:Effects:Armor", source, slot.Quality)
	-- 						end
	-- 					end)
	-- 				end
	-- 			else
	-- 				exports['pulsar-hud']:Notification(source, "error", "Cannot Use That Yet")
	-- 			end
	-- 		end
	-- 	end
	-- end)

	exports.ox_inventory:RegisterUse("coke_brick", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
			exports.ox_inventory:AddItem(
				char:GetData("SID"),
				"coke_bag",
				10,
				{},
				1,
				false,
				false,
				false,
				false,
				false,
				false,
				slot.Quality
			)
		end
	end)

	exports.ox_inventory:RegisterUse("coke_bag", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _effectCds.coke[char:GetData("SID")] == nil or os.time() > _effectCds.coke[char:GetData("SID")] then
				_effectCds.coke[char:GetData("SID")] = os.time() + (60 * 3)
				if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
					exports["pulsar-core"]:ClientCallback(source, "Drugs:Coke:Use", slot.Quality, function(s)
						if s then
							exports['pulsar-drugs']:AddictionAdd(source, "Coke", 0.25)
							TriggerClientEvent("Drugs:Effects:RunSpeed", source, slot.Quality)
						end
					end)
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "Cannot Use That Yet")
			end
		end
	end)

	exports.ox_inventory:RegisterUse("moonshine", "DrugShit", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _effectCds.moonshine[char:GetData("SID")] == nil or os.time() > _effectCds.moonshine[char:GetData("SID")] then
				_effectCds.moonshine[char:GetData("SID")] = os.time() + (60 * 3)
				if exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, slot.invType) then
					-- Get recipe from metadata, default to "classic"
					local recipeId = (slot.MetaData and slot.MetaData.Recipe) or "classic"
					local quality = slot.Quality or 50
					
					exports["pulsar-core"]:ClientCallback(source, "Drugs:Moonshine:Use", {
						quality = quality,
						recipeId = recipeId,
					}, function(s)
						if s then
							exports['pulsar-drugs']:AddictionAdd(source, "Moonshine", 0.25)
							local drugStates = char:GetData("DrugStates") or {}
							drugStates["moonshine"] = {
								item = "moonshine",
								expires = os.time() + (60 * 30),
							}
							char:SetData("DrugStates", drugStates)
							TriggerClientEvent("Drugs:Effects:Moonshine", source, quality, recipeId)
						end
					end)
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "Cannot Use That Yet")
			end
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItemUse()
	end
end)
