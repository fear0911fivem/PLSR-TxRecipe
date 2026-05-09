local _jobName = "garcon_pawn"
local _pawnItems = {
	["jewelry"] = {
		{
			item = "rolex",
			rep = 15,
		},
		{
			item = "ring",
			rep = 10,
		},
		{
			item = "chain",
			rep = 10,
		},
		{
			item = "watch",
			rep = 10,
		},
		{
			item = "earrings",
			rep = 10,
		},
		{
			item = "goldcoins",
			rep = 5,
		},
	},
	["valuegoods"] = {
		{
			item = "valuegoods",
			rep = 30,
		},
	},
	["electronics"] = {
		{
			item = "tv",
			rep = 30,
		},
		{
			item = "big_tv",
			rep = 80,
		},
		{
			item = "boombox",
			rep = 20,
		},
		{
			item = "pc",
			rep = 50,
		},
	},
	["appliance"] = {
		{
			item = "microwave",
			rep = 25,
		},
	},
	["golf"] = {
		{
			item = "golfclubs",
			rep = 40,
		},
	},
	["art"] = {
		{
			item = "house_art",
			rep = 50,
		},
	},
	["raremetals"] = {
		{
			item = "goldbar",
			rep = 25,
		},
		{
			item = "silverbar",
			rep = 15,
		},
	},
}

AddEventHandler("Businesses:Server:Startup", function()
	exports["pulsar-core"]:RegisterServerCallback("GarconPawn:Sell", function(source, data, cb)
		if exports['pulsar-jobs']:HasJob(source, _jobName) then
			local char = exports['pulsar-characters']:FetchCharacterSource(source)
			if char then
				local money = 0
				local soldCount = 0
				local data = {}
				for category, pawning in pairs(_pawnItems) do
					for k, v in ipairs(pawning) do
						local count = exports.ox_inventory:ItemsGetCount(char:GetData("SID"), 1, v.item) or 0
						if count > 0 then
							local itemData = exports.ox_inventory:ItemsGetData(v.item)

							if itemData and exports.ox_inventory:Remove(char:GetData("SID"), 1, v.item, count) then
								money += itemData.price * count
								soldCount += count
								table.insert(
									data,
									string.format("%s %s ($%s/each)", count, itemData.name, itemData.price)
								)
							end
						end
					end
				end

				if money > 0 then
					local f = exports['pulsar-finance']:AccountsGetOrganization(_jobName)
					if f ~= nil then
						exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(money) * 0.9), {
							type = "deposit",
							title = "Sold Goods",
							description = string.format("Sold %s Pawned Goods", soldCount),
							data = data,
						})
					else
						exports['pulsar-finance']:WalletModify(source, money)
					end

					f = exports['pulsar-finance']:AccountsGetOrganization("government")
					exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(money) * 0.1), {
						type = "deposit",
						title = "Sold Goods Tax",
						description = string.format("10%% Tax On %s Sold Goods", soldCount),
						data = data,
					}, true)

					-- -- KEKW
					-- f = exports['pulsar-finance']:AccountsGetOrganization("dgang")
					-- exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(money) * 0.1), {
					-- 	type = "deposit",
					-- 	title = "Sold Goods Tax",
					-- 	description = string.format("10%% Tax On %s Sold Goods", soldCount),
					-- 	data = data,
					-- }, true)
				else
					exports['pulsar-hud']:Notification(source, "error", "You Have Nothing To Sell")
				end
			end
		end
	end)
end)
