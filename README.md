# MrNewbOrganics

Fruit tree picking, vegetable harvesting, and a farmers market vendor.

[Documentation](https://mrnewb.github.io/docs/mrnewborganics) · [GitHub](https://github.com/MrNewb/MrNewbOrganics) · [Discord](https://discord.gg/mrnewbscripts)

## Install

Needs [ox_lib](https://github.com/overextended/ox_lib) and [Newb_Bridge](https://github.com/MrNewb/Newb_Bridge).

```cfg
ensure ox_lib
ensure Newb_Bridge
ensure MrNewbOrganics
```

Copy `[install]/images/` (`apple.png`, `pineapple.png`, `lettuce.png`) into your inventory images folder. Register `apple`, `pineapple`, and `lettuce` as items.

## Config

Everything lives in `configs/config.lua`:

- `Config.PickingTypes` — pick sites (sphere zones or spawned props), reward items, and animations. Each type only places a map blip on the **first** location in its list.
- `Config.FarmersMarket` — vendor peds, blips, and sell prices
