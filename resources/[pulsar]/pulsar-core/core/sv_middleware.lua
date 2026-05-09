local _middlewares = {}

local _ignored = {
    ["screencapture"] = true,
}

AddEventHandler('onResourceStart', function(resource)
    if not _ignored[resource] then
        if resource ~= GetCurrentResourceName() then
            ClearMiddleware(resource)
        end
    end
end)

function ClearMiddleware(resource)
    for event, middlewares in pairs(_middlewares) do
        for i = #middlewares, 1, -1 do
            if middlewares[i].resource == resource then
                table.remove(middlewares, i)
            end
        end

        if #middlewares == 0 then
            _middlewares[event] = nil
        end
    end
    collectgarbage()
end

function MiddlewareTriggerEvent(event, source, ...)
    if _middlewares[event] then
        for k, v in pairs(_middlewares[event]) do
            v.cb(source, ...)
        end
    end
end

function MiddlewareTriggerEventWithData(event, source, ...)
    if _middlewares[event] then
        -- Making bold assumption this is only going to be done with data you want inserted into a table
        local data = {}
        for k, v in pairs(_middlewares[event]) do
            for k2, v2 in ipairs(v.cb(source, ...)) do
                v2.ID = #data + 1
                table.insert(data, v2)
            end
        end
        table.sort(data, function(a, b) return a.ID < b.ID end)
        return data
    end
end

function MiddlewareAdd(event, cb, prio)
    if prio == nil then
        prio = 1
    end

    if _middlewares[event] == nil then
        _middlewares[event] = {}
    end

    local resource = GetInvokingResource() or GetCurrentResourceName()

    table.insert(_middlewares[event], {
        cb = cb,
        prio = prio,
        resource = resource
    })
    table.sort(_middlewares[event], function(a, b) return a.prio < b.prio end)
end

exports('MiddlewareTriggerEvent', MiddlewareTriggerEvent)
exports('MiddlewareTriggerEventWithData', MiddlewareTriggerEventWithData)
exports('MiddlewareAdd', MiddlewareAdd)
