local _hasFetched = false
local defaultSetup = "basketball"

local _MBAeventNames = {
    basketball = true,
    boxing = true,
    concert = true,
    curling = true,
    derby = true,
    fameorshame = true,
    fashion = true,
    football = true,
    icehockey = true,
    gokarta = true,
    gokartb = true,
    trackmaniaa = true,
    trackmaniab = true,
    trackmaniac = true,
    trackmaniad = true,
    mma = true,
    none = true,
    paintball = true,
    rocketleague = true,
    wrestling = true,
}

function SetMBAInterior(interior)
    if not _MBAeventNames[interior] then
        return false
    end

    local p = promise.new()
    exports.oxmysql:execute(
        'INSERT INTO business_configs (`key`, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value = ?',
        { "mba_setup", interior, interior },
        function(affectedRows)
            local success = affectedRows > 0
            if success then
                GlobalState["MBA:Interior"] = interior
                TriggerClientEvent("Businesses:Client:MBA:InteriorUpdate", -1, interior)
            end

            p:resolve(success)
        end)

    local res = Citizen.Await(p)
    return res
end

AddEventHandler("Businesses:Server:Startup", function()
    if not _hasFetched then
        _hasFetched = true

        local p = promise.new()
        exports.oxmysql:execute('SELECT value FROM business_configs WHERE `key` = ?', { "mba_setup" }, function(results)
            if results and #results > 0 and results[1].value then
                p:resolve(results[1].value)
            else
                exports.oxmysql:execute(
                    'INSERT INTO business_configs (`key`, value) VALUES (?, ?)',
                    { "mba_setup", defaultSetup },
                    function(insertId)
                        p:resolve(defaultSetup)
                    end)
            end
        end)

        local d = Citizen.Await(p)

        GlobalState["MBA:Interior"] = d
    end

    exports["pulsar-core"]:RegisterServerCallback("MBA:ChangeInterior", function(source, data, cb)
        if Player(source).state.onDuty == "mba" and data ~= GlobalState["MBA:Interior"] then
            cb(SetMBAInterior(data))
        else
            cb(false)
        end
    end)

    exports["pulsar-chat"]:RegisterStaffCommand("setmazebank", function(source, args, rawCommand)
        local int = args[1]
        if _MBAeventNames[int] then
            if SetMBAInterior(int) then
                exports["pulsar-chat"]:SendSystemSingle(source, "Success")
            else
                exports["pulsar-chat"]:SendSystemSingle(source, "Error")
            end
        else
            exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Interior")
        end
    end, {
        help = "[Staff] Set Maze Bank Arena Interior",
        params = {
            {
                name = "Interior Type",
                help = "basketball, gokarta, etc.",
            },
        },
    }, 1)
end)
