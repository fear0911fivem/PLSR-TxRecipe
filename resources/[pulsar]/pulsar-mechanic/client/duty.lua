--- Creates ox_target box zones for all mechanic shop duty points defined in Config.Shops
---@return nil
function CreateMechanicDutyPoints()
	for k = 1, #Config.Shops do
		local v = Config.Shops[k]
		if v.dutyPoint then
			local menu = {
				{
					icon = "fas fa-clipboard-check",
					label = "Go On Duty",
					onSelect = function()
						TriggerEvent("Mechanic:Client:OnDuty", v.job)
					end,
					groups = { v.job },
					reqOffDuty = true,
				},
				{
					icon = "fas fa-clipboard",
					label = "Go Off Duty",
					onSelect = function()
						TriggerEvent("Mechanic:Client:OffDuty", v.job)
					end,
					groups = { v.job },
					reqDuty = true,
				},
			}

			exports.ox_target:addBoxZone({
				id = "mechanic_duty_" .. k,
				coords = v.dutyPoint.center,
				size = vector3(v.dutyPoint.length, v.dutyPoint.width, 2.0),
				rotation = v.dutyPoint.options.heading or 0,
				debug = false,
				minZ = v.dutyPoint.options.minZ,
				maxZ = v.dutyPoint.options.maxZ,
				options = menu
			})
		end
		if v.dutyPoint2 then
			local menu = {
				{
					icon = "fas fa-clipboard-check",
					label = "Go On Duty",
					event = "Mechanic:Client:OnDuty",
					groups = { v.job },
					reqOffDuty = true,
				},
				{
					icon = "fas fa-clipboard",
					label = "Go Off Duty",
					event = "Mechanic:Client:OffDuty",
					groups = { v.job },
					reqDuty = true,
				},
			}

			exports.ox_target:addBoxZone({
				id = "mechanic_duty2_" .. k,
				coords = v.dutyPoint2.center,
				size = vector3(v.dutyPoint2.length, v.dutyPoint2.width, 2.0),
				rotation = v.dutyPoint2.options.heading or 0,
				debug = false,
				minZ = v.dutyPoint2.options.minZ,
				maxZ = v.dutyPoint2.options.maxZ,
				options = menu
			})
		end
	end
end

local _activeBenchZones = {}

local function addBenchZones(job)
    for i = 1, #Config.CraftingBenches do
        local shop = Config.CraftingBenches[i]
        if shop.job == job then
            for j = 1, #shop.benches do
                local bench   = shop.benches[j]
                local benchId = ('mechanic-bench-%s-%d'):format(shop.job, j)
                local numId   = exports.ox_target:addBoxZone({
                    coords   = bench.coords,
                    size     = vector3(bench.l or 2.0, bench.w or 2.0, 2.0),
                    rotation = bench.heading or 0,
                    minZ     = bench.minZ,
                    maxZ     = bench.maxZ,
                    options  = {{
                        label    = 'Mechanic Workshop',
                        icon     = 'fas fa-toolbox',
                        distance = 2.0,
                        onSelect = function()
                            exports['ox_inventory']:openInventory('crafting', { id = benchId, index = 1 })
                        end,
                    }},
                })
                _activeBenchZones[#_activeBenchZones + 1] = numId
            end
        end
    end
end

local function removeBenchZones()
    for i = 1, #_activeBenchZones do
        exports.ox_target:removeZone(_activeBenchZones[i])
    end
    _activeBenchZones = {}
end

AddStateBagChangeHandler('onDuty', ('player:%s'):format(cache.serverId), function(_, _, value)
    removeBenchZones()
    if value and Config.Jobs[value] then
        addBenchZones(value)
    end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    local duty = LocalPlayer.state.onDuty
    if duty and Config.Jobs[duty] then
        addBenchZones(duty)
    end
end)

AddEventHandler("Mechanic:Client:OnDuty", function(job)
	if not Config.Jobs[job] then
		return
	end

	exports['pulsar-jobs']:DutyOn(job)
end)

AddEventHandler("Mechanic:Client:OffDuty", function(job)
	if not Config.Jobs[job] then
		return
	end

	exports['pulsar-jobs']:DutyOff(job)
end)
