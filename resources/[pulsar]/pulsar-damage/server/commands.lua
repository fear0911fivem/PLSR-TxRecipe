function RegisterChatCommands()
    exports["pulsar-chat"]:RegisterStaffCommand("heal", function(source, args, rawCommand)
        if args[1] ~= nil then
            local admin = exports['pulsar-core']:FetchSource(source)
            local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
            if char ~= nil and ((char:GetData("Source") ~= admin:GetData("Source")) or admin.Permissions:IsAdmin()) then
                exports["pulsar-core"]:ClientCallback(char:GetData("Source"), "Damage:Heal", true)
                exports['pulsar-status']:Set(source, "PLAYER_STRESS", 0)
            else
                exports["pulsar-chat"]:SendSystemSingle(source, "Invalid State ID")
            end
        else
            local char = exports['pulsar-characters']:FetchCharacterSource(source)
            if char ~= nil then
                exports["pulsar-core"]:ClientCallback(source, "Damage:Heal", true)
                exports['pulsar-status']:Set(source, "PLAYER_STRESS", 0)
            end
        end
    end, {
        help = "Heals Player",
        params = {
            {
                name = "Target (Optional)",
                help = "State ID of Who You Want To Heal",
            },
        },
    }, -1)

    exports["pulsar-chat"]:RegisterStaffCommand("healrange", function(source, args, rawCommand)
        local radius = args[1] and tonumber(args[1]) or 25.0

        local myPed = GetPlayerPed(source)
        for k, v in pairs(exports['pulsar-characters']:FetchAllCharacters()) do
            if v ~= nil then
                local src = v:GetData("Source")
                if Player(src).state.isDead then
                    local ped = GetPlayerPed(src)
                    if #(GetEntityCoords(ped) - GetEntityCoords(myPed)) <= radius then
                        exports["pulsar-core"]:ClientCallback(src, "Damage:Heal", true)
                    end
                end
            end
        end

        exports["pulsar-core"]:ClientCallback(source, "Damage:Heal", true)
        exports['pulsar-status']:Set(source, "PLAYER_STRESS", 0)
    end, {
        help = "Heals Player",
        params = {
            {
                name = "Radius (Optional)",
                help = "Radius To Heal Players (If Empty, Default Is 25 Meters)",
            },
        },
    }, -1)

    exports["pulsar-chat"]:RegisterAdminCommand("god", function(source, args, rawCommand)
        if Player(source).state.isGodmode then
            SetPlayerInvincible(source, false)
            Player(source).state.isGodmode = false
            exports['pulsar-hud']:Notification(source, "info", "God Mode Disabled")
            exports["pulsar-core"]:ClientCallback(source, "Damage:Admin:Godmode", false)
        else
            SetPlayerInvincible(source, true)
            Player(source).state.isGodmode = true
            exports['pulsar-hud']:Notification(source, "info", "God Mode Enabled")
            exports["pulsar-core"]:ClientCallback(source, "Damage:Admin:Godmode", true)
        end
    end, {
        help = "Toggle God Mode",
    }, -1)

    exports["pulsar-chat"]:RegisterAdminCommand("die", function(source, args, rawCommand)
        if not Player(source).state.isDead then
            exports["pulsar-core"]:ClientCallback(source, "Damage:Kill")
        end
    end, {
        help = "Kill Yourself",
    })
end
