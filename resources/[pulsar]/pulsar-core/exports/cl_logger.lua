exports('LoggerTrace', function(component, log, flags, data)
    doLog(1, component, log, flags, data)
end)

exports('LoggerInfo', function(component, log, flags, data)
    doLog(2, component, log, flags, data)
end)

exports('LoggerWarn', function(component, log, flags, data)
    doLog(3, component, log, flags, data)
end)

exports('LoggerError', function(component, log, flags, data)
    doLog(4, component, log, flags, data)
end)

exports('LoggerCritical', function(component, log, flags, data)
    doLog(5, component, log, flags, data)
end)

function doLog(level, component, log)
    local prefix = '[LOG]'
    if level > 0 then
        if level == 1 then
            prefix = '[TRACE]'
        elseif level == 2 then
            prefix = '[^5INFO^7] '
        elseif level == 3 then
            prefix = '[^3WARN^7] '
        elseif level == 4 then
            prefix = '[^1ERROR^7]'
        elseif level == 5 then
            prefix = '[^9CRITICAL^7]'
        end
    end

    if exports["pulsar-core"]:GetLogging() == nil or level >= exports["pulsar-core"]:GetLogging() then
        local formattedLog = string.format('%s\t[^2%s^7] %s', prefix, component, log)
        print(formattedLog)
    end
end
