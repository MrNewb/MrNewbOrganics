local fieldState = {}
local lastPickAt = {}

local function getRestoreSeconds(field)
    return field.restoreSeconds or Config.PickingRestoreSeconds
end

local function isPlayerInField(src, state)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end

    local coordinates = GetEntityCoords(ped)
    local zone = state.zone
    if zone.points then
        return PickingPointInsidePolygon(zone.points, coordinates.x, coordinates.y)
    end
    return #(coordinates - zone.coords) <= zone.radius + 4.0
end

local function getAvailablePlants(state)
    local now = os.time()
    local restoreSeconds = getRestoreSeconds(state.field)
    local available = {}
    for plantIndex = 1, #state.plants do
        local pickedAt = state.plants[plantIndex].pickedAt
        if not pickedAt or now - pickedAt >= restoreSeconds then
            available[#available + 1] = plantIndex
        end
    end
    return available
end

local function buildFields()
    for fieldId, field in pairs(Config.PickingFields) do
        fieldState[fieldId] = {
            field = field,
            zone = field.zone,
            plants = PickingFieldPlantList(field),
            players = {},
        }
    end
end

local function enteredField(src, fieldId)
    if not IsValidId(fieldId) then return {} end

    local state = fieldState[fieldId]
    if not state or not isPlayerInField(src, state) then return {} end

    state.players[src] = true
    return getAvailablePlants(state)
end

local function leftField(fieldId)
    if not IsValidId(fieldId) then return end

    local state = fieldState[fieldId]
    if state then state.players[source] = nil end
end

local function pickedPlant(src, fieldId, plantIndex)
    if not IsValidId(fieldId) then return false end

    local state = fieldState[fieldId]
    if not state then return false end

    plantIndex = ParseWholeNumber(plantIndex, #state.plants)
    if not plantIndex or IsOnCooldown(lastPickAt, src) then return false end
    if not isPlayerInField(src, state) then return false, 'Warnings.TooFar' end

    local plant = state.plants[plantIndex]
    local now = os.time()
    if plant.pickedAt and now - plant.pickedAt < getRestoreSeconds(state.field) then return false, 'Warnings.AlreadyPicked' end
    if #(GetEntityCoords(GetPlayerPed(src)) - vec3(plant.coords.x, plant.coords.y, plant.coords.z)) > 5.0 then
        return false, 'Warnings.TooFar'
    end

    -- mark the plant before the inventory calls yield so two pickers cannot take the same one
    plant.pickedAt = now

    local reward = Config.PickingTypes[plant.plantType].rewardItem
    if not bridge.inventory.canCarryItem(src, reward.item, reward.count) or not bridge.inventory.addItem(src, reward.item, reward.count, reward.metadata) then
        plant.pickedAt = nil
        return false, 'Warnings.NotEnoughSpace'
    end

    lib.logger(src, 'organicsPicked', ('picked %s x%s'):format(reward.item, reward.count))
    for playerSrc in pairs(state.players) do
        TriggerClientEvent('MrNewbOrganics:client:plantRemoved', playerSrc, fieldId, plantIndex)
    end
    return true, ''
end

local function restorePlants()
    local now = os.time()
    for fieldId, state in pairs(fieldState) do
        local restoreSeconds = getRestoreSeconds(state.field)
        local restored = {}
        for plantIndex = 1, #state.plants do
            local pickedAt = state.plants[plantIndex].pickedAt
            if pickedAt and now - pickedAt >= restoreSeconds then
                state.plants[plantIndex].pickedAt = nil
                restored[#restored + 1] = plantIndex
            end
        end
        if #restored > 0 then
            for playerSrc in pairs(state.players) do
                TriggerClientEvent('MrNewbOrganics:client:plantsRestored', playerSrc, fieldId, restored)
            end
        end
    end
end

lib.callback.register('MrNewbOrganics:server:enteredField', enteredField)
lib.callback.register('MrNewbOrganics:server:pickedPlant', pickedPlant)
RegisterNetEvent('MrNewbOrganics:server:leftField', leftField)

CreateThread(function()
    while true do
        Wait(30000)
        restorePlants()
    end
end)

AddEventHandler('playerDropped', function()
    lastPickAt[source] = nil
    for _, state in pairs(fieldState) do
        state.players[source] = nil
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end
    exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)
end)

buildFields()
