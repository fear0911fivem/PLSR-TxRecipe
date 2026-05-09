RegisterNUICallback("Loans:GetData", function(data, cb)
	exports["pulsar-core"]:ServerCallback('Loans:GetLoans', {}, function(characterLoansData)
		cb(characterLoansData)
	end)
end)

RegisterNUICallback("Loans:Payment", function(data, cb)
	exports["pulsar-core"]:ServerCallback('Loans:Payment', data, function(res, updatedCharacterLoansData)
		if res and res.success and updatedCharacterLoansData then
			exports['pulsar-phone']:DataSet('bankLoans', updatedCharacterLoansData)
		end

		cb(res)
	end)
end)
