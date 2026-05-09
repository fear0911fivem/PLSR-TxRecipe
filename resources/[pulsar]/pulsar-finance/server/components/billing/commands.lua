AddEventHandler('Finance:Server:Startup', function()
    exports["pulsar-chat"]:RegisterCommand('fine', function(src, args, raw)
        local player = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
        if player ~= nil then
            local targetSource, fineAmount = table.unpack(args)
            local fine = tonumber(fineAmount)
            if fine and fine > 0 and fine <= 100000 then
                local success = exports['pulsar-finance']:BillingFine(src, player:GetData("Source"), fine)
                if success then
                    exports["pulsar-chat"]:SendSystemSingle(src,
                        string.format("You Successfully Fined State ID %s For $%s. You earned $%s.", args[1],
                            success.amount, success.cut))
                else
                    exports["pulsar-chat"]:SendSystemSingle(src, "Fine Failed")
                end
            else
                exports["pulsar-chat"]:SendSystemSingle(src, "Fine Amount Too High!")
            end
        else
            exports["pulsar-chat"]:SendSystemSingle(src, "Invalid Target")
        end
    end, {
        help = '[Government] Fine Someone',
        params = {
            { name = 'State ID', help = 'The State ID of the person you want to fine.' },
            { name = 'Amount',   help = 'The amount of money you are fining them.' },
        },
    }, 2, {
        { Id = 'police' },
    })

    exports["pulsar-chat"]:RegisterAdminCommand('testbilling', function(source, args, rawCommand)
        exports['pulsar-hud']:Notification(source, "info", 'Bill Created')
        exports['pulsar-finance']:BillingCreate(source, 'Some Random Business', 1500,
            'This is a description of a test bill.',
            function(wasPayed)
                if wasPayed then
                    exports['pulsar-hud']:Notification(src, "success", 'Bill Accepted')
                else
                    exports['pulsar-hud']:Notification(src, "error", 'Bill Declined')
                end
            end)
    end, {
        help = 'Test Billing'
    }, 0)
end)
