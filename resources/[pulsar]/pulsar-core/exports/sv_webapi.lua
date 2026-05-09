local function _b64enc(data)
	-- character table string
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

	return (
		(data:gsub(".", function(x)
			local r, b = "", x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return b:sub(c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

exports("WebAPIRequest", function(method, endpoint, params, jsondata)
	exports['pulsar-core']:LoggerTrace("WebAPI", "Endpoint Called: " .. method .. " - " .. endpoint)

	local first = true
	if params ~= nil then
		for k, v in pairs(params) do
			if first then
				endpoint = endpoint .. "?" .. k .. "=" .. v
				first = false
			else
				endpoint = endpoint .. "&" .. k .. "=" .. v
			end
		end
	end

	local p = promise.new()

	PerformHttpRequest(
		exports["pulsar-core"]:GetApiAddress() .. endpoint,
		function(errorCode, resultData, resultHeaders)
			data = {
				data = resultData,
				code = errorCode,
				headers = resultHeaders,
			}

			-- if data.code ~= nil and data.code ~= 200 then
			-- 	exports['pulsar-core']:LoggerError("WebAPI", "Error: " .. data.code, { console = true })
			-- end

			if data.data ~= nil then
				data.data = json.decode(data.data)
			end

			p:resolve(data)
		end,
		method,
		#jsondata > 0 and json.encode(jsondata) or "",
		{
			["Content-Type"] = "application/json",
			["Authorization"] = "Basic " .. _b64enc(
				string.format("%s:%s", exports["pulsar-core"]:GetApiId(), exports["pulsar-core"]:GetApiSecret())
			),
		}
	)

	return Citizen.Await(p)
end)

exports("WebAPIGetMemberIdentifier", function(identifier)
	if identifier ~= nil then
		local data = exports['pulsar-core']:WebAPIRequest("GET", "serverAPI/user/identifier", {
			license = identifier,
		}, {})

		if data.code == 200 then
			return data.data
		end
	end
	return nil
end)

exports("WebAPIGetMemberAccountID", function(accountId)
	if accountId ~= nil then
		local data = exports['pulsar-core']:WebAPIRequest("GET", "serverAPI/user/account", {
			account = accountId,
		}, {})

		if data.code == 200 then
			return data.data
		end
	end
	return nil
end)

-- exports("WebAPIValidate", function()
-- 	exports['pulsar-core']:LoggerTrace("Core", "Validating API Key With Authentication Services", {
-- 		console = true,
-- 	})

-- 	local res = exports['pulsar-core']:WebAPIRequest("GET", "admin/startup", nil, {})

-- 	if res.code ~= 200 then
-- 		exports['pulsar-core']:LoggerCritical("Core", "Failed Validation, Shutting Down Server", {
-- 			console = true,
-- 			file = true,
-- 		})
-- 		exports["pulsar-core"]:Shutdown("Failed Validation, Shutting Down Server")

-- 		return false
-- 	else
-- 		local serverConfig = exports['pulsar-core']:ConfigGetServer()
-- 		serverConfig.ID = res.data.id
-- 		serverConfig.Name = res.data.name
-- 		serverConfig.Access = res.data.restricted
-- 		serverConfig.Channel = res.data.channel
-- 		serverConfig.Region = res.data.region

-- 		GlobalState.GameConfig = {
-- 			ID = res.data.game.id,
-- 			Name = res.data.game.name,
-- 			Short = res.data.game.short,
-- 		}

--		exports['pulsar-core']:ConfigUpdateGroups(res.data.groups)

-- 		GlobalState.IsProduction = res.data.channel:upper() ~= "DEV"
-- 		local serverConfig = exports['pulsar-core']:ConfigGetServer()
-- 		if serverConfig.Access then
-- 			exports['pulsar-core']:LoggerTrace(
-- 				"Core",
-- 				string.format(
-- 					"Server ^2#%s^7 - ^2%s^7 Authenticated, Running With Access Restrictions",
-- 					tostring(serverConfig.ID),
-- 					serverConfig.Name
-- 				),
-- 				{ console = true }
-- 			)
-- 		else
-- 			exports['pulsar-core']:LoggerInfo(
-- 				"Core",
-- 				string.format(
-- 					"Server ^2#%s^7 - ^2%s^7 Authenticated, Running With No Access Restriction",
-- 					tostring(serverConfig.ID),
-- 					serverConfig.Name
-- 				),
-- 				{ console = true }
-- 			)
-- 		end

-- 		exports['pulsar-core']:LoggerTrace("WebAPI", "Loaded ^5" .. tostring(res.data.count) .. "^7 Group Configurations")

-- 		return true
-- 	end
-- end)

-- Endpoint for getting server information to display publicly

local handlerSetup = false
local pendingRestartTime = false

function SetupAPIHandler()
	if not handlerSetup then
		handlerSetup = true

		SetHttpHandler(function(req, res)
			if req.path == "/data" then
				local data = {
					Restart = pendingRestartTime,
					Uptime = GetGameTimer(),
					Players = exports['pulsar-core']:FetchCount(),
					MaxPlayers = GlobalState.MaxPlayers or 64,
				}

				data.Queue = exports['pulsar-core']:QueueGetCount()

				res.send(json.encode(data))
			end
		end)
	end
end

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
	if type(eventData.secondsRemaining) == "number" then
		pendingRestartTime = os.time() + eventData.secondsRemaining
	end
end)
