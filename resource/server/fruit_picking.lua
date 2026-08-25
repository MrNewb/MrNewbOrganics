local harvestLocations = {}

local function registerHarvestLocation(plantType, locationIndex, locationCoords, plantData)
    if type(plantType) ~= 'string' then return end
    if type(locationCoords) ~= 'vector4' and type(locationCoords) ~= 'table' then return end

    local rewardItem = plantData.rewardItem
    if type(rewardItem) ~= 'table' or type(rewardItem.item) ~= 'string' or rewardItem.item == '' then return end

    local rewardCount = math.floor(tonumber(rewardItem.count) or 1)
    if rewardCount < 1 then return end

    local harvestId = ('%s_%s'):format(plantType, locationIndex)
    harvestLocations[harvestId] = {
        coords = vector3(locationCoords.x, locationCoords.y, locationCoords.z),
        itemName = rewardItem.item,
        itemCount = rewardCount,
        metadata = rewardItem.metadata,
        lastHarvest = {},
    }
end

local function giveHarvestReward(src, harvestLocation)
    local playerPed = GetPlayerPed(src)
    if playerPed == 0 or not DoesEntityExist(playerPed) then return end
    if #(GetEntityCoords(playerPed) - harvestLocation.coords) > 5.0 then return end

    local identifier = bridge.framework.getIdentifier(src)
    if not identifier then return end

    local now = os.time()
    local lastHarvest = harvestLocation.lastHarvest[identifier] or 0
    if now - lastHarvest < 60 then return end

    if bridge.inventory.canCarryItem and not bridge.inventory.canCarryItem(src, harvestLocation.itemName, harvestLocation.itemCount) then
        return bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughSpace'), type = 'error' })
    end

    harvestLocation.lastHarvest[identifier] = now
    if not bridge.inventory.addItem(src, harvestLocation.itemName, harvestLocation.itemCount, harvestLocation.metadata) then
        harvestLocation.lastHarvest[identifier] = lastHarvest
    end
end

RegisterNetEvent('MrNewbOrganics:Server:PickPlant', function(harvestId)
    local src = source
    local playerPed = GetPlayerPed(src)
    if playerPed == 0 or not DoesEntityExist(playerPed) then return end
    if type(harvestId) ~= 'string' or harvestId == '' or #harvestId > 64 then return end

    local harvestLocation = harvestLocations[harvestId]
    if not harvestLocation then return end

    giveHarvestReward(src, harvestLocation)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)

    for plantType, plantData in pairs(Config.PickingTypes or {}) do
        if type(plantData) == 'table' then
            for locationIndex, locationCoords in ipairs(plantData.locations or {}) do
                registerHarvestLocation(plantType, locationIndex, locationCoords, plantData)
            end
        end
    end
end)
