-- local Targets = {}
local xSound = exports.xsound
local Props = {}

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterDjZones()
	end
end)

function RegisterDjZones()
	for k, v in ipairs(Props) do
		DeleteObject(v)
	end

	Props = {}

	for k, v in ipairs(Config.Locations) do
		if v.enableBooth then
			exports.ox_target:addBoxZone({
				id = "dj-booth" .. k,
				coords = v.coords,
				size = vector3(1.0, 1.0, 3.0),
				rotation = 0,
				debug = false,
				minZ = v.coords.z - 1.5,
				maxZ = v.coords.z + 1.5,
				options = {
					{
						icon = "compact-disc",
						label = "Open Stereo",
						onSelect = function()
							TriggerEvent("pulsar-dj:client:playMusic", { zone = k })
						end,
					},
				}
			})

			if v.prop then
				RequestModel(v.prop)
				while not HasModelLoaded(v.prop) do
					Wait(1)
				end
				local obj = CreateObject(v.prop, v.coords, false, false, false)
				local heading = v.heading or math.random(1, 359) + 0.0
				SetEntityHeading(obj, heading)
				FreezeEntityPosition(obj, true)

				table.insert(Props, obj)
			end
		end
	end
end

RegisterNetEvent("pulsar-dj:client:playMusic", function(data)
	local booth = ""
	local boothId = 0

	for k, v in pairs(Config.Locations) do
		if #(GetEntityCoords(PlayerPedId()) - v["coords"]) <= v["radius"] then
			-- if v["job"] then booth = v["job"]..k elseif v["gang"] then booth = v["gang"]..k end
			booth = "public" .. k
			boothId = k
		end
	end

	local song = {
		playing = "",
		duration = "",
		timeStamp = "",
		duration = "",
		url = "",
		icon = "",
		header = "",
		txt = "🔇 No Song Playing",
		volume = 0,
	}
	local p = promise.new()
	exports["pulsar-core"]:ServerCallback("pulsar-dj:server:songInfo", {}, function(cb)
		p:resolve(cb)
	end)
	previousSongs = Citizen.Await(p)

	-- Grab song info and build table
	if xSound:soundExists(booth) then
		song = {
			playing = xSound:isPlaying(booth),
			timeStamp = "",
			url = xSound:getLink(booth),
			icon = "https://img.youtube.com/vi/" .. string.sub(xSound:getLink(booth), -11) .. "/mqdefault.jpg",
			header = "",
			txt = xSound:getLink(booth),
			volume = math.ceil(xSound:getVolume(booth) * 100),
		}
		if xSound:isPlaying(booth) then
			song.header = "Currently Playing: "
		end
		if xSound:isPaused(booth) then
			song.header = "Currently Paused: "
		end
		if xSound:getMaxDuration(booth) == 0 then
			song.timeStamp = "🔴 Live"
		end
		if xSound:getMaxDuration(booth) > 0 then
			local timestamp = (xSound:getTimeStamp(booth) * 10)
			local mm = (timestamp // (60 * 10)) % 60.
			local ss = (timestamp // 10) % 60.
			timestamp = string.format("%02d:%02d", mm, ss)
			local duration = (xSound:getMaxDuration(booth) * 10)
			mm = (duration // (60 * 10)) % 60.
			ss = (duration // 10) % 60.
			duration = string.format("%02d:%02d", mm, ss)
			song.timeStamp = "(" .. timestamp .. "/" .. duration .. ")"
			if xSound:isPlaying(booth) then
				song.timeStamp = "🔊 " .. song.timeStamp
			else
				song.timeStamp = "🔇 " .. song.timeStamp
			end
		end
	end

	local djMenu = {}
	local djMenuSub = {}

	djMenu = exports['pulsar-menu']:Create("djMenuPlayer", string.format("DJ Turntable"), function() end, function()
		djMenu = nil
		djMenuSub = nil
		collectgarbage()
	end)

	djMenu.Add:Text(string.format("Song: %s", song.header), { "pad", "code", "center", "textLarge" })
	djMenu.Add:Text(string.format("Txt: %s", song.txt), { "pad", "code", "center", "textLarge" })
	djMenu.Add:Text(string.format("Time: %s", song.timeStamp), { "pad", "code", "center", "textLarge" })

	djMenu.Add:Text("Play a song", { "pad", "code", "center", "textLarge" })
	djMenu.Add:Input("Youtube URL", {
		disabled = false,
		max = 100,
		current = nil,
	}, function(data)
		local song = data.data.value
		if song == "" or song == nil then
			exports["pulsar-hud"]:Notification("error", "Empty text cannot be played dummy.", 2500, "fas fa-volume-off")
			return
		end
		if not string.find(song, "youtu") then
			song = "https://www.youtube.com/watch?v=" .. song
		end
		exports["pulsar-core"]:ServerCallback("pulsar-dj:server:playMusic", {
			song = song,
			zoneNum = boothId,
		}, function(success, zoneNum)
			if success then
				TriggerEvent("pulsar-dj:client:playMusic", { zone = zoneNum })
				exports["pulsar-hud"]:Notification("success", "Loading link: " .. song, 2500, "fas fa-pause")
			else
				exports["pulsar-hud"]:Notification("error", "Failed to Load Song", 2500, "fas fa-volume-off")
			end
		end)
	end)

	djMenuSub["songhistory"] = exports['pulsar-menu']:Create("djSongHistoryMenu", "Song History")
	if previousSongs[booth] then
		for _, v in pairs(previousSongs[booth]) do
			djMenuSub["songhistory"].Add:Text(string.format("Song: %s", v), { "pad", "code", "center", "textLarge" })
		end
	end

	djMenuSub["songhistory"].Add:SubMenuBack("Go Back", {})

	djMenu.Add:SubMenu("Song History", djMenuSub["songhistory"], {})

	if xSound:soundExists(booth) then
		if xSound:isPlaying(booth) then
			djMenu.Add:Button("Pause Music", { success = true }, function()
				exports["pulsar-core"]:ServerCallback("pulsar-dj:server:pauseMusic", {
					zoneName = booth,
					zoneNum = boothId,
				}, function(success)
					if success then
						exports["pulsar-hud"]:Notification("success", "Paused Music", 2500, "fas fa-pause")
					else
						exports["pulsar-hud"]:Notification("error", "Failed to Pause Music", 2500, "fas fa-pause")
					end
				end)
			end)
		elseif xSound:isPaused(booth) then
			djMenu.Add:Button("Resume Music", { success = true }, function()
				exports["pulsar-core"]:ServerCallback("pulsar-dj:server:resumeMusic", {
					zoneName = booth,
					zoneNum = boothId,
				}, function(success)
					if success then
						exports["pulsar-hud"]:Notification("success", "Resume Music", 2500, "fas fa-play")
					else
						exports["pulsar-hud"]:Notification("error", "Failed to Resume Music", 2500, "fas fa-play")
					end
				end)
			end)
		end
		-- i-_1Os7hVDw
		djMenuSub["changevolume"] = exports['pulsar-menu']:Create("dj_change_volume", "Change Volume")

		djMenuSub["changevolume"].Add:Slider("Change Volume", {
			current = song.volume,
			min = 0,
			max = 100,
			step = 1,
		}, function(data)
			-- data comes back as type number
			local volume = data.data.value
			if not volume then
				return
			end
			-- Automatically correct from numbers to be numbers xsound understands
			volume = (volume / 100)
			-- Don't let numbers go too high or too low
			if volume <= 0.01 then
				volume = 0.01
			end
			if volume > 1.0 then
				volume = 1.0
			end
			exports["pulsar-core"]:ServerCallback("pulsar-dj:server:changeVolume", {
				volume = volume,
				zoneName = booth,
				zoneNum = boothId,
			}, function(success, zoneNum)
				if success then
					song.volume = volume * 100
					TriggerEvent("pulsar-dj:client:playMusic", { zone = zoneNum })
					exports["pulsar-hud"]:Notification("success",
						string.format("Changed Volume to %s/100", tostring(math.ceil(volume * 100))),
						2500,
						"fas fa-volume-off"
					)
				else
					exports["pulsar-hud"]:Notification("error", "Failed to Change Volume", 2500, "fas fa-volume-off")
				end
			end)
		end)

		djMenuSub["changevolume"].Add:SubMenuBack("Go Back", {})
		djMenu.Add:SubMenu("Change Volume", djMenuSub["changevolume"], {})

		djMenu.Add:Button("Stop Music", { success = true }, function()
			exports["pulsar-core"]:ServerCallback("pulsar-dj:server:stopMusic", {
				zoneName = booth,
				zoneNum = boothId,
			}, function(success)
				if success then
					exports["pulsar-hud"]:Notification("success", "Stop Music", 2500, "fas fa-stop")
				else
					exports["pulsar-hud"]:Notification("error", "Failed to Stop Music", 2500, "fas fa-stop")
				end
			end)
		end)
	end

	djMenu.Add:Button("Close", { success = true }, function()
		djMenu:Close()
	end)

	djMenu:Show()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		for k, v in ipairs(Props) do
			DeleteObject(v)
		end
	end
end)
