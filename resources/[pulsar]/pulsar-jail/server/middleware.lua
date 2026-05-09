function RegisterMiddleware()
	exports['pulsar-core']:MiddlewareAdd("Characters:Creating", function(source, cData)
		return {
			{
				Jailed = false,
			},
		}
	end)

	exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
		local _src = source
		local currentTime = os.time() * 1000

		local char = exports['pulsar-characters']:FetchCharacterSource(_src)
		if char ~= nil then
			local jailed = char:GetData("Jailed")
			if
				(jailed and jailed.Jailed and jailed.Jailed.Time ~= nil and jailed.Jailed.Duration ~= nil)
				and (os.time() >= jailed.Time + (jailed.Duration * 60))
			then
				char:SetData("Jailed", false)
			end
		end
	end, 2)

	local function CheckJailed(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local jailed = char:GetData("Jailed") or false
			if
				(jailed and jailed.Jailed and jailed.Jailed.Time ~= nil and jailed.Jailed.Duration ~= nil)
				and (os.time() >= jailed.Time + (jailed.Duration * 60))
			then
				char:SetData("Jailed", false)
			end
		end
	end

	exports['pulsar-core']:MiddlewareAdd("Characters:Logout", CheckJailed, 1)
	exports['pulsar-core']:MiddlewareAdd("playerDropped", CheckJailed, 1)
end
