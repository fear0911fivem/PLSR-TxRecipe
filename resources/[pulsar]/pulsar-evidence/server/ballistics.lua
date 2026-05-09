function RegisterBallisticsCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Evidence:Ballistics:FileGunWeaponInHand", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and data and data.serial and data.weaponData then
			local weaponData = data.weaponData
			if weaponData and weaponData.metadata and weaponData.metadata.serial then
				local firearmRecord = MySQL.single.await(
					"SELECT serial, scratched, model, owner_sid, owner_name, police_filed, police_id FROM firearms WHERE serial = ?",
					{ weaponData.metadata.serial }
				)

				if firearmRecord then
					if not firearmRecord.police_filed or firearmRecord.police_filed == 0 then
						MySQL.query.await("UPDATE firearms SET police_filed = ? WHERE serial = ?", {
							1,
							firearmRecord.serial,
						})

						if firearmRecord.scratched == 1 then
							exports.ox_inventory:SetMetaDataKey(weaponData.slot, "PoliceWeaponId",
								firearmRecord.police_id, source)
						end

						return cb(
							true,
							false,
							GetMatchingEvidenceProjectiles(firearmRecord.serial),
							firearmRecord.scratched == 1 and string.format("PWI-%s", firearmRecord.police_id) or firearmRecord.serial
						)
					else
						return cb(
							true,
							true,
							GetMatchingEvidenceProjectiles(firearmRecord.serial),
							firearmRecord.scratched == 1 and string.format("PWI-%s", firearmRecord.police_id) or firearmRecord.serial
						)
					end
				end
			end
		end
		cb(false)
	end)
end

function RegisterBallisticsItemUses()
	exports.ox_inventory:RegisterUse("evidence-projectile", "Evidence", function(source, slot, itemData)
		if slot and slot.MetaData then
			if slot.MetaData.EvidenceId and slot.MetaData.EvidenceWeapon then
				exports["pulsar-core"]:ClientCallback(source, "Polyzone:IsCoordsInZone", {
					coords = GetEntityCoords(GetPlayerPed(source)),
					key = "ballistics",
					val = true,
				}, function(inZone)
					if inZone then
						if not slot.MetaData.EvidenceDegraded then
							local filedEvidence = GetEvidenceProjectileRecord(slot.MetaData.EvidenceId)
							local matchingWeapon = MySQL.single.await(
								"SELECT serial, scratched, model, owner_sid, owner_name, police_filed, police_id FROM firearms WHERE serial = ? AND police_filed = ?",
								{
									slot.MetaData.EvidenceWeapon.serial,
									1
								})

							if filedEvidence then -- Already Exists
								TriggerClientEvent(
									"Evidence:Client:FiledProjectile",
									source,
									false,
									true,
									true,
									filedEvidence,
									matchingWeapon,
									slot.MetaData.EvidenceId
								)
							else
								local newFiledEvidence = CreateEvidenceProjectileRecord({
									Id = slot.MetaData.EvidenceId,
									Weapon = slot.MetaData.EvidenceWeapon,
									Coords = slot.MetaData.EvidenceCoords,
									AmmoType = slot.MetaData.EvidenceAmmoType,
								})

								if newFiledEvidence then
									TriggerClientEvent(
										"Evidence:Client:FiledProjectile",
										source,
										false,
										true,
										false,
										newFiledEvidence,
										matchingWeapon,
										slot.MetaData.EvidenceId
									)
								else
									TriggerClientEvent("Evidence:Client:FiledProjectile", source, false, false)
								end
							end
						else
							TriggerClientEvent("Evidence:Client:FiledProjectile", source, true)
						end
					else
						exports['pulsar-hud']:Notification(source, "error", "You must be in the ballistics lab")
					end
				end)
			end
		end
	end)

	exports.ox_inventory:RegisterUse("evidence-dna", "Evidence", function(source, slot, itemData)
		if slot and slot.MetaData then
			if slot.MetaData.EvidenceId and slot.MetaData.EvidenceDNA then
				exports["pulsar-core"]:ClientCallback(source, "Polyzone:IsCoordsInZone", {
					coords = GetEntityCoords(GetPlayerPed(source)),
					key = "dna",
					val = true,
				}, function(inZone)
					if inZone then
						if not slot.MetaData.EvidenceDegraded then
							local char = GetCharacter(slot.MetaData.EvidenceDNA)
							if char then
								TriggerClientEvent(
									"Evidence:Client:RanDNA",
									source,
									false,
									char,
									slot.MetaData.EvidenceId
								)
							else
								TriggerClientEvent("Evidence:Client:RanDNA", source, false, false)
							end
						else
							TriggerClientEvent("Evidence:Client:RanDNA", source, true)
						end
					else
						exports['pulsar-hud']:Notification(source, "error", "You must be in the DNA lab")
					end
				end)
			end
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterBallisticsItemUses()
	end
end)

function GetEvidenceProjectileRecord(evidenceId)
	local results = MySQL.query.await('SELECT * FROM firearms_projectiles WHERE Id = ?', { evidenceId })
	
	if results and #results > 0 and results[1] then
		local record = results[1]
		if record.Weapon and type(record.Weapon) == "string" then
			record.Weapon = json.decode(record.Weapon)
		end
		if record.Coords and type(record.Coords) == "string" then
			record.Coords = json.decode(record.Coords)
		end
		return record
	end
	
	return false
end

function CreateEvidenceProjectileRecord(document)
	local weaponJson = json.encode(document.Weapon)
	local coordsJson = json.encode(document.Coords)

	local insertId = MySQL.insert.await(
		'INSERT INTO firearms_projectiles (Id, Weapon, Coords, AmmoType) VALUES (?, ?, ?, ?)',
		{ document.Id, weaponJson, coordsJson, document.AmmoType }
	)

	if insertId and insertId > 0 then
		return document
	end
	
	return false
end

function GetMatchingEvidenceProjectiles(weaponSerial)
	if not weaponSerial or weaponSerial == "" then
		return {}
	end
	
	local results = MySQL.query.await(
		'SELECT Id FROM firearms_projectiles WHERE JSON_UNQUOTE(JSON_EXTRACT(Weapon, "$.serial")) = ?',
		{ weaponSerial }
	)
	
	if results and #results > 0 then
		local foundEvidence = {}
		for k, v in ipairs(results) do
			table.insert(foundEvidence, v.Id)
		end
		return foundEvidence
	end
	
	return {}
end

function GetCharacter(stateId)
	local results = MySQL.query.await("SELECT SID, First, Last, DOB FROM characters WHERE SID = ?", { stateId })
	
	if results and #results > 0 then
		local char = results[1]
		if char and char.SID and char.First and char.Last and char.DOB then
			local age = 0
			if type(char.DOB) == "string" then
				local year, month, day = char.DOB:match("(%d+)-(%d+)-(%d+)")
				if year then
					local dobTime = os.time({
						year = tonumber(year),
						month = tonumber(month),
						day = tonumber(day),
						hour = 0,
						min = 0,
						sec = 0
					})
					age = math.floor((os.time() - dobTime) / 31536000)
				end
			elseif type(char.DOB) == "number" then
				age = math.floor((os.time() - char.DOB) / 31536000)
			end
			
			return {
				SID = char.SID,
				First = char.First,
				Last = char.Last,
				Age = age,
			}
		end
	end
	
	return false
end

AddEventHandler('Evidence:Server:RunBallistics', function(source, data)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if not char then return end
	
	local pState = Player(source).state
	if pState.onDuty ~= "police" then return end
	
	local its = exports.ox_inventory:GetInventory(source, data.owner, data.invType)
	if not its or #its == 0 then return end
	
	local item = its[1]
	local md = json.decode(item.metadata)
	local itemData = exports.ox_inventory:ItemsGetData(item.Name)
	
	if not itemData or itemData.type ~= 2 then
		exports['pulsar-hud']:Notification(source, "error", "Item Must Be A Weapon")
		return
	end
	
	local serial = md.serial or md.SerialNumber or md.ScratchedSerialNumber
	local isScratched = md.ScratchedSerialNumber ~= nil
	
	if not serial then
		exports.ox_inventory:BallisticsClear(source, data.owner, data.invType)
		exports["pulsar-core"]:ClientCallback(source, "Evidence:RunBallistics", {
			false, false, false, false, false, nil
		})
		return
	end
	
	local firearmRecord = MySQL.single.await(
		"SELECT serial, scratched, model, owner_sid, owner_name, police_filed, police_id FROM firearms WHERE serial = ?",
		{ serial }
	)
	
	if firearmRecord then
		if not firearmRecord.police_filed or firearmRecord.police_filed == 0 then
			MySQL.query.await("UPDATE firearms SET police_filed = ? WHERE serial = ?", {
				1,
				firearmRecord.serial,
			})
			
			if firearmRecord.scratched == 1 then
				exports.ox_inventory:SetMetaDataKey(item.id, "PoliceWeaponId",
					firearmRecord.police_id, source)
			end
			
			exports.ox_inventory:BallisticsClear(source, data.owner, data.invType)
			exports["pulsar-core"]:ClientCallback(source, "Evidence:RunBallistics", {
				true,
				false,
				GetMatchingEvidenceProjectiles(firearmRecord.serial),
				firearmRecord.scratched == 1 and string.format("PWI-%s", firearmRecord.police_id) or nil,
				firearmRecord.scratched == 0 and firearmRecord.serial or nil
			})
		else
			exports.ox_inventory:BallisticsClear(source, data.owner, data.invType)
			exports["pulsar-core"]:ClientCallback(source, "Evidence:RunBallistics", {
				true,
				true,
				GetMatchingEvidenceProjectiles(firearmRecord.serial),
				firearmRecord.scratched == 1 and string.format("PWI-%s", firearmRecord.police_id) or nil,
				firearmRecord.scratched == 0 and firearmRecord.serial or nil
			})
		end
	else
		exports.ox_inventory:BallisticsClear(source, data.owner, data.invType)
		exports["pulsar-core"]:ClientCallback(source, "Evidence:RunBallistics", {
			false, false, false, false, false, nil
		})
	end
end)