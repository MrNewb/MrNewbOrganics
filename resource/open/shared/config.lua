--		___  ___       _   _                  _      _____              _         _
--		|  \/  |      | \ | |                | |    /  ___|            (_)       | |
--		| .  . | _ __ |  \| |  ___ __      __| |__  \ `--.   ___  _ __  _  _ __  | |_  ___
--		| |\/| || '__|| . ` | / _ \\ \ /\ / /| '_ \  `--. \ / __|| '__|| || '_ \ | __|/ __|
--		| |  | || |   | |\  ||  __/ \ V  V / | |_) |/\__/ /| (__ | |   | || |_) || |_ \__ \
--		\_|  |_/|_|   \_| \_/ \___|  \_/\_/  |_.__/ \____/  \___||_|   |_|| .__/  \__||___/
--									          							  | |
--									          							  |_|
--
--		  Need support? Join our Discord server for help: https://discord.gg/mrnewbscripts
--		  Check out my paid scripts and freebies at https://mrnewbscripts.tebex.io/
--		  If you need help with configuration or have any questions, please do not hesitate to ask.
--		  Docs Are Always Available At -- https://mrnewb.github.io/docs/
--

Config = Config or {}

-- Seconds a picked plant stays gone for everyone. Counted from the pick time.
Config.PickingRestoreSeconds = 2 * 60 * 60

Config.PickingTypes = {
    apple = {
        rewardItem = { item = 'apple', count = 1, metadata = {} },
        anim = { dict = 'amb@prop_human_movie_bulb@idle_a', name = 'idle_a', flag = 1 },
    },
    pineapple = {
        rewardItem = { item = 'pineapple', count = 1, metadata = {} },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', name = 'base', flag = 1 },
        propModel = 'prop_pineapple',
    },
    lettuce = {
        rewardItem = { item = 'lettuce', count = 1, metadata = {} },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', name = 'base', flag = 1 },
        propModel = 'prop_veg_crop_03_cab',
    },
}

-- Enter a field zone, get currently spawned plant ids, batch them through AddInteraction.
-- Picked plants despawn for everyone in the zone and stay gone until restoreSeconds.
Config.PickingFields = {
    grapeseed = {
        zone = {
            points = {
                vec3(2153.78, 5087.38, 44.59),
                vec3(2243.47, 4994.81, 41.05),
                vec3(2308.55, 5061.18, 44.42),
                vec3(2268.86, 5102.03, 48.73),
                vec3(2230.20, 5140.64, 55.11),
                vec3(2218.99, 5147.03, 55.62),
                vec3(2206.53, 5137.12, 53.79),
                vec3(2180.02, 5112.02, 47.27),
                vec3(2162.61, 5095.16, 45.16),
                vec3(2162.50, 5095.20, 45.14),
            },
            thickness = 33.00,
        },
        plants = {
            {
                plantType = 'pineapple',
                coords = {
                    vec4(2185.0920, 5062.7695, 43.6382, 154.1222),
                    vec4(2199.4265, 5061.1816, 45.5715, 36.7008),
                    vec4(2217.8618, 5055.7319, 45.8715, 231.5974),
                    vec4(2223.2061, 5063.3726, 46.3834, 50.3194),
                    vec4(2196.4788, 5100.2192, 48.0138, 41.2732),
                },
            },
            {
                plantType = 'lettuce',
                coords = {
                    vec4(2254.8794, 5044.7373, 43.4337, 230.1057),
                    vec4(2216.9473, 5089.2075, 48.5649, 253.5473),
                    vec4(2205.1379, 5108.1646, 49.7646, 41.8140),
                    vec4(2213.2761, 5109.3677, 50.5175, 39.7399),
                    vec4(2268.2410, 5054.0469, 43.5804, 226.2908),
                },
            },
        },
    },
    paleto_orchard = {
        zone = { coords = vec3(347.5, 6517.5, 30.5), radius = 25.0 },
        plants = {
            { coords = vec4(347.5, 6517.5, 30.5, 1.0), plantType = 'apple' },
        },
    },
    grapeseed_east = {
        zone = { coords = vec3(2822.0, 4598.0, 45.2), radius = 45.0 },
        plants = {
            { coords = vec4(2817.8713, 4587.9688, 44.8657, 0.0000), plantType = 'lettuce' },
            { coords = vec4(2816.5793, 4593.1543, 44.8118, 0.0000), plantType = 'lettuce' },
            { coords = vec4(2819.2949, 4599.8921, 45.0838, 0.0000), plantType = 'lettuce' },
            { coords = vec4(2821.5347, 4615.8022, 45.4435, 0.0000), plantType = 'lettuce' },
            { coords = vec4(2835.7375, 4592.4468, 46.1003, 0.0000), plantType = 'lettuce' },
        },
    },
}

Config.BlipCategory = 13
Config.BlipCategoryLabel = 'Shops'

Config.FarmersMarket = {
    Enabled = true,
    Markets = {
        ['Mr Solitaire'] = {
            blip = { id = 52, color = 2, scale = 0.8, label = 'Farmers Market', category = Config.BlipCategory },
            entityType = 'ped',
            model = 'cs_brad',
            coords = vector4(1263.4164, 3545.6189, 35.1728, 204.9759),
            shopItems = {
                apple = 2,
                pineapple = 2,
                lettuce = 2,
            },
        },
    },
}
