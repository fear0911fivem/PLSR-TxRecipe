exports("WalletGet", function(source)
	return exports.ox_inventory:GetItemCount(source, 'money') or 0
end)

exports("WalletHas", function(source, amount)
	if amount > 0 then
		local currentCash = exports.ox_inventory:GetItemCount(source, 'money') or 0
		return currentCash >= amount
	end
	return false
end)

exports("WalletModify", function(source, amount, skipNotify)
	local currentCash = exports.ox_inventory:GetItemCount(source, 'money') or 0
	local newCashBalance = math.floor(currentCash + amount)

	if newCashBalance >= 0 then
		if amount > 0 then
			exports.ox_inventory:AddItem(source, 'money', amount)
		elseif amount < 0 then
			exports.ox_inventory:RemoveItem(source, 'money', math.abs(amount))
		end

		if not skipNotify then
			if amount < 0 then
				exports['pulsar-hud']:Notification(source, "info",
					string.format("You Paid $%s In Cash", formatNumberToCurrency(math.floor(math.abs(amount))))
				)
			else
				exports['pulsar-hud']:Notification(source, "success",
					string.format("You Received $%s In Cash", formatNumberToCurrency(math.floor(amount)))
				)
			end
		end
		return newCashBalance
	end
	return false
end)
