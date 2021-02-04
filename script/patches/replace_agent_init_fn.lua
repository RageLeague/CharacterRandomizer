local patch_id = "REPLACE_AGENT_INIT_FN"
if not rawget(_G, patch_id) then
    rawset(_G, patch_id, true)
    print("Loaded patch:"..patch_id)
    -- local replacement = {}
    local old_fn = Agent.init
    Agent.init = function(self, content_id, skin_table)
        local replacement = {}
        local original_def = Content.GetCharacterDef( content_id )
        TheGame:BroadcastEvent("init_swap_agent", replacement, content_id, skin_table)
        local new_skin = skin_table
        local new_id = content_id
        if replacement.new_content_id then
            new_id = replacement.new_content_id
        end
        if replacement.new_skin then
            new_skin = replacement.new_skin
        elseif replacement.new_skin == false or replacement.new_uuid == false then
            new_skin = nil
        elseif replacement.new_uuid then
            new_skin = Content.GetCharacterSkin(replacement.new_uuid)
        end
        
        if content_id ~= new_id or (skin_table and skin_table.uuid) ~= (new_skin and new_skin.uuid) then
            print(loc.format("Expected {1}:{2}, but actually created {3}:{4} lol", content_id, skin_table and skin_table.uuid, new_id, new_skin and new_skin.uuid))
        end

        old_fn(self, new_id, new_skin)

        -- if replacement.new_skin_overrides then
        --     self.def:PushProperties( replacement.new_skin_overrides )
        -- end
        if replacement.disguise_agent then
            self.disguise_agent = replacement.disguise_agent
            self.disguise_data = {content_id = self.disguise_agent:GetContentID(), uuid = self.disguise_agent:GetSkinID()}
            self.voice_actor = self.disguise_agent.voice_actor
            if replacement.params then
                local p = replacement.params
                local fields = {"disguise_loc_table", "disguise_portrait", "disguise_faction", "use_new_anim"}
                for i, id in ipairs(fields) do
                    if p[id] then
                        self.disguise_data[id] = true
                    end
                end
            end
        end

        local original_alias = original_def.alias or (skin_table and skin_table.alias)
        -- print("This agent's original alias: " .. (original_alias or "nil"))
        if original_alias then
            self.alias = original_alias
            -- self.def:PushProperties(original_def.alias)
        else
            self.null_fields = self.null_fields or {}
            self.null_fields.alias = true
            self.alias = nil
        end
        if new_id ~= content_id or skin_table ~= new_skin then
            self.original_agent = Agent.CreateDummyAgent(content_id, skin_table)
            self.original_data = {content_id = self.original_agent:GetContentID(), uuid = self.original_agent:GetSkinID()}
            if replacement.params then
                local p = replacement.params
                local fields = {"retain_content_id", "retain_strength", "retain_faction"}
                for i, id in ipairs(fields) do
                    if p[id] then
                        self.original_data[id] = true
                    end
                end
            end
        end
        -- Gotta keep this here to remove the appropriate skin from existing tables.
        if skin_table ~= new_skin then
            self.original_skin = skin_table
        end
        -- print("This agent's current alias: " .. (self.alias or "nil"))
        -- print(self:GetBaseBuild())
    end
    local old_query_fn = Agent.GetContentID
    Agent.GetContentID = function(self)
        return self.original_data and self.original_data.retain_content_id and  
            self.original_data.content_id or old_query_fn(self)
    end
    local old_renown_fn = Agent.GetRenown
    Agent.GetRenown = function(self)
        if self.original_agent and self.original_data and self.original_data.retain_strength then
            return old_renown_fn(self.original_agent)
        end
        return old_renown_fn(self)
    end
    local old_strength_fn = Agent.GetCombatStrength
    Agent.GetCombatStrength = function(self)
        if self.original_agent and self.original_data and self.original_data.retain_strength then
            return old_strength_fn(self.original_agent) + (self.combat_strength_modifier or 0)
        end
        return old_strength_fn(self)
    end
end