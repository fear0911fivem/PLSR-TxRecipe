exports('GameObjectsSpawn', function(coords, modelName, heading)
    local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
    SetEntityHeading(obj, heading)
    return obj
end)

exports('GameObjectsDelete', function(obj)
    DeleteObject(obj)
end)
