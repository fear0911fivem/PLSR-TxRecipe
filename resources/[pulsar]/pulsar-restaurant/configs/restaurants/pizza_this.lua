table.insert(Config.Restaurants, {
    Name = "Pizza This",
    Job = "pizza_this",
    Pickups = {
        {
            id = "pizza_this-pickup-1",
            coords = vector3(811.17, -750.84, 26.78),
            width = 1.0,
            length = 1.2,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 26.58,
                maxZ = 27.38
            },
            data = {
                business = "pizza_this",
            },
        },
        {
            id = "pizza_this-pickup-2",
            coords = vector3(811.17, -752.62, 26.78),
            width = 1.0,
            length = 1.2,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 26.58,
                maxZ = 27.38
            },
            data = {
                business = "pizza_this",
            },
        },
    },
    Warmers = {
        {
            id = "pizza_this-warmer-1",
            coords = vector3(811.69, -755.44, 26.78),
            width = 0.8,
            length = 2.0,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 26.58,
                maxZ = 27.38
            },
            restrict = {
                jobs = { "pizza_this" },
            },
            data = {
                business = "pizza_this",
            },
        },
        {
            id = "pizza_this-warmer-2",
            coords = vector3(806.0, -763.82, 26.78),
            width = 2.6,
            length = 1.0,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 25.78,
                maxZ = 28.18
            },
            restrict = {
                jobs = { "pizza_this" },
            },
            data = {
                business = "pizza_this",
            },
        },
    },
})
