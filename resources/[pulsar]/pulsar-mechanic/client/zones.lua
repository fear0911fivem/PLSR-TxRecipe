function CreateMechanicZones()
    for k, v in ipairs(_mechanicShops) do
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

function GetMechanicZoneAtCoords(coords)
    local insideZone = exports['pulsar-polyzone']:IsCoordsInZone(coords, false, 'mechanic_zone')
    if insideZone and insideZone.mechanic_zone and insideZone.mechanic_zone_job then
        return true, insideZone.mechanic_zone_job
    end
    return false
end
