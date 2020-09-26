local patch_id = "CREATE_DUMMY_AGENT"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

-- Creates an agent for query data only. The normal won't work, since, y'know, we overwritten it with our random stuff.
-- And we can't really save it.
-- Still, it contains all the display informations for the agent, except it can't really do anything.
function Agent.CreateDummyAgent(def, skin)
    if type(def) == "string" then
        def = Content.GetCharacterDef(def)
    end
    if type(skin) == "string" then
        skin = Content.GetCharacterSkin(skin)
    end

    local t = {}
    setmetatable(t, {
        __index = function(self, k)
            local v = Agent[ k ]
            if v == nil then
                local aspects = rawget( self, "aspects" )
                v = aspects and aspects[ k ]
            end
            if v == nil then
                local def = rawget( self, "def" )
                v = def and def[k]
            end
            return v
        end,
    })
    -- TheGame:GetDebug():CreatePanel(DebugTable(t))
    t.tags = table.empty
    t.aspects = table.empty
    t.money = 0
    
    t.def = PropertyBag()
    t.def:PushProperties( def )
    t.agent_def = def

    if skin then
        t.def:PushProperties( skin )
        t.skin_def = skin
    end

    -- No skin: run character gen.
    for i = #def.on_inits, 1, -1 do
        def.on_inits[ i ]( t )
    end

    

    return t
end