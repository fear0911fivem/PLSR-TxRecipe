AddEventHandler("Crypto:Server:Startup", function()
	exports['pulsar-finance']:CryptoCoinCreate("Vroom", "VRM", 100, false, false)
	exports['pulsar-finance']:CryptoCoinCreate("Mald", "MALD", 250, true, 190)

	-- Compatability since we're renaming MALD
	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local myCrypto = char:GetData("Crypto")

		if myCrypto.PLEB ~= nil then
			myCrypto.MALD = myCrypto.PLEB
			myCrypto.PLEB = nil
			char:SetData("Crypto", myCrypto)
		end
	end, 1)
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Crypto:Buy", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			return cb(exports['pulsar-finance']:CryptoExchangeBuy(data.Short, char:GetData("SID"), data.Quantity))
		end
		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Crypto:Sell", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			return cb(exports['pulsar-finance']:CryptoExchangeSell(data.Short, char:GetData("SID"), data.Quantity))
		end
		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Crypto:Transfer", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and char:GetData("SID") ~= data.Target then
			return cb(exports['pulsar-finance']:CryptoExchangeTransfer(data.Short, char:GetData("SID"), data.Target,
				data.Quantity))
		end
		cb(false)
	end)
end)
