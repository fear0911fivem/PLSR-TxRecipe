local _jobs = {}
local LastTime = nil

AddEventHandler('Proxy:Shared:RegisterReady', function()
    if LastTime == nil then
        LastTime = GetTime()
        CronTick()
    end
end)

function GetTime()
    local date = os.date("*t")

    return {
        day = date.wday,
        hour = date.hour,
        min = date.min
    }
end

function OnTime(day, hour, min)
    for k, v in pairs(_jobs) do
        if v.pause or v.skip then
            if v.skip then
                v.skip = false
            end
        else
            if v.day == day and v.hour == hour and v.min == min then
                v.callback()
            end
        end
    end
end

function CronTick()
    CreateThread(function()
        while true do
            Wait(60000)
            local time = GetTime()

            if time.hour ~= LastTime.hour or time.min ~= LastTime.min then
                OnTime(time.day, time.hour, time.min)
                LastTime = time
            end
        end
    end)
end

exports('CronRegister', function(id, day, hour, min, cb)
    if _jobs[id] ~= nil then
        exports['pulsar-core']:LoggerWarn('Cron', 'Overriding Already Existing Cron Job: ' .. id,
            { console = true })
    end

    _jobs[id] = {
        id = id,
        day = day,
        hour = hour,
        min = min,
        pause = false,
        skip = false,
        callback = cb
    }
end)

exports('CronDelete', function(id)
    if _jobs[id] ~= nil then
        _jobs[id] = nil
    else
        exports['pulsar-core']:LoggerWarn('Cron', 'Attempt To Delete Non-Existing Cron Job: ' .. id,
            { console = true })
    end
end)

exports('CronPause', function(id)
    if _jobs[id] ~= nil then
        _jobs[id].pause = true
    else
        exports['pulsar-core']:LoggerWarn('Cron', 'Attempt To Pause Non-Existing Cron Job: ' .. id,
            { console = true })
    end
end)

exports('CronResume', function(id)
    if _jobs[id] ~= nil then
        _jobs[id].pause = false
    else
        exports['pulsar-core']:LoggerWarn('Cron', 'Attempt To Resume Non-Existing Cron Job: ' .. id,
            { console = true })
    end
end)

exports('CronSkip', function(id)
    if _jobs[id] ~= nil then
        _jobs[id].skip = false
        _jobs[id].pause = false
    else
        exports['pulsar-core']:LoggerWarn('Cron', 'Attempt To Skip Non-Existing Cron Job: ' .. id,
            { console = true })
    end
end)
