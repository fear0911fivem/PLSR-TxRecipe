AddEventHandler('Finance:Server:Startup', function()
    exports["pulsar-core"]:RegisterServerCallback('Billing:DismissBill', function(source, data, cb)
        if data and data.bill then
            local success = exports['pulsar-finance']:BillingDismiss(source, data.bill)
            cb(success)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Billing:AcceptBill', function(source, data, cb)
        if data and data.bill then
            local success = exports['pulsar-finance']:BillingAccept(source, data.bill, data.account)
            cb(success)
            if data.notify then
                if success then
                    exports['pulsar-phone']:NotificationAdd(source, "Bill Payment Successful", false, os.time(),
                        3000, "bank", {})
                else
                    exports['pulsar-phone']:NotificationAdd(source, "Bill Payment Failed", false, os.time(), 3000,
                        "bank", {})
                end
            end
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Billing:CreateBill', function(source, data, cb)
        if data and data.fromAccount and data.target and data.description and data.amount then
            local creationSuccess = exports['pulsar-finance']:BillingPlayerCreateOrganizationBill(source, data.target,
                data.fromAccount,
                data.amount, data.description)
            cb(creationSuccess)
        end
    end)
end)
