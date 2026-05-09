function DoesCharacterPassStorageRestrictions(source, charJobs, restriction)
    if type(restriction) ~= 'table' then
        return true
    end

    local isServer = IsDuplicityVersion()

    for k, v in ipairs(restriction) do
        if v.JobId then
            for _, job in ipairs(charJobs) do
                if v.JobId == job.Id then
                    if v.WorkplaceId then
                        if job.Workplace and job.Workplace.Id == v.WorkplaceId then
                            return true
                        end
                    else
                        return true
                    end
                end
            end
        elseif v.PropertyData and v.PropertyData.key then
            if isServer then
                if exports['pulsar-properties']:HasAccessWithData(source, v.PropertyData.key, v.PropertyData.value) then
                    return true
                end
            else
                if exports['pulsar-properties']:HasAccessWithData(v.PropertyData.key, v.PropertyData.value) then
                    return true
                end
            end
        end
    end
    return false
end

local fleetLevelPrefix = 'FLEET_VEHICLES_'

function GetAllowedFleetVehicleLevelFromJobPermissions(jobPerms)
    local vehLevel = 0

    for k, v in pairs(jobPerms) do
        if string.find(k, fleetLevelPrefix, 1, true) then
            local cleaned = string.gsub(k, fleetLevelPrefix, '')
            local actualLevel = tonumber(cleaned)
            if type(actualLevel) == 'number' and actualLevel > 0 and actualLevel > vehLevel then
                vehLevel = actualLevel
            end
        end
    end

    return vehLevel
end

function DoesVehiclePassFleetRestrictions(vehOwnerData, fleetData)
    for k, v in ipairs(fleetData) do
        if v.JobId == vehOwnerData.Id and (not v.Workplace or not vehOwnerData.Workplace or (v.Workplace == vehOwnerData.Workplace)) then
            return true
        end
    end
    return false
end

local function getPluralForm(type, amount)
    if amount ~= 1 then
        return type .. 's'
    end
    return type
end

function GetFormattedTimeFromSeconds(seconds)
    local days = 0
    local hours = exports['pulsar-core']:UtilsRound(seconds / 3600, 0)
    if hours >= 24 then
        days = math.floor(hours / 24)
        hours = math.ceil(hours - (days * 24))
    end

    local timeString
    if days > 0 or hours > 0 then
        if days > 1 then
            if hours > 0 then
                timeString = string.format('%d %s and %d %s', days, getPluralForm('day', days), hours,
                    getPluralForm('hour', hours))
            else
                timeString = string.format('%d %s', days, getPluralForm('day', days))
            end
        else
            timeString = string.format('%d %s', hours, getPluralForm('hour', hours))
        end
    else
        local minutes = exports['pulsar-core']:UtilsRound(seconds / 60, 0)
        timeString = string.format('%d %s', minutes, getPluralForm('minute', minutes))
    end
    return timeString
end

function hasValue(tbl, value)
    for k, v in ipairs(tbl) do
        if v == value or (type(v) == "table" and hasValue(v, value)) then
            return true
        end
    end
    return false
end
