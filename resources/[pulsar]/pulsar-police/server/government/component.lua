_licenses = {
  drivers = { key = "Drivers", price = 1000 },
  weapons = { key = "Weapons", price = 2000 },
  hunting = { key = "Hunting", price = 800 },
  fishing = { key = "Fishing", price = 800 },
}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-police')
    exports["pulsar-core"]:RegisterServerCallback("Government:BuyID", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if exports['pulsar-finance']:WalletModify(source, -500) then
        exports.ox_inventory:AddItem(char:GetData("SID"), "govid", 1, {}, 1)
      else
        exports['pulsar-hud']:Notification(source, "error", "Not Enough Cash")
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Government:BuyLicense", function(source, data, cb)
      if _licenses[data] ~= nil then
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        local licenses = char:GetData("Licenses")
        if exports['pulsar-finance']:WalletModify(source, -_licenses[data].price) then
          if licenses[_licenses[data].key] ~= nil and not licenses[_licenses[data].key].Active then
            licenses[_licenses[data].key].Active = true
            char:SetData("Licenses", licenses)

            exports['pulsar-core']:MiddlewareTriggerEvent("Characters:ForceStore", source)
          else
            exports['pulsar-hud']:Notification(source, "error",
              "Unable To Purchase License")
          end
        else
          exports['pulsar-hud']:Notification(source, "error", "Not Enough Cash")
        end
      else
        exports['pulsar-core']:LoggerError(
          "Government",
          string.format("%s Tried To Buy Invalid License Type %s", char:GetData("SID"), data),
          {
            console = true,
            discord = true,
          }
        )
        exports['pulsar-hud']:Notification(source, "error", "Unable To Purchase License")
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Government:Client:DoWeaponsLicenseBuyPolice",
      function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if exports['pulsar-jobs']:HasJob(source, "police") and char then
          local licenses = char:GetData("Licenses")
          if exports['pulsar-finance']:WalletModify(source, -20) then
            licenses["Weapons"].Active = true
            char:SetData("Licenses", licenses)
            exports['pulsar-core']:MiddlewareTriggerEvent("Characters:ForceStore", source)
          else
            exports['pulsar-hud']:Notification(source, "error", "Not Enough Cash")
          end
        else
          exports['pulsar-hud']:Notification(source, "error", "You are Not PD")
        end
      end)
  end
end)

RegisterNetEvent("Government:Server:Gavel", function()
  TriggerClientEvent("Government:Client:Gavel", -1)
end)
