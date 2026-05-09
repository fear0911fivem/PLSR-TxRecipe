exports('StreamRequestModel', function(modelName)
    local modelHash = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
    if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) do
            if timeout > 20000 then
                exports['pulsar-core']:LoggerError("Stream",
                    string.format('failed to load model, please report this: %s', modelName))
            end
            Wait(1)
            timeout += 1
        end
    end
end)

exports('StreamRequestAnimDict', function(dictName)
    RequestAnimDict(dictName)
    while not HasAnimDictLoaded(dictName) do
        Wait(100)
    end
end)

exports('StreamRequestAnimSet', function(setName)
    RequestAnimSet(setName)
    while not HasAnimSetLoaded(setName) do
        Wait(100)
    end
end)
