--- Creates polyzone and box zones for all mechanic shops defined in Config.Shops
-- Zones carry mechanic_zone and mechanic_zone_job metadata used by GetMechanicZoneAtCoords
---@return nil
function CreateMechanicZones()
    for k = 1, #Config.Shops do
        local v = Config.Shops[k]
        if v.zone then
            local data = {
                mechanic_zone = true,
                mechanic_zone_job = v.job,
            }

            if v.zone.type == 'poly' and v.zone.points then
                exports['pulsar-polyzone']:CreatePoly('mech_zone_' .. k, v.zone.points, v.zone.options, data)
            elseif v.zone.type == 'box' and v.zone.center and v.zone.length and v.zone.width then
                exports['pulsar-polyzone']:CreateBox('mech_zone_' .. k, v.zone.center, v.zone.length, v.zone.width,
                    v.zone.options, data)
            end
        end
    end
end

--- Returns whether the given coords fall inside a mechanic zone and which job owns that zone
---@param coords vector3 World coordinates to test
---@return boolean true if inside a mechanic zone, false otherwise
---@return string|nil job name of the zone, or nil if not inside one
function GetMechanicZoneAtCoords(coords)
    local insideZone = exports['pulsar-polyzone']:IsCoordsInZone(coords, false, 'mechanic_zone')
    if insideZone and insideZone.mechanic_zone and insideZone.mechanic_zone_job then
        return true, insideZone.mechanic_zone_job
    end
    return false
end
