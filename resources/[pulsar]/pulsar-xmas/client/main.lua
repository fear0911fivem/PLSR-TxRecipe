_todaysDayNumber = nil
_existingTree = nil
_isChristmasMonth = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		TriggerEvent("Xmas:Client:RegisterStartups")
	end
end)

RegisterNetEvent("Xmas:Client:Init", function(dayNumber, tree, hasLooted)
	_isChristmasMonth = true

	exports.ox_target:addBoxZone({
		coords = vector3(184.33, -963.19, 30.1),
		size = vector3(3.0, 5.8, 3.2),
		rotation = 331,
		debug = false,
		options = {
			{
				icon = "gift",
				label = "Pickup Daily Gift",
				event = "Xmas:Client:Daily",
				canInteract = function()
					local xmasDaily = LocalPlayer.state.Character:GetData("XmasDaily")
					local xmasDailyCount = LocalPlayer.state.Character:GetData("XmasDailyCount") or 0
					return xmasDaily ~= _todaysDayNumber
						and (
							(_todaysDayNumber ~= 25 and xmasDailyCount < 1)
							or (_todaysDayNumber == 25 and xmasDailyCount < 3)
						)
				end,
			},
		}
	})

	_todaysDayNumber = dayNumber
	SetupTree(tree, hasLooted)
end)

RegisterNetEvent("Xmas:Client:NewTree", function(tree)
	if LocalPlayer.state.loggedIn then
		SetupTree(tree, false)
		exports["pulsar-sounds"]:PlayOne("xmas.ogg", 0.05)
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	if _existingTree ~= nil then
		DeleteEntity(_existingTree.entity)
		if exports.ox_target:zoneExists("legion-present") then
			exports.ox_target:removeZone("legion-present")
		end
		_existingTree = nil
	end
end)

AddEventHandler("Xmas:Client:Daily", function()
	exports['pulsar-hud']:Progress({
		name = "xmas",
		duration = 15000,
		label = "Picking Up Present",
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
			anim = "machinic_loop_mechandplayer",
			flags = 49,
		},
	}, function(cancelled)
		if not cancelled then
			exports["pulsar-core"]:ServerCallback("Xmas:Daily", {})
		end
	end)
end)

AddEventHandler("Xmas:Client:Tree", function()
	exports['pulsar-hud']:Progress({
		name = "xmas",
		duration = 15000,
		label = "Picking Up Present",
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
			anim = "machinic_loop_mechandplayer",
			flags = 49,
		},
	}, function(cancelled)
		if not cancelled then
			exports["pulsar-core"]:ServerCallback("Xmas:Tree", {}, function(s)
				_existingTree.hasLooted = s
			end)
		end
	end)
end)
