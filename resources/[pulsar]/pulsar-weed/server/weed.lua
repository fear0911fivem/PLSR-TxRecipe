_plants = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-weed')
    Startup()
    RegisterMiddleware()
    RegisterCallbacks()
    RegisterTasks()
    RegisterItems()
  end
end)

function getStageByPct(pct)
  local stagePct = 100 / (#Plants - 1)
  return math.floor((pct / stagePct) + 1.5)
end

function checkNearPlant(source, id)
  local coords = GetEntityCoords(GetPlayerPed(source))
  if _plants[id] ~= nil then
    return #(
      vector3(coords.x, coords.y, coords.z)
      - vector3(_plants[id].plant.location.x, _plants[id].plant.location.y, _plants[id].plant.location.z)
    ) <= 5
  else
    return false
  end
end

exports('PlantingSet', function(id, isUpdate, skipEvent)
  if _plants[id] ~= nil then
    local stage = getStageByPct(_plants[id].plant.growth)
    _plants[id].stage = stage

    if skipEvent then
      return { id = id, plant = _plants[id], update = isUpdate }
    else
      TriggerClientEvent("Weed:Client:Objects:Update", -1, id, _plants[id], isUpdate)
    end
  end
end)

exports('PlantingDelete', function(id, skipRemove)
  if _plants[id] ~= nil then
    _plants[id] = nil
    TriggerClientEvent("Weed:Client:Objects:Delete", -1, id)
  end
end)

exports('PlantingCreate', function(isMale, location, material)
  local p = promise.new()
  local weed = {
    isMale = isMale,
    location = location,
    growth = 0,
    output = 1,
    material = material,
    planted = os.time(),
    water = 100.0,
  }
  MySQL.insert(
    'INSERT INTO weed (is_male, x, y, z, growth, output, material, planted, water) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    {
      isMale and 1 or 0,
      location.x, location.y, location.z,
      0, 1, material, weed.planted, 100.0
    }, function(insertId)
      if not insertId then
        return p:resolve(nil)
      end
      weed._id = insertId
      return p:resolve(weed)
    end)
  return Citizen.Await(p)
end)
