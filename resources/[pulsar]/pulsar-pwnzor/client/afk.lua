local isAfk = false
local afkAnswer = false
local inputShowing = false
local submitting = false

local afkCd = false

local function GetCode()
	exports["pulsar-core"]:ServerCallback("Pwnzor:GetCode", {}, function(c)
		afkAnswer = c
	end)
end

local function ShowInput()
	if inputShowing then
		return
	end
	inputShowing = true

	while afkAnswer == nil do
		Wait(1)
	end

	exports['pulsar-hud']:InputShow("Are You There?", string.format('Enter: "%s" To Prevent Being Kicked', afkAnswer), {
		{
			id = "code",
			type = "text",
			options = {
				inputProps = {
					autofocus = "autofocus",
				},
			},
		},
	}, "Pwnzor:Client:EnterAFKCode", {})
end

local timerStarted = false
local function StartKickTimer()
	if timerStarted then
		return
	end
	timerStarted = true
	isAfk = true

	CreateThread(function()
		afkAnswer = nil
		GetCode()
		ShowInput()
	end)

	local time = 0
	local AFKTimer = 60 * 5

	CreateThread(function()
		while isAfk do
			if time > AFKTimer then
				if isAfk and not submitting and not (GlobalState["DisableAFK"] or false) then
					exports["pulsar-core"]:ServerCallback("Pwnzor:AFK")
				end
			end

			exports["pulsar-hud"]:Notification("error",
				"You Will Be Kicked In " .. (AFKTimer - time) .. " Seconds For Being AFK",
				-1,
				nil,
				nil,
				"pwnzor-afk"
			)

			time += 1

			Wait(1000)
		end
		timerStarted = false
	end)

	CreateThread(function()
		while isAfk do
			if afkAnswer ~= nil and not inputShowing then
				ShowInput()
			end
			Wait(1)
		end
	end)
end

AddEventHandler("Pwnzor:Client:EnterAFKCode", function(vals, data)
	submitting = true
	exports["pulsar-core"]:ServerCallback("Pwnzor:EnterCode", vals.code, function(c)
		if c then
			afkAnswer = false
			exports["pulsar-hud"]:Notification("remove", nil, nil, nil, nil, "pwnzor-afk")

			isAfk = false
			submitting = false
			inputShowing = false

			afkCd = true
			SetTimeout(1000 * GlobalState["AFKTimer"], function()
				afkCd = false
			end)
		else
			inputShowing = false
		end
	end)
end)

AddEventHandler("Input:Closed", function(event, data)
	inputShowing = false
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	if LocalPlayer.state.isDev or LocalPlayer.state.isStaff then
		return
	end

	CreateThread(function()
		local time = 0
		local prevPos = nil
		local currentPos = nil

		Wait(30000)

		while GlobalState["AFKTimer"] == nil do
			Wait(1000)
		end

		local AFKTimer = GlobalState["AFKTimer"]

		while LocalPlayer.state.inCreator do
			Wait(30000)
		end

		while LocalPlayer.state.loggedIn do
			Wait(1000)
			local playerPed = PlayerPedId()
			if playerPed and not afkCd and not isAfk and not (GlobalState["DisableAFK"] or false) then
				currentPos = GetEntityCoords(playerPed)
				if prevPos ~= nil then
					if
						#(vector3(currentPos.x, currentPos.y, currentPos.z) - vector3(prevPos.x, prevPos.y, prevPos.z))
						< 1.0
					then
						if time > AFKTimer then
							StartKickTimer()
							time = 0
						else
							time += 1
						end
					else
						time = 0
						afkCd = true
						SetTimeout(1000 * 60, function()
							afkCd = false
						end)
					end
				end

				prevPos = currentPos
			end
		end
	end)
end)
