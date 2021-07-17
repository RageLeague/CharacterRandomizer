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

    if rawget(self, "original_agent") then
        if table.arraycontains(fields_that_use_original, k) then -- does not check retain faction, because it will break Rook's campaign
            return old_index_fn(self.original_agent, k)
        end
    end
    return old_index_fn(self, k)
end

local old_tag_fn = Agent.HasTag

function Agent:HasTag(tag, ...)
    if self.original_agent then
        if self.tags and table.arraycontains(self.tags, tag) then
            return true
        end

        return Agent.HasTag(self.original_agent, tag, ...)
    end
    return old_tag_fn(self, tag, ...)
end

local old_quip_tags = Agent.FillOutQuipTags
function Agent:FillOutQuipTags(tags, ...)
    if self.original_agent then
        table.arrayadd( tags, self.tags )
        if self.original_agent.def and self.original_agent.def.tags then
            table.arrayadd( tags, self.original_agent.def.tags )
        end


        if TheGame:GetGameState() and TheGame:GetGameState():GetPlayerAgent() then
            if TheGame:GetGameState():GetPlayerAgent().player_quip_tag then
                table.insert( tags, TheGame:GetGameState():GetPlayerAgent().player_quip_tag)
            end
        end


        table.insert_unique(tags, self:GetContentID():lower())

        if self:IsUnique() then
            table.insert( tags, self:GetName() )
        end

        local faction_id = self:GetFactionID()
        if faction_id then
            table.insert_unique(tags, faction_id:lower())
        end

        if self.alias then
            table.insert_unique( tags, self.alias:lower() )
        end
        table.insert_unique( tags, self.species:lower() )

        if not self:IsPlayer() then
            local rel = self:GetRelationship()
            -- DO NOT add hated/loved quips: this forces us to write too many categories.
            if rel < RELATIONSHIP.NEUTRAL then
                table.insert_unique( tags, "disliked" )
            elseif rel > RELATIONSHIP.NEUTRAL then
                table.insert_unique( tags, "liked" )
            else
                table.insert_unique( tags, "neutral" )
            end

            if self:IsInPlayerParty() then
                table.insert_unique( tags, "in_party" )
            elseif self:KnowsPlayer() then
                table.insert_unique( tags, "met" )
            end
        end

        if self:IsDead() then
            table.insert_unique(tags, "dead")
        end


        if not TheGame:GetGameState() or TheGame:GetGameState():GetDayPhase() == DAY_PHASE.DAY then
            table.insert_unique( tags, "day" )
        else
            table.insert_unique( tags, "night" )
        end

        if self.location then
            for tag, v in self.location:Tags() do
            table.insert_unique( tags, tag )
            end
            if self.location:GetContent().tags then
                for i, tag in ipairs( self.location:GetContent().tags ) do
                    table.insert_unique( tags, tag )
                end
            end
            if self.location:GetAgentByRole("guard") == self then
                table.insert_unique(tags, "guard")
            end
        end

        if TheGame:GetGameState() then
            local why_event = self.social_connections and self.social_connections:GetRelationshipReason(TheGame:GetGameState():GetPlayerAgent())
            if why_event then
                table.insert_unique(tags, why_event.id)
            end

        end

        for k,v in pairs(self.aspects) do
            if v:IsQuipTag() then
                table.insert_unique(tags, v.id)
            end
        end

        return
    end
    return old_quip_tags(self, tags, ...)
end