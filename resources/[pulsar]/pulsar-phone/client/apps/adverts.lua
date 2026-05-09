RegisterNUICallback("CreateAdvert", function(data, cb)
	cb("OK")
	exports["pulsar-core"]:ServerCallback("Phone:Adverts:Create", data)
end)

RegisterNUICallback("UpdateAdvert", function(data, cb)
	cb("OK")
	exports["pulsar-core"]:ServerCallback("Phone:Adverts:Update", data)
end)

RegisterNUICallback("DeleteAdvert", function(data, cb)
	cb("OK")
	exports["pulsar-core"]:ServerCallback("Phone:Adverts:Delete")
end)
