function RegisterDonorVehicleSaleCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Dealerships:DonorSales:GetStock", function(source, data, cb)
    local plyr = exports['pulsar-core']:FetchSource(source)
    if plyr and _donorDealerships[data] then
      local pending = exports['pulsar-dealerships']:DonatorGetPending(plyr:GetData("Identifier"))

      if pending and #pending > 0 then
        local filtered = {}
        local allowedClasses = {}
        local classList = {}

        for k, v in ipairs(pending) do
          allowedClasses[v.class] = true
          table.insert(classList, v.class)
        end

        local dealerData = exports['pulsar-dealerships']:StockFetchDealer(_donorDealerships[data].availableVehicles)

        for k, v in ipairs(dealerData) do
          if allowedClasses[v.data.class] and (not _donorDealerships[data].flags.depleteStockOnPurchase or v.quantity > 0) then
            table.insert(filtered, v)
          end
        end

        cb({
          stock = filtered,
          classDisplay = table.concat(classList, ", ")
        })
        return
      end
    end

    cb(false)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Dealerships:DonorSales:GetPending", function(source, data, cb)
    local plyr = exports['pulsar-core']:FetchSource(source)
    if plyr then
      local pending = exports['pulsar-dealerships']:DonatorGetPending(plyr:GetData("Identifier"), true)
      local mainMenuItems = {}
      for k, v in ipairs(pending) do
        if not v.redeemed then
          table.insert(mainMenuItems, {
            label = string.format("%s Class Vehicle", v.class),
            description = string.format("UID: %s", v._id),
            disabled = v.redeemed,
          })
        end
      end

      for k, v in ipairs(pending) do
        if v.redeemed then
          table.insert(mainMenuItems, {
            label = string.format("%s Class Vehicle", v.class),
            description = string.format("UID: %s", v._id),
            disabled = v.redeemed,
          })
        end
      end

      cb({
        main = {
          label = "Unredeemed Vehicle Purchases",
          items = mainMenuItems
        }
      })
      return
    end

    cb(false)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Dealerships:DonorSales:Purchase", function(source, data, cb)
    if data?.dealer and data?.vehicle and _donorDealerships[data.dealer] then
      local plyr = exports['pulsar-core']:FetchSource(source)
      if plyr then
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        local hostDealer = _donorDealerships[data.dealer].availableVehicles
        local dealerData = _dealerships[hostDealer]

        if char and hostDealer then
          local profitPercent = exports['pulsar-dealerships']:ManagementGetData(hostDealer, 'profitPercentage')
          local commissionPercent = exports['pulsar-dealerships']:ManagementGetData(hostDealer, 'commission')
          local saleVehicleData = exports['pulsar-dealerships']:StockFetchDealerVehicle(hostDealer, data.vehicle)

          if profitPercent and commissionPercent and saleVehicleData and saleVehicleData.quantity > 0 and saleVehicleData.data.price and saleVehicleData.data.price > 0 then
            local donatorStuff = exports['pulsar-dealerships']:DonatorGetPending(plyr:GetData("Identifier"))

            local allowedClasses = {}
            for k, v in ipairs(donatorStuff) do
              allowedClasses[v.class] = true
            end

            if allowedClasses[saleVehicleData.data.class] then
              local vehiclePrice = saleVehicleData.data.price
              local priceMultiplier = 1 + (profitPercent / 100)
              local commissionMultiplier = (commissionPercent / 100)
              local salePrice = exports['pulsar-core']:UtilsRound(vehiclePrice * priceMultiplier, 0)

              local playerCommission = exports['pulsar-core']:UtilsRound(
                (salePrice - vehiclePrice) * commissionMultiplier, 0)
              local dealerRecieves = exports['pulsar-core']:UtilsRound(salePrice - playerCommission, 0)

              local removeSuccess = nil
              if _donorDealerships[data.dealer].flags.depleteStockOnPurchase then
                removeSuccess = exports['pulsar-dealerships']:StockRemove(hostDealer, saleVehicleData.vehicle, 1)
              else
                removeSuccess = saleVehicleData.quantity
              end

              local removeId
              for k, v in ipairs(donatorStuff) do
                if v.class == saleVehicleData.data.class then
                  removeId = v._id
                end
              end

              local revokeToken = exports['pulsar-dealerships']:DonatorRemovePending(plyr:GetData("Identifier"),
                removeId)
              if removeSuccess and revokeToken then
                exports['pulsar-vehicles']:OwnedAddToCharacter(char:GetData('SID'), GetHashKey(saleVehicleData.vehicle),
                  0,
                  saleVehicleData.modelType, {
                    make = saleVehicleData.data.make,
                    model = saleVehicleData.data.model,
                    class = saleVehicleData.data.class,
                    value = salePrice,
                    donatorFlag = true,
                  }, function(success, vehicleData)
                    if success and vehicleData then
                      if _donorDealerships[data.dealer].flags.depleteStockOnPurchase then
                        exports['pulsar-dealerships']:RecordsCreate(hostDealer, {
                          time = os.time(),
                          type = "full",
                          vehicle = {
                            VIN = vehicleData.VIN,
                            vehicle = saleVehicleData.vehicle,
                            data = saleVehicleData.data,
                          },
                          profitPercent = profitPercent,
                          salePrice = salePrice,
                          dealerProfits = 0, --dealerRecieves,
                          commission = 0,
                          buyer = {
                            ID = char:GetData('ID'),
                            SID = char:GetData('SID'),
                            First = char:GetData('First'),
                            Last = char:GetData('Last'),
                          },
                          newQuantity = removeSuccess,
                        })

                        SendDealerProfits(dealerData, 100, false, 0, saleVehicleData.data, {
                          SID = char:GetData('SID'),
                          First = char:GetData('First'),
                          Last = char:GetData('Last'),
                          Source = source,
                        })
                      end

                      SendCompletedCashSaleEmail({
                        SID = char:GetData('SID'),
                        First = char:GetData('First'),
                        Last = char:GetData('Last'),
                        Source = source,
                      }, dealerData, saleVehicleData.data, salePrice, vehicleData.VIN, vehicleData.RegisteredPlate)

                      cb(true)

                      exports['pulsar-core']:LoggerWarn(
                        "Donator",
                        string.format(
                          "%s [%s] Redeemed %s Class Donator Vehicle - Character %s %s (%s) - Vehicle %s %s",
                          plyr:GetData("Name"),
                          plyr:GetData("AccountID"),
                          saleVehicleData.data.class,
                          char:GetData('First'),
                          char:GetData('Last'),
                          char:GetData('SID'),
                          saleVehicleData.data.make,
                          saleVehicleData.data.model
                        ),
                        {
                          console = true,
                          file = false,
                          database = true,
                          discord = {
                            embed = true,
                            type = "error",
                            webhook = GetConvar("discord_donation_webhook", ''),
                          }
                        }
                      )
                      return
                    end
                  end, false, _donorDealerships[data.dealer].storage)
              end
            end
          end
        end
      end
    end

    cb(false)
  end)

  exports["pulsar-chat"]:RegisterAdminCommand("adddonatorvehicle", function(source, args, rawCommand)
    local license, class = table.unpack(args)

    if license and class then
      local success = exports['pulsar-dealerships']:DonatorAddPending(license, class)
      if success then
        exports["pulsar-chat"]:SendSystemSingle(source, "Successfully Added Donator Token")
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Failed")
      end
    end
  end, {
    help = "[Admin] Add a players donator vehicles",
    params = {
      {
        name = "Player Identifier",
        help = "Player License",
      },
      {
        name = "Vehicle Class",
        help = "Vehicle Class",
      },
    },
  }, 2)

  exports["pulsar-chat"]:RegisterAdminCommand("getdonatorvehicle", function(source, args, rawCommand)
    local license = table.unpack(args)

    if license then
      local res = exports['pulsar-dealerships']:DonatorGetPending(license, true)
      if res then
        local message = string.format("Player Identifier: %s<br>", license)
        for k, v in ipairs(res) do
          message = message ..
              string.format("<br>ID: %s<br>Class: %s<br>Redeemed: %s<br>", v._id, v.class, v.redeemed and "Yes" or "No")
        end
        exports["pulsar-chat"]:SendSystemSingle(source, message)
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Failed")
      end
    end
  end, {
    help = "[Admin] Check donator vehicles",
    params = {
      {
        name = "Player Identifier",
        help = "Player License",
      },
    },
  }, 1)

  exports["pulsar-chat"]:RegisterAdminCommand("removedonatorvehicle", function(source, args, rawCommand)
    local license, tokenId = table.unpack(args)

    if license and tokenId then
      local success = exports['pulsar-dealerships']:DonatorDeletePending(license, tokenId)
      if success then
        exports["pulsar-chat"]:SendSystemSingle(source, "Successfully Removed")
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Failed")
      end
    end
  end, {
    help = "[Admin] Remove donator vehicles",
    params = {
      {
        name = "Player Identifier",
        help = "Player License",
      },
      {
        name = "ID",
        help = "Donator Vehicle Pending Token",
      },
    },
  }, 2)
end

exports('DonatorAddPending', function(playerIdentifier, class, data)
  local p = promise.new()
  local dataJson = data and json.encode(data) or nil

  exports.oxmysql:execute(
    'INSERT INTO donator_vehicles (player, class, redeemed, data) VALUES (?, ?, ?, ?)',
    { playerIdentifier, class, false, dataJson },
    function(insertId)
      p:resolve(insertId and insertId > 0)
    end)

  return Citizen.Await(p)
end)

exports('DonatorGetPending', function(playerIdentifier, includeRedeemed)
  local p = promise.new()

  local query = 'SELECT * FROM donator_vehicles WHERE player = ?'
  local params = { playerIdentifier }

  if not includeRedeemed then
    query = query .. ' AND redeemed = ?'
    table.insert(params, false)
  end

  exports.oxmysql:execute(query, params, function(results)
    if results and #results > 0 then
      for k, v in ipairs(results) do
        if v.data then
          v.data = json.decode(v.data)
        end
      end
      p:resolve(results)
    else
      p:resolve({})
    end
  end)

  return Citizen.Await(p)
end)

exports('DonatorRemovePending', function(playerIdentifier, id)
  local p = promise.new()

  exports.oxmysql:execute(
    'UPDATE donator_vehicles SET redeemed = ? WHERE player = ? AND id = ?',
    { true, playerIdentifier, id },
    function(affectedRows)
      p:resolve(affectedRows and affectedRows > 0)
    end)

  return Citizen.Await(p)
end)

exports('DonatorDeletePending', function(playerIdentifier, id)
  local p = promise.new()

  exports.oxmysql:execute(
    'DELETE FROM donator_vehicles WHERE player = ? AND id = ?',
    { playerIdentifier, id },
    function(affectedRows)
      p:resolve(affectedRows and affectedRows > 0)
    end)

  return Citizen.Await(p)
end)

AddEventHandler("DonorDealer:Server:AddCarToPlayer", function(identifier, class)
  exports['pulsar-dealerships']:DonatorAddPending(identifier, class)
end)

function TebexAddDonatorVehicle(source, args)
  local sid, class = table.unpack(args)
  sid = tonumber(sid)
  if sid == nil or sid == 0 then
    exports['pulsar-core']:LoggerWarn(
      "Donator Vehicle",
      "Provided SID (server ID) was empty.",
      {
        console = true,
        file = false,
        database = true,
        discord = {
          embed = true,
          type = "error",
          webhook = GetConvar("discord_donation_webhook", ''),
        }
      }
    )
    return
  end
  local player = exports['pulsar-core']:FetchSource(sid)
  if player then
    local license = player:GetData("Identifier")
    if license and class then
      local success = exports['pulsar-dealerships']:DonatorAddPending(license, class)
      if success then
        exports["pulsar-chat"]:SendSystemSingle(sid, "Successfully Added Donator Token")
      else
        exports["pulsar-chat"]:SendSystemSingle(sid, "Failed")
      end
    end
  end
end

RegisterCommand("tebexadddonatorvehicle", TebexAddDonatorVehicle, true)
