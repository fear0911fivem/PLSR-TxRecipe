table.insert(Config.Restaurants, {
    Name = "Bean Machine",
    Job = "beanmachine",
    Pickups = {
        {
            id = "beanmachine-pickup-1",
            coords = vector3(121.87, -1037.29, 29.28),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 340,
                --debugPoly=true,
                minZ = 29.08,
                maxZ = 30.08
            },
            data = {
                business = "beanmachine",
            },
        },
        {
            id = "beanmachine-pickup-2",
            coords = vector3(120.59, -1040.88, 29.28),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 340,
                --debugPoly=true,
                minZ = 29.08,
                maxZ = 30.08
            },
            data = {
                business = "beanmachine",
            },
        },
    },
})
