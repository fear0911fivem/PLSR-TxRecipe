function RegisterCallbacks()
    exports["pulsar-core"]:RegisterServerCallback('Status:Get', function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char ~= nil then
            local s = char:GetData('Status')
            cb(s)
        else
            cb({})
        end
    end)
end
