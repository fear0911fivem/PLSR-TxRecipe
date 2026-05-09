AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterServerCallback("Trunk:PutIn", function(source, data, cb)
			local t = Player(source).state.isEscorting

			if t ~= nil then
				exports['pulsar-escort']:EscortStop(source)
				exports["pulsar-core"]:ClientCallback(t, "Trunk:GetPutIn", data)
			end
		end)

		exports["pulsar-core"]:RegisterServerCallback("Trunk:PullOut", function(source, data, cb)
			local ent = NetworkGetEntityFromNetworkId(data)
			local entState = Entity(ent).state

			if entState.trunkOccupied then
				exports["pulsar-core"]:ClientCallback(entState.trunkOccupied, "Trunk:GetPulledOut", {}, function()
					Wait(500)
					exports['pulsar-escort']:EscortDo(source, {
						target = entState.trunkOccupied,
						inVeh = false,
					})
				end)
			end
		end)
	end
end)

local _trunkOccupied = {}

exports("TrunkEnter", function(source, netId)
	local pState = Player(source).state
	pState.trunkVeh = netId

	local ent = NetworkGetEntityFromNetworkId(netId)
	if ent then
		local entState = Entity(ent).state
		if not entState.trunkOccupied then
			entState.trunkOccupied = source

			-- GlobalState[string.format("PlayerTrunk:%s", source)] = netId
			-- local t = GlobalState[string.format("Trunk:%s", netId)] or {}
			-- table.insert(t, source)
			-- GlobalState[string.format("Trunk:%s", netId)] = t
		end
	end
end)

exports("TrunkExit", function(source, netId)
	local pState = Player(source).state

	if pState.trunkVeh then
		local ent = NetworkGetEntityFromNetworkId(pState.trunkVeh)
		if ent then
			local entState = Entity(ent).state
			if entState.trunkOccupied and entState.trunkOccupied == source then
				entState.trunkOccupied = nil
			end
		end

		TriggerClientEvent("Trunk:Client:Exit", source)
		pState.trunkVeh = nil
	end

	-- if GlobalState[string.format("Trunk:%s", netId)] ~= nil then
	-- 	local newTable = {}
	-- 	for k, v in ipairs(GlobalState[string.format("Trunk:%s", netId)]) do
	-- 		if source == v then
	-- 			GlobalState[string.format("PlayerTrunk:%s", source)] = nil
	-- 			TriggerClientEvent("Trunk:Client:Exit", source)
	-- 		else
	-- 			table.insert(newTable, v)
	-- 		end
	-- 	end

	-- 	GlobalState[string.format("Trunk:%s", netId)] = newTable
	-- elseif GlobalState[string.format("PlayerTrunk:%s", source)] then -- Car Probably Deleted
	-- 	GlobalState[string.format("PlayerTrunk:%s", source)] = nil
	-- 	TriggerClientEvent("Trunk:Client:Exit", source)
	-- end
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	local pState = Player(source).state
	if pState.inTrunk then
		exports['pulsar-escort']:TrunkExit(source, GlobalState[string.format("PlayerTrunk:%s", source)])
	end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	local pState = Player(source).state
	if pState.inTrunk then
		exports['pulsar-escort']:TrunkExit(source, GlobalState[string.format("PlayerTrunk:%s", source)])
	end
end)

RegisterNetEvent("Trunk:Server:Enter", function(netId)
	exports['pulsar-escort']:TrunkEnter(source, netId)
end)

RegisterNetEvent("Trunk:Server:Exit", function(netId)
	exports['pulsar-escort']:TrunkExit(source, netId)
end)
