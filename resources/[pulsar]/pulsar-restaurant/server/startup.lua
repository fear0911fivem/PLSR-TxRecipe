_pickups = {}
_warmers = {}
_fridges = {}

function Startup()
	for k, v in ipairs(Config.Restaurants) do
		exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registering Restaurant ^3%s^7", v.Name))
		
		if v.Pickups then
			for num, pickup in pairs(v.Pickups) do
				table.insert(_pickups, pickup.id)
				pickup.num = num
				pickup.job = v.Job
				pickup.jobName = v.Name
				
				local stashId = string.format("restaurant_pickup_%s", pickup.id)
				exports.ox_inventory:RegisterStash(
					stashId,
					string.format("%s Pickup #%s", v.Name, num),
					10,  -- slots
					10000,  -- maxWeight
					pickup.id  -- owner
				)
				
				pickup.data = pickup.data or {}
				pickup.data.inventory = "stash"
				pickup.data.inventoryId = stashId

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Pickup ^3%s^7 for Restaurant ^3%s^7", pickup.id, v.Name))
				
				GlobalState[string.format("Restaurant:Pickup:%s", pickup.id)] = pickup
			end
		end

		if v.Warmers then
			for _, warmer in pairs(v.Warmers) do
				if warmer.restrict and warmer.restrict.jobs then
					for _, jobId in ipairs(warmer.restrict.jobs) do
						if _warmers[jobId] == nil then
							_warmers[jobId] = {}
						end
						table.insert(_warmers[jobId], warmer.id)
					end
				end
				
				local stashId = string.format("restaurant_warmer_%s", warmer.id)
				exports.ox_inventory:RegisterStash(
					stashId,
					string.format("%s Warmer", v.Name),
					80,  -- slots
					100000,  -- maxWeight
					warmer.id  -- owner
				)
				
				warmer.data = warmer.data or {}
				warmer.data.inventory = "stash"
				warmer.data.inventoryId = stashId

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Warmer ^3%s^7 for Restaurant ^3%s^7", warmer.id, v.Name))
				
				GlobalState[string.format("Restaurant:Warmers:%s", warmer.id)] = warmer
			end
		end

		if v.Fridges then
			for _, fridge in pairs(v.Fridges) do
				if fridge.restrict and fridge.restrict.jobs then
					for _, jobId in ipairs(fridge.restrict.jobs) do
						if _fridges[jobId] == nil then
							_fridges[jobId] = {}
						end
						table.insert(_fridges[jobId], fridge.id)
					end
				end
				
				local stashId = string.format("restaurant_fridge_%s", fridge.id)
				exports.ox_inventory:RegisterStash(
					stashId,
					string.format("%s Fridge", v.Name),
					80,  -- slots
					100000,  -- maxWeight
					fridge.id  -- owner
				)
				
				fridge.data = fridge.data or {}
				fridge.data.inventory = "stash"
				fridge.data.inventoryId = stashId

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Fridge ^3%s^7 for Restaurant ^3%s^7", fridge.id, v.Name))
				
				GlobalState[string.format("Restaurant:Fridges:%s", fridge.id)] = fridge
			end
		end
	end
end
