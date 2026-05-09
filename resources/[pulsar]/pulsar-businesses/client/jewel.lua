local _tableCam = nil
local _gemObj = 0

local _appraisalTables = {
	{
		coords = vector3(-697.919, -904.744, 19.373),
		length = 0.8,
		width = 2.7,
		options = {
			heading = 270,
			--debugPoly=true,
			minZ = 18.373,
			maxZ = 20.373,
		},
	},
	{
		coords = vector3(-707.573, -893.903, 19.373),
		length = 1.3,
		width = 3.4,
		options = {
			heading = 359.0,
			--debugPoly=true,
			minZ = 18.373,
			maxZ = 20.373,
		},
	},
}

local _tableConfig = {
	{
		createCoords = vector4(-697.919, -904.744, 19.373, 270.0),
	},
	{
		createCoords = vector4(-707.573, -893.903, 19.373, 359.0),
	},
}

local _sellers = {
	{
		coords = vector3(-779.593, -180.531, 36.284),
		heading = 122.857,
		model = `a_m_y_smartcaspat_01`,
	},
}

AddEventHandler("Businesses:Client:Startup", function()
	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("JEWELSeller%s", k), v.model, v.coords, v.heading, 25.0, {
			{
				icon = "fas fa-ring",
				text = "Sell Gems",
				event = "JEWEL:Client:Sell",
				jobPerms = {
					{
						job = "jewel",
						jobPerms = "JOB_SELL_GEMS",
					},
				},
			},
		}, "sack-dollar")
	end

	for k, v in ipairs(_appraisalTables) do
		exports.ox_target:addBoxZone({
			id = "jewel-table-" .. k,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-gem",
					label = "View Gem Table",
					event = "Businesses:Client:JEWEL:OpenTable",
					groups = { "jewel" },
					reqDuty = true,
					canInteract = function()
						return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_GEM_TABLE"]
					end,
				},
				{
					icon = "fas fa-gem",
					label = "Create Jewelry",
					event = "Businesses:Client:JEWEL:OpenJewelryCrafting",
					groups = { "jewel" },
					reqDuty = true,
					canInteract = function()
						return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_JEWELRY_CRAFTING"]
					end,
				},
			}
		})
	end
end)

RegisterNetEvent("UI:Client:Reset", function()
	CleanupTable()
end)

AddEventHandler("JEWEL:Client:Sell", function()
	exports["pulsar-core"]:ServerCallback("Businesses:JEWEL:Sell", {})
end)

AddEventHandler("Businesses:Client:JEWEL:OpenTable", function(data)
	exports.ox_inventory:DumbfuckOpen({
		invType = 149,
		owner = data.id,
	})
end)

AddEventHandler("Businesses:Client:JEWEL:OpenJewelryCrafting", function(data)
	exports.ox_inventory:CraftingBenchesOpen("jewel-jewelry")
end)

RegisterNetEvent("Businesses:Client:JEWEL:ViewGem", function(tableId, gemProps, quality, item)
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

	LocalPlayer.state:set("inGemTableJewel", true, true)

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
	LocalPlayer.state:set("inGemTableJewel", false, true)

	_tableCam = false
	_gemObj = 0
	_threading = false
end
