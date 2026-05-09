RegisterNetEvent('Damage:Server:LogDeath', function(killer, reason, wasExecuted)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
        if killer then
            local killerChar = exports['pulsar-characters']:FetchCharacterSource(killer)
            if killerChar then
                killer = string.format('%s %s (%s)', killerChar:GetData('First'), killerChar:GetData('Last'),
                    killerChar:GetData('SID'))
            end

            if wasExecuted then
                exports['pulsar-core']:LoggerInfo("Damage",
                    string.format("%s %s (%s) Executed By %s. Method: %s", char:GetData("First"), char:GetData("Last"),
                        char:GetData("SID"), killer, reason), {
                        console = true,
                        file = true,
                        database = true,
                        discord = {
                            embed = true,
                            type = 'info',
                            webhook = GetConvar('discord_kill_webhook', ''),
                        }
                    })
            else
                exports['pulsar-core']:LoggerInfo("Damage",
                    string.format("%s %s (%s) Killed By %s. Method: %s", char:GetData("First"), char:GetData("Last"),
                        char:GetData("SID"), killer, reason), {
                        console = true,
                        file = true,
                        database = true,
                        discord = {
                            embed = true,
                            type = 'info',
                            webhook = GetConvar('discord_kill_webhook', ''),
                        }
                    })
            end
        else
            if wasExecuted then
                exports['pulsar-core']:LoggerInfo("Damage",
                    string.format("%s %s (%s) Executed Themself. Method: %s", char:GetData("First"), char:GetData("Last"),
                        char:GetData("SID"), reason), {
                        console = true,
                        file = true,
                        database = true,
                        discord = {
                            embed = true,
                            type = 'info',
                            webhook = GetConvar('discord_kill_webhook', ''),
                        }
                    })
            else
                exports['pulsar-core']:LoggerInfo("Damage",
                    string.format("%s %s (%s) Killed Themself. Method: %s", char:GetData("First"), char:GetData("Last"),
                        char:GetData("SID"), reason), {
                        console = true,
                        file = true,
                        database = true,
                        discord = {
                            embed = true,
                            type = 'info',
                            webhook = GetConvar('discord_kill_webhook', ''),
                        }
                    })
            end
        end
    end
end)
