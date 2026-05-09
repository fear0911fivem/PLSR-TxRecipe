local _lb = RobberyConfig.lombank

function LBNeedsReset()
	for k, v in pairs(_lb.thermitePoints) do
		if not exports['ox_doorlock']:IsLocked(v.door) then
			return true
		end
	end

	for k, v in pairs(_lb.hackPoints) do
		if not exports['ox_doorlock']:IsLocked(v.door) then
			return true
		end
	end

	for k, v in ipairs(_lb.upperVaultPoints) do
		if
			GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)] ~= nil
			and GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)] > GetCloudTimeAsInt()
		then
			return true
		end
	end

	return false
end

function IsLBPowerDisabled()
	for k, v in ipairs(_lb.powerBoxes) do
		if
			not GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
			or GetCloudTimeAsInt() > GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
		then
			return false
		end
	end
	return true
end

AddEventHandler("Robbery:Client:Setup", function()
	exports['pulsar-polyzone']:CreatePoly("dumbcunt", _lb.polyZones.death.vertices, _lb.polyZones.death.options, _lb.polyZones.death.data)

	exports['pulsar-polyzone']:CreatePoly("bank_lombank", _lb.polyZones.bank.vertices, _lb.polyZones.bank.options)

	exports['pulsar-polyzone']:CreatePoly("lombank_power", _lb.polyZones.power.vertices, _lb.polyZones.power.options, _lb.polyZones.power.data)

	exports.ox_target:addBoxZone({
		id = "lombank_secure",
		coords = _lb.secureZone.coords,
		size = vector3(_lb.secureZone.length, _lb.secureZone.width, 2.0),
		rotation = _lb.secureZone.options.heading,
		debug = false,
		minZ = _lb.secureZone.options.minZ,
		maxZ = _lb.secureZone.options.maxZ,
		options = {
			{
				icon = "fas fa-lock",
				label = "Secure Bank",
				event = "Robbery:Client:Lombank:StartSecuring",
				groups = { "police" },
				canInteract = LBNeedsReset,
			},
		}
	})

	exports['pulsar-polyzone']:CreateBox("lombank_death", _lb.deathBox.coords, _lb.deathBox.length, _lb.deathBox.width, _lb.deathBox.options, _lb.deathBox.data)

	for k, v in ipairs(_lb.rooms) do
		exports['pulsar-polyzone']:CreateBox(string.format("lombank_room_%s", v.roomId), v.coords, v.length, v.width,
			v.options, {
				isLombankRoom = true,
				roomId = v.roomId,
			})
	end

	for k, v in ipairs(_lb.powerBoxes) do
		exports.ox_target:addBoxZone({
			id = string.format("lombank_power_%s", v.data.boxId),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = v.isThermite
				and {
					{
						icon = "fas fa-fire",
						label = "Use Thermite",
						item = "thermite",
						boxId = v.data.boxId,
						onSelect = function()
							TriggerEvent("Robbery:Client:Lombank:ElectricBox:Thermite", v.data)
						end,
						canInteract = function()
							return not GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
								or GetCloudTimeAsInt()
								> GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
						end,
					},
				}
				or {
					{
						icon = "fas fa-terminal",
						label = "Hack Power Interface",
						item = "adv_electronics_kit",
						boxId = v.data.boxId,
						onSelect = function()
							TriggerEvent("Robbery:Client:Lombank:ElectricBox:Hack", v.data)
						end,
						canInteract = function()
							return not GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
								or GetCloudTimeAsInt() > GlobalState[string.format("Lombank:Power:%s", v.data.boxId)]
						end,
					},
				}
		})
	end

	for k, v in ipairs(_lb.upperVaultPoints) do
		exports.ox_target:addBoxZone({
			id = string.format("lombank_upper_%s", v.wallId),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-drill",
					label = "Use Drill",
					item = "drill",
					wallId = v.wallId,
					onSelect = function(data)
						TriggerEvent("Robbery:Client:Lombank:Drill", data.wallId)
					end,
					canInteract = function()
						return not GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)]
							or GetCloudTimeAsInt() > GlobalState[string.format("Lombank:Upper:Wall:%s", v.wallId)]
					end,
				},
			}
		})
	end
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if type(data) == "table" then
		if data.isDeath then
			if not data.door or exports['ox_doorlock']:IsLocked(data.door) then
				exports['pulsar-damage']:ApplyStandardDamage(10000, false, true)
				TriggerServerEvent("Robbery:Server:Idiot", id)
				if data.tpCoords ~= nil then
					ClearPedTasksImmediately(PlayerPedId())
					Wait(100)
					SetEntityCoords(PlayerPedId(), data.tpCoords.x, data.tpCoords.y, data.tpCoords.z, 0, 0, 0, false)
				end
			end
		end
	end

	if id == "bank_lombank" then
		LocalPlayer.state:set("inLombankPower", false, true)
		LocalPlayer.state:set("inLombank", true, true)
	elseif id == "lombank_power" then
		LocalPlayer.state:set("inLombank", false, true)
		LocalPlayer.state:set("inLombankPower", true, true)
	elseif data.isLombankRoom then
		LocalPlayer.state:set("inLombankPower", false, true)
		LocalPlayer.state:set("lombankRoom", data.roomId, true)
		for k, v in ipairs(_lb.carts) do
			exports.ox_target:addModel(v, {
				{
					label = "Grab Loot",
					icon = "fas fa-hand-paper",
					onSelect = function(entity)
						TriggerEvent("Robbery:Client:Lombank:LootCart", entity, data.roomId)
					end,
					distance = 2.0,
					canInteract = function(d, entity)
						local coords = GetEntityCoords(entity.entity)
						return not exports['ox_doorlock']:IsLocked("lombank_lower_gate")
							and not exports['ox_doorlock']:IsLocked("lombank_lower_vault")
							and not exports['ox_doorlock']:IsLocked(string.format("lombank_lower_room_%s", data.roomId))
							and GlobalState[string.format(
								"Lombank:VaultRoom:%s:%s:%s",
								d,
								math.ceil(coords.x),
								math.ceil(coords.y)
							)] == nil
							and not Entity(entity.entity).state.looted
					end,
				},
			})
		end
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "bank_lombank" then
		if LocalPlayer.state.inLomBank then
			LocalPlayer.state:set("inLombank", false, true)
		end
	elseif id == "lombank_power" then
		if LocalPlayer.state.inLombankPower then
			LocalPlayer.state:set("inLombankPower", false, true)
		end
	elseif data.isLombankRoom then
		if LocalPlayer.state.lombankRoom then
			LocalPlayer.state:set("lombankRoom", false, true)
		end
		for k, v in ipairs(_lb.carts) do
			exports.ox_target:removeModel(v)
		end
	end
end)

AddEventHandler("Robbery:Client:Lombank:StartSecuring", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "secure_lombank",
		duration = 30000,
		label = "Securing",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "cop3",
		},
	}, function(status)
		if not status then
			exports["pulsar-core"]:ServerCallback("Robbery:Lombank:SecureBank", {})
		end
	end)
end)

AddEventHandler("Robbery:Client:Lombank:ElectricBox:Hack", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Lombank:ElectricBox:Hack", data, function() end)
end)

AddEventHandler("Robbery:Client:Lombank:ElectricBox:Thermite", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Lombank:ElectricBox:Thermite", data, function() end)
end)

AddEventHandler("Robbery:Client:Lombank:Drill", function(wallId)
	exports["pulsar-core"]:ServerCallback("Robbery:Lombank:Drill", wallId, function() end)
end)

AddEventHandler("Robbery:Client:Lombank:LootCart", function(entity, roomId)
	exports["pulsar-core"]:ServerCallback(
		"Robbery:Lombank:Vault:StartLootTrolley",
		{ coords = GetEntityCoords(entity.entity), roomId = roomId },
		function(valid)
			if valid then
				local CashAppear = function()
					RequestModel(GetHashKey("ch_prop_gold_bar_01a"))
					while not HasModelLoaded(GetHashKey("ch_prop_gold_bar_01a")) do
						Wait(1)
					end
					local grabobj = CreateObject(GetHashKey("ch_prop_gold_bar_01a"), myCoords, true)

					FreezeEntityPosition(grabobj, true)
					SetEntityInvincible(grabobj, true)
					SetEntityNoCollisionEntity(grabobj, LocalPlayer.state.ped)
					SetEntityVisible(grabobj, false, false)
					AttachEntityToEntity(
						grabobj,
						LocalPlayer.state.ped,
						GetPedBoneIndex(LocalPlayer.state.ped, 60309),
						0.0,
						0.0,
						0.0,
						0.0,
						0.0,
						0.0,
						false,
						false,
						false,
						false,
						0,
						true
					)
					local startedGrabbing = GetGameTimer()

					CreateThread(function()
						while GetGameTimer() - startedGrabbing < 37000 do
							Wait(1)
							DisableControlAction(0, 73, true)
							if HasAnimEventFired(LocalPlayer.state.ped, GetHashKey("CASH_APPEAR")) then
								if not IsEntityVisible(grabobj) then
									SetEntityVisible(grabobj, true, false)
								end
							end
							if HasAnimEventFired(LocalPlayer.state.ped, GetHashKey("RELEASE_CASH_DESTROY")) then
								if IsEntityVisible(grabobj) then
									SetEntityVisible(grabobj, false, false)
									--TODO Trigger loot
								end
							end
						end
						DeleteObject(grabobj)
					end)
				end

				local baghash = GetHashKey("hei_p_m_bag_var22_arm_s")

				local coords = GetOffsetFromEntityInWorldCoords(LocalPlayer.state.ped, 0.0, 0.0, -0.5)
				local rot = GetEntityRotation(LocalPlayer.state.ped)

				RequestAnimDict("anim@heists@ornate_bank@grab_cash")
				RequestModel(baghash)
				while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(baghash) do
					Wait(100)
				end

				local GrabBag = CreateObject(
					GetHashKey("hei_p_m_bag_var22_arm_s"),
					GetEntityCoords(PlayerPedId()),
					true,
					false,
					false
				)
				local Grab1 = NetworkCreateSynchronisedScene(
					coords,
					rot.x,
					rot.y,
					rot.z + 180.0,
					2,
					false,
					false,
					1065353216,
					0,
					1.3
				)
				NetworkAddPedToSynchronisedScene(
					LocalPlayer.state.ped,
					Grab1,
					"anim@heists@ornate_bank@grab_cash",
					"intro",
					1.5,
					-4.0,
					1,
					16,
					1148846080,
					0
				)
				NetworkAddEntityToSynchronisedScene(
					GrabBag,
					Grab1,
					"anim@heists@ornate_bank@grab_cash",
					"bag_intro",
					4.0,
					-8.0,
					1
				)
				--SetPedComponentVariation(LocalPlayer.state.ped, 5, 0, 0, 0)
				NetworkStartSynchronisedScene(Grab1)
				Wait(1500)
				CashAppear()
				local Grab2 = NetworkCreateSynchronisedScene(
					coords,
					rot.x,
					rot.y,
					rot.z + 180.0,
					2,
					false,
					false,
					1065353216,
					0,
					1.3
				)
				NetworkAddPedToSynchronisedScene(
					LocalPlayer.state.ped,
					Grab2,
					"anim@heists@ornate_bank@grab_cash",
					"grab",
					1.5,
					-4.0,
					1,
					16,
					1148846080,
					0
				)
				NetworkAddEntityToSynchronisedScene(
					GrabBag,
					Grab2,
					"anim@heists@ornate_bank@grab_cash",
					"bag_grab",
					4.0,
					-8.0,
					1
				)
				NetworkStartSynchronisedScene(Grab2)
				Wait(37000)
				local Grab3 = NetworkCreateSynchronisedScene(
					coords,
					rot.x,
					rot.y,
					rot.z + 180.0,
					2,
					false,
					false,
					1065353216,
					0,
					1.3
				)
				NetworkAddPedToSynchronisedScene(
					LocalPlayer.state.ped,
					Grab3,
					"anim@heists@ornate_bank@grab_cash",
					"exit",
					1.5,
					-4.0,
					1,
					16,
					1148846080,
					0
				)
				NetworkAddEntityToSynchronisedScene(
					GrabBag,
					Grab3,
					"anim@heists@ornate_bank@grab_cash",
					"bag_exit",
					4.0,
					-8.0,
					1
				)
				NetworkStartSynchronisedScene(Grab3)

				exports["pulsar-core"]:ServerCallback(
					"Robbery:Lombank:Vault:FinishLootTrolley",
					{ coords = GetEntityCoords(entity.entity) }
				)
				Entity(entity.entity).state:set("looted", true, true)
				Wait(1800)
				if DoesEntityExist(GrabBag) then
					DeleteEntity(GrabBag)
				end
				--SetPedComponentVariation(LocalPlayer.state.ped, 5, 45, 0, 0)
				RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
				SetModelAsNoLongerNeeded(GetHashKey("hei_p_m_bag_var22_arm_s"))
			end
		end
	)
end)
