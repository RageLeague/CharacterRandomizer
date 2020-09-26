local patch_id = "DISGUISE_AGENT_LOC_TABLE"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local oldfn = Agent.GenerateLocTable

Agent.GenerateLocTable = function(self)
    if self.disguise_agent and self.disguise_data and self.disguise_data.disguise_loc_table then
        oldfn(self.disguise_agent)
        self.loc_table = self.disguise_agent.loc_table
        self:BroadcastEvent( "loc_changed", self )
    else
        oldfn(self)
    end
end