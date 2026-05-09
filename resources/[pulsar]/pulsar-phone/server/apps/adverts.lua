local _adverts = {
	["0"] = {},
	-- Lua, Suck My Dick
}

exports("AdvertsCreate", function(source, advert)
	_adverts[source] = advert
	TriggerClientEvent("Phone:Client:AddData", -1, "adverts", advert, source)
end)

exports("AdvertsUpdate", function(source, advert)
	_adverts[source] = advert
	TriggerClientEvent("Phone:Client:UpdateData", -1, "adverts", source, advert)
end)

exports("AdvertsDelete", function(source)
	if _adverts[source] ~= nil then
		_adverts[source] = nil
		TriggerClientEvent("Phone:Client:RemoveData", -1, "adverts", source)
	end
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Adverts:Create", function(source, data, cb)
		exports['pulsar-phone']:AdvertsCreate(source, data)
	end)
	exports["pulsar-core"]:RegisterServerCallback("Phone:Adverts:Update", function(source, data, cb)
		exports['pulsar-phone']:AdvertsUpdate(source, data)
	end)
	exports["pulsar-core"]:RegisterServerCallback("Phone:Adverts:Delete", function(source, data, cb)
		exports['pulsar-phone']:AdvertsDelete(source)
	end)
end)

AddEventHandler("Phone:Server:RegisterMiddleware", function()
	exports['pulsar-core']:MiddlewareAdd("Phone:Spawning", function(source, char)
		return {
			{
				type = "adverts",
				data = _adverts,
			},
		}
	end)
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source, cData)
	exports['pulsar-phone']:AdvertsDelete(source)
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source, cData)
	exports['pulsar-phone']:AdvertsDelete(source)
end)
