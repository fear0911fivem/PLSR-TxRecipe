local _ranStartup = false
JOB_CACHE = {}
JOB_COUNT = 0

_loaded = false

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterJobMiddleware()
    RegisterJobCallbacks()
    RegisterJobChatCommands()

    _loaded = true

    RunStartup()

    TriggerEvent("Jobs:Server:Startup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-jobs')
  end
end)

function FindAllJobs()
  local results = MySQL.query.await('SELECT * FROM jobs', {})

  if results and #results > 0 then
    return results
  else
    return {}
  end
end

function RefreshAllJobData(job)
  local jobsFetch = FindAllJobs()
  JOB_COUNT = #jobsFetch
  for k, v in ipairs(jobsFetch) do
    JOB_CACHE[v.Id] = v
    if v.Workplaces ~= nil then
      JOB_CACHE[v.Id].Workplaces = json.decode(v.Workplaces or {})
    end

    if v.Grades ~= nil then
      JOB_CACHE[v.Id].Grades = json.decode(v.Grades or {})
    end
  end

  TriggerEvent("Jobs:Server:UpdatedCache", job or -1)

  local govResults = MySQL.query.await([[
		  SELECT Id, Name, Grades, Salary, SalaryTier, LastUpdated, Workplaces
		  FROM jobs
		  WHERE Type = "Government"
	  ]], {})

  if govResults and #govResults > 0 then
    for _, v in ipairs(govResults) do
      local Workplaces = json.decode(v.Workplaces)
      for _, Workplace in ipairs(Workplaces) do
        for _, Grade in ipairs(Workplace.Grades) do
          local key = string.format("JobPerms:%s:%s:%s", v.Id, Workplace.Id, Grade.Id)
          GlobalState[key] = Grade.Permissions
        end
      end
    end
  end

  local companyResults = MySQL.query.await([[
		  SELECT Id, Name, Grades, Salary, SalaryTier, LastUpdated, Workplaces
		  FROM jobs
		  WHERE Type = "Company"
	  ]], {})

  if companyResults and #companyResults > 0 then
    for _, v in ipairs(companyResults) do
      local Grades = json.decode(v.Grades)
      for _, Grade in ipairs(Grades) do
        local key = string.format("JobPerms:%s:false:%s", v.Id, Grade.Id)
        GlobalState[key] = Grade.Permissions
      end
    end
  end

  return true
end

function RunStartup()
  if _ranStartup then
    return
  end
  _ranStartup = true

  local function replaceExistingDefaultJob(_id, document)
    local deleteResult = MySQL.query.await('DELETE FROM jobs WHERE Id = ?', { _id })

    if deleteResult > 0 then
      local insertResult = MySQL.insert.await(
        'INSERT INTO jobs (Id, Name, Type, Workplaces, Grades, Salary, SalaryTier, LastUpdated, Owner, Custom, Hidden) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
          _id,
          document.Name,
          document.Type,
          json.encode(document.Workplaces),
          json.encode(document.Grades),
          document.Salary,
          document.SalaryTier,
          document.LastUpdated,
          document.Owner,
          document.Custom and 1 or 0,
          document.Hidden and 1 or 0
        })

      if insertResult then
        Wait(10000)
        return true
      else
        exports['pulsar-core']:LoggerError("Jobs", "Error Inserting Job on Default Job Update")
        return false
      end
    else
      exports['pulsar-core']:LoggerError("Jobs", "Error Deleting Job on Default Job Update")
      return false
    end
  end

  local function insertDefaultJob(document)
    local insertResult = MySQL.insert.await(
      'INSERT INTO jobs (Id, Name, Type, Workplaces, Grades, LastUpdated, Salary, SalaryTier, Owner, Custom, Hidden) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      {
        document.Id,
        document.Name,
        document.Type,
        json.encode(document.Workplaces),
        json.encode(document.Grades),
        document.LastUpdated,
        document.Salary,
        document.SalaryTier,
        document.Owner,
        document.Custom and 1 or 0,
        document.Hidden and 1 or 0
      })

    if insertResult then
      return true
    else
      exports['pulsar-core']:LoggerError('Jobs', 'Error Inserting Job on Default Job Update')
      return false
    end
  end

  local jobsFetch = FindAllJobs()
  local currentData = {}
  for k, v in ipairs(jobsFetch) do
    currentData[v.Id] = v
  end

  for k, v in ipairs(_defaultJobData) do
    local currentDataForJob = currentData[v.Id]
    if currentDataForJob and v.LastUpdated < v.LastUpdated then
      replaceExistingDefaultJob(currentDataForJob._id, v)
    elseif not currentDataForJob then
      insertDefaultJob(v)
    end
  end

  RefreshAllJobData()
  exports['pulsar-core']:LoggerTrace("Jobs", string.format("Loaded ^2%s^7 Jobs", JOB_COUNT))
  TriggerEvent("Jobs:Server:CompleteStartup")
end
