Config = Config or {}

Config.Drugs = {
    weed = "Marijuana",
    oxy  = "OxyContin",
}

Config.CuffItems = {
    { item = "pdhandcuffs",     count = 1 },
    { item = "handcuffs",       count = 1 },
    { item = "fluffyhandcuffs", count = 1 },
}

Config.PoliceCars = {
    [`nkballer7`]   = true,
    [`nkcaracara2`] = true,
    [`nkdominator3`]= true,
    [`nkgranger2`]  = true,
    [`nkstx`]       = true,
    [`nktenf`]      = true,
    [`nktraining`]  = true,
    [`nkvigero2`]   = true,
    [`nkvstr`]      = true,
    [`policebretro`]= true,
    [`bcat`]        = true,
}

Config.EMSCars = {
    [`emsa`]      = true,
    [`emsnspeedo`]= true,
}

Config.StationBlips = {
    { coords = vector3(-445.7,    6013.2,  100.0), label = "Paleto Bay PD"   },
    { coords = vector3(438.7,     -981.8,  100.0), label = "MRPD"            },
    { coords = vector3(1850.634,  3683.860,100.0), label = "Sandy Shores PD" },
    { coords = vector3(372.658,  -1601.816,100.0), label = "Davis PD"        },
    -- { coords = vector3(835.011, -1292.794, 100.0), label = "La Mesa PD"   },
    -- { coords = vector3(-1081.486, -263.036, 37.791), label = "Guardius"   },
}

Config.DutyZones = {
    {
        id      = "pd-clockinoff-mrpd",
        coords  = vector3(443.407, -981.411, 30.690),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 356,
        minZ    = 30.49,
        maxZ    = 31.49,
    },
    {
        id      = "pd-clockinoff-sandy",
        coords  = vector3(1833.55, 3678.69, 34.19),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ    = 33.79,
        maxZ    = 35.59,
    },
    {
        id      = "pd-clockinoff-pbpd",
        coords  = vector3(-447.18, 6013.36, 32.29),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 45,
        minZ    = 32.29,
        maxZ    = 32.89,
    },
    {
        id      = "pd-clockinoff-davis",
        coords  = vector3(381.37, -1595.84, 30.05),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 320,
        minZ    = 29.85,
        maxZ    = 31.05,
    },
    {
        id      = "pd-clockinoff-lamesa",
        coords  = vector3(837.23, -1289.2, 28.24),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 0,
        minZ    = 27.24,
        maxZ    = 29.04,
    },
    {
        id      = "pd-clockinoff-courthouse",
        coords  = vector3(-528.46, -189.44, 38.23),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ    = 37.63,
        maxZ    = 39.23,
    },
    {
        id      = "pd-clockinoff-guardius",
        coords  = vector3(-1083.75, -247.15, 37.76),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 27,
        minZ    = 36.76,
        maxZ    = 38.96,
    },
    {
        id      = "pd-clockinoff-guardius2",
        coords  = vector3(-1049.57, -231.01, 39.02),
        size    = vector3(2.0, 2.0, 2.0),
        rotation = 300,
        minZ    = 38.02,
        maxZ    = 40.22,
    },
}

-- EMS

Config.HospitalBlips = {
    { coords = vector3(1149.516, -1531.912, 35.381), label = "St Fiacre Hospital" },
    -- { coords = vector3(-457.019, -333.263, 69.521),  label = "Mt Zonah Hospital"  },
    -- { coords = vector3(297.840,  -584.339, 43.261),  label = "PB Hospital"        },
}

-- Governmen

Config.CourthouseBlip   = vector3(-538.916, -214.852, 37.650)
Config.CourthouseGavel  = {
    coords   = vector3(-575.8, -210.3, 38.77),
    size     = vector3(2.0, 2.0, 2.0),
    rotation = 30,
    minZ     = 37.77,
    maxZ     = 39.37,
}
Config.GovServicesPed   = {
    model    = `a_f_m_eastsa_02`,
    coords   = vector3(-552.412, -202.760, 37.239),
    heading  = 337.363,
}
Config.GovDutyZones = {
    {
        id       = "gov-duty-1",
        coords   = vector3(-587.98, -206.59, 38.23),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ     = 37.23,
        maxZ     = 38.83,
    },
}

-- Prison / Corrections

Config.PrisonDutyZones = {
    {
        id       = "prison-clockinoff-1",
        coords   = vector3(1838.94, 2578.14, 46.01),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 305,
        minZ     = 45.81,
        maxZ     = 46.61,
    },
    {
        id       = "prison-clockinoff-2",
        coords   = vector3(1773.99, 2493.69, 49.67),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ     = 50.02,
        maxZ     = 50.62,
    },
    {
        id       = "prison-clockinoff-3",
        coords   = vector3(1768.84, 2573.73, 45.73),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 0,
        minZ     = 45.13,
        maxZ     = 46.13,
    },
}

Config.PrisonLockdownZones = {
    {
        id       = "prison-lockdown-1",
        coords   = vector3(1771.76, 2491.75, 49.67),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ     = 49.07,
        maxZ     = 50.07,
    },
    {
        id       = "prison-lockdown-2",
        coords   = vector3(1773.06, 2571.9, 45.73),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 0,
        minZ     = 45.93,
        maxZ     = 46.93,
    },
}

Config.PrisonCellDoorsZone = {
    id       = "prison-doors-lockup",
    coords   = vector3(1774.88, 2492.29, 49.67),
    size     = vector3(2.0, 2.0, 2.0),
    rotation = 30,
    minZ     = 49.77,
    maxZ     = 50.97,
}

Config.PrisonLockerZone = {
    id       = "prison-shitty-locker",
    coords   = vector3(1833.2, 2574.06, 46.01),
    size     = vector3(2.0, 2.0, 2.0),
    rotation = 0,
    minZ     = 45.01,
    maxZ     = 47.01,
}

-- Armor

Config.ArmoryZones = {
    {
        id       = "pd-armory-mrpd",
        label    = "MRPD Armory",
        shop     = "armory:police",
        coords   = vector3(453.89, -994.08, 30.69),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 355,
        minZ     = 29.69,
        maxZ     = 31.69,
    },
    {
        id       = "pd-armory-sandy",
        label    = "Sandy Shores Armory",
        shop     = "armory:police",
        coords   = vector3(1849.26, 3683.78, 34.27),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 30,
        minZ     = 33.27,
        maxZ     = 35.27,
    },
    {
        id       = "pd-armory-pbpd",
        label    = "Paleto Bay Armory",
        shop     = "armory:police",
        coords   = vector3(-449.51, 6012.58, 31.72),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 45,
        minZ     = 30.72,
        maxZ     = 32.72,
    },
    {
        id       = "pd-armory-davis",
        label    = "Davis Armory",
        shop     = "armory:police",
        coords   = vector3(381.37, -1596.5, 29.29),
        size     = vector3(2.0, 2.0, 2.0),
        rotation = 320,
        minZ     = 28.29,
        maxZ     = 30.29,
    },
}
