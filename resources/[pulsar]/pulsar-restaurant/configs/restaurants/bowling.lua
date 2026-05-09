table.insert(Config.Restaurants, {
    Name = "Bobs Balls",
    Job = "bowling",
    Pickups = {
        {
            id = "bobs_balls-pickup-1",
            coords = vector3(755.73, -768.12, 26.34),
            width = 0.8,
            length = 0.6,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 26.14,
                maxZ = 26.94
            },
            data = {
                business = "bowling",
            },
        },
    },
})
