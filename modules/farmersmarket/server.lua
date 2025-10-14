---@diagnostic disable: duplicate-set-field
local activeShopObjs = {}
ShopObj = {}
ShopObj.__index = ShopObj

function ShopObj:new(id, coords, shopItems)
    local obj = {
        id = id,
        coords = vector4(coords.x, coords.y, coords.z, coords.w),
        shopItems = shopItems,
    }

    setmetatable(obj, self)
    activeShopObjs[id] = obj
    return obj
end

function ShopObj:sellItem(src, item, count)
    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)
    if #(playerCoords - vector3(self.coords.x, self.coords.y, self.coords.z)) > 5.0 then
        return false, Bridge.Notify.SendNotify(src, locale("FarmersMarket.toofar"), "error", 3000)
    end
    local shopData = self.shopItems[item]
    if not shopData then return false, Bridge.Notify.SendNotify(src, locale("FarmersMarket.notsolditem"), "error", 3000) end
    local itemCount = Bridge.Inventory.GetItemCount(src, item, nil)
    if itemCount < count then return false, Bridge.Notify.SendNotify(src, locale("FarmersMarket.noproducts", item), "error", 3000) end
    local totalPrice = shopData * count
    local removed = Bridge.Inventory.RemoveItem(src, item, count, nil)
    if not removed then return false, Bridge.Notify.SendNotify(src, locale("FarmersMarket.error"), "error", 3000) end
    return true, Bridge.Framework.AddAccountBalance(src, "bank", totalPrice)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not Config.FarmersMarket.Enabled then return end
    for k, v in pairs(Config.FarmersMarket.Markets) do
        ShopObj:new(k, v.coords, v.shopItems)
    end
end)

RegisterNetEvent("MrNewbFarmersMarket:Server:SellToMarket", function(id, itemName, count)
    local src = source
    local shop = activeShopObjs[id]
    if not shop then return end
    if count <= 0 then return end
    shop:sellItem(src, itemName, count)
end)