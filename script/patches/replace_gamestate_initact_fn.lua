local patch_id = "REPLACE_GAMESTATE_INITACT_FN"
if not rawget(_G, patch_id) then
    rawset(_G, patch_id, true)
    print("Loaded patch:"..patch_id)
    GameState.InitializeAct = function(self)
        engine.inst:ProfilerPush("InitializeAct")

        local params = require"CharacterRandomizer:settings"
        params.last_seed = nil
    
        self.current_act = self.options.start_act
        local act_data = GetPlayerActData( self.current_act )
     
        self.notifications:EnableNotifications( false )
    
        act_data:InitializeAct( self, self.options and self.options.custom)

        local region_id = act_data.data.world_region   
        self.world_region_id = region_id
    
        local world_region = Content.GetWorldRegion(region_id)
        assert(world_region, region_id)
        
        self.region = Region(region_id)
        self.region:PopulateGameState( self )
    
        local max_resolve = act_data.data.max_resolve or self.player_agent.max_resolve
        if max_resolve then
            local advancement_mod = GetAdvancementModifier( ADVANCEMENT_OPTION.LOWER_MAX_RESOLVE )
            if advancement_mod then
                max_resolve = math.round(max_resolve * advancement_mod)
            end
            self.caravan:SetMaxResolve( max_resolve )
        end
    
        self:UpdateWorld()
    
        if not self.options.no_act_quests then
            self:GetCurrentAct():SpawnQuests( self.options )
        end
        
        self.notifications:Clear()
        self.notifications:EnableNotifications( true )
    
        engine.inst:ProfilerPop()
    end
end