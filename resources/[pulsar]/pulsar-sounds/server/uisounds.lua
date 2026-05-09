exports("UISoundsPlayGeneric", function(clientId, id, sound, library)
	TriggerClientEvent("UISounds:Client:Play:Generic", clientId, id, sound, library)
end)

exports("UISoundsPlayCoords", function(clientId, id, sound, library, coords)
	TriggerClientEvent("UISounds:Client:Play:Coords", clientId, id, sound, library, coords)
end)

exports("UISoundsPlayEntity", function(clientId, id, sound, library, entity)
	TriggerClientEvent("UISounds:Client:Play:Entity", clientId, id, sound, library, entity)
end)

exports("UISoundsPlayFrontEnd", function(clientId, id, sound, library)
	TriggerClientEvent("UISounds:Client:Play:FrontEnd", clientId, id, sound, library)
end)
