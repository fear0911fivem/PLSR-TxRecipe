local govDutyPoints = Config.GovDutyZones

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		local govServices = {
			{
				icon = "fas fa-id-card",
				text = "Purchase ID ($500)",
				event = "Government:Client:BuyID",
			},
			{
				icon = "fas fa-id-badge",
				text = "License Services",
				event = "Government:Client:BuyLicense",
			},
			{
				icon = "fas fa-gavel",
				text = "Public Records",
				event = "Government:Client:AccessPublicRecords",
			},
			{
				icon = "fas fa-clipboard-check",
				text = "Go On Duty",
				event = "Government:Client:OnDuty",
				groups = { "government" },
				reqOffDuty = true,
			},
			{
				icon = "fas fa-clipboard",
				text = "Go Off Duty",
				event = "Government:Client:OffDuty",
				groups = { "government" },
				reqDuty = true,
			},
			{
				icon = "fas fa-shop-lock",
				text = "DOJ Shop",
				event = "Government:Client:DOJShop",
				groups = { "government" },
				workplace = "doj",
				reqDuty = true,
			},
		}

		local p = Config.GovServicesPed
		exports['pulsar-pedinteraction']:Add(
			"govt-services",
			p.model,
			p.coords,
			p.heading,
			25.0,
			govServices,
			"bell-concierge"
		)
		-- exports.ox_target:addBoxZone({
		--     id = "govt-services",
		--     coords = vector3(-555.92, -186.01, 38.22),
		--     size = vector3(2.0, 2.0, 2.0),
		--     rotation = 28,
		--     debug = false,
		--     minZ = 37.22,
		--     maxZ = 39.62,
		--     options = govServices
		-- })

		for _, v in ipairs(govDutyPoints) do
			exports.ox_target:addBoxZone({
				id       = v.id,
				coords   = v.coords,
				size     = v.size,
				rotation = v.rotation,
				debug    = false,
				minZ     = v.minZ,
				maxZ     = v.maxZ,
				options = {
					{
						icon = "fas fa-clipboard-check",
						label = "Go On Duty",
						event = "Government:Client:OnDuty",
						groups = { "government" },
						reqDuty = false,
					},
					{
						icon = "fas fa-clipboard",
						label = "Go Off Duty",
						event = "Government:Client:OffDuty",
						groups = { "government" },
						reqDuty = true,
					},
					{
						icon = "fas fa-gavel",
						label = "Public Records",
						event = "Government:Client:AccessPublicRecords",
					},
				}
			})
		end

		exports['pulsar-polyzone']:CreateBox("courtroom", vector3(-571.17, -207.02, 38.77), 18.2, 19.6, {
			heading = 30,
			--debugPoly=true,
			minZ = 36.97,
			maxZ = 47.37,
		}, {})

		local gavel = Config.CourthouseGavel
		exports.ox_target:addBoxZone({
			id       = "court-gavel",
			coords   = gavel.coords,
			size     = gavel.size,
			rotation = gavel.rotation,
			debug    = false,
			minZ     = gavel.minZ,
			maxZ     = gavel.maxZ,
			options  = {
				{
					icon  = "fas fa-gavel",
					label = "Use Gavel",
					event = "Government:Client:UseGavel",
				},
			}
		})
	end
end)

RegisterNetEvent("Characters:Client:Spawn", function()
	exports["pulsar-blips"]:Add("courthouse", "Courthouse", Config.CourthouseBlip, 419, 0, 0.9)
end)

AddEventHandler("Government:Client:UseGavel", function()
	TriggerServerEvent("Government:Server:Gavel")
end)

RegisterNetEvent("Government:Client:Gavel", function()
	if not LocalPlayer.state.loggedIn then
		return
	end
	local coords = GetEntityCoords(LocalPlayer.state.ped)
	if exports['pulsar-polyzone']:IsCoordsInZone(coords, "courtroom") then
		exports["pulsar-sounds"]:PlayOne("gavel.ogg", 0.6)
	end
end)

AddEventHandler("Government:Client:DOJShop", function()
	exports.ox_inventory:ShopOpen("doj-shop")
end)
