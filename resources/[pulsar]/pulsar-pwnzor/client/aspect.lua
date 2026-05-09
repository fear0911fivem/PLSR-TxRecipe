local IsWide = false

if Config.AspectRatio.Enabled then
	CreateThread(function()
		while true do
			Wait(1000)
			if LocalPlayer.state.loggedIn then
				local res = GetIsWidescreen()
				if not res and not IsWide then
					startTimer()
					IsWide = true
					SetTimecycleModifier("Glasses_BlackOut")
				elseif res and IsWide then
					IsWide = false
					exports["pulsar-hud"]:Notification("remove", nil, nil, nil, nil, "pwnzor-aspectchecker")
					ClearTimecycleModifier()
				end
			end
		end
	end)
end

function startTimer()
	local timer = Config.AspectRatio.Options.KickTimer

	CreateThread(function()
		while timer > 0 and IsWide do
			Wait(1000)

			if timer > 0 then
				timer = timer - 1
				if timer == 0 then
					exports["pulsar-core"]:ServerCallback("Pwnzor:AspectRatio")
				end
			end
		end
	end)

	CreateThread(function()
		while IsWide do
			Wait(1000)
			exports["pulsar-hud"]:Notification("error",
				string.format("You will get kicked in %s seconds. Change your resolution to 16:9", timer),
				-1,
				nil,
				nil,
				"pwnzor-aspectchecker"
			)
		end
	end)
end
