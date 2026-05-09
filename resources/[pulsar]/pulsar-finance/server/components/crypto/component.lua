_cryptoCoins = {}

exports("CryptoCoinCreate", function(name, acronym, price, buyable, sellable)
	if not exports['pulsar-finance']:CryptoCoinGet(acronym) then
		table.insert(_cryptoCoins, {
			Name = name,
			Short = acronym,
			Price = price,
			Buyable = buyable,
			Sellable = sellable,
		})
	else
		for k, v in ipairs(_cryptoCoins) do
			if v.Short == acronym then
				_cryptoCoins[k] = {
					Name = name,
					Short = acronym,
					Price = price,
					Buyable = buyable,
					Sellable = sellable,
				}
				return
			end
		end
	end
end)

exports("CryptoCoinGet", function(acronym)
	for k, v in ipairs(_cryptoCoins) do
		if v.Short == acronym then
			return v
		end
	end

	return nil
end)

exports("CryptoCoinGetAll", function()
	return _cryptoCoins
end)

exports("CryptoHas", function(source, coin, amt)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local crypto = char:GetData("Crypto") or {}
		return crypto[coin] ~= nil and crypto[coin] >= amt
	else
		return false
	end
end)

exports("CryptoExchangeIsListed", function(coin)
	for k, v in ipairs(_cryptoCoins) do
		if v.Short == coin then
			return true
		end
	end
	return false
end)

exports("CryptoExchangeBuy", function(coin, target, amount)
	if exports['pulsar-finance']:CryptoExchangeIsListed(coin) then
		local char = exports['pulsar-characters']:FetchBySID(target)
		if char ~= nil then
			local acc = exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID"))
			local coinData = exports['pulsar-finance']:CryptoCoinGet(coin)
			if acc.Balance >= (coinData.Price * amount) then
				if
					exports['pulsar-finance']:BalanceWithdraw(acc.Account, (coinData.Price * amount), {
						type = "withdraw",
						title = "Crypto Purchase",
						description = string.format("Bought %s $%s", amount, coin),
						transactionAccount = false,
						data = {
							character = char:GetData("SID"),
						},
					})
				then
					exports['pulsar-phone']:NotificationAdd(
						char:GetData("Source"),
						"Crypto Purchase",
						string.format("You Bought %s $%s", amount, coin),
						os.time(),
						6000,
						"crypto",
						{}
					)
					return exports['pulsar-finance']:CryptoExchangeAdd(coin, char:GetData("CryptoWallet"), amount)
				else
					return false
				end
			else
				exports['pulsar-phone']:NotificationAdd(
					char:GetData("Source"),
					"Crypto Purchase",
					"Insufficient Funds",
					os.time(),
					6000,
					"crypto",
					{}
				)
				return false
			end
		else
			return false
		end
	else
		return false
	end
end)

exports("CryptoExchangeSell", function(coin, target, amount)
	if exports['pulsar-finance']:CryptoExchangeIsListed(coin) then
		local char = exports['pulsar-characters']:FetchBySID(target)
		if char ~= nil then
			local acc = exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID"))
			local coinData = exports['pulsar-finance']:CryptoCoinGet(coin)

			if coinData.Sellable then
				if exports['pulsar-finance']:CryptoExchangeRemove(coin, char:GetData("CryptoWallet"), amount, true) then
					return exports['pulsar-finance']:BalanceDeposit(acc.Account, (coinData.Sellable * amount), {
						type = "deposit",
						title = "Crypto Sale",
						description = string.format("Sold %s $%s", amount, coin),
						transactionAccount = false,
						data = {
							character = char:GetData("SID"),
						},
					})
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end)

exports("CryptoExchangeAdd", function(coin, target, amount, skipAlert)
	local char = exports['pulsar-characters']:FetchCharacterData("CryptoWallet", target)
	if char ~= nil then
		local crypto = char:GetData("Crypto") or {}
		if crypto[coin] == nil then
			crypto[coin] = 0
		end

		crypto[coin] = crypto[coin] + amount
		char:SetData("Crypto", crypto)

		if not skipAlert then
			exports['pulsar-phone']:NotificationAdd(
				char:GetData("Source"),
				"Received Crypto",
				string.format("You Received %s $%s", amount, coin),
				os.time(),
				6000,
				"crypto",
				{}
			)
		end

		return true
	else
		local results = MySQL.Sync.fetchAll('SELECT Crypto FROM characters WHERE CryptoWallet = @target', {
			['@target'] = target
		})

		if results and #results > 0 then
			local crypto = json.decode(results[1].Crypto) or {}
			if crypto[coin] == nil then
				crypto[coin] = 0
			end

			crypto[coin] = crypto[coin] + amount
			local updatedCrypto = json.encode(crypto)

			local success = MySQL.Sync.execute('UPDATE characters SET Crypto = @crypto WHERE CryptoWallet = @target', {
				['@crypto'] = updatedCrypto,
				['@target'] = target
			})

			return success > 0
		else
			return false
		end
	end
end)

exports("CryptoExchangeRemove", function(coin, target, amount, skipAlert)
	local p = promise.new()
	local char = exports['pulsar-characters']:FetchCharacterData("CryptoWallet", target)
	if char ~= nil then
		local crypto = char:GetData("Crypto") or {}

		if crypto[coin] == nil then
			crypto[coin] = 0
		end

		if crypto[coin] >= amount then
			crypto[coin] = crypto[coin] - amount
			char:SetData("Crypto", crypto)

			if not skipAlert then
				exports['pulsar-phone']:NotificationAdd(
					char:GetData("Source"),
					"Crypto Purchase",
					string.format("You Paid %s $%s", amount, coin),
					os.time(),
					6000,
					"crypto",
					{}
				)
			end

			p:resolve(true)
		else
			p:resolve(false)
		end
	else
		MySQL.Async.fetchAll('SELECT Crypto FROM characters WHERE CryptoWallet = @wallet LIMIT 1', {
			['@wallet'] = target
		}, function(results)
			if #results == 0 then
				p:resolve(false)
				return
			else
				local crypto = json.decode(results[1].Crypto) or {}
				if crypto[coin] and crypto[coin] >= amount then
					crypto[coin] = crypto[coin] - amount
					MySQL.Async.execute('UPDATE characters SET Crypto = @crypto WHERE CryptoWallet = @wallet', {
						['@crypto'] = json.encode(crypto),
						['@wallet'] = target
					}, function(affectedRows)
						p:resolve(affectedRows > 0)
					end)
				else
					p:resolve(false)
				end
			end
		end)
	end

	return Citizen.Await(p)
end)

exports("CryptoExchangeTransfer", function(coin, sender, target, amount)
	local char = exports['pulsar-characters']:FetchBySID(sender)
	if char then
		if char:GetData("CryptoWallet") ~= target then
			local tChar = exports['pulsar-characters']:FetchCharacterData("CryptoWallet", target)

			if tChar or DoesCryptoWalletExist(target) then
				if exports['pulsar-finance']:CryptoExchangeRemove(coin, char:GetData("CryptoWallet"), math.abs(amount), true) then
					exports['pulsar-phone']:NotificationAdd(
						char:GetData("Source"),
						"Crypto Transfer",
						string.format("You Sent %s $%s", amount, coin),
						os.time(),
						6000,
						"crypto",
						{}
					)

					if exports['pulsar-finance']:CryptoExchangeAdd(coin, target, math.abs(amount), true) then
						if tChar then
							exports['pulsar-phone']:NotificationAdd(
								tChar:GetData("Source"),
								"Crypto Transfer",
								string.format("You Received %s $%s", amount, coin),
								os.time(),
								6000,
								"crypto",
								{}
							)
						end

						return true
					end
				end
			end
		end
	end
	return false
end)
