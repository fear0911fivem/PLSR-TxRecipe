AddEventHandler("Laptop:Server:RegisterCallbacks", function()
    exports["pulsar-core"]:RegisterServerCallback("Laptop:Settings:Update", function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char then
            local settings = char:GetData("LaptopSettings")
            settings[data.type] = data.val
            char:SetData("LaptopSettings", settings)
        end
    end)
end)
