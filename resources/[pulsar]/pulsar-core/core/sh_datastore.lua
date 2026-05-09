local _stores = {}

local _blacklistedCharEvents = {
	HP = true,
	Armor = true,
}

exports("CreateStore", function(owner, key, data)
	data = data or {}
	_stores[owner] = _stores[owner] or {}

	_stores[owner][key] = data

	return {
		Owner = owner,
		Key = key,
		SetData = function(self, var, data)
			_stores[self.Owner][self.Key][var] = data

			if self.Key == "Character" and IsDuplicityVersion() and not _blacklistedCharEvents[var] then
				TriggerClientEvent("Characters:Client:SetData", _stores[self.Owner][self.Key]["Source"], var, data)
			end
		end,
		GetData = function(self, var)
			if var ~= nil and var ~= "" then
				if
					_stores[self.Owner]
					and _stores[self.Owner][self.Key]
					and _stores[self.Owner][self.Key][var] ~= nil
				then
					return _stores[self.Owner][self.Key][var]
				else
					return nil
				end
			else
				return _stores[self.Owner][self.Key]
			end
		end,
		DeleteStore = function(self)
			exports["pulsar-core"]:DeleteStore(self.Owner, self.Key)
		end,
	}
end)

exports("GetStore", function(owner, key)
	if _stores[owner] and _stores[owner][key] then
		local internalStore = {
			Owner = owner,
			Key = key,
			SetData = function(self, var, data)
				_stores[self.Owner][self.Key][var] = data

				if self.Key == "Character" and IsDuplicityVersion() and not _blacklistedCharEvents[var] then
					TriggerClientEvent("Characters:Client:SetData", _stores[self.Owner][self.Key]["Source"], var, data)
				end
			end,
			GetData = function(self, var)
				if var ~= nil and var ~= "" then
					if
						_stores[self.Owner]
						and _stores[self.Owner][self.Key]
						and _stores[self.Owner][self.Key][var] ~= nil
					then
						return _stores[self.Owner][self.Key][var]
					else
						return nil
					end
				else
					return _stores[self.Owner][self.Key]
				end
			end,
			DeleteStore = function(self)
				exports["pulsar-core"]:DeleteStore(self.Owner, self.Key)
			end,
		}

		local store = {
			Owner = owner,
			Key = key,
			SetData = function(var, data)
				if type(var) ~= "string" then
					return nil
				end
				return internalStore:SetData(var, data)
			end,
			GetData = function(var, data)
				local key = var
				if type(var) ~= "string" and data and type(data) == "string" then
					key = data
				elseif type(var) ~= "string" then
					return nil
				end
				return internalStore:GetData(key)
			end,
			DeleteStore = function()
				return internalStore:DeleteStore()
			end,
		}

		setmetatable(store, {
			__index = function(self, key)
				if type(self[key]) == "function" then
					return self[key]
				end
				return self:GetData(key)
			end,
			__newindex = function(self, key, value)
				self:SetData(key, value)
			end
		})

		return store
	end
	return nil
end)

exports("GetCharacterData", function(key, source)
	local playerId = source or (LocalPlayer and LocalPlayer.state.Character and LocalPlayer.state.Character.Owner)
	local character = exports["pulsar-core"]:GetStore(playerId, "Character")
	if character then
		return character:GetData(key)
	end
	return nil
end)

exports("SetCharacterData", function(key, value, source)
	local playerId = source or (LocalPlayer and LocalPlayer.state.Character and LocalPlayer.state.Character.Owner)
	local character = exports["pulsar-core"]:GetStore(playerId, "Character")
	if character then
		return character:SetData(key, value)
	end
	return nil
end)

exports("DeleteCharacterStore", function(source)
	local playerId = source or (LocalPlayer and LocalPlayer.state.Character and LocalPlayer.state.Character.Owner)
	local character = exports["pulsar-core"]:GetStore(playerId, "Character")
	if character then
		return character:DeleteStore()
	end
	return nil
end)

exports("DeleteStore", function(owner, key)
	if _stores[owner] then
		_stores[owner][key] = nil
	end
end)
