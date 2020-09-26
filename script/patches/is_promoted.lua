function AgentUtil.IsPromoted( def )

    if type(def) == "string" then
        def = Content.GetCharacterDef(def)
    elseif type(def) == "table" and def.agent_def then
        def = def.agent_def -- Don't use GetContentID. The behaviour is modified in my mod CharacterRandomizer.
    end

    local base_def = def.base_def and Content.GetCharacterDef( def.base_def )
    if base_def and base_def.promotion_def == def.id then
        -- This is a promoted def, but is not permitted at this advancement.
        return true 
    end
    return false
end