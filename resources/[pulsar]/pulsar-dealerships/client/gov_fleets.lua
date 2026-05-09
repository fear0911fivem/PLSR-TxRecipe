function CreateGovermentFleetShops()
    for k, v in ipairs(_fleetConfig) do
        if v.interactionPed then
            exports['pulsar-pedinteraction']:Add('gov_fleet_shop_' .. v.job, v.interactionPed.model,
                v.interactionPed.coords,
                v.interactionPed.heading, v.interactionPed.range, {
                    {
                        icon = 'fas fa-warehouse',
                        text = 'Purchase Fleet Vehicles',
                        groups = { v.job },
                        permissionKey = v.requiredPermission,
                        reqDuty = true,
                        workplace = v.workplace,
                        onSelect = function()
                            TriggerEvent('FleetDealers:Client:Open', { shop = k })
                        end,
                    },
                }, 'cars', v.interactionPed.scenario)
        end
    end
end

AddEventHandler('FleetDealers:Client:Open', function(data)
    if data and data.shop and _fleetConfig[data.shop] then
        local shopData = _fleetConfig[data.shop]
        local menuData = {
            main = {
                label = string.format('Purchase a New %s Fleet Vehicle', shopData.jobName),
                items = {}
            }
        }

        table.insert(menuData.main.items, {
            label = 'Purchase Information',
            description = string.format(
                [[
                    Payments for Fleet Vehicles are Taken from the %s
                    Bank Account. Make Sure That the Balance is Sufficient.
                ]],
                shopData.jobName
            ),
            disabled = true,
        })

        for k, v in ipairs(shopData.vehicles) do
            local vehicleSub = 'vehicle_' .. k

            menuData[vehicleSub] = {
                label = 'Purchase ' .. v.make .. ' ' .. v.model,
                items = {},
            }

            for livery, liveryName in pairs(v.liveries) do
                table.insert(menuData[vehicleSub].items, {
                    label = string.format('Purchase With %s Livery', liveryName),
                    description = 'Price: $' .. formatNumberToCurrency(v.price),
                    event = 'FleetDealers:Client:ConfirmPurchase',
                    data = { 
                        jobName = shopData.jobName, 
                        shop = data.shop, 
                        vehicle = k, 
                        livery = livery, 
                        liveryName = liveryName, 
                        vehData = v,
                        workplaceId = shopData.workplace or false,  
                        qual = v.qual or false              
                    },
                })
            end

            table.insert(menuData.main.items, {
                label = v.make .. ' ' .. v.model,
                description = string.format('Fleet Price: $%s<br>Available Liveries: %s', formatNumberToCurrency(v.price),
                    exports['pulsar-core']:UtilsGetTableLength(v.liveries)),
                submenu = vehicleSub,
            })
        end

        exports['pulsar-hud']:ListMenuShow(menuData)
    end
end)

AddEventHandler('FleetDealers:Client:ConfirmPurchase', function(data)
    exports['pulsar-hud']:ConfirmShow(
        string.format('Confirm %s Fleet Purchase', data.jobName),
        {
            yes = 'FleetDealers:Client:Purchase',
            no = 'FleetDealers:Client:CancelPurchase',
        },
        string.format('Please Confirm the Purchase of a %s %s (%s Livery) for $%s', data.vehData.make, data.vehData
            .model, data.liveryName, formatNumberToCurrency(data.vehData.price)),
        data
    )
end)

AddEventHandler('FleetDealers:Client:Purchase', function(data)
    TriggerServerEvent('FleetDealers:Server:Purchase', data.shop, data.vehicle, data.livery, data.workplaceId, data.qual)
end)
