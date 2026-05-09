table.insert(Config.Restaurants, {
    Name = "Noodle Exchange",
    Job = "noodle",
    Pickups = {
        {
            id = "noodle-pickup-1",
            coords = vector3(-1188.24, -1156.97, 7.67),
            width = 0.8,
            length = 0.8,
            options = {
                heading = 15,
                --debugPoly=true,
                minZ = 6.67,
                maxZ = 8.27
            },
            data = {
                business = "noodle",
            },
        },
    },
    Warmers = {
        {
            id = "noodle-warmer-1",
            coords = vector3(-1182.64, -1157.08, 7.67),
            length = 0.8,
            width = 2.6,
            options = {
                heading = 15,
                --debugPoly=true,
                minZ = 6.67,
                maxZ = 8.67
            },
            restrict = {
                jobs = { "noodle" },
            },
            data = {
                business = "noodle",
            },
        },
    },
})
