function RegisterChatCommands()
	exports["pulsar-chat"]:RegisterCommand("resetphonepos", function(source, args, rawCommand)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			char:SetData("PhonePosition", {
				x = 25,
				y = 25,
			})
			TriggerClientEvent("Phone:Client:RestorePosition", source, char:GetData("PhonePosition"))
			exports["pulsar-chat"]:SendSystemSingle(source, "Phone Position Reset")
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Unable To Reset Phone Position")
		end
	end, {
		help = "Resets your phones position",
	}, 0)

	exports["pulsar-chat"]:RegisterAdminCommand("clearalias", function(source, args, rawCommand)
		if tonumber(args[1]) then
			local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))

			if char ~= nil then
				local aliases = char:GetData("Alias")
				aliases[args[2]] = nil
				char:SetData("Alias", aliases)
				exports["pulsar-chat"]:SendSystemSingle(
					source,
					string.format(
						"Alias Cleared For %s %s (%s) For %s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						args[2]
					)
				)
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Target")
			end
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Target")
		end
	end, {
		help = "[Admin] Clear Player App Alias",
		params = {
			{
				name = "SID",
				help = "Target State ID",
			},
			{
				name = "App ID",
				help = "App ID to reset the players alias for",
			},
		},
	}, 2)

	exports["pulsar-chat"]:RegisterAdminCommand("clearprofile", function(source, args, rawCommand)
		if tonumber(args[1]) then
			local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
			if char ~= nil then
				local profiles = char:GetData("Profiles") or {}

				if profiles[args[2]] ~= nil then
					local queries = {}
					table.insert(queries, {
						query = "INSERT INTO app_profile_history (sid, app, name, picture, meta) VALUES(?, ?, ?, ?, ?)",
						values = {
							char:GetData("SID"),
							args[2],
							profiles[args[2]].name,
							profiles[args[2]].picture,
							json.encode(profiles[args[2]].meta or {}),
						},
					})
					table.insert(queries, {
						query = "DELETE FROM character_app_profiles WHERE sid = ? AND app = ?",
						values = {
							char:GetData("SID"),
							args[2],
						},
					})
					MySQL.transaction(queries)

					profiles[args[2]] = nil
					char:SetData("Profiles", profiles)
					exports["pulsar-chat"]:SendSystemSingle(
						source,
						string.format(
							"Profile Cleared For %s %s (%s) For %s",
							char:GetData("First"),
							char:GetData("Last"),
							char:GetData("SID"),
							args[2]
						)
					)
				else
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Target")
			end
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Target")
		end
	end, {
		help = "[Admin] Clear Player App Alias",
		params = {
			{
				name = "SID",
				help = "Target State ID",
			},
			{
				name = "App ID",
				help = "App ID to reset the players alias for",
			},
		},
	}, 2)

	exports["pulsar-chat"]:RegisterStaffCommand("ctwitter", function(source, args, rawCommand)
		ClearAllTweets(args[1])
		exports["pulsar-chat"]:SendSystemSingle(source, "All Tweets Removed")
	end, {
		help = "[Admin] Clear All Tweets",
		params = {
			{
				name = "SID",
				help = "(Optional) Target State ID",
			},
		},
	}, -1)

	exports["pulsar-chat"]:RegisterStaffCommand("twitteraccount", function(source, args, rawCommand)
		local twitterName = args[1]

		local sid = MySQL.scalar.await("SELECT sid FROM character_app_profiles WHERE name = ? AND app = ?", {
			twitterName,
			"twitter",
		})

		local char = exports['pulsar-characters']:FetchBySID(sid)
		if char ~= nil then
			exports["pulsar-chat"]:SendSystemSingle(
				source,
				string.format(
					"Twitter Account Found With Name: %s. %s %s (SID: %s) [User: %s]",
					twitterName,
					char:GetData("First"),
					char:GetData("Last"),
					sid,
					char:GetData("User")
				)
			)
		else
			exports["pulsar-chat"]:SendSystemSingle(source, "No Twitter Account Found")
		end
	end, {
		help = "[Admin] Get Twitter Account Owner",
		params = {
			{
				name = "Account Name",
				help = "Account Name of User You Want to Find",
			},
		},
	}, 1)

	exports["pulsar-chat"]:RegisterAdminCommand("govtweet", function(source, args, rawCommand)
		local accountName, accountAvatar, content, image = args[1], args[2], args[3], args[4]

		if accountName and accountAvatar and content then
			if image then
				image = {
					using = true,
					link = image,
				}
			else
				image = {
					using = false,
				}
			end

			exports['pulsar-phone']:TwitterPost(-1, -1, {
				name = accountName,
				picture = accountAvatar,
			}, content, image, false, "government")
			exports["pulsar-chat"]:SendSystemSingle(source, "Tweet Sent")
		end
	end, {
		help = "[Admin] Send GOVERNMENT ACCOUNT Tweet",
		params = {
			{
				name = "Account Name",
				help = "",
			},
			{
				name = "Account Avatar",
				help = "",
			},
			{
				name = "Tweet Content",
				help = "",
			},
			{
				name = "Tweet Image",
				help = "",
			},
		},
	}, -1)

	exports["pulsar-chat"]:RegisterAdminCommand("reloadtracks", function(source, args, rawCommand)
		ReloadRaceTracks()
		exports["pulsar-chat"]:SendSystemSingle(source, "Reloaded Vroom Vrooms")
	end, {
		help = "[Admin] Reload Race Tracks",
	}, 0)

	exports["pulsar-chat"]:RegisterAdminCommand("reloadpdtracks", function(source, args, rawCommand)
		ReloadRaceTracksPD()
		exports["pulsar-chat"]:SendSystemSingle(source, "Reloaded PD Vroom Vrooms")
	end, {
		help = "[Admin] Reload PD Race Tracks",
	}, 0)

	exports["pulsar-chat"]:RegisterAdminCommand("raceinvite", function(source, args, rawCommand)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char then
			local id, count = args[1], tonumber(args[2])

			if IsRedlineRace(id) then
				exports.ox_inventory:AddItem(char:GetData("SID"), "event_invite", count, {
					Event = id,
				}, 1)
			else
				exports['pulsar-hud']:Notification(source, "error", "Invalid Race Event")
			end
		end
	end, {
		help = "[Admin] Create Race Invite Items",
		params = {
			{
				name = "Event ID",
				help = "ID of the race that using the invite will add you to",
			},
			{
				name = "Quantity",
				help = "How many invites to create",
			},
		},
	}, 2)
end
