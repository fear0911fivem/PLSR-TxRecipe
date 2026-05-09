function CreateMechanicDutyPoints()
	for k, v in ipairs(_mechanicShops) do
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

AddEventHandler("Mechanic:Client:OnDuty", function(job)
	if not _mechanicJobs[job] then
		return
	end

	exports['pulsar-jobs']:DutyOn(job)
end)

AddEventHandler("Mechanic:Client:OffDuty", function(job)
	if not _mechanicJobs[job] then
		return
	end

	exports['pulsar-jobs']:DutyOff(job)
end)
