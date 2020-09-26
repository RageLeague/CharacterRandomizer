local patch_id = "DISGUISE_AGENT_PORTRAIT"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local old_fn = Widget.AgentPortrait.SetAgent

Widget.AgentPortrait.SetAgent = function(self, agent)
    if agent and agent.disguise_agent and agent.disguise_data and agent.disguise_data.disguise_portrait then
        return old_fn(self, agent.disguise_agent)
    end
    return old_fn(self, agent)
end