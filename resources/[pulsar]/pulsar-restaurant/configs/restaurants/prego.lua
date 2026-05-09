table.insert(Config.Restaurants, {
    Name = "Cafe Prego",
    Job = "prego",
    Pickups = {
        {
            id = "prego-pickup-1",
            coords = vector3(-1117.37, -1457.06, 5.11),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 35,
                --debugPoly=true,
                minZ = 4.71,
                maxZ = 5.91
            },
            data = {
                business = "prego",
            },
        },
        {
            id = "prego-pickup-2",
            coords = vector3(-1115.56, -1455.0, 5.11),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 35,
                --debugPoly=true,
                minZ = 4.71,
                maxZ = 5.91
            },
            data = {
                business = "prego",
            },
        },
    },
    Warmers = {
        {
            id = "prego-warmer-1",
            coords = vector3(-1119.54, -1453.37, 5.11),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 35,
                --debugPoly=true,
                minZ = 4.51,
                maxZ = 5.91
            },
            restrict = {
                jobs = { "prego" },
            },
            data = {
                business = "prego",
            },
        },
    },
})
