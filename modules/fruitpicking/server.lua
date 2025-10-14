---@diagnostic disable: duplicate-set-field
local activeLocationObjs = {}
LocationObj = {}
LocationObj.__index = LocationObj

function LocationObj:new(_type, locationIndex, locationCoords, plantData)
    local uniqueId = _type .. "_" .. locationIndex
    local obj = {
        id = uniqueId,
        plantType = _type,
        coords = locationCoords,
        rewardItem = plantData.rewardItem,
        cooldowns = {}
    }

    setmetatable(obj, self)
    activeLocationObjs[uniqueId] = obj
    return obj
end

function LocationObj:verifyEligible(src)
    local identifier = Bridge.Framework.GetPlayerIdentifier(src)
    if self.cooldowns[identifier] then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local pedCoords = GetEntityCoords(ped)
    local locationCoords = vector3(self.coords.x, self.coords.y, self.coords.z)
    local distance = #(pedCoords - locationCoords)
    if distance >= 10.0 then return false end
    self:processCooldown(src)
    Bridge.Inventory.AddItem(src, self.rewardItem.item, self.rewardItem.count or 1, nil, self.rewardItem.metadata or {})
end

function LocationObj:processCooldown(src)
    local identifier = Bridge.Framework.GetPlayerIdentifier(src)
    self.cooldowns[identifier] = true
    SetTimeout(60000, function()
        if self.cooldowns[identifier] then self.cooldowns[identifier] = nil end
    end)
end

RegisterNetEvent("MrNewbPicking:Server:PickPlant", function(id)
    local src = source
    if not id or not activeLocationObjs[id] then return end
    local locationObj = activeLocationObjs[id]
    locationObj:verifyEligible(src)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for plantType, data in pairs(Config.PickingTypes) do
        for locationIndex, locationCoords in ipairs(data.locations) do
            LocationObj:new(plantType, locationIndex, locationCoords, data)
        end
    end
end)