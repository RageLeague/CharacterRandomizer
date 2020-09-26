local PARAMS_FN = require"CharacterRandomizer:script/collect_settings"
local SHUFFLE_PARAMETERS = PARAMS_FN()

local function ValidateForceMap(force_map, allowed_candidates)
    if not force_map then return end
    local used_values = {}
    for key, val in pairs(force_map) do
        local remove_pairing = false
        if used_values[val] then
            print(loc.format("({1}, {2}) Warning: value already used.", key, val))
            remove_pairing = true
        end
        local key_index = table.arrayfind(allowed_candidates, key)
        if not key_index then
            print(loc.format("({1}, {2}) Warning: key not found.", key, val))
            remove_pairing = true
        end
        local val_index = table.arrayfind(allowed_candidates, val)
        if not val_index then
            print(loc.format("({1}, {2}) Warning: value not found.", key, val))
            remove_pairing = true
        end
        if remove_pairing then
            force_map[key] = nil
        end
    end
    return force_map
end

local function DoShuffleMapping(map, to_shuffle, force_map, extra_keys, extra_vals)
    force_map = force_map or {}
    local key_table = table.merge(extra_keys or {}, to_shuffle)
    local value_table = table.merge(extra_vals or {}, to_shuffle)

    for id, val in pairs(force_map) do
        -- if not table.arraycontains(key_table, id) then
        --     print(loc.format("Warning: key {1} not in {2}. Force mapping is skipped.", id, key_table))
        -- elseif not table.arraycontains(value_table, val) then
        --     print(loc.format("Warning: value {1} not in {2}. Force mapping is skipped.", val, value_table))
        -- else
        table.arrayremove(key_table, id)
        table.arrayremove(value_table, val)
            -- map[id] = val
        -- end
    end
    table.shuffle(value_table)
    local num_of_pairs = math.min(#key_table, #value_table)
    for i = 1, num_of_pairs do
        map[key_table[i]] = value_table[i]
    end
    local leftover_key, leftover_value = {}, {}
    for i = num_of_pairs + 1, #key_table do
        table.insert(leftover_key, key_table[i])
    end
    for i = num_of_pairs + 1, #value_table do
        table.insert(leftover_value, value_table[i])
    end
    return leftover_key, leftover_value
end
local function CollectAllSkinnedAgents(mutator, process_fn)
    local params = mutator and mutator.userdata.random_params or {}
    local all_defs = Content.GetAllCharacterDefs()
    for content_id, def in pairs( all_defs ) do
        if params.allow_promotion or not AgentUtil.IsPromoted(content_id) then
            local skins = Content.GetAllCharacterSkins( content_id )
            if skins then
                for i, skin in ipairs( skins ) do
                    -- local properties = PropertyBag()
                    -- properties:PushProperties(def)
                    -- properties:PushProperties(skin)
                    local dummy_agent = Agent.CreateDummyAgent(def, skin)
                    -- TheGame:GetDebug():CreatePanel(DebugTable(properties))
                    if def.faction_id ~= PLAYER_FACTION and not def.hide_in_compendium then
                        if not dummy_agent:CanTalk() then -- if they can't talk, they are not allowed to shuffle.
                        elseif not (params.allow_non_sentients or dummy_agent:IsSentient()) then
                        elseif not (params.allow_not_in_compendium or not def.hide_in_compendium) then
                        else
                            process_fn(content_id, skin.uuid)
                        end
                    -- else
                        -- TheGame:GetDebug():CreatePanel(DebugTable(dummy_agent))
                    end
                end
            
            elseif def.unique then
                -- table.insert( all_skins, content_id .. ":" .. content_id)
                -- local dummy_agent = Agent.CreateDummyAgent(def)
                if not Agent.IsSentient(def) and not def.can_talk then
                elseif not (params.allow_non_sentients or Agent.IsSentient(def)) then
                elseif not (params.allow_not_in_compendium or not def.hide_in_compendium) then
                else
                    process_fn(content_id, content_id)
                end
            end
        end
    end
end

local function SkinnedAgentShuffleFn(self, agent, params_overrides)
    if not SHUFFLE_PARAMETERS.last_seed then
        local settings = require "CharacterRandomizer:settings"
        settings.last_seed = SHUFFLE_PARAMETERS.seed or math.random( 1, 2^32 )
        SHUFFLE_PARAMETERS = PARAMS_FN()
        print("This run's seed: " .. SHUFFLE_PARAMETERS.last_seed)
    end

    self.userdata.random_params = deepcopy(SHUFFLE_PARAMETERS)
    self.userdata.random_params.allow_promotion = GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_PROMOTION_CHANCE ) > 0 -- no allowing promotion when it isn't possible.
    if params_overrides then
        for id, val in pairs(params_overrides) do
            self.userdata.random_params[id] = val
        end
    end
    self.userdata.seed = SHUFFLE_PARAMETERS.last_seed
    print(self.id .. ": seed = " .. self.userdata.seed)
    self.rng = engine.Random(ToggleBits(self.userdata.seed, self:GetDef().seed_offset or 0))
    
    local r_res = ""
    push_random(function( n, m )
        local result = self.rng:Random( n, m )
        if result - math.floor(result) ~= 0 then
            LOGWARN(loc.format("random should be an integer, but get float instead:({1} from {2}, {3})", result, n, m))
        end
        r_res = r_res .. result .. ", "
        return result
    end)

    -- for i = 1, SHUFFLE_PARAMETERS.random_counts or 0 do
    --     math.random() -- burn through a random usage so that two consecutive mutators with the same seed won't generate
    --                 -- the same result
    -- end
    -- SHUFFLE_PARAMETERS.random_counts = (SHUFFLE_PARAMETERS.random_counts or 0) + 1

    self.userdata.map = {}
    
    -- Grouop regular skin by strength
    local regular_skin = {{},{},{},{}}

    local unique_skin = {{},{},{},{}}
    -- Group boss by strength(strength < 3?)
    local boss_skin = {{},{}}
    -- local all_uniques = {}
    local all_skins = {}
    local function AddSkinToList(content_id, uuid)
        local str_id = content_id .. ":" .. uuid
        local character_def = Content.GetCharacterDef( content_id )
        local combat_strength = character_def.combat_strength or 1
        if self.userdata.random_params.separate_boss and character_def.boss then
            if (self.userdata.random_params.boss_group_by_strength or 0) == 0 or combat_strength <= 3 then
                table.insert(boss_skin[1], str_id)
            else
                table.insert(boss_skin[2], str_id)
            end
            table.insert(all_skins, str_id)
            return
        end
        -- note: due to random memories, the order of which an item is added is not constant.
        -- don't use randomness here, just do a simple round down.
        combat_strength = clamp(math.floor(combat_strength), 1, 4)
        if character_def.unique and self.userdata.random_params.separate_unique then
            table.insert(unique_skin[combat_strength], str_id)
        else
            table.insert(regular_skin[combat_strength], str_id)
        end
        table.insert(all_skins, str_id)
    end

    CollectAllSkinnedAgents(self, AddSkinToList)

    local force_map = self:GetDef().skin_only and self.userdata.random_params.force_skin_map or self.userdata.random_params.force_agent_map
    ValidateForceMap(force_map, all_skins)

    for i, skin_group in ipairs(regular_skin) do
        table.sort(skin_group)
    end
    for i, skin_group in ipairs(unique_skin) do
        table.sort(skin_group)
    end
    for i, skin_group in ipairs(boss_skin) do
        table.sort(skin_group)
    end
    -- Group shuffle group by strength:
    -- 1
    -- 1-2
    -- 2-3
    -- 3-4+
    -- 4+
    local shuffle_bucket = {{},{},{},{},{}}
    local unique_shuffle_bucket = {{},{},{},{},{}}
    for i, skin_group in ipairs(regular_skin) do
        for j, data in ipairs(skin_group) do
            local bucket_index-- = math.random(0,1) + i
            if (self.userdata.random_params.group_by_strength or 0) == 0 then
                bucket_index = 1
            elseif (self.userdata.random_params.group_by_strength or 0) == 1 then
                bucket_index = math.random(0,1) + i
            else
                bucket_index = i
            end
            table.insert(shuffle_bucket[bucket_index], data)
        end
    end
    for i, skin_group in ipairs(unique_skin) do
        for j, data in ipairs(skin_group) do
            local bucket_index-- = math.random(0,1) + i
            if (self.userdata.random_params.unique_group_by_strength or 0) == 0 then
                bucket_index = 1
            elseif (self.userdata.random_params.unique_group_by_strength or 0) == 1 then
                bucket_index = math.random(0,1) + i
            else
                bucket_index = i
            end
            table.insert(unique_shuffle_bucket[bucket_index], data)
        end
    end
    -- Actually assign mapping

    -- Assign the forced mapping first
    for key, val in pairs(force_map) do
        self.userdata.map[key] = val
    end

    -- Then shuffle each bucket and assign them to map.
    local leftover_key, leftover_value = {}, {}
    if (self.userdata.random_params.group_by_strength or 0) >= 0 then
        for i, skin_group in ipairs(shuffle_bucket) do
            leftover_key, leftover_value = DoShuffleMapping(self.userdata.map, skin_group, force_map, leftover_key, leftover_value)
        end
    end
    if (self.userdata.random_params.unique_group_by_strength or 0) >= 0 then
        for i, skin_group in ipairs(unique_shuffle_bucket) do
            leftover_key, leftover_value = DoShuffleMapping(self.userdata.map, skin_group, force_map, leftover_key, leftover_value)
        end
    end
    if (self.userdata.random_params.boss_group_by_strength or 0) >= 0 then
        for i, skin_group in ipairs(boss_skin) do
            leftover_key, leftover_value = DoShuffleMapping(self.userdata.map, skin_group, force_map, leftover_key, leftover_value)
        end
    end
    assert_warning(#leftover_key == 0, "Some keys are not used")
    assert_warning(#leftover_value == 0, "Some values are not used")
    -- TheGame:GetDebug():CreatePanel(DebugTable(self.userdata.map))

    pop_random()
    -- print(r_res)
end

local function CompareClassForDef(def_a, def_b, params)
    params = params or {}
    if def_a.unique or def_b.unique then
        return false -- already mapped
    end
    if def_a.is_template or def_b.is_template then
        return false -- you are legally not allowed to create from templates.
    end
    if def_a.faction_id == PLAYER_FACTION or def_b.faction_id == PLAYER_FACTION then
        return false -- don't randomize player you idiot
    end
    -- if not params.allow_promotion and ( def_a.id)
    if not params.allow_promotion and (AgentUtil.IsPromoted(def_a) or AgentUtil.IsPromoted(def_b) ) then
        return false
    end
    print("Compare two defs: " .. def_a.id .. "," .. def_b.id)
    local dummy_a, dummy_b = Agent.CreateDummyAgent(def_a), Agent.CreateDummyAgent(def_b)
    -- Don't mix talker with non-talker. Even though it would be funny, it will break too many things.
    if dummy_a:CanTalk() ~= dummy_b:CanTalk() then
        return false
    end
    if not params.allow_non_sentients and not (dummy_a:IsSentient() and dummy_b:IsSentient()) then
        return false -- if non-sentients aren't allowed and at least one is non-sentient, return false
    end
    if not params.allow_beasts and not (dummy_a:CanTalk() and dummy_b:CanTalk()) then
        return false -- if beasts aren't allowed and at least one is beast, return false
    end
    if params.separate_boss then
        if dummy_a:IsBoss() ~= dummy_b:IsBoss() then
            return false
        end
        if dummy_a:IsBoss() then
            if (params.boss_group_by_strength or 0) == 1 and (dummy_a:GetCombatStrength() <= 3) ~= (dummy_b:GetCombatStrength() <= 3) then
                return false
            elseif (params.boss_group_by_strength or 0) < 0 then
                return false
            end
            return true
        end
    end
    local delta_strengths = dummy_a:GetCombatStrength() - dummy_b:GetCombatStrength() - 0.4 + math.random(0,1) * 0.8
    if (params.group_by_strength or 0) == 1 then
        if math.abs(delta_strengths) > 1.5 then
            return false
        end
    elseif (params.group_by_strength or 0) == 2 then
        if math.abs(delta_strengths) > 0.5 then
            return false
        end
    elseif (params.group_by_strength or 0) < 0 then
        return false
    end
    return true
end

local function GenerateGenericAgentReplacement(self, content_id)
    local all_defs = Content.GetAllCharacterDefs()
    local this_def = Content.GetCharacterDef(content_id)
    local candidates = {}
    for id, def in pairs(all_defs) do
        if CompareClassForDef(this_def, def, self.userdata.random_params) then
            table.insert(candidates, id)
        end
    end
    if #candidates > 0 then
        return table.arraypick(candidates)
    end
end

local function GenerateDescForRandomizer(self, fmt_str)
    if self.userdata.seed then
        return fmt_str .. "\n" .. loc.format(LOC"RANDOMIZER_STRINGS.SEED", self.userdata.seed, ToggleBits(self.userdata.seed, self:GetDef().seed_offset or 0))
    else
        if SHUFFLE_PARAMETERS.seed then
            return fmt_str .. "\n" .. loc.format(LOC"RANDOMIZER_STRINGS.SEED", SHUFFLE_PARAMETERS.seed, ToggleBits(SHUFFLE_PARAMETERS.seed, self:GetDef().seed_offset or 0))
        else
            return fmt_str .. "\n" .. LOC"RANDOMIZER_STRINGS.RANDOM_SEED"
        end
    end
    return fmt_str
end

local MUTATORS = {

    randomizer_skin = {
        name = "Skin Randomizer",
        desc = "Whenever an NPC will be created, another random NPC's skin will be applied. This is the base mutator for other Skin Randomizer mutators, and is completely customizable.",
        desc_fn = GenerateDescForRandomizer,
        event_priorities =
        {
            get_social_unlocks = 1,
        },
        seed_offset = 0xac6435,
        OnAdded = SkinnedAgentShuffleFn,
        skin_only = true,
        event_handlers =
        {
            get_social_unlocks = function(self, params)
                if self.userdata.random_params and self.userdata.random_params.obfuscate_social_grafts then
                    print("lool")
                    params.data = false
                end
            end,
            init_swap_agent = function(self, replacement, content_id, skin_table)
                -- local new_skin = {}
                local query_key
                if skin_table then
                    local uuid = skin_table.uuid
                    assert(uuid, "skin table has no uuid")
                    query_key = content_id .. ":" .. uuid
                else
                    query_key = content_id .. ":" .. content_id
                end
                if self.userdata.map and self.userdata.map[query_key] then
                    local value = self.userdata.map[query_key]
                    local data = value:split(":")
                    -- replacement.new_content_id = data[1]
                    -- replacement.new_uuid = data[2]
                    if data[1] ~= data[2] then
                        local dummy_agent = Agent.CreateDummyAgent(data[1], data[2])
                        replacement.disguise_agent = dummy_agent
                    else
                        local dummy_agent = Agent.CreateDummyAgent(data[1])
                        replacement.disguise_agent = dummy_agent
                    end
                    replacement.params = self.userdata.random_params
                else
                    local generic_replacement = GenerateGenericAgentReplacement(self, content_id)
                    if generic_replacement then
                        local dummy_agent = Agent.CreateDummyAgent(generic_replacement)
                        replacement.disguise_agent = dummy_agent
                    end
                end
            end,
        },
    },
    randomizer_agent = {
        name = "Agent Randomizer",
        desc = "Whenever an NPC will be created, another random NPC will be created in their place instead. This is the base mutator for other Agent Randomizer mutators, and is completely customizable.",
        desc_fn = GenerateDescForRandomizer,
        event_priorities =
        {
            -- new_game = -999,
            
        },
        seed_offset = 0x25e47c,
        OnAdded = SkinnedAgentShuffleFn,
        event_handlers =
        {
            init_swap_agent = function(self, replacement, content_id, skin_table)
                local query_key
                if skin_table then
                    local uuid = skin_table.uuid
                    assert(uuid, "skin table has no uuid")
                    query_key = content_id .. ":" .. uuid
                else
                    query_key = content_id .. ":" .. content_id
                end
                if self.userdata.map and self.userdata.map[query_key] then
                    local value = self.userdata.map[query_key]
                    local data = value:split(":")
                    replacement.new_content_id = data[1]
                    if data[1] ~= data[2] then
                        replacement.new_uuid = data[2]
                    else
                        replacement.new_skin = false
                    end
                    replacement.params = self.userdata.random_params
                else
                    local generic_replacement = GenerateGenericAgentReplacement(self, content_id)
                    if generic_replacement then
                        replacement.new_content_id = generic_replacement
                        replacement.new_skin = false
                    end
                end
            end,
        },
    },
    obfuscate_social_grafts = {
        name = "Obfuscate Social Grafts",
        desc = "When this mutator is on, all social grafts(boons/banes) and death loots are hidden even if you unlocked them previously.",
        event_priorities =
        {
            -- new_game = -999,
            get_social_unlocks = 999,
        },
        event_handlers =
        {
            get_social_unlocks = function(self, params)
                params.data = false
            end,
        },
    },
}

local EXTENDED_MUTATORS = {
    randomizer_agent_chaos = {
        base_def = "randomizer_agent",
        name = "Agent Randomizer(Chaos)",
        desc = "All agents are randomized, no filtering! Behaves like the base mutator, except no separation of characters, and no grouping by agent strengths.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                separate_boss = false,
                separate_unique = false,
                group_by_strength = 0,
            })
        end,
    },
    randomizer_agent_balanced = {
        base_def = "randomizer_agent",
        name = "Agent Randomizer(Balanced)",
        desc = "For those who wants randomness, but doesn't want to cause a huge imbalance. Behaves like the base mutator, except bosses are separated from normal agents, and there are minor grouping by agent strengths.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                separate_boss = true,
                -- separate_unique = false,
                group_by_strength = 1,
                boss_group_by_strength = 1,
            })
        end,
    },
    randomizer_agent_unique_only = {
        base_def = "randomizer_agent",
        name = "Agent Randomizer(Unique Only)",
        desc = "For those who wants the unique NPCs to be randomized, but doesn't want the generic ones to be randomized. Behaves like the base mutator, except regular NPCs are not randomized.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                -- separate_boss = true,
                separate_unique = true,
                group_by_strength = -1,
                -- boss_group_by_strength = 1,
            })
        end,
    },
    randomizer_skin_chaos = {
        base_def = "randomizer_skin",
        name = "Skins Randomizer(Chaos)",
        desc = "All skins are randomized, no filtering! Behaves like the base mutator, except no separation of characters, and no grouping by agent strengths.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                separate_boss = false,
                separate_unique = false,
                group_by_strength = 0,
            })
        end,
    },
    randomizer_skin_balanced = {
        base_def = "randomizer_skin",
        name = "Skins Randomizer(Balanced)",
        desc = "For those who wants randomness, but still want the skins to fit the combat strength range. Behaves like the base mutator, except bosses are separated from normal agents, and there are minor grouping by agent strengths.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                separate_boss = true,
                -- separate_unique = false,
                group_by_strength = 1,
                boss_group_by_strength = 1,
            })
        end,
    },
    randomizer_skin_unique_only = {
        base_def = "randomizer_skin",
        name = "Skins Randomizer(Unique Only)",
        desc = "For those who wants the unique NPCs to be randomized, but doesn't want the generic ones to be randomized. Behaves like the base mutator, except regular NPCs are not randomized.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                -- separate_boss = true,
                separate_unique = true,
                group_by_strength = -1,
                -- boss_group_by_strength = 1,
            })
        end,
    },
    randomizer_skin_mask = {
        base_def = "randomizer_skin",
        name = "Skins Randomizer(Total Disguise)",
        desc = "For those who enjoys mystery novels or movies. Behaves like Skins Randomizer(Chaos), but all information regarding the original NPCs are obfuscated to the best of my abilities.",
        OnAdded = function(self, agent)
            SkinnedAgentShuffleFn(self, agent, {
                separate_boss = false,
                separate_unique = false,
                group_by_strength = 0,
                disguise_loc_table = true,
                disguise_portrait = true,
                disguise_faction = true,
                obfuscate_social_grafts = true,
            })
        end,
    },
}
local exclusions = {}

for id, data in pairs(MUTATORS) do
    if not data.img_path then
        data.img_path = "CharacterRandomizer:assets/mutator_icon/" .. id .. ".png"
    end
    if data.img_path then
        data.img = engine.asset.Texture(data.img_path, true)
    end
    -- Content.AddMutatorGraft( id, data )
end
for id, data in pairs(EXTENDED_MUTATORS) do
    if not data.img_path then
        data.img_path = "CharacterRandomizer:assets/mutator_icon/" .. id .. ".png"
    end
    if data.img_path then
        data.img = engine.asset.Texture(data.img_path, true)
    end
    EXTENDED_MUTATORS[id] = table.extend(MUTATORS[data.base_def])(data)
    if not exclusions[data.base_def] then
        exclusions[data.base_def] = {}
    end
    table.insert(exclusions[data.base_def], id)
    -- Content.AddMutatorGraft( id, data )
end

for id, data in pairs(MUTATORS) do
    data.exclusion_ids = shallowcopy(exclusions[id])
    Content.AddMutatorGraft( id, data )
end
for id, data in pairs(EXTENDED_MUTATORS) do
    data.exclusion_ids = shallowcopy(exclusions[data.base_def])
    table.arrayremove(data.exclusion_ids, id)
    table.insert(data.exclusion_ids, data.base_def)
    Content.AddMutatorGraft( id, data )
end