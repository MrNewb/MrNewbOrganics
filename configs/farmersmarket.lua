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

Config.FarmersMarket = {
    Enabled = true,
    Markets = {
        ["Mr Geerdo"] = {
            blip = {id = 52, color = 2, scale = 0.8, label = "Farmers Market"},
            entityType = "ped",
            model = "cs_brad",
            coords = vector4(1263.4164, 3545.6189, 34.1728, 204.9759),
            shopItems = {
                apple = 5,
                pineapple = 10,
                lettuce = 7,
            },
        },
    }
}