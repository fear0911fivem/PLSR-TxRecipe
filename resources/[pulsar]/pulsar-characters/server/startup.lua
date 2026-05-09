Spawns = {}

function Startup()
	exports['pulsar-characters']:GetAllLocations("spawn", function(results)
		if not results then
			exports['pulsar-core']:LoggerError("Characters", "Failed to load spawn locations")
			return
		end

		exports['pulsar-core']:LoggerTrace("Characters", "Loaded ^2" .. #results .. "^7 Spawn Locations",
			{ console = true })

		for k, v in ipairs(results) do
			local spawn = {
				id = v.id,
				label = v.label,
				location = { x = v.location.x, y = v.location.y, z = v.location.z, h = v.location.h },
			}
			table.insert(Spawns, spawn)
		end
	end)
end
