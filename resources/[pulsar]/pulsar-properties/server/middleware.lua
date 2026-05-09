function RegisterMiddleware()
	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		TriggerLatentClientEvent("Properties:Client:Load", source, 50000, _properties,
			_charPropertyKeys[char:GetData("ID")])
	end)

	exports['pulsar-core']:MiddlewareAdd("Characters:GetSpawnPoints", function(source, charId)
		local p = promise.new()

		exports.oxmysql:execute(
			'SELECT * FROM properties WHERE JSON_EXTRACT(`keys`, CONCAT("$.", ?)) IS NOT NULL AND foreclosed = 0 AND type NOT IN (?, ?)',
			{ charId, "container", "warehouse" }, function(results)
				if not results or not #results then
					p:resolve({})
					return
				end
				local spawns = {}

				local keys = {}

				for k, v in ipairs(results) do
					table.insert(keys, v.id)
					local property = _properties[v.id]
					if property ~= nil then
						local interior = property.upgrades and property.upgrades.interior
						local interiorData = PropertyInteriors[interior]

						local icon = "house"
						if property.type == "warehouse" then
							icon = "warehouse"
						elseif property.type == "office" then
							icon = "building"
						end

						if interiorData ~= nil then
							table.insert(spawns, {
								id = property.id,
								label = property.label,
								location = {
									x = interiorData.locations.front.coords.x,
									y = interiorData.locations.front.coords.y,
									z = interiorData.locations.front.coords.z,
									h = interiorData.locations.front.heading,
								},
								icon = icon,
								event = "Properties:SpawnInside",
							})
						end
					end
				end
				_charPropertyKeys[charId] = keys
				p:resolve(spawns)
			end)

		return Citizen.Await(p)
	end, 3)
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	_charPropertyKeys[cData.ID] = nil
	local property = GlobalState[string.format("%s:Property", source)]
	if property then
		if _insideProperties[property] then
			_insideProperties[property][source] = nil
		end

		GlobalState[string.format("%s:Property", source)] = nil
	end

	if Player(source) and Player(source).state and Player(source).state.tpLocation then
		Player(source).state.tpLocation = nil
	end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	_charPropertyKeys[cData.ID] = nil
	local property = GlobalState[string.format("%s:Property", source)]
	if property then
		if _insideProperties[property] then
			_insideProperties[property][source] = nil
		end

		GlobalState[string.format("%s:Property", source)] = nil
	end

	if Player(source) and Player(source).state and Player(source).state.tpLocation then
		Player(source).state.tpLocation = nil
	end
end)
