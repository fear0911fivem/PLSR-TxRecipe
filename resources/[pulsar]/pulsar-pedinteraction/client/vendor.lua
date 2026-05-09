local _created = {}

RegisterNetEvent("Vendor:Client:Set", function(vendors)
	for k, v in pairs(vendors) do
		_created[v.id] = {
			name = v.name,
			type = v.type,
		}

		if v.type == "ped" then
			exports['pulsar-pedinteraction']:Add(v.id, v.model, v.position.coords, v.position.heading, 50.0, {
					{
						icon = v.iconOverride or "fas fa-question",
						text = v.labelOverride or "Buy Items",
						minDist = 2.0,
						onSelect = function()
							TriggerEvent("Vendor:Client:GetItems", v.id)
						end,
					},
				}, v.iconOverride or "fas fa-question", v.position.scenario or false, v.position.anim or nil,
				v.position.component or nil)
		elseif v.type == "poly" then
			exports.ox_target:addBoxZone({
				id = v.id,
				coords = v.position.coords,
				size = vector3(v.position.length, v.position.width, 2.0),
				rotation = v.position.options.heading or 0,
				debug = false,
				minZ = v.position.options.minZ,
				maxZ = v.position.options.maxZ,
				options = {
					{
						icon = v.iconOverride or "fas fa-question",
						label = v.labelOverride or "Buy Items",
						distance = 2.0,
						onSelect = function()
							TriggerEvent("Vendor:Client:GetItems", v.id)
						end,
					},
				}
			})
		end
	end
end)

RegisterNetEvent(
	"Vendor:Client:Add",
	function(id, name, type, model, position, iconOverride, labelOverride, isUnique, isGlobalUnique)
		if LocalPlayer.state.loggedIn then
			_created[id] = {
				name = name,
				type = type,
				isUnique = isUnique,
				isGlobalUnique = isGlobalUnique,
			}

			if type == "ped" then
				exports['pulsar-pedinteraction']:Add(id, model, position.coords, position.heading, 50.0, {
					{
						icon = iconOverride or "fas fa-question",
						text = labelOverride or "Buy Items",
						minDist = 2.0,
						jobs = false,
						onSelect = function()
							TriggerEvent("Vendor:Client:GetItems", id)
						end,
					},
				}, iconOverride or "fas fa-question", position.scenario or false, position.anim or false)
			elseif type == "poly" then
				exports.ox_target:addBoxZone({
					id = id,
					coords = position.coords,
					size = vector3(position.length, position.width, 2.0),
					rotation = position.options.heading or 0,
					debug = false,
					minZ = position.options.minZ,
					maxZ = position.options.maxZ,
					options = {
						{
							icon = iconOverride or "fas fa-question",
							label = labelOverride or "Buy Items",
							distance = 2.0,
							onSelect = function()
								TriggerEvent("Vendor:Client:GetItems", id)
							end,
						},
					}
				})
			end
		end
	end
)

RegisterNetEvent("Vendor:Client:Remove", function(id)
	if LocalPlayer.state.loggedIn then
		if _created[id].type == "ped" then
			exports['pulsar-pedinteraction']:Remove(id)
		elseif _created[id].type == "poly" then
			if exports.ox_target:zoneExists(id) then
				exports.ox_target:removeZone(id)
			end
		end

		_created[id] = nil
	end
end)

AddEventHandler("Vendor:Client:GetItems", function(entity, data)
	-- Handle both direct ID parameter and args data
	local vendorId = data and data.id or entity
	exports["pulsar-core"]:ServerCallback("Vendor:GetItems", vendorId, function(items)
		local itemList = {}

		if #items > 0 then
			for k, v in ipairs(items) do
				local itemData = exports.ox_inventory:ItemsGetData(v.item)
				if v.delayed then
					table.insert(itemList, {
						label = itemData.label,
						description = "Not For Sale Yet",
					})
				elseif v.qty == -1 or v.qty > 0 then
					local stockStr = _created[vendorId].isUnique and "Stock: 1 Per Person, Per Tsunami"
						or (v.qty == -1 and "Stock: ∞" or string.format("Stock: %s", v.qty))
					local priceStr = v.coin ~= nil and string.format("%s $%s", v.price, v.coin)
						or string.format("$%s", v.price)
					local descStr = string.format("%s | %s", stockStr, priceStr)

					table.insert(itemList, {
						label = itemData.label,
						description = descStr,
						event = "Vendor:Client:BuyItem",
						data = {
							id = vendorId,
							index = v.index,
						},
					})
				else
					table.insert(itemList, {
						label = itemData.label,
						description = "Sold Out",
					})
				end
			end
		end

		if #itemList <= 0 then
			table.insert(itemList, {
				label = "No Items Available",
			})
		end

		exports['pulsar-hud']:ListMenuShow({
			main = {
				label = _created[vendorId].name,
				items = itemList,
			},
		})
	end)
end)

AddEventHandler("Vendor:Client:BuyItem", function(data)
	exports["pulsar-core"]:ServerCallback("Vendor:BuyItem", data)
end)
