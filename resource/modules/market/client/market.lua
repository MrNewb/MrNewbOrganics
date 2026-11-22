local spawnedVendors = {}
local vendorBlips = {}

local function getInteractionId(vendorName)
    return ('mrnewb_organics_market_%s'):format(vendorName:gsub('%s+', '_'):lower())
end

local function createVendorBlip(coords, blipData)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipData.id)
    SetBlipColour(blip, blipData.color)
    SetBlipScale(blip, blipData.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipData.label)
    EndTextCommandSetBlipName(blip)
    if blipData.category then
        AddTextEntry('BLIP_CAT_' .. blipData.category, Config.BlipCategoryLabel)
        SetBlipCategory(blip, blipData.category)
    end
    return blip
end

local function askHowManyToSell(vendorName, itemName, itemLabel, itemCount)
    if itemCount < 1 then
        return bridge.notifications.notify({ description = locale('FarmersMarket.noproducts', itemLabel), type = 'error', duration = 3000 })
    end

    local input = bridge.inputs.inputdialog(itemLabel, {
        { type = 'slider', label = locale('FarmersMarket.AmountToSell'), min = 1, max = itemCount, default = 1, step = 1 },
    })
    if not input or not input[1] then return end

    TriggerServerEvent('MrNewbOrganics:server:soldProduce', vendorName, itemName, input[1])
end

local function openVendorMenu(vendorName)
    local vendor = Config.FarmersMarket.Markets[vendorName]
    local menuOptions = {
        {
            title = vendorName,
            description = locale('FarmersMarket.Description'),
            icon = locale('FarmersMarket.MenuIcon'),
            iconColor = locale('FarmersMarket.color'),
        },
    }

    for itemName, price in pairs(vendor.shopItems) do
        local itemInfo = bridge.inventory.getItemInfo(itemName) or {}
        local itemLabel = itemInfo.label or itemName
        menuOptions[#menuOptions + 1] = {
            title = locale('FarmersMarket.sellitem', itemLabel, price),
            description = locale('FarmersMarket.sellmenu'),
            icon = itemInfo.image or bridge.inventory.getImagePath(itemName),
            iconColor = locale('FarmersMarket.color'),
            onSelect = function()
                askHowManyToSell(vendorName, itemName, itemLabel, bridge.inventory.getItemCount(itemName))
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

    if vendor.blip then
        vendorBlips[vendorName] = createVendorBlip(vendor.coords, vendor.blip)
    end

    exports[bridge.name]:AddInteraction(getInteractionId(vendorName), {
        model = vendor.model,
        coords = vector3(vendor.coords.x, vendor.coords.y, vendor.coords.z),
        heading = vendor.coords.w,
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
    if not Config.FarmersMarket.Enabled then return end

    for vendorName, vendor in pairs(Config.FarmersMarket.Markets) do
        spawnVendor(vendorName, vendor)
    end
end

local function removeVendors()
    for vendorName in pairs(spawnedVendors) do
        exports[bridge.name]:RemoveInteraction(getInteractionId(vendorName))
        spawnedVendors[vendorName] = nil
    end

    for vendorName, blip in pairs(vendorBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
        vendorBlips[vendorName] = nil
    end
end

AddEventHandler('Newb_Bridge:client:playerLoaded', spawnVendors)
AddEventHandler('Newb_Bridge:client:playerUnloaded', removeVendors)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end
    removeVendors()
end)

CreateThread(function()
    Wait(500)
    if next(spawnedVendors) then return end
    spawnVendors()
end)
