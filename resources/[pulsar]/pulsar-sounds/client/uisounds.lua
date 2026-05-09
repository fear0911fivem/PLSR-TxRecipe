exports("UISoundsPlayGeneric", function(id, sound, library)
	PlaySound(id, sound, library, false, false, true)
end)

exports("UISoundsPlayCoords", function(id, sound, library, coords)
	PlaySoundFromCoord(id, sound, coords.x, coords.y, coords.z, library, false, false, true)
end)

exports("UISoundsPlayEntity", function(id, sound, library, entity)
	PlaySoundFromCoord(id, sound, entity, library, false, false, true)
end)

exports("UISoundsPlayFrontEnd", function(id, sound, library)
	PlaySoundFrontend(id, sound, library, true)
end)

RegisterNetEvent("UISounds:Client:Play:Generic")
AddEventHandler("UISounds:Client:Play:Generic", function(id, sound, library)
	exports['pulsar-sounds']:UISoundsPlayGeneric(id, sound, library)
end)

RegisterNetEvent("UISounds:Client:Play:Coords")
AddEventHandler("UISounds:Client:Play:Coords", function(id, sound, library, coords)
	exports['pulsar-sounds']:UISoundsPlayCoords(id, sound, library, coords)
end)

RegisterNetEvent("UISounds:Client:Play:Entity")
AddEventHandler("UISounds:Client:Play:Entity", function(id, sound, library, entity)
	exports['pulsar-sounds']:UISoundsPlayEntity(id, sound, library, entity)
end)

RegisterNetEvent("UISounds:Client:Play:FrontEnd")
AddEventHandler("UISounds:Client:Play:FrontEnd", function(id, sound, library)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(id, sound, library)
end)
