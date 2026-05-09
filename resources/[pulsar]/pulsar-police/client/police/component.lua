local policeStationBlips = Config.StationBlips

local _pdModels = {}
local _emsModels = {}

local lastTackle = 0

local _breached = {}

local policeDutyPoint = {
	{
		icon = "fas fa-clipboard-check",
		label = "Go On Duty",
		event = "Police:Client:OnDuty",
		groups = { "police" },
		reqOffDuty = true,
	},
	{
		icon = "fas fa-clipboard",
		label = "Go Off Duty",
		event = "Police:Client:OffDuty",
		groups = { "police" },
		reqDuty = true,
	},
	{
		icon = "fas fa-location-dot",
		label = "Re-Enable Tracker",
		event = "Police:Client:ReEnableTracker",
		canInteract = function()
			return LocalPlayer.state.trackerDisabled
		end,
	},
}

local _pdStationPolys = {
	{
		points = {
			vector2(419.16091918945, -966.34405517578),
			vector2(419.2200012207, -1016.196105957),
			vector2(409.74496459961, -1016.0508422852),
			vector2(410.03247070312, -1033.0327148438),
			vector2(489.80380249023, -1026.6353759766),
			vector2(488.85284423828, -966.38427734375),
		},
		options = {
			name = "pdstation_missionrow",
			minZ = 25.36417388916,
			maxZ = 45.414678573608,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(411.00393676758, -1661.6872558594),
			vector2(424.06509399414, -1645.6456298828),
			vector2(424.70223999023, -1640.4389648438),
			vector2(423.83392333984, -1627.9958496094),
			vector2(360.71951293945, -1574.7712402344),
			vector2(339.02374267578, -1600.73046875),
		},
		options = {
			name = "pdstation_davis",
			minZ = 25.36417388916,
			maxZ = 45.414678573608,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(818.44097900391, -1249.2879638672),
			vector2(836.80029296875, -1252.8927001953),
			vector2(860.4052734375, -1278.6043701172),
			vector2(862.82849121094, -1296.5511474609),
			vector2(877.03753662109, -1297.9116210938),
			vector2(878.47839355469, -1328.7099609375),
			vector2(878.81671142578, -1361.5606689453),
			vector2(848.46789550781, -1417.4731445312),
			vector2(816.15045166016, -1417.8415527344),
		},
		options = {
			name = "pdstation_popular",
			minZ = 25.36417388916,
			maxZ = 45.414678573608,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(1889.2142333984, 3691.6762695312),
			vector2(1851.7814941406, 3668.3894042969),
			vector2(1830.3732910156, 3704.9562988281),
			vector2(1868.1072998047, 3727.1462402344),
		},
		options = {
			name = "pdstation_sandy",
			minZ = 29.36417388916,
			maxZ = 49.414678573608,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(-442.38430786133, 6062.9243164062),
			vector2(-416.13342285156, 6005.0458984375),
			vector2(-415.57186889648, 5998.3540039062),
			vector2(-439.16738891602, 5975.2041015625),
			vector2(-449.66729736328, 5985.3481445312),
			vector2(-472.04858398438, 5963.1728515625),
			vector2(-500.68542480469, 5991.81640625),
			vector2(-478.4963684082, 6014.41796875),
			vector2(-488.33645629883, 6024.4272460938),
			vector2(-460.89733886719, 6051.8681640625),
		},
		options = {
			name = "pdstation_paleto",
			minZ = 29.36417388916,
			maxZ = 49.414678573608,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(-1102.2563476562, -273.6389465332),
			vector2(-1016.8302001953, -232.33473205566),
			vector2(-1040.9318847656, -211.10615539551),
			vector2(-1101.2906494141, -241.23860168457),
			vector2(-1111.4075927734, -247.7313079834)
		},
		options = {
			name = "pdstation_guardius",
			minZ = 25.0,
			maxZ = 67.4,
		},
		data = { pdstation = true },
	},
	{
		points = {
			vector2(-127.90340423584, -1157.5145263672),
			vector2(-128.29985046387, -1186.4349365234),
			vector2(-249.06109619141, -1184.8615722656),
			vector2(-247.67953491211, -1157.8649902344),
		},
		options = {
			name = "pdstation_impound",
			heading = 0,
			--debugPoly=true,
			minZ = 22.04,
			maxZ = 34.04
		},
		data = { pdstation = true },
	},
}

function loadModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(1)
	end
end

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		_pdModels = GlobalState["PoliceCars"]
		_emsModels = GlobalState["EMSCars"]

		exports['pulsar-hud']:InteractionRegisterMenu("police", false, "siren-on", function(data)
			exports['pulsar-hud']:InteractionShowMenu({
				{
					icon = "siren-on",
					label = "13-A",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerServerEvent("Police:Server:Panic", true)
					end,
					shouldShow = function()
						return LocalPlayer.state.isDead
					end,
				},
				{
					icon = "siren",
					label = "13-B",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerServerEvent("Police:Server:Panic", false)
					end,
					shouldShow = function()
						return LocalPlayer.state.isDead
					end,
				},
			})
		end, function()
			return LocalPlayer.state.onDuty == "police" and LocalPlayer.state.isDead
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("police-raid-biz", "Search Inventory", "magnifying-glass",
			function(data)
				exports['pulsar-hud']:InteractionHide()
				exports['pulsar-hud']:ProgressWithTickEvent({
					name = 'pd_raid_biz',
					duration = 8000,
					label = "Searching",
					tickrate = 250,
					useWhileDead = false,
					canCancel = true,
					vehicle = false,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableCombat = true,
					},
					animation = {
						animDict = "anim@gangops@facility@servers@bodysearch@",
						anim = "player_search",
						flags = 49,
					},
				}, function()
					if LocalPlayer.state.onDuty == "police" and not LocalPlayer.state.isDead and LocalPlayer.state._inInvPoly ~= nil then
						return
					end
					exports['pulsar-hud']:ProgressCancel()
				end, function(cancelled)
					_doing = false
					if not cancelled then
						exports["pulsar-core"]:ServerCallback("Inventory:Raid", LocalPlayer.state._inInvPoly.inventory,
							function(owner) end)
					end
				end)
			end, function()
				return LocalPlayer.state.onDuty == "police"
					and not LocalPlayer.state.isDead
					and LocalPlayer.state._inInvPoly ~= nil
					and LocalPlayer.state._inInvPoly?.business ~= nil
			end)

			exports['pulsar-hud']:InteractionRegisterMenu("pd-locked-veh", "Secured Compartment", "shield",
			    function(data)
			        exports['pulsar-hud']:InteractionHide()
			        exports['pulsar-hud']:Progress({
			            name = "pd_rack_prog",
			            duration = 2000,
			            label = "Unlocking Compartment",
			            useWhileDead = false,
			            canCancel = true,
			            animation = false,
			        }, function(status)
			            if not status then
			                exports["pulsar-core"]:ServerCallback("Police:AccessRifleRack")
			            end
			        end)
			    end, 
			    function()
			        local v = GetVehiclePedIsIn(LocalPlayer.state.ped)
			        return (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison") and
			            not LocalPlayer.state.isDead and v ~= 0 and _pdModels[GetEntityModel(v)] and
			            exports['pulsar-vehicles']:HasAccess(v)
			    end
			)

		exports['pulsar-hud']:InteractionRegisterMenu("police-utils", "Police Utilities", "tablet", function(data)
			exports['pulsar-hud']:InteractionShowMenu({
				{
					icon = "lock-open",
					label = "Slimjim Vehicle",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerServerEvent("Police:Server:Slimjim")
					end,
					shouldShow = function()
						local target = lib.getClosestVehicle(GetEntityCoords(cache.ped), 2.0, true)

						if not target or not DoesEntityExist(target) then
							return false
						end

						return IsEntityAVehicle(target)
					end,
				},
				{
					icon = "tablet-screen-button",
					label = "MDT",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerEvent("MDT:Client:Toggle")
					end,
					shouldShow = function()
						return LocalPlayer.state.onDuty == "police"
					end,
				},
				{
					icon = "video",
					label = "Toggle Body Cam",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						TriggerEvent("MDT:Client:ToggleBodyCam")
					end,
					shouldShow = function()
						return LocalPlayer.state.onDuty == "police"
					end,
				},
				{
					icon = "car-burst",
					label = "Start Pit Timer (5 Mins)",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						exports["pulsar-hud"]:Notification("success", "5 Minute Pit Timer", 60 * 1000 * 5, 'car-burst',
							{
								alert = {
									background = "#247BA5B3",
								},
								progress = {
									background = "#ffffff",
								},
							})

						SetTimeout(60 * 1000 * 5, function()
							exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET")
						end)
					end,
					shouldShow = function()
						return LocalPlayer.state.onDuty == "police"
					end,
				},
			})
		end, function()
			return LocalPlayer.state.onDuty == "police"
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("pd-breach", "Breach", "bomb", function(data)
			local prop = exports['pulsar-properties']:Get(data.propertyId)
			exports['pulsar-hud']:InteractionShowMenu({
				{
					icon = "house",
					label = "Breach Property",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						exports["pulsar-core"]:ServerCallback("Police:Breach", {
							type = "property",
							property = data.propertyId,
						}, function(s)
							if s then

							end
						end)
					end,
					shouldShow = function()
						return prop ~= nil and prop.sold
					end,
				},
				{
					icon = "window-frame-open",
					label = "Breach Apartment",
					action = function()
						exports['pulsar-hud']:InteractionHide()
						exports['pulsar-hud']:InputShow("Breaching", "Unit Number (Owner State ID)", {
							{
								id = "unit",
								type = "number",
								options = {},
							},
						}, "Police:Client:DoApartmentBreach", data.id)
					end,
					shouldShow = function()
						return exports['pulsar-apartments']:GetNearApartment()
					end,
				},
			})
		end, function()
			if LocalPlayer.state.onDuty and LocalPlayer.state.onDuty == "police" then
				return exports['pulsar-properties']:GetNearHouse() or exports['pulsar-apartments']:GetNearApartment()
			else
				return nil
			end
		end)

		exports['pulsar-hud']:InteractionRegisterMenu("pd-breach-robbery", "Breach House Robbery", "bomb",
			function(data)
				local bruh = GlobalState["Robbery:InProgress"]
				for k, v in ipairs(bruh) do
					local robberystatus = GlobalState[string.format("Robbery:InProgress:%s", v)]
					if robberystatus then
						local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(loc.x, loc.y, loc.z))
						if dist <= 3.0 then
							exports["pulsar-core"]:ServerCallback("Police:Breach", {
								type = "robbery",
								property = v,
							})

							return
						end
					end
				end
				exports['pulsar-hud']:InteractionHide()
			end, function()
				if LocalPlayer.state.onDuty and LocalPlayer.state.onDuty == "police" then
					local bruh = GlobalState["Robbery:InProgress"]
					for k, v in ipairs(bruh) do
						local robberystatus = GlobalState[string.format("Robbery:InProgress:%s", v)]
						if robberystatus then
							local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(loc.x, loc.y, loc.z))
							if dist <= 3.0 then
								return true
							end
						end
					end
				end
				return false
			end)

		exports["pulsar-core"]:RegisterClientCallback("Police:PanicButton", function(data, cb)
			exports['pulsar-hud']:Progress({
				name = "panic_button",
				duration = 2000,
				label = "Activating Panic Button",
				useWhileDead = true,
				canCancel = true,
				disarm = false,
				controlDisables = {
					disableMovement = false,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					-- animDict = "missfbi3_sniping",
					-- anim = "male_unarmed_b",
					animDict = "missfbi3_steve_phone",
					anim = "steve_phone_reaction",
					flags = 48,
				},
			}, function(cancelled)
				cb(cancelled)
			end)
		end)

		exports["pulsar-core"]:RegisterClientCallback("Police:Breach", function(data, cb)
			exports['pulsar-hud']:Progress({
				name = "breach_action",
				duration = 3000,
				label = "Breaching",
				useWhileDead = false,
				canCancel = true,
				disarm = false,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					animDict = "missprologuemcs_1",
					anim = "kick_down_player_zero",
					flags = 49,
				},
			}, function(cancelled)
				cb(not cancelled)
				if not cancelled then
					--exports["pulsar-sounds"]:PlayLocation(LocalPlayer.state.myPos, 20, "breach.ogg", 0.15)
				end
			end)
		end)

		local switchModels = {
			[`mp_m_freemode_01`] = true,
			[`mp_f_freemode_01`] = true,
		}
		exports["pulsar-core"]:RegisterClientCallback("Police:DoDetCord", function(data, cb)
			local closestDoor = exports.ox_doorlock:getClosestDoor()
			if closestDoor and closestDoor.state == 1 then -- state 1 means locked
				CreateThread(function()
					local playerPed = PlayerPedId()
					local playerPos = GetEntityCoords(playerPed, false)
					local doorPosition = playerPos + GetEntityForwardVector(playerPed)
					if #(playerPos - doorPosition) < 1.0 then
						print("To far away")
						return cb(false);
					end
					local raycast = StartShapeTestSweptSphere(playerPos.x, playerPos.y, playerPos.z, doorPosition.x,
						doorPosition.y, doorPosition.z, 0.2, 16, playerPed, 4)
					local retval, hit, endCoords, surfaceNormal, entity = GetShapeTestResult(raycast)

					-- Apparently This Can Happen Sometimes so better just setting to door coords instead of halfway across map
					if endCoords == vector3(0, 0, 0) then
						endCoords = closestDoor and closestDoor.coords or vector3(0, 0, 0)
					end

					-- Use ox_lib to load animation dictionary and model
					lib.requestAnimDict("anim@heists@ornate_bank@thermal_charge")
					lib.requestModel("hei_p_m_bag_var22_arm_s")
					
					local ped = PlayerPedId()
					Wait(100)
					local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(ped)))
					local bagscene = NetworkCreateSynchronisedScene(endCoords.x, endCoords.y, endCoords.z, rotx, roty,
						rotz, 2, false, false, 1065353216, 0, 1.3)
					NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge",
						"thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
					local curVar = 0
					if switchModels[GetEntityModel(PlayerPedId())] then
						GetPedDrawableVariation(ped, 5)
						SetPedComponentVariation(ped, 5, 0, 0, 0)
					end
					NetworkStartSynchronisedScene(bagscene)
					Wait(1500)
					local x, y, z = table.unpack(GetEntityCoords(ped))
					local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2, true, true, true)
					SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(bomba), false)
					SetEntityCollision(bomba, false, true)
					AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false,
						true, 1, true)
					Wait(4000)
					if curVar > 0 then
						SetPedComponentVariation(ped, 5, curVar, 0, 0)
					end
					DetachEntity(bomba, 1, 1)
					FreezeEntityPosition(bomba, true)
					NetworkStopSynchronisedScene(bagscene)
					lib.playAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1,
						0, 0, 0)
					lib.playAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 6000, 49, 1,
						0, 0, 0)
					exports["pulsar-core"]:ServerCallback("Robbery:DoThermiteFx", {
						delay = 7000,
						netId = ObjToNet(bomba)
					}, function() end)
					Wait(7000)

					exports["pulsar-core"]:ServerCallback("Robbery:DoDetCordFx", {
						x = endCoords.x,
						y = endCoords.y,
						z = endCoords.z,
						h = closestDoor and closestDoor.heading or 0.0,
					}, function() end)

					ClearPedTasks(ped)
					DeleteObject(bomba)
					cb(true, closestDoor and closestDoor.id or nil)
				end)
			end
		end)

		local _cuffCd = false
		exports["pulsar-kbs"]:Add("pd_cuff", "LBRACKET", "keyboard", "Police - Cuff", function()
			if LocalPlayer.state.Character ~= nil and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison") then
				if not _cuffCd then
					TriggerServerEvent("Police:Server:Cuff")
					_cuffCd = true
					SetTimeout(3000, function()
						_cuffCd = false
					end)
				end
			end
		end)

		exports["pulsar-kbs"]:Add("pd_uncuff", "RBRACKET", "keyboard", "Police - Uncuff", function()
			if LocalPlayer.state.Character ~= nil and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison") then
				if not _cuffCd then
					TriggerServerEvent("Police:Server:Uncuff")
					_cuffCd = true
					SetTimeout(3000, function()
						_cuffCd = false
					end)
				end
			end
		end)

		-- exports["pulsar-kbs"]:Add("pd_toggle_cuff", "", "keyboard", "Police - Cuff / Uncuff", function()
		-- 	if LocalPlayer.state.Character ~= nil and LocalPlayer.state.onDuty == "police" then
		-- 		if not _cuffCd then
		-- 			TriggerServerEvent("Police:Server:ToggleCuff")
		-- 			_cuffCd = true
		-- 			CreateThread(function()
		-- 				Wait(2000)
		-- 				_cuffCd = false
		-- 			end)
		-- 		end
		-- 	end
		-- end)

		exports["pulsar-kbs"]:Add("tackle", "", "keyboard", "Tackle", function()
			if LocalPlayer.state.Character ~= nil then
				if
					not LocalPlayer.state.isCuffed
					and not LocalPlayer.state.tpLocation
					and not IsPedInAnyVehicle(LocalPlayer.state.ped)
					and not LocalPlayer.state.playingCasino
				then
					if GetEntitySpeed(LocalPlayer.state.ped) > 2.0 then
						local cPlayer, dist = exports['pulsar-core']:GamePlayersGetClosestPlayer()
						local tarPlayer = GetPlayerServerId(cPlayer)
						if tarPlayer ~= 0 and dist <= 2.0 and GetGameTimer() - lastTackle > 7000 then
							lastTackle = GetGameTimer()
							TriggerServerEvent("Police:Server:Tackle", tarPlayer)

							loadAnimDict("swimming@first_person@diving")

							if
								IsEntityPlayingAnim(
									LocalPlayer.state.ped,
									"swimming@first_person@diving",
									"dive_run_fwd_-45_loop",
									3
								)
							then
								ClearPedSecondaryTask(LocalPlayer.state.ped)
							else
								-- TaskPlayAnim(
								-- 	LocalPlayer.state.ped,
								-- 	"swimming@first_person@diving",
								-- 	"dive_run_fwd_-45_loop",
								-- 	8.0,
								-- 	-8,
								-- 	-1,
								-- 	49,
								-- 	0,
								-- 	0,
								-- 	0,
								-- 	0
								-- )
								-- Wait(350)
								StupidRagdoll(true)
								-- ClearPedSecondaryTask(LocalPlayer.state.ped)
								-- SetPedToRagdoll(LocalPlayer.state.ped, 500, 500, 0, 0, 0, 0)
							end
						else
							--StupidRagdoll(true)
						end
					else
						--StupidRagdoll(false)
					end
				end
			end
		end)

		for _, zone in ipairs(Config.DutyZones) do
			exports.ox_target:addBoxZone({
				id       = zone.id,
				coords   = zone.coords,
				size     = zone.size,
				rotation = zone.rotation,
				debug    = false,
				minZ     = zone.minZ,
				maxZ     = zone.maxZ,
				options  = policeDutyPoint,
			})
		end

		for _, zone in ipairs(Config.ArmoryZones) do
			local shopId = zone.shop
			exports.ox_target:addBoxZone({
				id       = zone.id,
				coords   = zone.coords,
				size     = zone.size,
				rotation = zone.rotation,
				debug    = false,
				minZ     = zone.minZ,
				maxZ     = zone.maxZ,
				options  = {
					{
						icon     = "fas fa-box-open",
						label    = zone.label or "Police Armory",
						groups   = { "police" },
						reqDuty  = true,
						onSelect = function()
							TriggerServerEvent('ox_inventory:bridge:openShop', shopId)
						end,
					},
				},
			})
		end

		for k, v in ipairs(_pdStationPolys) do
			--print(v.options.name)
			exports['pulsar-polyzone']:CreatePoly(v.options.name, v.points, v.options, v.data)
		end

		exports["pulsar-core"]:RegisterClientCallback("Police:DeploySpikes", function(data, cb)
			exports['pulsar-hud']:ProgressWithStartEvent({
				name = "spikestrips",
				duration = 1000,
				label = "Laying Spikes",
				useWhileDead = false,
				canCancel = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
					anim = "plant_floor",
				},
				disarm = true,
			}, function()
				TriggerEvent('ox_inventory:disarm', LocalPlayer.state.ped, true)
			end, function(status)
				if not status then
					local h = GetEntityHeading(PlayerPedId())
					local positions = {}
					for i = 1, 3 do
						table.insert(
							positions,
							GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, -1.5 + (3.5 * i), 0.15)
						)
					end
					cb({
						positions = positions,
						h = h,
					})
				else
					cb(nil)
				end
			end)
		end)
	end
end)

AddEventHandler("Police:Client:DoApartmentBreach", function(values, data)
	exports["pulsar-core"]:ServerCallback("Police:Breach", {
		type = "apartment",
		property = tonumber(values.unit),
		id = data,
	}, function(s)
		if s then

		end
	end)
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	for k, v in ipairs(policeStationBlips) do
		exports["pulsar-blips"]:Add("police_station_" .. k, v.label or "Police Department", v.coords, 137, 38, 0.6)
	end
end)

RegisterNetEvent("Police:Client:Breached", function(type, id)
	_breached[type] = _breached[type] or {}
	_breached[type][id] = GetCloudTimeAsInt() + (60 * 5)
end)

RegisterNetEvent("Police:Client:GetTackled", function(s)
	if LocalPlayer.state.loggedIn then
		SetPedToRagdoll(LocalPlayer.state.ped, math.random(3000, 5000), math.random(3000, 5000), 0, 0, 0, 0)
		lastTackle = GetGameTimer()
	end
end)

exports('IsPdCar', function(entity)
	return _pdModels[GetEntityModel(entity)]
end)

exports('IsEMSCar', function(entity)
	return _emsModels[GetEntityModel(entity)]
end)

function StupidRagdoll(tackleAnim)
	local time = 3500
	if tackleAnim then
		TaskPlayAnim(
			LocalPlayer.state.ped,
			"swimming@first_person@diving",
			"dive_run_fwd_-45_loop",
			8.0,
			-8,
			-1,
			49,
			0,
			0,
			0,
			0
		)
		-- time = 1000
	end
	Wait(350)
	ClearPedSecondaryTask(LocalPlayer.state.ped)
	SetPedToRagdoll(LocalPlayer.state.ped, time, time, 0, 0, 0, 0)
end
