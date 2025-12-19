local Config = {}

Config.Debug = true

Config.Shops = {
    {
        Job = 'realestate',
        Logo = 'https://files.fivemerr.com/images/409553aa-af17-47d9-a2b7-e37aecbe5442.png',
        Refiner = vec4(448.53, -1482.36, 29.35, 17.83),
        Computer = vec4(451.82, -1461.85, 29.10, 19.80),
        Tray = {
            vec4(449.73, -1469.44, 29.30, 290.0),
            vec4(450.72, -1472.31, 29.30, 290.0)
        },
        Zone = {
            vec(435.50, -1464.69, 28.0),
            vec(455.71, -1457.66, 28.0),
            vec(465.80, -1486.34, 28.0),
            vec(446.81, -1492.82, 28.0)
        }
    }
}

Config.Tray = {
    Slots = 5,
    MaxWeight = 30000,
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

Config.Levels = {
    { 0, 1000 },
    { 1001, 3000 },
    { 3001, 6000 }
}

Config.Refiner = {
    Currency = {
        Type = 'Item',
        Value = 'refinedmaterial'
    },
    Items = {
        {
            Item = 'necklace',
            Label = 'Necklace',
            Price = 1000,
            Time = 400
        },
        {
            Item = 'diamond_necklace',
            Label = 'Diamond Necklace',
            Price = 3250,
            Time = 650
        },
        {
            Item = 'ring',
            Label = 'Ring',
            Price = 750,
            Time = 400
        },
        {
            Item = 'diamond_ring',
            Label = 'Diamond Ring',
            Price = 3250,
            Time = 650
        },
        {
            Item = 'watch',
            Label = 'Watch',
            Price = 750,
            Time = 400
        },
        {
            Item = 'luxurious_watch',
            Label = 'Luxurious Watch',
            Price = 2950,
            Time = 650
        },
        {
            Item = 'gold_bar',
            Label = 'Gold Bar',
            Price = 3000,
            Time = 1000
        },
        {
            Item = 'diamantboks',
            Label = 'Diamond Box',
            Price = 3900,
            Time = 400
        },
        {
            Item = 'skull_art',
            Label = 'Skull Art',
            Price = 2000,
            Time = 1000
        },
        {
            Item = 'painting1',
            Label = 'Painting 1',
            Price = 2500,
            Time = 500
        },
        {
            Item = 'painting2',
            Label = 'Painting 2',
            Price = 5000,
            Time = 750
        },
        {
            Item = 'painting3',
            Label = 'Painting 3',
            Price = 15000,
            Time = 1000
        },
        {
            Item = 'painting4',
            Label = 'Painting 4',
            Price = 30000,
            Time = 2000
        }
    }
}

return Config