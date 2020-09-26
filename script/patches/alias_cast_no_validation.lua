local patch_id = "ALIAS_CAST_NO_VALIDATION"
if not rawget(_G, patch_id) then
    rawset(_G, patch_id, true)
    print("Loaded patch:"..patch_id)
    local old_fn = QuestDef.AddCastByAlias
    QuestDef.AddCastByAlias = function(self, cast)
        -- surpirsed this isn't already done.
        if cast.no_validation == nil then
            cast.no_validation = true
        end
        return old_fn(self, cast)
    end
end