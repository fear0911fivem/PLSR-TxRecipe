local _activeTowVehicles = {}
local maxActive = 10

_activeTowers = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-tow')

    exports["pulsar-core"]:RegisterServerCallback("Tow:RequestJob", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if not exports['pulsar-jobs']:HasJob(source, "tow") and char then
        cb(exports['pulsar-jobs']:GiveJob(char:GetData("SID"), "tow", false, "employee"))
      else
        cb(false)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Tow:QuitJob", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if exports['pulsar-jobs']:HasJob(source, "tow") and char then
        _activeTowers[source] = nil
        cb(exports['pulsar-jobs']:RemoveJob(char:GetData("SID"), "tow"))
      else
        cb(false)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Tow:OnDuty", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      local dutyData = exports['pulsar-jobs']:DutyGetDutyData("tow")
      if exports['pulsar-jobs']:HasJob(source, "tow") and char then
        if not dutyData or (dutyData and dutyData.Count < maxActive) then
          if exports['pulsar-jobs']:DutyOn(source, "tow", true) then
            _activeTowers[source] = {
              next = os.time() + (math.random(1, 3) * 60),
            }
            exports['pulsar-hud']:Notification(source, "info",
              [[
                                You are now on Duty as a Tow Truck Driver.<br><br>
                                Get a Tow Truck from Jerry in the Tow Lot.<br>
                                To Impound Vehicles, Bring them to the Tow Lot and
                                Fill out the Paperwork.
                            ]],
              10000,
              "truck-tow"
            )
          else
            exports['pulsar-hud']:Notification(source, "error", "Failed to Go On Duty",
              5000, "truck-tow")
          end
        else
          exports['pulsar-hud']:Notification(source, "error",
            "Too Many Tow Employees on Duty", 5000, "truck-tow")
        end
      else
        exports['pulsar-hud']:Notification(source, "error", "Failed to Go On Duty", 5000,
          "truck-tow")
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Tow:OffDuty", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char and exports['pulsar-jobs']:DutyGet(source, "tow") then
        local stateId = char:GetData("SID")
        if not _activeTowVehicles[stateId] then
          exports['pulsar-jobs']:DutyOff(source, "tow")
          exports['pulsar-tow']:CleanupPickup(source)
          _activeTowers[source] = nil
          exports['pulsar-phone']:NotificationRemoveById(source, "TOW_OBJ")
        else
          exports['pulsar-hud']:Notification(source, "error",
            "Return the Tow Truck Before Going Off Duty",
            5000,
            "truck-tow"
          )
        end
      else
        exports['pulsar-hud']:Notification(source, "error", "Failed to Go Off Duty", 5000,
          "truck-tow")
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Tow:RequestTruck", function(source, spaceCoords, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char and Player(source).state.onDuty == "tow" then
        local stateId = char:GetData("SID")
        if not _activeTowVehicles[stateId] then
          exports['pulsar-vehicles']:SpawnTemp(
            source,
            `flatbed`,
            'automobile',
            spaceCoords.xyz,
            spaceCoords.w,
            function(spawnedVehicle, VIN, plate)
              if spawnedVehicle then
                exports['pulsar-vehicles']:KeysAdd(source, VIN)

                _activeTowVehicles[stateId] = {
                  SID = stateId,
                  veh = spawnedVehicle,
                  net = NetworkGetNetworkIdFromEntity(spawnedVehicle),
                  VIN = VIN,
                  plate = plate,
                }

                GlobalState[string.format("TowTrucks:%s", stateId)] =
                    NetworkGetNetworkIdFromEntity(spawnedVehicle)

                exports['pulsar-hud']:Notification(source, "success",
                  "Your Tow Truck Was Provided",
                  5000,
                  "truck-tow"
                )
                cb(spawnedVehicle)
              else
                exports['pulsar-hud']:Notification(source, "error",
                  "Truck Spawn Failed", 5000, "truck-tow")
                cb(nil)
              end
            end,
            {
              Make = "MTL",
              Model = "Flatbed",
              Value = 50000,
            }
          )
        else
          exports['pulsar-hud']:Notification(source, "error", "We Already Gave You a Truck",
            5000, "truck-tow")
          cb(nil)
        end
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Tow:ReturnTruck", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char then
        local stateId = char:GetData("SID")
        local hasTruck = _activeTowVehicles[stateId]
        if hasTruck and hasTruck.veh and DoesEntityExist(hasTruck.veh) then
          local truckCoords = GetEntityCoords(hasTruck.veh)
          if #(truckCoords - _towSpaces[1].xyz) <= 20.0 then
            exports['pulsar-vehicles']:Delete(hasTruck.veh, function(success)
              if success then
                _activeTowVehicles[stateId] = nil
                GlobalState[string.format("TowTrucks:%s", stateId)] = false
                exports['pulsar-hud']:Notification(source, "success",
                  "Thanks for Returning Your Tow Truck",
                  5000,
                  "truck-tow"
                )
              else
                exports['pulsar-hud']:Notification(source, "error",
                  "Error Returning Truck",
                  5000,
                  "truck-tow"
                )
              end
            end)
          else
            exports['pulsar-hud']:Notification(source, "error",
              "Your Tow Truck Isn't Nearby",
              5000,
              "truck-tow"
            )
          end
        else
          exports['pulsar-hud']:Notification(source, "error",
            "You Don't Have a Truck to Return",
            5000,
            "truck-tow"
          )
        end
      end
    end)
  end
end)

AddEventHandler("Vehicles:Server:Deleted", function(veh, VIN)
  for k, v in pairs(_activeTowVehicles) do
    if v.veh == veh then
      GlobalState[string.format('TowTrucks:%s', v.SID)] = false
      _activeTowVehicles[v.SID] = nil
    end
  end
end)

exports('PayoutPickup', function(source)
  if _activeTowers[source] ~= nil then
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    exports['pulsar-finance']:BalanceDeposit(
      exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID")).Account, 300, {
        type = "paycheck",
        title = "Tow Fee",
        description = "Your Fee For A Vehicle Pickup",
        data = 300,
      })
    exports['pulsar-phone']:NotificationRemoveById(source, "TOW_OBJ")
    exports['pulsar-phone']:NotificationAdd(
      source,
      "Yard Manager",
      "Good work, I've sent your fee to your account. I'll let you know when I got another job for you",
      os.time(),
      10000,
      {
        color = "#247919",
        label = "Los Santos Tow",
        icon = "truck-tow",
      },
      {},
      nil
    )

    exports['pulsar-tow']:CleanupPickup(source)
  end
end)

exports('CleanupPickup', function(source)
  if _activeTowers[source] ~= nil then
    if _activeTowers[source].veh ~= nil and DoesEntityExist(_activeTowers[source].veh) then
      exports['pulsar-vehicles']:Delete(veh, function(success) end)
      _activeTowers[source].veh = nil
    end

    if _activeTowers[source].location ~= nil then
      _inuse[_activeTowers[source].location] = false
      _activeTowers[source].location = nil
    end

    _activeTowers[source].next = os.time() + (math.random(3, 6) * 60)
    _activeTowers[source].onTask = false
    TriggerClientEvent("Tow:Client:CleanupPickup", source)
  end
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source)
  exports['pulsar-tow']:CleanupPickup(source)
  _activeTowers[source] = nil
end)
AddEventHandler("Characters:Server:PlayerDropped", function(source)
  exports['pulsar-tow']:CleanupPickup(source)
  _activeTowers[source] = nil
end)
