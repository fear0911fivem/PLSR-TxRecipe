initLoaded = false
ELEVATOR_STATE = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		CreateElevators()
		Wait(1000)
		InitElevators()
	end
end)

function InitElevators()
	if initLoaded then
		return
	end
	initLoaded = true
	ELEVATOR_STATE = {}
	exports["pulsar-core"]:ServerCallback("Elevators:Fetch", {}, function(fetchedElevators)
		for k, v in ipairs(_elevatorConfig) do
			for k2, v2 in pairs(v.floors) do
				v2.locked = fetchedElevators[k].floors[k2].locked
			end
			ELEVATOR_STATE[k] = v
		end

		CreateElevators()
	end)
end

function CreateElevators()
	if ELEVATOR_STATE then
		for k, v in pairs(ELEVATOR_STATE) do
			if v.floors then
				for floorId, floorData in pairs(v.floors) do
					if floorData.zone then
						if #floorData.zone > 0 then
							for j, b in ipairs(floorData.zone) do
								CreateElevatorFloorTarget(b, k, floorId, j)
							end
						else
							CreateElevatorFloorTarget(floorData.zone, k, floorId, 1)
						end
					end
				end
			end
		end
	end
end

function CreateElevatorFloorTarget(zoneData, elevatorId, floorId, zoneId)
	exports.ox_target:addBoxZone({
		id = "elevators_" .. elevatorId .. "_level_" .. floorId .. "_" .. zoneId,
		coords = zoneData.center,
		size = vector3(zoneData.length, zoneData.width, 2.0),
		rotation = zoneData.heading,
		debug = false,
		minZ = zoneData.minZ,
		maxZ = zoneData.maxZ,
		options = {
			{
				icon = "elevator",
				label = "Use Elevator",
				onSelect = function()
					TriggerEvent("Elevators:Client:OpenElevator", {
						elevator = elevatorId,
						floor = floorId,
					})
				end,
				distance = 3.0,
				canInteract = function()
					return (
						(not LocalPlayer.state.Character:GetData("ICU")
							or LocalPlayer.state.Character:GetData("ICU").Released)
						and not LocalPlayer.state.isCuffed
					)
				end,
			},
		}
	})
end

RegisterNetEvent("Elevators:Client:UpdateElevatorState", function(elevator, floor, state)
	if ELEVATOR_STATE[elevator] and ELEVATOR_STATE[elevator].floors and ELEVATOR_STATE[elevator].floors[floor] then
		ELEVATOR_STATE[elevator].floors[floor].locked = state
	end
end)
