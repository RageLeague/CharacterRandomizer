local patch_id = "ADD_AGENT_NULL_INDEX_FIELD"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

-- local fields_that_use_original = {
--     "faction_id",
-- }
local old_index_fn = Agent.__index
Agent.__index = function(self, k)

    if k == "null_fields" then return nil end
    if rawget(self, "null_fields") and rawget(self, "null_fields")[k] then return nil end
    -- if rawget(self, "original_agent") and rawget(self, "original_data") 
    --     and self.original_data.retain_faction and table.arraycontains(fields_that_use_original, k) then

    --     return old_index_fn(self.original_agent, k)
    -- end
    return old_index_fn(self, k)
end
