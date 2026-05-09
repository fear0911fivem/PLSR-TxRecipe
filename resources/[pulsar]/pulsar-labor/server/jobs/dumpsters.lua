local _searchedDumpsters = {}
local _lockedDumpsters = {}
local _dumpsterLockVal = 3
local _repName = "DumpsterDiving"

AddEventHandler("Labor:Server:Startup", function()
	RegisterDumpsterCallbacks()
	RegisterDumpsterStartup()
end)

function RegisterDumpsterStartup()
	exports['pulsar-characters']:RepCreate(_repName, "Dumpster Diving", {
		{ label = "Rank 1",  value = 1000 },
		{ label = "Rank 2",  value = 2500 },
		{ label = "Rank 3",  value = 5000 },
		{ label = "Rank 4",  value = 10000 },
		{ label = "Rank 5",  value = 25000 },
		{ label = "Rank 6",  value = 50000 },
		{ label = "Rank 7",  value = 100000 },
		{ label = "Rank 8",  value = 250000 },
		{ label = "Rank 9",  value = 500000 },
		{ label = "Rank 10", value = 1000000 },
	})
end

function RegisterDumpsterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Inventory:Server:AvailableDumpster", function(source, entity, cb)
		local _dumpsterId = entity
		if entity and _searchedDumpsters[_dumpsterId] == nil then
			cb(true)
		else
			cb(false)
		end
	end)
	exports["pulsar-core"]:RegisterServerCallback("Inventory:Dumpster:HidePlayer", function(source, data, cb)
		local plyr = exports['pulsar-core']:FetchSource(source)
		local _dumpsterId = data.identifier
		local _locked = data.locked
		if plyr ~= nil then
			if not Player(source).state.isCuffed and not Player(source).state.isDead then
				if _lockedDumpsters[_dumpsterId] == nil then
					if _locked == _dumpsterLockVal then
						_lockedDumpsters[_dumpsterId] = true
					else
						_lockedDumpsters[_dumpsterId] = false
					end
					cb(true, _lockedDumpsters[_dumpsterId])
				else
					cb(true, _lockedDumpsters[_dumpsterId])
				end
			else
				cb(false, false)
			end
		else
			cb(false, false)
		end
	end)
	exports["pulsar-core"]:RegisterServerCallback("Inventory:Server:SearchDumpster", function(source, entity, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local _dumpsterId = entity
			if entity and _searchedDumpsters[_dumpsterId] == nil then
				_searchedDumpsters[_dumpsterId] = true
				local _PlayerRep = exports['pulsar-characters']:RepGetLevel(source, _repName) or 0
				local _found = math.random(100) >= math.random(75)
				if _found then
					if _PlayerRep >= 8 then
						if math.random(100) >= math.random(75) then
							exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
								_dumpsterLoot.high,
								char:GetData("SID"),
								1,
								1,
								false
							)
						end
						if math.random(100) >= math.random(75) then
							exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
								_dumpsterLoot.medium,
								char:GetData("SID"),
								1,
								1,
								false
							)
						end
						exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
							_dumpsterLoot.low,
							char:GetData("SID"),
							1,
							1,
							false
						)
					elseif _PlayerRep <= 7 and _PlayerRep >= 4 then
						if math.random(100) >= math.random(75) then
							exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
								_dumpsterLoot.medium,
								char:GetData("SID"),
								1,
								1,
								false
							)
						end
						exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
							_dumpsterLoot.low,
							char:GetData("SID"),
							1,
							1,
							false
						)
						exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
							_dumpsterLoot.low,
							char:GetData("SID"),
							1,
							1,
							false
						)
					else
						exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
							_dumpsterLoot.low,
							char:GetData("SID"),
							1,
							1,
							false
						)
						exports.ox_inventory:LootCustomWeightedSetWithCountAndModifier(
							_dumpsterLoot.low,
							char:GetData("SID"),
							1,
							1,
							false
						)
					end
					exports['pulsar-characters']:RepAdd(source, _repName, math.random(5, 10))
					exports['pulsar-hud']:Notification(source, "success", "You found something!")
				else
					exports['pulsar-characters']:RepAdd(source, _repName, math.random(1, 3))
					exports['pulsar-hud']:Notification(source, "info", "Nothing was found.")
				end
				cb(true)
			else
				exports['pulsar-hud']:Notification(source, "error",
					"This dumpster has been searched already!")
				cb(false)
			end
		else
			cb(false)
		end
	end)
end
