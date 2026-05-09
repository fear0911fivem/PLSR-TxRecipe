function RegisterEvents()
    CreateThread(function()
        exports["pulsar-core"]:ServerCallback('Pwnzor:GetEvents', {}, function(e)
            for k, v in ipairs(e) do
                AddEventHandler(v, function()
                    exports["pulsar-core"]:ServerCallback('Pwnzor:Trigger', {
                        check = v,
                        match = v,
                    }, function(s)
                        CancelEvent()
                        return
                    end)
                end)
            end
        end)
    end)
end
