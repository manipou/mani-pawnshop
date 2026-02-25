local Config = {}

Config.Debug = false

Config.Profit = 5 -- 5% profit

Config.Shops = {
    {
        Job = 'pantestjerne',
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
            vec3(435.50, -1464.69, 28.0),
            vec3(455.71, -1457.66, 28.0),
            vec3(465.80, -1486.34, 28.0),
            vec3(446.81, -1492.82, 28.0)
        }
    },
    {
        Job = 'gp',
        Logo = 'https://files.fivemerr.com/images/b9fd1f97-8a2f-448e-b662-1453db5020b6.png',
        Refiner = vec3(-490.32, 295.03, 83.93),
        Computer = vec3(-492.70, 291.74, 83.19),
        Printer = vec3(-494.79, 291.50, 83.33),
        Stash = vec3(-494.01, 294.97, 83.57),
        Tray = {
            vec3(-493.88, 287.71, 83.38),
            vec3(-491.39, 287.34, 83.38),
            vec3(-489.00, 287.13, 83.38)
        },
        Zone = {
            vec3(-509.90, 276.55, 82.24),
            vec3(-473.47, 273.55, 82.27),
            vec3(-462.39, 297.42, 82.27),
            vec3(-512.08, 301.96, 82.18)
        }
    }
}


Config.Inventory = {
    ['tray'] = {
        Label = 'Bakke',
        Slots = 15,
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
            Amount = { 10, 20 }
        },
        SearchTime = 2500,
        Zones = {
            { Coords = vec3(1122.70, -546.00, 0.00), Radius = 300.0, Dumpsters = { 10, 16 } },
            { Coords = vec3(-182.69, -1304.80, 00.00), Radius = 200.0, Dumpsters = { 10, 16 } },
            { Coords = vec3(-662.68, -862.78, 00.00), Radius = 250.0, Dumpsters = { 10, 16 } }
        },
        DumpsterProps = {
            'prop_dumpster_4b',
            'prop_dumpster_4a',
            'prop_dumpster_01a',
            'prop_dumpster_02b',
            'prop_dumpster_02a'
        },
        Cooldown = 10 * 1000 * 60,
        XP = 3 -- Per dumpster
    }
}

Config.Orders = {
    Interval = { 10, 20 }, -- Minutes
    Expire = 130, -- Minutes
    Worth = {
        ['refinedmaterial'] = 400
    },
    Types = {
        {
            Label = 'Mandehul A/S',
            Logo = 'https://files.fivemerr.com/images/5e1ddc1b-f3fa-4c7b-b164-96964e05d258.png',
            Coords = vec4(539.95, -1655.64, 27.83, 230.59),
            Items = 1,
            InterestedIn = {
                { Item = 'refinedmaterial', Amount = { 3500, 4500 } }
            }
        },
        {
            Label = 'Burgershot',
            Logo = 'https://files.fivemerr.com/images/be2f4265-2def-45c2-8ee4-95f4a1d6a5bc.png',
            Coords = vec4(-1175.75, -899.56, 12.70, 217.64),
            Items = 1,
            InterestedIn = {
                { Item = 'refinedmaterial', Amount = { 3500, 4500 } }
            }
        },
    }
}

Config.Refiner = {
    ['necklace'] = {
        Price = 600,
        Time = 400
    },
    ['coins'] = {
        Price = 2100,
        Time = 400
    },
    ['diamond_necklace'] = {
        Price = 2600,
        Time = 650
    },
    ['ring'] = {
        Price = 400,
        Time = 400
    },
    ['diamond_ring'] = {
        Price = 3600,
        Time = 650
    },
    ['watch'] = {
        Price = 1100,
        Time = 400
    },
    ['luxurious_watch'] = {
        Price = 2800,
        Time = 650
    },
    ['gold_bar'] = {
        Price = 3000,
        Time = 1000
    },
    ['diamantboks'] = {
        Price = 4000,
        Time = 400
    },
    ['skull_art'] = {
        Price = 1800,
        Time = 1000
    },
    ['painting1'] = {
        Price = 3400,
        Time = 500
    },
    ['painting2'] = {
        Price = 6300,
        Time = 750
    },
    ['painting3'] = {
        Price = 20000,
        Time = 1000
    },
    ['painting4'] = {
        Price = 50000,
        Time = 2000
    }
}

return Config