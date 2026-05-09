AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterMiddleware()
    RegisterChatCommands()
    RegisterItems()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-core')
  end
end)

function RegisterMiddleware()
  exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char:GetData("Animations") == nil then
      char:SetData("Animations", { walk = "default", expression = "default", emoteBinds = {} })
    end
  end, 10)
end

function RegisterChatCommands()
  exports["pulsar-chat"]:RegisterCommand("e", function(source, args, rawCommand)
    local emote = args[1]
    if emote == "c" or emote == "cancel" then
      TriggerClientEvent("Animations:Client:CharacterCancelEmote", source)
    else
      TriggerClientEvent("Animations:Client:CharacterDoAnEmote", source, emote)
    end
  end, {
    help = "Do An Emote or Dance",
    params = { {
      name = "Emote",
      help = "Name of The Emote",
    } },
  })
  exports["pulsar-chat"]:RegisterCommand("emotes", function(source, args, rawCommand)
    TriggerClientEvent("Animations:Client:OpenMainEmoteMenu", source)
  end, {
    help = "Open Emote Menu",
  })
  exports["pulsar-chat"]:RegisterCommand("emotebinds", function(source, args, rawCommand)
    TriggerClientEvent("Animations:Client:OpenEmoteBinds", source)
  end, {
    help = "Edit Emote Binds",
  })
  exports["pulsar-chat"]:RegisterCommand("walks", function(source, args, rawCommand)
    TriggerClientEvent("Animations:Client:OpenWalksMenu", source)
  end, {
    help = "Change Walk Style",
  })
  exports["pulsar-chat"]:RegisterCommand("face", function(source, args, rawCommand)
    TriggerClientEvent("Animations:Client:OpenExpressionsMenu", source)
  end, {
    help = "Change Facial Expression",
  })
  exports["pulsar-chat"]:RegisterCommand("selfie", function(source, args, rawCommand)
    if
        not Player(source).state.isCuffed
        and not Player(source).state.isDead
        and exports.ox_inventory:GetItemCount(source, 'phone') > 0
    then
      TriggerClientEvent("Animations:Client:Selfie", source)
    else
      exports['pulsar-hud']:Notification(source, "error", "You do not have a phone.")
    end
  end, {
    help = "Open Selfie Mode",
  })
end

function RegisterCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Animations:UpdatePedFeatures", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
      cb(exports['pulsar-animations']:PedFeaturesUpdateFeatureInfo(char, data.type, data.data))
    else
      cb(false)
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Animations:UpdateEmoteBinds", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
      cb(exports['pulsar-animations']:EmoteBindsUpdate(char, data), data)
    else
      cb(false)
    end
  end)
end

exports("PedFeaturesUpdateFeatureInfo", function(char, type, data, cb)
  if type == "walk" then
    local currentData = char:GetData("Animations")
    char:SetData(
      "Animations",
      { walk = data, expression = currentData.expression, emoteBinds = currentData.emoteBinds }
    )
    return true
  elseif type == "expression" then
    local currentData = char:GetData("Animations")
    char:SetData(
      "Animations",
      { walk = currentData.walk, expression = data, emoteBinds = currentData.emoteBinds }
    )
    return true
  end
  return false
end)

exports("EmoteBindsUpdate", function(char, data, cb)
  local currentData = char:GetData("Animations")
  char:SetData(
    "Animations",
    { walk = currentData.walk, expression = currentData.expression, emoteBinds = data }
  )
  return true
end)

RegisterServerEvent("Animations:Server:ClearAttached", function(propsToDelete)
  local src = source
  local ped = GetPlayerPed(src)

  if ped then
    for k, v in ipairs(GetAllObjects()) do
      if DoesEntityExist(v) and GetEntityAttachedTo(v) == ped and propsToDelete[GetEntityModel(v)] then
        DeleteEntity(v)
      end
    end
  end
end)

local pendingSend = false

RegisterServerEvent("Selfie:CaptureSelfie", function()
  local src = source
  local char = exports['pulsar-characters']:FetchCharacterSource(src)
  if not char then return end

  if pendingSend then
    exports['pulsar-hud']:Notification(src, "warning", "Please wait while current photo is uploading", 2000)
    return
  end

  pendingSend = true
  exports['pulsar-hud']:Notification(src, "info", "Prepping Photo Upload", 2000)

  local webhookUrl = tostring(GetConvar("phone_selfie_webhook", ""))
  if webhookUrl == "" then
    pendingSend = false
    TriggerClientEvent("Selfie:DoCloseSelfie", src)
    exports['pulsar-hud']:Notification(src, "error", "Selfie upload is not configured.", 2000)
    return
  end

  exports["screencapture"]:remoteUpload(
    src,
    webhookUrl,
    {
      encoding = "webp",
      quality = 0.8,
      headers = { Authorization = tostring(GetConvar("phone_selfie_token", "")) },
      formField = "image"
    },
    function(response)
      local image = type(response) == "table" and response or (type(response) == "string" and json.decode(response) or nil)
      local imageUrl = image and image.url

      if not imageUrl then
        print("^1[pulsar-animations] Selfie upload failed. Response: " .. json.encode(response) .. "^0")
        pendingSend = false
        TriggerClientEvent("Selfie:DoCloseSelfie", src)
        exports['pulsar-hud']:Notification(src, "error", "Error uploading photo!", 2000)
        return
      end

      local retval = exports['pulsar-phone']:PhotosCreate(src, { image_url = imageUrl })
      pendingSend = false
      TriggerClientEvent("Selfie:DoCloseSelfie", src)
      if retval then
        exports['pulsar-hud']:Notification(src, "success", "Photo uploaded successfully!", 2000)
      else
        exports['pulsar-hud']:Notification(src, "error", "Error uploading photo!", 2000)
      end
    end,
    "blob"
  )
end)
