AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    FetchBillboardsData()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-billboards')

    exports["pulsar-chat"]:RegisterAdminCommand("setbillboard", function(source, args, rawCommand)
      local billboardId, billboardUrl = args[1], args[2]

      if #billboardUrl <= 10 then
        billboardUrl = false
      end

      exports['pulsar-billboards']:Set(billboardId, billboardUrl)
    end, {
      help = "Set a Billboard URL",
      params = {
        {
          name = "ID",
          help = "Billboard ID",
        },
        {
          name = "URL",
          help = "Billboard URL",
        },
      },
    }, 2)

    exports["pulsar-core"]:RegisterServerCallback("Billboards:UpdateURL", function(source, data, cb)
      local billboardData = _billboardConfig[data and data.id]
      if billboardData and billboardData.job and Player(source).state.onDuty == billboardData.job then
        local billboardUrl = data.link
        if #billboardUrl <= 5 then
          billboardUrl = false
        end

        if not billboardUrl or exports['pulsar-core']:RegexTest(_billboardRegex, billboardUrl, "gim") then
          cb(exports['pulsar-billboards']:Set(data.id, billboardUrl))
        else
          cb(false, true)
        end
      else
        cb(false)
      end
    end)
  end
end)

exports("Set", function(id, url)
  if id and _billboardConfig[id] then
    local updated = SetBillboardURL(id, url)
    if updated then
      GlobalState[string.format("Billboards:%s", id)] = url

      TriggerClientEvent('Billboards:Client:UpdateBoardURL', -1, id, url)

      return true
    end
  end
  return false
end)

exports("Get", function(id)
  return GlobalState[string.format("Billboards:%s", id)]
end)

exports("GetCategory", function(cat)
  local cIds = {}

  for k, v in pairs(_billboardConfig) do
    if v.category == cat then
      table.insert(cIds, k)
    end
  end

  return cIds
end)

local started = false
function FetchBillboardsData()
  if started then return; end

  started = true

  local fetchedBillboards = {}
  local billboardIds = {}

  local result = MySQL.query.await('SELECT billboardId, billboardUrl FROM billboards')

  if result and #result > 0 then
    for k, v in ipairs(result) do
      if v.billboardId and v.billboardUrl then
        fetchedBillboards[v.billboardId] = v.billboardUrl
      end
    end
  end

  for k, v in pairs(_billboardConfig) do
    GlobalState[string.format("Billboards:%s", k)] = fetchedBillboards[k]

    table.insert(billboardIds, k)
  end
end

function SetBillboardURL(billboardId, url)
  local result = MySQL.query.await(
    'INSERT INTO billboards (billboardId, billboardUrl) VALUES (?, ?) ON DUPLICATE KEY UPDATE billboardUrl = ?',
    { billboardId, url, url }
  )

  return result and result.affectedRows > 0
end
