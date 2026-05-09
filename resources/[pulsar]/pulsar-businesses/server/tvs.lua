local _started = false
AddEventHandler('Businesses:Server:Startup', function()
    if not _started then
        _started = true
        for k, v in pairs(_tvData) do
            if v?.default then
                GlobalState[string.format('TVsLink:%s', k)] = v.default
            end
        end

        local results = MySQL.query.await("SELECT * FROM business_tvs")

        if results and #results > 0 then
            for k, v in pairs(results) do
                if v.tv and _tvData[v.tv] then
                    GlobalState[string.format('TVsLink:%s', v.tv)] = v.link
                end
            end
        end
    end

    exports["pulsar-core"]:RegisterServerCallback('TVs:UpdateTVLink', function(source, data, cb)
        if data.tv and data.link then
            local tv = _tvData[data.tv]
            if tv then
                local res = SetBusinessTVLink(data.tv, data.link)
                if res then
                    GlobalState[string.format('TVsLink:%s', data.tv)] = data.link
                    TriggerClientEvent('TVs:Client:Update', -1, data.tv)
                end

                cb(res)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

function SetBusinessTVLink(tvId, link)
    local result = MySQL.update.await([[
          UPDATE business_tvs
          SET link = ?
          WHERE tv = ?
      ]], { link, tvId })

    if result.affectedRows == 0 then
        MySQL.insert.await([[
              INSERT INTO business_tvs (tv, link)
              VALUES (?, ?)
          ]], { tvId, link })
    end

    return link
end
