AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports['pulsar-hud']:InteractionRegisterMenu("prison", false, "siren-on", function(data)
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
			return LocalPlayer.state.onDuty == "prison" and LocalPlayer.state.isDead
		end)

		local lockdownOptions = {
			{
				icon = "lock",
				label = "Enable Lockdown",
				onSelect = function()
					TriggerEvent("Prison:Client:SetLockdown", { state = true })
				end,
				canInteract = function()
					return not GlobalState["PrisonLockdown"]
						and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison")
				end,
			},
			{
				icon = "lock-open",
				label = "Disable Lockdown",
				onSelect = function()
					TriggerEvent("Prison:Client:SetLockdown", { state = false })
				end,
				canInteract = function()
					return GlobalState["PrisonLockdown"]
						and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison")
				end,
			},
		}

		for _, zone in ipairs(Config.PrisonLockdownZones) do
			exports.ox_target:addBoxZone({
				id       = zone.id,
				coords   = zone.coords,
				size     = zone.size,
				rotation = zone.rotation,
				debug    = false,
				minZ     = zone.minZ,
				maxZ     = zone.maxZ,
				options  = lockdownOptions,
			})
		end

		local cellDoors = Config.PrisonCellDoorsZone
		exports.ox_target:addBoxZone({
			id       = cellDoors.id,
			coords   = cellDoors.coords,
			size     = cellDoors.size,
			rotation = cellDoors.rotation,
			debug    = false,
			minZ     = cellDoors.minZ,
			maxZ     = cellDoors.maxZ,
			options  = {
				{
					icon = "lock",
					label = "Lock Cell Doors",
					onSelect = function()
						TriggerEvent("Prison:Client:SetCellState", { state = true })
					end,
					canInteract = function()
						return not GlobalState["PrisonCellsLocked"]
							and not GlobalState["PrisonLockdown"]
							and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison")
					end,
				},
				{
					icon = "lock-open",
					label = "Unlock Cell Doors",
					onSelect = function()
						TriggerEvent("Prison:Client:SetCellState", { state = false })
					end,
					canInteract = function()
						return GlobalState["PrisonCellsLocked"]
							and (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison")
					end,
				},
			},
		})

		exports['pulsar-hud']:InteractionRegisterMenu("prison-utils", "Corrections Utilities", "tablet-rugged",
			function(data)
				exports['pulsar-hud']:InteractionShowMenu({
					{
						icon = "lock-open",
						label = "Slimjim Vehicle",
						action = function()
							exports['pulsar-hud']:InteractionHide()
							TriggerServerEvent("Police:Server:Slimjim")
						end,
						shouldShow = function()
							local target = lib.getClosestVehicle(GetEntityCoords(cache.ped), 2.0, false)

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
							return LocalPlayer.state.onDuty == "prison"
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
							return LocalPlayer.state.onDuty == "prison"
						end,
					},
				})
			end, function()
				return LocalPlayer.state.onDuty == "prison"
			end)

		local prisonDutyOptions = {
			{
				icon      = "fas fa-clipboard-check",
				label     = "Go On Duty",
				event     = "Corrections:Client:OnDuty",
				groups    = { "prison" },
				reqOffDuty = true,
			},
			{
				icon    = "fas fa-clipboard",
				label   = "Go Off Duty",
				event   = "Corrections:Client:OffDuty",
				groups  = { "prison" },
				reqDuty = true,
			},
			{
				icon      = "fas fa-clipboard-check",
				label     = "Go On Duty (Medical)",
				event     = "EMS:Client:OnDuty",
				groups    = { "ems" },
				reqOffDuty = true,
			},
			{
				icon    = "fas fa-clipboard",
				label   = "Go Off Duty (Medical)",
				event   = "EMS:Client:OffDuty",
				groups  = { "ems" },
				reqDuty = true,
			},
		}

		for _, zone in ipairs(Config.PrisonDutyZones) do
			exports.ox_target:addBoxZone({
				id       = zone.id,
				coords   = zone.coords,
				size     = zone.size,
				rotation = zone.rotation,
				debug    = false,
				minZ     = zone.minZ,
				maxZ     = zone.maxZ,
				options  = prisonDutyOptions,
			})
		end

		local locker = Config.PrisonLockerZone
		exports.ox_target:addBoxZone({
			id       = locker.id,
			coords   = locker.coords,
			size     = locker.size,
			rotation = locker.rotation,
			debug    = false,
			minZ     = locker.minZ,
			maxZ     = locker.maxZ,
			options  = {
				{
					icon    = "fas fa-user-lock",
					label   = "Open Personal Locker",
					event   = "Police:Client:OpenLocker",
					groups  = { "prison", "ems" },
					reqDuty = true,
				},
			},
		})
	end
end)

_PROGRESS_LOCKDOWN = false

AddEventHandler("Prison:Client:SetLockdown", function(entity, data)
	if not _PROGRESS_LOCKDOWN then
		_PROGRESS_LOCKDOWN = true
		exports["pulsar-core"]:ServerCallback("Prison:SetLockdown", data.state, function(success, state)
			if success then
				if state then
					exports["pulsar-hud"]:Notification("success", "Lockdown Initiated")
					TriggerServerEvent("Prison:Server:Lockdown:AlertPolice", state)
				else
					exports["pulsar-hud"]:Notification("success", "Lockdown Disabled")
					TriggerServerEvent("Prison:Server:Lockdown:AlertPolice", state)
				end

				SetTimeout(5000, function()
					_PROGRESS_LOCKDOWN = false
				end)
			else
				exports["pulsar-hud"]:Notification("success", "Unauthorized!")
			end
		end)
	end
end)

_PROGRESS_DOORS = false

AddEventHandler("Prison:Client:SetCellState", function(entity, data)
	if not _PROGRESS_DOORS then
		_PROGRESS_DOORS = true
		exports["pulsar-core"]:ServerCallback("Prison:SetCellState", data.state, function(success, state)
			if success then
				if state then
					exports["pulsar-hud"]:Notification("success", "Cell Doors Locked")
				else
					exports["pulsar-hud"]:Notification("success", "Cell Doors Unlocked")
				end

				-- TriggerEvent("Prison:Client:JailAlarm", data.state)
				SetTimeout(5000, function()
					_PROGRESS_DOORS = false
				end)
			else
				exports["pulsar-hud"]:Notification("success", "Unauthorized!")
			end
		end)
	end
end)

RegisterNetEvent("Prison:Client:JailAlarm")
AddEventHandler("Prison:Client:JailAlarm", function(toggle)
	if toggle then
		local alarmIpl = GetInteriorAtCoordsWithType(1787.004, 2593.1984, 45.7978, "int_prison_main")

		RefreshInterior(alarmIpl)
		EnableInteriorProp(alarmIpl, "prison_alarm")

		CreateThread(function()
			while not PrepareAlarm("PRISON_ALARMS") do
				Wait(100)
			end
			StartAlarm("PRISON_ALARMS", true)
		end)
	else
		local alarmIpl = GetInteriorAtCoordsWithType(1787.004, 2593.1984, 45.7978, "int_prison_main")

		RefreshInterior(alarmIpl)
		DisableInteriorProp(alarmIpl, "prison_alarm")

		CreateThread(function()
			while not PrepareAlarm("PRISON_ALARMS") do
				Wait(100)
			end
			StopAllAlarms(true)
		end)
	end
end)
