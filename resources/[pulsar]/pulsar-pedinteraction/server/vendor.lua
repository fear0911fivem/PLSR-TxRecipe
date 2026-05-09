_created = {}
local _bought = {}
local _globalBought = {}

function hasValue(tbl, value)
  for k, v in ipairs(tbl) do
    if v == value or (type(v) == "table" and hasValue(v, value)) then
      return true
    end
  end
  return false
end

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

local _illegalBlacklist = {
  police = true,
  ems = true,
  government = true,
}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    StartRestockThread()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-pedinteraction')

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      local tmp = {}
      for k, v in pairs(_created) do
        tmp[v.id] = {
          id = v.id,
          type = v.type,
          name = v.name,
          model = v.model,
          position = v.position,
          iconOverride = v.iconOverride,
          labelOverride = v.labelOverride,
        }
      end
      TriggerClientEvent("Vendor:Client:Set", source, tmp)
    end, 5)

    exports["pulsar-core"]:RegisterServerCallback("Vendor:GetItems", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        if _created[data] ~= nil then
          local itms = {}

          local pState = Player(source).state
          local cStates = char:GetData("States") or {}
          local hasVpn = exports.ox_inventory:ItemsHas(char:GetData("SID"), 'vpn', 1)
          local vendorSales = char:GetData("Vendor") or {}

          if _created[data] and not _illegalBlacklist[pState.onDuty or ""] then
            for k, v in ipairs(_created[data].items) do
              if
                  (v.rep == nil or exports['pulsar-characters']:RepGetLevel(source, v.rep) >= (v.repLvl or 1))
                  and (not v.vpn or hasVpn)
                  and (not v.state or hasValue(cStates, v.state))
                  and (not v.limited or v.limited and (not vendorSales[data] or not vendorSales[data][v.item] or not vendorSales[data][v.item][v.limited.id] or vendorSales[data][v.item][v.limited.id] < v.limited.qty))
                  and (v.ignoreUnique or (not _created[data].isUnique or (_bought[data][source] == nil or _bought[data][source][v.item] == nil or _bought[data][source][v.item] < _created[data].isUnique)))
                  and (not _created[data].isGlobalUnique or _globalBought[data][source] == nil or _globalBought[data][source] < _created[data].isGlobalUnique)
                  and (
                    not v.requireCurrency
                    or v.requireCurrency
                    and ((v.coin ~= nil and exports['pulsar-finance']:CryptoHas(source, v.coin, v.price)) or (v.coin == nil and exports['pulsar-finance']:WalletHas(
                      source,
                      v.price
                    )))
                  )
              then
                v.index = k

                if
                    v.limited
                    and (
                      not vendorSales[data]
                      or not vendorSales[data][v.item]
                      or not vendorSales[data][v.item][v.limited.id]
                      or vendorSales[data][v.item][v.limited.id] < v.limited.qty
                    )
                then
                  if
                      not vendorSales[data]
                      or not vendorSales[data][v.item]
                      or not vendorSales[data][v.item][v.limited.id]
                  then
                    v.qty = v.limited.qty
                  else
                    v.qty = v.limited.qty - vendorSales[data][v.item][v.limited.id]
                  end
                end

                if
                    _created[data].stockTimeDelay ~= false
                    and _created[data].stockTimeDelay > os.time()
                then
                  v.delayed = true
                else
                  v.delayed = false
                end

                table.insert(itms, v)
              end
            end

            cb(itms)
          else
            exports['pulsar-core']:LoggerWarn(
              "Vendor",
              string.format(
                "^3%s %s^7 (^3%s^7) Attempted to access an illegal flagged vendor (^3%s^7) while on duty as %s",
                char:GetData("First"),
                char:GetData("Last"),
                char:GetData("SID"),
                data,
                pState.onDuty
              )
            )
            cb({})
          end
        else
          cb({})
        end
      else
        cb({})
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Vendor:BuyItem", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        if _created[data.id] ~= nil then
          if not _created[data.id].stockTimeDelay or os.time() > _created[data.id].stockTimeDelay then
            local pState = Player(source).state
            local cStates = char:GetData("States") or {}
            local vendorSales = char:GetData("Vendor") or {}

            local hasVpn = exports.ox_inventory:ItemsHas(char:GetData("SID"), 'vpn', 1)
            local itemData = _created[data.id].items[data.index]

            if _created[data.id] and not _illegalBlacklist[pState.onDuty or ""] then
              if itemData ~= nil and (itemData.qty == -1 or itemData.qty > 0) then
                if
                    (
                      itemData.rep == nil
                      or exports['pulsar-characters']:RepGetLevel(source, itemData.rep) >= (itemData.repLvl or 1)
                    )
                    and (not itemData.vpn or hasVpn)
                    and (not itemData.state or hasValue(cStates, itemData.state))
                    and (not itemData.limited or itemData.limited and (not vendorSales[data] or not vendorSales[data][itemData.item] or not vendorSales[data][itemData.item][itemData.limited.id] or vendorSales[data][itemData.item][itemData.limited.id] < itemData.limited.qty))
                    and (itemData.ignoreUnique or (not _created[data.id].isUnique or _bought[data.id] == nil or _bought[data.id][source] == nil or _bought[data.id][source][itemData.item] == nil or _bought[data][source][itemData.item] < _created[data.id].isUnique))
                    and (not _created[data.id].isGlobalUnique or _globalBought[data.id][source] == nil or _globalBought[data.id][source] < _created[data.id].isGlobalUnique)
                    and (
                      not _created[data.id].requireCurrency
                      or _created[data.id].requireCurrency
                      and ((itemData.coin ~= nil and exports['pulsar-finance']:CryptoHas(
                        source,
                        itemData.coin,
                        itemData.price
                      )) or exports['pulsar-finance']:WalletHas(source, itemData.price))
                    )
                then
                  if itemData.coin ~= nil then
                    local coinData = exports['pulsar-finance']:CryptoCoinGet(itemData.coin)
                    if
                        exports['pulsar-finance']:CryptoExchangeRemove(
                          itemData.coin,
                          char:GetData("CryptoWallet"),
                          itemData.price
                        )
                    then
                      if itemData.qty ~= -1 then
                        _created[data.id].items[data.index].qty = itemData.qty - 1
                      end
                      _globalBought[data.id][source] = (_globalBought[data.id][source] or 0) + 1
                      _bought[data.id][source] = _bought[data.id][source] or {}
                      _bought[data.id][source][itemData.item] = (
                        _bought[data.id][source][itemData.item] or 0
                      ) + 1

                      if itemData.limited then
                        local vendorSales = char:GetData("Vendor") or {}
                        vendorSales[data.id] = vendorSales[data.id] or {}
                        vendorSales[data.id][itemData.item] = vendorSales[data.id]
                            [itemData.item]
                            or {}
                        vendorSales[data.id][itemData.item][itemData.limited.id] = vendorSales
                            [data.id][itemData.item][itemData.limited.id]
                            or 0
                        vendorSales[data.id][itemData.item][itemData.limited.id] += 1

                        char:SetData("Vendor", vendorSales)
                      end

                      -- This probably should be handled some other way to be more dynamic
                      -- but for this a quick hack is fine
                      local md = {}
                      if itemData.item == "lsundg_invite" then
                        md.Inviter = {
                          SID = char:GetData("SID"),
                          First = char:GetData("First"),
                          Last = char:GetData("Last"),
                        }
                      end

                      cb(exports.ox_inventory:AddItem(char:GetData("SID"), itemData.item, 1,
                        {}, 1))
                    else
                      exports['pulsar-hud']:Notification(source, "error",
                        string.format("Not Enough %s", coinData.Name)
                      )
                    end
                  else
                    if exports['pulsar-finance']:WalletHas(source, itemData.price) then
                      if exports['pulsar-finance']:WalletModify(source, -itemData.price) then
                        if itemData.qty ~= -1 then
                          _created[data.id].items[data.index].qty = itemData.qty - 1
                        end
                        _globalBought[data.id][source] = (_globalBought[data.id][source] or 0)
                            + 1
                        _bought[data.id][source] = _bought[data.id][source] or {}
                        _bought[data.id][source][itemData.item] = (
                          _bought[data.id][source][itemData.item] or 0
                        ) + 1
                        cb(exports.ox_inventory:AddItem(char:GetData("SID"),
                          itemData.item, 1, {}, 1))
                      end
                    else
                      exports['pulsar-hud']:Notification(source, "error",
                        "Not Enough Cash")
                    end
                  end
                end
              else
                exports['pulsar-hud']:Notification(source, "error",
                  "Item Not In Stock")
              end
            else
              exports['pulsar-core']:LoggerWarn(
                "Vendor",
                string.format(
                  "%s %s (%s) Attempted to buy %s from an illegal flagged vendor (%s) while on duty as %s",
                  char:GetData("First"),
                  char:GetData("Last"),
                  char:GetData("SID"),
                  itemData.label,
                  data.id,
                  pState.onDuty
                )
              )
              exports['pulsar-hud']:Notification(source, "error",
                "You shouldn't be doing this, logged & flagged :)"
              )
              cb({})
            end
          else
            cb({})
          end
        else
          cb({})
        end
      else
        cb({})
      end
    end)
  end
end)

exports("VendorCreate",
  function(id, type, name, model, position, items, iconOverride, labelOverride, isUnique, isGlobalUnique, isIllegal,
           stockTimeDelay, restock)
    if restock ~= false then
      for k, v in ipairs(items) do
        v.oQty = v.qty
      end
    end

    _created[id] = {
      id = id,
      type = type,
      name = name,
      model = model,
      position = position,
      items = items,
      iconOverride = iconOverride,
      labelOverride = labelOverride,
      isUnique = isUnique,
      isGlobalUnique = isGlobalUnique,
      isIllegal = isIllegal or false,
      stockTimeDelay = (stockTimeDelay and os.time() + stockTimeDelay) or false,
      restock = restock or false,
      restockTime = (restock and os.time() + restock) or false,
    }
    _bought[id] = {}
    _globalBought[id] = {}

    TriggerClientEvent(
      "Vendor:Client:Add",
      -1,
      id,
      type,
      name,
      model,
      position,
      iconOverride,
      labelOverride,
      isUnique,
      isGlobalUnique,
      isIllegal
    )
  end)

exports("VendorRemove", function(id)
  _created[id] = nil
  TriggerClientEvent("Vendor:Client:Remove", -1, id)
end)
