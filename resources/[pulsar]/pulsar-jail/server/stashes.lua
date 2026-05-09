local _jailStashLocs = {
	[1] = {
		type = "box",
		coords = vector3(1707.83, 2553.05, 45.56),
		length = 1.8,
		width = 0.8,
		options = {
			heading = 0,
			-- debugPoly=true,
			minZ = 42.56,
			maxZ = 46.56,
		},
		stashType = "self",
	},
	[2] = {
		type = "box",
		coords = vector3(1763.72, 2487.0, 45.74),
		length = 1.6,
		width = 1.8,
		options = {
			heading = 0,
			-- debugPoly=true,
			minZ = 42.74,
			maxZ = 46.74,
		},
		stashType = "self",
	},
	[3] = {
		type = "box",
		coords = vector3(1736.37, 2541.75, 43.59),
		length = 1.6,
		width = 1.6,
		options = {
			heading = 0,
			-- debugPoly=true,
			minZ = 40.59,
			maxZ = 44.59,
		},
		stashType = "public",
	},
}

function RegisterPrisonStashStartup()
	GlobalState.JailStashLocations = _jailStashLocs

	exports["pulsar-core"]:RegisterServerCallback("Inventory:PrisonStash:Open", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		-- if not exports['pulsar-jail']:IsJailed(source) then
		if char then
			local _inventory = 5000
			local _inventoryOwner = ("prisonstash:%s"):format(char:GetData("SID"))

			if data == "public" then
				_inventory = 5001
				_inventoryOwner = "prisonstash:public"
			end

			exports["pulsar-core"]:ClientCallback(source, "Inventory:Compartment:Open", {
				invType = _inventory,
				owner = _inventoryOwner,
			}, function()
				exports.ox_inventory:OpenSecondary(source, _inventory, _inventoryOwner)
			end)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Inventory:PrisonStash:Raid", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and data and data.stateid then
			if
				Player(source).state.onDuty == "police" or Player(source).state.onDuty == "prison"
			--and exports['pulsar-jobs']:HasPermissionInJob(source, "police", "PD_RAID")
			then
				-- exports['pulsar-core']:LoggerWarn(
				-- 	"Police",
				-- 	string.format(
				-- 		"Police Storage Unit Raid - Character %s %s (%s) - Accessing Storage Unit %s (%s)",
				-- 		char:GetData("First"),
				-- 		char:GetData("Last"),
				-- 		char:GetData("SID"),
				-- 		unit.label,
				-- 		unit.id
				-- 	),
				-- 	{
				-- 		console = true,
				-- 		discord = {
				-- 			embed = true,
				-- 			type = "info",
				-- 		},
				-- 	}
				-- )
				local _inventory = 5000
				local _inventoryOwner = ("prisonstash:%s"):format(tonumber(data.stateid))
				print("_inventoryOwner", _inventoryOwner)
				exports["pulsar-core"]:ClientCallback(source, "Inventory:Compartment:Open", {
					invType = _inventory,
					owner = _inventoryOwner,
				}, function()
					exports.ox_inventory:OpenSecondary(source, _inventory, _inventoryOwner)
				end)

				cb(true)
			else
				cb(false)
			end
		end
	end)
end
