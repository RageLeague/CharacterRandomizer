local patch_id = "DISGUISE_FACTION_ICON"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local old_fn = Widget.CharacterPortrait.SetCharacter

Widget.CharacterPortrait.SetCharacter = function(self, agent)
    local do_swap = false
    local old_faction_id = nil
    if agent and agent.disguise_agent and agent.disguise_data and agent.disguise_data.disguise_faction then
        print("old faction id:" .. (agent.faction_id or "nil"))
        do_swap = true
        old_faction_id = rawget(agent, "faction_id")
        rawset(agent, "faction_id", agent.disguise_agent.faction_id)
        print("temp faction id:" .. (agent.faction_id or "nil"))
    end
    old_fn(self, agent)
    if do_swap then
        rawset(agent, "faction_id", old_faction_id)
    end
    print("post faction id:" .. (agent.faction_id or "nil"))
    return self
end
local old_fn2 = Widget.PeopleCompendiumDetailsPopup.Refresh
Widget.PeopleCompendiumDetailsPopup.Refresh = function(self, agent)
    local do_swap = false
    local old_faction_id = nil
    if agent and agent.disguise_agent and agent.disguise_data and agent.disguise_data.disguise_faction then
        print("old faction id:" .. (agent.faction_id or "nil"))
        do_swap = true
        old_faction_id = rawget(agent, "faction_id")
        rawset(agent, "faction_id", agent.disguise_agent.faction_id)
        print("temp faction id:" .. (agent.faction_id or "nil"))
    end
    old_fn2(self, agent)
    if do_swap then
        rawset(agent, "faction_id", old_faction_id)
    end
    print("post faction id:" .. (agent.faction_id or "nil"))
    return self
end