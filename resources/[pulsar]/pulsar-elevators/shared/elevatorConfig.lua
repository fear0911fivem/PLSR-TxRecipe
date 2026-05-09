_elevatorConfig = {}

function addElevatorsToConfig(elevators)
	for _, elevator in ipairs(elevators) do
		table.insert(_elevatorConfig, elevator)
	end
end
