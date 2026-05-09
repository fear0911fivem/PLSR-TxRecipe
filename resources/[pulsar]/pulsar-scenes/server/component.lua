_expirationThread = false

_loadedScenes = {}
_hasLoadedScenes = false

_spamCheck = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    LoadScenesFromDB()
    StartExpirationThread()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-scenes')

    exports["pulsar-core"]:RegisterServerCallback("Scenes:Create", function(source, data, cb)
      local player = exports['pulsar-core']:FetchSource(source)
      local timeStamp = GetGameTimer()

      if _spamCheck[source] and (timeStamp < _spamCheck[source]) and not player.Permissions:IsStaff() then
        return cb(false)
      end

      if player and data.scene and data.data then
        local wasCreated = exports['pulsar-scenes']:Create(data.scene,
          data.data.staff and player.Permissions:IsStaff())
        if wasCreated then
          _spamCheck[source] = timeStamp + 3500
        end
        cb(wasCreated)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Scenes:Delete", function(source, sceneId, cb)
      local player = exports['pulsar-core']:FetchSource(source)
      local scene = _loadedScenes[sceneId]
      local timeStamp = GetGameTimer()

      if _spamCheck[source] and (timeStamp < _spamCheck[source]) and not player.Permissions:IsStaff() then
        return cb(false)
      end

      if scene and player then
        if scene.staff and not player.Permissions:IsStaff() then
          return cb(false, true)
        end

        _spamCheck[source] = timeStamp + 5000

        cb(exports['pulsar-scenes']:Delete(sceneId))
      else
        cb(false)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Scenes:CanEdit", function(source, sceneId, cb)
      local player = exports['pulsar-core']:FetchSource(source)
      local scene = _loadedScenes[sceneId]
      local timeStamp = GetGameTimer()

      if _spamCheck[source] and (timeStamp < _spamCheck[source]) and not player.Permissions:IsStaff() then
        return cb(false, false)
      end

      if scene and player then
        if scene.staff and not player.Permissions:IsStaff() then
          return cb(false, player.Permissions:IsStaff())
        end

        _spamCheck[source] = timeStamp + 5000

        cb(true, player.Permissions:IsStaff())
      else
        cb(false, false)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Scenes:Edit", function(source, data, cb)
      local player = exports['pulsar-core']:FetchSource(source)
      local scene = _loadedScenes[data.id]
      local timeStamp = GetGameTimer()

      if _spamCheck[source] and (timeStamp < _spamCheck[source]) and not player.Permissions:IsStaff() then
        return cb(false)
      end

      if scene and player then
        _spamCheck[source] = timeStamp + 5000

        cb(exports['pulsar-scenes']:Edit(data.id, data.scene, player.Permissions:IsStaff()))
      else
        cb(false)
      end
    end)

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      TriggerClientEvent("Scenes:Client:RecieveScenes", source, _loadedScenes)
    end, 5)

    exports["pulsar-chat"]:RegisterCommand("scene", function(source, args, rawCommand)
      TriggerClientEvent("Scenes:Client:Creation", source, args)
    end, {
      help = "Create a Scene (Look Where You Want to Place)",
    })

    exports["pulsar-chat"]:RegisterStaffCommand("scenestaff", function(source, args, rawCommand)
      TriggerClientEvent("Scenes:Client:Creation", source, args, true)
    end, {
      help = "[Staff] Create a Scene (Look Where You Want to Place)",
    })

    exports["pulsar-chat"]:RegisterCommand("scenedelete", function(source, args, rawCommand)
      TriggerClientEvent("Scenes:Client:Deletion", source)
    end, {
      help = "Delete a Scene (Look at Scene You Want to Delete)",
    })

    exports["pulsar-chat"]:RegisterCommand("sceneedit", function(source, args, rawCommand)
      TriggerClientEvent("Scenes:Client:StartEdit", source)
    end, {
      help = "Edit a Scene (Look at Scene You Want to Edit)",
    })
  end
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, message)
  _spamCheck[source] = nil
end)

exports('Create', function(scene, isStaff)
  if scene and scene.coords then
    scene.coords = {
      x = scene.coords.x,
      y = scene.coords.y,
      z = scene.coords.z,
    }

    if not scene.length and not isStaff then
      return false
    end

    if scene.length then
      if scene.length > 24 then
        scene.length = 24
      elseif scene.length < 1 then
        scene.length = 1
      end

      scene.expires = os.time() + (3600 * scene.length)
      scene.staff = false
    else
      scene.expires = false
      scene.staff = true
    end

    if type(scene.distance) ~= "number" or scene.distance > 10.0 or scene.distance < 1.0 then
      scene.distance = 7.5
    end

    scene.text.text = SanitizeEmojis(scene.text.text)

    local p = promise.new()
    local coordsJson = json.encode(scene.coords)
    local textJson = json.encode(scene.text)
    local backgroundJson = json.encode(scene.background)

    exports.oxmysql:insert(
      'INSERT INTO scenes (coords, length, expires, staff, distance, route, text, background) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      { coordsJson, scene.length, scene.expires, scene.staff and 1 or 0, scene.distance, scene.route or 0, textJson, backgroundJson },
      function(insertId)
        if insertId and insertId > 0 then
          scene._id = insertId
          p:resolve(scene)
          _loadedScenes[scene._id] = scene
          TriggerClientEvent("Scenes:Client:AddScene", -1, scene._id, scene)
        else
          p:resolve(false)
        end
      end)

    return Citizen.Await(p)
  end
end)

exports('Edit', function(id, newData, isStaff)
  if newData and newData.coords then
    newData.coords = {
      x = newData.coords.x,
      y = newData.coords.y,
      z = newData.coords.z,
    }

    if not newData.length and not isStaff then
      return false
    end

    if newData.length then
      if newData.length > 24 then
        newData.length = 24
      elseif newData.length < 1 then
        newData.length = 1
      end

      newData.expires = os.time() + (3600 * newData.length)
      newData.staff = false
    else
      newData.expires = false
      newData.staff = true
    end

    if type(newData.distance) ~= "number" or newData.distance > 10.0 or newData.distance < 1.0 then
      newData.distance = 7.5
    end

    newData._id = nil

    local p = promise.new()
    local coordsJson = json.encode(newData.coords)
    local textJson = json.encode(newData.text)
    local backgroundJson = json.encode(newData.background)

    exports.oxmysql:update(
      'UPDATE scenes SET coords = ?, length = ?, expires = ?, staff = ?, distance = ?, route = ?, text = ?, background = ? WHERE _id = ?',
      { coordsJson, newData.length, newData.expires, newData.staff and 1 or 0, newData.distance, newData.route or 0,
        textJson, backgroundJson, id },
      function(affectedRows)
        if affectedRows and affectedRows > 0 then
          newData._id = id
          p:resolve(newData)
          _loadedScenes[id] = newData
          TriggerClientEvent("Scenes:Client:AddScene", -1, newData._id, newData)
        else
          p:resolve(false)
        end
      end)

    return Citizen.Await(p)
  end
end)

exports('Delete', function(id)
  local p = promise.new()
  exports.oxmysql:update('DELETE FROM scenes WHERE _id = ?', { id }, function(affectedRows)
    local success = affectedRows and affectedRows > 0
    p:resolve(success)

    if success and _loadedScenes[id] then
      _loadedScenes[id] = nil
      TriggerClientEvent("Scenes:Client:RemoveScene", -1, id)
    end
  end)

  return Citizen.Await(p)
end)

function DeleteExpiredScenes(deleteRouted)
  local p = promise.new()

  local currentTime = os.time()
  local query
  local params = {}

  if deleteRouted then
    query = 'DELETE FROM scenes WHERE (staff = ? AND expires <= ?) OR route != ?'
    params = { 0, currentTime, 0 }
  else
    query = 'DELETE FROM scenes WHERE staff = ? AND expires <= ?'
    params = { 0, currentTime }
  end

  exports.oxmysql:update(query, params, function(affectedRows)
    if affectedRows then
      p:resolve(affectedRows)
    else
      p:resolve(false)
    end
  end)

  return Citizen.Await(p)
end

function LoadScenesFromDB()
  if not _hasLoadedScenes then
    _hasLoadedScenes = true
    DeleteExpiredScenes(true)

    exports.oxmysql:execute('SELECT * FROM scenes', {}, function(results)
      if results and #results > 0 then
        for k, v in ipairs(results) do
          if v.coords then
            v.coords = json.decode(v.coords)
          end
          if v.text then
            v.text = json.decode(v.text)
          end
          if v.background then
            v.background = json.decode(v.background)
          end
          v.staff = v.staff == 1

          _loadedScenes[v._id] = v
        end
      end
    end)
  end
end

function StartExpirationThread()
  if not _expirationThread then
    _expirationThread = true

    CreateThread(function()
      while true do
        Wait(60 * 1000 * 30)
        if _hasLoadedScenes then
          local deleteScenes = {}
          local timeStamp = os.time()

          for k, v in pairs(_loadedScenes) do
            if v.expires and timeStamp >= v.expires then
              if exports['pulsar-scenes']:Delete(v._id) then
                table.insert(deleteScenes, v._id)
              end
            end
          end

          TriggerClientEvent("Scenes:Client:RemoveScenes", -1, deleteScenes)
        end
      end
    end)
  end
end
