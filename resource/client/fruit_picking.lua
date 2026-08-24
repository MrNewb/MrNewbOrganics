local spawnedHarvests = {}
local harvestBlips = {}

local function createHarvestBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 280)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipCategory(blip, 9)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('Blips.pickblip'))
    EndTextCommandSetBlipName(blip)
    return blip
end

local function playHarvestAnimation(animation)
    if type(animation) ~= 'table' or type(animation.dict) ~= 'string' or type(animation.name) ~= 'string' then return end

    lib.requestAnimDict(animation.dict)
    local duration = GetAnimDuration(animation.dict, animation.name) * 1000
    if duration < 1 then duration = 5000 end

    TaskPlayAnim(cache.ped, animation.dict, animation.name, 8.0, -8.0, -1, animation.flag or 1, 0.0, false, false, false)
    Wait(duration)
    StopAnimTask(cache.ped, animation.dict, animation.name, 1.0)
    RemoveAnimDict(animation.dict)
end

local function harvestThisPlant(harvest)
    if harvest.onCooldown then return end

    playHarvestAnimation(harvest.animation)
    TriggerServerEvent('MrNewbOrganics:Server:PickPlant', harvest.id)

    harvest.onCooldown = true
    SetTimeout(60000, function()
        harvest.onCooldown = false
    end)
end

local function addHarvestProp(harvest)
    exports[bridge.name]:AddInteraction(('mrnewb_organics_pick_%s'):format(harvest.id), {
        model = harvest.propModel,
        coords = vector3(harvest.coords.x, harvest.coords.y, harvest.coords.z),
        heading = harvest.coords.w or 0.0,
        radius = 50.0,
        snapToGround = true,
        options = {
            {
                label = locale('Targets.picklabel'),
                icon = locale('Targets.pickicon'),
                distance = 3.0,
                canInteract = function()
                    return not harvest.onCooldown
                end,
                onSelect = function()
                    harvestThisPlant(harvest)
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
end

local function addHarvestZone(harvest)
    local zoneRadius = harvest.coords.w
    if type(zoneRadius) ~= 'number' or zoneRadius < 0.5 then
        zoneRadius = 1.5
    end

    harvest.zoneId = bridge.target.addSphereZone({
        coords = vector3(harvest.coords.x, harvest.coords.y, harvest.coords.z),
        radius = zoneRadius,
        options = {
            {
                label = locale('Targets.picklabel'),
                icon = locale('Targets.pickicon'),
                distance = 3.0,
                canInteract = function()
                    return not harvest.onCooldown
                end,
                onSelect = function()
                    harvestThisPlant(harvest)
                end,
            },
        },
    })
end

local function spawnHarvestLocation(plantType, locationIndex, locationCoords, plantData)
    local harvestId = ('%s_%s'):format(plantType, locationIndex)
    if spawnedHarvests[harvestId] then return end
    if type(locationCoords) ~= 'vector4' and type(locationCoords) ~= 'table' then return end

    local harvest = {
        id = harvestId,
        coords = locationCoords,
        animation = plantData.anim,
        propModel = plantData.propModel,
        onCooldown = false,
    }

    spawnedHarvests[harvestId] = harvest
    if locationIndex == 1 then
        harvestBlips[harvestId] = createHarvestBlip(locationCoords)
    end

    if harvest.propModel then
        addHarvestProp(harvest)
        return
    end

    addHarvestZone(harvest)
end

local function spawnHarvestLocations()
    for plantType, plantData in pairs(Config.PickingTypes or {}) do
        if type(plantData) == 'table' then
            for locationIndex, locationCoords in ipairs(plantData.locations or {}) do
                spawnHarvestLocation(plantType, locationIndex, locationCoords, plantData)
            end
        end
    end
end

local function removeHarvestLocations()
    for harvestId, harvest in pairs(spawnedHarvests) do
        if harvest.propModel then
            exports[bridge.name]:RemoveInteraction(('mrnewb_organics_pick_%s'):format(harvestId))
        elseif harvest.zoneId then
            bridge.target.removeZone(harvest.zoneId)
        end
        spawnedHarvests[harvestId] = nil
    end

    for harvestId, blip in pairs(harvestBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        harvestBlips[harvestId] = nil
    end
end

AddEventHandler('Newb_Bridge:client:playerLoad', spawnHarvestLocations)
AddEventHandler('Newb_Bridge:client:playerUnload', removeHarvestLocations)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    removeHarvestLocations()
end)

CreateThread(function()
    Wait(500)
    if next(spawnedHarvests) then return end
    spawnHarvestLocations()
end)
