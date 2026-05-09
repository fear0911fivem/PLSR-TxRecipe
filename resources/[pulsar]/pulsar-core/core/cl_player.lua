local _data = {}

RegisterNetEvent('Player:Client:SetData')
AddEventHandler('Player:Client:SetData', function(data)
    _data = exports["pulsar-core"]:CreateStore(1, 'Player', data)
    TriggerEvent('Player:Client:Updated')
end)

exports("GetLocalPlayer", function()
    return _data
end)

exports("GetPlayerData", function(key)
    if _data and _data.GetData then
        return _data:GetData(key)
    end
    return nil
end)

exports("SetPlayerData", function(key, value)
    if _data and _data.SetData then
        _data:SetData(key, value)
    end
end)
