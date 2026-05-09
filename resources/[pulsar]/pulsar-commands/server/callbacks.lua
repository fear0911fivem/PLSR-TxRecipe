function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Commands:ValidateAdmin", function(source, data, cb)
		local player = exports['pulsar-core']:FetchSource(source)
		if player.Permissions:IsAdmin() then
			cb(true)
		else
			exports['pulsar-core']:LoggerError("Commands",
				string.format("%s attempted to use an admin command but failed Admin Validation.", {
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
						type = "error",
					},
				}, player:GetData("Identifier"))
			)
		end
	end)
end
