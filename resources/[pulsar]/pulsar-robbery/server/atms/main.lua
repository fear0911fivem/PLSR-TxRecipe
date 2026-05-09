local _atm = RobberyConfig.atms

local _ATMRobberyCDs = {}

AddEventHandler("Robbery:Server:Setup", function()
	GlobalState["ATMRobberyTerminal"] = _atm.terminal
	GlobalState["ATMRobberyAreas"] = _atm.areas

	exports['pulsar-characters']:RepCreate("ATMRobbery", "ATM Hacking", {
		{ label = "Newbie", value = 1000 },
		{ label = "Okay",   value = 2000 },
		{ label = "Good",   value = 4000 },
		{ label = "Pro",    value = 10000 },
		{ label = "Expert", value = 16000 },
		{ label = "God",    value = 25000 },
	}, false)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:ATM:StartJob", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local inATM = Player(source).state.ATMRobbery

		if
			char and (not inATM or inATM <= 0) and not GlobalState["ATMRobberyStartCD"]
			or (os.time() > GlobalState["ATMRobberyStartCD"]) and GlobalState["Sync:IsNight"]
		then
			if GlobalState["RobberiesDisabled"] then
				exports['pulsar-hud']:Notification(source, "error",
					"Temporarily Disabled, Please See City Announcements",
					6000
				)
				return
			end
			if data then
				local personalMax = GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] or 0
				if personalMax < _atm.maxRobberies then
					Player(source).state.ATMRobbery = math.random(4, 6)
					GlobalState["ATMRobberyStartCD"] = os.time() + (60 * math.random(2, 5)) -- Cooldown

					local repLvl = exports['pulsar-characters']:RepGetLevel(source, "ATMRobbery")

					local location = GetNewATMLocation(repLvl)
					Player(source).state.ATMRobberyZone = location.id

					cb(true, location)
				else
					cb(false, true)
				end
			else
				GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] = 10
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:ATM:HackATM", function(source, difficulty, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local inATM = Player(source).state.ATMRobbery

		if
			char and inATM and inATM > 0 and not _ATMRobberyCDs[char:GetData("SID")]
			or (os.time() > _ATMRobberyCDs[char:GetData("SID")])
		then
			if GlobalState["RobberiesDisabled"] then
				exports['pulsar-hud']:Notification(source, "error",
					"Temporarily Disabled, Please See City Announcements",
					6000
				)
				return
			end
			local newATMRobbery = inATM - 1
			Player(source).state.ATMRobbery = newATMRobbery
			_ATMRobberyCDs[char:GetData("SID")] = os.time() + 60

			local personalMax = GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] or 0
			GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] = personalMax + 1

			exports['pulsar-characters']:RepAdd(source, "ATMRobbery", 100)

			local repLvl = exports['pulsar-characters']:RepGetLevel(source, "ATMRobbery")

			if repLvl >= 4 then
				exports.ox_inventory:LootCustomWeightedSetWithCount(_atm.lootHigh, char:GetData("SID"), 1)
			else
				exports.ox_inventory:LootCustomWeightedSetWithCount(_atm.loot, char:GetData("SID"), 1)
			end

			local chance = 15
			if repLvl >= 4 then
				chance = 22
			end
			if math.random(100) < chance and repLvl >= 2 then
				exports.ox_inventory:AddItem(char:GetData("SID"), "crypto_voucher", 1, {
					CryptoCoin = "HEIST",
					Quantity = math.random(2, repLvl + 1),
				}, 1)
			end

			local reward = math.floor((difficulty or 5) * 100 / 4)
			exports['pulsar-finance']:WalletModify(source, (math.random(150) + reward))

			if newATMRobbery > 0 then
				local location = GetNewATMLocation(repLvl, Player(source).state.ATMRobberyZone)
				Player(source).state.ATMRobberyZone = location.id

				cb(true, location)
			else
				cb(true, false)
			end

			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:ATM:FailHackATM", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local inATM = Player(source).state.ATMRobbery

		if char and inATM and inATM > 0 then
			Player(source).state.ATMRobbery = false

			if not data.alarm then
				exports['pulsar-robbery']:TriggerPDAlert(source, data.coords, "10-90", "ATM Robbery", {
					icon = 521,
					size = 0.9,
					color = 31,
					duration = (60 * 5),
				})
			end

			local personalMax = GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] or 0
			GlobalState[string.format("ATMRobbery:%s", char:GetData("SID"))] = personalMax + 1

			exports['pulsar-characters']:RepRemove(source, "ATMRobbery", 65)

			cb(true)
		else
			cb(false)
		end
	end)

	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		Player(source).state.ATMRobbery = false
	end, 10)
end)

function GetNewATMLocation(repLvl, lastZoneId)
	local availableLocations = {}

	for k, v in ipairs(_atm.areas) do
		v.id = k

		if repLvl >= 3 or v.city and v.id ~= lastZoneId then
			table.insert(availableLocations, v)
		end
	end

	local randLocation = availableLocations[math.random(#availableLocations)]
	return randLocation
end

RegisterNetEvent("Robbery:Server:ATM:AlertPolice", function(coords)
	local src = source
	exports['pulsar-robbery']:TriggerPDAlert(src, coords, "10-90", "ATM Robbery", {
		icon = 521,
		size = 0.9,
		color = 31,
		duration = (60 * 5),
	})
end)
