function GetCharacterCreditScore(stateId)
    local p = promise.new()
    exports.oxmysql:execute('SELECT Score FROM loans_credit_scores WHERE SID = ?', { stateId }, function(results)
        if results and #results > 0 then
            p:resolve(results[1].Score)
        else
            p:resolve(_creditScoreConfig.default)
        end
    end)

    local res = Citizen.Await(p)
    return res
end

function SetCharacterCreditScore(stateId, score)
    local p = promise.new()

    if score > _creditScoreConfig.max then
        score = _creditScoreConfig.max
    end

    if score < _creditScoreConfig.min then
        score = _creditScoreConfig.min
    end

    exports.oxmysql:execute(
        'INSERT INTO loans_credit_scores (SID, Score) VALUES (?, ?) ON DUPLICATE KEY UPDATE Score = ?',
        { stateId, score, score },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                p:resolve(score)
            else
                p:resolve(false)
            end
        end)

    local res = Citizen.Await(p)
    return res
end

function IncreaseCharacterCreditScore(stateId, amount)
    local creditScore = GetCharacterCreditScore(stateId)
    return SetCharacterCreditScore(stateId, math.min(_creditScoreConfig.max, creditScore + amount))
end

function DecreaseCharacterCreditScore(stateId, amount)
    local creditScore = GetCharacterCreditScore(stateId)
    return SetCharacterCreditScore(stateId, math.max(_creditScoreConfig.min, creditScore - amount))
end
