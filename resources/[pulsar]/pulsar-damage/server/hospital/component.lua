BED_LIMIT = #Config.Beds
_inBed = {}
_inBedChar = {}

local _medsForSale = {
	{ item = "firstaid", coin = "MALD", price = 20,  qty = -1, vpn = false, requireCurrency = false },
	{ item = "ifak",     coin = "MALD", price = 100, qty = -1, vpn = false, requireCurrency = true },
}

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		HospitalCallbacks()
		HospitalMiddleware()

		GlobalState["HiddenHospital"] = {
			coords = vector3(2810.023, 5977.588, 349.919),
			heading = 146.641,
		}

		exports['pulsar-pedinteraction']:VendorCreate("BlackmarketMeds", "ped", "Medical Supplies", `S_M_M_Paramedic_01`,
			{
				coords = vector3(2815.044, 5980.179, 349.928),
				heading = 277.889,
				scenario = "WORLD_HUMAN_CLIPBOARD",
			}, _medsForSale, "pump-medical", "View Supplies", false, false, true)

		exports["pulsar-chat"]:RegisterAdminCommand("clearbeds", function(source, args, rawCommand)
			_inBed = {}
		end, {
			help = "Force Clear All Hospital Beds",
			params = {},
		}, -1)
	end
end)

exports("HospitalRequestBed", function(source)
	--return math.random(#Config.Beds)
	for k, v in ipairs(Config.Beds) do
		if _inBed[k] == nil then
			return k
		end
	end
	return nil
end)

exports("HospitalFindBed", function(source, location)
	for k, v in ipairs(Config.Beds) do
		if (#(vector3(v.x, v.y, v.z) - vector3(location.x, location.y, location.z)) <= 2.0) and not _inBed[k] then
			return k
		end
	end
	return nil
end)

exports("HospitalOccupyBed", function(source, bedId)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char and Config.Beds[bedId] ~= nil then
		if _inBed[bedId] == nil then
			_inBedChar[char:GetData("ID")] = bedId
			_inBed[bedId] = char:GetData("ID")
			return true
		else
			return false
		end
	else
		return false
	end
end)

exports("HospitalLeaveBed", function(source)
	local char = exports['pulsar-characters']:FetchCharacterSource(source)
	if char ~= nil then
		local inBedId = _inBedChar[char:GetData("ID")]
		if inBedId ~= nil then
			_inBed[inBedId] = nil
			_inBedChar[char:GetData("ID")] = nil
			return true
		end
	end
	return false
end)

exports("HospitalICUSend", function(target)
	local char = exports['pulsar-characters']:FetchCharacterSource(target)
	if char ~= nil then
		if char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
			return false
		end

		exports['pulsar-labor']:JailSentenced(target)

		Player(target).state.ICU = true
		char:SetData("ICU", {
			Released = false,
		})

		CreateThread(function()
			exports['pulsar-jobs']:DutyOff(target, Player(target).state.onDuty)
			exports['pulsar-police']:UncuffTarget(-1, target)
			exports['pulsar-ped']:MaskUnequipNoItem(target)
			exports.ox_inventory:HoldingPut(target)
		end)

		exports['pulsar-pwnzor']:TempPosIgnore(target)
		TriggerClientEvent("Hospital:Client:ICU:Sent", target)
		TriggerClientEvent("Hospital:Client:ICU:Enter", target)
		exports['pulsar-hud']:Notification("info", target, "You Were Admitted To ICU")
	else
		return false
	end
end)

exports("HospitalICURelease", function(target)
	local char = exports['pulsar-characters']:FetchCharacterSource(target)
	if char ~= nil then
		Player(target).state.ICU = false
		char:SetData("ICU", {
			Released = true,
			Items = false,
		})
		exports['pulsar-hud']:Notification("info", target, "You Were Released From ICU")
	else
		return false
	end
end)

exports("HospitalICUGetItems", function(target)
	local char = exports['pulsar-characters']:FetchCharacterSource(target)
	if char ~= nil then
		Player(target).state.ICU = false
		char:SetData("ICU", {
			Released = true,
			Items = true,
		})
		exports.ox_inventory:HoldingTake(target)
	else
		return false
	end
end)
