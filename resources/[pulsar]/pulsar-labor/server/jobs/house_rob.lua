local _JOB = "HouseRobbery"

local _joiners = {}
local _robbers = {}
local _inProgress = {}

local _cooldowns = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
}

local Weapons = {
	`WEAPON_BAT`,
	`WEAPON_KNIFE`,
	`WEAPON_BATTLEAXE`,
	`WEAPON_HAMMER`,
	`WEAPON_PISTOL`,
	`WEAPON_DBSHOTGUN`,
	`WEAPON_APPISTOL`,
}

local _loot = {
	standard = {
		{ 20, { name = "goldcoins", min = 4, max = 13 } },
		{ 10, { name = "rolex", min = 2, max = 6 } },
		{ 25, { name = "ring", min = 2, max = 8 } },
		{ 15, { name = "chain", min = 3, max = 10 } },
		{ 29, { name = "earrings", min = 6, max = 15 } },
		{ 1,  { name = "valuegoods", max = 1 } },
	},
	medicine = {
		-- { 25, { name = "hydrocodone", max = 3 } },
		-- { 20, { name = "vicodin", max = 3 } },
		{ 100, { name = "bandage", max = 10 } },
	},
	golfclubs = {
		{ 100, { name = "golfclubs", max = 1 } },
	},
	tv = {
		{ 100, { name = "tv", max = 1 } },
	},
	['house_art'] = {
		{ 100, { name = "house_art", max = 1 } },
	},
	['big_tv'] = {
		{ 100, { name = "big_tv", max = 1 } },
	},
	boombox = {
		{ 100, { name = "boombox", max = 1 } },
	},
	microwave = {
		{ 100, { name = "microwave", max = 1 } },
	},
	pc = {
		{ 100, { name = "pc", max = 1 } },
	},
}

function StartAlarmCheck(joiner)
	if
		_robbers[joiner] ~= nil
		and not _robbers[joiner].threading
		and (not _robbers[joiner].nodes.states.alarm.disabled and not _robbers[joiner].nodes.states.alarm.triggered)
	then
		_robbers[joiner].threading = false
		_robbers[joiner].expires = os.time() + (60 * 4)

		if _robbers[joiner].tier >= 5 then
			_robbers[joiner].expires = os.time() + (60 * 3)
		end

		CreateThread(function()
			while
				_robbers[joiner] ~= nil
				and _robbers[joiner].nodes ~= nil
				and (
					not _robbers[joiner].nodes.states.alarm.disabled
					and not _robbers[joiner].nodes.states.alarm.triggered
				)
			do
				if
					_robbers[joiner].nodes.chances.alarm
					and os.time() > _robbers[joiner].expires
					and (
						not _robbers[joiner].nodes.states.alarm.disabled
						and not _robbers[joiner].nodes.states.alarm.triggered
					)
				then
					exports['pulsar-labor']:SendWorkgroupEvent(joiner,
						string.format("HouseRobbery:Client:%s:AlarmTriggered", joiner))

					exports['pulsar-robbery']:TriggerPDAlert(joiner,
						vector3(_robbers[joiner].coords.x, _robbers[joiner].coords.y, _robbers[joiner].coords.z), "10-90",
						"House Alarm", {
							icon = 374,
							size = 0.9,
							color = 31,
							duration = (60 * 5),
						})
					return
				end
				Wait(10000)
			end
		end)
	end
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	if GlobalState[string.format("%s:RobbingHouse", source)] ~= nil then
		GlobalState[string.format("%s:RobbingHouse", source)] = nil
	end
end)

AddEventHandler("Labor:Server:Startup", function()
	RegisterItems()

	--SetupHouseData()

	exports['pulsar-core']:WaitListCreate("houserobbery", "individual_time", {
		event = "Labor:Server:HouseRobbery:Queue",
		delay = (1000 * 60) * math.random(2, 5),
	})

	GlobalState["Robbery:InProgress"] = {}

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:Enable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if not hasValue(states, "SCRIPT_HOUSE_ROBBERY") then
			table.insert(states, "SCRIPT_HOUSE_ROBBERY")
			char:SetData("States", states)
			exports['pulsar-phone']:NotificationAdd(
				source,
				"New Job Available",
				"A new job is available, check it out.",
				os.time(),
				6000,
				"labor",
				{}
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:Disable", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local states = char:GetData("States") or {}
		if hasValue(states, "SCRIPT_HOUSE_ROBBERY") then
			for k, v in ipairs(states) do
				if v == "SCRIPT_HOUSE_ROBBERY" then
					table.remove(states, k)
					char:SetData("States", states)
					break
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:ArrivedNear", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			if
				char:GetData("TempJob") == _JOB
				and _joiners[source] ~= nil
				and _robbers[_joiners[source]] ~= nil
				and _robbers[_joiners[source]].state == 1
			then
				_robbers[_joiners[source]].state = 2
				exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Break into the house")
				exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
					string.format("HouseRobbery:Client:%s:Near", _joiners[source]), _robbers[_joiners[source]].coords)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:BreakIn", function(source, data, cb)
		if _robbers[_joiners[source]].state == 4 then
			exports['pulsar-pwnzor']:TempPosIgnore(source)
			local routeId = exports["pulsar-core"]:RequestRouteId(
				"Robbery:Properties:" .. _robbers[_joiners[source]].property, false)
			exports["pulsar-core"]:AddPlayerToRoute(source, routeId)
			GlobalState[string.format("%s:RobbingHouse", source)] = data

			local intr = HouseRobberyInteriors[_robbers[_joiners[source]].tier]
			exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
				string.format("HouseRobbery:Client:%s:InnerStuff", _joiners[source]), intr)

			Player(source).state.tpLocation = {
				x = _robbers[_joiners[source]].coords.x,
				y = _robbers[_joiners[source]].coords.y,
				z = _robbers[_joiners[source]].coords.z,
			}

			if
				_robbers[_joiners[source]].nodes.chances.alarm
				and os.time() > _robbers[_joiners[source]].expires
				and (
					not _robbers[_joiners[source]].nodes.states.alarm.disabled
					and not _robbers[_joiners[source]].nodes.states.alarm.triggered
				)
			then
				exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
					string.format("HouseRobbery:Client:%s:AlarmTriggered", _joiners[source]))
			end

			_robbers[_joiners[source]].inside += 1

			cb(true, { x = intr.x, y = intr.y, z = intr.z, h = intr.h }, intr.exit)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:Exit", function(source, data, cb)
		exports['pulsar-pwnzor']:TempPosIgnore(source)
		local intr = nil
		if _joiners[source] and _robbers[_joiners[source]] then
			intr = HouseRobberyInteriors[_robbers[_joiners[source]].tier]
		end

		cb(GlobalState[string.format("%s:RobbingHouse", source)], intr)
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)

		Wait(300)

		if _joiners[source] ~= nil and _robbers[_joiners[source]] ~= nil and _robbers[_joiners[source]].state == 5 then
			if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
				_robbers[_joiners[source]].state = 6
				Wait(1000)
				exports['pulsar-labor']:ManualFinishOffer(_joiners[source], _JOB)
			end
		elseif _joiners[source] ~= nil and _robbers[_joiners[source]] ~= nil and _robbers[_joiners[source]].state == 4 then
			_robbers[_joiners[source]].inside -= 1
		end

		Player(source).state.tpLocation = nil
		GlobalState[string.format("%s:RobbingHouse", source)] = nil
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:HackAlarm", function(source, data, cb)
		if
			_joiners[source] ~= nil
			and _robbers[_joiners[source]] ~= nil
			and _robbers[_joiners[source]].state == 4
			and (
				not _robbers[_joiners[source]].nodes.states.alarm.disabled
				and not _robbers[_joiners[source]].nodes.states.alarm.triggered
			)
		then
			if data.state then
				_robbers[_joiners[source]].nodes.states.alarm.disabled = true
				exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
					string.format("HouseRobbery:Client:%s:AlarmHacked", _joiners[source]))
			else
				_robbers[_joiners[source]].nodes.states.alarm.triggered = true
				exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
					string.format("HouseRobbery:Client:%s:AlarmTriggered", _joiners[source]))

				exports['pulsar-robbery']:TriggerPDAlert(source, _robbers[_joiners[source]].coords, "10-90",
					"House Alarm", {
						icon = 374,
						size = 0.9,
						color = 31,
						duration = (60 * 5),
					})
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("HouseRobbery:Search", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if
			char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _robbers[_joiners[source]] ~= nil
			and _robbers[_joiners[source]].state == 4
			and not _robbers[_joiners[source]].nodes.searched[data]
		then
			_robbers[_joiners[source]].nodes.searched[data] = true
			exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
				string.format("HouseRobbery:Client:%s:Action", _joiners[source]),
				data)

			local intr = HouseRobberyInteriors[_robbers[_joiners[source]].tier]
			if intr?.robberies?.locations then
				local lootType = intr.robberies.locations[data] and intr.robberies.locations[data].type or "standard"
				local lootTable = _loot[lootType] or _loot["standard"]
				exports.ox_inventory:LootCustomWeightedSetWithCount(lootTable, char:GetData("SID"), 1)

				if math.random(100) <= 5 then
					exports.ox_inventory:AddItem(char:GetData("SID"), "safecrack_kit", 1, {}, 1)
				end
			end

			if exports['pulsar-labor']:UpdateOffer(_joiners[source], _JOB, 1, true) then
				_robbers[_joiners[source]].state = 5
				exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
					string.format("HouseRobbery:Client:%s:EndRobbery", _joiners[source]))
				if _robbers[_joiners[source]].isWorkgroup then
					exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Leave The House",
						_robbrs[_joiners[source]].inside)
				else
					exports['pulsar-labor']:StartOffer(_joiners[source], _JOB, "Leave The House", 1)
				end
			end
		end
	end)
end)

function RegisterItems()
	exports.ox_inventory:RegisterUse("lockpick", "Robbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if
			char
			and char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _robbers[_joiners[source]] ~= nil
			and _robbers[_joiners[source]].state == 2
		then
			if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 then
				local dist = #(GetEntityCoords(GetPlayerPed(source)) - vector3(_robbers[_joiners[source]].coords.x, _robbers[_joiners[source]].coords.y, _robbers[_joiners[source]].coords.z))

				if dist <= 3.0 then
					if s ~= nil and s > os.time() then
						exports['pulsar-hud']:Notification(source, "error",
							"You Notice The Door Lock Has Been Damaged",
							6000
						)
					else
						_robbers[_joiners[source]].state = 3
						exports["pulsar-core"]:ClientCallback(
							source,
							"HouseRobbery:Lockpick",
							{ property = _robbers[_joiners[source]].property, tier = _robbers[_joiners[source]].tier },
							function(success)
								local newValue = slot.CreateDate - (60 * 60 * 24)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
								end
								if (os.time() - itemData.durability >= newValue) then
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
								else
									exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
								end

								local tier = _robbers[_joiners[source]].tier
								if success then
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", tier)
									exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
										string.format("HouseRobbery:Client:%s:Lockpicked", _joiners[source]),
										_robbers[_joiners[source]].nodes)

									exports['pulsar-labor']:StartOffer(
										_joiners[source],
										_JOB,
										"Search Areas",
										#HouseRobberyInteriors[tier].robberies.locations
									)

									if _robbers[_joiners[source]].nodes.chances.alarm then
										StartAlarmCheck(_joiners[source])
									end

									_robbers[_joiners[source]].state = 4
								else
									_robbers[_joiners[source]].state = 2
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", tier * 2)
								end
							end
						)
					end
				end
			else
			end
		end
	end)

	exports.ox_inventory:RegisterUse("adv_lockpick", "Robbery", function(source, slot, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if
			char
			and char:GetData("TempJob") == _JOB
			and _joiners[source] ~= nil
			and _robbers[_joiners[source]] ~= nil
			and _robbers[_joiners[source]].state == 2
		then
			if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 then
				local dist = #(GetEntityCoords(GetPlayerPed(source)) - vector3(_robbers[_joiners[source]].coords.x, _robbers[_joiners[source]].coords.y, _robbers[_joiners[source]].coords.z))

				if dist <= 3.0 then
					if s ~= nil and s > os.time() then
						exports['pulsar-hud']:Notification(source, "error",
							"You Notice The Door Lock Has Been Damaged",
							6000
						)
					else
						_robbers[_joiners[source]].state = 3
						exports["pulsar-core"]:ClientCallback(
							source,
							"HouseRobbery:AdvLockpick",
							{ property = _robbers[_joiners[source]].property, tier = _robbers[_joiners[source]].tier },
							function(success)
								local newValue = slot.CreateDate - (60 * 60 * 24)
								if success then
									newValue = slot.CreateDate - (60 * 60 * 12)
								end
								if (os.time() - itemData.durability >= newValue) then
									exports.ox_inventory:RemoveId(slot.Owner, slot.invType, slot)
								else
									exports.ox_inventory:SetItemCreateDate(slot.id, newValue)
								end

								local tier = _robbers[_joiners[source]].tier
								if success then
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", tier)
									exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
										string.format("HouseRobbery:Client:%s:Lockpicked", _joiners[source]),
										_robbers[_joiners[source]].nodes)

									exports['pulsar-labor']:StartOffer(
										_joiners[source],
										_JOB,
										"Search Areas",
										#HouseRobberyInteriors[tier].robberies.locations
									)

									if _robbers[_joiners[source]].nodes.chances.alarm then
										StartAlarmCheck(_joiners[source])
									end

									_robbers[_joiners[source]].state = 4
								else
									_robbers[_joiners[source]].state = 2
									exports['pulsar-status']:Add(source, "PLAYER_STRESS", tier * 2)
								end
							end
						)
					end
				end
			else
			end
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItems()
	end
end)

AddEventHandler("Labor:Server:HouseRobbery:Breach", function(source, house)
	local h = GlobalState[string.format("Robbery:InProgress:%s", house)]
	if h then
		local hData = HouseRobberyProperties[house]
		exports['pulsar-pwnzor']:TempPosIgnore(source)

		local routeId = exports["pulsar-core"]:RequestRouteId("Robbery:Properties:" .. house, false)
		exports["pulsar-core"]:AddPlayerToRoute(source, routeId)

		GlobalState[string.format("%s:RobbingHouse", source)] = house

		local intr = HouseRobberyInteriors[hData.tier]

		Player(source).state.tpLocation = {
			x = hData.coords.x,
			y = hData.coords.y,
			z = hData.coords.z,
		}

		TriggerClientEvent("HouseRobbery:Client:Breach", source, { x = intr.x, y = intr.y, z = intr.z, h = intr.h },
			intr.exit)
	end
end)

AddEventHandler("Labor:Server:HouseRobbery:Queue", function(source, data)
	if _joiners[source] ~= nil and _robbers[_joiners[source]] ~= nil then
		local house = nil

		local maxTier = _robbers[_joiners[source]].maxTier or 1
		if maxTier > 4 then
			if math.random(100) >= 80 then
				maxTier = 5
			else
				maxTier = 4
			end
		end

		local minTier = maxTier - 1
		if math.random(100) >= 70 or minTier < 1 then
			minTier = 1
		end

		while house == nil or _inProgress[house] ~= nil do
			local rand = math.random(#HouseRobberyProperties)
			local d = HouseRobberyProperties[rand]

			if maxTier >= d.tier and d.tier >= minTier then
				house = rand
			end

			Wait(1)
		end

		local pData = HouseRobberyProperties[house]
		local intr = HouseRobberyInteriors[pData.tier]

		_inProgress[house] = true

		local c = GlobalState["Robbery:InProgress"]
		table.insert(c, house)
		GlobalState["Robbery:InProgress"] = c

		GlobalState[string.format("Robbery:InProgress:%s", house)] = pData.coords

		_robbers[_joiners[source]].inside = 0

		_robbers[_joiners[source]].tier = pData.tier
		_robbers[_joiners[source]].coords = pData.coords
		_robbers[_joiners[source]].property = house

		_robbers[_joiners[source]].state = 1

		local pdo = ((GlobalState["Duty:police"] or 0) * 2)
		if pdo > 8 then
			pdo = 15
		end

		local exp = os.time() + (60 * 45) - pdo
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			_cooldowns[_robbers[source].tier][char:GetData("ID")] = exp
		end
		if _robbers[source].isWorkgroup then
			if #_robbers[source].members > 0 then
				for k, v in ipairs(_robbers[source].members) do
					_cooldowns[_robbers[source].tier][v.CharID] = exp
				end
			end
		end

		local alarmChance = math.random(100)
		local ownerChance = math.random(100)
		local t = {
			started = os.time(),
			opened = false,
			chances = {
				alarm = alarmChance <= intr.robberies.effects.alarm,
				owner = ownerChance <= intr.robberies.effects.owner,
			},
			states = {
				alarm = {
					disabled = false,
					triggered = false,
				},
				owner = {},
			},
			points = {},
			searched = {},
		}

		if t.chances.owner then
			local p = CreatePed(
				5,
				PedModels[math.random(#PedModels)],
				intr.robberies.pois.owner.coords.x,
				intr.robberies.pois.owner.coords.y,
				intr.robberies.pois.owner.coords.z,
				intr.robberies.pois.owner.heading,
				true,
				true
			)
			local id = exports["pulsar-core"]:RequestRouteId(string.format("Robbery:Properties:%s", house))

			local w = Weapons[math.random(#Weapons)]

			GiveWeaponToPed(p, w, 250, false, true)
			SetCurrentPedWeapon(p, w, true)
			SetEntityRoutingBucket(p, id)
			SetPedArmour(p, 200)
			TaskCombatPed(p, GetPlayerPed(source), 0, 16)

			-- exports['pulsar-robbery']:TriggerPDAlert(joiner, intr.locations.front, "000", "House Alarm", {
			-- 	icon = 374,
			-- 	size = 0.9,
			-- 	color = 31,
			-- 	duration = (60 * 5),
			-- })

			t.ownerPed = p
		end

		for k, v in ipairs(intr.robberies.locations) do
			t.points[k] = false
		end

		_robbers[_joiners[source]].nodes = t

		exports['pulsar-phone']:NotificationAdd(
			_robbers[_joiners[source]].joiner,
			"Job Activity",
			"You've Received A Contract",
			os.time(),
			6000,
			"labor",
			{}
		)
		if _robbers[_joiners[source]].isWorkgroup then
			if #_robbers[_joiners[source]].members > 0 then
				for k, v in ipairs(_robbers[_joiners[source]].members) do
					exports['pulsar-phone']:NotificationAdd(
						v.ID,
						"Job Activity",
						"You've Received A Contract",
						os.time(),
						6000,
						"labor",
						{}
					)
				end
			end
		end

		_offers[_joiners[source]].noExpire = false
		exports['pulsar-labor']:TaskOffer(_joiners[source], _JOB, "Go To The Location")
		exports['pulsar-labor']:SendWorkgroupEvent(_joiners[source],
			string.format("HouseRobbery:Client:%s:Receive", _joiners[source]),
			house, pData)
	end

	exports['pulsar-core']:WaitListInteractRemove("houserobbery", source)
end)

AddEventHandler("HouseRobbery:Server:OnDuty", function(joiner, members, isWorkgroup)
	local char = exports['pulsar-characters']:FetchCharacterSource(joiner)

	if char == nil then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		return
	end

	local level = exports['pulsar-characters']:RepGetLevel(joiner, "HouseRobbery") + 1
	while (_cooldowns[level][char:GetData("ID")] or 0) > os.time() and level > 1 do
		level = level - 1
	end

	if (_cooldowns[level][char:GetData("ID")] or 0) > os.time() and level == 1 then
		exports['pulsar-labor']:CancelOffer(joiner, _JOB)
		exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
		exports['pulsar-phone']:NotificationAdd(
			joiner,
			"Job Activity",
			"You're Not Eligible For Any Available Contracts",
			os.time(),
			6000,
			"labor",
			{}
		)
		if isWorkgroup then
			if #members > 0 then
				for k, v in ipairs(members) do
					exports['pulsar-phone']:NotificationAdd(
						v.ID,
						"Job Activity",
						"Your Group Is Not Eligible For Any Available Contracts. Please Wait",
						os.time(),
						6000,
						"labor",
						{}
					)
				end
			end
		end
		return
	elseif isWorkgroup then
		if #members > 0 then
			for k, v in ipairs(members) do
				local gChar = exports['pulsar-characters']:FetchCharacterSource(v.ID)
				if (_cooldowns[level][v.CharID] or 0) > os.time() and level == 1 then
					exports['pulsar-labor']:CancelOffer(joiner, _JOB)
					exports['pulsar-labor']:OffDuty(_JOB, joiner, false, true)
					exports['pulsar-phone']:NotificationAdd(
						joiner,
						"Job Activity",
						"Your Group Is Not Eligible For Any Available Contracts. Please Wait",
						os.time(),
						6000,
						"labor",
						{}
					)
					if isWorkgroup then
						if #members > 0 then
							for k2, v2 in ipairs(members) do
								if v.ID == v2.ID then
									exports['pulsar-phone']:NotificationAdd(
										v2.ID,
										"Job Activity",
										"You're Not Eligible For Any Available Contracts. Please Wait",
										os.time(),
										6000,
										"labor",
										{}
									)
								else
									exports['pulsar-phone']:NotificationAdd(
										v2.ID,
										"Job Activity",
										"Your Group Is Not Eligible For Any Available Contracts. Please Wait",
										os.time(),
										6000,
										"labor",
										{}
									)
								end
							end
						end
					end
					return
				end
			end
		end
	end

	_joiners[joiner] = joiner
	_robbers[joiner] = {
		joiner = joiner,
		members = members,
		isWorkgroup = isWorkgroup,
		maxTier = math.min(level, 5), -- TODO: Add Level 4+ Houses
		started = os.time(),
		state = 0,
	}

	char:SetData("TempJob", _JOB)
	TriggerClientEvent("HouseRobbery:Client:OnDuty", joiner, joiner, os.time())

	exports['pulsar-labor']:TaskOffer(joiner, _JOB, "Wait For A Contract")
	_offers[joiner].noExpire = true
	if #members > 0 then
		for k, v in ipairs(members) do
			_joiners[v.ID] = joiner
			local member = exports['pulsar-characters']:FetchCharacterSource(v.ID)
			member:SetData("TempJob", _JOB)
			TriggerClientEvent("HouseRobbery:Client:OnDuty", v.ID, joiner, os.time())
		end
	end

	exports['pulsar-core']:WaitListInteractAdd("houserobbery", joiner, {
		joiner = joiner,
	})
end)

AddEventHandler("HouseRobbery:Server:OffDuty", function(source, joiner)
	exports['pulsar-core']:WaitListInteractRemove("houserobbery", _joiners[source])
	_joiners[source] = nil
	TriggerClientEvent("HouseRobbery:Client:OffDuty", source)
end)

AddEventHandler("HouseRobbery:Server:FinishJob", function(joiner)
	local house = _robbers[joiner].property
	_inProgress[house] = nil
	--GlobalState[string.format("Robbery:InProgress:%s", house)] = nil

	_robbers[joiner] = nil
end)
