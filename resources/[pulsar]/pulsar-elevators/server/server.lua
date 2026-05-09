ELEVATOR_CACHE = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()

    RunStartup()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-elevators')
  end
end)

local _startup = false
function RunStartup()
  if _startup then
    return
  end
  _startup = true

  for k, v in ipairs(_elevatorConfig) do
    ELEVATOR_CACHE[k] = {
      floors = {},
    }

    for k2, v2 in pairs(v.floors) do
      ELEVATOR_CACHE[k].floors[k2] = {
        locked = v2.defaultLocked or false,
      }
    end
  end

  exports['pulsar-core']:LoggerTrace("Elevators", "Loaded ^2" .. #_elevatorConfig .. "^7 Elevators")
end

function RegisterCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Elevators:Fetch", function(source, data, cb)
    cb(ELEVATOR_CACHE)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Elevators:ToggleLocks", function(source, data, cb)
    local targetElevator = _elevatorConfig[data.elevator]
    if targetElevator and targetElevator.canLock and CheckPlayerAuth(source, targetElevator.canLock) then
      local newState = exports['pulsar-elevators']:SetElevatorLock(data.elevator, data.floor)
      if newState == nil then
        cb(false, false)
      else
        cb(true, newState)
      end
    else
      cb(false)
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Elevators:Validate", function(source, data, cb)
    exports['pulsar-pwnzor']:TempPosIgnore(source)
    cb()
  end)
end

exports('SetElevatorLock', function(elevatorId, floorId, newState)
  local data = _elevatorConfig[elevatorId]

  if
      data
      and ELEVATOR_CACHE[elevatorId]
      and ELEVATOR_CACHE[elevatorId].floors
      and ELEVATOR_CACHE[elevatorId].floors[floorId]
  then
    local isLocked = ELEVATOR_CACHE[elevatorId].floors[floorId].locked
    if newState == nil then
      newState = not isLocked
    end

    if data and newState ~= isLocked then
      ELEVATOR_CACHE[elevatorId].floors[floorId].locked = newState
      TriggerClientEvent("Elevators:Client:UpdateElevatorState", -1, elevatorId, floorId, newState)
    end
    return newState
  end
  return nil
end)



function CheckPlayerAuth(source, doorPermissionData)
  if type(doorPermissionData) ~= "table" then
    return true
  end

  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char then
    local stateId = char:GetData("SID")

    if exports['pulsar-jobs']:HasJob(source, "dgang", false, false, 99, true) then
      return true
    end

    for k, v in ipairs(doorPermissionData) do
      if v.type == "character" then
        if stateId == v.SID then
          return true
        end
      elseif v.type == "job" then
        if v.job then
          if
              exports['pulsar-jobs']:HasJob(
                source,
                v.job,
                v.workplace,
                v.grade,
                v.gradeLevel,
                v.reqDuty,
                v.jobPermission
              )
          then
            return true
          end
        elseif v.jobPermission then
          if exports['pulsar-jobs']:HasPermission(source, v.jobPermission) then
            return true
          end
        end
      elseif v.type == "propertyData" then
        if exports['pulsar-properties']:HasAccessWithData(source, v.key, v.value) then
          return true
        end
      end
    end
  end
  return false
end
