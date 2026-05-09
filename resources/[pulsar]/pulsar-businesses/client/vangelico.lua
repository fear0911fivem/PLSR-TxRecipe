local _tableCam = nil
local _gemObj = 0

local _appraisalTables = {
	{
		coords = vector3(-383.6, 6049.87, 31.51),
		length = 0.85,
		width = 2.4,
		options = {
			heading = 45,
			--debugPoly=true,
			minZ = 30.11,
			maxZ = 32.31,
		},
	},
	{
		coords = vector3(-378.57, 6047.48, 31.51),
		length = 1.5,
		width = 1.0,
		options = {
			heading = 45,
			--debugPoly=true,
			minZ = 28.51,
			maxZ = 32.51,
		},
	},
	{
		coords = vector3(-377.4, 6042.71, 31.51),
		length = 2.6,
		width = 0.6,
		options = {
			heading = 315,
			--debugPoly=true,
			minZ = 30.11,
			maxZ = 32.51,
		},
	},
}

local _tableConfig = {
	{
		createCoords = vector4(-383.6, 6049.87, 31.51, 45.0),
	},
	{
		createCoords = vector4(-378.57, 6047.48, 31.51, 45.0),
	},
	{
		createCoords = vector4(-377.4, 6042.71, 31.51, 315.0),
	},
}

local _sellers = {
	{
		coords = vector3(-1034.341, -432.509, 38.616),
		heading = 128.313,
		model = `a_m_y_smartcaspat_01`,
	},
}

AddEventHandler("Businesses:Client:Startup", function()
	for k, v in ipairs(_sellers) do
		exports['pulsar-pedinteraction']:Add(string.format("VANGELICOSeller%s", k), v.model, v.coords, v.heading, 25.0,
			{
				{
					icon = "ring",
					text = "Sell Gems",
					event = "VANGELICO:Client:Sell",
					jobPerms = {
						{
							job = "vangelico",
							jobPerms = "JOB_SELL_GEMS",
						},
					},
				},
			}, "sack-dollar")
	end

	for k, v in ipairs(_appraisalTables) do
		exports.ox_target:addBoxZone({
			id = "vangelico-table-" .. k,
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
					event = "Businesses:Client:VANGELICO:OpenTable",
					groups = { "vangelico" },
					reqDuty = true,
					canInteract = function()
						return LocalPlayer.state.jobPerms and LocalPlayer.state.jobPerms["JOB_USE_GEM_TABLE"]
					end,
				},
				{
					icon = "gem",
					label = "Create Jewelry",
					event = "Businesses:Client:VANGELICO:OpenJewelryCrafting",
					groups = { "vangelico" },
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

AddEventHandler("VANGELICO:Client:Sell", function()
	exports["pulsar-core"]:ServerCallback("Businesses:VANGELICO:Sell", {})
end)

AddEventHandler("Businesses:Client:VANGELICO:OpenTable", function(data)
	exports.ox_inventory:DumbfuckOpen({
		invType = 196,
		owner = data.id,
	})
end)

AddEventHandler("Businesses:Client:VANGELICO:OpenJewelryCrafting", function(data)
	exports.ox_inventory:CraftingBenchesOpen("vangelico-jewelry")
end)

RegisterNetEvent("Businesses:Client:VANGELICO:ViewGem", function(tableId, gemProps, quality, item)
	LocalPlayer.state:set("inGemViewVangelico", true, true)
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
		LocalPlayer.state:set("inGemViewVangelico", false, true)
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

	LocalPlayer.state:set("inGemTableVangelico", true, true)

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
	if LocalPlayer.state.inGemTableVangelico then
		LocalPlayer.state:set("inGemTableVangelico", false, true)
	end

	_tableCam = false
	_gemObj = 0
	_threading = false
end
