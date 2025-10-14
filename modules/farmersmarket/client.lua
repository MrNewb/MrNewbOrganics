---@diagnostic disable: duplicate-set-field
local activeShopObjs = {}
ShopObj = {}
ShopObj.__index = ShopObj

function ShopObj:new(id, coords, entityType, model, blip)
    local obj = {
        id = id,
        coords = vector4(coords.x, coords.y, coords.z, coords.w),
        model = model,
        entityType = entityType,
        blipData = blip,
    }

    setmetatable(obj, self)
    activeShopObjs[id] = obj
    obj:createShop()
    return obj
end

function ShopObj:createShop()
    if self.blipData then self.blip = Bridge.Utility.CreateBlip(self.coords, self.blipData.id, self.blipData.color, self.blipData.scale, self.blipData.label, true, 2) end
    Bridge.Entity.Create({
        id = self.id,
        entityType = self.entityType,
        model = self.model,
        coords = self.coords,
        heading = self.coords.w,
        spawnDistance = 100,
        OnSpawn = function(entityData)
            SetEntityInvincible(entityData.spawned, true)
            FreezeEntityPosition(entityData.spawned, true)
            self.entity = entityData.spawned
            self.target = Bridge.Target.AddLocalEntity(entityData.spawned, {
                {
                    name = self.id,
                    label = locale("Targets.FarmersMarketLabel"),
                    icon = locale("Targets.FarmersMarketIcon"),
                    color = locale("Targets.FarmersMarketColor"),
                    distance = 3,
                    onSelect = function()
                        GenerateFarmersMarketMenus(self.id)
                    end
                },
            })
        end,
        OnRemove = function(entityData)
            if not entityData.spawned then return end
            Bridge.Target.RemoveLocalEntity(entityData.spawned)
            self.entity = nil
            self.target = nil
        end
    })
end

local function inputSellAmount(id, itemName, itemLabel)
    local itemCount = Bridge.Inventory.GetItemCount(itemName)
    if not itemCount or itemCount <= 0 then return Bridge.Notify.SendNotify(locale("FarmersMarket.noproducts", itemLabel), "error", 3000) end
    local menuName = Bridge.Input.GetResourceName()
    local min = 1
    if menuName == "lation_ui" and (itemCount == 1) then min = 0 end
    local input = Bridge.Input.Open(itemLabel, {
        { type = 'slider', label = locale("FarmersMarket.AmountToSell"), min = min, max = itemCount, step = 1 },
	}, false)
	if not input or not input[1] then return end
    if tonumber(input[1]) <= 0 then return end
    TriggerServerEvent("MrNewbFarmersMarket:Server:SellToMarket", id, itemName, input[1])
end

function GenerateFarmersMarketMenus(id)
    local menuOptions = {
        {
            title = id,
            description = locale("FarmersMarket.Description"),
            icon = locale("FarmersMarket.MenuIcon"),
            iconColor = locale("FarmersMarket.color"),
        },
    }
    for k, v in pairs(Config.FarmersMarket.Markets[id].shopItems) do
        local itemInfo = Bridge.Inventory.GetItemInfo(k)
        table.insert(menuOptions, {
            title = locale("FarmersMarket.sellitem", itemInfo.label, v),
            description = locale("FarmersMarket.sellmenu"),
            --icon = "fa-solid fa-dollar-sign",
            icon = itemInfo.image,
            iconColor = locale("FarmersMarket.color"),
            onSelect = function()
                inputSellAmount(id, k, itemInfo.label)
            end
        })
    end
    local menuID = Bridge.Ids.RandomLower(nil, 8)
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("FarmersMarket.Title"), options = menuOptions }, false)
end

function ShopObj:destroy()
    if self.model then Bridge.Entity.Destroy(self.id) end
    if self.target then Bridge.Target.RemoveLocalEntity(self.entity) end
    if self.blip then Bridge.Utility.RemoveBlip(self.blip) end
end

-- -- for my tests and stuff
-- CreateThread(function()
--     if not Config.FarmersMarket.Enabled then return end
--     for k, v in pairs(Config.FarmersMarket.Markets) do
--         ShopObj:new(k, v.coords, v.entityType, v.model, v.blip)
--     end
-- end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not Config.FarmersMarket.Enabled then return end
    for _, ShopObj in pairs(activeShopObjs) do
        ShopObj:destroy()
    end
end)

AddEventHandler('community_bridge:Client:OnPlayerLoaded', function()
    if not Config.FarmersMarket.Enabled then return end
    for k, v in pairs(Config.FarmersMarket.Markets) do
        ShopObj:new(k, v.coords, v.entityType, v.model, v.blip)
    end
end)

AddEventHandler("community_bridge:Client:OnPlayerUnload", function()
    if not Config.FarmersMarket.Enabled then return end
    for _, ShopObj in pairs(activeShopObjs) do
        ShopObj:destroy()
    end
end)