voiceData = {}
radioData = {}
callData = {}

local mappedChannels = {}

function firstFreeChannel()
  for i = 1, 2048 do
    if not mappedChannels[i] then
      return i
    end
  end

  return 0
end

function GetDefaultPlayerVOIPData(source)
  return {
    Radio = 0,
    Call = 0,
    LastRadio = 0,
    LastCall = 0,
  }
end

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-voip')
    RegisterMiddleware()
    RegisterItems()

    local mAddress = GetConvar("ext_mumble_address", "")
    if mAddress ~= "" then
      GlobalState.MumbleAddress = mAddress
      GlobalState.MumblePort = GetConvarInt("ext_mumble_port", 64738)
    end

    --RegisterChatCommands()
  end
end)

function RegisterItems()
  exports.ox_inventory:RegisterUse("radio", "VOIP", function(source, itemData)
    TriggerClientEvent("Radio:Client:OpenUI", source, 1)
  end)

  exports.ox_inventory:RegisterUse("radio_shitty", "VOIP", function(source, itemData)
    TriggerClientEvent("Radio:Client:OpenUI", source, 3)
  end)

  exports.ox_inventory:RegisterUse("radio_extendo", "VOIP", function(source, itemData)
    TriggerClientEvent("Radio:Client:OpenUI", source, 2)
  end)

  exports.ox_inventory:RegisterUse("megaphone", "VOIP", function(source, itemData)
    TriggerClientEvent("VOIP:Client:Megaphone:Use", source, false)
  end)
end

RegisterNetEvent('ox_inventory:ready', function()
  if GetResourceState(GetCurrentResourceName()) == 'started' then
    RegisterItems()
  end
end)

function RegisterMiddleware()
  exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
    exports["pulsar-voip"]:AddPlayer(source)
  end, 3)
end

exports("AddPlayer", function(source)
  if not voiceData[source] then
    voiceData[source] = GetDefaultPlayerVOIPData()

    local plyState = Player(source).state

    if plyState then
      local chan = firstFreeChannel()
      if chan > 0 then
        MumbleCreateChannel(chan)

        mappedChannels[chan] = source
        plyState:set("voiceChannel", chan, true)
      end
    end
  end
end)

exports("RemovePlayer", function(source)
  if voiceData[source] then
    local plyData = voiceData[source]

    if plyData.Radio > 0 then
      exports["pulsar-voip"]:RadioSetChannel(source, 0)
    end

    if plyData.Call > 0 then
      exports["pulsar-voip"]:SetChannel(source, 0)
    end

    voiceData[source] = nil
  end

  local aChannel = Player(source).state.voiceChannel
  if aChannel then
    mappedChannels[aChannel] = nil
  end
end)

AddEventHandler("Characters:Server:PlayerLoggedOut", function(source)
  exports["pulsar-voip"]:RemovePlayer(source)
end)
