local _mb = RobberyConfig.mazebank

function NeedsReset()
	for k, v in ipairs(_mb.doors) do
		if not exports['ox_doorlock']:IsLocked(v.door) then
			return true
		end
	end

	for k, v in ipairs(_mb.officeDoors) do
		if not exports['ox_doorlock']:IsLocked(v.door) then
			return true
		end
	end

	for k, v in ipairs(_mb.hacks) do
		if
			GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)] ~= nil
			and (
				(GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].state ~= 4)
				or (
					GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].state == 4
					and (
						(GlobalState[string.format("MazeBank:ManualDoor:%s", v.doorId)].expires or 0)
						< GetCloudTimeAsInt()
					)
				)
			)
		then
			return true
		end
	end

	for k, v in ipairs(_mb.drillPoints) do
		if
			GlobalState[string.format("MazeBank:Vault:Wall:%s", v.data.wallId)] ~= nil
			and GlobalState[string.format("MazeBank:Vault:Wall:%s", v.data.wallId)] > GetCloudTimeAsInt()
		then
			return true
		end
	end

	for k, v in ipairs(_mb.desks) do
		if
			GlobalState[string.format("MazeBank:Offices:PC:%s", v.data.deskId)] ~= nil
			and GlobalState[string.format("MazeBank:Offices:PC:%s", v.data.deskId)] > GetCloudTimeAsInt()
		then
			return true
		end
	end

	return false
end

AddEventHandler("Robbery:Client:Setup", function()
	exports['pulsar-polyzone']:CreatePoly("bank_mazebank", _mb.polyZone.vertices, _mb.polyZone.options)

	exports.ox_target:addBoxZone({
		id = "mazebanK_secure",
		coords = _mb.secureZone.coords,
		size = vector3(_mb.secureZone.length, _mb.secureZone.width, 2.0),
		rotation = _mb.secureZone.options.heading,
		debug = false,
		minZ = _mb.secureZone.options.minZ,
		maxZ = _mb.secureZone.options.maxZ,
		options = {
			{
				icon = "fas fa-lock",
				label = "Secure Bank",
				event = "Robbery:Client:MazeBank:StartSecuring",
				groups = { "police" },
				canInteract = NeedsReset,
			},
		}
	})

	for k, v in ipairs(_mb.electric) do
		exports.ox_target:addBoxZone({
			id = string.format("mazebank_power_%s", v.data.boxId),
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
							TriggerEvent("Robbery:Client:MazeBank:ElectricBox:Thermite", v.data)
						end,
						canInteract = function()
							return not GlobalState["MazeBank:Secured"]
								and (
									not GlobalState[string.format("MazeBank:Power:%s", v.data.boxId)]
									or GetCloudTimeAsInt()
									> GlobalState[string.format("MazeBank:Power:%s", v.data.boxId)]
								)
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
							TriggerEvent("Robbery:Client:MazeBank:ElectricBox:Hack", v.data)
						end,
						canInteract = function()
							return not GlobalState["MazeBank:Secured"]
								and (
									not GlobalState[string.format("MazeBank:Power:%s", v.data.boxId)]
									or GetCloudTimeAsInt()
									> GlobalState[string.format("MazeBank:Power:%s", v.data.boxId)]
								)
						end,
					},
				}
		})
	end

	for k, v in ipairs(_mb.drillPoints) do
		exports.ox_target:addBoxZone({
			id = string.format("mazebanK_drill_%s", v.data.wallId),
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
					wallId = v.data.wallId,
					onSelect = function(data)
						TriggerEvent("Robbery:Client:MazeBank:Drill", data.wallId)
					end,
					canInteract = function()
						return not GlobalState["MazeBank:Secured"]
							and (
								not GlobalState[string.format("MazeBank:Vault:Wall:%s", v.data.wallId)]
								or GetCloudTimeAsInt()
								> GlobalState[string.format("MazeBank:Vault:Wall:%s", v.data.wallId)]
							)
					end,
				},
			}
		})
	end

	for k, v in ipairs(_mb.desks) do
		exports.ox_target:addBoxZone({
			id = string.format("mazebanK_workstation_%s", v.data.deskId),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-terminal",
					label = "Hack Workstation",
					item = "adv_electronics_kit",
					deskId = v.data.deskId,
					onSelect = function(data)
						TriggerEvent("Robbery:Client:MazeBank:PC:Hack", data.deskId)
					end,
					canInteract = function()
						return not GlobalState["MazeBank:Secured"]
							and (
								not GlobalState[string.format("MazeBank:Offices:PC:%s", v.data.deskId)]
								or GetCloudTimeAsInt()
								> GlobalState[string.format("MazeBank:Offices:PC:%s", v.data.deskId)]
							)
					end,
				},
			}
		})
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	MazeBankThreads()
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if id == "bank_mazebank" then
		LocalPlayer.state:set("inMazeBank", true, true)
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "bank_mazebank" then
		if LocalPlayer.state.inMazeBank then
			LocalPlayer.state:set("inMazeBank", false, true)
		end
	end
end)

AddEventHandler("Robbery:Client:MazeBank:StartSecuring", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "secure_mazebank",
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
			exports["pulsar-core"]:ServerCallback("Robbery:MazeBank:SecureBank", {})
		end
	end)
end)

AddEventHandler("Robbery:Client:MazeBank:ElectricBox:Hack", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:MazeBank:ElectricBox:Hack", data, function() end)
end)

AddEventHandler("Robbery:Client:MazeBank:ElectricBox:Thermite", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:MazeBank:ElectricBox:Thermite", data, function() end)
end)

AddEventHandler("Robbery:Client:MazeBank:Drill", function(wallId)
	exports["pulsar-core"]:ServerCallback("Robbery:MazeBank:Drill", wallId, function() end)
end)

AddEventHandler("Robbery:Client:MazeBank:PC:Hack", function(deskId)
	exports["pulsar-core"]:ServerCallback("Robbery:MazeBank:PC:Hack", { id = deskId }, function() end)
end)

RegisterNetEvent("Robbery:Client:MazeBank:OpenVaultDoor", function(door)
	local myCoords = GetEntityCoords(LocalPlayer.state.ped)
	if #(myCoords - door.coords) <= 100 then
		OpenDoor(door.coords, door.doorConfig)
	end
end)

RegisterNetEvent("Robbery:Client:MazeBank:CloseVaultDoor", function(door)
	local myCoords = GetEntityCoords(LocalPlayer.state.ped)
	if #(myCoords - door.coords) <= 100 then
		CloseDoor(door.coords, door.doorConfig)
	end
end)
