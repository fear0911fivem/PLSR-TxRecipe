function CreatePropertyZones(propertyId, int)
    DestroyPropertyZones(propertyId)

    Wait(100)

    local interior = PropertyInteriors[int]
    if interior then
        exports.ox_target:addBoxZone({
            id = string.format("property-%s-exit", propertyId),
            coords = interior.locations.front.polyzone.center,
            size = vector3(interior.locations.front.polyzone.length, interior.locations.front.polyzone.width, 2.0),
            rotation = interior.locations.front.polyzone.options.heading or 0,
            debug = false,
            minZ = interior.locations.front.polyzone.options.minZ,
            maxZ = interior.locations.front.polyzone.options.maxZ,
            options = {
                {
                    icon = "fas fa-door-open",
                    label = "Exit",
                    onSelect = function()
                        TriggerEvent("Properties:Client:Exit", {
                            property = propertyId,
                            backdoor = false,
                        })
                    end,
                },
            }
        })

        if interior.locations.back then
            exports.ox_target:addBoxZone({
                id = string.format("property-%s-exit-back", propertyId),
                coords = interior.locations.back.polyzone.center,
                size = vector3(interior.locations.back.polyzone.length, interior.locations.back.polyzone.width, 2.0),
                rotation = interior.locations.back.polyzone.options.heading or 0,
                debug = false,
                minZ = interior.locations.back.polyzone.options.minZ,
                maxZ = interior.locations.back.polyzone.options.maxZ,
                options = {
                    {
                        icon = "fas fa-door-open",
                        label = "Exit",
                        onSelect = function()
                            TriggerEvent("Properties:Client:Exit", {
                                property = propertyId,
                                backdoor = true,
                            })
                        end,
                    },
                }
            })
        end

        if interior.locations.office then
            exports.ox_target:addBoxZone({
                id = string.format("property-%s-office", propertyId),
                coords = interior.locations.office.polyzone.center,
                size = vector3(interior.locations.office.polyzone.length, interior.locations.office.polyzone.width, 2.0),
                rotation = interior.locations.office.polyzone.options.heading or 0,
                debug = false,
                minZ = interior.locations.office.polyzone.options.minZ,
                maxZ = interior.locations.office.polyzone.options.maxZ,
                options = {
                    {
                        icon = "fas fa-box-open-full",
                        label = "Access Storage",
                        onSelect = function()
                            TriggerEvent("Properties:Client:Stash", propertyId)
                        end,
                        canInteract = function(data)
                            if not _propertiesLoaded then
                                return false
                            end
                            local property = _properties[data]
                            return (property.keys ~= nil and property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil) or
                                LocalPlayer.state.onDuty == "police"
                        end,
                    },
                    {
                        icon = "fas fa-clipboard",
                        label = "Go On/Off Duty",
                        onSelect = function()
                            TriggerEvent("Properties:Client:Duty", propertyId)
                        end,
                        canInteract = function(data)
                            if not _propertiesLoaded then
                                return false
                            end
                            local property = _properties[data]
                            return property.keys ~= nil and
                                property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil and
                                property?.data?.jobDuty
                        end,
                    },
                }
            })
        end

        if interior.locations.warehouse then
            exports.ox_target:addBoxZone({
                id = string.format("property-%s-warehouse", propertyId),
                coords = interior.locations.warehouse.polyzone.center,
                size = vector3(interior.locations.warehouse.polyzone.length, interior.locations.warehouse.polyzone.width,
                    2.0),
                rotation = interior.locations.warehouse.polyzone.options.heading or 0,
                debug = false,
                minZ = interior.locations.warehouse.polyzone.options.minZ,
                maxZ = interior.locations.warehouse.polyzone.options.maxZ,
                options = {
                    {
                        icon = "fas fa-box-open-full",
                        label = "Access Storage",
                        onSelect = function()
                            TriggerEvent("Properties:Client:Stash", propertyId)
                        end,
                        canInteract = function(data)
                            if not _propertiesLoaded then
                                return false
                            end
                            local property = _properties[data]
                            return property.keys ~= nil and
                                property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil
                        end,
                    },
                }
            })
        end

        if interior.locations.crafting and GlobalState[string.format("Property:Crafting:%s", propertyId)] then
            local menu = {
                {
                    icon = "fas fa-box-open-full",
                    label = "Access Storage",
                    onSelect = function()
                        TriggerEvent("Properties:Client:Stash", propertyId)
                    end,
                    canInteract = function(data)
                        if not _propertiesLoaded then
                            return false
                        end
                        local property = _properties[data]
                        return (property.keys ~= nil and property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil) or
                            LocalPlayer.state.onDuty == "police"
                    end,
                },
                {
                    icon = "fas fa-screwdriver-wrench",
                    label = "Use Bench",
                    onSelect = function()
                        TriggerEvent("Properties:Client:Crafting", propertyId)
                    end,
                    canInteract = function(data)
                        if not _propertiesLoaded then
                            return false
                        end
                        local property = _properties[data]
                        return property.keys ~= nil and property.keys[LocalPlayer.state.Character:GetData("ID")] ~= nil
                    end,
                },
            }

            if GlobalState[string.format("Property:Crafting:%s", propertyId)].schematics then
                table.insert(menu, {
                    icon = "fas fa-memo-circle-check",
                    label = "Add Schematic To Bench",
                    event = "Crafting:Client:AddSchematic",
                    onSelect = function()
                        TriggerEvent("Crafting:Client:AddSchematic", {
                            id = string.format("property-%s", propertyId),
                        })
                    end,
                    canInteract = function()
                        if not _propertiesLoaded then
                            return false
                        end

                        return exports.ox_inventory:ItemsHasType(17, 1)
                    end,
                })
            end

            exports.ox_target:addBoxZone({
                id = string.format("property-%s-crafting", propertyId),
                coords = interior.locations.crafting.polyzone.center,
                size = vector3(interior.locations.crafting.polyzone.length, interior.locations.crafting.polyzone.width,
                    2.0),
                rotation = interior.locations.crafting.polyzone.options.heading or 0,
                debug = false,
                minZ = interior.locations.crafting.polyzone.options.minZ,
                maxZ = interior.locations.crafting.polyzone.options.maxZ,
                options = menu
            })
        end

        Wait(1000)
    end
end

function DestroyPropertyZones(propertyId)
    exports.ox_target:removeZone(string.format("property-%s-exit", propertyId))
    exports.ox_target:removeZone(string.format("property-%s-exit-back", propertyId))
    exports.ox_target:removeZone(string.format("property-%s-warehouse", propertyId))
    exports.ox_target:removeZone(string.format("property-%s-office", propertyId))
    exports.ox_target:removeZone(string.format("property-%s-crafting", propertyId))
end
