--- Registers all mechanic crafting benches with ox_inventorys
---@return nil
local function RegisterMechanicBenches()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(500)
    end

    for i = 1, #Config.CraftingBenches do
        local shop    = Config.CraftingBenches[i]
        local recipes = shop.recipes or Config.BenchRecipes
        for j = 1, #shop.benches do
            local bench = shop.benches[j]
            exports.ox_inventory:CraftingRegisterBench(
                ('mechanic-bench-%s-%d'):format(shop.job, j),
                'Mechanic Workshop',
                nil,
                nil,
                { job = { id = shop.job, grade = 0 } },
                recipes,
                false
            )
        end
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        RegisterCallbacks()
        RegisterMechanicItems()
        exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-mechanic')
        CreateThread(RegisterMechanicBenches)
    end
end)
