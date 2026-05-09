AddEventHandler('Dealerships:Client:StartRunningCredit', function(hit, data)
    exports['pulsar-hud']:InputShow(
        "Run Credit Check & See Max Borrowable Amount",
        "Customer State ID",
        {
            {
                id = 'SID',
                type = 'number',
                options = {
                    inputProps = {
                        maxLength = 4,
                    },
                }
            },
        },
        "Dealerships:Client:RecieveInput",
        data
    )
end)

AddEventHandler('Dealerships:Client:RecieveInput', function(values, data)
    exports["pulsar-core"]:ServerCallback('Dealerships:CheckPersonsCredit', {
        dealerId = data.dealerId,
        SID = values.SID,
    }, function(canBorrow, score, result)
        if canBorrow then
            exports['pulsar-hud']:ConfirmShow(
                'Credit Check Results',
                {},
                string.format(
                    [[
                        State ID %s is elegible for a vehicle loan of <b>$%s</b> with their current credit score
                        of %s.
                    ]],
                    values.SID,
                    formatNumberToCurrency(math.floor(exports['pulsar-core']:UtilsRound(result, 0))),
                    score
                ),
                {},
                'Close',
                'Ok'
            )
        else
            if score and result then
                exports['pulsar-hud']:ConfirmShow(
                    'Credit Check Results',
                    {},
                    string.format(
                        [[
                            State ID %s is not elegible for a vehicle loan. This is because they already have an active vehicle loan. At this time people can
                            only have a single vehicle loan.
                        ]],
                        values.SID,
                        values.creditScore
                    ),
                    {},
                    'Close',
                    'Ok'
                )
            elseif score and not result then
                exports['pulsar-hud']:ConfirmShow(
                    'Credit Check Results',
                    {},
                    string.format(
                        [[
                            State ID %s is not elegible for a vehicle loan with their current credit score of %s.
                        ]],
                        values.SID,
                        score
                    ),
                    {},
                    'Close',
                    'Ok'
                )
            else
                exports['pulsar-hud']:ConfirmShow(
                    'Credit Check Results',
                    {},
                    [[
                        An error occured whilst running credit.
                    ]],
                    {},
                    'Close',
                    'Ok'
                )
            end
        end
    end)
end)
