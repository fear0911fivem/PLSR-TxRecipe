local ConfigFormatEnabled = false

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-polyzone')

    exports["pulsar-chat"]:RegisterAdminCommand("pzcreate", function(src, args, raw)
      TriggerClientEvent("polyzone:createcommand", src, args)
    end, {
      help = "Starts creation of a zone for PolyZone",
      params = {
        { name = "zoneType", help = "Zone Type (circle, box, poly)" },
      },
    }, 1)

    exports["pulsar-chat"]:RegisterAdminCommand("pzadd", function(src, args, raw)
      TriggerClientEvent("polyzone:pzadd", src)
    end, {
      help = "Adds point to a zone",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzundo", function(src, args, raw)
      TriggerClientEvent("polyzone:pzundo", src)
    end, {
      help = "Undoes the last point added.",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzfinish", function(src, args, raw)
      TriggerClientEvent("polyzone:pzfinish", src)
    end, {
      help = "Finishes and prints zone.",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzlast", function(src, args, raw)
      TriggerClientEvent("polyzone:pzlast", src)
    end, {
      help = "Starts creation of the last zone you finished (only works on BoxZone and CircleZone)",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzcancel", function(src, args, raw)
      TriggerClientEvent("polyzone:pzcancel", src)
    end, {
      help = "Cancel zone creation.",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzcomboinfo", function(src, args, raw)
      TriggerClientEvent("polyzone:pzcomboinfo", src)
    end, {
      help = "Prints some useful info for all created ComboZones.",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pzdebug", function(src, args, raw)
      TriggerClientEvent("Polyzone:Client:ToggleDebug", src)
    end, {
      help = "Toggle Polyzone Debug mode",
    })
  end
end)

RegisterNetEvent("polyzone:printPoly")
AddEventHandler("polyzone:printPoly", function(zone)
  local src = source
  local player = exports['pulsar-core']:FetchSource(src)
  if not player.Permissions:IsAdmin() then return end

  local created_zones = LoadResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt") or ""
  local output = created_zones .. parsePoly(zone)
  SaveResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt", output, -1)
end)

RegisterNetEvent("polyzone:printCircle")
AddEventHandler("polyzone:printCircle", function(zone)
  local src = source
  local player = exports['pulsar-core']:FetchSource(src)
  if not player.Permissions:IsAdmin() then return end

  local created_zones = LoadResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt") or ""
  local output = created_zones .. parseCircle(zone)
  SaveResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt", output, -1)
end)

RegisterNetEvent("polyzone:printBox")
AddEventHandler("polyzone:printBox", function(zone)
  local src = source
  local player = exports['pulsar-core']:FetchSource(src)
  if not player.Permissions:IsAdmin() then return end

  local created_zones = LoadResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt") or ""
  local output = created_zones .. parseBox(zone)
  SaveResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt", output, -1)
end)

function round(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function printoutHeader(name)
  return "--Name: " .. name .. " | " .. os.date("!%Y-%m-%dT%H:%M:%SZ\n")
end

function parsePoly(zone)
  if ConfigFormatEnabled then
    local printout = printoutHeader(zone.name)
    printout = printout .. "points = {\n"

    for i = 1, #zone.points do
      if i ~= #zone.points then
        printout = printout .. "  vector2(" .. tostring(zone.points[i].x) .. ", " .. tostring(zone.points[i].y) .. "),\n"
      else
        printout = printout .. "  vector2(" .. tostring(zone.points[i].x) .. ", " .. tostring(zone.points[i].y) .. ")\n"
      end
    end

    printout = printout ..
        "},\nname = \"" ..
        zone.name .. "\",\n--minZ = " .. zone.minZ .. ",\n--maxZ = " .. zone.maxZ .. ",\n--debugPoly = true\n\n"

    return printout
  else
    local printout = printoutHeader(zone.name)
    printout = printout .. "PolyZone:Create({\n"
    for i = 1, #zone.points do
      if i ~= #zone.points then
        printout = printout .. "  vector2(" .. tostring(zone.points[i].x) .. ", " .. tostring(zone.points[i].y) .. "),\n"
      else
        printout = printout .. "  vector2(" .. tostring(zone.points[i].x) .. ", " .. tostring(zone.points[i].y) .. ")\n"
      end
    end

    printout = printout ..
        "}, {\n  name = \"" ..
        zone.name .. "\",\n  --minZ = " .. zone.minZ .. ",\n  --maxZ = " .. zone.maxZ .. "\n})\n\n"

    return printout
  end
end

function parseCircle(zone)
  if ConfigFormatEnabled then
    local printout = printoutHeader(zone.name)
    printout = printout .. "coords = "
    printout = printout ..
        "vector3(" ..
        tostring(round(zone.center.x, 2)) ..
        ", " .. tostring(round(zone.center.y, 2)) .. ", " .. tostring(round(zone.center.z, 2)) .. "),\n"
    printout = printout .. "radius = " .. tostring(zone.radius) .. ",\n"
    printout = printout ..
        "name = \"" .. zone.name .. "\",\nuseZ = " .. tostring(zone.useZ) .. ",\n--debugPoly = true\n\n"

    return printout
  else
    local printout = printoutHeader(zone.name)
    printout = printout .. "CircleZone:Create("
    printout = printout ..
        "vector3(" ..
        tostring(round(zone.center.x, 2)) ..
        ", " .. tostring(round(zone.center.y, 2)) .. ", " .. tostring(round(zone.center.z, 2)) .. "), "
    printout = printout .. tostring(zone.radius) .. ", "
    printout = printout ..
        "{\n  name = \"" .. zone.name .. "\",\n  useZ = " .. tostring(zone.useZ) .. ",\n  --debugPoly = true\n})\n\n"

    return printout
  end
end

function parseBox(zone)
  if ConfigFormatEnabled then
    local printout = printoutHeader(zone.name)
    printout = printout .. "coords = "
    printout = printout ..
        "vector3(" ..
        tostring(round(zone.center.x, 2)) ..
        ", " .. tostring(round(zone.center.y, 2)) .. ", " .. tostring(round(zone.center.z, 2)) .. "),\n"
    printout = printout .. "length = " .. tostring(zone.length) .. ",\n"
    printout = printout .. "width = " .. tostring(zone.width) .. ",\n"
    printout = printout .. "name = \"" .. zone.name .. "\",\nheading = " .. zone.heading .. ",\n--debugPoly = true"

    if zone.minZ then
      printout = printout .. ",\nminZ = " .. tostring(round(zone.minZ, 2))
    end

    if zone.maxZ then
      printout = printout .. ",\nmaxZ = " .. tostring(round(zone.maxZ, 2))
    end

    printout = printout .. "\n\n"

    return printout
  else
    local printout = printoutHeader(zone.name)
    printout = printout .. "BoxZone:Create("
    printout = printout ..
        "vector3(" ..
        tostring(round(zone.center.x, 2)) ..
        ", " .. tostring(round(zone.center.y, 2)) .. ", " .. tostring(round(zone.center.z, 2)) .. "), "
    printout = printout .. tostring(zone.length) .. ", "
    printout = printout .. tostring(zone.width) .. ", "
    printout = printout ..
        "{\n  name = \"" .. zone.name .. "\",\n  heading = " .. zone.heading .. ",\n  --debugPoly = true"

    if zone.minZ then
      printout = printout .. ",\n  minZ = " .. tostring(round(zone.minZ, 2))
    end

    if zone.maxZ then
      printout = printout .. ",\n  maxZ = " .. tostring(round(zone.maxZ, 2))
    end

    printout = printout .. "\n})\n\n"

    return printout
  end
end
