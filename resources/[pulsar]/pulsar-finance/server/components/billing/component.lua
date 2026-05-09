local pendingBillId = 0
PENDING_BILLS = {}
PENDING_BILLS_CB = {}

function GetBillingId()
    pendingBillId = pendingBillId + 1
    return pendingBillId
end

exports("BillingCreate", function(source, name, amount, description, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
        local stateId = char:GetData('SID')
        local newBillingId = GetBillingId()
        local billData = {
            Type = false,
            Id = newBillingId,
            Name = name,
            Account = false,
            Amount = amount,
            Description = description,
            Biller = false,
            Timestamp = os.time(),
        }

        if not PENDING_BILLS[stateId] then PENDING_BILLS[stateId] = {} end
        table.insert(PENDING_BILLS[stateId], billData)
        SendNewBillNotificationToPhone(source, billData)

        PENDING_BILLS_CB[newBillingId] = cb
        return true
    end
    return false
end)

exports("BillingPlayerCreateOrganizationBill", function(billingSource, stateId, account, amount, description)
    local amount = math.tointeger(amount)
    local targetChar = exports['pulsar-characters']:FetchBySID(tonumber(stateId))
    local billingChar = exports['pulsar-characters']:FetchCharacterSource(billingSource)
    if account and amount and amount > 0 and (billingChar and targetChar) and (targetChar:GetData('SID') ~= billingChar:GetData('SID')) then
        local billerStateId = billingChar:GetData('SID')
        local account = exports['pulsar-finance']:AccountsGet(account)
        if account and account.Type == 'organization' and HasBankAccountPermission(billingSource, account, 'BILL', billerStateId) then
            local targetStateId = targetChar:GetData('SID')
            local newBillingId = GetBillingId()
            local billData = {
                Type = true,
                Id = newBillingId,
                Name = account.Name or account.Account,
                Account = account.Account,
                Amount = amount,
                Description = description,
                Biller = billerStateId,
                Timestamp = os.time(),
            }

            if not PENDING_BILLS[targetStateId] then PENDING_BILLS[targetStateId] = {} end
            table.insert(PENDING_BILLS[targetStateId], billData)
            SendNewBillNotificationToPhone(targetChar:GetData('Source'), billData)

            PENDING_BILLS_CB[newBillingId] = function(wasPayed, withAccount)
                if wasPayed then
                    local success = exports['pulsar-finance']:BalanceDeposit(billData.Account, billData.Amount, {
                        type = 'bill',
                        transactionAccount = withAccount,
                        title = 'Bill Payment',
                        description = string.format(
                            'Bill Payment From State ID: %s With Account: %s. Bill Description: %s', targetStateId,
                            withAccount, billData.Description),
                        data = {
                            biller = billerStateId,
                            character = targetStateId,
                        }
                    })

                    if success then
                        exports['pulsar-phone']:NotificationAdd(billingSource, "Bill Payment Received",
                            string.format("Payment for a bill you sent to State ID: %s was just received.",
                                targetStateId), os.time(), 5000, "bank", {})
                    end
                end
            end
            return true
        end
    end
    return false
end)

exports("BillingDismiss", function(source, billId)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char and billId then
        local stateId = char:GetData('SID')
        local characterBills = PENDING_BILLS[stateId]
        for k, v in ipairs(characterBills) do
            if v.Id == billId then
                if PENDING_BILLS_CB[billId] then
                    PENDING_BILLS_CB[billId](false)
                    PENDING_BILLS_CB[billId] = nil
                end
                PENDING_BILLS[stateId][k] = nil

                return true
            end
        end
    end
    return false
end)

exports("BillingAccept", function(source, billId, withAccount)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char and billId then
        local stateId = char:GetData('SID')
        local characterBills = PENDING_BILLS[stateId]
        for k, v in ipairs(characterBills) do
            if v.Id == billId then
                local account = false
                if withAccount then
                    account = exports['pulsar-finance']:AccountsGet(withAccount)
                else
                    account = exports['pulsar-finance']:AccountsGetPersonal(stateId)
                end
                if PENDING_BILLS_CB[billId] and account and (account.Balance >= v.Amount) and HasBankAccountPermission(source, account, 'WITHDRAW', stateId) then
                    local success = exports['pulsar-finance']:BalanceWithdraw(account.Account, v.Amount, {
                        type = 'bill',
                        transactionAccount = v.Account,
                        title = 'Payment for a Bill',
                        description = string.format('Payment for a Bill From %s. Bill Description: %s', v.Name,
                            v.Description),
                        data = {
                            biller = v.Biller,
                            character = stateId,
                        }
                    })

                    if success then
                        if PENDING_BILLS_CB[billId] then
                            PENDING_BILLS_CB[billId](true, account.Account)
                            PENDING_BILLS_CB[billId] = nil
                        end
                        PENDING_BILLS[stateId][k] = nil
                        return true
                    end
                end
                break
            end
        end
    end
    return false
end)

exports("BillingFine", function(finingSource, targetSource, amount)
    local amount = math.tointeger(amount)
    if amount and amount > 0 then
        local finingChar = exports['pulsar-characters']:FetchCharacterSource(finingSource)
        local targetChar = exports['pulsar-characters']:FetchCharacterSource(targetSource)

        if finingChar and targetChar and finingChar:GetData('SID') ~= targetChar:GetData('SID') then
            local targetCharSID = targetChar:GetData('SID')
            local finingCharSID = finingChar:GetData('SID')

            local targetCharAccount = exports['pulsar-finance']:AccountsGetPersonal(targetCharSID)
            local finingCharAccount = exports['pulsar-finance']:AccountsGetPersonal(finingCharSID)
            local policeJob = exports['pulsar-jobs']:HasJob(finingSource, 'police')

            local policeAccount = exports['pulsar-finance']:AccountsGetOrganization(string.format('police-%s',
                (policeJob and policeJob.Workplace and policeJob.Workplace.Id) or ''))
            if not policeAccount then
                policeAccount = exports['pulsar-finance']:AccountsGetOrganization('police')
            end

            if targetCharAccount and finingCharAccount then
                local finerCut = 0.15 -- THE PERSON THAT IS CREATING THE FINE GETS A CUT OF THE FINE
                local policeCut = 0.25
                local stateCut = 1.0 - finerCut - policeCut

                local finerCutAmount = math.floor(amount * finerCut)
                local policeCutAmount = math.floor(amount * policeCut)
                local stateCutAmount = math.floor(amount * stateCut)

                local success = exports['pulsar-finance']:BalanceWithdraw(targetCharAccount.Account, amount, {
                    type = 'fine',
                    title = 'Fine Payment',
                    description = 'Fine From the State of San Andreas',
                    data = {
                        finer = finingCharSID
                    }
                })

                if success then
                    exports['pulsar-finance']:BalanceDeposit(finingCharAccount.Account, finerCutAmount, {
                        type = 'fine_profit',
                        title = 'Fine Profit',
                        description = string.format('Your Earned %% of Fine Profit', targetCharSID),
                        data = {
                            fined = targetCharSID,
                        }
                    })

                    if policeAccount then
                        exports['pulsar-finance']:BalanceDeposit(policeAccount.Account, policeCutAmount, {
                            type = 'fine_profit',
                            title = 'Fine Profit',
                            description = string.format('Fine Profit (Fine to State ID: %s By State ID: %s)',
                                targetCharSID, finingCharSID),
                            data = {
                                finer = finingCharSID,
                                fined = targetCharSID,
                            }
                        })
                    end

                    exports['pulsar-finance']:BalanceDeposit(100000, stateCutAmount, {
                        type = 'fine_profit',
                        title = 'Fine Profit',
                        description = string.format('Fine Profit (Fine to State ID: %s By State ID: %s)',
                            targetCharSID, finingCharSID),
                        data = {
                            finer = finingCharSID,
                            fined = targetCharSID,
                        }
                    })

                    exports['pulsar-phone']:NotificationAdd(targetSource, "Received Fine",
                        string.format("You received a fine of $%d from the State of San Andreas", amount), os.time(),
                        7500, "bank", {})

                    exports['pulsar-core']:LoggerInfo("Billing",
                        string.format("%s %s (%s) Fined $%s By %s %s (%s).", targetChar:GetData("First"),
                            targetChar:GetData("Last"), targetChar:GetData("SID"), amount,
                            finingChar:GetData("First"), finingChar:GetData("Last"), finingChar:GetData("SID")), {
                            console = true,
                            file = true,
                            database = true,
                            discord = {
                                embed = true,
                                type = 'info',
                                webhook = GetConvar('discord_log_webhook', ''),
                            }
                        })

                    return {
                        amount = amount,
                        cut = finerCutAmount,
                    }
                end
            end
        end
    end
    return false
end)

exports("BillingCharge", function(source, amount, title, description)
    local amount = math.tointeger(amount)
    if amount and amount > 0 then
        local targetChar = exports['pulsar-characters']:FetchCharacterSource(source)
        if targetChar then
            local targetCharSID = targetChar:GetData('SID')
            local targetCharAccount = exports['pulsar-finance']:AccountsGetPersonal(targetCharSID)

            if targetCharAccount then
                local success = exports['pulsar-finance']:BalanceWithdraw(targetCharAccount.Account, amount, {
                    type = 'bill',
                    title = title,
                    description = description,
                    data = {}
                })

                if success then
                    exports['pulsar-phone']:NotificationAdd(source, "New Bank Charge",
                        string.format("Received Charge of $%d - %s", amount, title), os.time(), 7500, "bank", {})

                    return amount
                end
            end
        end
    end
    return false
end)

function SendNewBillNotificationToPhone(source, billData)
    exports['pulsar-phone']:NotificationAdd(source, "Received New Bill",
        string.format("$%d Bill From %s", billData.Amount, billData.Name),
        os.time(), 7500, "bank", {
            accept = "Phone:Nui:Bank:AcceptBill",
            cancel = "Phone:Nui:Bank:DenyBill",
        }, {
            bill = billData.Id
        })
end
