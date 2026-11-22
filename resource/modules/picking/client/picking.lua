local fieldPlants = {}
local fieldZones = {}
local insideFields = {}
local wantedPlants = {}
local registeredPlants = {}
local sphereZones = {}
local pendingBatch = {}

for fieldId, field in pairs(Config.PickingFields) do
    fieldPlants[fieldId] = PickingFieldPlantList(field)
    wantedPlants[fieldId] = {}
    registeredPlants[fieldId] = {}
    sphereZones[fieldId] = {}
end

local function getInteractionId(fieldId, plantIndex)
    return ('MrNewbOrganics:pick:%s:%s'):format(fieldId, plantIndex)
end

local function removePlantSpawn(fieldId, plantIndex)
    wantedPlants[fieldId][plantIndex] = nil
    registeredPlants[fieldId][plantIndex] = nil

    local sphereId = sphereZones[fieldId][plantIndex]
    if sphereId then
        bridge.target.removeZone(sphereId)
        sphereZones[fieldId][plantIndex] = nil
        return
    end

    exports[bridge.name]:RemoveInteraction(getInteractionId(fieldId, plantIndex))
end

local function clearFieldSpawns(fieldId)
    exports[bridge.name]:CancelInteractionBatch()
    pendingBatch[fieldId] = nil
    for plantIndex in pairs(registeredPlants[fieldId] or {}) do
        removePlantSpawn(fieldId, plantIndex)
    end
    wantedPlants[fieldId] = {}
    registeredPlants[fieldId] = {}
    sphereZones[fieldId] = {}
end

local function harvestPlant(fieldId, plantIndex)
    local plant = fieldPlants[fieldId][plantIndex]
    local typeData = Config.PickingTypes[plant.plantType]
    local animation = typeData.anim

    if not bridge.progressbar.openprogressbar({
        duration = 5000,
        label = locale('Targets.picklabel'),
        disable = { move = true, combat = true },
        anim = animation and { dict = animation.dict, clip = animation.name, flag = animation.flag },
        canCancel = true,
    }) then
        return bridge.notifications.notify({ description = locale('Warnings.Canceled'), type = 'error' })
    end

    local picked, failReason = lib.callback.await('MrNewbOrganics:server:pickedPlant', false, fieldId, plantIndex)
    if picked then
        removePlantSpawn(fieldId, plantIndex)
    elseif failReason and failReason ~= '' then
        bridge.notifications.notify({ description = locale(failReason), type = 'error' })
    end
end

local function plantStillWanted(fieldId, plantIndex)
    return wantedPlants[fieldId][plantIndex] == true
end

local function pickOption(fieldId, plantIndex)
    return {
        label = locale('Targets.picklabel'),
        icon = locale('Targets.pickicon'),
        distance = 3.0,
        canInteract = function()
            return plantStillWanted(fieldId, plantIndex)
        end,
        onSelect = function()
            harvestPlant(fieldId, plantIndex)
        end,
    }
end

local function addPlantSphere(fieldId, plantIndex, plant)
    if sphereZones[fieldId][plantIndex] then return end

    local zoneRadius = plant.coords.w
    if zoneRadius < 0.5 or zoneRadius > 8.0 then
        zoneRadius = 1.5
    end

    sphereZones[fieldId][plantIndex] = bridge.target.addSphereZone({
        coords = vector3(plant.coords.x, plant.coords.y, plant.coords.z),
        radius = zoneRadius,
        options = { pickOption(fieldId, plantIndex) },
    })
    registeredPlants[fieldId][plantIndex] = true
end

local function addPlantProp(fieldId, plantIndex, plant, typeData)
    registeredPlants[fieldId][plantIndex] = true
    return {
        id = getInteractionId(fieldId, plantIndex),
        payload = {
            model = typeData.propModel,
            coords = vector3(plant.coords.x, plant.coords.y, plant.coords.z),
            heading = plant.coords.w,
            radius = 80.0,
            snapToGround = true,
            onEnter = function()
                return plantStillWanted(fieldId, plantIndex)
            end,
            canSpawn = function()
                return plantStillWanted(fieldId, plantIndex)
            end,
            options = { pickOption(fieldId, plantIndex) },
            onSpawn = function(interaction)
                local entity = interaction.entity
                if not entity or not DoesEntityExist(entity) then return end
                SetEntityInvincible(entity, true)
                FreezeEntityPosition(entity, true)
            end,
        },
    }
end

local function finishFieldBatch(fieldId)
    local queued = pendingBatch[fieldId]
    pendingBatch[fieldId] = nil
    if not queued then return end
    for queueIndex = 1, #queued do
        local plantIndex = queued[queueIndex]
        if not wantedPlants[fieldId][plantIndex] then
            exports[bridge.name]:RemoveInteraction(getInteractionId(fieldId, plantIndex))
        end
    end
end

local function spawnFieldPlants(fieldId, plantIndexes)
    clearFieldSpawns(fieldId)

    local plants = fieldPlants[fieldId]
    local batch = {}
    local queued = {}
    for index = 1, #plantIndexes do
        local plantIndex = plantIndexes[index]
        local plant = plants[plantIndex]
        if plant then
            local typeData = Config.PickingTypes[plant.plantType]
            wantedPlants[fieldId][plantIndex] = true
            if typeData.propModel then
                queued[#queued + 1] = plantIndex
                batch[#batch + 1] = addPlantProp(fieldId, plantIndex, plant, typeData)
            else
                addPlantSphere(fieldId, plantIndex, plant)
            end
        end
    end

    if #batch < 1 then return end
    pendingBatch[fieldId] = queued
    exports[bridge.name]:AddInteractionsBatch(batch, {
        batchSize = 25,
        onComplete = function()
            finishFieldBatch(fieldId)
        end,
    })
end

local function spawnRestoredPlants(fieldId, plantIndexes)
    if not insideFields[fieldId] then return end

    local plants = fieldPlants[fieldId]
    for index = 1, #plantIndexes do
        local plantIndex = plantIndexes[index]
        local plant = plants[plantIndex]
        if plant and not wantedPlants[fieldId][plantIndex] then
            local typeData = Config.PickingTypes[plant.plantType]
            wantedPlants[fieldId][plantIndex] = true
            if typeData.propModel then
                local entry = addPlantProp(fieldId, plantIndex, plant, typeData)
                exports[bridge.name]:AddInteraction(entry.id, entry.payload)
            else
                addPlantSphere(fieldId, plantIndex, plant)
            end
        end
    end
end

local function enterPickingField(fieldId)
    if insideFields[fieldId] then return end
    insideFields[fieldId] = true

    local plantIndexes = lib.callback.await('MrNewbOrganics:server:enteredField', false, fieldId)
    if not plantIndexes or not insideFields[fieldId] then return end
    spawnFieldPlants(fieldId, plantIndexes)
end

local function leavePickingField(fieldId)
    if not insideFields[fieldId] then return end
    insideFields[fieldId] = nil
    clearFieldSpawns(fieldId)
    TriggerServerEvent('MrNewbOrganics:server:leftField', fieldId)
end

local function registerFieldZone(fieldId, zone)
    if zone.points then
        fieldZones[fieldId] = lib.zones.poly({
            points = zone.points,
            thickness = zone.thickness,
            onEnter = function() enterPickingField(fieldId) end,
            onExit = function() leavePickingField(fieldId) end,
        })
        return
    end

    fieldZones[fieldId] = lib.zones.sphere({
        coords = zone.coords,
        radius = zone.radius,
        onEnter = function() enterPickingField(fieldId) end,
        onExit = function() leavePickingField(fieldId) end,
    })
end

local function plantRemoved(fieldId, plantIndex)
    if source ~= 65535 or not insideFields[fieldId] then return end
    removePlantSpawn(fieldId, plantIndex)
end

local function plantsRestored(fieldId, plantIndexes)
    if source ~= 65535 then return end
    spawnRestoredPlants(fieldId, plantIndexes)
end

RegisterNetEvent('MrNewbOrganics:client:plantRemoved', plantRemoved)
RegisterNetEvent('MrNewbOrganics:client:plantsRestored', plantsRestored)

CreateThread(function()
    for fieldId, field in pairs(Config.PickingFields) do
        registerFieldZone(fieldId, field.zone)
    end
end)

AddEventHandler('Newb_Bridge:client:playerLoaded', function()
    local playerCoords = GetEntityCoords(cache.ped)
    for fieldId, zone in pairs(fieldZones) do
        if zone:contains(playerCoords) then
            enterPickingField(fieldId)
        end
    end
end)

AddEventHandler('Newb_Bridge:client:playerUnloaded', function()
    for fieldId in pairs(insideFields) do
        leavePickingField(fieldId)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end
    exports[bridge.name]:CancelInteractionBatch()
    for fieldId in pairs(insideFields) do
        clearFieldSpawns(fieldId)
        insideFields[fieldId] = nil
    end
end)
