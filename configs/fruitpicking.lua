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
--		  If you need help with configuration or have any questions, please do not hesitate to ask.
--		  Docs Are Always Available At -- https://mrnewbs-scrips.gitbook.io/guide


Config = Config or {}

Config.PickingTypes = {
    ["Apple Trees"] = {
        locations = {
            vector4(347.5, 6517.5, 30.5, 1.0),
        },
        rewardItem = {item = "apple", count = 1, metadata = {}},
        anim = {dict = "amb@prop_human_movie_bulb@idle_a", name = "idle_a", flag = 1},
    },
    ["Pineapple"] = {
        locations = {
            vector4(2190.8911, 5096.1934, 47.0741, 41.8049),
            vector4(2188.4407, 5098.7378, 47.9127, 42.9676),
            vector4(2185.2417, 5102.0708, 47.6935, 43.8043),
        },
        rewardItem = {item = "pineapple", count = 1, metadata = {}},
        anim = {dict = "amb@world_human_gardener_plant@male@base", name = "base", flag = 1},
        propModel = "prop_pineapple",
    },
    ["Lettuce"] = {
        locations = {
            vector4(2194.8003, 5092.0093, 47.1285, 225.2668),
            vector4(2817.8713, 4587.9688, 44.8657, 0.0000),
            vector4(2817.0652, 4590.8008, 44.8424, 0.0000),
            vector4(2816.5793, 4593.1543, 44.8118, 0.0000),
            vector4(2820.0085, 4596.8662, 45.0933, 0.0000),
            vector4(2819.2949, 4599.8921, 45.0838, 0.0000),
            vector4(2821.5347, 4615.8022, 45.4435, 0.0000),
            vector4(2822.0645, 4613.2876, 45.4886, 0.0000),
            vector4(2835.7375, 4592.4468, 46.1003, 0.0000),
        },
        rewardItem = {item = "lettuce", count = 1, metadata = {}},
        anim = {dict = "amb@world_human_gardener_plant@male@base", name = "base", flag = 1},
        propModel = "prop_veg_crop_03_cab",
    },
}