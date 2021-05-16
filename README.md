![GitHub Logo](/main_shared/bw-assets/bw-logo.png)

# T4M Bot Warfare
Bot Warfare is a GSC mod for the [T4M project](https://github.com/ineedbots/T4M).

It aims to add playable AI to the multiplayer games of World at War.

You can find the ModDB release post [here](https://www.moddb.com/mods/bot-warfare/downloads/t4m-bot-warfare-latest).

## <span style="color:red">Important to public dedicated servers</span>
The ```bots_main_firstIsHost``` DVAR is enabled by default!

This is so inexperienced users of the mod can access with menu without any configuration.

Make sure to disable this DVAR by adding ```set bots_main_firstIsHost 0``` in your server config!

## Contents
- [Features](#Features)
- [Installation](#Installation)
- [Documentation](#Documentation)
- [Changelog](#Changelog)
- [Credits](#Credits)

## Features
- A Waypoint Editor for creating and modifying bot's waypoints of traversing the map. Have a look at [Using the Waypoint editor](/main_shared/bw-assets/wpedit.md).

- A clean and nice menu, you can edit every bot DVAR within in-game.

- Everything can be customized, ideal for both personal use and dedicated servers. Have a look at [Documentation](#Documentation) to see whats possible!

- This mod does not edit ANY stock .gsc files, meaning EVERY other mod is compatible with this mod. Mod doesn't add anything unnecessary, what you see is what you get.

- Adds AI clients to multiplayer games to simulate playing real players. (essentially Combat Training for WaW)
  - Bots move around the maps with native engine input. (all normal maps, most to all custom maps)
  - Bots press all the buttons with native engine input (ads, sprint, jump, etc)
  - Bots play all gamemodes/objectives, they capture flags, plant, defuse bombs, etc. ( all normal modes, most custom modes)
  - Bots use all killstreaks.
  - Bots target killstreaks and vehicles.
  - Bots target equipment.
  - Bots can camp randomly.
  - Bots can follow others on own will.
  - Bots have smooth and realistic aim.
  - Bots respond smartly to their surroundings, they will go to you if you shoot, uav, etc.
  - Bots use all perks and weapons.
  - Bots difficulty level can be customized and are accurate. (hard is hard, easy is easy, etc.)
  - Bots each all have different classes, traits, and difficulty and remember it all.
  - Bots switch from between primaries and secondaries.
  - Bots can grenade, place betties, they even use grenades and tubes in preset map locations.
  - Bots use grenade launchers.
  - Bots can melee people.
  - Bots can run!
  - Bots can climb ladders!
  - Bots jump shot and drop shot.
  - Bots detect smoke grenades, flares, gas and airstrike slows.
  - Bots will remember their class, skill and traits, even on multiround based gametypes.
  - Bots can throwback grenades.
  - ... And pretty much everything you expect a Combat Training bot to have

## Installation
T4M requires an unpacked steamless version of the multiplayer World at War executable (otherwise known as LanFixed). You can use a [Steam Unpacker](https://github.com/atom0s/Steamless) on your multiplayer World at War Steam executable to acquire the required executable.

Also make sure that PunkBuster is disabled!
![Disabling PunkBuster](/main_shared/bw-assets/disable_pb.png)

0. Make sure that [T4M](https://github.com/ineedbots/T4M) is installed, updated and working properly.
    - Download the [d3d9.dll](https://github.com/ineedbots/T4M/releases) and place it into the root of your World at War install
    - Download the [WaW MP LanFixed](https://bit.ly/3803IUC) and place it into the root of your World at War install, you will use this executable to run the game.
    - Download the [latest release](https://github.com/ineedbots/t4m_bot_warfare/releases) of Bot Warfare.
1. Extract all the files from the Bot Warfare release archive you downloaded to anywhere on your computer.
2. Run the 'install.bat'. This copies the mod to your WaW mods folder.
3. The mod is now installed, now run your game.
    - If you are a dedicated server, you will need to set the DVAR 'fs_game' to 'mods/mp_bots'
    - If you are not a dedicated server, open the 'Mods' option from the main menu of the game and select 'mp_bots' and then 'Launch'.
4. The mod should be loaded! Now go start a map and play!

## Documentation

### Menu Usage
- You can open the menu by pressing the primary grenade and secondary grenade buttons together.

- You can navigate the options by the pressing the ADS and fire keys, and you can select options by pressing your melee key.

- Pressing the menu buttons again closes menus.

### DVARs
- bots_manage_add - an integer amount of bots to add to the game, resets to 0 once the bots have been added.
    - for example: 'bots_manage_add 10' will add 10 bots to the game.

- bots_manage_fill - an integer amount of players/bots (depends on bots_manage_fill_mode) to retain on the server, it will automatically add bots to fill player space.
    - for example: 'bots_manage_fill 10' will have the server retain 10 players in the server, if there are less than 10, it will add bots until that value is reached.

- bots_manage_fill_mode - a value to indicate if the server should consider only bots or players and bots when filling player space.
    - 0 will consider both players and bots.
    - 1 will only consider bots.

- bots_manage_fill_kick - a boolean value (0 or 1), whether or not if the server should kick bots if the amount of players/bots (depends on bots_manage_fill_mode) exceeds the value of bots_manage_fill.

- bots_manage_fill_spec - a boolean value (0 or 1), whether or not if the server should consider players who are on the spectator team when filling player space.

---

- bots_team - a string, the value indicates what team the bots should join:
    - 'autoassign' will have bots balance the teams
    - 'allies' will have the bots join the allies team
    - 'axis' will have the bots join the axis team
    - 'custom' will have bots_team_amount bots on the axis team, the rest will be on the allies team
    
- bots_team_amount - an integer amount of bots to have on the axis team if bots_team is set to 'custom', the rest of the bots will be placed on the allies team.
    - for example: there are 5 bots on the server and 'bots_team_amount 3', then 3 bots will be placed on the axis team, the other 2 will be placed on the allies team.

- bots_team_force - a boolean value (0 or 1), whether or not if the server should enforce periodically the bot's team instead of just a single team when the bot is added to the game.
    - for example: 'bots_team_force 1' and 'bots_team autoassign' and the teams become to far unbalanced, then the server will change a bot's team to make it balanced again.

- bots_team_mode - a value to indicate if the server should consider only bots or players and bots when counting players on the teams.
    - 0 will consider both players and bots.
    - 1 will only consider bots.

---

- bots_skill - value to indicate how difficult the bots should be.
    - 0 will be mixed difficultly
    - 1 will be the most easy
    - 2-6 will be in between most easy and most hard
    - 7 will be the most hard.
    - 8 will be custom.

- bots_skill_axis_hard - an integer amount of hard bots on the axis team.
- bots_skill_axis_med - an integer amount of medium bots on the axis team.
- bots_skill_allies_hard - an integer amount of hard bots on the allies team.
- bots_skill_allies_med - an integer amount of medium bots on the allies team
    - if bots_skill is 8 (custom). The remaining bots on the team will become easy bots
    - for example: having 5 bots on the allies team, 'bots_skill_allies_hard 2' and 'bots_skill_allies_med 2' will have 2 hard bots, 2 medium bots, and 1 easy bot on the allies team.

---

- bots_loadout_reasonable - a boolean value (0 or 1), whether or not if the bots should filter out bad create a class selections

- bots_loadout_allow_op - a boolean value (0 or 1), whether or not if the bots are allowed to use jug, marty, etc.

- bots_loadout_rank - an integer number, bots will be around this rank, -1 is average of all players in game, 0 is all random

- bots_loadout_prestige - an integer number, bots will be this prestige, -1 is the same as player, -2 is all random

- bots_play_move - a boolean value (0 or 1), whether or not if the bots will move
- bots_play_knife - a boolean value (0 or 1), whether or not if the bots will use the knife
- bots_play_fire - a boolean value (0 or 1), whether or not if the bots will fire their weapons
- bots_play_nade - a boolean value (0 or 1), whether or not if the bots will grenade
- bots_play_obj - a boolean value (0 or 1), whether or not if the bots will play the objective
- bots_play_camp - a boolean value (0 or 1), whether or not if the bots will camp
- bots_play_jumpdrop - a boolean value (0 or 1), whether or not if the bots will jump shot or drop shot
- bots_play_target_other - a boolean value (0 or 1), whether or not if the bots will target claymores, killstreaks, etc.
- bots_play_killstreak - a boolean value (0 or 1), whether or not if the bots will use killstreaks
- bots_play_ads - a boolean value (0 or 1), whether or not if the bots will ads

---

- bots_main - a boolean value (0 or 1), enables or disables the mod

- bots_main_firstIsHost - a boolean value (0 or 1), the first player to connect is considered a host

- bots_main_GUIDs - a list of GUIDs (comma seperated) of players who will be considered a host

- bots_main_waitForHostTime - a float value, how long in seconds to wait for the host player to connect before adding in bots

- bots_main_menu - a boolean value (0 or 1), enables or disables the menu

- bots_main_debug - a boolean value (0 or 1), enables or disables the waypoint editor

## Changelog
- v2.0.1
  - Reduced bots crouching
  - Increased bots sprinting
  - Improved bots mantling, crouching and knifing glass when needed
  - Fixed possible script runtime errors
  - Improved domination
  - Bots use explosives more if they have it
  - Bots aim slower when ads'ing
  - Fixed bots holding breath
  - Fixed bots rubberbanding movement when their goal changes
  - Added bots quickscoping with snipers
  - Added bots reload canceling and fast swaps
  - Bots use C4
  - Improved revenge
  - Bots can swap weapons on spawn more likely

- v2.0.0
  - Initial reboot release

## Credits
- iAmThatMichael - https://github.com/iAmThatMichael/T4M
- INeedGames(me) - http://www.moddb.com/mods/bot-warfare
- PeZBot team - http://www.moddb.com/mods/pezbot
- Ability
- Salvation

Feel free to use code, host on other sites, host on servers, mod it and merge mods with it, just give credit where credit is due!
	-INeedGames/INeedBot(s) @ ineedbots@outlook.com
