local vendors = {}
local maxSellCount = 1000

local function registerVendor(vendorName, vendorData)
    if type(vendorName) ~= 'string' or type(vendorData) ~= 'table' or not vendorData.coords then return end

    local shopItems = {}
    for itemName, price in pairs(vendorData.shopItems or {}) do
        local sellPrice = tonumber(price)
        if type(itemName) == 'string' and sellPrice and sellPrice == sellPrice and sellPrice >= 0 then
            shopItems[itemName] = sellPrice
        end
    end

    vendors[vendorName] = {
        coords = vector3(vendorData.coords.x, vendorData.coords.y, vendorData.coords.z),
        shopItems = shopItems,
    }
end

local function sellProduce(src, vendor, itemName, sellCount)
    local priceEach = vendor.shopItems[itemName]
    if not priceEach then return bridge.notifications.notify(src, { description = locale('FarmersMarket.notsolditem'), type = 'error', duration = 3000 }) end

    local itemInfo = bridge.inventory.getItemInfo(itemName)
    local itemLabel = itemInfo and itemInfo.label or itemName

    if (bridge.inventory.getItemCount(src, itemName) or 0) < sellCount then return bridge.notifications.notify(src, { description = locale('FarmersMarket.noproducts', itemLabel), type = 'error', duration = 3000 }) end
    if not bridge.inventory.removeItem(src, itemName, sellCount) then return bridge.notifications.notify(src, { description = locale('FarmersMarket.error'), type = 'error', duration = 3000 }) end

    local totalPrice = priceEach * sellCount
    if not bridge.framework.addMoney(src, 'bank', totalPrice, 'farmers_market') then
        bridge.inventory.addItem(src, itemName, sellCount)
        bridge.notifications.notify(src, { description = locale('FarmersMarket.error'), type = 'error', duration = 3000 })
        return
    end

    bridge.notifications.notify(src, { description = locale('FarmersMarket.sold', sellCount, itemLabel, totalPrice), type = 'success', duration = 3000 })
end

RegisterNetEvent('MrNewbOrganics:Server:SellToMarket', function(vendorName, itemName, sellCount)
    local src = source
    if type(vendorName) ~= 'string' or vendorName == '' or #vendorName > 64 then return end
    if type(itemName) ~= 'string' or itemName == '' or #itemName > 64 then return end

    sellCount = tonumber(sellCount)
    if not sellCount or sellCount ~= sellCount or sellCount % 1 ~= 0 or sellCount < 1 or sellCount > maxSellCount then return end

    local vendor = vendors[vendorName]
    if not vendor then return end

    local ped = GetPlayerPed(src)
    if ped == 0 or not DoesEntityExist(ped) then return end
    if #(GetEntityCoords(ped) - vendor.coords) > 5.0 then
        return bridge.notifications.notify(src, { description = locale('FarmersMarket.toofar'), type = 'error', duration = 3000 })
    end

    sellProduce(src, vendor, itemName, sellCount)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not Config.FarmersMarket or not Config.FarmersMarket.Enabled then return end

    for vendorName, vendorData in pairs(Config.FarmersMarket.Markets or {}) do
        registerVendor(vendorName, vendorData)
    end
end)
