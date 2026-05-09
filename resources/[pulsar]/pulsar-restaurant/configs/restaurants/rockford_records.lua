table.insert(Config.Restaurants, {
    Name = "Rockford Records Bar",
    Job = "rockford_records",
    Pickups = {
        {
            id = "rockford_records-pickup-1",
            coords = vector3(-996.79, -259.17, 39.04),
            width = 1.2,
            length = 1.6,
            options = {
                heading = 325,
                --debugPoly=true,
                minZ = 38.44,
                maxZ = 40.24
            },
            data = {
                business = "rockford_records",
            },
        },
        {
            id = "rockford_records-pickup-2",
            coords = vector3(-998.34, -257.11, 39.04),
            width = 1.2,
            length = 1.6,
            options = {
                heading = 285,
                --debugPoly=true,
                minZ = 38.44,
                maxZ = 40.24
            },
            data = {
                business = "rockford_records",
            },
        },
    },
    Fridges = {
        {
            id = "rockford_records-1",
            coords = vector3(-994.04, -257.81, 39.04),
            width = 1.2,
            length = 1.2,
            options = {
                heading = 325,
                --debugPoly=true,
                minZ = 38.04,
                maxZ = 40.64
            },
            restrict = {
                jobs = { "rockford_records" },
            },
            data = {
                business = "rockford_records",
            },
        },
        {
            id = "rockford_records-2",
            coords = vector3(-995.04, -259.43, 39.04),
            width = 1.0,
            length = 1.0,
            options = {
                heading = 325,
                --debugPoly=true,
                minZ = 38.04,
                maxZ = 39.44
            },
            restrict = {
                jobs = { "rockford_records" },
            },
            data = {
                business = "rockford_records",
            },
        },
    },
})
