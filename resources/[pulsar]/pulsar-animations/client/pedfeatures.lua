local myFeatures = {}
local crouchAnimSet = "move_ped_crouched"
local crouchStrafeAnimSet = "move_ped_crouched_strafing"

function RequestAndLoadAnimSet(animSet)
    RequestAnimSet(crouchAnimSet)
    while not HasAnimSetLoaded(crouchAnimSet) do
        Wait(10)
    end
end

exports("PedFeaturesToggleCrouch", function(toggle)
    if toggle == nil then
        toggle = not _isCrouched
    end

    if toggle then
        if IsPedOnFoot(LocalPlayer.state.ped) and not LocalPlayer.state.placingFurniture then
            if not LocalPlayer.state.isLimping then
                RequestAndLoadAnimSet(crouchAnimSet)
                --RequestAndLoadAnimSet(crouchStrafeAnimSet)

                SetPedMovementClipset(LocalPlayer.state.ped, crouchAnimSet, 1.0)
                --SetPedWeaponMovementClipset(LocalPlayer.state.ped, crouchAnimSet, 1.0)
                --SetPedStrafeClipset(LocalPlayer.state.ped, crouchStrafeAnimSet, 1.0)

                _isCrouched = true
            else
                SetPedToRagdoll(LocalPlayer.state.ped, 1500, 2000, 3, true, true, false)
            end
        end
    else
        ResetPedMovementClipset(LocalPlayer.state.ped, 0)

        ResetPedWeaponMovementClipset(LocalPlayer.state.ped)
        ResetPedStrafeClipset(LocalPlayer.state.ped)

        if not LocalPlayer.state.drunkMovement then
            exports['pulsar-animations']:PedFeaturesRequestFeaturesUpdate()
        end
        _isCrouched = false
    end
end)

exports("PedFeaturesSetWalk", function(walk, label)
    if LocalPlayer.state.isLimping then
        RequestAnimSet("move_m@injured")
        SetPedMovementClipset(LocalPlayer.state.ped, "move_m@injured", 0.2)
        RemoveAnimSet("move_m@injured")
        if walk == 'reset' then
            walkStyle = walk
            exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures',
                { type = 'walk', data = 'default' },
                function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("info", 'Reset Walking Style', 5000)
                    end
                end)
        else
            walkStyle = walk
            exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = walk },
                function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("success", 'Saved Walking Style: ' .. label, 5000)
                    end
                end)
        end
    else
        if walk == 'reset' then
            ResetPedMovementClipset(LocalPlayer.state.ped, 0.0)
            walkStyle = walk
            exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures',
                { type = 'walk', data = 'default' },
                function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("info", 'Reset Walking Style', 5000)
                    end
                end)
        else
            ReqAnimSet(walk)
            SetPedMovementClipset(LocalPlayer.state.ped, walk, 0.2)
            RemoveAnimSet(walk)
            walkStyle = walk
            exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures', { type = 'walk', data = walk },
                function(success)
                    if success then
                        exports["pulsar-hud"]:Notification("success", 'Saved Walking Style: ' .. label, 5000)
                    end
                end)
        end
    end
end)

exports("PedFeaturesSetExpression", function(expression, label)
    if expression == 'reset' then
        ClearFacialIdleAnimOverride(LocalPlayer.state.ped)
        facialExpression = expression
        exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures',
            { type = 'expression', data = 'default' },
            function(success)
                if success then
                    exports["pulsar-hud"]:Notification("info", 'Expression Reset', 5000)
                end
            end)
    else
        SetFacialIdleAnimOverride(LocalPlayer.state.ped, expression, 0)
        facialExpression = expression
        exports["pulsar-core"]:ServerCallback('Animations:UpdatePedFeatures',
            { type = 'expression', data = expression },
            function(success)
                if success then
                    exports["pulsar-hud"]:Notification("success", 'Saved Expression: ' .. label, 5000)
                end
            end)
    end
end)

exports("PedFeaturesRequestFeaturesUpdate", function(feats)
    if LocalPlayer.state.isLimping then
        RequestAnimSet("move_m@injured")
        SetPedMovementClipset(LocalPlayer.state.ped, "move_m@injured", 0.2)
        RemoveAnimSet("move_m@injured")
    else
        if walkStyle ~= 'default' then
            ReqAnimSet(walkStyle)
            SetPedMovementClipset(LocalPlayer.state.ped, walkStyle, 0.6)
            RemoveAnimSet(walkStyle)
        else
            ResetPedMovementClipset(LocalPlayer.state.ped, 0.0)
        end
    end
    if facialExpression ~= 'default' then
        SetFacialIdleAnimOverride(LocalPlayer.state.ped, facialExpression, 0)
    end
end)
