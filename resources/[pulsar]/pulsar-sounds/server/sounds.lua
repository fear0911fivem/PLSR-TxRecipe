AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-sounds')
    RegisterCallbacks()
  end
end)

exports("PlayOne", function(clientNetId, soundFile, soundVolume)
  TriggerClientEvent("Sounds:Client:Play:One", clientNetId, soundFile, soundVolume)
end)

exports("PlayDistance", function(clientNetId, maxDistance, soundFile, soundVolume)
  TriggerClientEvent("Sounds:Client:Play:Distance", -1, clientNetId, maxDistance, soundFile, soundVolume)
end)

exports("PlayLocation", function(clientNetId, Location, maxDistance, soundFile, soundVolume)
  TriggerClientEvent(
    "Sounds:Client:Play:Location",
    -1,
    clientNetId,
    Location,
    maxDistance,
    soundFile,
    soundVolume
  )
end)

exports("PlayAll", function(clientNetId, soundFile, soundVolume)
  TriggerClientEvent("Sounds:Client:Play:One", -1, clientNetId, soundFile, soundVolume)
end)

exports("PlayJob", function(clientNetId, soundFile, job, soundVolume)
  for k, v in ipairs(GetPlayers()) do
    local myDuty = Player(v).state.onDuty
    if myDuty and job[myDuty] then
      TriggerClientEvent(
        "Sounds:Client:Play:One",
        v,
        clientNetId,
        soundFile,
        soundVolume
      )
    end
  end
end)

exports("LoopOne", function(clientNetId, soundFile, soundVolume)
  TriggerClientEvent("Sounds:Client:Loop:One", clientNetId, soundFile, soundVolume)
end)

exports("LoopDistance", function(clientNetId, maxDistance, soundFile, soundVolume)
  TriggerClientEvent("Sounds:Client:Loop:Distance", -1, clientNetId, maxDistance, soundFile, soundVolume)
end)

exports("LoopLocation", function(clientNetId, Location, maxDistance, soundFile, soundVolume)
  TriggerClientEvent(
    "Sounds:Client:Loop:Location",
    -1,
    clientNetId,
    Location,
    maxDistance,
    soundFile,
    soundVolume
  )
end)

exports("StopOne", function(clientNetId, soundFile)
  TriggerClientEvent("Sounds:Client:Stop:One", clientNetId, soundFile)
end)

exports("StopDistance", function(clientNetId, soundFile)
  TriggerClientEvent("Sounds:Client:Stop:Distance", -1, clientNetId, soundFile)
end)

exports("StopLocation", function(clientNetId, location, soundFile)
  TriggerClientEvent("Sounds:Client:Stop:Distance", -1, clientNetId, soundFile)
end)

function RegisterCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Sounds:Play:Distance", function(source, data, cb)
    exports["pulsar-sounds"]:PlayDistance(source, data.maxDistance, data.soundFile, data.soundVolume)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Sounds:Play:Location", function(source, data, cb)
    exports["pulsar-sounds"]:PlayLocation(source, data.location, data.maxDistance, data.soundFile, data.soundVolume)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Sounds:Loop:Distance", function(source, data, cb)
    exports["pulsar-sounds"]:LoopDistance(source, data.maxDistance, data.soundFile, data.soundVolume)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Sounds:Loop:Location", function(source, data, cb)
    exports["pulsar-sounds"]:LoopLocation(source, data.location, data.maxDistance, data.soundFile, data.soundVolume)
  end)

  exports["pulsar-core"]:RegisterServerCallback("Sounds:Stop:Distance", function(source, data, cb)
    exports["pulsar-sounds"]:StopDistance(source, data.soundFile)
  end)
end

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source)
  TriggerClientEvent("Sounds:Client:Stop:All", -1, source)
end)

AddEventHandler("Characters:Server:PlayerDropped", function(source)
  TriggerClientEvent("Sounds:Client:Stop:All", -1, source)
end)

AddEventHandler("Sounds:Server:Play:One", function(soundFile, soundVolume)
  exports["pulsar-sounds"]:PlayOne(soundFile, soundVolume)
end)

AddEventHandler("Sounds:Server:Play:Distance", function(playerNetId, maxDistance, soundFile, soundVolume)
  exports["pulsar-sounds"]:PlayDistance(playerNetId, maxDistance, soundFile, soundVolume)
end)

AddEventHandler("Sounds:Server:Play:All", function(playerNetId, soundFile, soundVolume)
  exports["pulsar-sounds"]:PlayAll(playerNetId, soundFile, soundVolume)
end)

AddEventHandler("Sounds:Server:Play:Job", function(playerNetId, soundFile, job, soundVolume)
  exports["pulsar-sounds"]:PlayJob(playerNetId, soundFile, job, soundVolume)
end)

AddEventHandler("Sounds:Server:Loop:One", function(soundFile, soundVolume)
  exports["pulsar-sounds"]:LoopOne(soundFile, soundVolume)
end)

AddEventHandler("Sounds:Server:Loop:Distance", function(playerNetId, maxDistance, soundFile, soundVolume)
  exports["pulsar-sounds"]:LoopDistance(playerNetId, maxDistance, soundFile, soundVolume)
end)

AddEventHandler("Sounds:Server:Stop:One", function(soundFile)
  exports["pulsar-sounds"]:StopOne(soundFile)
end)

AddEventHandler("Sounds:Server:Stop:Distance", function(playerNetId, soundFile)
  exports["pulsar-sounds"]:StopDistance(playerNetId, soundFile)
end)
