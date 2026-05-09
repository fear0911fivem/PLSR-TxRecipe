AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RepItems()
	end
end)

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RepItems()
	end
end)

function RepItems()
	exports.ox_inventory:RegisterUse("rep_voucher", "RandomItems", function(source, item)
		if item.MetaData.Reputation and ((item.MetaData.Amount and tonumber(item.MetaData.Amount) or 0) > 0) then
			exports['pulsar-characters']:RepAdd(source, item.MetaData.Reputation, item.MetaData.Amount)
			exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1)
		else
			exports['pulsar-hud']:Notification(source, "error", "Invalid Voucher")
		end
	end)
end

exports('RepCreate', function(id, label, levels, hidden)
	GlobalState[string.format("Rep:%s", id)] = {
		id = id,
		label = label,
		levels = levels,
		hidden = hidden,
	}
end)

exports('RepGetLevel', function(source, id)
	if GlobalState[string.format("Rep:%s", id)] ~= nil then
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local reps = char:GetData("Reputations") or {}
			local level = 0
			if reps[id] ~= nil then
				for k, v in ipairs(GlobalState[string.format("Rep:%s", id)].levels) do
					if v.value <= reps[id] then
						level = k
					end
				end
				return level
			else
				return 0
			end
		else
			return nil
		end
	else
		return nil
	end
end)

exports('RepHasLevel', function(source, id, level)
	if GlobalState[string.format("Rep:%s", id)] ~= nil then
		return exports['pulsar-characters']:RepGetLevel(source, id) >= level
	else
		return false
	end
end)

exports('RepView', function(source)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local reps = char:GetData("Reputations") or {}
		local viewingData = {}

		for id, val in pairs(reps) do
			local repData = GlobalState[string.format("Rep:%s", id)]
			if id and val and repData and not repData.hidden then
				local repCurrent = {
					level = 0,
					value = 0
				}

				for k, v in ipairs(repData.levels) do
					if v.value <= val then
						repCurrent = {
							level = k,
							label = v.label,
							value = v.value,
						}
					end
				end

				local repNext = {
					level = repCurrent.level + 1
				}

				local nextRepLevel = repCurrent.level + 1
				local nextRepLevelLabel = nil
				if repData.levels[nextRepLevel] then
					repNext.value = repData.levels[nextRepLevel].value
					repNext.label = repData.levels[nextRepLevel].label
				else
					repNext = {
						level = repCurrent.level,
						value = repCurrent.value,
						label = 'Done!',
					}
				end

				table.insert(viewingData, {
					id = repData.id,
					label = repData.label,
					value = val,
					current = repCurrent,
					next = repNext,
				})
			end
		end

		return viewingData
	else
		return nil
	end
end)

exports('RepViewList', function(source, list)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local reps = char:GetData("Reputations") or {}
		local viewingData = {}

		for id, val in pairs(reps) do
			local repData = GlobalState[string.format("Rep:%s", id)]
			if id and val and repData and list[id] then
				local repCurrent = {
					level = 0,
					value = 0
				}

				for k, v in ipairs(repData.levels) do
					if v.value <= val then
						repCurrent = {
							level = k,
							label = v.label,
							value = v.value,
						}
					end
				end

				local repNext = {
					level = repCurrent.level + 1
				}

				local nextRepLevel = repCurrent.level + 1
				local nextRepLevelLabel = nil
				if repData.levels[nextRepLevel] then
					repNext.value = repData.levels[nextRepLevel].value
					repNext.label = repData.levels[nextRepLevel].label
				else
					repNext = {
						level = repCurrent.level,
						value = repCurrent.value,
						label = 'Done!',
					}
				end

				table.insert(viewingData, {
					id = repData.id,
					label = repData.label,
					value = val,
					current = repCurrent,
					next = repNext,
				})
			end
		end

		return viewingData
	else
		return nil
	end
end)

exports('RepAdd', function(source, id, amount)
	if GlobalState[string.format("Rep:%s", id)] ~= nil then
		local rep = GlobalState[string.format("Rep:%s", id)]
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local reps = char:GetData("Reputations") or {}
			if reps[id] ~= nil then
				if reps[id] + math.abs(amount) <= rep.levels[#rep.levels].value then
					reps[id] = reps[id] + math.abs(amount)
				else
					reps[id] = rep.levels[#rep.levels].value
				end
			else
				if math.abs(amount) <= rep.levels[#rep.levels].value then
					reps[id] = math.abs(amount)
				else
					reps[id] = rep.levels[#rep.levels].value
				end
			end
			char:SetData("Reputations", reps)
		end
	end
end)

exports('RepRemove', function(source, id, amount)
	if GlobalState[string.format("Rep:%s", id)] ~= nil then
		local rep = GlobalState[string.format("Rep:%s", id)]

		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local reps = char:GetData("Reputations") or {}
			if reps[id] ~= nil and (reps[id] - math.abs(amount) > 0) then
				reps[id] = reps[id] - math.abs(amount)
			else
				reps[id] = 0
			end
			char:SetData("Reputations", reps)
		end
	end
end)
