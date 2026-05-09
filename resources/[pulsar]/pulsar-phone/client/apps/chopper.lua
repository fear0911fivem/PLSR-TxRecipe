RegisterNUICallback("GetChopperDetails", function(data, cb)
    exports["pulsar-core"]:ServerCallback("Laptop:LSUnderground:GetDetails", {
        phone = true
    }, function(data)
        cb(data)
    end)
end)
