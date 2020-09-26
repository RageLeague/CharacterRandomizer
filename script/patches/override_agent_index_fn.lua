local patch_id = "OVERRIDE_AGENT_INDEX_FN"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local fields_that_use_original = {
    "faction_id",
}
local old_index_fn = Agent.__index
Agent.__index = function(self, k)

    if rawget(self, "original_agent") and rawget(self, "original_data") then
        if table.arraycontains(fields_that_use_original, k) then -- does not check retain faction, because it will break Rook's campaign
            return old_index_fn(self.original_agent, k)
        end
    end
    return old_index_fn(self, k)
end
