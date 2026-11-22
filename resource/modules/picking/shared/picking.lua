function PickingPointInsidePolygon(points, x, y)
    local inside = false
    local previousIndex = #points
    for pointIndex = 1, #points do
        local current = points[pointIndex]
        local previous = points[previousIndex]
        if (current.y > y) ~= (previous.y > y) then
            local interceptX = (previous.x - current.x) * (y - current.y) / (previous.y - current.y) + current.x
            if x < interceptX then
                inside = not inside
            end
        end
        previousIndex = pointIndex
    end
    return inside
end

local function zoneCenter(points)
    local sumX, sumY, sumZ = 0.0, 0.0, 0.0
    for pointIndex = 1, #points do
        local point = points[pointIndex]
        sumX = sumX + point.x
        sumY = sumY + point.y
        sumZ = sumZ + point.z
    end
    return vec3(sumX / #points, sumY / #points, sumZ / #points)
end

local function nearestPointZ(points, x, y, fallbackZ)
    if not points then return fallbackZ end
    local bestZ = points[1].z
    local bestDistanceSquared
    for pointIndex = 1, #points do
        local point = points[pointIndex]
        local deltaX = point.x - x
        local deltaY = point.y - y
        local distanceSquared = deltaX * deltaX + deltaY * deltaY
        if not bestDistanceSquared or distanceSquared < bestDistanceSquared then
            bestDistanceSquared = distanceSquared
            bestZ = point.z
        end
    end
    return bestZ
end

local function plantTooClose(plants, x, y)
    for plantIndex = 1, #plants do
        local coordinates = plants[plantIndex].coords
        local deltaX = coordinates.x - x
        local deltaY = coordinates.y - y
        if (deltaX * deltaX) + (deltaY * deltaY) < 16.0 then
            return true
        end
    end
    return false
end

local function appendPlant(plants, coordinates, plantType)
    if #plants >= MAX_FIELD_PLANTS then return end
    plants[#plants + 1] = { coords = coordinates, plantType = plantType }
end

-- coords is one vector or a list of vectors
local function appendListedPlant(plants, plant)
    if plant.coords.x then
        appendPlant(plants, plant.coords, plant.plantType)
        return
    end
    for coordIndex = 1, #plant.coords do
        appendPlant(plants, plant.coords[coordIndex], plant.plantType)
    end
end

function PickingFieldPlantList(field)
    local plants = {}

    for plantIndex = 1, #(field.plants or {}) do
        appendListedPlant(plants, field.plants[plantIndex])
    end

    local grid = field.grid
    if not grid then return plants end

    local zone = field.zone
    local zonePoints = zone.points
    local center = grid.center or zone.coords or zoneCenter(zonePoints)
    local plantType = grid.plantType or field.plantType
    local radius = grid.radius or 80.0
    local rotation = math.rad(grid.rotation or 0.0)
    local spacing = grid.spacing or 8.0
    local maxPoints = math.max(#plants, math.min(MAX_FIELD_PLANTS, math.floor(grid.maxPoints or 64)))
    local columns = math.max(1, math.floor(math.sqrt(maxPoints) + 0.5))
    local cosine = math.cos(rotation)
    local sine = math.sin(rotation)
    local origin = (columns - 1) * 0.5

    for columnIndex = 0, columns - 1 do
        for rowIndex = 0, columns - 1 do
            if #plants >= maxPoints then return plants end
            local localX = (columnIndex - origin) * spacing
            local localY = (rowIndex - origin) * spacing
            local worldX = center.x + localX * cosine - localY * sine
            local worldY = center.y + localX * sine + localY * cosine
            if #(vec3(worldX, worldY, 0.0) - vec3(center.x, center.y, 0.0)) <= radius + 0.01 then
                if not zonePoints or PickingPointInsidePolygon(zonePoints, worldX, worldY) then
                    if not plantTooClose(plants, worldX, worldY) then
                        local worldZ = nearestPointZ(zonePoints, worldX, worldY, center.z)
                        local heading = ((#plants + 1) * 53) % 360
                        appendPlant(plants, vec4(worldX, worldY, worldZ, heading), plantType)
                    end
                end
            end
        end
    end

    return plants
end
