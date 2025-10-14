Bridge = exports.community_bridge:Bridge()

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
end

if IsDuplicityVersion() then return end
RegisterNetEvent("community_bridge:Client:OnPlayerUnload")
RegisterNetEvent("community_bridge:Client:OnPlayerLoaded")