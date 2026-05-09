exports("AccountsGet", function(accountNumber)
	return MySQL.single.await(
		"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE account = ?",
		{
			accountNumber
		})
end)

exports("AccountsCreatePersonal", function(ownerSID)
	local hasAccount = exports['pulsar-finance']:AccountsGetPersonal(ownerSID)
	if hasAccount then
		return hasAccount
	end

	local acc = CreateBankAccount("personal", tostring(ownerSID), 5000)
	if acc then
		return exports['pulsar-finance']:AccountsGet(acc)
	end
	return false
end)

exports("AccountsGetPersonal", function(ownerSID)
	return MySQL.single.await(
		"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE type = ? AND owner = ?",
		{
			"personal",
			tostring(ownerSID)
		})
end)

exports("AccountsCreatePersonalSavings", function(ownerSID)
	local acc = CreateBankAccount("personal_savings", tostring(ownerSID), 0)
	if acc then
		local data = exports['pulsar-finance']:AccountsGet(acc)
		data.JointOwners = {}
		return data
	end
	return false
end)

exports("AccountsAddPersonalSavingsJointOwner", function(accountId, jointOwnerSID)
	local account = MySQL.single.await("SELECT account, type FROM bank_accounts WHERE type = ? AND account = ?",
		{
			"personal_savings",
			accountId
		})

	if account then
		local existing = MySQL.single.await(
			"SELECT jointOwner FROM bank_accounts_permissions WHERE account = ? AND jointOwner = ?", {
				accountId,
				tostring(jointOwnerSID)
			})

		if not existing then
			return MySQL.insert.await(
				"INSERT INTO bank_accounts_permissions (account, type, jointOwner) VALUES (?, ?, ?)", {
					accountId,
					1,
					tostring(jointOwnerSID)
				})
		end
	end
end)

exports("AccountsRemovePersonalSavingsJointOwner", function(accountId, jointOwnerSID)
	return MySQL.query.await(
		"DELETE FROM bank_accounts_permissions WHERE account = ? AND type = ? AND jointOwner = ?", {
			accountId,
			1,
			tostring(jointOwnerSID)
		})
end)

exports("AccountsGetOrganization", function(accountId)
	return MySQL.single.await(
		"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE type = ? AND owner = ?",
		{
			"organization",
			accountId
		})
end)

exports("BalanceGet", function(accountNumber)
	local account = exports['pulsar-finance']:AccountsGet(accountNumber)
	if account then
		return account.Balance
	end
	return false
end)

exports("BalanceHas", function(accountNumber, amount)
	local balance = exports['pulsar-finance']:BalanceGet(accountNumber)
	if balance then
		return balance >= amount
	end
	return false
end)

exports("BalanceDeposit", function(accountNumber, amount, transactionLog, skipPhoneNoti)
	if amount and amount > 0 then
		local u = MySQL.query.await("UPDATE bank_accounts SET balance = balance + ? WHERE account = ?", {
			math.floor(amount),
			accountNumber
		})

		if u and u.affectedRows > 0 then
			if transactionLog then
				exports['pulsar-finance']:TransactionLogsAdd(
					accountNumber,
					transactionLog.type,
					math.floor(amount),
					transactionLog.title,
					transactionLog.description,
					transactionLog.transactionAccount,
					transactionLog.data
				)

				if transactionLog.title ~= "Cash Deposit" then
					local acct = exports['pulsar-finance']:AccountsGet(accountNumber)
					if acct ~= nil then
						if acct.Type == "personal" or acct.Type == "personal_savings" then
							local p = exports['pulsar-characters']:FetchBySID(tonumber(acct.Owner))
							if p ~= nil and not skipPhoneNoti then
								exports['pulsar-phone']:NotificationAdd(
									p:GetData("Source"),
									"Received A Deposit",
									string.format("$%s Deposited Into %s", math.floor(amount), acct.Name),
									os.time(),
									6000,
									"bank",
									{}
								)
							end

							-- if acct.Type == "personal_savings" then
							-- 	local jO = MySQL.query.await("SELECT jointOwner FROM bank_accounts_permissions WHERE account = ? AND type = ?", {
							-- 		acct.Account,
							-- 		1
							-- 	})

							-- 	if jO and #jO > 0 then
							-- 		for k, v in ipairs(jO) do
							-- 			local char = exports['pulsar-characters']:FetchCharacterData("SID", tonumber(v.jointOwner))
							-- 			if char ~= nil then
							-- 				exports['pulsar-phone']:NotificationAdd(
							-- 					char:GetData("Source"),
							-- 					"Received A Deposit",
							-- 					string.format(
							-- 						"$%s Deposited Into %s",
							-- 						math.floor(amount),
							-- 						acct.Name
							-- 					),
							-- 					os.time(),
							-- 					6000,
							-- 					"bank",
							-- 					{}
							-- 				)
							-- 			end
							-- 		end
							-- 	end
							-- end
						end
					end
				end
			end
			return true
		end
	end
	return false
end)

exports("BalanceWithdraw", function(accountNumber, amount, transactionLog)
	if amount and amount > 0 then
		local u = MySQL.query.await("UPDATE bank_accounts SET balance = balance - ? WHERE account = ?", {
			math.floor(amount),
			accountNumber
		})

		if u and u.affectedRows > 0 then
			if transactionLog then
				exports['pulsar-finance']:TransactionLogsAdd(
					accountNumber,
					transactionLog.type,
					-(math.floor(amount)),
					transactionLog.title,
					transactionLog.description,
					transactionLog.transactionAccount,
					transactionLog.data
				)
			end

			return true
		end
	end
	return false
end)

-- Withdraw But Checks If Has Balance
exports("BalanceCharge", function(accountNumber, amount, transactionLog)
	if exports['pulsar-finance']:BalanceHas(accountNumber, (math.floor(amount))) then
		return exports['pulsar-finance']:BalanceWithdraw(accountNumber, (math.floor(amount)), transactionLog)
	end
	return false
end)

exports("TransactionLogsAdd", function(accountNumber, tType, amount, title, description, transactionAccount, data)
	if type(data) ~= "table" then
		data = { data = data }
	end

	data.transactionAccount = transactionAccount

	MySQL.single.await(
		"INSERT INTO bank_accounts_transactions (type, account, amount, title, description, data) VALUES (?, ?, ?, ?, ?, ?)",
		{
			tType,
			accountNumber,
			math.floor(amount),
			title,
			description,
			json.encode(data)
		})
end)
