local _items = {
	perishable = {
		{ section = "perishable", item = "lettuce",  price = 1 },
		{ section = "perishable", item = "cucumber", price = 1 },
		{ section = "perishable", item = "tomato",   price = 1 },
		{ section = "perishable", item = "potato",   price = 1 },
		{ section = "perishable", item = "orange",   price = 1 },
		{ section = "perishable", item = "peas",     price = 1 },
	},
	crafting = {
		{ section = "crafting", item = "rubber",           price = 1 },
		{ section = "crafting", item = "plastic",          price = 1 },
		{ section = "crafting", item = "copperwire",       price = 1 },
		{ section = "crafting", item = "glue",             price = 1 },
		{ section = "crafting", item = "heavy_glue",       price = 1 },
		{ section = "crafting", item = "scrapmetal",       price = 1 },
		{ section = "crafting", item = "ironbar",          price = 1 },
		{ section = "crafting", item = "electronic_parts", price = 1 },
	},
}

AddEventHandler("Labor:Server:Startup", function()
	Wait(10000)
	local menu = {
		main = {
			label = "Goods Exporter",
			items = {
				{
					label = "Perishable Goods",
					submenu = "perishable",
				},
				{
					label = "Crafting Goods",
					submenu = "crafting",
				},
			},
		},
	}

	menu.perishable = {
		label = "Perishable Goods",
		items = {},
	}

	for k, v in ipairs(_items.perishable) do
		local itemData = exports.ox_inventory:ItemsGetData(v.item)
		table.insert(menu.perishable.items, {
			label = itemData.label,
			description = string.format("Export Price: $%s/unit", v.price),
			event = "Labor:Client:Export:Sell",
			data = v,
		})
	end

	menu.crafting = {
		label = "Crafting Goods",
		items = {},
	}

	for k, v in ipairs(_items.crafting) do
		local itemData = exports.ox_inventory:ItemsGetData(v.item)
		table.insert(menu.crafting.items, {
			label = itemData.label,
			description = string.format("Export Price: $%s/unit", v.price),
			event = "Labor:Client:Export:Sell",
			data = v,
		})
	end

	GlobalState["LaborExporter"] = menu

	exports["pulsar-core"]:RegisterServerCallback("Labor:Exporter:Sell", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if _items[data.section] ~= nil then
				for k, v in ipairs(_items[data.section]) do
					if data.item == v.item then
						local itemData = exports.ox_inventory:ItemsGetData(v.item)
						local count = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, v.item)
						if (count or 0) > 0 then
							if exports.ox_inventory:Remove(char:GetData("SID"), 1, v.item, count) then
								exports['pulsar-finance']:BalanceDeposit(
									exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID")).Account,
									count * v.price,
									{
										type = "deposit",
										title = "Goods Export",
										description = string.format(
											"Sold %s x%s at $%s/unit",
											itemData.label,
											count,
											v.price
										),
									},
									false
								)
							else
								exports['pulsar-core']:LoggerInfo(
									"Labor",
									string.format(
										"%s %s (%s) Failed to Sell %s (%s) at Goods Exporter",
										char:GetData("First"),
										char:GetData("Last"),
										char:GetData("SID"),
										v.item,
										count
									),
									{
										console = true,
										file = true,
										database = true,
										discord = {
											embed = true,
										},
									}
								)
								exports['pulsar-hud']:Notification(source, "error",
									string.format("Unable To Remove %s", itemData.label)
								)
							end
						else
							exports['pulsar-hud']:Notification(source, "error",
								string.format("You Have No %s", itemData.label)
							)
						end
						return
					end
				end
			end
		end
	end)
end)
