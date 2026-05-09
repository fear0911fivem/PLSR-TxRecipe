AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterItems()
	end
end)

function RegisterItems()
    exports.ox_inventory:RegisterUse("camping_chair", "Animations", function(source, item, itemData)
        TriggerClientEvent('Animations:Client:CampChair', source)
    end)

    exports.ox_inventory:RegisterUse("beanbag", "Animations", function(source, item, itemData)
        TriggerClientEvent('Animations:Client:BeanBag', source)
    end) 

    exports.ox_inventory:RegisterUse('binoculars', "Animations", function(source, item, itemData)
        TriggerClientEvent('Animations:Client:Binoculars', source)
    end)

    exports.ox_inventory:RegisterUse('camera', "Animations", function(source, item, itemData)
        TriggerClientEvent('Animations:Client:Camera', source)
    end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItems()
	end
end)