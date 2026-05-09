RegisterNUICallback("UpdateSetting", function(data, cb)
	cb("OK")
	_settings[data.type] = data.val
	exports["pulsar-core"]:ServerCallback("Laptop:Settings:Update", data)
end)
