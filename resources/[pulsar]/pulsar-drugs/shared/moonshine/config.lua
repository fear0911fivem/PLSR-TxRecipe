-- Development Mode Configuration
-- Dev mode is automatically enabled when sv_environment is set to "DEV"
-- You can also manually enable it by setting _devMode = true
_devMode = false -- Set to true to force dev mode (overrides environment check)
_devCookTime = 30 -- Cook time in seconds when dev mode is enabled (default: 30 seconds)
_devAgingTime = 30 -- Barrel aging time in seconds when dev mode is enabled (default: 30 seconds)

-- Still Tiers Configuration
_stillTiers = {
    [1] = {
        label = "Basic Still",
        checks = 10,
        cookTime = 30,
        efficiency = 0.75, -- Quality multiplier
        maxHeat = 50, -- Heat generation per brew
        upgradeCost = 0, -- Cost to upgrade to next tier
    },
    [2] = {
        label = "Improved Still",
        checks = 15,
        cookTime = 20,
        efficiency = 0.90,
        maxHeat = 40,
        upgradeCost = 50000,
    },
    [3] = {
        label = "Professional Still",
        checks = 20,
        cookTime = 15,
        efficiency = 1.0,
        maxHeat = 30,
        upgradeCost = 150000,
    },
    [4] = {
        label = "Master Still",
        checks = 25,
        cookTime = 10,
        efficiency = 1.15,
        maxHeat = 20,
        upgradeCost = 0, -- Max tier
    }
}

-- Moonshine Recipes
_moonshineRecipes = {
    {
        id = "classic",
        label = "Classic Moonshine",
        description = "Traditional corn-based moonshine",
        ingredients = {
            { item = "corn", amount = 5 },
            { item = "sugar", amount = 3 },
            { item = "water", amount = 2 },
        },
        baseQuality = 50,
        difficulty = 1,
        agingBonus = 1.2, -- Quality multiplier from aging
        minAgingTime = 60 * 60 * 24, -- 1 day minimum
        optimalAgingTime = 60 * 60 * 24 * 3, -- 3 days optimal
        effects = {
            drunkAmount = 10, -- Base drunk level
            healAmount = 5, -- Health per second
            healDuration = 30, -- Seconds of healing
            stressRelief = 5, -- Stress reduction
        },
    },
    {
        id = "apple",
        label = "Apple Pie Moonshine",
        description = "Sweet apple-flavored moonshine",
        ingredients = {
            { item = "corn", amount = 4 },
            { item = "apple", amount = 6 },
            { item = "sugar", amount = 4 },
            { item = "water", amount = 2 },
        },
        baseQuality = 60,
        difficulty = 2,
        agingBonus = 1.3,
        minAgingTime = 60 * 60 * 24 * 2,
        optimalAgingTime = 60 * 60 * 24 * 4,
        effects = {
            drunkAmount = 12, -- Slightly more drunk
            healAmount = 6, -- Better healing
            healDuration = 35, -- Longer healing
            stressRelief = 8, -- More stress relief
        },
    },
    {
        id = "peach",
        label = "Peach Moonshine",
        description = "Premium peach-infused moonshine",
        ingredients = {
            { item = "corn", amount = 5 },
            { item = "peach", amount = 8 },
            { item = "sugar", amount = 5 },
            { item = "water", amount = 2 },
        },
        baseQuality = 70,
        difficulty = 3,
        agingBonus = 1.4,
        minAgingTime = 60 * 60 * 24 * 3,
        optimalAgingTime = 60 * 60 * 24 * 5,
        effects = {
            drunkAmount = 15, -- More drunk
            healAmount = 7, -- Better healing
            healDuration = 40, -- Longer healing
            stressRelief = 10, -- Good stress relief
        },
    },
    {
        id = "cherry",
        label = "Cherry Bomb Moonshine",
        description = "High-quality cherry moonshine",
        ingredients = {
            { item = "corn", amount = 6 },
            { item = "cherry", amount = 10 },
            { item = "sugar", amount = 6 },
            { item = "water", amount = 3 },
        },
        baseQuality = 80,
        difficulty = 4,
        agingBonus = 1.5,
        minAgingTime = 60 * 60 * 24 * 4,
        optimalAgingTime = 60 * 60 * 24 * 7,
        effects = {
            drunkAmount = 18, -- Strong drunk effect
            healAmount = 8, -- Great healing
            healDuration = 45, -- Long healing
            stressRelief = 15, -- Excellent stress relief
        },
    },
    {
        id = "premium",
        label = "Premium Reserve",
        description = "Ultra-premium moonshine for connoisseurs",
        ingredients = {
            { item = "corn", amount = 8 },
            { item = "honey", amount = 4 },
            { item = "sugar", amount = 8 },
            { item = "water", amount = 4 },
            { item = "yeast", amount = 2 },
        },
        baseQuality = 90,
        difficulty = 5,
        agingBonus = 1.6,
        minAgingTime = 60 * 60 * 24 * 7,
        optimalAgingTime = 60 * 60 * 24 * 14,
        effects = {
            drunkAmount = 20, -- Maximum drunk effect
            healAmount = 10, -- Maximum healing
            healDuration = 50, -- Longest healing
            stressRelief = 20, -- Maximum stress relief
        },
    }
}

-- Quality Calculation Factors
_qualityFactors = {
    skillMultiplier = 0.3, -- 30% from skill level
    ingredientQuality = 0.2, -- 20% from ingredient quality
    temperature = 0.15, -- 15% from temperature
    skillChecks = 0.25, -- 25% from skill check success rate
    stillTier = 0.10, -- 10% from still tier
}

-- Police Detection System
_policeDetection = {
    heatPerBrew = 5, -- Heat generated per brew
    heatDecayRate = 1, -- Heat lost per minute
    maxHeat = 100,
    alertThreshold = 50, -- Heat level to trigger police alert
    raidThreshold = 80, -- Heat level to trigger raid chance
    raidChance = 0.15, -- 15% chance per check when above threshold
    detectionRadius = 100.0, -- Meters
    alertCooldown = 60 * 5, -- 5 minutes between alerts
}

-- Temperature Effects (affects quality)
_temperatureEffects = {
    optimal = { min = 15, max = 25 }, -- Celsius, optimal range
    good = { min = 10, max = 30 }, -- Good range
    poor = { min = 5, max = 35 }, -- Poor range
    -- Outside poor range = very bad quality
}

-- Weather Effects
_weatherEffects = {
    clear = 1.0, -- No modifier
    clouds = 0.95,
    foggy = 0.90,
    rain = 0.85,
    thunder = 0.80,
    snow = 0.75,
}

-- Reputation System
_reputationSystem = {
    repPerBrew = 2, -- Reputation gained per successful brew
    repPerDelivery = 10, -- Reputation gained per delivery
    repLossOnRaid = 20, -- Reputation lost if raided
    unlockRecipes = {
        classic = 0,
        apple = 500,
        peach = 1500,
        cherry = 3000,
        premium = 5000,
    }
}

-- Delivery System
_deliverySystem = {
    minRep = 100, -- Minimum reputation to unlock deliveries
    basePayPerJar = 50, -- Base payment per jar (realistic economy)
    payPerQualityPerJar = 1, -- Additional pay per quality point per jar
    minJarsPerStop = 1, -- Minimum jars to sell per stop
    maxJarsPerStop = 3, -- Maximum jars to sell per stop
    minStops = 3, -- Minimum number of stops per delivery
    maxStops = 6, -- Maximum number of stops per delivery
    deliveryTimeLimit = 60 * 20, -- 20 minutes to complete entire delivery route
    policeChance = 0.10, -- 10% chance of police encounter
    bulkSaleRep = 500, -- Reputation required for bulk sale option
    bulkSaleMultiplier = 0.60, -- Only pay 60% of normal price (lazy way)
    travelRep = 2000, -- Reputation required for travel option
    travelBasePayPerJar = 150, -- Base payment per jar for Cayo Perico delivery (higher than drop-off)
    travelPayPerQualityPerJar = 3, -- Additional pay per quality point per jar for travel
    travelRepPerStop = 8, -- Reputation per stop (random between travelRepPerStop-10)
    travelRepPerStopMax = 10, -- Max reputation per stop
    travelMinStops = 4, -- Minimum number of stops on Cayo Perico
    travelMaxStops = 7, -- Maximum number of stops on Cayo Perico
    travelTime = 60 * 30, -- 30 minutes to complete travel delivery (longer due to island travel)
}

-- Aging System
_agingSystem = {
    baseAgingTime = 60 * 60 * 24 * 2, -- 2 days base
    qualityIncreasePerDay = 2, -- Quality points per day of aging
    maxAgingBonus = 30, -- Maximum quality bonus from aging
    optimalTemp = 12, -- Optimal aging temperature (Celsius)
}

-- Still Upgrade System
_upgradeSystem = {
    upgradeTime = 60 * 5, -- 5 minutes to upgrade
    upgradeCostMultiplier = 1.5, -- Cost multiplier per tier
    requireRep = {
        [2] = 0,
        [3] = 1000,
        [4] = 3000,
    }
}

-- Delivery Drop-Off Locations (Rough areas: bridges, hobo camps, some front doors)
_deliveryLocations = {
    -- Under bridges / rough areas
    vector3(-1087.0, -1638.0, 4.4), -- Under bridge near beach
    vector3(-1150.0, -1420.0, 4.9), -- Under bridge
    vector3(-200.0, -1600.0, 31.0), -- Under highway bridge
    vector3(100.0, -2000.0, 5.0), -- Under bridge near airport
    vector3(500.0, -1800.0, 5.0), -- Under bridge
    vector3(1200.0, -1400.0, 35.0), -- Under bridge near industrial
    -- Hobo camps / alleyways
    vector3(-1153.0, -1425.0, 4.9), -- Beach hobo camp
    vector3(-47.0, -585.0, 37.9), -- Downtown alley
    vector3(-128.0, -641.0, 168.8), -- Downtown alley
    vector3(-187.0, -590.0, 167.0), -- Downtown alley
    vector3(-255.0, -623.0, 33.0), -- Downtown alley
    vector3(-340.0, -874.0, 31.0), -- Back alley
    vector3(-379.0, -829.0, 31.6), -- Back alley
    vector3(-442.0, -795.0, 30.7), -- Back alley
    vector3(-468.0, -677.0, 32.7), -- Back alley
    vector3(-598.0, -777.0, 25.1), -- Industrial area
    vector3(-641.0, -801.0, 25.2), -- Industrial area
    vector3(-680.0, -845.0, 23.0), -- Industrial area
    vector3(-717.0, -879.0, 23.0), -- Industrial area
    -- Some front doors (less common)
    vector3(-1150.0, -1520.0, 4.3), -- Beach house
    vector3(-1108.0, -1690.0, 4.3), -- Beach house
    vector3(-1067.0, -1655.0, 4.4), -- Beach house
    vector3(-1010.0, -1638.0, 4.9), -- Beach house
    vector3(-974.0, -1108.0, 2.1), -- Beach house
    vector3(-907.0, -979.0, 2.1), -- Beach house
    vector3(-890.0, -853.0, 19.2), -- Beach house
    vector3(-819.0, -696.0, 27.9), -- Beach house
    vector3(-595.0, -1048.0, 22.3), -- Beach house
    -- Sandy Shores rough areas
    vector3(1961.0, 3740.0, 32.3), -- Sandy Shores
    vector3(1392.0, 3604.0, 34.9), -- Sandy Shores
    vector3(1193.0, 2703.0, 38.2), -- Sandy Shores
    -- Paleto Bay rough areas
    vector3(-448.0, 6017.0, 31.3), -- Paleto Bay
    vector3(-247.0, 6331.0, 32.4), -- Paleto Bay
    vector3(-175.0, 6428.0, 31.1), -- Paleto Bay
}

-- Cayo Perico Delivery Locations (island coordinates)
_cayoPericoLocations = {
    -- Main compound area
    vector3(5000.0, -5750.0, 15.0), -- Near compound entrance
    vector3(5020.0, -5700.0, 15.0), -- Compound area
    vector3(5050.0, -5650.0, 15.0), -- Compound area
    vector3(5100.0, -5600.0, 15.0), -- Compound area
    -- Beach areas
    vector3(4900.0, -5800.0, 2.0), -- Beach area
    vector3(4850.0, -5750.0, 2.0), -- Beach area
    vector3(4800.0, -5700.0, 2.0), -- Beach area
    vector3(4750.0, -5650.0, 2.0), -- Beach area
    -- Airstrip area
    vector3(4500.0, -4550.0, 3.0), -- Airstrip
    vector3(4550.0, -4500.0, 3.0), -- Airstrip area
    vector3(4600.0, -4450.0, 3.0), -- Airstrip area
    -- North dock area
    vector3(5120.0, -4600.0, 2.0), -- North dock
    vector3(5150.0, -4550.0, 2.0), -- North dock area
    -- South dock area
    vector3(5090.0, -4680.0, 2.0), -- South dock
    vector3(5060.0, -4720.0, 2.0), -- South dock area
    -- Main dock area
    vector3(4840.0, -5174.0, 2.0), -- Main dock (spawn point)
    vector3(4800.0, -5200.0, 2.0), -- Main dock area
    vector3(4880.0, -5150.0, 2.0), -- Main dock area
    -- Village area
    vector3(5000.0, -5100.0, 2.0), -- Village
    vector3(4950.0, -5050.0, 2.0), -- Village area
    vector3(4900.0, -5000.0, 2.0), -- Village area
    -- Radio tower area
    vector3(5300.0, -5400.0, 40.0), -- Radio tower
    vector3(5250.0, -5350.0, 35.0), -- Radio tower area
    -- El Rubio's mansion area
    vector3(5070.0, -5750.0, 20.0), -- Mansion area
    vector3(5120.0, -5700.0, 20.0), -- Mansion area
}