_tempIds = 1
_placedProps = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-objects')
    local props = MySQL.query.await("SELECT * FROM placed_props WHERE is_enabled = 1", {})
    local restored = 0
    for k, v in ipairs(props) do
      if _placedProps[v.id] == nil or not DoesEntityExist(_placedProps[v.id]?.entity) then
        local coords = json.decode(v.coords)
        local rotation = json.decode(v.rotation)
        _placedProps[v.id] = {
          id = v.id,
          type = v.type,
          model = GetHashKey(v.model),
          coords = coords,
          heading = v.heading,
          rotation = rotation,
          created = math.ceil(v.created / 1000),
          creator = v.creator,
          isFrozen = v.is_frozen,
          nameOverride = v.name_override,
        }
        restored += 1
      end
    end
    exports['pulsar-core']:LoggerTrace("Objects",
      string.format("Restored ^2%s^7 Persistant Props From Database", restored))

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      TriggerClientEvent("Objects:Client:SetupObjects", source, _placedProps)
    end, 1)

    exports["pulsar-chat"]:RegisterAdminCommand("addobj", function(source, args, rawCommand)
      exports["pulsar-core"]:ClientCallback(source, "Objects:StartPlacement", {
        model = GetHashKey(args[1]),
        data = {
          model = args[1],
          type = tonumber(args[2]),
          nameOverride = args[4],
          isTemp = false,
          isFrozen = args[3] == "1",
        },
      }, function() end)
    end, {
      help = "Create A Persistent Prop",
      params = {
        {
          name = "Prop Model",
          help = "Name for the prop model to spawn",
        },
        {
          name = "Prop Type",
          help = "Type of prop (0: Normal, 1: Has Inventory, 2: No Delete/Info Prompts)",
        },
        {
          name = "Is Frozen?",
          help = "Freeze entity? 1 = Yes, 0 = No",
        },
        {
          name = "Name Override",
          help = "Overrides the name displayed in inventory, put 0 to disable",
        },
      },
    }, 4)

    exports["pulsar-chat"]:RegisterAdminCommand("addtobj", function(source, args, rawCommand)
      exports["pulsar-core"]:ClientCallback(source, "Objects:StartPlacement", {
        model = GetHashKey(args[1]),
        data = {
          model = args[1],
          type = tonumber(args[2]),
          nameOverride = args[4],
          isTemp = true,
          isFrozen = args[3] == "1",
        },
      }, function() end)
    end, {
      help = "Create A Temporary Prop",
      params = {
        {
          name = "Prop Model",
          help = "Name for the prop model to spawn",
        },
        {
          name = "Prop Type",
          help = "Type of prop (0: Normal, 1: Has Inventory)",
        },
        {
          name = "Is Frozen?",
          help = "Freeze entity? 1 = Yes, 0 = No",
        },
        {
          name = "Name Override",
          help = "Overrides the name displayed in inventory, put 0 to disable",
        },
      },
    }, 4)

    exports["pulsar-chat"]:RegisterAdminCommand("deleteobj", function(source, args, rawCommand)
      exports['pulsar-objects']:Delete(source, tonumber(args[1]))
    end, {
      help = "Delete a Prop",
      params = {
        {
          name = "ID",
          help = "ID of Object to Delete",
        },
      },
    }, 1)
  end
end)

exports('Info', function(source, id)
  local plyr = exports['pulsar-core']:FetchSource(source)
  if plyr ~= nil then
    if plyr.Permissions:IsStaff() or plyr.Permissions:IsAdmin() then
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        if _placedProps[id] ~= nil then
          exports["pulsar-chat"]:SendServerSingle(
            source,
            string.format(
              "Prop %s: Creator %s, Created %s, Frozen %s, Persistant %s",
              id,
              _placedProps[id].creator,
              os.date("%m/%d/%Y %I:%M %p", _placedProps[id].created),
              tostring(_placedProps[id].isFrozen),
              tostring(not _placedProps[id].isTemp)
            )
          )
        else
          exports["pulsar-chat"]:SendServerSingle(source,
            string.format("Unable To Locate Placed Prop With ID %s", id))
        end
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end)

exports('Create', function(source, type, isTemp, model, coords, rotation, isFrozen, nameOverride)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local id = nil

    local modelhash = GetHashKey(model)
    if isTemp then
      id = string.format("TMP-%s", _tempIds)
      _tempIds += 1
      exports['pulsar-core']:LoggerWarn(
        "Objects",
        string.format(
          "%s %s (%s) Created Temporary Object: %s (%s)",
          char:GetData("First"),
          char:GetData("Last"),
          char:GetData("SID"),
          model,
          id
        )
      )
    else
      id = MySQL.insert.await(
        "INSERT INTO placed_props (model, coords, rotation, heading, creator, is_frozen, type, name_override) VALUES(?, ?, ?, ?, ?, ?, ?, ?)",
        {
          model,
          json.encode(coords),
          json.encode(rotation),
          0,
          char:GetData("SID"),
          isFrozen,
          type,
          nameOverride ~= "0" and nameOverride or "Placed Object",
        }
      )

      exports['pulsar-core']:LoggerWarn(
        "Objects",
        string.format(
          "%s %s (%s) Created Persistant Object: %s (%s)",
          char:GetData("First"),
          char:GetData("Last"),
          char:GetData("SID"),
          model,
          id
        )
      )
    end

    _placedProps[id] = {
      id = id,
      type = type,
      created = os.time(),
      creator = char:GetData("SID"),
      model = modelhash,
      coords = coords,
      rotation = rotation,
      heading = 0,
      isFrozen = isFrozen,
      nameOverride = nameOverride ~= "0" and nameOverride or "Placed Object",
      temp = isTemp,
    }
    TriggerClientEvent(
      "Objects:Client:Create",
      -1,
      id,
      type,
      char:GetData("SID"),
      modelhash,
      coords,
      0,
      rotation,
      isFrozen,
      nameOverride ~= "0" and nameOverride or "Placed Object"
    )
  else
    return false
  end
end)

exports('Delete', function(source, id)
  local plyr = exports['pulsar-core']:FetchSource(source)
  if plyr ~= nil and id ~= nil then
    if plyr.Permissions:IsStaff() or plyr.Permissions:IsAdmin() then
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        if not _placedProps[id].temp then
          MySQL.query.await("DELETE FROM placed_props WHERE id = ?", { id })
        end
        TriggerClientEvent("Objects:Client:Delete", -1, id)
        exports['pulsar-core']:LoggerInfo(
          "Objects",
          string.format(
            "%s %s (%s) Deleted Object: %s",
            char:GetData("First"),
            char:GetData("Last"),
            char:GetData("SID"),
            id
          )
        )

        _placedProps[id] = nil
      end
    else
      return false
    end
  else
    return false
  end
end)

RegisterNetEvent("Objects:Server:Create", function(data, endCoords)
  local src = source
  exports['pulsar-objects']:Create(src, data.type, data.isTemp, data.model, endCoords.coords, endCoords.rotation,
    data.isFrozen,
    data.nameOverride)
end)

RegisterNetEvent("Objects:Server:Delete", function(id)
  local src = source
  exports['pulsar-objects']:Delete(src, id)
end)

RegisterNetEvent("Objects:Server:View", function(id)
  local src = source
  exports['pulsar-objects']:Info(src, id)
end)
