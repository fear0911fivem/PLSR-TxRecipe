local _activeTestDrives = {}
local maxActive = 10
local _hasStartedCountdown = false

RegisterNetEvent('Dealerships:Server:StartSale', function(dealership, type, data)

end)

RegisterNetEvent('Vehicles:Server:TestDriveTime', function(vNet)
    local _src = source
    local vehicle = NetworkGetEntityFromNetworkId(vNet)
    if vehicle and DoesEntityExist(vehicle) and Entity(vehicle).state.testDrive then
        local dealership = Entity(vehicle).state.testDriveDealership
        local timeRemaining = Entity(vehicle).state.testDrive - os.time()

        if _activeTestDrives[dealership] and not _activeTestDrives[dealership].startedTimer then
            _activeTestDrives[dealership].startedTimer = true

            if timeRemaining > 0 then
                exports['pulsar-hud']:Notification("info", _src, "Test Drive Time Remaining", timeRemaining * 1000,
                    "car")

                SetTimeout(timeRemaining * 1000, function()
                    EndTestDrive(vehicle, dealership, _src)
                end)
            else
                EndTestDrive(vehicle, dealership, _src)
            end
        end
    end
end)

function EndTestDrive(vehicle, dealership, _src)
    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        exports['pulsar-vehicles']:Delete(vehicle, function(success) end)
    else
        exports['pulsar-hud']:Notification("error", _src, "Cannot find vehicle to return. Test drive cancelled.", 3000,
            "car")
    end

    if _dealerships[dealership].testdrive.setplayerback then
        SetEntityCoords(
            GetPlayerPed(_src),
            _dealerships[dealership].testdrive.coords.x,
            _dealerships[dealership].testdrive.coords.y,
            _dealerships[dealership].testdrive.coords.z,
            0,
            0,
            0,
            false
        )
    end

    _activeTestDrives[dealership] = nil
end

function RegisterVehicleSaleCallbacks()
    exports["pulsar-core"]:RegisterServerCallback('Dealerships:Sales:TestDrive', function(source, testDriveData, cb)
        local dealership = testDriveData?.dealership
        local data = testDriveData?.data
        if dealership and data then
            local spawn = _dealerships[dealership].testdrive.coords
            local timer = _dealerships[dealership].testdrive.timer
            local model = data.vehicle

            -- In Case of Deletion
            if _activeTestDrives[dealership] and not DoesEntityExist(_activeTestDrives[dealership].veh) then
                _activeTestDrives[dealership] = nil
            end

            if _activeTestDrives[dealership] == nil then
                exports['pulsar-vehicles']:SpawnTemp(
                    source,
                    GetHashKey(model),
                    data.modelType,
                    vector3(spawn.x, spawn.y, spawn.z),
                    spawn.w,
                    function(spawnedVehicle, VIN, plate)
                        if spawnedVehicle then
                            exports['pulsar-vehicles']:KeysAdd(source, VIN)

                            _activeTestDrives[dealership] = {
                                veh = spawnedVehicle,
                                net = NetworkGetNetworkIdFromEntity(spawnedVehicle),
                                VIN = VIN,
                                plate = plate,
                                startedTimer = false,
                            }

                            exports['pulsar-hud']:Notification(source, "success",
                                "Your Test Drive Vehicle Was Provided",
                                5000, "car")
                            Entity(spawnedVehicle).state.testDrive = os.time() + timer
                            Entity(spawnedVehicle).state.testDriveDealership = dealership
                        else
                            exports['pulsar-hud']:Notification(source, "error",
                                "Test Drive Vehicle Failed To Spawn", 5000,
                                "car")
                        end
                    end,
                    {
                        Make = "Test Drive",
                        Model = model,
                        Value = 999999,
                    }
                )
            else
                exports['pulsar-hud']:Notification(source, "error",
                    "We Already Gave You a Test Drive Vehicle", 5000, "car")
            end
            cb(true, 'Initiating Test Drive')
        else
            cb(false, 'Error Initiating Test Drive')
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback('Dealerships:Sales:StartSale', function(source, saleData, cb)
        local dealership = saleData?.dealership
        local type = saleData?.type
        local data = saleData?.data

        if dealership and type and data then
            local dealerData = _dealerships[dealership]
            local customerStateId, vehicle = math.tointeger(data.customer), data.vehicle
            local char = exports['pulsar-characters']:FetchCharacterSource(source)
            if char and dealerData and customerStateId and vehicle and exports['pulsar-jobs']:HasPermissionInJob(source, dealerData.id, 'dealership_sell') then
                local targetCharacter = exports['pulsar-characters']:FetchBySID(customerStateId)
                if targetCharacter then
                    local playerCoords = GetEntityCoords(GetPlayerPed(source))
                    local targetCoords = GetEntityCoords(GetPlayerPed(targetCharacter:GetData('Source')))
                    if #(playerCoords - targetCoords) <= 15.0 then
                        local targetSrc = targetCharacter:GetData('Source')

                        local profitPercent = exports['pulsar-dealerships']:ManagementGetData(dealership,
                            'profitPercentage')
                        local commissionPercent = exports['pulsar-dealerships']:ManagementGetData(dealership,
                            'commission')

                        local saleVehicleData = exports['pulsar-dealerships']:StockFetchDealerVehicle(dealerData.id,
                            vehicle)
                        if profitPercent and commissionPercent and saleVehicleData and saleVehicleData.quantity > 0 and saleVehicleData.data.price and saleVehicleData.data.price > 0 then
                            local vehiclePrice = saleVehicleData.data.price
                            local priceMultiplier = 1 + (profitPercent / 100)
                            local commissionMultiplier = (commissionPercent / 100)
                            local salePrice = exports['pulsar-core']:UtilsRound(vehiclePrice * priceMultiplier, 0)

                            local playerCommission = exports['pulsar-core']:UtilsRound(
                                (salePrice - vehiclePrice) * commissionMultiplier, 0)
                            local dealerRecieves = exports['pulsar-core']:UtilsRound(salePrice - playerCommission, 0)


                            if type == 'full' then
                                exports['pulsar-finance']:BillingCreate(targetSrc, dealerData.abbreviation .. ' - Sales',
                                    salePrice, '',
                                    function(wasPayed, withAccount)
                                        if wasPayed then
                                            local removeSuccess = exports['pulsar-dealerships']:StockRemove(
                                                dealerData.id,
                                                saleVehicleData.vehicle, 1)
                                            if removeSuccess then
                                                exports['pulsar-vehicles']:OwnedAddToCharacter(
                                                    targetCharacter:GetData('SID'),
                                                    GetHashKey(saleVehicleData.vehicle), 0, saleVehicleData.modelType, {
                                                        make = saleVehicleData.data.make,
                                                        model = saleVehicleData.data.model,
                                                        class = saleVehicleData.data.class,
                                                        value = salePrice,
                                                    }, function(success, vehicleData)
                                                        if success and vehicleData then
                                                            exports['pulsar-dealerships']:RecordsCreate(dealerData.id, {
                                                                time = os.time(),
                                                                type = type,
                                                                vehicle = {
                                                                    VIN = vehicleData.VIN,
                                                                    vehicle = saleVehicleData.vehicle,
                                                                    data = saleVehicleData.data,
                                                                },
                                                                profitPercent = profitPercent,
                                                                salePrice = salePrice,
                                                                dealerProfits = dealerRecieves,
                                                                commission = playerCommission,
                                                                seller = {
                                                                    ID = char:GetData('ID'),
                                                                    SID = char:GetData('SID'),
                                                                    First = char:GetData('First'),
                                                                    Last = char:GetData('Last'),
                                                                },
                                                                buyer = {
                                                                    ID = targetCharacter:GetData('ID'),
                                                                    SID = targetCharacter:GetData('SID'),
                                                                    First = targetCharacter:GetData('First'),
                                                                    Last = targetCharacter:GetData('Last'),
                                                                },
                                                                newQuantity = removeSuccess,
                                                            })

                                                            exports['pulsar-hud']:Notification(source, "success",
                                                                'Completed Sales Process - The Customer Received their Vehicle',
                                                                7500, 'car-building')
                                                            SendCompletedCashSaleEmail({
                                                                    SID = targetCharacter:GetData('SID'),
                                                                    First = targetCharacter:GetData('First'),
                                                                    Last = targetCharacter:GetData('Last'),
                                                                    Source = targetSrc,
                                                                }, dealerData, saleVehicleData.data, salePrice,
                                                                vehicleData.VIN,
                                                                vehicleData.RegisteredPlate)

                                                            SendDealerProfits(dealerData, dealerRecieves,
                                                                char:GetData('BankAccount'), playerCommission,
                                                                saleVehicleData.data, {
                                                                    SID = targetCharacter:GetData('SID'),
                                                                    First = targetCharacter:GetData('First'),
                                                                    Last = targetCharacter:GetData('Last'),
                                                                    Source = targetSrc,
                                                                })

                                                            -- Disable credit increase if purchased in fule
                                                            -- if salePrice >= 50000 then
                                                            --     local creditIncrease = math.floor(salePrice / 2000)
                                                            --     if creditIncrease > 25 then
                                                            --         creditIncrease = 25
                                                            --     end

                                                            --     exports['pulsar-finance']:LoansCreditIncrease(targetCharacter:GetData('SID'), creditIncrease)
                                                            -- end
                                                        else
                                                            exports['pulsar-hud']:Notification(source, "error",
                                                                'Error Completing Vehicle Sale', 5000, 'car-building')
                                                            exports['pulsar-hud']:Notification("error", targetSrc,
                                                                'Error Completing Vehicle Sale', 5000, 'car-building')
                                                        end
                                                    end, false, dealerData.storage)
                                            else
                                                exports['pulsar-hud']:Notification(source, "error",
                                                    'Error Completing Vehicle Sale', 5000, 'car-building')
                                                exports['pulsar-hud']:Notification("error", targetSrc,
                                                    'Error Completing Vehicle Sale', 5000, 'car-building')
                                            end
                                        else
                                            exports['pulsar-hud']:Notification(source, "error",
                                                'Payment Failed', 5000,
                                                'car-building')
                                        end
                                    end)

                                cb(true, 'Initiating Sales Process')
                            elseif type == 'loan' then
                                local loanData = exports['pulsar-finance']:LoansGetAllowedLoanAmount(targetCharacter
                                    :GetData('SID'))
                                local hasLoans = exports['pulsar-finance']:LoansGetPlayerLoans(
                                    targetCharacter:GetData('SID'), 'vehicle')

                                if loanData and #hasLoans < loanData.limit then
                                    if loanData and loanData.maxBorrowable and loanData.maxBorrowable > 0 then
                                        local defaultInterestRate = exports['pulsar-finance']
                                            :LoansGetDefaultInterestRate()
                                        local downPaymentPercent, loanWeeks = math.tointeger(data.downPayment),
                                            math.tointeger(data.loanWeeks)

                                        if downPaymentPercent and loanWeeks and defaultInterestRate then
                                            local downPayment = exports['pulsar-core']:UtilsRound(
                                                salePrice * (downPaymentPercent / 100), 0)
                                            local salePriceAfterDown = salePrice - downPayment
                                            local afterInterest = exports['pulsar-core']:UtilsRound(
                                                salePriceAfterDown * (1 + (defaultInterestRate / 100)), 0)

                                            local perWeek = exports['pulsar-core']:UtilsRound(afterInterest / loanWeeks,
                                                0)

                                            if loanData.maxBorrowable >= salePriceAfterDown then
                                                SendPendingLoanEmail({
                                                        SID = targetCharacter:GetData('SID'),
                                                        First = targetCharacter:GetData('First'),
                                                        Last = targetCharacter:GetData('Last'),
                                                        Source = targetSrc,
                                                    }, dealerData, saleVehicleData.data, downPaymentPercent, downPayment,
                                                    loanWeeks, perWeek, afterInterest, function()
                                                        exports['pulsar-hud']:Notification(source, "info",
                                                            'The Loan Terms Were Accepted by the Customer', 5000,
                                                            'car-building')
                                                        exports['pulsar-finance']:BillingCreate(
                                                            targetSrc,
                                                            dealerData.name,
                                                            downPayment,
                                                            string.format('Vehicle Loan Downpayment, %s %s',
                                                                saleVehicleData.data.make, saleVehicleData.data.model),
                                                            function(wasPayed, withAccount)
                                                                if wasPayed then
                                                                    local preGenerateVIN = exports['pulsar-vehicles']
                                                                        :VINGenerateOwned()

                                                                    local loanSuccess = exports['pulsar-finance']
                                                                        :LoansCreateVehicleLoan(
                                                                            targetSrc,
                                                                            preGenerateVIN, salePrice, downPayment,
                                                                            loanWeeks)
                                                                    if loanSuccess then
                                                                        local removeSuccess = exports
                                                                            ['pulsar-dealerships']:StockRemove(
                                                                                dealerData.id, saleVehicleData.vehicle, 1)
                                                                        if removeSuccess then
                                                                            exports['pulsar-vehicles']
                                                                                :OwnedAddToCharacter(
                                                                                    targetCharacter:GetData('SID'),
                                                                                    GetHashKey(saleVehicleData.vehicle),
                                                                                    0,
                                                                                    saleVehicleData.modelType, {
                                                                                        make = saleVehicleData.data.make,
                                                                                        model = saleVehicleData.data
                                                                                            .model,
                                                                                        class = saleVehicleData.data
                                                                                            .class,
                                                                                        value = saleVehicleData.data
                                                                                            .price
                                                                                    }, function(success, vehicleData)
                                                                                        if success and vehicleData then
                                                                                            exports['pulsar-dealerships']
                                                                                                :RecordsCreate(
                                                                                                    dealerData.id,
                                                                                                    {
                                                                                                        time = os.time(),
                                                                                                        type = type,
                                                                                                        loan = {
                                                                                                            length =
                                                                                                                loanWeeks,
                                                                                                            downPayment =
                                                                                                                downPayment,
                                                                                                        },
                                                                                                        vehicle = {
                                                                                                            VIN =
                                                                                                                vehicleData
                                                                                                                .VIN,
                                                                                                            vehicle =
                                                                                                                saleVehicleData
                                                                                                                .vehicle,
                                                                                                            data =
                                                                                                                saleVehicleData.data,
                                                                                                        },
                                                                                                        profitPercent =
                                                                                                            profitPercent,
                                                                                                        salePrice =
                                                                                                            salePrice,
                                                                                                        dealerProfits =
                                                                                                            dealerRecieves,
                                                                                                        commission =
                                                                                                            playerCommission,
                                                                                                        seller = {
                                                                                                            ID = char
                                                                                                                :GetData(
                                                                                                                    'ID'),
                                                                                                            SID = char
                                                                                                                :GetData(
                                                                                                                    'SID'),
                                                                                                            First = char
                                                                                                                :GetData(
                                                                                                                    'First'),
                                                                                                            Last = char
                                                                                                                :GetData(
                                                                                                                    'Last'),
                                                                                                        },
                                                                                                        buyer = {
                                                                                                            ID =
                                                                                                                targetCharacter
                                                                                                                :GetData(
                                                                                                                    'ID'),
                                                                                                            SID =
                                                                                                                targetCharacter
                                                                                                                :GetData(
                                                                                                                    'SID'),
                                                                                                            First =
                                                                                                                targetCharacter
                                                                                                                :GetData(
                                                                                                                    'First'),
                                                                                                            Last =
                                                                                                                targetCharacter
                                                                                                                :GetData(
                                                                                                                    'Last'),
                                                                                                        },
                                                                                                        newQuantity =
                                                                                                            removeSuccess,
                                                                                                    })

                                                                                            exports['pulsar-core']
                                                                                                :Notification(source,
                                                                                                    "success",
                                                                                                    'Completed Sales Process - The Customer Received their Vehicle',
                                                                                                    7500, 'car-building')
                                                                                            SendCompletedLoanSaleEmail({
                                                                                                    SID = targetCharacter
                                                                                                        :GetData('SID'),
                                                                                                    First =
                                                                                                        targetCharacter
                                                                                                        :GetData(
                                                                                                            'First'),
                                                                                                    Last =
                                                                                                        targetCharacter
                                                                                                        :GetData(
                                                                                                            'Last'),
                                                                                                    Source = targetSrc,
                                                                                                }, dealerData,
                                                                                                saleVehicleData.data,
                                                                                                downPaymentPercent,
                                                                                                downPayment,
                                                                                                loanWeeks, perWeek,
                                                                                                afterInterest,
                                                                                                vehicleData.VIN,
                                                                                                vehicleData.RegisteredPlate)

                                                                                            SendDealerProfits(dealerData,
                                                                                                dealerRecieves,
                                                                                                char:GetData(
                                                                                                    'BankAccount'),
                                                                                                playerCommission,
                                                                                                saleVehicleData.data, {
                                                                                                    SID = targetCharacter
                                                                                                        :GetData('SID'),
                                                                                                    First =
                                                                                                        targetCharacter
                                                                                                        :GetData(
                                                                                                            'First'),
                                                                                                    Last =
                                                                                                        targetCharacter
                                                                                                        :GetData(
                                                                                                            'Last'),
                                                                                                    Source = targetSrc,
                                                                                                })
                                                                                        else
                                                                                            exports['pulsar-core']
                                                                                                :Notification(source,
                                                                                                    "error",
                                                                                                    'Error Completing Vehicle Sale',
                                                                                                    5000,
                                                                                                    'car-building')
                                                                                            exports['pulsar-core']
                                                                                                :Notification("error",
                                                                                                    targetSrc,
                                                                                                    'Error Completing Vehicle Sale',
                                                                                                    5000,
                                                                                                    'car-building')
                                                                                        end
                                                                                    end, false, dealerData.storage,
                                                                                    preGenerateVIN)
                                                                        else
                                                                            -- Removal of Car from Stock Failed
                                                                            exports['pulsar-core']:LoggerError(
                                                                                'Dealerships',
                                                                                string.format(
                                                                                    'Vehicle Purchase Failed (Removal of Car from Stock Failed) After Taking Money, Uh Oh! Remove Success: %s, Loan Success: %s, Pre Gen VIN: %s, withAccount: %s, targetSrc: %s',
                                                                                    removeSuccess,
                                                                                    loanSuccess,
                                                                                    preGenerateVIN,
                                                                                    withAccount,
                                                                                    targetSrc
                                                                                )
                                                                            )
                                                                        end
                                                                    else
                                                                        -- Car Loan Adding Failed

                                                                        exports['pulsar-core']:LoggerError(
                                                                            'Dealerships',
                                                                            string.format(
                                                                                'Vehicle Purchase Failed (Car Loan Added Failed) After Taking Money, Uh Oh! Loan Success: %s, Pre Gen VIN: %s, withAccount: %s, targetSrc: %s',
                                                                                loanSuccess,
                                                                                preGenerateVIN,
                                                                                withAccount,
                                                                                targetSrc
                                                                            )
                                                                        )
                                                                    end
                                                                else
                                                                    exports['pulsar-hud']:Notification(source, "error",
                                                                        'Loan Downpayment Failed', 5000, 'car-building')
                                                                end
                                                            end
                                                        )
                                                    end)

                                                cb(true, 'Initiating Sales Process')
                                            else
                                                cb(false, 'Person Doesn\'t Qualify for Loan')
                                            end
                                        else
                                            cb(false, 'Error Initiating Sale')
                                        end
                                    else
                                        cb(false, 'Person Doesn\'t Qualify for Loan')
                                    end
                                else
                                    cb(false, 'Person Has a Vehicle Loan')
                                end
                            else
                                cb(false, 'Error Initiating Sale')
                            end
                        else
                            cb(false, 'Vehicle Isn\'t In Stock')
                        end
                    else
                        cb(false, 'The Customer is Required to be Present')
                    end

                    return
                end
            end

            cb(false, 'Ensure that the Customer\'s State ID is Correct')
        else
            cb(false, 'Error Initiating Sale')
        end
    end)
end

function SendCompletedCashSaleEmail(charData, dealerData, vehicleInfoData, price, VIN, plate)
    exports['pulsar-phone']:EmailSend(
        charData.Source,
        dealerData.emails.sales,
        os.time(),
        string.format('Vehicle Purchase - %s %s', vehicleInfoData.make, vehicleInfoData.model),
        string.format(
            [[
                Dear %s %s,
                We thank you for completing your purchase of a <b>%s %s</b> for $%s, it has been a pleasure doing business with you.
                Your new vehicle will be delivered as quickly as possible.<br><br>
                The Vehicle VIN is <b>%s</b><br>
                The Vehicle License Plate is <b>%s</b><br>
                <br><br>
                Thanks, %s
            ]],
            charData.First,
            charData.Last,
            vehicleInfoData.make,
            vehicleInfoData.model,
            formatNumberToCurrency(math.floor(price)),
            VIN,
            plate,
            dealerData.name
        ),
        {}
    )
end

local _pendingLoanAccept = {}

function SendPendingLoanEmail(charData, dealerData, vehicleInfoData, downPaymentPercent, downPayment, loanWeeks,
                              weeklyPayments, remaining, cb)
    if not _pendingLoanAccept[charData.SID] then
        _pendingLoanAccept[charData.SID] = cb
        exports['pulsar-phone']:EmailSend(
            charData.Source,
            dealerData.emails.loans,
            os.time(),
            string.format('Vehicle Loan - %s %s', vehicleInfoData.make, vehicleInfoData.model),
            string.format(
                [[
                    Dear %s %s,
                    Thank you for applying for a vehicle loan for a %s %s. The terms of this loan are set out below.<br><br>
                    Down payment: <b>$%s</b> (%s%%)<br>
                    Remaining Amount Owed: <b>$%s</b> (Interest Applied)<br>
                    Loan Length: <b>%s Weeks</b><br>
                    Weekly Payments: <b>$%s</b><br><br>

                    Missing loan payments will lead to an increase in the loans interest rate and a missed payment fee.
                    It may also lead to the eventual seizure of your vehicle by the State of San Andreas.
                    <br><br>
                    If you agree with these terms, please click the link attached above to begin the loan acceptance process.
                    <br><br>
                    Thanks, %s
                ]],
                charData.First,
                charData.Last,
                vehicleInfoData.make,
                vehicleInfoData.model,
                formatNumberToCurrency(math.floor(downPayment)),
                downPaymentPercent,
                formatNumberToCurrency(math.floor(remaining)),
                loanWeeks,
                formatNumberToCurrency(math.floor(weeklyPayments)),
                dealerData.name
            ),
            {
                hyperlink = {
                    event = 'Dealerships:Server:AcceptLoan',
                },
            },
            (os.time() + (60 * 5))
        )

        SetTimeout(60000 * 5, function()
            _pendingLoanAccept[charData.SID] = nil
        end)
    else
        cb(false, 1)
    end
end

RegisterNetEvent('Dealerships:Server:AcceptLoan', function(_, email)
    local src = source
    local char = exports['pulsar-characters']:FetchCharacterSource(src)
    if char then
        exports['pulsar-phone']:EmailDelete(char:GetData('ID'), email)
        local stateId = char:GetData('SID')

        if _pendingLoanAccept[stateId] then
            _pendingLoanAccept[stateId]()
            _pendingLoanAccept[stateId] = nil
        end
    end
end)


function SendCompletedLoanSaleEmail(charData, dealerData, vehicleInfoData, downPaymentPercent, downPayment, loanWeeks,
                                    weeklyPayments, remaining, VIN, plate)
    exports['pulsar-phone']:EmailSend(
        charData.Source,
        dealerData.emails.loans,
        os.time(),
        string.format('Vehicle Loan - %s %s', vehicleInfoData.make, vehicleInfoData.model),
        string.format(
            [[
                Dear %s %s,
                Thank you for taking out a vehicle loan for a %s %s, it has been a pleasure doing business with you.
                Your new vehicle will be delivered as quickly as possible.<br><br>

                The Vehicle VIN is <b>%s</b><br>
                The Vehicle License Plate is <b>%s</b><br>
                <br><br>

                The terms of this loan are set out below.<br><br>
                Down payment: <b>$%s</b> (%s%%)<br>
                Remaining Amount Owed: <b>$%s</b> (Interest Applied)<br>
                Loan Length: <b>%s Weeks</b><br>
                Weekly Payments: <b>$%s</b><br><br>

                Missing loan payments will lead to an increase in the loans interest rate and a missed payment fee.
                It may also lead to the eventual seizure of your vehicle by the State of San Andreas.
                <br><br>
                Thanks, %s
            ]],
            charData.First,
            charData.Last,
            vehicleInfoData.make,
            vehicleInfoData.model,
            VIN,
            plate,
            formatNumberToCurrency(math.floor(downPayment)),
            downPaymentPercent,
            formatNumberToCurrency(math.floor(remaining)),
            loanWeeks,
            formatNumberToCurrency(math.floor(weeklyPayments)),
            dealerData.name
        )
    )
end

function SendDealerProfits(dealerData, dealerProfits, playerBankAccount, playerProfits, vehicleInfoData, buyerData)
    local dealerAccount = exports['pulsar-finance']:AccountsGetOrganization(dealerData.id)
    if dealerAccount then
        exports['pulsar-finance']:BalanceDeposit(dealerAccount.Account, math.floor(dealerProfits), {
            type = 'transfer',
            title = 'Vehicle Purchase',
            description = string.format('Vehicle Sale of a %s %s to %s %s (State ID %s)', vehicleInfoData.make,
                vehicleInfoData.model, buyerData.First, buyerData.Last, buyerData.SID),
            data = {},
        })
    end

    if playerBankAccount then
        exports['pulsar-finance']:BalanceDeposit(playerBankAccount, math.floor(playerProfits), {
            type = 'transfer',
            title = dealerData.abbreviation .. ' - Commission',
            description = string.format('Vehicle Sale Commission from your %s employment.', dealerData.name),
            data = {}
        })
    end
end
