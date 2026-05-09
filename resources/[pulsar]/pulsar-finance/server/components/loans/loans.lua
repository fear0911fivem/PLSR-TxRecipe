local _ranStartup = false

function RunLoanStartup()
    if _ranStartup then return end
    _ranStartup = true

    exports.oxmysql:execute('SELECT COUNT(*) as count FROM loans WHERE Remaining > 0', {}, function(results)
        if results and #results > 0 then
            local count = results[1].count
            exports['pulsar-core']:LoggerTrace('Loans', 'Loaded ^2' .. count .. '^7 Active Loans')
        end
    end)
end

AddEventHandler('Finance:Server:Startup', function()
    RunLoanStartup()
    RegisterLoanCallbacks()

    CreateLoanTasks()
end)

function CreateLoanTasks()
    exports['pulsar-core']:TasksRegister('loan_payment', 60, function()
        --RegisterCommand('testloans', function()
        local TASK_RUN_TIMESTAMP = os.time()

        exports.oxmysql:execute(
            'SELECT * FROM loans WHERE NextPayment > 0 AND NextPayment <= ? AND Defaulted = 0 AND Remaining >= 0',
            { TASK_RUN_TIMESTAMP },
            function(results)
                if results and #results > 0 then
                    for k, v in ipairs(results) do
                        local newInterestRate = v.InterestRate + _loanConfig.missedPayments.interestIncrease
                        local newMissedPayments = v.MissedPayments + 1
                        local newTotalMissedPayments = v.TotalMissedPayments + 1
                        local newNextPayment = v.NextPayment + _loanConfig.paymentInterval
                        local additionalCharge = v.Total * (_loanConfig.missedPayments.charge / 100)
                        local newRemaining = v.Remaining + additionalCharge

                        exports.oxmysql:execute(
                            'UPDATE loans SET InterestRate = ?, LastMissedPayment = ?, MissedPayments = ?, TotalMissedPayments = ?, NextPayment = ?, Remaining = ? WHERE id = ?',
                            { newInterestRate, TASK_RUN_TIMESTAMP, newMissedPayments, newTotalMissedPayments,
                                newNextPayment, newRemaining, v.id },
                            function(affectedRows)
                            end)
                    end
                end

                local success = results ~= nil
                if success then
                    exports.oxmysql:execute(
                        'SELECT * FROM loans WHERE MissedPayments >= MissablePayments AND Defaulted = 0', {},
                        function(results)
                            if results and #results > 0 then
                                local updatingAssets = {}

                                for k, v in ipairs(results) do
                                    table.insert(updatingAssets, v.AssetIdentifier)
                                end

                                if #updatingAssets > 0 then
                                    local placeholders = string.rep('?,', #updatingAssets - 1) .. '?'
                                    exports.oxmysql:execute(
                                        'UPDATE loans SET Defaulted = 1 WHERE AssetIdentifier IN (' ..
                                        placeholders .. ')',
                                        updatingAssets,
                                        function(affectedRows)
                                            if affectedRows and affectedRows > 0 then
                                                exports['pulsar-core']:LoggerInfo('Loans',
                                                    '^2' .. #results .. '^7 Loans Have Just Been Defaulted')
                                                for k, v in ipairs(results) do
                                                    if v.SID then
                                                        DecreaseCharacterCreditScore(v.SID,
                                                            _creditScoreConfig.removal.defaultedLoan)
                                                        local onlineChar = exports['pulsar-characters']:FetchBySID(v
                                                            .SID)
                                                        if onlineChar then
                                                            SendDefaultedLoanNotification(onlineChar:GetData('Source'), v)
                                                        end
                                                    end

                                                    if v.AssetIdentifier then
                                                        if v.Type == 'vehicle' then
                                                            exports['pulsar-vehicles']:OwnedSeize(v.AssetIdentifier,
                                                                true)
                                                        elseif v.Type == 'property' then
                                                            exports['pulsar-properties']:Foreclose(v.AssetIdentifier,
                                                                true)
                                                        end
                                                    end
                                                end
                                            end
                                        end)
                                end
                            end
                        end)

                    exports.oxmysql:execute(
                        'SELECT * FROM loans WHERE MissedPayments < MissablePayments AND Defaulted = 0 AND LastMissedPayment = ?',
                        { TASK_RUN_TIMESTAMP }, function(results)
                            if results and #results > 0 then
                                exports['pulsar-core']:LoggerInfo('Loans',
                                    '^2' .. #results .. '^7 Loan Payments Were Just Missed')
                                for k, v in ipairs(results) do
                                    if v.SID then
                                        DecreaseCharacterCreditScore(v.SID, _creditScoreConfig.removal.missedLoanPayment)

                                        local onlineChar = exports['pulsar-characters']:FetchBySID(v.SID)
                                        if onlineChar then
                                            SendMissedLoanNotification(onlineChar:GetData('Source'), v)
                                        end
                                    end
                                end
                            end
                        end)
                end
            end)
    end)

    exports['pulsar-core']:TasksRegister('loan_reminder', 120, function()
        local TASK_RUN_TIMESTAMP = os.time()
        -- Get All Loans That are Due Soon
        local sixHoursFromNow = TASK_RUN_TIMESTAMP + (60 * 60 * 6)
        exports.oxmysql:execute(
            'SELECT * FROM loans WHERE Remaining > 0 AND Defaulted = 0 AND ((NextPayment > 0 AND NextPayment <= ?) OR MissedPayments > 0)',
            { sixHoursFromNow },
            function(results)
                if results and #results > 0 then
                    for k, v in ipairs(results) do
                        if v.SID then
                            local onlineChar = exports['pulsar-characters']:FetchBySID(v.SID)
                            if onlineChar then
                                exports['pulsar-phone']:NotificationAdd(onlineChar:GetData("Source"),
                                    "Loan Payment Due",
                                    "You have a loan payment that is due very soon.", os.time(), 7500, "loans", {})
                            end

                            Wait(100)
                        end
                    end
                end
            end)
    end)
end

function SendMissedLoanNotification(source, loanData)
    exports['pulsar-phone']:NotificationAdd(source, "Loan Payment Missed",
        "You just missed a loan payment on one of your loans.",
        os.time(), 7500, "loans", {})
end

function SendDefaultedLoanNotification(source, loanData)
    exports['pulsar-phone']:NotificationAdd(source, "Loan Defaulted",
        "One of your loans just got defaulted and the assets are going to be seized.", os.time(), 7500, "loans", {})
end

local typeNames = {
    vehicle = 'Vehicle Loan',
    property = 'Property Loan',
}

function GetLoanTypeName(type)
    return typeNames[type]
end
