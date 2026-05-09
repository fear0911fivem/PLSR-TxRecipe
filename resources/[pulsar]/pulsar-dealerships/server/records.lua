-- Dealership Sale Records
exports('RecordsGet', function(dealership)
    if _dealerships[dealership] then
        local p = promise.new()
        exports.oxmysql:execute('SELECT * FROM dealer_records WHERE dealership = ? ORDER BY time DESC LIMIT 100',
            { dealership }, function(results)
                if results then
                    for i, record in ipairs(results) do
                        if record.seller then
                            record.seller = json.decode(record.seller)
                        end
                        if record.buyer then
                            record.buyer = json.decode(record.buyer)
                        end
                        if record.vehicle then
                            record.vehicle = json.decode(record.vehicle)
                        end
                        if record.price then
                            record.salePrice = tonumber(record.price)
                            record.price = nil
                        end
                        if record.commission then
                            record.commission = tonumber(record.commission)
                        end
                    end
                    p:resolve(results)
                else
                    p:resolve(false)
                end
            end)
        return Citizen.Await(p)
    end
    return false
end)

exports('RecordsGetPage', function(category, term, dealership, page, perPage)
    if _dealerships[dealership] then
        local p = promise.new()

        local skip = 0
        if page > 1 then
            skip = perPage * (page - 1)
        end

        local query = 'SELECT * FROM dealer_records WHERE dealership = ?'
        local params = { dealership }

        if category ~= "all" then
            query = query .. ' AND JSON_EXTRACT(vehicle, "$.data.category") = ?'
            table.insert(params, category)
        end

        if term and #term > 0 then
            query = query ..
                ' AND (JSON_EXTRACT(seller, "$.First") LIKE ? OR JSON_EXTRACT(seller, "$.Last") LIKE ? OR JSON_EXTRACT(buyer, "$.First") LIKE ? OR JSON_EXTRACT(buyer, "$.Last") LIKE ? OR JSON_EXTRACT(vehicle, "$.data.make") LIKE ? OR JSON_EXTRACT(vehicle, "$.data.model") LIKE ?)'
            local searchTerm = '%' .. term .. '%'
            for i = 1, 6 do
                table.insert(params, searchTerm)
            end
        end

        query = query .. ' ORDER BY time DESC LIMIT ? OFFSET ?'
        table.insert(params, perPage + 1)
        table.insert(params, skip)

        exports.oxmysql:execute(query, params, function(results)
            if results then
                for i, record in ipairs(results) do
                    if record.seller then
                        record.seller = json.decode(record.seller)
                    end
                    if record.buyer then
                        record.buyer = json.decode(record.buyer)
                    end
                    if record.vehicle then
                        record.vehicle = json.decode(record.vehicle)
                    end
                    if record.price then
                        record.salePrice = tonumber(record.price)
                        record.price = nil
                    end
                    if record.commission then
                        record.commission = tonumber(record.commission)
                    end
                end

                local more = false
                if #results > perPage then
                    more = true
                    table.remove(results)
                end

                p:resolve({
                    data = results,
                    more = more,
                })
            else
                p:resolve(false)
            end
        end)
        return Citizen.Await(p)
    end
    return false
end)

exports('RecordsCreate', function(dealership, document)
    if type(document) == 'table' then
        document.dealership = dealership
        
        local price = document.price or document.salePrice
        local commission = document.commission
        
        local p = promise.new()

        local sellerJson = document.seller and json.encode(document.seller) or nil
        local buyerJson = document.buyer and json.encode(document.buyer) or nil
        local vehicleJson = document.vehicle and json.encode(document.vehicle) or nil

        exports.oxmysql:execute(
            'INSERT INTO dealer_records (dealership, time, seller, buyer, vehicle, price, commission) VALUES (?, ?, ?, ?, ?, ?, ?)',
            { document.dealership, document.time, sellerJson, buyerJson, vehicleJson, price, commission },
            function(result)
                if result then
                    p:resolve(true)
                else
                    p:resolve(false)
                end
            end)
        return Citizen.Await(p)
    end
    return false
end)

exports('RecordsCreateBuyBack', function(dealership, document)
    if type(document) == 'table' then
        document.dealership = dealership
        local p = promise.new()

        local vehicleJson = document.vehicle and json.encode(document.vehicle) or nil
        local previousOwnerJson = document.previousOwner and json.encode(document.previousOwner) or nil
        local buyerJson = document.buyer and json.encode(document.buyer) or nil

        exports.oxmysql:execute(
            'INSERT INTO dealer_records_buybacks (dealership, time, vehicle, previousOwner, buyer) VALUES (?, ?, ?, ?, ?)',
            { document.dealership, document.time, vehicleJson, previousOwnerJson, buyerJson },
            function(insertId)
                p:resolve(insertId and (type(insertId) == "number" and insertId > 0) or
                    (type(insertId) == "table" and insertId.insertId and insertId.insertId > 0))
            end)
        return Citizen.Await(p)
    end
    return false
end)
