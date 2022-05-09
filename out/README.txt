# T4M Bot Warfare v2.1.0
Bot Warfare is a GSC mod for the T4M project.

It aims to add playable AI to the multiplayer games of World at War.

You can find the more information at the Git Repo: https://github.com/ineedbots/t4m_bot_warfare

**Important to public dedicated servers**
The 'bots_main_firstIsHost' DVAR is enabled by default!
This is so inexperienced users of the mod can access with menu without any configuration.
Make sure to disable this DVAR by adding 'set bots_main_firstIsHost 0' in your server config!

## Installation
0. Make sure that PlutoniumT4 is installed, updated and working properly.
1. Extract all the files from the Bot Warfare release archive you downloaded to anywhere on your computer.
2. Run the 'install.bat'. This copies the mod to your WaW mods folder.
3. The mod is now installed, now run your game.
  - If you are a dedicated server, you will need to set the DVAR 'fs_game' to 'mods/mp_bots'
  - If you are not a dedicated server, open the 'Mods' option from the main menu of the game and select 'mp_bots' and then 'Launch'.
4. The mod should be loaded! Now go start a map and play!

## Menu Usage
- You can open the menu by pressing the primary grenade and secondary grenade buttons together.

- You can navigate the options by the pressing the ADS and fire keys, and you can select options by pressing your melee key.

- Pressing the menu buttons again closes menus.

## Changelog
- v2.1.0
  - Bot chatter system, bots_main_chat
  - Greatly reduce script variable usage
  - Improved bots mantling and stuck
  - Fix some runtime errors
  - Bots sprint more
  - Improved bots sight on enemies
  - Bots do random actions while waiting at an objective
  - Improved bots from getting stuck
  - Better bot difficulty management, bots_skill_min and bots_skill_max

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
