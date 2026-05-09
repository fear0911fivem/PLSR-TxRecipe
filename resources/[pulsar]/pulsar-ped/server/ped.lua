local TemplateData = {
  model = "",
  customization = {
    face = {
      face1 = {
        index = 0,
        texture = 0,
        mix = 50.0,
      },
      face2 = {
        index = 0,
        texture = 0,
        mix = 50.0,
      },
      face3 = {
        index = 0,
        texture = 0,
        mix = 100.0,
      },
      features = {
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      },
    },
    eyeColor = 0,
    overlay = {
      blemish = {
        id = 0,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      facialhair = {
        id = 1,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      eyebrows = {
        id = 2,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      ageing = {
        id = 3,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      makeup = {
        id = 4,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      blush = {
        id = 5,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      complexion = {
        id = 6,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      sundamage = {
        id = 7,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      lipstick = {
        id = 8,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      freckles = {
        id = 9,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      chesthair = {
        id = 10,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      bodyblemish = {
        id = 11,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
      addbodyblemish = {
        id = 12,
        index = 0,
        opacity = 100.0,
        disabled = true,
      },
    },
    colors = {
      hair = {
        color1 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
        color2 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
      },
      facialhair = {
        color1 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
        color2 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
      },
      eyebrows = {
        color1 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
        color2 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
      },
      chesthair = {
        color1 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
        color2 = {
          index = 0,
          rgb = "rgb(0, 0, 0)",
        },
      },
    },
    components = {
      face = {
        componentId = 0,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      mask = {
        componentId = 1,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      hair = {
        componentId = 2,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      torso = {
        componentId = 3,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      leg = {
        componentId = 4,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      bag = {
        componentId = 5,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      shoes = {
        componentId = 6,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      accessory = {
        componentId = 7,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      undershirt = {
        componentId = 8,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      kevlar = {
        componentId = 9,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      badge = {
        componentId = 10,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
      torso2 = {
        componentId = 11,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      },
    },
    props = {
      hat = {
        componentId = 0,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      },
      glass = {
        componentId = 1,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      },
      ear = {
        componentId = 2,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      },
      watch = {
        componentId = 6,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      },
      bracelet = {
        componentId = 7,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      },
    },
    tattoos = {},
  },
}

GlobalState["Ped:Pricing"] = {
  CREATOR = 0,
  BARBER = 100,
  SHOP = 100,
  TATTOO = 100,
  SURGERY = 2500,
}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterItemUses()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-ped')
    GlobalState["GangChains"] = _gangChains
    GlobalState["ClothingStoreHidden"] = _hideFromStore

    exports["pulsar-chat"]:RegisterCommand("m0", function(source, args, rawCommand)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local ped = char:GetData("Ped")
        if ped.customization.components.mask.drawableId ~= 0 then
          TriggerClientEvent("Ped:Client:MaskAnim", source)
          Wait(300)
          exports['pulsar-ped']:MaskUnequip(source)
        end
      end
    end, {
      help = "Remove Mask",
    })

    exports["pulsar-chat"]:RegisterCommand("h0", function(source, args, rawCommand)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local ped = char:GetData("Ped")
        if not ped.customization.props.hat.disabled then
          TriggerClientEvent("Ped:Client:HatGlassAnim", source)
          Wait(300)
          exports['pulsar-ped']:HatUnequip(source)
        end
      end
    end, {
      help = "Remove Hat",
    })

    exports["pulsar-chat"]:RegisterCommand("h1", function(source, args, rawCommand)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local ped = char:GetData("Ped")
        if not ped.customization.props.hat.disabled then
          TriggerClientEvent("Ped:Client:HatGlassAnim", source)
          Wait(300)
          TriggerClientEvent("Ped:Client:Hat", source)
        end
      end
    end, {
      help = "Re-equip Hat If You Had One",
    })

    exports["pulsar-chat"]:RegisterCommand("g1", function(source, args, rawCommand)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local ped = char:GetData("Ped")
        if not ped.customization.props.glass.disabled then
          TriggerClientEvent("Ped:Client:HatGlassAnim", source)
          Wait(300)
          TriggerClientEvent("Ped:Client:Glasses", source)
        end
      end
    end, {
      help = "Re-equip Glasses If You Had One",
    })

    exports["pulsar-chat"]:RegisterCommand("g0", function(source, args, rawCommand)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        TriggerClientEvent("Ped:Client:RemoveGlasses", source)
      end
    end, {
      help = "Remove Glasses",
    })

    exports["pulsar-chat"]:RegisterAdminCommand("pedwhitelist", function(source, args, rawCommand)
      local sid, model, label = tonumber(args[1]), args[2], args[3]
      if sid and model and label then
        MySQL.Async.fetchAll('SELECT SID FROM characters WHERE SID = @sid LIMIT 1', {
          ['@sid'] = sid
        }, function(results)
          if #results > 0 then
            MySQL.Async.execute(
              'INSERT INTO whitelisted_peds (sid, model, label) VALUES (@sid, @model, @label)', {
                ['@sid'] = sid,
                ['@model'] = model,
                ['@label'] = label
              }, function(affectedRows)
                if affectedRows > 0 then
                  exports["pulsar-chat"]:SendSystemSingle(source,
                    string.format("Added Whitelisted Ped to State ID %s", sid))
                else
                  exports["pulsar-chat"]:SendSystemSingle(source, "Failed to add Whitelisted Ped")
                end
              end)
          else
            exports["pulsar-chat"]:SendSystemSingle(source, "Invalid State ID")
          end
        end)
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
      end
    end, {
      help = "Add Whitelisted Ped to Character",
      params = {
        {
          name = "SID",
          help = "Character State ID",
        },
        {
          name = "Model",
          help = "Ped Model e.g. mp_m_freemode_01",
        },
        {
          name = "Label",
          help = "Ped Name",
        },
      },
    }, 3)

    exports["pulsar-chat"]:RegisterAdminCommand("pedwhitelistview", function(source, args, rawCommand)
      local sid = tonumber(args[1])
      if sid then
        local res = MySQL.query.await("SELECT model, label FROM whitelisted_peds WHERE sid = ?", {
          sid
        })

        local message = "Whitelisted Peds<br>"
        for k, v in ipairs(res) do
          message = message .. string.format("Model: %s | Label: %s", v.model, v.label)
        end
        exports["pulsar-chat"]:SendSystemSingle(source, message)
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
      end
    end, {
      help = "View Whitelisted Peds for Character",
      params = {
        {
          name = "SID",
          help = "Character State ID",
        },
      },
    }, 1)

    exports["pulsar-chat"]:RegisterAdminCommand("pedwhitelistremove", function(source, args, rawCommand)
      local sid, model = tonumber(args[1]), args[2]
      if sid and model then
        local d = MySQL.query.await("DELETE FROM whitelisted_peds WHERE SID = ? AND model = ?", {
          sid,
          model,
        })

        if d.affectedRows > 0 then
          exports["pulsar-chat"]:SendSystemSingle(source, "Deleted Ped")
        else
          exports["pulsar-chat"]:SendSystemSingle(source, "Failed to Delete")
        end
      else
        exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
      end
    end, {
      help = "Remove Whitelisted Ped from Character",
      params = {
        {
          name = "SID",
          help = "Character State ID",
        },
        {
          name = "Model",
          help = "Ped Model e.g. mp_m_freemode_01",
        },
      },
    }, 2)
  end
end)

exports("Save", function(char, ped)
  if ped and ped.customization and ped.customization.face and ped.customization.face.features and type(ped.customization.face.features) == "table" then
    for k, v in pairs(ped.customization.face.features) do
      ped.customization.face.features[tostring(k)] = v
    end
  end

  local savePedQuery = MySQL.query.await([[
		INSERT INTO `peds` (`char`, `ped`) VALUES (?, ?)
		ON DUPLICATE KEY UPDATE `ped` = VALUES(`ped`)
	  ]], { char:GetData("ID"), json.encode(ped) })

  if not savePedQuery then
    return false
  end

  char:SetData("Ped", ped)

  return true
end)

exports("ApplyOutfit", function(source, outfit)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    ped.customization.components = outfit.data.components or ped.customization.components
    ped.customization.props = outfit.data.props or ped.customization.props
    ped.customization.colors = outfit.data.colors or ped.customization.colors
    ped.customization.overlay = outfit.data.overlay or ped.customization.overlay
    exports['pulsar-ped']:Save(char, ped)
  end
end)

exports("MaskEquip", function(source, data)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    ped.customization.components.mask = data
    exports['pulsar-ped']:Save(char, ped)
  end
end)

exports("MaskUnequip", function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")

    local itemId = exports.ox_inventory:GetWithStaticMetadata(
      "mask",
      "drawableId",
      "textureId",
      char:GetData("Gender"),
      ped.customization.components.mask
    ) or "mask"

    local md = { mask = ped.customization.components.mask }
    if itemId ~= "mask" then
      md = {}
    end

    if exports.ox_inventory:AddItem(char:GetData("SID"), itemId, 1, md, 1) then
      ped.customization.components.mask = {
        componentId = 1,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      }
      exports['pulsar-ped']:Save(char, ped)
    end
  end
end)

exports("MaskUnequipNoItem", function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    if ped.customization.components.mask.drawableId ~= 0 then
      TriggerClientEvent("Ped:Client:MaskAnim", source)
      ped.customization.components.mask = {
        componentId = 1,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      }
      exports['pulsar-ped']:Save(char, ped)
    end
  end
end)

exports("HatEquip", function(source, data)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    ped.customization.props.hat = data
    exports['pulsar-ped']:Save(char, ped)
  end
end)

exports("HatUnequip", function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")

    local itemId = exports.ox_inventory:GetWithStaticMetadata(
      "hat",
      "drawableId",
      "textureId",
      char:GetData("Gender"),
      ped.customization.props.hat
    ) or "hat"

    local md = { hat = ped.customization.props.hat }
    if itemId ~= "hat" then
      md = {}
    end

    if exports.ox_inventory:AddItem(char:GetData("SID"), itemId, 1, md, 1) then
      ped.customization.props.hat = {
        componentId = 0,
        drawableId = 0,
        textureId = 0,
        disabled = true,
      }
      exports['pulsar-ped']:Save(char, ped)
    end
  end
end)

exports("NecklaceEquip", function(source, data)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    ped.customization.components.accessory = data
    exports['pulsar-ped']:Save(char, ped)
  end
end)

exports("NecklaceUnequip", function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    local itemId = exports.ox_inventory:GetWithStaticMetadata(
      "accessory",
      "drawableId",
      "textureId",
      char:GetData("Gender"),
      ped.customization.components.accessory
    ) or "accessory"

    if itemId ~= "accessory" then
      if exports.ox_inventory:AddItem(char:GetData("SID"), itemId, 1, {}, 1) then
        ped.customization.components.accessory = {
          componentId = 7,
          drawableId = 0,
          textureId = 0,
          paletteId = 0,
        }
        exports['pulsar-ped']:Save(char, ped)
      end
    end
  end
end)

exports("NecklaceUnequipNoItem", function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local ped = char:GetData("Ped")
    if ped.customization.components.mask.drawableId ~= 0 then
      TriggerClientEvent("Ped:Client:MaskAnim", source)
      ped.customization.components.mask = {
        componentId = 1,
        drawableId = 0,
        textureId = 0,
        paletteId = 0,
      }
      exports['pulsar-ped']:Save(char, ped)
    end
  end
end)

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function RegisterCallbacks()
  exports["pulsar-core"]:RegisterServerCallback("Ped:CheckPed", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then
      local myPed = MySQL.single.await([[
				SELECT * FROM `peds` WHERE `char` = ?
			]], { char:GetData("ID") })

      if not myPed then
        local tmp = deepcopy(TemplateData)

        if char:GetData("Gender") == 0 then
          tmp.model = "mp_m_freemode_01"
        else
          tmp.model = "mp_f_freemode_01"
        end

        char:SetData("Ped", tmp)
        return cb({
          existed = false,
          ped = tmp,
        })
      end

      local ped = json.decode(myPed.ped)

      if not ped or next(ped) == nil then
        local tmp = deepcopy(TemplateData)

        if char:GetData("Gender") == 0 then
          tmp.model = "mp_m_freemode_01"
        else
          tmp.model = "mp_f_freemode_01"
        end

        char:SetData("Ped", tmp)
        return cb({
          existed = false,
          ped = tmp,
        })
      end

      if ped.model == "" then
        if char:GetData("Gender") == 0 then
          ped.model = "mp_m_freemode_01"
        else
          ped.model = "mp_f_freemode_01"
        end
      end

      char:SetData("Ped", ped)
      cb({
        existed = true,
        ped = ped,
      })
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:MakePayment", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    local pricing = GlobalState["Ped:Pricing"][data.type]
    if pricing == 0 or char:GetData("Cash") >= pricing then
      char:SetData("Cash", char:GetData("Cash") - pricing)
      cb(true, pricing)
    else
      cb(false)
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:SavePed", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    cb(exports['pulsar-ped']:Save(char, data.ped))
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:RemoveMask", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
      local ped = char:GetData("Ped")
      if ped.customization.components.mask.drawableId ~= 0 then
        TriggerClientEvent("Ped:Client:MaskAnim", source)
        Wait(500)
        exports['pulsar-ped']:MaskUnequip(source)
      end
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:RemoveHat", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
      local ped = char:GetData("Ped")
      if not ped.customization.props.hat.disabled then
        TriggerClientEvent("Ped:Client:HatGlassAnim", source)
        Wait(500)
        exports['pulsar-ped']:HatUnequip(source)
      end
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:RemoveAccessory", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
      local ped = char:GetData("Ped")
      if ped.customization.components.accessory.drawableId ~= 0 then
        TriggerClientEvent("Ped:Client:HatGlassAnim", source)
        Wait(500)
        exports['pulsar-ped']:NecklaceUnequip(source)
      end
    end
  end)

  exports["pulsar-core"]:RegisterServerCallback("Ped:GetWhitelistedPeds", function(source, data, cb)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
      local res = MySQL.query.await("SELECT model, label FROM whitelisted_peds WHERE SID = ?", {
        char:GetData("SID")
      })

      cb(res)
    else
      cb({})
    end
  end)
end
