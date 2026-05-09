exports('ShowroomLoad', function()
    local p = promise.new()
    exports.oxmysql:execute('SELECT * FROM dealer_showrooms', {}, function(results)
        local showRoomData = {}
        if results and #results > 0 then
            for k, v in ipairs(results) do
                if _dealerships[v.dealership] then
                    local showroom = v.showroom and json.decode(v.showroom) or {}
                    showRoomData[v.dealership] = showroom
                end
            end

            GlobalState.DealershipShowrooms = showRoomData
            showroomsLoaded = true
        end
        p:resolve(results ~= nil)
    end)
    return Citizen.Await(p)
end)

exports('ShowroomUpdate', function(dealershipId, showroom)
    if _dealerships[dealershipId] then
        if type(showroom) ~= 'table' then
            showroom = {}
        end

        local p = promise.new()
        local showroomJson = json.encode(showroom)

        exports.oxmysql:execute(
            'INSERT INTO dealer_showrooms (dealership, showroom) VALUES (?, ?) ON DUPLICATE KEY UPDATE showroom = ?',
            { dealershipId, showroomJson, showroomJson },
            function(result)
                local affected = 0
                if type(result) == 'number' then
                    affected = result
                elseif type(result) == 'table' then
                    affected = result.affectedRows or result.changedRows or 0
                end

                if affected > 0 then
                    local currentData = GlobalState.DealershipShowrooms or {}
                    currentData[dealershipId] = showroom
                    GlobalState.DealershipShowrooms = currentData

                    TriggerClientEvent('Dealerships:Client:ShowroomUpdate', -1, dealershipId)
                    p:resolve(showroom)
                else
                    p:resolve(false)
                end
            end
        )

        return Citizen.Await(p)
    end
    return false
end)

exports('ShowroomUpdatePos', function(dealershipId, position, vehicleData)
    if _dealerships[dealershipId] and (#_dealerships[dealershipId].showroom >= position) then
        position = tostring(position)
        local showroomData = GlobalState.DealershipShowrooms[dealershipId] or {}
        showroomData[position] = type(vehicleData) == 'table' and vehicleData or nil

        return exports['pulsar-dealerships']:ShowroomUpdate(dealershipId, showroomData)
    end
    return false
end)
