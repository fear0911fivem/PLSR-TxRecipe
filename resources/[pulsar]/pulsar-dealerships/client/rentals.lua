function CreateRentalSpots()
    for k, v in ipairs(_vehicleRentals) do
        if v.interactionPed then
            exports['pulsar-pedinteraction']:Add('veh_rental_' .. k, v.interactionPed.model, v.coords,
                v.interactionPed.heading,
                v.interactionPed.range, {
                    {
                        icon = 'fas fa-car-side',
                        text = 'Vehicle Rentals',
                        onSelect = function()
                            TriggerEvent('VehicleRentals:Client:OpenRental', { rental = k })
                        end,
                    },
                    {
                        icon = 'fas fa-warehouse',
                        text = 'Rental Returns',
                        onSelect = function()
                            TriggerEvent('VehicleRentals:Client:ReturnRental', { rental = k })
                        end,
                    },
                }, 'car-side', v.interactionPed.scenario)
        end

        if v.zone then
            CreatePolyzone('veh_rental_' .. k, v.zone, {
                vehicleRental = k,
            })
        end
    end
end

function CreateRentalSpotsBlips()
    for k, v in ipairs(_vehicleRentals) do
        exports["pulsar-blips"]:Add('veh_rental_' .. k, v.name, v.coords, v.blip.sprite, v.blip.color, v.blip.scale)
    end
end

AddEventHandler('VehicleRentals:Client:OpenRental', function(data)
    local myCash = LocalPlayer.state.Character:GetData('Cash')
    local rentalSpotData = _vehicleRentals[data.rental]
    local menu = {
        main = {
            label = rentalSpotData.name,
            items = {},
        }
    }

    for k, v in ipairs(rentalSpotData.vehicleList) do
        local vehicleSub = 'vehicle_' .. k
        menu[vehicleSub] = {
            label = v.make .. ' ' .. v.model,
            items = {},
        }

        table.insert(menu[vehicleSub].items, {
            label = '$' .. v.cost.deposit .. ' Deposit',
            description = 'The deposit will be returned to you when the vehicle is brought back in an operational state.',
            event = false,
        })

        table.insert(menu[vehicleSub].items, {
            label = '$' .. v.cost.payment .. ' Rental Payment',
        })

        local totalCost = v.cost.deposit + v.cost.payment

        table.insert(menu[vehicleSub].items, {
            label = 'Purchase Rental Vehicle',
            description = 'The vehicle will be brought around to the parking lot after the rental payment is complete.',
            event = 'VehicleRentals:Client:ConfirmRental',
            data = { rental = data.rental, vehicle = k },
            disabled = myCash < totalCost
        })

        table.insert(menu[vehicleSub].items, {
            label = 'Purchase Rental Vehicle - Use Bank Account',
            description = 'The vehicle will be brought around to the parking lot after the rental payment is complete.',
            event = 'VehicleRentals:Client:ConfirmRental',
            data = { rental = data.rental, vehicle = k, bank = true },
        })

        table.insert(menu.main.items, {
            label = v.make .. ' ' .. v.model,
            description = v.description .. ' - $' .. v.cost.payment .. ' with a $' .. v.cost.deposit .. ' Deposit.',
            submenu = vehicleSub,
        })
    end

    exports['pulsar-hud']:ListMenuShow(menu)
end)

AddEventHandler('VehicleRentals:Client:ConfirmRental', function(data)
    local rentalSpotData = _vehicleRentals[data.rental]
    local availableSpace = GetClosestAvailableParkingSpace(LocalPlayer.state.myPos, rentalSpotData.spaces)
    if availableSpace then
        exports["pulsar-core"]:ServerCallback('Rentals:Purchase', {
            spaceCoords = availableSpace.xyz,
            spaceHeading = availableSpace.w,
            rental = data.rental,
            vehicle = data.vehicle,
            bank = data.bank,
        }, function(success, plate)
            if success then
                exports["pulsar-hud"]:Notification("success",
                    'Rental Purchased, It is Parked Nearby. Rental Vehicle Plate: ' ..
                    plate)
            else
                exports["pulsar-hud"]:Notification("error", 'Rental Purchase Failed')
            end
        end)
    end
end)

AddEventHandler('VehicleRentals:Client:ReturnRental', function(data)
    exports["pulsar-core"]:ServerCallback('Rentals:GetPending', { rental = data.rental }, function(pending)
        if pending then
            local menu = {
                main = {
                    label = 'Pending Rental Returns',
                    items = {},
                }
            }

            for k, v in pairs(pending) do
                local canReturn = false

                local vehPool = GetGamePool("CVehicle")
                for _, veh in ipairs(vehPool) do
                    if DoesEntityExist(veh) and Entity(veh).state then
                        local vin = Entity(veh).state.VIN
                        if vin == v.VIN and IsAbleToReturnVehicle(veh, data.rental) then
                            canReturn = veh
                        end
                    end
                end

                table.insert(menu.main.items, {
                    label = 'Return ' .. v.Vehicle,
                    description = (canReturn and 'Return the vehicle and recieve your deposit back.' or 'Currently unable to return vehicle.'),
                    event = 'VehicleRentals:Client:ConfirmReturnRental',
                    data = { vehicle = canReturn, VIN = v.VIN, rental = data.rental },
                    disabled = not canReturn
                })
            end

            if #menu.main.items > 0 then
                exports['pulsar-hud']:ListMenuShow(menu)
            else
                exports["pulsar-hud"]:Notification("error", 'You Have no Vehicle Rentals to Return')
            end
        else
            exports["pulsar-hud"]:Notification("error", 'You Have no Vehicle Rentals to Return')
        end
    end)
end)

AddEventHandler('VehicleRentals:Client:ConfirmReturnRental', function(data)
    if data and data.vehicle and data.VIN and IsAbleToReturnVehicle(data.vehicle, data.rental) then
        exports["pulsar-core"]:ServerCallback('Rentals:Return', {
            VIN = data.VIN,
        }, function(success)
            if success then
                exports["pulsar-hud"]:Notification("success", 'Rental Returned & Deposit Returned')
            end
        end)
    end
end)

function IsAbleToReturnVehicle(vehicle, rentalSpot)
    if DoesEntityExist(vehicle) then
        local vehicleCoords = GetEntityCoords(vehicle)
        local hasDriver = GetPedInVehicleSeat(vehicle, -1)
        local speed = GetEntitySpeed(vehicle)
        local withinReturnZone = exports['pulsar-polyzone']:IsCoordsInZone(vehicleCoords, false, 'vehicleRental',
            rentalSpot)
        if withinReturnZone and (not hasDriver or hasDriver <= 0) and speed <= 2.0 then
            return true
        end
    end
    return false
end
