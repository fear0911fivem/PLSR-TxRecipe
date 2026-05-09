GENERATED_LOCAL_VINS = {}
GENERATED_TEMP_VINS = {} -- Owned VINS generate this session
GENERATED_TEMP_PLATES = {}

local plateVINCharSet = {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"J",
	"K",
	"L",
	"M",
	"N",
	"P",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
}

function RandomCharOrNumber(amount)
	if amount == nil then
		amount = 1
	end
	local value = ""
	for i = 1, amount do
		if math.random(0, 6) <= 4 then -- More chance of letter
			value = value .. plateVINCharSet[math.random(1, #plateVINCharSet)]
		else
			value = value .. tostring(math.random(0, 9))
		end
	end
	return value
end

function GeneratePlate()
	return RandomCharOrNumber(8)
end

function GenerateVIN(isOwned)
	local vin = RandomCharOrNumber(10)
		.. (isOwned and "A" or "B")
		.. RandomCharOrNumber(1)
		.. tostring(math.random(10000, 99999))
	return vin
end

exports("VINGenerateLocal", function()
	local generated = GenerateVIN(false)
	while GENERATED_LOCAL_VINS[generated] do
		generated = GenerateVIN(false)
	end
	GENERATED_LOCAL_VINS[generated] = true
	return generated
end)

exports("VINGenerateOwned", function()
	local generated = GenerateVIN(true)
	while IsVINOwned(generated) do
		generated = GenerateVIN(true)
	end

	GENERATED_TEMP_VINS[generated] = true

	return generated
end)

exports("PlateGenerate", function(isTemp)
	local plate = GeneratePlate()
	while IsPlateOwned(plate) and GENERATED_TEMP_PLATES[plate] do
		plate = GeneratePlate()
	end
	if isTemp then
		GENERATED_TEMP_PLATES[plate] = true
	end
	return plate
end)

function IsVINOwned(vin)
	if GENERATED_TEMP_VINS[vin] then
		return true
	end

	local result = MySQL.single.await(
		"SELECT VIN FROM vehicles WHERE VIN = ?",
		{ vin }
	)

	return result ~= nil
end

function IsPlateOwned(plate)
	local result = MySQL.single.await(
		"SELECT RegisteredPlate FROM vehicles WHERE RegisteredPlate = ? OR JSON_EXTRACT(Properties, '$.FakePlate') = ?",
		{ plate, plate }
	)

	return result ~= nil
end
