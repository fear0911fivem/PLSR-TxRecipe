exports("ActionShow", function(id, message, duration)
	local formattedMessage = string.gsub(
		message,
		"{keybind}([A-Za-z!\"#$%&'()*+,-./[\\%]^_`|~]+){/keybind}",
		function(key)
			local keyName = exports["pulsar-kbs"]:GetKey(key) or "Unknown"
			return "{key}" .. keyName .. "{/key}"
		end
	)

	SendNUIMessage({
		type = "ADD_ACTION",
		data = {
			id = id,
			message = formattedMessage,
		},
	})
end)

exports("ActionHide", function(id)
	SendNUIMessage({
		type = "REMOVE_ACTION",
		data = {
			id = id,
		}
	})
end)

exports("ActionHideAll", function()
	SendNUIMessage({
		type = "REMOVE_ALL_ACTIONS",
	})
end)

RegisterNetEvent("Characters:Client:Logout", function()
	exports['pulsar-hud']:ActionHideAll()
end)
