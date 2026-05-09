--[[

	player stash
	public stash

]]

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
	while not GlobalState.JailStashLocations do
		Wait(100)
	end

	if GlobalState.JailStashLocations ~= nil then
		for key, data in ipairs(GlobalState.JailStashLocations) do
			exports.ox_target:addBoxZone({
				id = string.format("prison_stash_%s", key),
				coords = data.coords,
				size = vector3(data.width, data.length, 2.0),
				rotation = data.options.heading or 0,
				debug = false,
				minZ = data.options.minZ,
				maxZ = data.options.maxZ,
				options = {
					{
						icon = "box",
						label = data.stashType == "self" and "Open Stash" or "Open Public Stash",
						event = "Prison:Client:Target:Stash",
					},
					{
						icon = "bomb",
						label = "Raid Storage",
						event = "Prison:Client:Stash:Raid",
						canInteract = function()
							return (LocalPlayer.state.onDuty == "police" or LocalPlayer.state.onDuty == "prison")
								and data.stashType == "self"
						end,
					},
				}
			})
		end
	end
end)

AddEventHandler("Prison:Client:Target:Stash", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Inventory:PrisonStash:Open", data.stashType)
end)

AddEventHandler("Prison:Client:Stash:Raid", function(entity, data)
	local menu = {}
	local playerSID = nil

	exports['pulsar-hud']:InputShow("Prison Stash Raid", "Enter Prisoner State ID", {
		{
			id = "stateid",
			type = "text",
			options = {
				helperText = "Numbers Only - Minimum Length of 1 and a Maximum Length of 6",
				inputProps = {
					pattern = "[0-9]+",
					minlength = 1,
					maxlength = 6,
				},
			},
		},
	}, "Inventory:Client:PrisonStash:Raid", data)
end)

AddEventHandler("Inventory:Client:PrisonStash:Raid", function(values, data)
	if values and values.stateid and #values.stateid >= 1 then
		exports["pulsar-core"]:ServerCallback("Inventory:PrisonStash:Raid", {
			stateid = values.stateid,
		}, function(success)
			-- if success then
			-- 	exports["pulsar-hud"]:Notification("success", "Updated Passcode")
			-- else
			-- 	exports["pulsar-hud"]:Notification("error", "Failed to Update Passcode")
			-- end
		end)
	end
end)
