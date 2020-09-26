local DEFAULT_SETTINGS = require"CharacterRandomizer:settings"
local t = {}
local MODID = CURRENT_MOD_ID

local mt = {
    __index = function(self, key)

        if Content.GetModSetting then
            if Content.GetModSetting(MODID, key) ~= nil then
                return Content.GetModSetting(MODID, key)
            end
        end

        return DEFAULT_SETTINGS[key]
    end,
}
setmetatable(t, mt)

-- returns a function that generates a table of settings
return function()
    local rval = {}
    for id, val in pairs( DEFAULT_SETTINGS ) do
        rval[id] = t[id]
    end
    setmetatable(rval, mt)
    return rval
end