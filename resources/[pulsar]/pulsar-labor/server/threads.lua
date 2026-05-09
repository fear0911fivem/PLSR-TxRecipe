CreateThread(function()
    while true do
        for k, v in pairs(_offers) do
            if _Jobs[v.job].Timeout then
                if v.expires < os.time() and not v.noExpire then
                    exports['pulsar-core']:LoggerInfo(
                        "Labor",
                        string.format("Joiner %s Removed From %s, No Offer update In 10 Minutes", k, v.job)
                    )
                    exports['pulsar-labor']:FailOffer(k, v.job, _Jobs[v.job].Timeout)
                end
            end
        end
        Wait(30000)
    end
end)
