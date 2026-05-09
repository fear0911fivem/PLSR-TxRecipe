AddEventHandler("Vehicles:Client:StartUp", function()
    exports["pulsar-core"]:RegisterClientCallback("Vehicles:GetPersonalPlate", function(data, cb)
        local coords = GetEntityCoords(PlayerPedId())
        local maxDistance = 2.0
        local includePlayerVehicle = false
        local target = lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)

        if target and DoesEntityExist(target) and IsEntityAVehicle(target) then
            if exports['pulsar-vehicles']:HasAccess(target) and (exports['pulsar-vehicles']:UtilsIsCloseToRearOfVehicle(target) or exports['pulsar-vehicles']:UtilsIsCloseToFrontOfVehicle(target)) then
                local settingPlate = GetNewPersonalPlate()

                if settingPlate then
                    cb(VehToNet(target.entity), settingPlate)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

    exports['pulsar-pedinteraction']:Add("donor_plates", `u_f_m_debbie_01`, vector3(-504.405, -182.683, 36.691), 290.319,
        25.0, {
            {
                icon = "rectangle-wide",
                text = "Donator License Plate Claim",
                event = "Vehicles:Client:DonatorLicensePlateClaim",
            },
        }, "comment-dollar")
end)

local platePromise
function GetNewPersonalPlate()
    platePromise = promise.new()
    exports['pulsar-hud']:InputShow("New Personal Plate", "Personal Plate", {
        {
            id = "plate",
            type = "text",
            options = {
                inputProps = {
                    pattern = "[A-HJ-NPR-Z0-9 ]+",
                    maxlength = 8,
                },
                helperText =
                "Plates cannot include the letters O, Q, I and must include at least 3 characters. SPACES FOR PADDING ARE ADDED AUTOMATICALLY!"
            },
        },
    }, "Vehicles:Client:RecievePersonalPlateInput", {})

    return Citizen.Await(platePromise)
end

AddEventHandler("Vehicles:Client:RecievePersonalPlateInput", function(values)
    if platePromise then
        platePromise:resolve(values?.plate)
        platePromise = nil
    end
end)

AddEventHandler("Input:Closed", function()
    if platePromise then
        platePromise:resolve(false)
        platePromise = nil
    end
end)

AddEventHandler("Vehicles:Client:DonatorLicensePlateClaim", function()
    exports["pulsar-core"]:ServerCallback("Vehicles:CheckDonatorPersonalPlates", {}, function(data)
        if data and data > 0 then
            local menu = {
                main = {
                    label = "Claim Donator License Plates",
                    items = {
                        {
                            label = "Information",
                            description =
                            "Please make sure that there is enough space in your inventory for your new license plates.<br>"
                        },
                    }
                }
            }

            if data == 1 then
                table.insert(menu.main.items, {
                    label = "Claim 1 Plate",
                    event = "Vehicles:Client:DonatorLicensePlateClaimConfirm",
                    data = 1,
                })
            else
                table.insert(menu.main.items, {
                    label = "Claim 1 Plate",
                    event = "Vehicles:Client:DonatorLicensePlateClaimConfirm",
                    data = 1,
                })

                table.insert(menu.main.items, {
                    label = string.format("Claim %s Plates", data),
                    event = "Vehicles:Client:DonatorLicensePlateClaimConfirm",
                    data = data,
                })
            end


            exports['pulsar-hud']:ListMenuShow(menu)
        else
            exports["pulsar-hud"]:Notification("error", "No Plates to Claim")
        end
    end)
end)

AddEventHandler("Vehicles:Client:DonatorLicensePlateClaimConfirm", function(data)
    exports["pulsar-core"]:ServerCallback("Vehicles:ClaimDonatorPersonalPlates", data, function(success)
        if not success then
            exports["pulsar-hud"]:Notification("error", "Unable to Claim Plates")
        end
    end)
end)
