Config = {}

-- Vehicle classes that require high-grade repair parts
Config.HighPerformanceClasses = {
    ['S']  = true,
    ['S+'] = true,
    ['X']  = true,
}

-- Maps repair part item names to vehicle component data (used when the item is installed on a vehicle)
Config.ItemsToParts = {
    ['repair_part_electronics']    = { part = 'Electronics',   amount = 25.0,  time = 5,  regular = true,  hperformance = true  },
    ['repair_part_axle']           = { part = 'Axle',          amount = 50.0,  time = 10, regular = true,  hperformance = true  },
    ['repair_part_injectors']      = { part = 'FuelInjectors', amount = 25.0,  time = 5,  regular = true,  hperformance = false },
    ['repair_part_clutch']         = { part = 'Clutch',        amount = 25.0,  time = 5,  regular = true,  hperformance = false },
    ['repair_part_brakes']         = { part = 'Brakes',        amount = 25.0,  time = 5,  regular = true,  hperformance = false },
    ['repair_part_transmission']   = { part = 'Transmission',  amount = 50.0,  time = 10, regular = true,  hperformance = false },
    ['repair_part_rad']            = { part = 'Radiator',      amount = 100.0, time = 20, regular = true,  hperformance = false },

    ['repair_part_injectors_hg']   = { part = 'FuelInjectors', amount = 25.0,  time = 5,  regular = false, hperformance = true },
    ['repair_part_clutch_hg']      = { part = 'Clutch',        amount = 25.0,  time = 5,  regular = false, hperformance = true },
    ['repair_part_brakes_hg']      = { part = 'Brakes',        amount = 25.0,  time = 5,  regular = false, hperformance = true },
    ['repair_part_transmission_hg']= { part = 'Transmission',  amount = 50.0,  time = 10, regular = false, hperformance = true },
    ['repair_part_rad_hg']         = { part = 'Radiator',      amount = 100.0, time = 20, regular = false, hperformance = true },
}

-- Maps upgrade item names to vehicle mod data (used when the item is installed on a vehicle)
Config.ItemsToUpgrades = {
    ['upgrade_turbo'] = { part = 'Turbo', time = 20, mod = 'turbo', modType = 18, toggleMod = true },
}

local upgradePrefixes = {
    upgrade_engine       = { modType = 11, maxLevel = 4, mod = 'engine',       part = 'Engine',       installTime = 5, increasePerLevel = 5 },
    upgrade_transmission = { modType = 13, maxLevel = 4, mod = 'transmission', part = 'Transmission', installTime = 5, increasePerLevel = 5 },
    upgrade_brakes       = { modType = 12, maxLevel = 4, mod = 'brakes',       part = 'Brakes',       installTime = 5, increasePerLevel = 5 },
    upgrade_suspension   = { modType = 15, maxLevel = 4, mod = 'suspension',   part = 'Suspension',   installTime = 5, increasePerLevel = 5 },
}

for prefix, data in pairs(upgradePrefixes) do
    for i = 1, data.maxLevel do
        Config.ItemsToUpgrades[prefix .. i] = {
            part     = data.part,
            time     = math.floor(data.installTime + (data.increasePerLevel * i)),
            mod      = data.mod,
            modIndex = i - 1,
            modType  = data.modType,
        }
    end
end

-- Mechanic job names (used for duty and zone access checks)
Config.Jobs = {
    tirenutz      = true,
    hayes         = true,
    atomic        = true,
    tuna          = true,
    harmony       = true,
    redline       = true,
    blackline     = true,
    autoexotics   = true,
    ottos         = true,
    bennys        = true,
    paleto_tuners = true,
    dreamworks    = true,
}

-- Shop zones and duty-point locations
Config.Shops = {
    {
        job  = 'tirenutz',
        zone = {
            type   = 'box',
            center = vector3(-69.2, -1334.98, 29.26),
            length = 26.0, width = 24.8,
            options = { heading = 0, minZ = 28.26, maxZ = 35.66 },
        },
        dutyPoint = {
            center = vector3(-67.25, -1330.1, 29.27),
            length = 2.0, width = 2.0,
            options = { heading = 0, minZ = 28.27, maxZ = 30.07 },
        },
    },
    {
        job  = 'redline',
        zone = {
            type   = 'box',
            center = vector3(-568.77, -925.64, 23.89),
            length = 30.0, width = 38.6,
            options = { heading = 0, minZ = 22.89, maxZ = 32.09 },
        },
        dutyPoint = {
            center = vector3(-589.78, -930.82, 23.89),
            length = 3.6, width = 0.8,
            options = { heading = 0, minZ = 23.49, maxZ = 24.29 },
        },
    },
    {
        job  = 'hayes',
        zone = {
            type   = 'box',
            center = vector3(-1420.57, -443.49, 35.91),
            length = 21.4, width = 24.0,
            options = { heading = 32, minZ = 34.31, maxZ = 46.71 },
        },
        dutyPoint = {
            center = vector3(-1430.41, -454.76, 35.91),
            length = 1.0, width = 1.0,
            options = { heading = 32, minZ = 34.91, maxZ = 36.91 },
        },
    },
    {
        job  = 'atomic',
        zone = {
            type   = 'box',
            center = vector3(478.98, -1889.98, 26.09),
            length = 30.0, width = 30.0,
            options = { heading = 31, minZ = 25.09, maxZ = 34.29 },
        },
        dutyPoint = {
            center = vector3(470.73, -1897.04, 26.09),
            length = 2.0, width = 2.0,
            options = { heading = 25, minZ = 25.09, maxZ = 27.29 },
        },
    },
    {
        job  = 'harmony',
        zone = {
            type   = 'box',
            center = vector3(1179.71, 2640.69, 37.75),
            length = 35.2, width = 40.4,
            options = { heading = 0, minZ = 35.55, maxZ = 45.55 },
        },
        dutyPoint = {
            center = vector3(1186.78, 2637.96, 38.4),
            length = 0.8, width = 2.0,
            options = { heading = 0, minZ = 37.4, maxZ = 39.4 },
        },
    },
    {
        job  = 'tuna',
        zone = {
            type   = 'box',
            center = vector3(135.79, -3037.25, 7.04),
            length = 26.6, width = 29.8,
            options = { heading = 0, minZ = 6.04, maxZ = 10.04 },
        },
        dutyPoint = {
            center = vector3(145.3, -3012.75, 7.0),
            length = 0.45, width = 0.35,
            options = { heading = 0, minZ = 6.8, maxZ = 7.2 },
        },
    },
    {
        job  = 'blackline',
        zone = {
            type   = 'box',
            center = vector3(993.42, -1492.83, 31.5),
            length = 29.2, width = 20.6,
            options = { heading = 270, minZ = 29.5, maxZ = 34.7 },
        },
        dutyPoint = {
            center = vector3(1001.39, -1502.34, 31.5),
            length = 1.0, width = 1.0,
            options = { heading = 0, minZ = 30.5, maxZ = 32.9 },
        },
    },
    {
        job  = 'autoexotics',
        zone = {
            type   = 'poly',
            points = {
                vector2(526.17, -148.27), vector2(556.03, -148.14),
                vector2(556.34, -165.00), vector2(562.15, -164.80),
                vector2(593.48, -202.53), vector2(593.00, -208.16),
                vector2(577.96, -242.32), vector2(568.55, -238.03),
                vector2(543.08, -291.42), vector2(520.26, -280.81),
                vector2(537.29, -244.96), vector2(538.86, -220.53),
                vector2(538.40, -193.54), vector2(530.63, -193.41),
                vector2(524.67, -171.61), vector2(523.81, -162.12),
            },
            options = { minZ = 48.06, maxZ = 70.98 },
        },
        dutyPoint = {
            center = vector3(543.86, -199.82, 54.51),
            length = 0.8, width = 0.8,
            options = { heading = 0, minZ = 53.91, maxZ = 55.11 },
        },
    },
    {
        job  = 'ottos',
        zone = {
            type   = 'box',
            center = vector3(933.22, -963.35, 39.8),
            length = 58.4, width = 61.8,
            options = { heading = 0, minZ = 34.07, maxZ = 48.67 },
        },
        dutyPoint = {
            center = vector3(952.12, -968.46, 39.51),
            length = 0.8, width = 0.8,
            options = { heading = 5, minZ = 38.91, maxZ = 39.91 },
        },
    },
    {
        job  = 'bennys',
        zone = {
            type   = 'box',
            center = vector3(-211.42, -1325.88, 31.30),
            length = 50.0, width = 60.0,
            options = { heading = 180, minZ = 29.0, maxZ = 50.0 },
        },
        dutyPoint = {
            center = vector3(-197.98, -1317.23, 31.30),
            length = 2.2, width = 0.8,
            options = { heading = 360, minZ = 29.30, maxZ = 33.30 },
        },
    },
    {
        job  = 'paleto_tuners',
        zone = {
            type   = 'box',
            center = vector3(158.66, 6387.48, 31.34),
            length = 84.6, width = 82.6,
            options = { heading = 26, minZ = 30.34, maxZ = 41.14 },
        },
    },
    {
        job  = 'dreamworks',
        zone = {
            type   = 'box',
            center = vector3(-744.94, -1476.06, 5.0),
            length = 102.8, width = 118.4,
            options = { heading = 50, minZ = 2.0, maxZ = 15.4 },
        },
        dutyPoint = {
            center = vector3(-765.8, -1520.73, 5.06),
            length = 2.2, width = 0.8,
            options = { heading = 23, minZ = 4.31, maxZ = 5.91 },
        },
        dutyPoint2 = {
            center = vector3(-696.17, -1391.4, 5.5),
            length = 1.0, width = 1.0,
            options = { heading = 320, minZ = 2.1, maxZ = 6.1 },
        },
    },
}

-- Crafting recipes available at all mechanic benches.
-- To restrict a recipe to a specific shop, add it to that shop's `recipes` table in Config.CraftingBenches.
Config.BenchRecipes = {

    -- Regular repair parts
    { result = { name = 'repair_part_electronics',     count = 10 }, time = 3500,  items = {
        { name = 'electronic_parts', count = 5  },
        { name = 'plastic',          count = 4  },
        { name = 'rubber',           count = 1  },
        { name = 'copperwire',       count = 8  },
    }},
    { result = { name = 'repair_part_axle',            count = 5  }, time = 5000,  items = {
        { name = 'ironbar',          count = 4  },
    }},
    { result = { name = 'repair_part_injectors',       count = 20 }, time = 4500,  items = {
        { name = 'ironbar',          count = 2  },
        { name = 'plastic',          count = 2  },
        { name = 'copperwire',       count = 4  },
        { name = 'glue',             count = 1  },
    }},
    { result = { name = 'repair_part_clutch',          count = 8  }, time = 5000,  items = {
        { name = 'ironbar',          count = 6  },
        { name = 'rubber',           count = 1  },
    }},
    { result = { name = 'repair_part_brakes',          count = 5  }, time = 4500,  items = {
        { name = 'ironbar',          count = 2  },
        { name = 'glue',             count = 1  },
    }},
    { result = { name = 'repair_part_transmission',    count = 2  }, time = 3500,  items = {
        { name = 'ironbar',          count = 3  },
        { name = 'electronic_parts', count = 1  },
        { name = 'plastic',          count = 1  },
    }},
    { result = { name = 'repair_part_rad',             count = 2  }, time = 2000,  items = {
        { name = 'ironbar',          count = 3  },
        { name = 'rubber',           count = 1  },
        { name = 'glue',             count = 1  },
    }},

    -- High-grade repair parts
    { result = { name = 'repair_part_injectors_hg',    count = 20 }, time = 11000, items = {
        { name = 'ironbar',          count = 3  },
        { name = 'plastic',          count = 2  },
        { name = 'copperwire',       count = 4  },
        { name = 'heavy_glue',       count = 1  },
    }},
    { result = { name = 'repair_part_clutch_hg',       count = 8  }, time = 13000, items = {
        { name = 'ironbar',          count = 8  },
        { name = 'rubber',           count = 2  },
    }},
    { result = { name = 'repair_part_brakes_hg',       count = 5  }, time = 9000,  items = {
        { name = 'ironbar',          count = 2  },
        { name = 'heavy_glue',       count = 1  },
    }},
    { result = { name = 'repair_part_transmission_hg', count = 2  }, time = 9000,  items = {
        { name = 'ironbar',          count = 3  },
        { name = 'electronic_parts', count = 1  },
        { name = 'plastic',          count = 1  },
        { name = 'copperwire',       count = 1  },
    }},
    { result = { name = 'repair_part_rad_hg',          count = 2  }, time = 6000,  items = {
        { name = 'ironbar',          count = 3  },
        { name = 'rubber',           count = 1  },
        { name = 'glue',             count = 1  },
    }},

    -- Tools & consumables
    { result = { name = 'repairkit',                   count = 4  }, time = 3500,  items = {
        { name = 'ironbar',          count = 2  },
        { name = 'glue',             count = 1  },
        { name = 'plastic',          count = 2  },
        { name = 'copperwire',       count = 4  },
        { name = 'rubber',           count = 2  },
    }},
    { result = { name = 'repairkitadv',                count = 4  }, time = 5500,  items = {
        { name = 'ironbar',          count = 3  },
        { name = 'heavy_glue',       count = 1  },
        { name = 'plastic',          count = 3  },
        { name = 'copperwire',       count = 4  },
        { name = 'rubber',           count = 4  },
    }},
    { result = { name = 'lockpick',                    count = 2  }, time = 5000,  items = {
        { name = 'ironbar',          count = 5  },
        { name = 'scrapmetal',       count = 10 },
    }},
    { result = { name = 'adv_lockpick',                count = 4  }, time = 5000,  items = {
        { name = 'ironbar',          count = 20 },
        { name = 'scrapmetal',       count = 40 },
        { name = 'diamond',          count = 1  },
    }},
    { result = { name = 'camber_controller',           count = 1  }, time = 8000,  items = {
        { name = 'plastic',          count = 40 },
        { name = 'ironbar',          count = 20 },
        { name = 'electronic_parts', count = 75 },
        { name = 'scrapmetal',       count = 10 },
        { name = 'heavy_glue',       count = 10 },
        { name = 'goldbar',          count = 1  },
        { name = 'diamond',          count = 1  },
    }},
    { result = { name = 'carclean',                    count = 4  }, time = 5500,  items = {
        { name = 'water',            count = 1  },
        { name = 'plastic',          count = 4  },
    }},
    { result = { name = 'carpolish',                   count = 4  }, time = 1000,  items = {
        { name = 'fishing_oil',      count = 1  },
        { name = 'plastic',          count = 20 },
    }},
    { result = { name = 'carpolish_high',              count = 4  }, time = 1000,  items = {
        { name = 'fishing_oil',      count = 2  },
        { name = 'plastic',          count = 40 },
        { name = 'cloth',            count = 20 },
    }},

    -- Performance upgrades — turbo
    { result = { name = 'upgrade_turbo',               count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 20  },
        { name = 'copperwire',       count = 150 },
        { name = 'electronic_parts', count = 75  },
        { name = 'rubber',           count = 100 },
        { name = 'plastic',          count = 100 },
        { name = 'goldbar',          count = 5   },
        { name = 'silverbar',        count = 5   },
        { name = 'heavy_glue',       count = 50  },
        { name = 'diamond',          count = 2   },
    }},

    -- Performance upgrades — engine (tier 4 disabled; too powerful for general availability)
    { result = { name = 'upgrade_engine1',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 5  },
        { name = 'copperwire',       count = 30 },
        { name = 'electronic_parts', count = 25 },
        { name = 'rubber',           count = 45 },
        { name = 'silverbar',        count = 1  },
        { name = 'goldbar',          count = 1  },
    }},
    { result = { name = 'upgrade_engine2',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 10 },
        { name = 'copperwire',       count = 50 },
        { name = 'electronic_parts', count = 50 },
        { name = 'rubber',           count = 60 },
        { name = 'silverbar',        count = 3  },
        { name = 'goldbar',          count = 3  },
    }},
    { result = { name = 'upgrade_engine3',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 15 },
        { name = 'copperwire',       count = 70 },
        { name = 'electronic_parts', count = 74 },
        { name = 'rubber',           count = 80 },
        { name = 'silverbar',        count = 5  },
        { name = 'goldbar',          count = 5  },
    }},

    -- Performance upgrades — brakes
    { result = { name = 'upgrade_brakes1',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 5  },
        { name = 'electronic_parts', count = 25 },
        { name = 'rubber',           count = 45 },
        { name = 'glue',             count = 30 },
        { name = 'silverbar',        count = 1  },
        { name = 'goldbar',          count = 1  },
    }},
    { result = { name = 'upgrade_brakes2',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 10 },
        { name = 'electronic_parts', count = 50 },
        { name = 'rubber',           count = 60 },
        { name = 'glue',             count = 30 },
        { name = 'silverbar',        count = 3  },
        { name = 'goldbar',          count = 3  },
    }},
    { result = { name = 'upgrade_brakes3',             count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 15 },
        { name = 'electronic_parts', count = 75 },
        { name = 'rubber',           count = 80 },
        { name = 'glue',             count = 40 },
        { name = 'silverbar',        count = 5  },
        { name = 'goldbar',          count = 5  },
    }},

    -- Performance upgrades — transmission
    { result = { name = 'upgrade_transmission1',       count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 5  },
        { name = 'electronic_parts', count = 25 },
        { name = 'rubber',           count = 15 },
        { name = 'plastic',          count = 20 },
        { name = 'heavy_glue',       count = 3  },
        { name = 'silverbar',        count = 1  },
        { name = 'goldbar',          count = 1  },
    }},
    { result = { name = 'upgrade_transmission2',       count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 10 },
        { name = 'electronic_parts', count = 50 },
        { name = 'rubber',           count = 30 },
        { name = 'plastic',          count = 30 },
        { name = 'heavy_glue',       count = 6  },
        { name = 'silverbar',        count = 3  },
        { name = 'goldbar',          count = 3  },
    }},
    { result = { name = 'upgrade_transmission3',       count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 15 },
        { name = 'electronic_parts', count = 75 },
        { name = 'rubber',           count = 45 },
        { name = 'plastic',          count = 40 },
        { name = 'heavy_glue',       count = 9  },
        { name = 'silverbar',        count = 5  },
        { name = 'goldbar',          count = 5  },
    }},

    -- Performance upgrades — suspension
    { result = { name = 'upgrade_suspension1',         count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 5  },
        { name = 'copperwire',       count = 20 },
        { name = 'rubber',           count = 10 },
        { name = 'plastic',          count = 10 },
        { name = 'glue',             count = 15 },
        { name = 'silverbar',        count = 3  },
    }},
    { result = { name = 'upgrade_suspension2',         count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 10 },
        { name = 'copperwire',       count = 30 },
        { name = 'rubber',           count = 20 },
        { name = 'plastic',          count = 25 },
        { name = 'glue',             count = 18 },
        { name = 'silverbar',        count = 5  },
    }},
    { result = { name = 'upgrade_suspension3',         count = 1  }, time = 2000,  items = {
        { name = 'ironbar',          count = 15 },
        { name = 'copperwire',       count = 40 },
        { name = 'rubber',           count = 30 },
        { name = 'plastic',          count = 40 },
        { name = 'glue',             count = 21 },
        { name = 'goldbar',          count = 7  },
    }},
}

-- Crafting bench locations per shop. `recipes` is optional; omit to use Config.BenchRecipes.
-- blackline has no crafting bench.
Config.CraftingBenches = {
    {
        job = 'redline',
        benches = {
            { coords = vector3(-584.07, -939.57, 23.89),   w = 3.8, l = 1.0, heading = 270, minZ = 23.29, maxZ = 24.89 },
            { coords = vector3(-589.19, -926.07, 28.14),   w = 2.0, l = 1.0, heading = 270, minZ = 27.54, maxZ = 29.14 },
        },
    },
    {
        job = 'tuna',
        benches = {
            { coords = vector3(133.37, -3051.24, 7.04),    w = 1.8, l = 11.8, heading = 0,   minZ = 6.04,  maxZ = 8.24  },
        },
    },
    {
        job = 'tirenutz',
        benches = {
            { coords = vector3(-57.5, -1325.07, 29.27),    w = 4.2, l = 1.0,  heading = 0,   minZ = 28.27, maxZ = 31.07 },
        },
    },
    {
        job = 'hayes',
        benches = {
            { coords = vector3(-1421.67, -456.38, 35.91),  w = 3.8, l = 1.0,  heading = 302, minZ = 34.91, maxZ = 37.31 },
        },
    },
    {
        job = 'atomic',
        benches = {
            { coords = vector3(476.67, -1876.93, 26.09),   w = 1.2, l = 4.0,  heading = 25,  minZ = 25.09, maxZ = 28.09 },
        },
    },
    {
        job = 'harmony',
        benches = {
            { coords = vector3(1176.15, 2635.21, 37.75),   w = 3.8, l = 1.4,  heading = 0,   minZ = 36.75, maxZ = 39.55 },
        },
    },
    {
        job = 'autoexotics',
        benches = {
            { coords = vector3(558.99, -171.67, 54.51),    w = 1.2, l = 3.6,  heading = 0,   minZ = 53.51, maxZ = 56.11 },
        },
    },
    {
        job = 'ottos',
        benches = {
            { coords = vector3(950.91, -979.09, 39.5),     w = 3.8, l = 1.2,  heading = 4,   minZ = 38.55, maxZ = 40.75 },
        },
    },
    {
        job = 'bennys',
        benches = {
            { coords = vector3(-205.33, -1335.66, 31.30),  w = 1.0, l = 5.0,  heading = 270, minZ = 29.30, maxZ = 32.30 },
        },
    },
    {
        job = 'paleto_tuners',
        benches = {
            { coords = vector3(163.12, 6364.78, 31.27),    w = 2.0, l = 4.4,  heading = 30,  minZ = 30.27, maxZ = 32.67 },
        },
    },
    {
        job = 'dreamworks',
        benches = {
            { coords = vector3(-726.39, -1505.64, 5.06),   w = 1.0, l = 5.0,  heading = 293, minZ = 4.06,  maxZ = 6.66  },
        },
    },
}
