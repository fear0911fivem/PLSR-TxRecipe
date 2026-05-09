table.insert(Config.Restaurants, {
    Name = "Bakery",
    Job = "bakery",
    Pickups = {
        {
            id = "bakery-pickup-1",
            coords = vector3(-1262.53, -290.64, 37.39),
            width = 1.0,
            length = 0.8,
            options = {
                heading = 21,
                --debugPoly=true,
                minZ = 36.59,
                maxZ = 37.99
            },
            data = {
                business = "bakery",
            },
        },
    },
    Warmers = {
        {
            id = "bakery-warmer-1",
            coords = vector3(-1265.04, -279.81, 37.39),
            length = 5.8,
            width = 1.2,
            options = {
                heading = 21,
                --debugPoly=true,
                minZ = 36.39,
                maxZ = 38.79
            },
            restrict = {
                jobs = { "bakery" },
            },
            data = {
                business = "bakery",
            },
        },
        {
            id = "bakery-warmer-2",
            coords = vector3(-1259.47, -286.53, 37.38),
            length = 5.0,
            width = 1.0,
            options = {
                heading = 21,
                --debugPoly=true,
                minZ = 36.38,
                maxZ = 38.78
            },
            restrict = {
                jobs = { "bakery" },
            },
            data = {
                business = "bakery",
            },
        },
    },
})
