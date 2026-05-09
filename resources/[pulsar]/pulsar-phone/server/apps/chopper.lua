local marketItems = {
	{
		item = "chopping_invite",
		coin = "MALD",
		price = 600,
		vpn = true,
		ep = "Chopping",
		repLvl = 3,
		limited = {
			id = 1,
			qty = 1,
		},
	},
}

local _blacklistedJobs = {
	police = true,
	ems = true,
	government = true,
}

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports['pulsar-pedinteraction']:VendorCreate("ChoperItems", "ped", "Items", `U_M_Y_SmugMech_01`, {
		coords = vector3(-623.589, -1681.736, 19.101),
		heading = 228.222,
		scenario = "WORLD_HUMAN_TOURIST_MOBILE",
	}, marketItems, "fas fa-money-bill", "View Offers", false, false, true)
end)

function RegisterItemUses()
	exports.ox_inventory:RegisterUse("chopping_invite", "LSUNDG", function(source, item, itemData)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char ~= nil then
			local pState = Player(source).state
			if not pState.onDuty or not _blacklistedJobs[pState.onDuty] then
				if not hasValue(char:GetData("States") or {}, "ACCESS_CHOPPER") then
					if exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1) then
						local states = char:GetData("States") or {}
						table.insert(states, "ACCESS_CHOPPER")
						char:SetData("States", states)

						char:SetData("Apps",
							exports['pulsar-phone']:StoreInstallDo("chopper", char:GetData("Apps"), "force"))

						SetTimeout(5000, function()
							exports['pulsar-phone']:NotificationAdd(source, "App Installed", nil, os.time(), 6000,
								"chopper", {
									view = "",
								}, nil)
						end)
					end
				else
					exports['pulsar-hud']:Notification(source, "error",
						"You already have access to that app")
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "You Can't Use This Item")
			end
		end
	end)
end

RegisterNetEvent('ox_inventory:ready', function()
	if GetResourceState(GetCurrentResourceName()) == 'started' then
		RegisterItemUses()
	end
end)

-- Also try to register on resource start in case ox_inventory is already ready
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		Wait(2000) -- Wait for ox_inventory to be ready
		if GetResourceState('ox_inventory') == 'started' then
			RegisterItemUses()
		end
	end
end)