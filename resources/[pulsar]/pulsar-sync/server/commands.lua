function RegisterChatCommands()
    exports["pulsar-chat"]:RegisterAdminCommand('freezetime', function(source, args, rawCommand)
        exports["pulsar-sync"]:FreezeTime()
        exports["pulsar-chat"]:SendServerSingle(source,
            'Time Has Been ' .. (exports["pulsar-sync"]:GetTimeFrozen() and 'Frozen' or 'Unfrozen'))
    end, {
        help = 'Freeze Time',
        params = {}
    })

    exports["pulsar-chat"]:RegisterAdminCommand('freezeweather', function(source, args, rawCommand)
        exports["pulsar-sync"]:FreezeWeather()
        exports["pulsar-chat"]:SendServerSingle(source,
            'Weather Has Been ' .. (exports["pulsar-sync"]:GetWeatherFrozen() and 'Frozen' or 'Unfrozen'))
    end, {
        help = 'Freeze the Weather',
        params = {}
    })

    exports["pulsar-chat"]:RegisterAdminCommand('weather', function(source, args, rawCommand)
        for _, v in pairs(AvailableWeatherTypes) do
            if args[1]:upper() == v then
                exports["pulsar-sync"]:SetWeather(args[1])
                return
            end
        end
        exports["pulsar-chat"]:SendServerSingle(source, 'Invalid Weather Type')
    end, {
        help = 'Set Weather',
        params = { {
            name = 'Type',
            help =
            'EXTRASUNNY, CLEAR, NEUTRAL, SMOG, FOGGY, OVERCAST, CLOUDS, CLEARING, RAIN, THUNDER, SNOW, BLIZZARD, SNOWLIGHT, XMAS, HALLOWEEN'
        }
        }
    }, 1)

    exports["pulsar-chat"]:RegisterAdminCommand('time', function(src, args, raw)
        exports["pulsar-sync"]:SetTimeType(args[1])
    end, {
        help = 'Set Time',
        params = {
            { name = 'Type', help = 'MORNING, NOON, EVENING, NIGHT' }
        }
    }, 1)

    exports["pulsar-chat"]:RegisterAdminCommand('clock', function(src, args, raw)
        exports["pulsar-sync"]:SetTime(tonumber(args[1]), tonumber(args[2]))
    end, {
        help = 'Set Specific Hour',
        params = {
            { name = 'Hour', help = '0 - 23' },
        }
    }, -1)

    exports["pulsar-chat"]:RegisterAdminCommand('blackout', function(source, args, rawCommand)
        exports["pulsar-sync"]:SetBlackout()
        exports["pulsar-chat"]:SendServerSingle(source,
            'Blackout Has Been ' .. (exports["pulsar-sync"]:GetBlackout() and 'Enabled' or 'Disabled'))
    end, {
        help = 'Toggle Blackout'
    }, 0)

    exports["pulsar-chat"]:RegisterAdminCommand('winter', function(source, args, rawCommand)
        exports["pulsar-sync"]:SetWinter()
        exports["pulsar-chat"]:SendServerSingle(source, 'Winter Only Weather Has Been ' ..
            (exports["pulsar-sync"]:GetWinter() and 'Enabled' or 'Disabled'))
    end, {
        help = 'Toggle Winter Only Weather'
    }, 0)
end
