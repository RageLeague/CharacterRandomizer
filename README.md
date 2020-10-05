# Character Randomizer

A mod that allows you to break the natural order of the game by randomizing the characters.

Version: 0.1.2

Author: RageLeague

Supported Languages: English, 简体中文, 繁體中文.

Expands On Mods:

* 简中文本优化/Better CHS L10N (https://steamcommunity.com/sharedfiles/filedetails/?id=2234153945) (Localization).

## Mod Information

This mod adds two major class of mutators: Agent Randomizer and Skin Randomizer. The Agent Randomizer will randomize the agent spawned during a run, which will affect their negotiation/combat behaviours, their boons/banes, etc. The Skin Randomizer will randomize the appearance of an agent when they spawn. With tons of customizations on the randomization process, this mod will break all rules of the existing game.

Additional mutators extends from the base class, and usually have various minor change in the settings.

**Note: This mod changes a lot of existing functions, and is not guaranteed bug-free. If you encounter any bugs related to this mod, please leave a comment either on the GitHub page or the workshop page.**

## How to install?

### Directly fron GitHub

With the official mod update, you can read about how to set up mods at https://forums.kleientertainment.com/forums/topic/116914-early-mod-support/.

1. Find `[user]/AppData/Roaming/Klei/Griftlands/` folder on your computer, or `[user]/AppData/Roaming/Klei/Griftlands_testing/` if you're on experimental. Find the folder with all the autogenerated files, log.txt, and `saves` directory. If you are on Steam, open the folder that starts with `steam-`. If you are on Epic, open the folder that contains only hexadecimal code.
2. Create a new folder called `mods` if you haven't already.
3. Clone this repository into that folder.
4. The `modinit.lua` file should be under `.../mods/[insert_repo_name_here]`.
5. Volia! Now the mod should work.

### Steam workshop

With the new official workshop support, you can directly install mods from steam workshop. You can read about it at https://forums.kleientertainment.com/forums/topic/121426-steam-workshop-beta/ and https://forums.kleientertainment.com/forums/topic/121488-example-mods/.

1. Subscribe this item.
2. Enable it in-game.
3. Volia!

## Customization

Go to settings.lua in the mod folder to edit the settings of the mod.

If you are in the Experimental Branch, you can go to the "Mods" tabs in the options menu and customize the mod behaviour there.

**Note: The customizations only has effects at the start of the run when you enabled the mutator(s). If you change the settings after starting a run, it will not affect that run.**

## Changelog

### 0.1.2

* Add an additional option: Use new character animation. You can now select whether you want to use the original character's animations or use the disguised ones. If you want to see Rook holding a shotgun, or Fssh with rocket legs, now you can!
* Added localizations for Chinese Simplified and Chinese Traditional. This even works with modded languages, as long as the modded language has zh_HANT or zh_HANS defined as one of the default languages.
* This mod loads after 简中文本优化/Better CHS L10N (https://steamcommunity.com/sharedfiles/filedetails/?id=2234153945) so that I can add localization files to this modded language. I have to convince Klei to implement the mod load order code I wrote into the base game in order for this to work, but it's totally worth it.

### 0.1.1

* Now replaced agent always keep their original faction, because otherwise Rook's story will softlock because your handler's faction is neither Rise or Spark Baron. The old "Retain Faction" setting is UI only now.
* Some other minor optimizations.

### 0.1.0

* Mod released!
