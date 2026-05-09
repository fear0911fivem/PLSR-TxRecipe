local _maskItems = {
	"mask",
}

local _hatItems = {
	"hat",
	"sombrero",
}

local _accessoryItems = {
	"accessory",
}

function RegisterItemUses()
	for k, v in ipairs(_maskItems) do
		exports.ox_inventory:RegisterUse(v, "Ped", function(source, item)
			if not Player(source).state.isCuffed then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if item.MetaData.mask then
					TriggerClientEvent("Ped:Client:HatGlassAnim", source)
					Wait(300)
					local ped = char:GetData("Ped")
					if ped.customization.components.mask.drawableId ~= 0 then
						exports['pulsar-ped']:MaskUnequip(source)
					end
					exports['pulsar-ped']:MaskEquip(source, item.MetaData.mask)
					exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1)
				end
			end
		end)
	end

	for k, v in ipairs(_hatItems) do
		exports.ox_inventory:RegisterUse(v, "Ped", function(source, item)
			if not Player(source).state.isCuffed then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if item.MetaData.hat then
					TriggerClientEvent("Ped:Client:HatGlassAnim", source)
					Wait(300)
					local ped = char:GetData("Ped")
					if not ped.customization.props.hat.disabled then
						exports['pulsar-ped']:HatUnequip(source)
					end
					exports['pulsar-ped']:HatEquip(source, item.MetaData.hat)
					exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1)
				end
			end
		end)
	end

	for k, v in ipairs(_accessoryItems) do
		exports.ox_inventory:RegisterUse(v, "Ped", function(source, item)
			if not Player(source).state.isCuffed then
				local char = exports['pulsar-characters']:FetchCharacterSource(source)
				if item.MetaData.accessory then
					TriggerClientEvent("Ped:Client:HatGlassAnim", source)
					Wait(300)
					local ped = char:GetData("Ped")
					if (ped.customization.components.accessory?.drawableId or 0) ~= 0 then
						exports['pulsar-ped']:NecklaceUnequip(source)
					end

					exports['pulsar-ped']:NecklaceEquip(
						source,
						item.MetaData.accessory[char:GetData("Gender")]
						or item.MetaData.accessory[tostring(char:GetData("Gender"))]
						or item.MetaData.accessory
					)
					exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1)
				end
			end
		end)
	end
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItemUses()
	end
end)
