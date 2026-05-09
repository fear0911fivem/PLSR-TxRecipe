RegisterServerEvent('Characters:Server:Spawning', function()
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
        local cData = char:GetData()
        exports['pulsar-core']:MiddlewareTriggerEvent("Characters:Spawning", source, cData)
    else
        exports['pulsar-core']:MiddlewareTriggerEvent("Characters:Spawning", source)
    end
end)

RegisterServerEvent('Ped:LeaveCreator', function()
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
        if char:GetData("New") then
            char:SetData("New", false)
        end
    end
end)
