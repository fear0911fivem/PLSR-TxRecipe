local function GetPlayerName()
    local playerName = GetPlayerName(PlayerId())
    local identifiers = GetPlayerIdentifiers(PlayerId())
    
    playerName = playerName:gsub("~[^~]~", ""):gsub("~", "")
    
    for _, v in pairs(identifiers) do
        if string.find(v, "steam:") then
            break
        end
    end
    
    return playerName
end

if not nuiHandoverData then nuiHandoverData = {} end
nuiHandoverData.name = GetPlayerName()

print("^2[Loading Screen] ^7Player name set to: ^2" .. nuiHandoverData.name)
