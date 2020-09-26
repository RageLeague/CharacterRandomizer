local patch_id = "COMPREHENSIVE_ATTACK_FALLBACKS"
if rawget(_G, patch_id) then
    return
end
rawset(_G, patch_id, true)
print("Loaded patch:"..patch_id)

local battle_defs = require "battle/battle_defs"
require "components/animfighter"

local melee_fallback = {
    "slice",
    "swing",
    "slash",
    "smash",
    "crush",
    "stab",
    "punch",
    "bite",
    "whip",
    "poke",
    "cut",
    "claw",
    "attack3",
    "attack2",
}
local ranged_fallback = {
    "throw",
    "blast",
    "shoot",
    "pierce",
    "projectile",
    "spark_canister",
    "grenade",
    "master_blaster",
}
local attacks_fallback = {
    "attack1",
    -- Everyone has a counter, maybe?
    "riposte",
}
local all_fallback = {
    -- Everyone has a taunt.
    "taunt",
}
local extra_anim = {
    blast = {pre_anim = "blast_pre",post_anim = "blast_pst",}
}

local old_fn = AnimFighter.DoAttack

AnimFighter.DoAttack = function(self, attack, screen)
    local anim, presentation = self:GetPresentation( attack.anim )
    local selected_anim_id = attack.anim
    
    if not self.entity.cmp.AnimController:GetAnimInfo( anim ) and CheckBits( attack.flags, battle_defs.CARD_FLAGS.MELEE ) then
        for i, id in ipairs(melee_fallback) do
            anim, presentation = self:GetPresentation(id)
            selected_anim_id = id
            if self.entity.cmp.AnimController:GetAnimInfo( anim ) then break end
        end
    end

    if not self.entity.cmp.AnimController:GetAnimInfo( anim ) and CheckBits( attack.flags, battle_defs.CARD_FLAGS.RANGED ) then
        for i, id in ipairs(ranged_fallback) do
            anim, presentation = self:GetPresentation(id)
            selected_anim_id = id
            if self.entity.cmp.AnimController:GetAnimInfo( anim ) then break end
        end
    end

    if not self.entity.cmp.AnimController:GetAnimInfo( anim ) and CheckAnyBits( attack.flags, battle_defs.CARD_FLAGS.MELEE | battle_defs.CARD_FLAGS.RANGED ) then
        for i, id in ipairs(attacks_fallback) do
            anim, presentation = self:GetPresentation(id)
            selected_anim_id = id
            if self.entity.cmp.AnimController:GetAnimInfo( anim ) then break end
        end
    end

    if not self.entity.cmp.AnimController:GetAnimInfo( anim ) then
        for i, id in ipairs(all_fallback) do
            anim, presentation = self:GetPresentation(id)
            selected_anim_id = id
            if self.entity.cmp.AnimController:GetAnimInfo( anim ) then break end
        end
    end

    if selected_anim_id and extra_anim[selected_anim_id] then
        for id, data in pairs(extra_anim[selected_anim_id]) do
            attack.card[id] = data
        end
    end
    if selected_anim_id then
        attack.anim = selected_anim_id
    end
    print("selected anim id: " .. (selected_anim_id or "nil"))
    -- TheGame:GetDebug():CreatePanel(DebugTable(attack))
    return old_fn(self,attack,screen)
end