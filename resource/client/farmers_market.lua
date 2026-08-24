local spawnedVendors = {}
local vendorBlips = {}

local function createVendorBlip(coords, blipData)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipData.id or 52)
    SetBlipColour(blip, blipData.color or 2)
    SetBlipScale(blip, blipData.scale or 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipData.label or locale('FarmersMarket.Title'))
    EndTextCommandSetBlipName(blip)
    return blip
end

local function askHowManyToSell(vendorName, itemName, itemLabel, itemCount)
    if itemCount < 1 then
        bridge.notifications.notify({ description = locale('FarmersMarket.noproducts', itemLabel), type = 'error', duration = 3000 })
        return
    end

    local input = bridge.inputs.inputdialog(itemLabel, {
        { type = 'slider', label = locale('FarmersMarket.AmountToSell'), min = 1, max = itemCount, default = 1, step = 1 },
    })
    if not input then return end

    local sellCount = tonumber(input[1])
    if not sellCount or sellCount < 1 then return end

    TriggerServerEvent('MrNewbOrganics:Server:SellToMarket', vendorName, itemName, sellCount)
end

local function openVendorMenu(vendorName)
    local vendor = Config.FarmersMarket and Config.FarmersMarket.Markets and Config.FarmersMarket.Markets[vendorName]
    if not vendor then return end

    local menuOptions = {
        {
            title = vendorName,
            description = locale('FarmersMarket.Description'),
            icon = locale('FarmersMarket.MenuIcon'),
            iconColor = locale('FarmersMarket.color'),
        },
    }

    for itemName, price in pairs(vendor.shopItems or {}) do
        local itemInfo = bridge.inventory.getItemInfo(itemName) or {}
        local itemLabel = itemInfo.label or itemName
        menuOptions[#menuOptions + 1] = {
            title = locale('FarmersMarket.sellitem', itemLabel, price),
            description = locale('FarmersMarket.sellmenu'),
            icon = itemInfo.image or bridge.inventory.getImagePath(itemName),
            iconColor = locale('FarmersMarket.color'),
            onSelect = function()
                askHowManyToSell(vendorName, itemName, itemLabel, bridge.inventory.getItemCount(itemName) or 0)
            end,
        }
    end

    bridge.menu.openMenu({
        id = 'mrnewb_organics_farmers_market',
        title = locale('FarmersMarket.Title'),
        options = menuOptions,
    })
end

local function spawnVendor(vendorName, vendor)
    if spawnedVendors[vendorName] then return end
    if type(vendorName) ~= 'string' or type(vendor) ~= 'table' or not vendor.coords then return end

    if vendor.blip then
        vendorBlips[vendorName] = createVendorBlip(vendor.coords, vendor.blip)
    end

    local vendorCoords = vendor.coords
    exports[bridge.name]:AddInteraction(('mrnewb_organics_market_%s'):format(vendorName:gsub('%s+', '_'):lower()), {
        model = vendor.model,
        coords = vector3(vendorCoords.x, vendorCoords.y, vendorCoords.z),
        heading = vendorCoords.w or 0.0,
        radius = 100.0,
        options = {
            {
                label = locale('Targets.FarmersMarketLabel'),
                icon = locale('Targets.FarmersMarketIcon'),
                distance = 3.0,
                onSelect = function()
                    openVendorMenu(vendorName)
                end,
            },
        },
        onSpawn = function(interaction)
            local entity = interaction.entity
            if not entity or not DoesEntityExist(entity) then return end
            SetEntityInvincible(entity, true)
            FreezeEntityPosition(entity, true)
        end,
    })

    spawnedVendors[vendorName] = true
end

local function spawnVendors()
    if not Config.FarmersMarket or not Config.FarmersMarket.Enabled then return end

    for vendorName, vendor in pairs(Config.FarmersMarket.Markets or {}) do
        spawnVendor(vendorName, vendor)
    end
end

local function removeVendors()
    for vendorName in pairs(spawnedVendors) do
        exports[bridge.name]:RemoveInteraction(('mrnewb_organics_market_%s'):format(vendorName:gsub('%s+', '_'):lower()))
        spawnedVendors[vendorName] = nil
    end

    for vendorName, blip in pairs(vendorBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        vendorBlips[vendorName] = nil
    end
end

AddEventHandler('Newb_Bridge:client:playerLoad', spawnVendors)
AddEventHandler('Newb_Bridge:client:playerUnload', removeVendors)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    removeVendors()
end)

CreateThread(function()
    Wait(500)
    if next(spawnedVendors) then return end
    spawnVendors()
end)
