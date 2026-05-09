AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterMiddleware()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-escort')
  end
end)

exports("EscortDo", function(source, data)
  local mPed = GetPlayerPed(source)
  local tPed = GetPlayerPed(data.target)

  local mPos = GetEntityCoords(mPed)
  local tPos = GetEntityCoords(tPed)

  local pState = Player(source).state
  local tState = Player(data.target).state

  if tState.myEscorter == nil and (pState.myDuty == "ems" or not tState.ICU) then
    local dist = #(vector3(mPos.x, mPos.y, mPos.z) - vector3(tPos.x, tPos.y, tPos.z))
    if dist <= 1.5 or (data.inVeh and dist <= 5) or (data.isSwimming and dist <= 15) then
      if data.inVeh then
        TaskLeaveAnyVehicle(tPed, 0, 16)
      end

      pState.isEscorting = data.target
      tState.myEscorter = source
      TriggerClientEvent("Escort:Client:Escorted", data.target)
      return true
    else
      return false
    end
  else
    return false
  end
end)

exports("EscortDoPutIn", function(source, data)
  local pState = Player(source).state
  if pState.isEscorting ~= nil then
    local tPed = GetPlayerPed(pState.isEscorting)
    local tState = Player(pState.isEscorting).state
    local veh = NetworkGetEntityFromNetworkId(data.veh)
    ClearPedTasksImmediately(tPed)

    if data.class == 18 then -- Emergency
      -- Favour Lowest Back Seat But Try Passenger Seat as Last Resort
      local maxSeats = data.seatCount - 1
      for i = 1, maxSeats do
        local seat = (i < maxSeats) and i or 0

        local ent = GetPedInVehicleSeat(veh, seat)
        if ent == 0 then
          TaskWarpPedIntoVehicle(tPed, veh, seat)
          break
        end
      end
    else
      -- Favour Highest Back Seats First
      for i = (data.seatCount - 2), 0, -1 do
        local ent = GetPedInVehicleSeat(veh, i)
        if ent == 0 then
          TaskWarpPedIntoVehicle(tPed, veh, i)
          break
        end
      end
    end

    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
    return true
  else
    return false
  end
end)

exports("EscortStop", function(source)
  local pState = Player(source).state
  if pState.isEscorting ~= nil then
    local tState = Player(pState.isEscorting).state

    if GetPlayerEndpoint(pState.isEscorting) then -- Check if player source still online
      local p = promise.new()
      exports["pulsar-core"]:ClientCallback(pState.isEscorting, "Escort:StopEscort", {}, function()
        p:resolve(true)
      end)
      Citizen.Await(p)
    end

    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  end
end)

function RegisterCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Escort:DoEscort", function(source, data, cb)
    cb(exports['pulsar-escort']:EscortDo(source, data))
  end)

  exports["pulsar-core"]:RegisterServerCallback("Escort:DoPutIn", function(source, data, cb)
    cb(exports['pulsar-escort']:EscortDoPutIn(source, data))
  end)

  exports["pulsar-core"]:RegisterServerCallback("Escort:StopEscort", function(source, data, cb)
    exports['pulsar-escort']:EscortStop(source)
  end)
end

function RegisterMiddleware()

end

local function HandleLogout(source)
  local pState = Player(source).state

  if pState.isEscorting ~= nil then
    local tState = Player(pState.isEscorting).state

    if GetPlayerEndpoint(pState.isEscorting) then -- Check if player source still online
      local p = promise.new()
      exports["pulsar-core"]:ClientCallback(pState.isEscorting, "Escort:StopEscort", {}, function()
        p:resolve(true)
      end)
      Citizen.Await(p)
    end

    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  elseif pState.myEscorter ~= nil then
    local tState = Player(pState.myEscorter).state

    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil

    local p = promise.new()
    exports["pulsar-core"]:ClientCallback(source, "Escort:StopEscort", {}, function()
      p:resolve(true)
    end)
    Citizen.Await(p)
  end
end

AddEventHandler("Characters:Server:PlayerLoggedOut", HandleLogout)
AddEventHandler("Characters:Server:PlayerDropped", HandleLogout)

RegisterNetEvent("Ped:Server:Died", function()
  local src = source
  local pState = Player(src).state
  if pState.isEscorting ~= nil then
    local tState = Player(pState.isEscorting).state
    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  elseif pState.myEscorter then
    local tState = Player(pState.myEscorter).state
    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  end
end)

RegisterNetEvent("Escort:Server:ForceStop", function()
  local src = source
  local pState = Player(src).state
  if pState.isEscorting ~= nil then
    local tState = Player(pState.isEscorting).state
    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  elseif pState.myEscorter then
    local tState = Player(pState.myEscorter).state
    tState.myEscorter = nil
    tState.isEscorting = nil
    pState.myEscorter = nil
    pState.isEscorting = nil
  end
end)

RegisterNetEvent("Escort:Server:DoPutIn", function(veh)
  local src = source
  local pState = Player(src).state

  if pState.isEscorting ~= nil then
    exports["pulsar-core"]:ClientCallback(pState.isEscorting, "Escort:StopEscort", {}, function() end)
  end
end)
