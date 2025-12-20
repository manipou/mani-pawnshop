local Config = {}

Config.Debug = true

Config.Shops = {
    {
        Job = 'realestate',
        Logo = 'https://files.fivemerr.com/images/409553aa-af17-47d9-a2b7-e37aecbe5442.png',
        Refiner = vec3(448.53, -1482.36, 29.35),
        Computer = vec3(451.82, -1461.85, 29.10),
        Printer = vec3(451.73, -1463.57, 29.24),
        Stash = vec3(454.36, -1471.53, 29.40),
        Tray = {
            vec3(449.73, -1469.44, 29.30),
            vec3(450.72, -1472.31, 29.30)
        },
        Zone = {
            vec(435.50, -1464.69, 28.0),
            vec(455.71, -1457.66, 28.0),
            vec(465.80, -1486.34, 28.0),
            vec(446.81, -1492.82, 28.0)
        }
    }
}

Config.Inventory = {
    ['tray'] = {
        Label = 'Bakke',
        Slots = 5,
        MaxWeight = 30000,
    },
    ['refiner'] = {
        Label = 'Refiner',
        Slots = 20,
        MaxWeight = 120000,
    },
    ['printer'] = {
        Label = 'Printer',
        Slots = 5,
        MaxWeight = 30000,
    },
    ['stash'] = {
        Label = 'Opbevaring',
        Slots = 100,
        MaxWeight = 2500000,
    }
}

Config.Levels = {
    { 0, 1000 },
    { 1001, 3000 },
    { 3001, 6000 }
}

Config.Contracts = {
    ['DumpsterDive'] = {
        Reward = {
            Item = 'refinedmaterial',
            Amount = { 1, 3 }
        },
        SearchTime = 100,
        Zones = {
            { Coords = vec3(1122.70, -546.00, 0.00), Radius = 300.0, Dumpsters = { 10, 16 } },
        },
        DumpsterProps = {
            'prop_dumpster_4b',
            'prop_dumpster_4a',
            'prop_dumpster_01a',
            'prop_dumpster_02b',
            'prop_dumpster_02a'
        },
        XP = 5 -- Per dumpster
    }
}

Config.Orders = {
    Interval = { 1, 2 }, -- Minutes
    Expire = 120, -- Minutes
    Worth = {
        ['refinedmaterial'] = 500
    },
    Types = {
        {
            Label = 'Mandehul A/S',
            Logo = 'https://files.fivemerr.com/images/409553aa-af17-47d9-a2b7-e37aecbe5442.png',
            Coords = vec4(539.95, -1655.64, 27.83, 230.59),
            Items = 1,
            InterestedIn = {
                { Item = 'refinedmaterial', Amount = { 5, 10 } }
            }
        },
        {
            Label = 'Burgershot',
            Logo = 'https://files.fivemerr.com/images/409553aa-af17-47d9-a2b7-e37aecbe5442.png',
            Coords = vec4(-1175.75, -899.56, 12.70, 217.64),
            Items = 1,
            InterestedIn = {
                { Item = 'refinedmaterial', Amount = { 5, 10 } }
            }
        },
        {
            Label = 'Mechanigger',
            Logo = 'https://files.fivemerr.com/images/409553aa-af17-47d9-a2b7-e37aecbe5442.png',
            Coords = vec4(1142.77, -792.44, 56.60, 89.92),
            Items = 1,
            InterestedIn = {
                { Item = 'refinedmaterial', Amount = { 5, 10 } }
            }
        },
    }
}

Config.Refiner = {
    ['necklace'] = {
        Price = 700,
        Reward = 2,
        Time = 400
    },
    ['coins'] = {
        Price = 2300,
        Reward = 6,
        Time = 400
    },
    ['diamond_necklace'] = {
        Price = 2900,
        Reward = 8,
        Time = 650
    },
    ['ring'] = {
        Price = 450,
        Reward = 2,
        Time = 400
    },
    ['diamond_ring'] = {
        Price = 3900,
        Reward = 10,
        Time = 650
    },
    ['watch'] = {
        Price = 1200,
        Reward = 3,
        Time = 400
    },
    ['luxurious_watch'] = {
        Price = 3100,
        Reward = 10,
        Time = 650
    },
    ['gold_bar'] = {
        Price = 3300,
        Reward = 9,
        Time = 1000
    },
    ['diamantboks'] = {
        Price = 4300,
        Reward = 11,
        Time = 400
    },
    ['skull_art'] = {
        Price = 2000,
        Reward = 5,
        Time = 1000
    },
    ['painting1'] = {
        Price = 3700,
        Reward = 8,
        Time = 500
    },
    ['painting2'] = {
        Price = 7000,
        Reward = 15,
        Time = 750
    },
    ['painting3'] = {
        Price = 22000,
        Reward = 50,
        Time = 1000
    },
    ['painting4'] = {
        Price = 55000,
        Reward = 120,
        Time = 2000
    }
}

return Config