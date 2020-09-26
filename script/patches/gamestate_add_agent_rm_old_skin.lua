local patch_id = "GAMESTATE_ADD_AGENT_RM_OLD_SKIN"
if not rawget(_G, patch_id) then
    rawset(_G, patch_id, true)
    print("Loaded patch:"..patch_id)
    local old_fn = GameState.AddAgent
    GameState.AddAgent = function(self, agent)
        local result = old_fn(self,agent)
        agent.original_skin = nil
        return result
    end
    local old_skin_fn = Agent.GetSkinID
    Agent.GetSkinID = function(self)
        return self.original_skin and self.original_skin.uuid or old_skin_fn(self)
    end
end