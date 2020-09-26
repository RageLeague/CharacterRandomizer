local patch_id = "DISGUISE_AGENT_LOC_TABLE"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local oldfn = Agent.GenerateLocTable

Agent.GenerateLocTable = function(self)
    local old_faction_id = rawget(self, "faction_id")
    if self.original_agent and not (self.original_data and self.original_data.retain_faction) then
        print("old faction id:" .. (self.faction_id or "nil"))
        -- do_swap = true
        -- old_faction_id = 
        rawset(self, "faction_id", self.def.faction_id)
        print("temp faction id:" .. (self.faction_id or "nil"))
    end

    if self.disguise_agent and self.disguise_data and self.disguise_data.disguise_loc_table then
        oldfn(self.disguise_agent)
        self.loc_table = self.disguise_agent.loc_table
        self:BroadcastEvent( "loc_changed", self )
    else
        oldfn(self)
    end

    rawset(self, "faction_id", old_faction_id)
end