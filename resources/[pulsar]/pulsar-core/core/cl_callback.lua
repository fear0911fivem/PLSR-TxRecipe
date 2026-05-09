local _sCallbacks = {}
local _cCallbacks = {}

local function ServerCallback(event, data, cb, extraId)
    local id = event
    if extraId ~= nil then
        id = string.format("%s-%s", event, extraId)
    else
        extraId = ''
    end

    data = data or {}
    _sCallbacks[id] = cb
    TriggerLatentServerEvent('Callbacks:Server:TriggerEvent', 50000, event, data, extraId)
end

local function RegisterClientCallback(event, cb)
    _cCallbacks[event] = cb
end

local function DoClientCallback(event, extraId, data)
    if _cCallbacks[event] ~= nil then
        CreateThread(function()
            _cCallbacks[event](data, function(...)
                TriggerLatentServerEvent('Callbacks:Server:ReceiveCallback', 50000, event, extraId, ...)
            end)
        end)
    end
end

exports('ServerCallback', ServerCallback)
exports('RegisterClientCallback', RegisterClientCallback)
exports('DoClientCallback', DoClientCallback)

RegisterNetEvent('Callbacks:Client:TriggerEvent')
AddEventHandler('Callbacks:Client:TriggerEvent', function(event, data, extraId)
    if data == nil then data = {} end
    DoClientCallback(event, extraId, data)
end)

RegisterNetEvent('Callbacks:Client:ReceiveCallback')
AddEventHandler('Callbacks:Client:ReceiveCallback', function(event, extraId, ...)
    local id = event
    if extraId ~= '' then
        id = string.format("%s-%s", event, extraId)
    end

    if _sCallbacks[id] ~= nil then
        _sCallbacks[id](...)
        _sCallbacks[id] = nil
        collectgarbage()
    end
end)
