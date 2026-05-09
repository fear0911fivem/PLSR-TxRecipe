_withinBallistics = false
_ballisticsId = nil
_holdingGun = nil

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
    if data and data.ballistics and LocalPlayer.state.onDuty == 'police' then
        _ballisticsId = id
        _withinBallistics = true
        exports['pulsar-hud']:ActionShow('ballistics',
            '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
    end
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
    if _withinBallistics and data and data.ballistics and LocalPlayer.state.onDuty == 'police' then
        _ballisticsId = nil
        _withinBallistics = false
        exports['pulsar-hud']:ActionHide('ballistics')
    end
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    if _withinBallistics and LocalPlayer.state.loggedIn then
        exports['pulsar-hud']:ActionHide('ballistics')
        local playerPed = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(playerPed)
        
        if currentWeapon and currentWeapon ~= `WEAPON_UNARMED` then
            local currentWeaponData = exports.ox_inventory:getCurrentWeapon()
            
            if currentWeaponData and currentWeaponData.metadata then
                local serial = currentWeaponData.metadata.serial
                
                if serial then
                    exports['pulsar-animations']:EmotesPlay('type3', false, 5500, true, true)
                    exports['pulsar-hud']:Progress({
                        name = 'weapon_ballistics_test',
                        duration = 5000,
                        label = 'Testing & Filing Gun Ballistics',
                        useWhileDead = false,
                        canCancel = false,
                        ignoreModifier = true,
                        disarm = false,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = false,
                            disableMouse = false,
                            disableCombat = true,
                        },
                    }, function(status)
                        if not status then
                            exports["pulsar-core"]:ServerCallback("Evidence:Ballistics:FileGunWeaponInHand", {
                                serial = serial,
                                weaponData = currentWeaponData
                            }, function(success, alreadyFiled, projectiles, policeWeaponId)
                                if success then
                                    if alreadyFiled then
                                        exports["pulsar-hud"]:Notification("success", string.format("Weapon already filed - Police Weapon ID: %s", policeWeaponId), 7500)
                                    else
                                        exports["pulsar-hud"]:Notification("success", string.format("Weapon filed successfully - Police Weapon ID: %s", policeWeaponId), 7500)
                                    end
                                    
                                    if projectiles and #projectiles > 0 then
                                        exports["pulsar-hud"]:Notification("info", string.format("Found %d matching projectiles", #projectiles), 7500)
                                    end
                                else
                                    exports["pulsar-hud"]:Notification("error", "Failed to file weapon - Invalid weapon or serial number", 7500)
                                end
                                
                                if _withinBallistics then
                                    exports['pulsar-hud']:ActionShow('ballistics',
                                        '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
                                end
                            end)
                        else
                            if _withinBallistics then
                                exports['pulsar-hud']:ActionShow('ballistics',
                                    '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
                            end
                        end
                    end)
                else
                    exports["pulsar-hud"]:Notification("error", "No serial number found on weapon", 7500)
                    if _withinBallistics then
                        exports['pulsar-hud']:ActionShow('ballistics',
                            '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
                    end
                end
            else
                exports["pulsar-hud"]:Notification("error", "No weapon data found", 7500)
                if _withinBallistics then
                    exports['pulsar-hud']:ActionShow('ballistics',
                        '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
                end
            end
        else
            exports["pulsar-hud"]:Notification("error", "No weapon in hand", 7500)
            if _withinBallistics then
                exports['pulsar-hud']:ActionShow('ballistics',
                    '{keybind}primary_action{/keybind} Test & File Gun Ballistics | {key}Use Projectile Evidence{/key} File Projectile & Compare')
            end
        end
    end
end)

RegisterNetEvent('Evidence:Client:FiledProjectile', function(tooDegraded, success, alreadyFiled, filedEvidenceData, matchingWeaponData, evidenceId)
    if tooDegraded then
        return exports["pulsar-hud"]:Notification("error", 'Projectile too Degraded to Run Ballistics')
    end

    exports['pulsar-animations']:EmotesPlay('type3', false, 5500, true, true)
    exports['pulsar-hud']:Progress({
        name = 'projectile_ballistics_test',
        duration = 5000,
        label = 'Testing Projectile Ballistics',
        useWhileDead = false,
        canCancel = false,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(status)
        if not status then
            if success then
                if alreadyFiled then
                    exports["pulsar-hud"]:Notification("success", 'Projectile Was Already Filed', 7500)
                else
                    exports["pulsar-hud"]:Notification("success", 'Projectile Filed Successfully', 7500)
                end

                local desc, label

                if matchingWeaponData and matchingWeaponData.police_filed then
                    local weaponItem = matchingWeaponData.model and exports.ox_inventory:Items()[matchingWeaponData.model]
                    local weaponLabel = weaponItem and weaponItem.label or matchingWeaponData.model

                    label = string.format('Successfully Matched to a %s', weaponLabel)

                    if matchingWeaponData.scratched == 1 or matchingWeaponData.scratched == true then
                        desc = string.format(
                            'Matched to a Weapon with no Serial Number<br>Assigned Police Weapon ID: PWI-%s',
                            matchingWeaponData.police_id
                        )
                    else
                        desc = string.format('Serial Number: %s', matchingWeaponData.serial)
                    end
                else
                    label = 'No Matching Weapon Found'
                    desc = 'There are currently no weapons filed that match this projectile'
                end

                if label and desc then
                    exports['pulsar-hud']:ListMenuShow({
                        main = {
                            label = 'Ballistics Comparison - Results',
                            items = {
                                {
                                    label = 'Projectile Evidence Identifier',
                                    description = evidenceId,
                                },
                                {
                                    label = label,
                                    description = desc,
                                },
                            },
                        },
                    })
                end
            else
                exports["pulsar-hud"]:Notification("error", 'Ballistics Testing Failed - No Matching Weapon Found', 7500)
            end
        end
    end)
end)