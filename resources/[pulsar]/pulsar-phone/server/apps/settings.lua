AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Settings:Update", function(source, data, cb)
		local src = source
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		local settings = char:GetData("PhoneSettings")
		settings[data.type] = data.val
		char:SetData("PhoneSettings", settings)
	end)
end)
