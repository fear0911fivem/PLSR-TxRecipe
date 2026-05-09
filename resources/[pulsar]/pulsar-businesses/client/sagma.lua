local _tableCam = nil
local _gemObj = 0

local _sagmaPaintings = {
	["business_gallery_01"] = {
		coords = vector3(-442.95, 28.38, 46.68),
		length = 3.4,
		width = 0.6,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.08,
			maxZ = 49.48,
		},
	},
	["business_gallery_02"] = {
		coords = vector3(-420.51, 44.24, 46.23),
		length = 0.4,
		width = 1.2,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.03,
			maxZ = 48.43,
		},
	},
	["business_gallery_03"] = {
		coords = vector3(-423.49, 44.46, 46.23),
		length = 0.4,
		width = 1.2,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.03,
			maxZ = 48.43,
		},
	},
	["business_gallery_04"] = {
		coords = vector3(-426.76, 44.76, 46.23),
		length = 0.4,
		width = 1.2,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.03,
			maxZ = 48.43,
		},
	},
	["business_gallery_05"] = {
		coords = vector3(-434.25, 45.43, 46.23),
		length = 0.4,
		width = 1.2,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.03,
			maxZ = 48.43,
		},
	},
	["business_gallery_06"] = {
		coords = vector3(-458.94, 25.44, 46.68),
		length = 0.4,
		width = 2.0,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.68,
			maxZ = 48.68,
		},
	},
	["business_gallery_07"] = {
		coords = vector3(-453.41, 24.96, 47.15),
		length = 0.4,
		width = 1.8,
		options = {
			heading = 175,
			--debugPoly=true,
			minZ = 46.55,
			maxZ = 48.55,
		},
	},
	["business_gallery_08"] = {
		coords = vector3(-418.67, 42.18, 46.23),
		length = 0.4,
		width = 1.8,
		options = {
			heading = 85,
			--debugPoly=true,
			minZ = 46.23,
			maxZ = 48.63,
		},
	},
	["business_gallery_09"] = {
		coords = vector3(-451.82, 31.3, 46.68),
		length = 0.4,
		width = 1.8,
		options = {
			heading = 85,
			--debugPoly=true,
			minZ = 46.68,
			maxZ = 48.28,
		},
	},
	["business_gallery_10"] = {
		coords = vector3(-453.45, 41.0, 46.68),
		length = 0.4,
		width = 1.8,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.68,
			maxZ = 49.08,
		},
	},
	["business_gallery_11"] = {
		coords = vector3(-453.44, 40.99, 46.68),
		length = 0.4,
		width = 1.8,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 46.68,
			maxZ = 49.08,
		},
	},
	["business_gallery_12"] = {
		coords = vector3(-424.12, 42.01, 52.87),
		length = 0.6,
		width = 3.2,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 52.67,
			maxZ = 55.67,
		},
	},
	["business_gallery_13"] = {
		coords = vector3(-415.86, 41.22, 52.87),
		length = 0.6,
		width = 1.6,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 52.67,
			maxZ = 55.67,
		},
	},
}

local _appraisalTables = {
	{
		coords = vector3(-468.36, 33.02, 46.23),
		length = 2.2,
		width = 1.4,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 45.23,
			maxZ = 47.23,
		},
	},
	{
		coords = vector3(-467.89, 40.4, 46.23),
		length = 2.4,
		width = 1.4,
		options = {
			heading = 355,
			--debugPoly=true,
			minZ = 45.23,
			maxZ = 47.23,
		},
	},
	{
		coords = vector3(-466.79, 46.17, 46.23),
		length = 1.6,
		width = 1.4,
		options = {
			heading = 354,
			--debugPoly=true,
			minZ = 45.23,
			maxZ = 47.83,
		},
	},
}

local _tableConfig = {
	{
		createCoords = vector4(-468.423, 33.344, 46.309, 177.862),
	},
	{
		createCoords = vector4(-468.152, 40.172, 46.530, 170.470),
	},
	{
		createCoords = vector4(-466.827, 46.053, 46.095, 168.156),
	},
}

local _sellers = {
	{
		coords = vector3(-589.303, -707.714, 35.279),
		heading = 1.511,
		model = `a_m_y_smartcaspat_01`,
	},
}

AddEventHandler("Businesses:Client:Startup", function()
	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("SAGMASeller%s", k), v.model, v.coords, v.heading, 25.0, {
			{
				icon = "ring",
				text = "Sell Gems",
				event = "SAGMA:Client:Sell",
				jobPerms = {
					{
						job = "sagma",
						jobPerms = "JOB_SELL_GEMS",
					},
				},
			},
		}, "sack-dollar")
	end

	for k, v in pairs(_sagmaPaintings) do
		exports.ox_target:addBoxZone({
			id = "sagma-art-" .. k,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "palette",
					label = "Update Painting",
					event = "Billboards:Client:SetLink",
					groups = { "sagma" },
					reqDuty = true,
					canInteract = function()
						return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_GEM_TABLE"]
					end,
				},
			}
		})
	end

	for k, v in ipairs(_appraisalTables) do
		exports.ox_target:addBoxZone({
			id = "sagma-table-" .. k,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "gem",
					label = "View Gem Table",
					event = "Businesses:Client:SAGMA:OpenTable",
					groups = { "sagma" },
					reqDuty = true,
					canInteract = function()
						return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_GEM_TABLE"]
					end,
				},
				-- {
				-- 	icon = "gem",
				-- 	label = "Create Jewelry",
				-- 	event = "Businesses:Client:SAGMA:OpenJewelryCrafting",
				-- 	groups = { "sagma" },
				-- 	reqDuty = true,
				-- 	canInteract = function()
				-- 		return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_JEWELRY_CRAFTING"]
				-- 	end,
				-- },
			}
		})
	end
end)

RegisterNetEvent("UI:Client:Reset", function()
	CleanupTable()
end)

AddEventHandler("SAGMA:Client:Sell", function()
	exports["pulsar-core"]:ServerCallback("Businesses:SAGMA:Sell", {})
end)

AddEventHandler("Businesses:Client:SAGMA:OpenTable", function(data)
	exports.ox_inventory:DumbfuckOpen({
		invType = 132,
		owner = data.id,
	})
end)

AddEventHandler("Businesses:Client:SAGMA:OpenJewelryCrafting", function(data)
	exports.ox_inventory:CraftingBenchesOpen("sagma-jewelry")
end)

RegisterNetEvent("Businesses:Client:SAGMA:ViewGem", function(tableId, gemProps, quality, item)
	LocalPlayer.state:set("inGemView", true, true)
	-- exports['pulsar-hud']:GemTableOpen(quality)
	--exports.ox_inventory:StaticTooltipOpen(item)
	local str = string.format("Gem Quality: %s%%", quality)
	exports["pulsar-hud"]:Notification("standard", str, 5000, "gem")
	--ActivateTable(tableId, gemProps.color, quality, item)
end)

AddEventHandler("Keybinds:Client:KeyUp:cancel_action", function()
	if LocalPlayer.state.inGemView then
		exports['pulsar-hud']:GemTableClose()
		--exports.ox_inventory:StaticTooltipClose()
		LocalPlayer.state:set("inGemView", false, true)
	end
end)

local _threading = false
function RunTableThread()
	if _threading then
		return
	end
	_threading = true
	CreateThread(function()
		while _threading do
			if IsControlJustReleased(0, 202) then
				listening = false
				FreezeEntityPosition(LocalPlayer.state.ped, false)
				DoScreenFadeOut(1000)
				Wait(1000)
				CleanupTable()
				DoScreenFadeIn(1000)
				return
			end
			local curHeading = GetEntityHeading(_gemObj)
			if curHeading >= 360 then
				curHeading = 0.0
			end
			SetEntityHeading(_gemObj, curHeading + 0.1)
			DisablePlayerFiring(LocalPlayer.state.ped, true)
			Wait(0)
		end
	end)
end

function ActivateTable(tableId, color, quality, item)
	local prop = `h4_prop_h4_diamond_01a`
	Stream.RequestModel(prop)

	LocalPlayer.state:set("inGemTable", true, true)

	if _gemObj ~= 0 then
		DeleteEntity(_gemObj)
	end

	local obj = -1
	local loopcount = 0
	while loopcount < 5 do
		obj = GetClosestObjectOfType(GetEntityCoords(LocalPlayer.state.ped), 5.0, prop, 0)
		loopcount = loopcount + 1
		DeleteEntity(obj)
	end
	DoScreenFadeOut(1000)
	FreezeEntityPosition(LocalPlayer.state.ped, true)
	Wait(1000)
	local dirtLevel = (15 - math.floor(quality / 6.66)) + 0.0

	exports['pulsar-hud']:GemTableOpen(quality)
	--exports.ox_inventory:StaticTooltipOpen(item)

	_gemObj = CreateObject(prop, _tableConfig[tableId].createCoords, 0, 0)
	FreezeEntityPosition(_gemObj, true)
	SetEntityCollision(_gemObj, false, false)
	SetVehicleDirtLevel(_gemObj, dirtLevel)
	SetVehicleColours(_gemObj, color, 0)
	SetVehicleExtraColours(_gemObj, 0, false)
	_tableCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(_tableCam, GetOffsetFromEntityInWorldCoords(_gemObj, -0.55, 0.10, 0.45))

	SetCamRot(_tableCam, -20.0, 0.0, _tableConfig[tableId].createCoords[4] + 90.0, 2)
	SetCamFov(_tableCam, 50.0)
	RenderScriptCams(true, false, 0, 1, 0)
	Wait(200)
	DoScreenFadeIn(1000)
	RunTableThread()
end

function CleanupTable()
	RenderScriptCams(false, false, 0, 1, 0)
	DeleteEntity(_gemObj)
	exports['pulsar-hud']:GemTableClose()
	--exports.ox_inventory:StaticTooltipClose()
	if LocalPlayer.state.inGemTable then
		LocalPlayer.state:set("inGemTable", false, true)
	end

	_tableCam = false
	_gemObj = 0
	_threading = false
end
