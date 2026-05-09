RegisterNUICallback("UpdateSetting", function(data, cb)
	cb("OK")
	_settings[data.type] = data.val
	exports["pulsar-core"]:ServerCallback("Phone:Settings:Update", data)
end)

local testingSound = nil
RegisterNUICallback("TestSound", function(data, cb)
	cb("OK")

	if testingSound ~= nil then
		exports["pulsar-sounds"]:StopOne(testingSound)
		testingSound = nil
	end

	testingSound = data.val
	exports["pulsar-sounds"]:PlayOne(data.val, 0.1 * (_settings.volume / 100))
end)
