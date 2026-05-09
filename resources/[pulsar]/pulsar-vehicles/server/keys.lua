VEHICLE_KEYS = {}

RegisterServerEvent("Vehicles:Server:StealLocalKeys", function(vehNet)
	local src = source
	local veh = NetworkGetEntityFromNetworkId(vehNet)
	local vehEnt = Entity(veh)
	if vehEnt and vehEnt.state.VIN then
		exports['pulsar-vehicles']:KeysAdd(src, vehEnt.state.VIN)
	end
end)

exports("KeysHas", function(source, VIN, groupKeys)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local id = char:GetData('SID')
		if VEHICLE_KEYS[id] == nil then
			return false
		end
		return (VEHICLE_KEYS[id][VIN] or (groupKeys and (Player(source).state.onDuty == groupKeys or (Player(source).state.sentOffDuty and Player(source).state.sentOffDuty == groupKeys))))
	end
	return false
end)

exports("KeysAdd", function(source, VIN)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local id = char:GetData('SID')
		if VEHICLE_KEYS[id] == nil then
			VEHICLE_KEYS[id] = {}
		end
		VEHICLE_KEYS[id][VIN] = true

		TriggerClientEvent("Vehicles:Client:UpdateKeys", source, VEHICLE_KEYS[id])
	end
end)

exports("KeysRemove", function(source, VIN)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local id = char:GetData('SID')
		if VEHICLE_KEYS[id] == nil then
			VEHICLE_KEYS[id] = {}
			return
		end
		if exports['pulsar-vehicles']:KeysHas(source, VIN, false) then
			VEHICLE_KEYS[id][VIN] = nil
			TriggerClientEvent("Vehicles:Client:UpdateKeys", source, VEHICLE_KEYS[id])
		end
	end
end)

exports("KeysAddBySID", function(SID, VIN)
	if VEHICLE_KEYS[SID] == nil then
		VEHICLE_KEYS[SID] = {}
	end

	VEHICLE_KEYS[SID][VIN] = true

	local char = exports['pulsar-characters']:FetchBySID(SID)
	if char then
		TriggerClientEvent('Vehicles:Client:UpdateKeys', char:GetData('Source'), VEHICLE_KEYS[SID])
	end
end)
