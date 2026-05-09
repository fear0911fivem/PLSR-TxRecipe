local _pzs = {}
local _inPoly = false
local _menu = false
local _apartmentZones = {}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		for k, v in ipairs(GlobalState["Apartments"]) do
			local aptId = string.format("apt-%s", v)
			local apt = GlobalState[string.format("Apartment:%s", v)]

			exports['pulsar-polyzone']:CreateBox(aptId, apt.coords, apt.length, apt.width, apt.options, {
				tier = k
			})

			exports["pulsar-blips"]:Add(aptId, apt.name, apt.coords, 475, 25)
			_pzs[aptId] = {
				name = apt.name,
				id = apt.id,
			}
		end

		exports['pulsar-hud']:InteractionRegisterMenu("apt-exit", "Exit Apartment", "door-open", function(data)
			exports['pulsar-hud']:InteractionHide()
			exports['pulsar-apartments']:Exit()
		end, function()
			if
				not LocalPlayer.state.isDead
				and GlobalState[string.format("%s:", LocalPlayer.state.ID)] ~= nil
			then
				local p = GlobalState[string.format(
					"Apartment:%s",
					LocalPlayer.state.inApartment.type
				)]

				local dist = #(
					vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
					- vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z)
				)
				return dist <= 2.0
			else
				return false
			end
		end)

		-- exports['pulsar-hud']:InteractionRegisterMenu("apt-visitors", "Check Visitors", "hand-back-fist", function(data)
		-- 	exports['pulsar-hud']:InteractionHide()
		-- 	CheckVisitors()
		-- end, function()
		-- 	if GlobalState[string.format("%s:Apartment", LocalPlayer.state.ID)] ~= nil then
		-- 		local p = GlobalState[string.format(
		-- 			"Apartment:%s",
		-- 			GlobalState[string.format(
		-- 				"Apartment:Interior:%s",
		-- 				GlobalState[string.format("%s:Apartment", LocalPlayer.state.ID)]
		-- 			)]
		-- 		)]
		-- 		local dist = #(
		-- 				vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
		-- 				- vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z)
		-- 			)
		-- 		return dist <= 2.0
		-- 	else
		-- 		return false
		-- 	end
		-- end)
	end
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	for k, v in ipairs(GlobalState["Apartments"]) do
		local aptId = string.format("apt-%s", v)
		local apt = GlobalState[string.format("Apartment:%s", v)]

		exports["pulsar-blips"]:Add(aptId, apt.name, apt.coords, 475, 25)
	end
end)

-- function CheckVisitors()
-- 	exports["pulsar-core"]:ServerCallback("Apartment:GetRequests", {}, function(requets)
-- 		if #reqeusts > 0 then
-- 			local menu = {
-- 				label = _pzs[_inPoly].name,
-- 			}
-- 			local its = {}

-- 			for k, v in ipairs(requests) do
-- 				table.insert(its, {
-- 					label = string.format("%s %s", v.First, v.Last),
-- 					description = "Requesting To Enter Apartment",
-- 					data = _inPoly,
-- 				})
-- 				menu[string.format("request-%s", v.SID)] = {
-- 					label = string.format("Allow %s %s?", v.First, v.Last),
-- 					items = {
-- 						{
-- 							label = "Yes",
-- 							description = "Allow Them To Enter",
-- 							event = "Apartment:Client:Enter",
-- 							data = _inPoly,
-- 						},
-- 						{
-- 							label = "Breach Apartment",
-- 							description = "Breach An Apartment",
-- 							event = "Apartment:Client:Enter",
-- 							data = _inPoly,
-- 						},
-- 					},
-- 				}
-- 			end

-- 			menu.items = menu

-- 			exports['pulsar-hud']:ListMenuShow(menu)
-- 		else
-- 			exports["pulsar-hud"]:Notification("error", "You Have No Requesting Visitors")
-- 		end
-- 	end)
-- end

RegisterNetEvent("Apartment:Client:InnerStuff", function(aptId, unit, wakeUp)
	while GlobalState[string.format("%s:", LocalPlayer.state.ID)] == nil do
		Wait(10)
		print("Interior Stuff Waiting, This Shouldn't Spam")
	end

	local p = GlobalState[string.format("Apartment:%s", aptId)]
	TriggerEvent("Interiors:Enter", vector3(p.interior.spawn.x, p.interior.spawn.y, p.interior.spawn.z))

	if wakeUp then
		SetTimeout(250, function()
			exports['pulsar-animations']:EmotesWakeUp(p.interior.wakeup)
		end)
	end

	local exitZoneId = exports.ox_target:addBoxZone({
		name = string.format("apt-%s-exit", aptId),
		coords = p.interior.locations.exit.coords,
		size = vec3(p.interior.locations.exit.width, p.interior.locations.exit.length,
			math.abs(p.interior.locations.exit.options.maxZ - p.interior.locations.exit.options.minZ)),
		rotation = p.interior.locations.exit.options.heading or 0,
		debug = p.interior.locations.exit.options.debugPoly or false,
		options = {
			{
				name = "apt_exit",
				label = "Exit",
				icon = "fas fa-door-open",
				onSelect = function()
					TriggerEvent("Apartment:Client:ExitEvent", unit)
				end,
				distance = 3.0,
			},
		},
	})
	_apartmentZones[string.format("apt-%s-exit", aptId)] = exitZoneId

	local logoutZoneId = exports.ox_target:addBoxZone({
		name = string.format("apt-%s-logout", aptId),
		coords = p.interior.locations.logout.coords,
		size = vec3(p.interior.locations.logout.width, p.interior.locations.logout.length,
			math.abs(p.interior.locations.logout.options.maxZ - p.interior.locations.logout.options.minZ)),
		rotation = p.interior.locations.logout.options.heading or 0,
		debug = p.interior.locations.logout.options.debugPoly or false,
		options = {
			{
				name = "apt_logout",
				label = "Switch Characters",
				icon = "fas fa-bed",
				onSelect = function()
					TriggerEvent("Apartment:Client:Logout", unit)
				end,
				distance = 3.0,
				canInteract = function()
					return unit == LocalPlayer.state.Character:GetData("SID")
				end,
			},
		},
	})
	_apartmentZones[string.format("apt-%s-logout", aptId)] = logoutZoneId

	local wardrobeZoneId = exports.ox_target:addBoxZone({
		name = string.format("apt-%s-wardrobe", aptId),
		coords = p.interior.locations.wardrobe.coords,
		size = vec3(p.interior.locations.wardrobe.width, p.interior.locations.wardrobe.length,
			math.abs(p.interior.locations.wardrobe.options.maxZ - p.interior.locations.wardrobe.options.minZ)),
		rotation = p.interior.locations.wardrobe.options.heading or 0,
		debug = p.interior.locations.wardrobe.options.debugPoly or false,
		options = {
			{
				name = "apt_wardrobe",
				label = "Wardrobe",
				icon = "fas fa-shirt",
				onSelect = function()
					TriggerEvent("Apartment:Client:Wardrobe", unit)
				end,
				distance = 3.0,
				canInteract = function()
					return unit == LocalPlayer.state.Character:GetData("SID")
				end,
			},
		},
	})
	_apartmentZones[string.format("apt-%s-wardrobe", aptId)] = wardrobeZoneId

	local stashZoneId = exports.ox_target:addBoxZone({
		name = string.format("apt-%s-stash", aptId),
		coords = p.interior.locations.stash.coords,
		size = vec3(p.interior.locations.stash.width, p.interior.locations.stash.length,
			math.abs(p.interior.locations.stash.options.maxZ - p.interior.locations.stash.options.minZ)),
		rotation = p.interior.locations.stash.options.heading or 0,
		debug = p.interior.locations.stash.options.debugPoly or false,
		options = {
			{
				name = "apt_stash",
				label = "Stash",
				icon = "fas fa-box",
				onSelect = function()
					TriggerEvent("Apartment:Client:Stash", aptId)
				end,
				distance = 2.0,
			},
		},
	})
	_apartmentZones[string.format("apt-%s-stash", aptId)] = stashZoneId

	Wait(1000)
	exports["pulsar-sync"]:Stop(1)
end)

AddEventHandler("Apartment:Client:ExitEvent", function()
	exports['pulsar-apartments']:Exit()
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if _pzs[id] and string.format("apt-%s", LocalPlayer.state.Character:GetData("Apartment") or 1) == id then
		_inPoly = {
			id = id,
			data = data.tier
		}

		-- local str = "{keybind}secondary_action{/keybind} View Options"
		-- if string.format("apt-%s", LocalPlayer.state.Character:GetData("Apartment") or 1) == id then
		-- 	str = string.format("{keybind}primary_action{/keybind}: Enter {keybind}secondary_action{/keybind}: Other", _pzs[id].name)
		-- end

		local str = string.format("{keybind}primary_action{/keybind} To Enter %s", _pzs[id].name)

		exports['pulsar-hud']:ActionShow('apt-enter', str)
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if _inPoly and _inPoly.id and id == _inPoly.id then
		_inPoly = nil
		exports['pulsar-hud']:ActionHide('apt-enter')
	end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
	if
		_inPoly
		and (LocalPlayer.state.Character:GetData("Apartment") or 1) == _inPoly.data
		and not LocalPlayer.state.isDead and GetVehiclePedIsIn(LocalPlayer.state.ped) == 0
	then
		exports['pulsar-apartments']:Enter(_inPoly.data, -1)
	end
end)

AddEventHandler("Apartment:Client:Enter", function(data)
	exports['pulsar-apartments']:Enter(data)
end)

AddEventHandler("Apartment:Client:RequestEntry", function(data)
	exports['pulsar-hud']:InputShow("Request Entry", "Unit Number (Owner State ID)", {
		{
			id = "unit",
			type = "number",
			options = {
				inputProps = {
					maxLength = 4,
				},
			},
		},
	}, "Apartment:Client:DoRequestEntry", _inPoly)
end)

AddEventHandler("Apartment:Client:DoRequestEntry", function(values, data)
	exports["pulsar-core"]:ServerCallback("Apartment:RequestEntry", {
		inZone = data,
		target = values.unit,
	})
end)

AddEventHandler("Apartment:Client:Stash", function(response)
	exports['pulsar-apartments']:ExtrasStash()
end)

AddEventHandler("Apartment:Client:Wardrobe", function(response)
	exports['pulsar-apartments']:ExtrasWardrobe()
end)

AddEventHandler("Apartment:Client:Logout", function(response)
	exports['pulsar-apartments']:ExtrasLogout()
end)

exports("Enter", function(tier, id)
	exports["pulsar-core"]:ServerCallback("Apartment:Enter", {
		id = id or -1,
		tier = tier,
	}, function(s)
		if s then
			exports["pulsar-sounds"]:PlayOne("door_open.ogg", 0.15)

			DoScreenFadeOut(1000)
			while not IsScreenFadedOut() do
				Wait(10)
			end

			local p = GlobalState[string.format("Apartment:%s", s)]

			FreezeEntityPosition(PlayerPedId(), true)
			Wait(50)
			SetEntityCoords(
				PlayerPedId(),
				p.interior.spawn.x,
				p.interior.spawn.y,
				p.interior.spawn.z,
				0,
				0,
				0,
				false
			)
			Wait(100)
			SetEntityHeading(PlayerPedId(), p.interior.spawn.h)

			local time = GetGameTimer()
			while (not HasCollisionLoadedAroundEntity(PlayerPedId()) and (GetGameTimer() - time) < 10000) do
				Wait(100)
			end

			FreezeEntityPosition(PlayerPedId(), false)

			DoScreenFadeIn(1000)
			while not IsScreenFadedIn() do
				Wait(10)
			end
		end
	end)
end)

exports("Exit", function()
	local apartmentId = GlobalState[string.format("%s:", LocalPlayer.state.ID)]
	local p = GlobalState[string.format(
		"Apartment:%s",
		LocalPlayer.state.inApartment.type
	)]

	exports["pulsar-core"]:ServerCallback("Apartment:Exit", {}, function()
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Wait(10)
		end

		TriggerEvent("Interiors:Exit")
		exports["pulsar-sync"]:Start()

		exports["pulsar-sounds"]:PlayOne("door_close.ogg", 0.3)
		Wait(200)

		SetEntityCoords(PlayerPedId(), p.coords.x, p.coords.y, p.coords.z, 0, 0, 0, false)
		Wait(100)
		SetEntityHeading(PlayerPedId(), p.heading)

		for zoneName, zoneId in pairs(_apartmentZones) do
			if string.find(zoneName, string.format("apt-%s-", apartmentId)) then
				if exports.ox_target:zoneExists(zoneId) then
					exports.ox_target:removeZone(zoneId)
				end
				_apartmentZones[zoneName] = nil
			end
		end

		DoScreenFadeIn(1000)
		while not IsScreenFadedIn() do
			Wait(10)
		end
	end)
end)

exports("GetNearApartment", function()
	if _inPoly and _inPoly.id and _pzs[_inPoly.id] and _pzs[_inPoly.id].id then
		return GlobalState[string.format("Apartment:%s", _pzs[_inPoly.id].id)]
	else
		return nil
	end
end)

exports("ExtrasStash", function()
	local apartmentType = LocalPlayer.state.inApartment.type
	local characterSID = LocalPlayer.state.Character:GetData("SID")

	if characterSID then
		exports.ox_inventory:openInventory('stash', {
			id = string.format("apartment_%s", apartmentType),
			owner = characterSID
		})
	end
end)

exports("ExtrasWardrobe", function()
	exports["pulsar-core"]:ServerCallback("Apartment:Validate", {
		id = GlobalState[string.format("%s:", LocalPlayer.state.ID)],
		type = "wardrobe",
	}, function(state)
		if state then
			exports['pulsar-ped']:WardrobeShow()
		end
	end)
end)

exports("ExtrasLogout", function()
	exports["pulsar-core"]:ServerCallback("Apartment:Validate", {
		id = GlobalState[string.format("%s:", LocalPlayer.state.ID)],
		type = "logout",
	}, function(state)
		if state then
			exports['pulsar-characters']:Logout()
		end
	end)
end)

RegisterNetEvent("Apartment:Client:Enter", function(targetType, target, wakeUp)
	exports['pulsar-apartments']:ClientEnter(targetType, target, wakeUp)
end)

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
	for k, v in pairs(_apartmentZones) do
		if exports.ox_target:zoneExists(v) then
			exports.ox_target:removeZone(v)
		end
		_apartmentZones[k] = nil
	end
end)
