local filepath = require "util/filepath"
local function OnNewGame(mod, game_state)
    local player_agent = game_state:GetPlayerAgent()
    if player_agent then
        for i, graft in ipairs(player_agent.graft_owner:GetGrafts(GRAFT_TYPE.MUTATOR)) do
            if graft:GetDef():GetModID() == mod.id then
                game_state:RequireMod(mod)
            end
        end
    end
end
local function OnPreLoad(mod)
    for k, filepath in ipairs( filepath.list_files( "CharacterRandomizer:script/patches", "*.lua", true )) do
        local name = filepath:match( "(.+)[.]lua$" )
        require(name)
    end
end
local function OnLoad(mod)
    rawset(_G, "CURRENT_MOD_ID", mod.id)
    Content.AddStringTable("CHARACTER_RANDOMIZER", {
        RANDOMIZER_STRINGS = {
            SEED = "<#HILITE>(Seed for this run: {1}.)</>\n<#HILITE>(Seed for this mutator: {2}.)</>",
            RANDOM_SEED = "<#HILITE>(A random seed will be assigned at the start of a new run)</>",
        },
    })
    
    -- Content.ReloadConversation()
    -- so it can store the current mod id locally
    require "CharacterRandomizer:script/collect_settings"
    require "CharacterRandomizer:script/mutators"
end
local MOD_OPTIONS = {
    {
        title = "Group By Strength",
        spinner = true,
        key = "group_by_strength",
        default_value = 0,
        values =
        {
            { name="No Randomization", desc="Don't randomize NPCs.", data = -1 },
            { name="No Grouping", desc="Randomize all NPCs in a single group, without separating them by strength.", data = 0 },
            { name="Minor Grouping", desc="NPCs will be randomized with other NPCs who are up to 1.5 combat strengths with each other.", data = 1 },
            { name="Strict Grouping", desc="NPCs will be randomized with other NPCs who are up to 0.5 combat strengths with each other.", data = 2 },
        },
    },
    {
        title = "Separate Bosses",
        spinner = true,
        key = "separate_boss",
        default_value = false,
        values =
        {
            { name="False", desc="Allow bosses and other NPCs to mix when randomizing.", data = false },
            { name="True", desc="Separate bosses and other NPCs into different random groups.", data = true },
        },
    },
    {
        title = "Group By Strength(Bosses)",
        spinner = true,
        key = "boss_group_by_strength",
        default_value = 0,
        values =
        {
            { name="No Randomization", desc="Don't randomize bosses.", data = -1 },
            { name="No Grouping", desc="Randomize all bosses in a single group, without separating them by strength.", data = 0 },
            { name="Minor Grouping", desc="All bosses with combat strength 3 or less are grouped together while randomizing, and so are all bosses with combat strength 4 or more.", data = 1 },
        },
    },
    {
        title = "Separate Uniques",
        spinner = true,
        key = "separate_unique",
        default_value = false,
        values =
        {
            { name="False", desc="Allow unique NPCs and other NPCs to mix when randomizing.", data = false },
            { name="True", desc="Separate unique NPCs and other NPCs into different random groups. If Separate Bosses is also turned on, a unique boss NPC will be grouped with bosses.", data = true },
        },
    },
    {
        title = "Group By Strength(Uniques)",
        spinner = true,
        key = "unique_group_by_strength",
        default_value = 0,
        values =
        {
            { name="No Randomization", desc="Don't randomize unique NPCs.", data = -1 },
            { name="No Grouping", desc="Randomize all unique NPCs in a single group, without separating them by strength.", data = 0 },
            { name="Minor Grouping", desc="Unique NPCs will be randomized with other Unique NPCs who are up to 1.5 combat strengths with each other.", data = 1 },
            { name="Strict Grouping", desc="Unique NPCs will be randomized with other Unique NPCs who are up to 0.5 combat strengths with each other.", data = 2 },
        },
    },
    {
        title = "Allow Non-Sentients",
        spinner = true,
        key = "allow_non_sentients",
        default_value = false,
        values =
        {
            { name="False", desc="Non-sentients who can talk are not randomized with sentient NPCs.", data = false },
            { name="True", desc="Non-sentients who can talk are randomized with sentient NPCs. This doesn't allow beasts to be randomized with sentient NPCs.", data = true },
        },
    },
    {
        title = "Allow Beasts",
        spinner = true,
        key = "allow_beasts",
        default_value = false,
        values =
        {
            { name="False", desc="Non-sentients who can't talk are not randomized.", data = false },
            { name="True", desc="Non-sentients who can't talk are randomized among themselves.", data = true },
        },
    },
    {
        title = "Allow Not In Compendium",
        spinner = true,
        key = "allow_not_in_compendium",
        default_value = false,
        values =
        {
            { name="False", desc="Don't allow NPCs who aren't in the compendium to be randomized.", data = false },
            { name="True", desc="Allow NPCs who aren't in the compendium to be randomized within their respective groups.", data = true },
        },
    },
    {
        title = "Retain Content ID",
        spinner = true,
        key = "retain_content_id",
        default_value = true,
        values =
        {
            { name="False", desc="Agents don't retain their original content ID after replacement. (Not Recommended)", data = false },
            { name="True", desc="Agents retain their original content ID after replacement. (Recommended)", data = true },
        },
    },
    {
        title = "Retain Strength",
        spinner = true,
        key = "retain_strength",
        default_value = false,
        values =
        {
            { name="False", desc="Agents don't retain their original renown and combat strength after replacement, making combat/negotiation balancing reflect their true strengths.", data = false },
            { name="True", desc="Agents retain their original renown and combat strength after replacement, which makes NPC randomizations have effects, even after the initial random assignment.", data = true },
        },
    },
    {
        title = "Retain Faction(UI only)",
        spinner = true,
        key = "retain_faction",
        default_value = false,
        values =
        {
            { name="False", desc="Agents don't display their original faction after replacement, but will still keep their original faction.", data = false },
            { name="True", desc="Agents retain their original faction after replacement, which will be reflected on their portrait.", data = true },
        },
    },
    {
        title = "Disguise Loc Table",
        spinner = true,
        key = "disguise_loc_table",
        default_value = false,
        values =
        {
            { name="False", desc="Agents will retain their name, title, etc. after getting a new skin.", data = false },
            { name="True", desc="Agents will disguise their name, title, etc. with the name, title, etc. of the new skin.", data = true },
        },
    },
    {
        title = "Disguise Portrait",
        spinner = true,
        key = "disguise_portrait",
        default_value = false,
        values =
        {
            { name="False", desc="Agents will retain the original portrait, even after getting a new skin.", data = false },
            { name="True", desc="Agents will disguise their portrait with the portrait of the new skin.", data = true },
        },
    },
    {
        title = "Disguise Faction",
        spinner = true,
        key = "disguise_faction",
        default_value = false,
        values =
        {
            { name="False", desc="Agents will not diguise their faction.", data = false },
            { name="True", desc="Agents will disguise their faction with the faction of the new skin on the portrait or in the compendium, but their true faction does not change.", data = true },
        },
    },
    {
        title = "Obfuscate Social Grafts",
        spinner = true,
        key = "obfuscate_social_grafts",
        default_value = false,
        values =
        {
            { name="False", desc="Agents will still display their boons, banes, and death loots.", data = false },
            { name="True", desc="When a skin randomizer mutator is selected, agents will hide their boons, banes, and death loots until you acquire them so you can't deduce their identity based on that.", data = true },
        },
    },
    {
        title = "Use New Character Animation(Skin Randomizer)",
        spinner = true,
        key = "use_new_anim",
        default_value = false,
        values =
        {
            { name="False", desc="Agents will use their original character animations, which means they will carry their original weapon, etc. (Only applies to humanoid characters)", data = false },
            { name="True", desc="Agents will use their disguise's character animations, which means they will carry ther disguise's weapon, etc. (Only applies to humanoid characters)", data = true },
        },
    },
}
return {
    alias = "CharacterRandomizer",
    version = "0.1.1",

    mod_options = MOD_OPTIONS,

    OnPreLoad = OnPreLoad,
    OnLoad = OnLoad,
    OnNewGame = OnNewGame,

    title = "Character Randomizer",
    description = "This mod adds two major class of mutators: Agent Randomizer and Skin Randomizer. With tons of customizations on the randomization process, this mod will break all rules of the existing game.",
    previewImagePath = "preview.png",
}