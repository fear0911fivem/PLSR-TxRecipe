local _selling = {}
local _pendingLoanAccept = {}

local govCut = 5
local commissionCut = 5
local companyCut = 10

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Dyn8:Search", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			local whereClause = "label LIKE ?"
			local params = { "%" .. data .. "%" }

			if Player(source).state.onDuty ~= 'realestate' then
				whereClause = whereClause .. " AND sold = 0"
			end

			exports.oxmysql:execute('SELECT * FROM properties WHERE ' .. whereClause .. ' LIMIT 80', params,
				function(results)
					if not results then
						cb(false)
						return
					end

					local convertedResults = {}
					for k, v in ipairs(results) do
						local property = {
							_id = v.id,
							id = v.id,
							type = v.type,
							label = v.label,
							price = v.price,
							sold = v.sold == 1,
							owner = v.owner,
							location = v.location and json.decode(v.location) or nil,
							upgrades = v.upgrades and json.decode(v.upgrades) or nil,
							locked = v.locked == 1,
							keys = v.keys and json.decode(v.keys) or nil,
							data = v.data and json.decode(v.data) or nil,
							foreclosed = v.foreclosed == 1,
							soldAt = v.soldAt
						}
						table.insert(convertedResults, property)
					end

					cb(convertedResults)
				end)
		else
			cb(false)
		end
	end)
end)
