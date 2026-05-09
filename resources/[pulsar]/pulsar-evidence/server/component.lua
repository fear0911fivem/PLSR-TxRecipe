EVIDENCE_CACHE = {}

RegisterNetEvent("Evidence:Server:RecieveEvidence", function(newEvidence)
  local _src = source

  local time = os.time()

  for k, v in ipairs(newEvidence) do
    v.id = string.format("%s-%s", os.date("%d%m%y-%H%M%S", time), 100000 + #EVIDENCE_CACHE)
    v.time = GetGameTimer()
    v.client = _src

    table.insert(EVIDENCE_CACHE, v)
  end
end)

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    StartDeletionThread()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-evidence')

    exports["pulsar-core"]:RegisterServerCallback("Evidence:Fetch", function(source, data, cb)
      cb(EVIDENCE_CACHE)
    end)

    RegisterBallisticsCallbacks()
    RegisterBallisticsItemUses()
  end
end)

local _deletionThead = false

function StartDeletionThread()
  if not _deletionThead then
    _deletionThead = true

    CreateThread(function()
      while true do
        Wait((60 * 1000) * 30)

        if #EVIDENCE_CACHE > 0 then
          local removed = 0
          local currentTimer = GetGameTimer()
          for k, v in ipairs(EVIDENCE_CACHE) do
            if (currentTimer - v.time) >= ((60 * 1000) * 120) then
              table.remove(EVIDENCE_CACHE, k)
              removed = removed + 1
            end
          end

          if removed > 0 then
            TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
            collectgarbage()
          end
        end
      end
    end)
  end
end

AddEventHandler("Sync:Server:WeatherChange", function(weather)
  if IsWeatherTypeRain(weather) then
    -- Wash away evidence after a bit
    if #EVIDENCE_CACHE > 0 then
      SetTimeout(45000, function()
        local removed = 0
        for k, v in ipairs(EVIDENCE_CACHE) do
          if v.type == "blood" then
            table.remove(EVIDENCE_CACHE, k)
            removed = removed + 1
          end
        end

        if removed > 0 then
          TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
          collectgarbage()
        end
      end)
    end
  end
end)

RegisterNetEvent("Evidence:Server:PickupEvidence", function(evidenceId)
  local _src = source
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char and exports['pulsar-jobs']:HasJob(_src, "police") then
    for k, v in ipairs(EVIDENCE_CACHE) do
      if v.id == evidenceId then
        local itemName, metadata
        local collectedTime = os.time()

        if v.type == "paint_fragment" then
          itemName = "evidence-paint"
          local color = v.data and v.data.color
          metadata = {
            EvidenceType = v.type,
            EvidenceId = v.id,
            EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
            EvidenceColor = color,
            CollectedTime = collectedTime,
            description = color and string.format(
              "Paint Fragment\nRGB: (%d, %d, %d)",
              color.r or 0,
              color.g or 0,
              color.b or 0
            ) or "Paint Fragment",
          }
        elseif v.type == "projectile" then
          itemName = "evidence-projectile"
          local degraded = v.data and v.data.tooDegraded
          metadata = {
            EvidenceType = v.type,
            EvidenceId = v.id,
            EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
            EvidenceWeapon = v.data and v.data.weapon,
            EvidenceAmmoType = (v.data and v.data.weapon) and v.data.weapon.ammoTypeName,
            EvidenceDegraded = degraded,
            CollectedTime = collectedTime,
            description = degraded and "⚠️ Evidence too degraded for analysis" or string.format(
              "Evidence ID: %s\nAmmo: %s",
              v.id or "N/A",
              (v.data and v.data.weapon) and v.data.weapon.ammoTypeName or "Unknown"
            ),
          }
        elseif v.type == "casing" then
          itemName = "evidence-casing"
          local weapon = v.data and v.data.weapon
          local weaponLabel = "Unknown Weapon"
          if weapon and weapon.name then
            local ItemList = require 'modules.items.shared'
            local weaponItem = ItemList[weapon.name]
            weaponLabel = (weaponItem and weaponItem.label) or weapon.name or "Unknown Weapon"
          end
          metadata = {
            EvidenceType = v.type,
            EvidenceId = v.id,
            EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
            EvidenceWeapon = weapon,
            EvidenceAmmoType = weapon and weapon.ammoTypeName,
            CollectedTime = collectedTime,
            description = (weapon and weapon.serial) and string.format(
              "Casing from %s\nSerial: %s\nAmmo: %s",
              weaponLabel,
              weapon.serial,
              weapon.ammoTypeName or "Unknown"
            ) or "Casing Evidence",
          }
        elseif v.type == "blood" then
          itemName = "evidence-dna"
          local degraded = v.data and v.data.tooDegraded
          local dna = v.data and v.data.DNA
          metadata = {
            EvidenceType = v.type,
            EvidenceId = v.id,
            EvidenceCoords = { x = v.coords.x, y = v.coords.y, z = v.coords.z },
            EvidenceDNA = dna,
            EvidenceBloodPool = v.data and v.data.IsBloodPool,
            EvidenceDegraded = degraded,
            CollectedTime = collectedTime,
            description = degraded and "⚠️ DNA sample too degraded for analysis" or (dna and string.format(
              "%s DNA Sample\nSID: %s",
              (v.data and v.data.IsBloodPool) and "Blood Pool" or "Blood",
              dna
            ) or "DNA Evidence"),
          }
        end

        if itemName then
          exports.ox_inventory:AddItem(
            char:GetData("SID"),
            itemName,
            1,
            metadata,
            1
          )

          table.remove(EVIDENCE_CACHE, k)
          TriggerClientEvent("Evidence:Client:ForceUpdateEvidence", -1)
        end
        break
      end
    end
  end
end)

local pendingSend = false

RegisterServerEvent("Camara:CapturePhoto", function()
  local src = source
  local char = exports['pulsar-characters']:FetchCharacterSource(src)

  if char then
    if pendingSend then
      exports['pulsar-hud']:Notification(src, "warning",
        "Please wait while current photo is uploading", 2000)
      return
    end
    pendingSend = true
    exports['pulsar-hud']:Notification(src, "info", "Prepping Photo Upload", 2000)

    local options = {
      encoding = "webp",
      quality = 0.8,
    }

    local webhookUsername = GetConvar("evidence_webhook_username", "Evidence Camera")
    exports["discord-screenshot"]:requestCustomClientScreenshotUploadToDiscord(
      src,
      tostring(GetConvar("evidence_selfie_webhook", "")),
      options,
      {
        username = webhookUsername,
        avatar_url = "https://i.ibb.co/1Yg16pK/icon.png",
        content = "",
        embeds = {
          {
            color = 0xff9900,
            title = string.format(
              "New Evidence Posted by @%s_%s",
              char:GetData("First"),
              char:GetData("Last")
            ),
            author = {
              name = webhookUsername,
              icon_url = "https://i.ibb.co/1Yg16pK/icon.png",
            },
            footer = {
              text = string.format("%s %s | %s", char:GetData("First"), char:GetData("Last"), src),
            },
          },
        },
      },
      5000,
      function(error)
        if error then
          pendingSend = false
          exports['pulsar-hud']:Notification(src, "error", "Error uploading photo!", 2000)
          print("^1ERROR: " .. error .. "^7")
        end
        pendingSend = false
        exports['pulsar-hud']:Notification(src, "success", "Photo uploaded successfully!",
          2000)
      end
    )
  end
end)
