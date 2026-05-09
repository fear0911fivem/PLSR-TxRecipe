_aptData = {
	{
		name = "Elkridge Hotel",
		invEntity = 13,
		coords = vector3(285.77, -937.08, 29.32),
		heading = 153.319,
		length = 3.0,
		width = 5.0,
		options = {
			heading = 314,
			--debugPoly=true,
			minZ = 28.32,
			maxZ = 32.32,
		},
		interior = {
			wakeup = {
				x = 154.297,
				y = -1005.266,
				z = -99.976,
				h = 179.907,
			},
			spawn = {
				x = 151.556,
				y = -1007.567,
				z = -98.000,
				h = 353.366,
			},
			locations = {
				exit = {
					coords = vector3(151.3, -1007.99, -99.0),
					length = 1.4,
					width = 1.8,
					options = {
						heading = 0,
						--debugPoly=true,
						minZ = -101.6,
						maxZ = -97.6
					},
				},
				wardrobe = {
					coords = vector3(150.47, -1001.45, -99.0),
					length = 2.0,
					width = 2.0,
					options = {
						heading = 0,
						--debugPoly=true,
						minZ = -101.6,
						maxZ = -97.6
					},
				},
				stash = {
					coords = vector3(150.69, -1004.24, -99.0),
					length = 3.0,
					width = 1.0,
					options = {
						heading = 0,
						--debugPoly=true,
						minZ = -101.6,
						maxZ = -97.6
					},
				},
				logout = {
					coords = vector3(154.31, -1004.52, -99.0),
					length = 2.0,
					width = 2.4,
					options = {
						heading = 0,
						--debugPoly=true,
						minZ = -102.8,
						maxZ = -98.8
					},
				},
			},
		},
	},
}

function Startup()
	local aptIds = {}

	for k, v in ipairs(_aptData) do
		v.id = k
		GlobalState[string.format("Apartment:%s", k)] = v
		table.insert(aptIds, k)


		exports.ox_inventory:RegisterStash(
			string.format("apartment_%s", k),
			string.format("%s Stash", v.name),
			50,
			100000,
			true
		)
	end

	GlobalState["Apartments"] = aptIds
end
