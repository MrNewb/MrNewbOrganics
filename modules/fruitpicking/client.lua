---@diagnostic disable: duplicate-set-field
local activeLocationObjs = {}
LocationObj = {}
LocationObj.__index = LocationObj

function LocationObj:new(_type, locationIndex, locationCoords, plantData)
    local uniqueId = _type .. "_" .. locationIndex
    local obj = {
        id = uniqueId,
        plantType = _type,
        coords = vector4(locationCoords.x, locationCoords.y, locationCoords.z, locationCoords.w),
        model = plantData.propModel,
        type = _type,
        cooldown = false,
        anim = plantData.anim,
    }

    setmetatable(obj, self)
    activeLocationObjs[uniqueId] = obj
    obj:createTargets()
    return obj
end

function LocationObj:createTargets()
    self.blip = Bridge.Utility.CreateBlip(self.coords, 280, 2, 0.8, locale("Blips.pickblip"), true, 9)
    if self.model then return self:createPropTarget() end
    self:createZoneTarget()
end

function LocationObj:createPropTarget()
    Bridge.Entity.Create({
        id = self.id,
        entityType = "object",
        model = self.model,
        coords = self.coords,
        heading = self.coords.w,
        spawnDistance = 50,
        OnSpawn = function(entityData)
            SetEntityInvincible(entityData.spawned, true)
            FreezeEntityPosition(entityData.spawned, true)
            self.entity = entityData.spawned
            self.target = Bridge.Target.AddLocalEntity(entityData.spawned, {
                {
                    name = self.id,
                    label = locale("Targets.picklabel"),
                    icon = locale("Targets.pickicon"),
                    color = locale("Targets.pickcolor"),
                    distance = 3,
                    canInteract = function()
                        return not self.cooldown
                    end,
                    onSelect = function()
                        self:attemptPick()
                    end
                },
            })
        end,
        OnRemove = function(entityData)
            if not entityData.spawned then return end
            Bridge.Target.RemoveLocalEntity(entityData.spawned)
            self.entity = nil
            self.target = nil
        end
    })
end

function LocationObj:createZoneTarget()
    local options = {
        {
            name = self.id,
            label = locale("Targets.picklabel"),
            icon = locale("Targets.pickicon"),
            color = locale("Targets.pickcolor"),
            distance = 3,
            canInteract = function()
                return not self.cooldown
            end,
            onSelect = function()
                self:attemptPick()
            end
        },
    }
    self.targetzone = Bridge.Target.AddSphereZone(self.id, vector3(self.coords.x, self.coords.y, self.coords.z), self.coords.w, options, false)
end

function LocationObj:attemptPick()
    if self.anim then
        Bridge.Utility.RequestAnimDict(self.anim.dict)
        local animDuration = (GetAnimDuration(self.anim.dict, self.anim.name) * 1000) or 5000
        TaskPlayAnim(PlayerPedId(), self.anim.dict, self.anim.name, 8.0, -8.0, -1, 1, 0, false, false, false)
        Wait(animDuration)
        StopAnimTask(PlayerPedId(), self.anim.dict, self.anim.name, 1.0)
        RemoveAnimDict(self.anim.dict)
    end
    TriggerServerEvent('MrNewbPicking:Server:PickPlant', self.id)
    self.cooldown = true
    SetTimeout(60000, function()
        self.cooldown = false
    end)
end

function LocationObj:destroy()
    if self.model then Bridge.Entity.Destroy(self.id) end
    if self.targetzone then Bridge.Target.RemoveZone(self.id) end
    if self.target then Bridge.Target.RemoveLocalEntity(self.entity) end
    if self.blip then Bridge.Utility.RemoveBlip(self.blip) end
end

-- -- for my tests and stuff
-- CreateThread(function()
--     for plantType, data in pairs(Config.PickingTypes) do
--         for locationIndex, locationCoords in ipairs(data.locations) do
--             LocationObj:new(plantType, locationIndex, locationCoords, data)
--         end
--     end
-- end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, locationObj in pairs(activeLocationObjs) do
        locationObj:destroy()
    end
end)

AddEventHandler('community_bridge:Client:OnPlayerLoaded', function()
    for plantType, data in pairs(Config.PickingTypes) do
        for locationIndex, locationCoords in ipairs(data.locations) do
            LocationObj:new(plantType, locationIndex, locationCoords, data)
        end
    end
end)

AddEventHandler("community_bridge:Client:OnPlayerUnload", function()
    for _, locationObj in pairs(activeLocationObjs) do
        locationObj:destroy()
    end
end)
