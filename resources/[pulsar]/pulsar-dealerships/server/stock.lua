exports('StockFetchAll', function()
    local p = promise.new()
    exports.oxmysql:execute('SELECT * FROM dealer_stock', {}, function(result)
        if result then
            for i, record in ipairs(result) do
                if record.data then
                    record.data = json.decode(record.data)
                end
            end
            p:resolve(result)
        else
            p:resolve(false)
        end
    end)
    return Citizen.Await(p)
end)

exports('StockFetchDealer', function(dealerId)
    local p = promise.new()
    exports.oxmysql:execute('SELECT * FROM dealer_stock WHERE dealership = ?', { dealerId }, function(result)
        if result then
            for i, record in ipairs(result) do
                if record.data then
                    record.data = json.decode(record.data)
                end
            end
            p:resolve(result)
        else
            p:resolve(false)
        end
    end)
    return Citizen.Await(p)
end)

exports('StockFetchDealerVehicle', function(dealerId, vehModel)
    local p = promise.new()
    exports.oxmysql:execute('SELECT * FROM dealer_stock WHERE dealership = ? AND vehicle = ?', { dealerId, vehModel },
        function(result)
            if result and #result > 0 then
                if result[1].data then
                    result[1].data = json.decode(result[1].data)
                end
                p:resolve(result[1])
            else
                p:resolve(false)
            end
        end)
    return Citizen.Await(p)
end)

exports('StockHasVehicle', function(dealerId, vehModel)
    local vehicle = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)
    if vehicle and vehicle.quantity > 0 then
        return vehicle.quantity
    else
        return false
    end
end)

exports('StockAdd', function(dealerId, vehModel, modelType, quantity, vehData)
    vehData = ValidateVehicleData(vehData)
    if _dealerships[dealerId] and vehModel and vehData and quantity > 0 then
        local isStocked = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)
        local p = promise.new()
        if isStocked then -- The vehicle is already stocked
            exports.oxmysql:execute(
                'UPDATE dealer_stock SET quantity = quantity + ?, data = ?, lastStocked = ? WHERE dealership = ? AND vehicle = ?',
                { quantity, json.encode(vehData), os.time(), dealerId, vehModel }, function(result)
                    if result and result.affectedRows > 0 then
                        p:resolve({
                            success = true,
                            existed = true,
                        })
                    else
                        p:resolve(false)
                    end
                end)
        else
            exports.oxmysql:insert(
                'INSERT INTO dealer_stock (dealership, vehicle, modelType, data, quantity, lastStocked) VALUES (?, ?, ?, ?, ?, ?)',
                { dealerId, vehModel, modelType, json.encode(vehData), quantity, os.time() }, function(insertId)
                    if insertId and insertId > 0 then
                        p:resolve({
                            success = true,
                            existed = false,
                        })
                    else
                        p:resolve(false)
                    end
                end)
        end
        return Citizen.Await(p)
    end
    return false
end)

exports('StockIncrease', function(dealerId, vehModel, amount)
    if _dealerships[dealerId] and vehModel and amount > 0 then
        local isStocked = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)
        if isStocked then -- The vehicle is already stocked
            local p = promise.new()
            exports.oxmysql:execute(
                'UPDATE dealer_stock SET quantity = quantity + ?, lastStocked = ? WHERE dealership = ? AND vehicle = ?',
                { amount, os.time(), dealerId, vehModel }, function(result)
                    if result and result.affectedRows > 0 then
                        p:resolve({ success = true })
                    else
                        p:resolve(false)
                    end
                end)
            return Citizen.Await(p)
        else
            return false
        end
    end
    return false
end)

exports('StockUpdate', function(dealerId, vehModel, setting)
    if _dealerships[dealerId] and vehModel and type(setting) == "table" then
        local isStocked = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)
        if isStocked then -- The vehicle is already stocked
            local p = promise.new()
            local updateFields = {}
            local updateValues = {}

            for key, value in pairs(setting) do
                table.insert(updateFields, key .. " = ?")
                if key == "data" and type(value) == "table" then
                    table.insert(updateValues, json.encode(value))
                else
                    table.insert(updateValues, value)
                end
            end

            local query = "UPDATE dealer_stock SET " ..
                table.concat(updateFields, ", ") .. " WHERE dealership = ? AND vehicle = ?"
            table.insert(updateValues, dealerId)
            table.insert(updateValues, vehModel)

            exports.oxmysql:execute(query, updateValues, function(result)
                if result and result.affectedRows > 0 then
                    p:resolve({ success = true })
                else
                    p:resolve(false)
                end
            end)
            return Citizen.Await(p)
        else
            return false
        end
    end
    return false
end)

exports('StockEnsure', function(dealerId, vehModel, quantity, vehData)
    if _dealerships[dealerId] and vehModel then
        local isStocked = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)
        if isStocked then
            local missingQuantity = quantity - isStocked.quantity
            if missingQuantity >= 1 then
                return exports['pulsar-dealerships']:StockAdd(dealerId, vehModel, missingQuantity, vehData)
            end
        else
            return exports['pulsar-dealerships']:StockAdd(dealerId, vehModel, quantity, vehData)
        end
    end
    return false
end)

exports('StockRemove', function(dealerId, vehModel, quantity)
    if _dealerships[dealerId] and vehModel and quantity > 0 then
        local isStocked = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerId, vehModel)

        if isStocked and isStocked.quantity > 0 then
            local newQuantity = isStocked.quantity - quantity
            if newQuantity >= 0 then
                local p = promise.new()
                exports.oxmysql:execute(
                    'UPDATE dealer_stock SET quantity = ?, lastPurchase = ? WHERE dealership = ? AND vehicle = ?',
                    { newQuantity, os.time(), dealerId, vehModel }, function(result)
                        if result and result.affectedRows > 0 then
                            p:resolve(newQuantity)
                        else
                            p:resolve(false)
                        end
                    end)
                return Citizen.Await(p)
            end
        end
    end
    return false
end)

local requiredAttributes = {
    make = 'string',
    model = 'string',
    class = 'string',
    --category = 'string',
    price = 'number'
}

function ValidateVehicleData(data)
    if type(data) ~= 'table' then
        return false
    end
    for k, v in pairs(requiredAttributes) do
        if data[k] == nil or type(data[k]) ~= v then
            return false
        end
    end

    return data
end
