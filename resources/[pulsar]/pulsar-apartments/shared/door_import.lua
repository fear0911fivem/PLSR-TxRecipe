ApartmentDoorDefinitions = ApartmentDoorDefinitions or {}

function addDoorsListToConfig(newDoors)
	for _, door in ipairs(newDoors or {}) do
		table.insert(ApartmentDoorDefinitions, door)
	end
end
