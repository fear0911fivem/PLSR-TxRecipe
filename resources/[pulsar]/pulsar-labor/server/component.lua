AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterCallbacks()
    RegisterMiddleware()
    TriggerEvent("Labor:Server:Startup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-labor')
  end
end)

_Jobs = {}
_Groups = {}

_active = {}
_pendingInvites = {}
_offers = {}

exports('GetJobs', function()
  return _Jobs
end)

exports('GetGroups', function()
  return _Groups
end)

exports('RegisterJob', function(id, name, limit, salary, repAward, restrictions, customRep, hiddenRep, timeout)
  _Jobs[id] = {
    Id = id,
    Name = name,
    Limit = limit,
    Salary = salary or 0,
    RepAward = repAward or 0,
    OnDuty = {},
    Restricted = restrictions,
    Timeout = timeout,
  }

  exports['pulsar-characters']:RepCreate(id, name, customRep or {
    { label = "Rank 1", value = 1500 },
    { label = "Rank 2", value = 3000 },
    { label = "Rank 3", value = 6000 },
    { label = "Rank 4", value = 9000 },
    { label = "Rank 5", value = 12000 },
  }, hiddenRep)
end)

exports('TaskOffer', function(joiner, job, text, appOverride)
  local title = "Job Activity"
  local app = "labor"
  if appOverride then
    title = appOverride.title or "Job Activity"
    app = appOverride or "labor"
  end

  for k, v in pairs(_Jobs[job].OnDuty) do
    if v.Joiner == joiner then
      if _Jobs[job].Timeout then
        if _offers[joiner] == nil then
          _offers[joiner] = { job = job }
        end
        _offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
      end

      if v.Group then
        for k2, v2 in pairs(_Groups) do
          if v2.Creator.ID == joiner then
            for k3, v3 in ipairs(v2.Members) do
              exports['pulsar-phone']:NotificationAddWithId(
                v3.ID,
                "LABOR_OBJ",
                title,
                text,
                os.time(),
                -1,
                app,
                {}
              )
            end
          end
        end
      end

      exports['pulsar-phone']:NotificationAddWithId(joiner, "LABOR_OBJ", title, text, os.time(), -1,
        app, {})
    end
  end
end)

exports('StartOffer', function(joiner, job, text, max, appOverride)
  local title = "Job Activity"
  local app = "labor"
  if appOverride then
    title = appOverride.title or "Job Activity"
    app = appOverride or "labor"
  end

  if _Jobs[job] ~= nil then
    _offers[joiner] = {
      job = job,
      text = text,
      current = 0,
      max = max,
    }

    if _Jobs[job].Timeout then
      _offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
    end

    for k, v in pairs(_Jobs[job].OnDuty) do
      if v.Joiner == joiner then
        if v.Group then
          for k2, v2 in pairs(_Groups) do
            if v2.Creator.ID == joiner then
              for k3, v3 in ipairs(v2.Members) do
                exports['pulsar-phone']:NotificationAddWithId(
                  v3.ID,
                  "LABOR_OBJ",
                  title,
                  string.format(
                    "%s - %s/%s",
                    _offers[joiner].text,
                    _offers[joiner].current,
                    _offers[joiner].max
                  ),
                  os.time(),
                  -1,
                  app,
                  {}
                )
              end
            end
          end
        end

        exports['pulsar-phone']:NotificationAddWithId(
          joiner,
          "LABOR_OBJ",
          title,
          string.format(
            "%s - %s/%s",
            _offers[joiner].text,
            _offers[joiner].current,
            _offers[joiner].max
          ),
          os.time(),
          -1,
          app,
          {}
        )
      end
    end
  end
end)

exports('UpdateOffer', function(joiner, job, change, skipFinish, appOverride)
  local title = "Job Activity"
  if appOverride then
    title = appOverride.title or "Job Activity"
  end

  if _offers[joiner] ~= nil then
    _offers[joiner].current = _offers[joiner].current + change

    if _Jobs[job].Timeout then
      _offers[joiner].expires = os.time() + _Jobs[job].Timeout.Duration
    end

    if _offers[joiner].current >= _offers[joiner].max and not skipFinish then
      local paidOut = {}

      for k, v in pairs(_Jobs[job].OnDuty) do
        if v.Joiner == joiner then
          if v.Group then
            for k2, v2 in pairs(_Groups) do
              if v2.Creator.ID == joiner then
                for k3, v3 in ipairs(v2.Members) do
                  exports['pulsar-phone']:NotificationRemoveById(v3.ID, "LABOR_OBJ")
                  if not paidOut[v3.ID] then
                    paidOut[v3.ID] = true
                    exports['pulsar-labor']:CompleteOffer(v3.ID, job)
                  end
                end
              end
            end
          end
          exports['pulsar-phone']:NotificationRemoveById(joiner, "LABOR_OBJ")
          if not paidOut[joiner] then
            paidOut[joiner] = true
            exports['pulsar-labor']:CompleteOffer(joiner, job)
          end
          exports['pulsar-labor']:OffDuty(job, joiner, true)
          TriggerEvent(string.format("%s:Server:FinishJob", job), joiner)
        end
      end

      _offers[joiner] = nil
      return true
    else
      for k, v in pairs(_Jobs[job].OnDuty) do
        if v.Joiner == joiner then
          if v.Group then
            for k2, v2 in pairs(_Groups) do
              if v2.Creator.ID == joiner then
                for k3, v3 in ipairs(v2.Members) do
                  exports['pulsar-phone']:NotificationUpdate(
                    v3.ID,
                    "LABOR_OBJ",
                    title,
                    string.format(
                      "%s - %s/%s",
                      _offers[joiner].text,
                      _offers[joiner].current,
                      _offers[joiner].max
                    )
                  )
                end
              end
            end
          end
          exports['pulsar-phone']:NotificationUpdate(
            joiner,
            "LABOR_OBJ",
            title,
            string.format(
              "%s - %s/%s",
              _offers[joiner].text,
              _offers[joiner].current,
              _offers[joiner].max
            )
          )
        end
      end

      if _offers[joiner].current >= _offers[joiner].max and skipFinish then
        return true
      else
        return false
      end
    end
  else
    return false
  end
end)

exports('CompleteOffer', function(source, job)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char then
    exports['pulsar-core']:LoggerInfo(
      "Labor",
      string.format(
        "%s %s (%s) Completed Manual Round (%s) - Got $%s",
        char:GetData("First"),
        char:GetData("Last"),
        char:GetData("SID"),
        job,
        _Jobs[job].Salary
      )
    )
    if _Jobs[job].Salary > 0 then
      exports['pulsar-finance']:BalanceDeposit(
        exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID")).Account,
        _Jobs[job].Salary,
        {
          type = "paycheck",
          title = "Paycheck",
          description = string.format("Paycheck For Labor Worked: %s - $%s", job, _Jobs[job].Salary),
          data = _Jobs[job].Salary,
        })
    end

    exports['pulsar-characters']:RepAdd(source, job, _Jobs[job].RepAward)
  end
end)

exports('ManualFinishOffer', function(joiner, job, appOverride)
  local paidOut = {}
  for k, v in pairs(_Jobs[job].OnDuty) do
    if v.Joiner == joiner then
      if v.Group then
        for k2, v2 in pairs(_Groups) do
          if v2.Creator.ID == v.Joiner then
            for k3, v3 in ipairs(v2.Members) do
              exports['pulsar-phone']:NotificationRemoveById(v3.ID, "LABOR_OBJ")
              if not paidOut[v3.ID] then
                paidOut[v3.ID] = true
                exports['pulsar-labor']:CompleteOffer(v3.ID, job)
              end
            end
          end
        end
      end

      exports['pulsar-phone']:NotificationRemoveById(v.Joiner, "LABOR_OBJ")
      if not paidOut[v.Joiner] then
        paidOut[v.Joiner] = true
        exports['pulsar-labor']:CompleteOffer(v.Joiner, job)
      end
      TriggerEvent(string.format("%s:Server:FinishJob", job), v.Joiner)
      exports['pulsar-labor']:OffDuty(job, v.Joiner, true)
    end
  end

  _offers[joiner] = nil
end)

exports('FailOffer', function(joiner, job, timeout)
  local paidOut = {}
  for k, v in pairs(_Jobs[job].OnDuty) do
    if v.Joiner == joiner then
      if v.Group then
        for k2, v2 in pairs(_Groups) do
          if v2.Creator.ID == joiner then
            for k3, v3 in ipairs(v2.Members) do
              exports['pulsar-phone']:NotificationRemoveById(v3.ID, "LABOR_OBJ")
              if timeout ~= nil then
                exports['pulsar-phone']:NotificationAdd(
                  v3.ID,
                  "Job Failed",
                  timeout.Message,
                  os.time(),
                  6000,
                  "labor",
                  {}
                )
              end
              if not paidOut[v3.ID] then
                paidOut[v3.ID] = true
                if not _Jobs[job]?.Timeout?.KeepRep then
                  exports['pulsar-characters']:RepRemove(v3.ID, job, _Jobs[job].RepAward)
                end
              end
            end
          end
        end
      end
      exports['pulsar-phone']:NotificationRemoveById(joiner, "LABOR_OBJ")
      if timeout ~= nil then
        exports['pulsar-phone']:NotificationAdd(
          joiner,
          "Job Failed",
          timeout.Message,
          os.time(),
          6000,
          "labor",
          {}
        )
      end
      if not paidOut[v.Joiner] then
        paidOut[v.Joiner] = true
        if not _Jobs[job]?.Timeout?.KeepRep then
          exports['pulsar-characters']:RepRemove(joiner, job, _Jobs[job].RepAward)
        end
      end
      TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
      exports['pulsar-labor']:OffDuty(job, joiner, false, true)
    end
  end

  _offers[joiner] = nil
end)

exports('CancelOffer', function(joiner, job)
  for k, v in pairs(_Jobs[job].OnDuty) do
    if v.Joiner == joiner then
      if v.Group then
        for k2, v2 in pairs(_Groups) do
          if v2.Creator.ID == joiner then
            for k3, v3 in ipairs(v2.Members) do
              exports['pulsar-phone']:NotificationRemoveById(v3.ID, "LABOR_OBJ")
            end
          end
        end
      end

      exports['pulsar-phone']:NotificationRemoveById(joiner, "LABOR_OBJ")
      TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
      exports['pulsar-labor']:OffDuty(job, joiner, false, true)
    end
  end
end)

exports('CreateWorkgroup', function(source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
      return false
    end

    local myId = char:GetData("SID")
    for k, v in ipairs(_Groups) do
      if v.Creator.ID == source then
        return false
      end

      for k2, v2 in ipairs(v.Members) do
        if v2.ID == source then
          return false
        end
      end
    end

    local name = { First = char:GetData("First"), Last = char:GetData("Last") }

    if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, 'vpn', 1) then
      local vpn = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "vpn", 1)
      local vpnName = vpn.MetaData.VpnName
      if type(vpnName) == "string" then
        local first, last = vpnName:match("^(%S+)%s*(.*)$")
        name.First = first or vpnName
        name.Last = last or ""
      elseif type(vpnName) == "table" then
        name.First = vpnName.First or name.First
        name.Last = vpnName.Last or name.Last
      end
    end

    table.insert(_Groups, {
      ID = source,
      Creator = {
        ID = source,
        SID = char:GetData("SID"),
        CharID = char:GetData("ID"),
        First = name.First,
        Last = name.Last,
      },
      Members = {},
    })

    return true
  else
    return false
  end
end)


exports('DisbandWorkgroup', function(source, force)
  for k, v in ipairs(_Groups) do
    if v.Creator.ID == source and (not _Groups[k].Working or force) then
      if _Groups[k].Working then
        exports['pulsar-labor']:OffDuty(_Groups[k].Job, v.Creator.ID, false, true)
      end
      for k2, v2 in ipairs(v.Members) do
        TriggerClientEvent("Labor:Client:WorkgroupDisbanded", v2.ID)
        exports['pulsar-phone']:NotificationAdd(
          v2.ID,
          "Job Activity",
          string.format(
            "%s %s Disbanded Your Workgroup",
            v.Creator.First,
            v.Creator.Last
          ),
          os.time(),
          6000,
          "labor",
          {}
        )
      end

      table.remove(_Groups, k)
      return true
    end
  end
  return false
end)

exports('JoinWorkgroup', function(creator, source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil and char:GetData("TempJob") == nil then
    if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
      return false
    end

    local myId = char:GetData("SID")
    for k, v in ipairs(_Groups) do
      if v.Creator.ID == source then
        return false
      end

      for k2, v2 in ipairs(v.Members) do
        if v2.ID == source then
          return false
        end
      end
    end

    for k, v in ipairs(_Groups) do
      if v.Creator.ID == creator then
        if #_Groups[k].Members < 4 and not _Groups[k].Working then
          for k2, v2 in ipairs(_Groups[k].Members) do
            if v2.ID == source then
              return
            end
          end

          local name = { First = char:GetData("First"), Last = char:GetData("Last") }

          if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, 'vpn', 1) then
            local vpn = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "vpn", 1)
            local vpnName = vpn.MetaData.VpnName
            if type(vpnName) == "string" then
              local first, last = vpnName:match("^(%S+)%s*(.*)$")
              name.First = first or vpnName
              name.Last = last or ""
            elseif type(vpnName) == "table" then
              name.First = vpnName.First or name.First
              name.Last = vpnName.Last or name.Last
            end
          end

          local d = {
            ID = source,
            SID = char:GetData("SID"),
            CharID = char:GetData("ID"),
            First = name.First,
            Last = name.Last,
          }
          table.insert(_Groups[k].Members, d)

          exports['pulsar-phone']:NotificationAdd(
            v.Creator.ID,
            "Job Activity",
            string.format("%s %s Joined Your Workgroup", name.First, name.Last),
            os.time(),
            6000,
            "labor",
            {}
          )

          return true
        end
      end
    end
    return false
  else
    return false
  end
end)

exports('RequestWorkgroup', function(group, source)
  if _pendingInvites[source] == nil then
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil and char:GetData("TempJob") == nil then
      if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
        return false
      end

      local myId = char:GetData("SID")
      for k, v in ipairs(_Groups) do
        if v.Creator.ID == source then
          return false
        end

        for k2, v2 in ipairs(v.Members) do
          if v2.ID == source then
            return false
          end
        end
      end

      for k, v in ipairs(_Groups) do
        if v.Creator.ID == group.Creator.ID then
          if #_Groups[k].Members < 4 and not _Groups[k].Working then
            for k2, v2 in ipairs(_Groups[k].Members) do
              if v2.ID == source then
                return
              end
            end

            _pendingInvites[source] = group.Creator.ID

            local name = { First = char:GetData("First"), Last = char:GetData("Last") }

            if exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, 'vpn', 1) then
              local vpn = exports.ox_inventory:ItemsGetFirst(char:GetData("SID"), "vpn", 1)
              local vpnName = vpn.MetaData.VpnName
              if type(vpnName) == "string" then
                local first, last = vpnName:match("^(%S+)%s*(.*)$")
                name.First = first or vpnName
                name.Last = last or ""
              elseif type(vpnName) == "table" then
                name.First = vpnName.First or name.First
                name.Last = vpnName.Last or name.Last
              end
            end

            exports['pulsar-phone']:NotificationAdd(
              v.Creator.ID,
              "Job Activity",
              string.format("%s %s Request To Join Your Group", name.First, name.Last),
              os.time(),
              20000,
              "labor",
              {
                accept = "Labor:Client:AcceptRequest",
                cancel = "Labor:Client:DeclineRequest",
              },
              {
                source = source,
              }
            )

            SetTimeout(30 * 1000, function()
              if _pendingInvites[source] ~= nil then
                _pendingInvites[source] = nil

                exports['pulsar-phone']:NotificationAdd(
                  source,
                  "Job Activity",
                  "Your Group Request Was Ignored",
                  os.time(),
                  4000,
                  "labor",
                  {}
                )
              end
            end)

            return true
          end
        end
      end
      return false
    else
      return false
    end
  end
end)

exports('LeaveWorkgroup', function(group, source)
  local char = exports['pulsar-characters']:FetchCharacterSource(source)
  if char ~= nil then
    local myId = char:GetData("SID")
    for k, v in ipairs(_Groups) do
      if v.Creator.ID == group.Creator.ID then
        for k2, v2 in ipairs(v.Members) do
          if v2.ID == source then
            table.remove(_Groups[k].Members, k2)

            exports['pulsar-phone']:NotificationAdd(
              v.Creator.ID,
              "Job Activity",
              string.format("%s %s Left Your Workgroup", v2.First, v2.Last),
              os.time(),
              6000,
              "labor",
              {}
            )

            return true
          end
        end
      end
    end
    return false
  else
    return false
  end
end)

exports('SendWorkgroupEvent', function(joiner, event, ...)
  for k, v in ipairs(_Groups) do
    if v.Creator.ID == joiner then
      for k2, v2 in ipairs(v.Members) do
        TriggerClientEvent(event, v2.ID, ...)
      end

      TriggerClientEvent(event, v.Creator.ID, ...)
      return
    end
  end

  TriggerClientEvent(event, joiner, ...)
end)

exports('OnDuty', function(job, joiner, isWorkgroup, data)
  if _Jobs[job] ~= nil then
    if (_Jobs[job].Limit == 0) or #_Jobs[job].OnDuty < _Jobs[job].Limit then
      table.insert(_Jobs[job].OnDuty, {
        Joiner = joiner,
        Group = isWorkgroup,
        Data = data or {},
      })

      if isWorkgroup then
        for k, v in ipairs(_Groups) do
          if v.Creator.ID == joiner then
            TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, v.Members, isWorkgroup,
              data or {})
            _Groups[k].Job = job
            _Groups[k].Working = true
            return true
          end
        end

        TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, {}, false, data or {})
      else
        TriggerEvent(string.format("%s:Server:OnDuty", job), joiner, {}, isWorkgroup, data or {})
      end
      return true
    else
      return false
    end
  else
    return false
  end
end)

exports('OffDuty', function(job, joiner, wasFinished, noAlert)
  if _Jobs[job] ~= nil then
    for k, v in ipairs(_Jobs[job].OnDuty) do
      if v.Joiner == joiner then
        if v.Group then
          for k, v in ipairs(_Groups) do
            if v.Creator.ID == joiner then
              for k2, v2 in ipairs(v.Members) do
                local c = exports['pulsar-characters']:FetchCharacterSource(v2.ID)
                if c ~= nil then
                  c:SetData("TempJob", nil)
                  exports['pulsar-phone']:NotificationRemoveById(v2.ID, "LABOR_OBJ")
                  TriggerEvent(string.format("%s:Server:OffDuty", job), v2.ID, joiner)

                  if not noAlert then
                    if wasFinished then
                      exports['pulsar-phone']:NotificationAdd(
                        v2.ID,
                        "Job Activity",
                        "You finished a job",
                        os.time(),
                        6000,
                        "labor",
                        {}
                      )
                    else
                      exports['pulsar-phone']:NotificationAdd(
                        v2.ID,
                        "Job Activity",
                        "You quit a job",
                        os.time(),
                        6000,
                        "labor",
                        {}
                      )
                    end
                  end
                end
              end
              _Groups[k].Working = false
            end
          end
        end
        table.remove(_Jobs[job].OnDuty, k)

        _offers[joiner] = nil

        local char = exports['pulsar-characters']:FetchCharacterSource(joiner)
        if char then
          char:SetData("TempJob", nil)
          exports['pulsar-phone']:NotificationRemoveById(joiner, "LABOR_OBJ")
          TriggerEvent(string.format("%s:Server:OffDuty", job), joiner, joiner)
          if not noAlert then
            if wasFinished then
              exports['pulsar-phone']:NotificationAdd(
                joiner,
                "Job Activity",
                "You finished a job",
                os.time(),
                6000,
                "labor",
                {}
              )
            else
              exports['pulsar-phone']:NotificationAdd(
                joiner,
                "Job Activity",
                "You quit a job",
                os.time(),
                6000,
                "labor",
                {}
              )
              TriggerEvent(string.format("%s:Server:CancelJob", job), joiner)
            end
          end
          return true
        end
      end
    end
    return false
  else
    return false
  end
end)

exports('JailSentenced', function(source)
  for k, v in pairs(_Jobs) do
    if not v.Restricted or not v.Restricted.state or v.Restricted.state ~= "SCRIPT_PRISON_JOB" then
      if v.Restricted then
        exports['pulsar-labor']:FailOffer(source, k)
      else
        exports['pulsar-labor']:OffDuty(k, source, false, true)
      end
    end
  end
end)

exports('JailReleased', function(source)
  for k, v in pairs(_Jobs) do
    if v.Restricted and v.Restricted.state and v.Restricted.state == "SCRIPT_PRISON_JOB" then
      exports['pulsar-labor']:OffDuty(k, source, false, true)
    end
  end
end)

exports('GetOffers', function()
  return _offers
end)
