AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterChatCommands()
    StartDashboardThread()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-admin')

    exports['pulsar-core']:MiddlewareAdd('Characters:Spawning', function(source)
      local player = exports['pulsar-core']:FetchSource(source)

      if player and player.Permissions:IsStaff() then
        local highestLevel, highestGroup, highestGroupName = 0, nil, nil
        for k, v in ipairs(player:GetData('Groups')) do
          local group = exports['pulsar-core']:ConfigGetGroupById(tostring(v))
          if group and (type(group.Permission) == 'table') then
            if group.Permission.Level > highestLevel then
              highestLevel = group.Permission.Level
              highestGroup = v
              highestGroupName = group.Name
            end
          end
        end

        TriggerClientEvent('Admin:Client:Menu:RecievePermissionData', source, {
          Source = source,
          Name = player:GetData('Name'),
          AccountID = player:GetData('AccountID'),
          Identifier = player:GetData('Identifier'),
          Groups = player:GetData('Groups'),
          Discord = player:GetData("Discord"),
          Mention = player:GetData("Mention"),
          Avatar = player:GetData("Avatar"),
        }, highestGroup, highestGroupName, highestLevel)
      end
    end, 5)
  end
end)

function RegisterChatCommands()
  exports["pulsar-chat"]:RegisterAdminCommand("weptest", function(source, args, rawCommand)
    if GlobalState.IsProduction then
      exports['pulsar-hud']:Notification(source, "error",
        "Cannot Use This On Production Servers")
      return
    end
    TriggerClientEvent("Admin:Client:DamageTest", source, args[1] == "1")
  end, {
    help = "[Admin] Start Weapon Damage Testing",
    params = {
      {
        name = "Mode",
        help = "0 = Body Shots, 1 = Headshots",
      },
    },
  }, 1)

  exports["pulsar-chat"]:RegisterAdminCommand("statebaglog", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:StateBagLog", source)
  end, {
    help = "[Admin] Toggle Console State Bag Logging",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("voiptargetlog", function(source, args, rawCommand)
    TriggerClientEvent("VOIP:Client:ToggleDebugMode", source)
  end, {
    help = "[Admin] Toggle Console VOIP Target Logging",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("admin", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:Menu:Open", source)
  end, {
    help = "[Admin] Open Admin Menu",
  }, 0)

  exports["pulsar-chat"]:RegisterStaffCommand("staff", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:Menu:Open", source)
  end, {
    help = "[Staff] Open Staff Menu",
  }, 0)

  exports["pulsar-chat"]:RegisterStaffCommand("noclip", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:NoClip", source, false)
  end, {
    help = "[Admin] Toggle NoClip",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("noclip:dev", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:NoClip", source, true)
  end, {
    help = "[Developer] Toggle Developer Mode NoClip",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("noclip:info", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:NoClipInfo", source)
  end, {
    help = "[Developer] Get NoClip Camera Info",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("marker", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:Marker", source, tonumber(args[1]) + 0.0, tonumber(args[2]) + 0.0)
  end, {
    help = "Place Marker at Coordinates",
    params = {
      {
        name = "X",
        help = "X Coordinate",
      },
      {
        name = "Y",
        help = "Y Coordinate",
      },
    },
  }, 2)

  exports["pulsar-chat"]:RegisterStaffCommand("cpcoords", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:CopyCoords", source, args[1])
    exports['pulsar-hud']:Notification(source, "success", "Copied Coordinates")
  end, {
    help = "[Dev] Copy Coords",
    params = {
      {
        name = "Type",
        help = "Type of Coordinate (vec3, vec4, vec2, table, z, h, rot)",
      },
    },
  }, -1)

  exports["pulsar-chat"]:RegisterAdminCommand("cpproperty", function(source, args, rawCommand)
    local nearProperty = exports['pulsar-properties']:IsNearProperty(source)
    if nearProperty.propertyId then
      TriggerClientEvent("Admin:Client:CopyClipboard", source, nearProperty.propertyId)
      exports['pulsar-hud']:Notification(source, "success", "Copied Property ID")
    end
  end, {
    help = "[Dev] Copy Property ID of Closest Property",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("property", function(source, args, rawCommand)
    local nearProperty = exports['pulsar-properties']:IsNearProperty(source)
    if nearProperty.propertyId then
      local prop = exports['pulsar-properties']:Get(nearProperty.propertyId)
      if prop then
        exports["pulsar-chat"]:SendSystemSingle(
          source,
          string.format(
            "Property ID: %s<br>Property: %s<br>Interior: %s<br>Owner: %s<br>Price: $%s<br>Type: %s",
            prop.id,
            prop.label,
            prop.upgrades?.interior,
            prop.owner and prop.owner.SID or "N/A",
            prop.price,
            prop.type
          )
        )
      end
    end
  end, {
    help = "[Dev] Get Closest Property Data",
  }, 0)

  exports["pulsar-chat"]:RegisterCommand("record", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:Recording", source, 'record')
  end, {
    help = "Record With R* Editor",
  }, 0)

  exports["pulsar-chat"]:RegisterCommand("recordstop", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:Recording", source, 'stop')
  end, {
    help = "Record With R* Editor",
  }, 0)

  -- exports["pulsar-chat"]:RegisterStaffCommand("recorddel", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Admin:Client:Recording", source, 'delete')
  -- end, {
  -- 	help = "[Staff] Record With R* Editor",
  -- }, 0)

  -- exports["pulsar-chat"]:RegisterStaffCommand("recordedit", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Admin:Client:Recording", source, 'editor')
  -- end, {
  -- 	help = "[Staff] Record With R* Editor",
  -- }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("setped", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:ChangePed", source, args[1])
  end, {
    help = "[Admin] Set Ped",
    params = {
      {
        name = "Ped",
        help = "Ped Model",
      },
    },
  }, 1)

  exports["pulsar-chat"]:RegisterAdminCommand("staffcam", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:NoClip", source, true)
  end, {
    help = "[Staff] Camera Mode",
  }, 0)

  exports["pulsar-chat"]:RegisterAdminCommand("zsetped", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:ChangePed", tonumber(args[1]), args[2])
  end, {
    help = "[Admin] Set Ped",
    params = {
      {
        name = "Source (Lazy)",
        help = "Source",
      },
      {
        name = "Ped",
        help = "Ped Model",
      },
    },
  }, 2)

  exports["pulsar-chat"]:RegisterAdminCommand("nuke", function(source, args, rawCommand)
    TriggerClientEvent("Admin:Client:NukeCountdown", -1)
    Wait(23000)
    TriggerClientEvent("Admin:Client:Nuke", -1)
  end, {
    help = "DO NOT USE",
  }, 0)
end
