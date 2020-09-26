
-- Parameters for the mod.
return {
    -- Set this field to a number for the seed. Remove this field for a random seed at the start of each run.
    -- seed = 12345,

    -- Whether to separate boss from the rest while shuffling.
    separate_boss = false,

    -- Whether to separate uniques from the rest while shuffling.
    separate_unique = false,
    
    -- This can have some values:
    -- Any negative value: No randomization.
    -- 0: No grouping. Everything is shuffled together.
    -- 1: Minor grouping. Regular enemies are grouped by stength +- 1.
    -- 2: Strict grouping. Regular enemies are grouped by absolute strength.
    -- Note: Regular enemies with strength 4+ counts as 4, because if there's any with strength 5 or up,
    -- They are probably modded.
    group_by_strength = 0,

    -- Same as group_by_strength, but with unique characters instead.
    unique_group_by_strength = 0,
    -- Any negative value: No randomization.
    -- 0: No grouping. All bosses are shuffled together.
    -- 1: Minor grouping. Boss with strength 3- are grouped together, while bosses with strength 4+ are grouped together.
    boss_group_by_strength = 0,
    
    -- Whether to allow non-sentients to be randomized. Note: this will only allow basically robots that can
    -- talk, such as Bossbit, to be shuffled. Due to a lot of complicated issues, we don't allow agents that
    -- can talk to replace agents that can talk, since they won't then show up on the UI.
    allow_non_sentients = false,

    -- Whether to allow beasts, i.e. non-sentients that can't talk, to be randomized. They are only allowed
    -- to be randomized among themselves.
    allow_beasts = false,
    
    -- Whether to allow characters that are hidden in the compendium into the shuffle group.
    allow_not_in_compendium = false,

    -- You can't turn of the retain original alias feature, because otherwise the entire
    -- cast by alias system won't work properly.

    -- Whether a replaced agent retains the original content id.
    -- If you want to have random NPCs show up at job slots, you want to turn this on.
    retain_content_id = true,
    -- Whether a replaced agent retains the original renown/combat strength.
    -- Set this to false for a *slightly* more balanced run, as agents with inappropriate renown/
    -- combat strength might get filtered out of quests.
    retain_strength = true,
    -- Whether a replaced agent retains the original faction.
    -- UI only. Otherwise Rook's contact quests won't work.
    retain_faction = false,

    -- Whether to replace an agent's loc table with the disguise.
    -- It will not affect gameplay, but it will replace strings that identifies that character with the strings for the disguise.
    -- For example, "Snack", "Civilian Heavy Laborer" will be replaced by the disguise.
    disguise_loc_table = false,
    
    -- Whether to replace an agent's portrait with the disguise.
    disguise_portrait = false,

    -- Whether to disguise an agent's faction when displaying that agent's faction.
    -- It will not affect the agent's actual faction. Hopefully.
    disguise_faction = false,

    -- Whether to hide all NPC's boons and banes, as well as their death loot.
    -- Turn this on if you want to make the discovery of an agent's true identity harder.
    obfuscate_social_grafts = false,

    -- When using the skin randomizer, force a few particular mapping so that a specific agent
    -- is guaranteed to be replaced by another agent.
    force_skin_map = {
        -- When inputting entries, follow something like this:
        -- ["FSSH:d18e5b49-45a2-4561-aaae-37338243c36d"] = "SWEET_MOREEF:65dc4d86-e8ab-4c5e-9444-7ab7d765806d",

        -- If an agent is unique, but doesn't have a skin defined, use something like this:
        -- ["NPC_ROOK:NPC_ROOK"] = "VIXMALLI:VIXMALLI",
    },

    -- When using the agent randomizer, force a few particular mapping, similar to force_skin_map.
    force_agent_map = {

    },
}