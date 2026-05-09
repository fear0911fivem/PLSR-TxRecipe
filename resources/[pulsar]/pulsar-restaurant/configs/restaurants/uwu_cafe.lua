table.insert(Config.Restaurants, {
    Name = "UwU Cafe",
    Job = "uwu",
    Pickups = {
        {
            id = "uwu-pickup-1",
            coords = vector3(-584.01, -1062.1, 22.34),
            width = 0.8,
            length = 0.6,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 22.34,
                maxZ = 22.94
            },
            data = {
                business = "uwu",
            },
        },
        {
            id = "uwu-pickup-2",
            coords = vector3(-584.02, -1059.26, 22.34),
            width = 0.8,
            length = 0.6,
            options = {
                heading = 270,
                --debugPoly=true,
                minZ = 22.34,
                maxZ = 22.94
            },
            data = {
                business = "uwu",
            },
        },
        {
            id = "uwu-pickup-3",
            coords = vector3(-586.62, -1062.95, 22.34),
            width = 0.8,
            length = 0.6,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 22.34,
                maxZ = 22.94
            },
            data = {
                business = "uwu",
            },
        },
    },
    Warmers = {
        {
            id = "uwu-warmer-1",
            coords = vector3(-587.23, -1059.64, 22.36),
            width = 2.2,
            length = 0.8,
            options = {
                heading = 0,
                --debugPoly = true,
                minZ = 22.16,
                maxZ = 22.96
            },
            restrict = {
                jobs = { "uwu" },
            },
            data = {
                business = "uwu",
            },
        },
    },
})
