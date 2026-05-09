local badgeCooldowns = {}

AddEventHandler("MDT:Server:RegisterCallbacks", function()
    RegisterItems()
    exports["pulsar-core"]:RegisterServerCallback("MDT:PrintBadge", function(source, data, cb)
        local now = GetGameTimer()

        if not badgeCooldowns[source] or (now - badgeCooldowns[source]) > 20000 then
            badgeCooldowns[source] = GetGameTimer()
            local char = exports['pulsar-characters']:FetchCharacterSource(source)
            if char and CheckMDTPermissions(source, { 'PD_HIGH_COMMAND', 'SAFD_HIGH_COMMAND', 'DOJ_JUDGE', 'DOC_HIGH_COMMAND' }) then
                local officer = exports['pulsar-mdt']:PeopleView(data.SID)
                if officer then
                    local departmentName = false
                    local departmentData = false
                    local titleData = false
                    if officer.Jobs then
                        for k, v in ipairs(officer.Jobs) do
                            if v.Id == data.JobId and v.Workplace then
                                departmentData = v.Workplace.Id
                                departmentName = v.Workplace.Name
                                titleData = v.Grade.Name
                            end
                        end
                    end

                    if departmentData then
                        exports.ox_inventory:AddItem(char:GetData('SID'), 'government_badge', 1, {
                            ['Department Name'] = departmentName,
                            Title = titleData,
                            First = officer.First,
                            Last = officer.Last,
                            SID = officer.SID,
                            Callsign = officer.Callsign,
                            Mugshot = officer.Mugshot,
                            Department = departmentData,
                            DOB = officer.DOB,
                        }, 1)
                    else
                        cb(false)
                    end
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

function RegisterItems()
    exports.ox_inventory:RegisterUse("government_badge", "MDT", function(source, itemData)
        if itemData and itemData.MetaData and itemData.MetaData.Department then
            exports["pulsar-core"]:ClientCallback(source, "MDT:Client:CanShowBadge", itemData.MetaData,
                function(canShow)
                    TriggerClientEvent("MDT:Client:ShowBadge", -1, source, itemData.MetaData)
                end)
        end
    end)

    exports.ox_inventory:RegisterUse("govid", "MDT", function(source, itemData)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char and itemData and itemData.MetaData and itemData.MetaData.StateID then
            exports["pulsar-core"]:ClientCallback(source, "MDT:Client:CanShowLicense", itemData.MetaData,
                function(canShow)
                    TriggerClientEvent("MDT:Client:ShowLicense", -1, source, {
                        SID = itemData.MetaData.StateID,
                        Name = itemData.MetaData.Name,
                        Gender = itemData.MetaData.Gender,
                        DOB = itemData.MetaData.DOB,
                        Mugshot = itemData.MetaData.Mugshot,
                    })
                end)
        end
    end)
end

RegisterNetEvent('ox_inventory:ready', function()
    if GetResourceState(GetCurrentResourceName()) == 'started' then
        RegisterItems()
    end
end)
