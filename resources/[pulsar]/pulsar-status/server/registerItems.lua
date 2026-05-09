local alcoholItems = {
	wine_glass = "wine",
	beer = "beer",
	whiskey = "whiskey",
	vodka = "vodka",
	tequila = "tequila",
	rum = "rum",
	whiskey_glass = "whiskey_glass",
	vodka_shot = "vodka_shot",
	tequila_shot = "tequila_shot",
	tequila_sunrise = "tequila_sunrise",
	pina_colada = "cocktail",
	raspberry_mimosa = "cocktail",
	bahama_mamas = "cocktail",
	bloody_mary = "cocktail",
	jaeger_bomb = "jaeger_bomb",
	diamond_drink = "diamond_drink",
	pint_mcdougles = "pint_mcdougles",
}

function registerUsables()
	exports.ox_inventory:RegisterUse("wine_bottle", "Status", function(source, itemData)
		local currentMeta = itemData.MetaData or {}
		if not currentMeta.GlassesRemaining then
			currentMeta.GlassesRemaining = 4
		end

		if currentMeta.GlassesRemaining >= 1 then
			currentMeta.GlassesRemaining -= 1
			currentMeta = exports.ox_inventory:UpdateMetaData(itemData.id, currentMeta)
			exports.ox_inventory:AddItem(itemData.Owner, "wine_glass", 1, {}, 1)
		else
			exports['pulsar-hud']:Notification(source, "error", "Bottle is Empty!")
		end
	end)

	for k, v in pairs(alcoholItems) do
		exports.ox_inventory:RegisterUse(k, "Status", function(source, itemData)
			exports["pulsar-core"]:ClientCallback(source, "Status:DrinkAlcohol", v, function(success)
				if success then
					exports.ox_inventory:RemoveSlot(itemData.Owner, itemData.Name, 1, itemData.Slot,
						itemData.invType)
				end
			end)
		end)
	end

	exports.ox_inventory:RegisterUse("scuba_gear", "Status", function(source, slot, itemData)
		exports["pulsar-core"]:ClientCallback(source, "Status:UseScubaGear", {}, function(success)
			if success then
				local newValue = slot.CreateDate - (60 * 60 * 24 * 20)
				if os.time() - itemData.durability >= newValue then
					exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
				else
					exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
				end
			end
		end)
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		registerUsables()
	end
end)
