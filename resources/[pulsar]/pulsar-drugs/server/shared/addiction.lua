function RunDegenThread()
	for k, v in pairs(exports['pulsar-characters']:FetchAllCharacters()) do
		if v ~= nil then
			local addictions = v:GetData("Addiction")
			if addictions ~= nil then
				for k2, v2 in pairs(addictions) do
					if v2.Factor > 0 and v2.LastUse < os.time() - (60 * 60 * 2) then
						v2.Factor = v2.Factor - 1.0

						if v2.Factor < 0 then
							v2.Factor = 0
						end

						DoAlert(v:GetData("Source"), k2, v2.Factor + 1.0, v2.Factor)
					end
				end
				v:SetData("Addiction", addictions)
			end
		end
	end
end

function DoAlert(source, drug, previous, factor)
	if factor > 10.0 and previous <= 10.0 then
		exports['pulsar-hud']:Notification(source, "info",
			string.format("You're Incredibly Addicted To %s", drug))
	elseif factor > 5.0 and (previous <= 5.0 or previous > 10.0) then
		exports['pulsar-hud']:Notification(source, "info",
			string.format("You're Very Addicted To %s", drug))
	elseif factor > 0.0 and (previous <= 0.0) then
		exports['pulsar-hud']:Notification(source, "info",
			string.format("You're Somewhat Addicted To %s", drug))
	elseif factor <= 0.0 and (previous > 0.0) then
		exports['pulsar-hud']:Notification(source, "info",
			string.format("You're No Longer Addicted To %s", drug))
	end
end

exports('AddictionAdd', function(source, drug, factor)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local addictions = char:GetData("Addiction")
		addictions[drug] = {
			LastUse = os.time(),
			Factor = addictions[drug].Factor + (factor or 1.0),
		}
		DoAlert(source, drug, addictions[drug].Factor - (factor or 1.0), addictions[drug].Factor)
		char:SetData("Addiction", addictions)
	end
end)

exports('AddictionRemove', function(source, drug, factor)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local addictions = char:GetData("Addiction")
		addictions[drug] = {
			LastUse = os.time(),
			Factor = addictions[drug].Factor - (factor or 1.0),
		}

		if addictions[drug].Factor < 0 then
			addictions[drug].Factor = 0
		end

		DoAlert(source, drug, addictions[drug].Factor - (factor or 1.0), addictions[drug].Factor)
		char:SetData("Addiction", addictions)
	end
end)

exports('AddictionReset', function(source, drug)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local addictions = char:GetData("Addiction")
		addictions[drug] = {
			LastUse = false,
			Factor = 0,
		}
		DoAlert(source, drug, addictions[drug].Factor)
		char:SetData("Addiction", addictions)
	end
end)
