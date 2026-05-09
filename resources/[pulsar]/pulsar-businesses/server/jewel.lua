local _jobName = "jewel"

AddEventHandler("Businesses:Server:Startup", function()
	exports["pulsar-core"]:RegisterServerCallback("Businesses:JEWEL:OpenTable", function(source, data, cb)
		exports.ox_inventory:OpenSecondary(source, 149, data)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Businesses:JEWEL:Sell", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if exports['pulsar-jobs']:HasJob(source, _jobName, false, false, false, false, "JOB_SELL_GEMS") then
			local its = exports.ox_inventory:GetAllOfTypeNoStack(char:GetData("SID"), 1, 11)

			if its and #its > 0 then
				local totalSold = 0
				local totalPayout = 0
				for k, v in ipairs(its) do
					local md = json.decode(v.MetaData)
					local itemData = exports.ox_inventory:ItemsGetData(v.Name)
					local gemWorth = (itemData.price * ((md.Quality or 1) / 100))

					if exports.ox_inventory:RemoveId(char:GetData("SID"), 1, v) then
						totalPayout += gemWorth
						totalSold += 1
					end
				end

				local f = exports['pulsar-finance']:AccountsGetOrganization(_jobName)
				if f ~= nil then
					exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(totalPayout) * 0.8), {
						type = "deposit",
						title = "Sold Goods",
						description = string.format("Sold %s Gems", totalSold),
						data = {},
					})
					exports['pulsar-hud']:Notification(source, "success",
						string.format(
							"Sold %s Gems For $%s (Deposited To Company Account)",
							totalSold,
							math.ceil(math.abs(totalPayout) * 0.8)
						)
					)
				else
					exports['pulsar-finance']:WalletModify(source, totalPayout)
				end

				f = exports['pulsar-finance']:AccountsGetOrganization("government")
				exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(totalPayout) * 0.1), {
					type = "deposit",
					title = "Sold Goods Tax",
					description = string.format("10%% Tax On %s Sold Gems", totalSold),
					data = data,
				}, true)

				-- KEKW
				f = exports['pulsar-finance']:AccountsGetOrganization("dgang")
				exports['pulsar-finance']:BalanceDeposit(f.Account, math.ceil(math.abs(totalPayout) * 0.1), {
					type = "deposit",
					title = "Sold Goods Tax",
					description = string.format("10%% Tax On %s Sold Gems", totalSold),
					data = data,
				}, true)
			else
				exports['pulsar-hud']:Notification(source, "error", "You Don't Have Any Gems To Sell")
			end
		end
	end)
end)

AddEventHandler("Businesses:Server:JEWEL:ViewGem", function(source, data)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		if exports['pulsar-jobs']:HasJob(source, _jobName, false, false, false, true, "JOB_USE_GEM_TABLE") then
			local its = exports.ox_inventory:GetInventory(source, data.owner, data.invType)
			if #its > 0 then
				local md = json.decode(its[1].MetaData)
				local itemData = exports.ox_inventory:ItemsGetData(its[1].Name)
				if itemData ~= nil and itemData.type == 11 and itemData.gemProperties ~= nil then
					TriggerClientEvent(
						"Businesses:Client:JEWEL:ViewGem",
						source,
						data.owner,
						itemData.gemProperties,
						md.Quality,
						its[1]
					)
				end
			end
		end
	end
end)
