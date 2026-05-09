Materials = {
	[581794674] = { groundType = "normal" },
	[-2041329971] = { groundType = "normal" },
	[-309121453] = { groundType = "normal" },
	[-913351839] = { groundType = "normal" },
	[-1885547121] = { groundType = "normal" },
	[-1915425863] = { groundType = "normal" },
	[-1833527165] = { groundType = "normal" },
	[2128369009] = { groundType = "normal" },
	[-124769592] = { groundType = "normal" },
	[-840216541] = { groundType = "normal" },
	[-461750719] = { groundType = "grass" },
	[930824497] = { groundType = "grass" },
	[1333033863] = { groundType = "grocks" },
	[223086562] = { groundType = "wet" },
	[1109728704] = { groundType = "wet" },
	[-1286696947] = { groundType = "mgrass" },
	[-1942898710] = { groundType = "grocks" },
	[509508168] = { groundType = "sand" },
	[-2073312001] = { groundType = "unk1" },
	[627123000] = { groundType = "unk1" },
	[-1595148316] = { groundType = "unk2" },
	[435688960] = { groundType = "unk3" },
}

Plants = {
	{
		model = GetHashKey("bzzz_plants_weed_green_small"),
		offset = 0.0,
		harvestable = false,
		targeting = {
			{
				icon = "fas fa-magnifying-glass",
				text = "Check",
				event = "Weed:Client:Check",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-hand-scissors",
				text = "Destroy Plant",
				event = "Weed:Client:PDDestroy",
				groups = { "police" },
				reqDuty = true,
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
		},
	},
	{
		model = GetHashKey("bzzz_plants_weed_green_medium"),
		offset = 0.0,
		harvestable = false,
		targeting = {
			{
				icon = "fas fa-magnifying-glass",
				text = "Check",
				event = "Weed:Client:Check",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-hand-scissors",
				text = "Destroy Plant",
				event = "Weed:Client:PDDestroy",
				groups = { "police" },
				reqDuty = true,
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
		},
	},
	{
		model = GetHashKey("bzzz_plants_weed_green_big"),
		offset = 0.0,
		harvestable = false,
		targeting = {
			{
				icon = "fas fa-magnifying-glass",
				text = "Check",
				event = "Weed:Client:Check",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-hand-scissors",
				text = "Destroy Plant",
				event = "Weed:Client:PDDestroy",
				groups = { "police" },
				reqDuty = true,
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
		},
	},
	{
		model = GetHashKey("bzzz_plants_weed_green_bud"),
		offset = 0.0,
		harvestable = false,
		targeting = {
			{
				icon = "fas fa-magnifying-glass",
				text = "Check",
				event = "Weed:Client:Check",
				canInteract = function(entity)
					return GetWeedPlant(entity.entity)
				end,
			},
			{
				icon = "fas fa-sack",
				text = "Harvest",
				event = "Weed:Client:Harvest",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-hand-scissors",
				text = "Destroy Plant",
				event = "Weed:Client:PDDestroy",
				groups = { "police" },
				reqDuty = true,
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
		},
	},
	{
		model = GetHashKey("bzzz_plants_weed_green_bud_big"),
		offset = 0.0,
		harvestable = true,
		targeting = {
			{
				icon = "fas fa-magnifying-glass",
				text = "Check",
				event = "Weed:Client:Check",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-sack",
				text = "Harvest",
				event = "Weed:Client:Harvest",
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
			{
				icon = "fas fa-hand-scissors",
				text = "Destroy Plant",
				event = "Weed:Client:PDDestroy",
				groups = { "police" },
				reqDuty = true,
				canInteract = function(entity)
					return GetWeedPlant(entity)
				end,
			},
		},
	},
	-- {
	-- 	model = GetHashKey("bzzz_plants_weed_green_big"),
	-- 	offset = -0.4,
	-- 	harvestable = false,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_01_small_01c"),
	-- 	offset = -0.4,
	-- 	harvestable = false,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_01_small_01b"),
	-- 	offset = -0.4,
	-- 	harvestable = false,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_01_small_01a"),
	-- 	offset = -0.4,
	-- 	harvestable = false,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_med_01a"),
	-- 	offset = -0.4,
	-- 	harvestable = false,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_med_01b"),
	-- 	offset = -0.4,
	-- 	harvestable = true,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-sack",
	-- 			text = "Harvest",
	-- 			event = "Weed:Client:Harvest",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_lrg_01a"),
	-- 	offset = -0.4,
	-- 	harvestable = true,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-sack",
	-- 			text = "Harvest",
	-- 			event = "Weed:Client:Harvest",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("bkr_prop_weed_lrg_01b"),
	-- 	offset = -0.4,
	-- 	harvestable = true,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-sack",
	-- 			text = "Harvest",
	-- 			event = "Weed:Client:Harvest",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Destroy Plant",
	-- 			event = "Weed:Client:PDDestroy",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("prop_weed_02"),
	-- 	offset = -0.4,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Confiscate",
	-- 			event = "Weed:Client:Confiscate",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	-- {
	-- 	model = GetHashKey("prop_weed_01"),
	-- 	offset = -0.4,
	-- 	targeting = {
	-- 		{
	-- 			icon = "fas fa-magnifying-glass",
	-- 			text = "Check",
	-- 			event = "Weed:Client:Check",
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 		{
	-- 			icon = "fas fa-hand-scissors",
	-- 			text = "Confiscate",
	-- 			event = "Weed:Client:Confiscate",
	-- 			groups = { "police" },
	-- 			reqDuty = true,
	-- 			canInteract = function(entity)
	-- 				return GetWeedPlant(entity)
	-- 			end,
	-- 		},
	-- 	},
	-- },
}
