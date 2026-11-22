function NotifyFail(src, key, ...)
    bridge.notifications.notify(src, { description = locale(key, ...), type = 'error', duration = 3000 })
    return false
end

function IsOnCooldown(lastUseBySource, src)
    local now = GetGameTimer()
    if lastUseBySource[src] and now - lastUseBySource[src] < 1000 then return true end
    lastUseBySource[src] = now
    return false
end

function ParseWholeNumber(value, maxValue)
    local number = tonumber(value)
    if not number or number % 1 ~= 0 or number < 1 or number > maxValue then return end
    return number
end
