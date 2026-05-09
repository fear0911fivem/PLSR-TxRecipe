local function GetPlayer()
    return exports["pulsar-core"]:GetLocalPlayer()
end

local function GetCharacter()
    return exports["pulsar-core"]:GetPlayerData('Character')
end

exports('FetchPlayer', GetPlayer)
exports('FetchCharacter', GetCharacter)
