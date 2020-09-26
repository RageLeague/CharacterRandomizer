local patch_id = "OBFUSCATE_BOONS"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local old_boon_fn = Widget.AgentSocialGraft.Refresh
Widget.AgentSocialGraft.Refresh = function(self, graft)
    local data = {}
    TheGame:BroadcastEvent("get_social_unlocks", data)
    if data.data ~= nil then
        return old_boon_fn(self, data.data and graft or nil)
    end
    return old_boon_fn(self, graft)
end
local old_rel_fn = Widget.RelationshipsScreenBoon.Refresh
Widget.RelationshipsScreenBoon.Refresh = function(self, boon, active, agent)
    if active then
        return old_rel_fn(self, boon, active, agent)
    end
    local data = {}
    TheGame:BroadcastEvent("get_social_unlocks", data)
    if data.data ~= nil then
        return old_rel_fn(self, data.data and boon or nil, active, agent)
    end
    return old_rel_fn(self, boon, active, agent)
end
-- local old_bane_fn = GameProfile.HasUnlockedBane
-- GameProfile.HasUnlockedBane = function(self, skin_id)
--     local data = {}
--     TheGame:BroadcastEvent("get_social_unlocks", data)
--     if data.data ~= nil then
--         return data.data
--     end
--     return old_bane_fn(self, skin_id)
-- end

local old_loot_fn = Widget.AgentDeathLoot.Refresh
Widget.AgentDeathLoot.Refresh = function(self, agent)
    local data = {}
    TheGame:BroadcastEvent("get_social_unlocks", data)
    
    if data.data ~= nil and not data.data then
        return old_loot_fn(self, nil)
    end 
    
    return old_loot_fn(self,agent)
end