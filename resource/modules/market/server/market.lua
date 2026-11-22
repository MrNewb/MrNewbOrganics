local vendors = {}
local lastSaleAt = {}
local MAX_SELL_COUNT = 1000

local function sellProduce(src, vendor, itemName, sellCount)
    local priceEach = vendor.shopItems[itemName]
    if not priceEach then return NotifyFail(src, 'FarmersMarket.notsolditem') end

    local itemInfo = bridge.inventory.getItemInfo(itemName)
    local itemLabel = itemInfo and itemInfo.label or itemName

    if bridge.inventory.getItemCount(src, itemName) < sellCount then return NotifyFail(src, 'FarmersMarket.noproducts', itemLabel) end
    if not bridge.inventory.removeItem(src, itemName, sellCount) then return NotifyFail(src, 'FarmersMarket.error') end

    local totalPrice = priceEach * sellCount
    if not bridge.framework.addMoney(src, 'bank', totalPrice, 'farmers_market') then
        bridge.inventory.addItem(src, itemName, sellCount)
        return NotifyFail(src, 'FarmersMarket.error')
    end

    lib.logger(src, 'organicsSold', ('sold %sx %s for $%s'):format(sellCount, itemName, totalPrice))
    bridge.notifications.notify(src, { description = locale('FarmersMarket.sold', sellCount, itemLabel, totalPrice), type = 'success', duration = 3000 })
end

local function soldProduce(vendorName, itemName, sellCount)
    local src = source
    if not IsValidId(vendorName) or not IsValidId(itemName) then return end

    sellCount = ParseWholeNumber(sellCount, MAX_SELL_COUNT)
    if not sellCount or IsOnCooldown(lastSaleAt, src) then return end

    local vendor = vendors[vendorName]
    if not vendor then return end

    local ped = GetPlayerPed(src)
    if ped == 0 then return end
    if #(GetEntityCoords(ped) - vendor.coords) > 5.0 then return NotifyFail(src, 'FarmersMarket.toofar') end

    sellProduce(src, vendor, itemName, sellCount)
end

RegisterNetEvent('MrNewbOrganics:server:soldProduce', soldProduce)

AddEventHandler('playerDropped', function()
    lastSaleAt[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end
    if not Config.FarmersMarket.Enabled then return end

    for vendorName, vendor in pairs(Config.FarmersMarket.Markets) do
        vendors[vendorName] = {
            coords = vector3(vendor.coords.x, vendor.coords.y, vendor.coords.z),
            shopItems = vendor.shopItems,
        }
    end
end)
