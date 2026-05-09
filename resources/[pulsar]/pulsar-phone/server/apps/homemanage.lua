AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Home:CreateDigiKey", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local property = exports['pulsar-properties']:Get(data.id)
			if property ~= nil then
				local mykey = property.keys[char:GetData("ID")]
				if mykey ~= nil and mykey.Owner then
					if data.updating then
						local charId = nil
						local charSource = nil

						for k, v in pairs(property.keys) do
							if v.SID == data.target then
								charId = v.Char
							end
						end

						if charId ~= nil and property.keys[charId] ~= nil then
							local onlineChar = exports['pulsar-characters']:FetchByID(data.target)
							if onlineChar then
								charSource = onlineChar:GetData("Source")
							end

							if exports['pulsar-properties']:GiveKey({
									ID = charId,
									SID = property.keys[charId].SID,
									First = property.keys[charId].First,
									Last = property.keys[charId].Last,
									Source = charSource,
								}, data.id, false, data.permissions, true) then
								if charSource then
									exports['pulsar-phone']:NotificationAdd(
										charSource,
										"DigiKey Updated",
										"One of your DigiKey's Have Been Updated",
										os.time(),
										6000,
										"homemanage",
										{
											view = "",
										}
									)
								end
								cb({ error = false, code = 1 })
							else
								cb({ error = true, code = 7 })
							end
						else
							cb({ error = true, code = 7 })
						end
					else
						local tchar = exports['pulsar-characters']:FetchBySID(data.target)
						if tchar ~= nil then
							if property.keys[tchar:GetData("ID")] == nil then
								if exports['pulsar-properties']:GiveKey({
										ID = tchar:GetData("ID"),
										SID = tchar:GetData("SID"),
										First = tchar:GetData("First"),
										Last = tchar:GetData("Last"),
										Source = tchar:GetData("Source"),
									}, data.id, false, data.permissions) then
									exports['pulsar-phone']:NotificationAdd(
										tchar:GetData("Source"),
										"DigiKey Issued",
										"You've been given a new DigiKey",
										os.time(),
										6000,
										"homemanage",
										{
											view = "",
										}
									)
									cb({ error = false, code = 1 })
								else
									cb({ error = true, code = 7 })
								end
							else
								cb({ error = true, code = 6 })
							end
						else
							cb({ error = true, code = 5 })
						end
					end
				else
					cb({ error = true, code = 3 })
				end
			else
				cb({ error = true, code = 2 })
			end
		else
			cb({ error = true, code = 1 })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Home:RevokeDigiKey", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local property = exports['pulsar-properties']:Get(data.id)
			if property ~= nil then
				local mykey = property.keys[char:GetData("ID")]
				if mykey ~= nil and mykey.Owner then
					if exports['pulsar-properties']:TakeKey(data.target, data.id) then
						local tchar = exports['pulsar-characters']:FetchByID(data.id)
						if tchar ~= nil then
							exports['pulsar-phone']:NotificationAdd(
								tchar:GetData("Source"),
								"DigiKey Revoked",
								"One of your DigiKeys have been revoked",
								os.time(),
								6000,
								"homemanage",
								{
									view = "",
								}
							)
						end
						cb({ error = false, code = 1 })
					else
						cb({ error = true, code = 4 })
					end
				else
					cb({ error = true, code = 3 })
				end
			else
				cb({ error = true, code = 2 })
			end
		else
			cb({ error = true, code = 1 })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Home:RemoveMyKey", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local property = exports['pulsar-properties']:Get(data.id)
			if property ~= nil then
				local mykey = property.keys[char:GetData("ID")]
				if mykey ~= nil and not mykey.Owner then
					if exports['pulsar-properties']:TakeKey(char:GetData("ID"), data.id) then
						exports['pulsar-phone']:NotificationAdd(
							source,
							"DigiKey Revoked",
							"One of your DigiKeys have been revoked",
							os.time(),
							6000,
							"homemanage",
							{
								view = "",
							}
						)
						cb({ error = false, code = 1 })
					else
						cb({ error = true, code = 4 })
					end
				else
					cb({ error = true, code = 3 })
				end
			else
				cb({ error = true, code = 2 })
			end
		else
			cb({ error = true, code = 1 })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Phone:Home:LockProperty", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local property = exports['pulsar-properties']:Get(data.id)
			if property ~= nil then
				if property.keys ~= nil and property.keys[char:GetData("ID")] ~= nil then
					cb(exports['pulsar-properties']:ToggleLock(data.id))
				else
					cb(false)
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)
