function PrisonHospitalCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Hospital:PrisonHospitalRevive", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local p = Player(source).state
		local cost = Config.PrisonCheckIn.Cost

		exports['pulsar-finance']:BillingCharge(source, cost, "Medical Services",
			"Use of facilities at Bolingbroke Infirmary")

		local f = exports['pulsar-finance']:AccountsGetOrganization("ems")
		exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
			type = "deposit",
			title = "Medical Treatment",
			description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
			data = {},
		}, true)

		f = exports['pulsar-finance']:AccountsGetOrganization("government")
		exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
			type = "deposit",
			title = "Medical Treatment",
			description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
			data = {},
		}, true)

		local tChar = exports['pulsar-characters']:FetchCharacterSource(source)
		if tChar ~= nil then
			exports["pulsar-core"]:ClientCallback(tChar:GetData("Source"), "Damage:Heal", true)
		else
			exports['pulsar-hud']:Notification(source, "error",
				"An error has occured. Please report this.")
		end

		cb(true)
	end)
end
