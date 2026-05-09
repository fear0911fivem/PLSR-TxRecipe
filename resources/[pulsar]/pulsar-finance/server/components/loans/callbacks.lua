function GetCharactersLoans(stateId)
    local p = promise.new()

    exports.oxmysql:execute('SELECT * FROM loans WHERE SID = ?', { stateId }, function(results)
        if results and #results > 0 then
            for k, v in ipairs(results) do
                if v.paymentHistory then
                    v.paymentHistory = json.decode(v.paymentHistory)
                end
                if v.terms then
                    v.terms = json.decode(v.terms)
                end
            end
            p:resolve(results)
        else
            p:resolve({})
        end
    end)

    local res = Citizen.Await(p)
    return res
end

function RegisterLoanCallbacks()
    exports["pulsar-core"]:RegisterServerCallback('Loans:GetLoans', function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char then
            local SID = char:GetData('SID')
            local loans = GetCharactersLoans(SID)
            cb({
                loans = loans,
                creditScore = GetCharacterCreditScore(SID)
            })
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Loans:Payment', function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if char and data and data.loan then
            local SID = char:GetData('SID')
            local res = exports['pulsar-finance']:LoansMakePayment(source, data.loan, data.paymentAhead, data.weeks)
            if res and res.success then
                cb(res, {
                    loans = GetCharactersLoans(SID),
                    creditScore = GetCharacterCreditScore(SID),
                })
            else
                cb(res)
            end
        else
            cb(false)
        end
    end)
end
