exports("LibraryCreate", function(label, link, job, workplace)
    local inserted = MySQL.insert.await("INSERT INTO mdt_library (label, link, job, workplace) VALUES (?, ?, ?, ?)",
        {
            label,
            link,
            job,
            workplace and workplace or nil,
        })

    return inserted
end)

exports("LibraryDelete", function(id)
    MySQL.query.await("DELETE FROM mdt_library WHERE id = ?", {
        id
    })

    return true
end)

AddEventHandler("MDT:Server:RegisterCallbacks", function()
    exports["pulsar-core"]:RegisterServerCallback("MDT:AddLibraryDocument", function(source, data, cb)
        if CheckMDTPermissions(source, true) then
            cb(exports['pulsar-mdt']:LibraryCreate(data.label, data.link, data.job, data.workplace))
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("MDT:RemoveLibraryDocument", function(source, data, cb)
        if CheckMDTPermissions(source, true) then
            cb(exports['pulsar-mdt']:LibraryDelete(data.id))
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("MDT:GetLibraryDocuments", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char then
            local dutyData = exports['pulsar-jobs']:DutyGet(source)

            if CheckMDTPermissions(source, true) then
                local res = MySQL.query.await("SELECT id, label, link FROM mdt_library ORDER BY label", {})

                cb(res)
            elseif dutyData then
                local res = MySQL.query.await(
                    "SELECT id, label, link FROM mdt_library WHERE (job = ? AND workplace IS NULL) OR (job = ? AND workplace = ?) ORDER BY label",
                    {
                        dutyData.Id,
                        dutyData.Id,
                        dutyData.WorkplaceId,
                    })
                cb(res)
            else
                cb({})
            end
        else
            cb({})
        end
    end)
end)
