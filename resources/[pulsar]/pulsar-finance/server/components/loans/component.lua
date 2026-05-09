exports("LoansGetAllowedLoanAmount", function(stateId, type)
	if not type then
		type = "vehicle"
	end
	if _creditScoreConfig.allowedLoanMultipliers[type] then
		local creditScore = GetCharacterCreditScore(stateId)

		local creditMult = 0
		for k, v in ipairs(_creditScoreConfig.allowedLoanMultipliers[type]) do
			if creditScore >= v.value then
				creditMult = v.multiplier
			else
				break
			end
		end

		return {
			creditScore = creditScore,
			maxBorrowable = creditScore * creditMult,
			limit = creditScore > 420 and 3 or 2,
		}
	end
end)

exports("LoansGetDefaultInterestRate", function()
	return _loanConfig.defaultInterestRate
end)

exports("LoansGetPlayerLoans", function(stateId, type)
	local p = promise.new()
	local currentTime = os.time()
	local oneDayAgo = currentTime - (60 * 60 * 24 * 1)

	exports.oxmysql:execute(
		'SELECT * FROM loans WHERE SID = ? AND Type = ? AND (Remaining > 0 OR (Remaining = 0 AND LastPayment >= ?))',
		{ stateId, type, oneDayAgo },
		function(results)
			if results then
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
				p:resolve(false)
			end
		end)
	return Citizen.Await(p)
end)

exports("LoansCreateVehicleLoan", function(targetSource, VIN, totalCost, downPayment, totalWeeks)
	local char = exports['pulsar-characters']:FetchCharacterSource(targetSource)
	if char then
		local p = promise.new()
		local remainingCost = totalCost - downPayment
		local timeStamp = os.time()

		local doc = {
			Creation = timeStamp,
			SID = char:GetData("SID"),
			Type = "vehicle",
			AssetIdentifier = VIN,
			Defaulted = false,
			InterestRate = _loanConfig.defaultInterestRate,
			Total = totalCost,
			Remaining = remainingCost,
			Paid = downPayment,
			DownPayment = downPayment,
			TotalPayments = totalWeeks,
			PaidPayments = 0,
			MissablePayments = _loanConfig.missedPayments.limit,
			MissedPayments = 0,
			TotalMissedPayments = 0,
			NextPayment = timeStamp + _loanConfig.paymentInterval,
			LastPayment = 0,
		}

		exports.oxmysql:execute(
			'INSERT INTO loans (Creation, SID, Type, AssetIdentifier, Defaulted, InterestRate, Total, Remaining, Paid, DownPayment, TotalPayments, PaidPayments, MissablePayments, MissedPayments, TotalMissedPayments, NextPayment, LastPayment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
			{ doc.Creation, doc.SID, doc.Type, doc.AssetIdentifier, doc.Defaulted and 1 or 0, doc.InterestRate, doc
				.Total, doc.Remaining, doc.Paid, doc.DownPayment, doc.TotalPayments, doc.PaidPayments, doc
				.MissablePayments, doc.MissedPayments, doc.TotalMissedPayments, doc.NextPayment, doc.LastPayment },
			function(result)
				local insertId = type(result) == "table" and result.insertId or result
				if insertId and insertId > 0 then
					p:resolve(true)
				else
					p:resolve(false)
				end
			end)

		local res = Citizen.Await(p)
		return res
	end
	return false
end)

exports("LoansCreatePropertyLoan", function(targetSource, propertyId, totalCost, downPayment, totalWeeks)
	local char = exports['pulsar-characters']:FetchCharacterSource(targetSource)
	if char then
		local p = promise.new()
		local remainingCost = totalCost - downPayment
		local timeStamp = os.time()

		local doc = {
			Creation = timeStamp,
			SID = char:GetData("SID"),
			Type = "property",
			AssetIdentifier = propertyId,
			Defaulted = false,
			InterestRate = _loanConfig.defaultInterestRate,
			Total = totalCost,
			Remaining = remainingCost,
			Paid = downPayment,
			DownPayment = downPayment,
			TotalPayments = totalWeeks,
			PaidPayments = 0,
			MissablePayments = _loanConfig.missedPayments.limit,
			MissedPayments = 0,
			TotalMissedPayments = 0,
			NextPayment = timeStamp + _loanConfig.paymentInterval,
			LastPayment = 0,
		}

		exports.oxmysql:execute(
			'INSERT INTO loans (Creation, SID, Type, AssetIdentifier, Defaulted, InterestRate, Total, Remaining, Paid, DownPayment, TotalPayments, PaidPayments, MissablePayments, MissedPayments, TotalMissedPayments, NextPayment, LastPayment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
			{ doc.Creation, doc.SID, doc.Type, doc.AssetIdentifier, doc.Defaulted and 1 or 0, doc.InterestRate, doc
				.Total, doc.Remaining, doc.Paid, doc.DownPayment, doc.TotalPayments, doc.PaidPayments, doc
				.MissablePayments, doc.MissedPayments, doc.TotalMissedPayments, doc.NextPayment, doc.LastPayment },
			function(result)
				local insertId = type(result) == "table" and result.insertId or result
				if insertId and insertId > 0 then
					p:resolve(true)
				else
					p:resolve(false)
				end
			end)

		local res = Citizen.Await(p)
		return res
	end
	return false
end)

exports("LoansMakePayment", function(source, loanId, inAdvanced, advancedPaymentCount)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char then
		local SID = char:GetData("SID")
		local Account = char:GetData("BankAccount")
		local loan = GetLoanByID(loanId, SID)
		if loan then
			local timeStamp = os.time()

			local remainingPayments = loan.TotalPayments - loan.PaidPayments

			local totalCreditGained = _creditScoreConfig.addition.loanPaymentMin
			if loan.Total >= 50000 then
				totalCreditGained += (math.floor(loan.Total / 50000) * 10)

				if totalCreditGained > _creditScoreConfig.addition.loanPaymentMax then
					totalCreditGained = _creditScoreConfig.addition.loanPaymentMax
				end
			end

			if remainingPayments > 0 and loan.Remaining > 0 then
				local interestMult = ((100 + loan.InterestRate) / 100)
				local creditScoreIncrease = 0
				local actuallyAdvancedPayments = 0
				local payments = 1
				if loan.MissedPayments > 0 then
					payments = loan.MissedPayments

					if payments > remainingPayments then
						payments = remainingPayments
					end

					creditScoreIncrease += math.floor(((totalCreditGained / loan.TotalPayments) * payments) / 2)
				else
					local timeUntilDue = loan.NextPayment - timeStamp
					local doneMinLoanLength = (timeStamp - loan.Creation) >= (60 * 60 * 24 * 5)

					if timeUntilDue >= (_loanConfig.paymentInterval * 4) and not doneMinLoanLength then -- Can only pay 2 weeks in advanced or wait until loan is 1 week old
						return {
							success = false,
							message = "Can't Pay That Far in Advanced - Hold Loan For At Least 5 Days",
						}
					end

					local loanPaymentCreditIncrease = math.floor(totalCreditGained / loan.TotalPayments)
					creditScoreIncrease += loanPaymentCreditIncrease

					local earlyTime = loan.NextPayment - (_loanConfig.paymentInterval * 0.5)
					if timeStamp <= earlyTime then -- Well Done You Are Early
						creditScoreIncrease += 2
					end
				end

				-- TODO: (maybe) Interest Going to the Government Account?

				local dueAmount = math.ceil(((loan.Remaining / remainingPayments) * payments) * interestMult)
				local chargeSuccess = exports['pulsar-finance']:BalanceCharge(Account, dueAmount, {
					type = "loan",
					title = "Loan Payment",
					description = string.format(
						"Loan Payment for %s %s",
						GetLoanTypeName(loan.Type),
						loan.AssetIdentifier
					),
					data = {
						loan = loan._id,
					},
				})

				if chargeSuccess then
					local updateQuery
					local loanPaidOff = false
					local nowRemainingPayments = remainingPayments - payments
					if nowRemainingPayments <= 0 then
						loanPaidOff = true
					end

					if loan.Defaulted then -- Unseize Assets
						if loan.Type == "vehicle" then
							exports['pulsar-vehicles']:OwnedSeize(loan.AssetIdentifier, false)
						elseif loan.Type == "property" then
							exports['pulsar-properties']:Foreclose(loan.AssetIdentifier, false)
						end
					end

					if loanPaidOff then
						if loan.TotalMissedPayments <= 0 then
							creditScoreIncrease += _creditScoreConfig.addition.completingLoanNoMissed
						else
							creditScoreIncrease += _creditScoreConfig.addition.completingLoan
						end

						updateQuery = {
							["$set"] = {
								LastPayment = timeStamp,
								NextPayment = 0,
								Remaining = 0,
								Defaulted = false,
							},
							["$inc"] = {
								Paid = dueAmount,
								PaidPayments = payments,
							},
						}
					else
						updateQuery = {
							["$set"] = {
								LastPayment = timeStamp,
								NextPayment = (loan.NextPayment + _loanConfig.paymentInterval),
								Defaulted = false,
							},
							["$inc"] = {
								Paid = dueAmount,
								PaidPayments = payments,
								Remaining = -dueAmount,
							},
						}

						if loan.MissedPayments > 0 then
							updateQuery["$set"]["MissedPayments"] = 0
							updateQuery["$set"]["MissablePayments"] =
								math.max(1, loan.MissablePayments - loan.MissedPayments)
						end
					end

					local updated = UpdateLoanById(loan._id, updateQuery)

					if creditScoreIncrease > 0 then
						IncreaseCharacterCreditScore(SID, creditScoreIncrease)
					end

					if updated then
						return {
							success = true,
							paidOff = loanPaidOff,
							paymentAmount = dueAmount,
							creditIncrease = creditScoreIncrease,
						}
					end
				else
					return {
						success = false,
						message = "Insufficient Funds in Checking Account",
					}
				end
			end
		end
	end
	return {
		success = false,
	}
end)

exports("LoansHasRemainingPayments", function(assetType, assetId, checkAge)
	-- checkAge (check if older than certain age (days))
	local p = promise.new()
	exports.oxmysql:execute('SELECT * FROM loans WHERE Type = ? AND AssetIdentifier = ?', { assetType, assetId },
		function(results)
			if results and #results > 0 then
				local l = results[1]

				if checkAge and l.Creation >= (os.time() - (60 * 60 * 24 * checkAge)) then
					p:resolve(true)
					return
				end

				if l and l.Remaining and l.Remaining > 0 then
					p:resolve(true)
				else
					p:resolve(false)
				end
			else
				p:resolve(false)
			end
		end)

	return Citizen.Await(p)
end)

exports("LoansCreditGet", function(stateId)
	return GetCharacterCreditScore(stateId)
end)

exports("LoansCreditSet", function(stateId, newVal)
	return SetCharacterCreditScore(stateId, newVal)
end)

exports("LoansCreditIncrease", function(stateId, increase)
	return IncreaseCharacterCreditScore(stateId, increase)
end)

exports("LoansCreditDecrease", function(stateId, decrease)
	return DecreaseCharacterCreditScore(stateId, decrease)
end)

exports("LoansHasBeenDefaulted", function(assetType, assetId)
	local p = promise.new()

	exports.oxmysql:execute('SELECT * FROM loans WHERE Type = ? AND AssetIdentifier = ? AND Defaulted = ?',
		{ assetType, assetId, 1 }, function(results)
			if results and #results > 0 then
				local l = results[1]

				p:resolve(l)
			else
				p:resolve(false)
			end
		end)

	return Citizen.Await(p)
end)

function GetLoanByID(loanId, stateId)
	local p = promise.new()
	exports.oxmysql:execute('SELECT * FROM loans WHERE id = ? AND SID = ?', { loanId, stateId }, function(results)
		if results and #results > 0 then
			local loan = results[1]
			if loan.paymentHistory then
				loan.paymentHistory = json.decode(loan.paymentHistory)
			end
			if loan.terms then
				loan.terms = json.decode(loan.terms)
			end
			loan.Defaulted = loan.Defaulted == 1
			p:resolve(loan)
		else
			p:resolve(false)
		end
	end)

	local res = Citizen.Await(p)
	return res
end

function UpdateLoanById(loanId, update)
	local p = promise.new()

	local setParts = {}
	local incParts = {}
	local values = {}

	if update["$set"] then
		for k, v in pairs(update["$set"]) do
			if k == "Defaulted" then
				table.insert(setParts, k .. " = ?")
				table.insert(values, v and 1 or 0)
			else
				table.insert(setParts, k .. " = ?")
				table.insert(values, v)
			end
		end
	end

	if update["$inc"] then
		for k, v in pairs(update["$inc"]) do
			table.insert(incParts, k .. " = " .. k .. " + ?")
			table.insert(values, v)
		end
	end

	local updateParts = {}
	for _, part in ipairs(setParts) do
		table.insert(updateParts, part)
	end
	for _, part in ipairs(incParts) do
		table.insert(updateParts, part)
	end

	if #updateParts > 0 then
		local query = "UPDATE loans SET " .. table.concat(updateParts, ", ") .. " WHERE id = ?"
		table.insert(values, loanId)

		exports.oxmysql:execute(query, values, function(affectedRows)
			if affectedRows and affectedRows > 0 then
				p:resolve(true)
			else
				p:resolve(false)
			end
		end)
	else
		p:resolve(false)
	end

	local res = Citizen.Await(p)
	return res
end
