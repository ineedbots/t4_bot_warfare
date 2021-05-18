#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_VERSION = "2.0.1";

	if(getDvar("bots_main") == "")
		setDvar("bots_main", true);

	if (!getDvarInt("bots_main"))
		return;

	thread load_waypoints();
	cac_init_patch();
	thread hook_callbacks();

	if(getDvar("bots_main_GUIDs") == "")
		setDvar("bots_main_GUIDs", "");//guids of players who will be given host powers, comma seperated
	if(getDvar("bots_main_firstIsHost") == "")
		setDvar("bots_main_firstIsHost", true);//first player to connect is a host
	if(getDvar("bots_main_waitForHostTime") == "")
		setDvar("bots_main_waitForHostTime", 10.0);//how long to wait to wait for the host player
		
	if(getDvar("bots_manage_add") == "")
		setDvar("bots_manage_add", 0);//amount of bots to add to the game
	if(getDvar("bots_manage_fill") == "")
		setDvar("bots_manage_fill", 0);//amount of bots to maintain
	if(getDvar("bots_manage_fill_spec") == "")
		setDvar("bots_manage_fill_spec", true);//to count for fill if player is on spec team
	if(getDvar("bots_manage_fill_mode") == "")
		setDvar("bots_manage_fill_mode", 0);//fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
	if(getDvar("bots_manage_fill_kick") == "")
		setDvar("bots_manage_fill_kick", false);//kick bots if too many
	
	if(getDvar("bots_team") == "")
		setDvar("bots_team", "autoassign");//which team for bots to join
	if(getDvar("bots_team_amount") == "")
		setDvar("bots_team_amount", 0);//amount of bots on axis team
	if(getDvar("bots_team_force") == "")
		setDvar("bots_team_force", false);//force bots on team
	if(getDvar("bots_team_mode") == "")
		setDvar("bots_team_mode", 0);//counts just bots when 1
	
	if(getDvar("bots_skill") == "")
		setDvar("bots_skill", 0);//0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random
	if(getDvar("bots_skill_axis_hard") == "")
		setDvar("bots_skill_axis_hard", 0);//amount of hard bots on axis team
	if(getDvar("bots_skill_axis_med") == "")
		setDvar("bots_skill_axis_med", 0);
	if(getDvar("bots_skill_allies_hard") == "")
		setDvar("bots_skill_allies_hard", 0);
	if(getDvar("bots_skill_allies_med") == "")
		setDvar("bots_skill_allies_med", 0);
	
	if(getDvar("bots_loadout_reasonable") == "")//filter out the bad 'guns' and perks
		setDvar("bots_loadout_reasonable", false);
	if(getDvar("bots_loadout_allow_op") == "")//allows jug, marty and laststand
		setDvar("bots_loadout_allow_op", true);
	if(getDvar("bots_loadout_rank") == "")// what rank the bots should be around, -1 is around the players, 0 is all random
		setDvar("bots_loadout_rank", -1);
	if(getDvar("bots_loadout_prestige") == "")// what pretige the bots will be, -1 is the players, -2 is random
		setDvar("bots_loadout_prestige", -1);

	if(getDvar("bots_play_move") == "")//bots move
		setDvar("bots_play_move", true);
	if(getDvar("bots_play_knife") == "")//bots knife
		setDvar("bots_play_knife", true);
	if(getDvar("bots_play_fire") == "")//bots fire
		setDvar("bots_play_fire", true);
	if(getDvar("bots_play_nade") == "")//bots grenade
		setDvar("bots_play_nade", true);
	if(getDvar("bots_play_obj") == "")//bots play the obj
		setDvar("bots_play_obj", true);
	if(getDvar("bots_play_camp") == "")//bots camp and follow
		setDvar("bots_play_camp", true);
	if(getDvar("bots_play_jumpdrop") == "")//bots jump and dropshot
		setDvar("bots_play_jumpdrop", true);
	if(getDvar("bots_play_target_other") == "")//bot target non play ents (vehicles)
		setDvar("bots_play_target_other", true);
	if(getDvar("bots_play_killstreak") == "")//bot use killstreaks
		setDvar("bots_play_killstreak", true);
	if(getDvar("bots_play_ads") == "")//bot ads
		setDvar("bots_play_ads", true);

	if(!isDefined(game["botWarfare"]))
		game["botWarfare"] = true;
	
	level.defuseObject = undefined;
	level.bots_smokeList = List();
	level.tbl_PerkData[0]["reference_full"] = true;
	for(h = 1; h < 6; h++)
		for(i = 0; i < 3; i++)
			level.default_perk["CLASS_CUSTOM"+h][i] = "specialty_null";
	
	level.bots_minSprintDistance = 315;
	level.bots_minSprintDistance *= level.bots_minSprintDistance;
	level.bots_minGrenadeDistance = 256;
	level.bots_minGrenadeDistance *= level.bots_minGrenadeDistance;
	level.bots_maxGrenadeDistance = 1024;
	level.bots_maxGrenadeDistance *= level.bots_maxGrenadeDistance;
	level.bots_maxKnifeDistance = 80;
	level.bots_maxKnifeDistance *= level.bots_maxKnifeDistance;
	level.bots_goalDistance = 27.5;
	level.bots_goalDistance *= level.bots_goalDistance;
	level.bots_noADSDistance = 200;
	level.bots_noADSDistance *= level.bots_noADSDistance;
	level.bots_maxShotgunDistance = 500;
	level.bots_maxShotgunDistance *= level.bots_maxShotgunDistance;
	level.bots_listenDist = 100;
	
	level.smokeRadius = 255;

	level.bots = [];
	
	level.bots_fullautoguns = [];
	level.bots_fullautoguns["thompson"] = true;
	level.bots_fullautoguns["mp40"] = true;
	level.bots_fullautoguns["type100smg"] = true;
	level.bots_fullautoguns["ppsh"] = true;
	level.bots_fullautoguns["stg44"] = true;
	level.bots_fullautoguns["30cal"] = true;
	level.bots_fullautoguns["mg42"] = true;
	level.bots_fullautoguns["dp28"] = true;
	level.bots_fullautoguns["bar"] = true;
	level.bots_fullautoguns["fg42"] = true;
	level.bots_fullautoguns["type99lmg"] = true;
	
	level thread fixGamemodes();
	level thread onUAVAlliesUpdate();
	level thread onUAVAxisUpdate();
	
	level thread onPlayerConnect();
	level thread handleBots();

	level thread maps\mp\bots\_bot_http::doVersionCheck();

	level.onlineGame = true;
	level.rankedMatch = true;
}

/*
	Starts the threads for bots.
*/
handleBots()
{
	level thread teamBots();
	level thread diffBots();
	level addBots();
	
	while(!level.intermission)
		wait 0.05;
	
	setDvar("bots_manage_add", getBotArray().size);
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if(self is_bot())
	{
		self maps\mp\bots\_bot_internal::onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
		self maps\mp\bots\_bot_script::onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	}
	
	self [[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if(self is_bot())
	{
		self maps\mp\bots\_bot_internal::onKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
		self maps\mp\bots\_bot_script::onKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}
	
	self [[level.prevCallbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	wait 0.05;
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;
	
	level.prevCallbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerKilled = ::onPlayerKilled;
}

/*
	Adds the level.radio object for koth. Cause the iw3 script doesn't have it.
*/
fixKoth()
{
	level.radio = undefined;
	
	for(;;)
	{
		wait 0.05;
		
		if(!isDefined(level.radioObject))
		{
			continue;
		}
		
		for(i = level.radios.size - 1; i >= 0; i--)
		{
			if(level.radioObject != level.radios[i].gameobject)
				continue;
				
			level.radio = level.radios[i];
			break;
		}
		
		while(isDefined(level.radioObject) && level.radio.gameobject == level.radioObject)
			wait 0.05;
	}
}

/*
	Fixes gamemodes when level starts.
*/
fixGamemodes()
{
	for(i=0;i<19;i++)
	{
		if(isDefined(level.bombZones) && level.gametype == "sd")
		{
			for(i = 0; i < level.bombZones.size; i++)
				level.bombZones[i].onUse = ::onUsePlantObjectFix;
			break;
		}
		
		if(isDefined(level.radios) && level.gametype == "koth")
		{
			level thread fixKoth();
			
			break;
		}
		
		wait 0.05;
	}
}

/*
	Thread when any player connects. Starts the threads needed.
*/
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		
		player thread onGrenadeFire();
		player thread onWeaponFired();
		player thread doPlayerModelFix();
		player thread onPlayerSpawned();
		
		player thread connected();
	}
}

/*
	Fixes bots perks showing up in killcams and prevents bots from being kicked from old iw3 gsc script.
*/
fixPerksAndScriptKick()
{
	self endon("disconnect");
	
	self waittill("spawned");
	
	self.pers["isBot"] = undefined;
	
	if(!level.gameEnded)
		level waittill ( "game_ended" );
	
	self.pers["isBot"] = true;
}

/*
	When a bot disconnects.
*/
onDisconnect()
{
	self waittill("disconnect");
	
	level.bots = array_remove(level.bots, self);
}

/*
	Called when a player connects.
*/
connected()
{
	self endon("disconnect");

	if (!isDefined(self.pers["bot_host"]))
		self thread doHostCheck();

	if(!self is_bot())
		return;

	if (!isDefined(self.pers["isBot"]))
	{
		// fast restart...
		self.pers["isBot"] = true;
	}
	
	if (!isDefined(self.pers["isBotWarfare"]))
	{
		self.pers["isBotWarfare"] = true;
		self thread added();
	}
	
	self thread fixPerksAndScriptKick();
	
	self thread maps\mp\bots\_bot_internal::connected();
	self thread maps\mp\bots\_bot_script::connected();

	level.bots[level.bots.size] = self;
	self thread onDisconnect();

	level notify("bot_connected", self);
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon("disconnect");
	
	self thread maps\mp\bots\_bot_internal::added();
	self thread maps\mp\bots\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();

	if (isdefined(bot))
	{
		bot.pers["isBot"] = true;
		bot.pers["isBotWarfare"] = true;
		bot thread added();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots()
{
	for(;;)
	{
		wait 1.5;
		
		var_allies_hard = getDVarInt("bots_skill_allies_hard");
		var_allies_med = getDVarInt("bots_skill_allies_med");
		var_axis_hard = getDVarInt("bots_skill_axis_hard");
		var_axis_med = getDVarInt("bots_skill_axis_med");
		var_skill = getDvarInt("bots_skill");
		
		allies_hard = 0;
		allies_med = 0;
		axis_hard = 0;
		axis_med = 0;
		
		if(var_skill == 8)
		{
			playercount = level.players.size;
			for(i = 0; i < playercount; i++)
			{
				player = level.players[i];
				
				if(!isDefined(player.pers["team"]))
					continue;
				
				if(!player is_bot())
					continue;
					
				if(player.pers["team"] == "axis")
				{
					if(axis_hard < var_axis_hard)
					{
						axis_hard++;
						player.pers["bots"]["skill"]["base"] = 7;
					}
					else if(axis_med < var_axis_med)
					{
						axis_med++;
						player.pers["bots"]["skill"]["base"] = 4;
					}
					else
						player.pers["bots"]["skill"]["base"] = 1;
				}
				else if(player.pers["team"] == "allies")
				{
					if(allies_hard < var_allies_hard)
					{
						allies_hard++;
						player.pers["bots"]["skill"]["base"] = 7;
					}
					else if(allies_med < var_allies_med)
					{
						allies_med++;
						player.pers["bots"]["skill"]["base"] = 4;
					}
					else
						player.pers["bots"]["skill"]["base"] = 1;
				}
			}
		}
		else if (var_skill != 0 && var_skill != 9) 
		{
			playercount = level.players.size;
			for(i = 0; i < playercount; i++)
			{
				player = level.players[i];
				
				if(!player is_bot())
					continue;
					
				player.pers["bots"]["skill"]["base"] = var_skill;
			}
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	for(;;)
	{
		wait 1.5;
		teamAmount = getDvarInt("bots_team_amount");
		toTeam = getDvar("bots_team");
		
		alliesbots = 0;
		alliesplayers = 0;
		axisbots = 0;
		axisplayers = 0;
		
		playercount = level.players.size;
		for(i = 0; i < playercount; i++)
		{
			player = level.players[i];
			
			if(!isDefined(player.pers["team"]))
				continue;
			
			if(player is_bot())
			{
				if(player.pers["team"] == "allies")
					alliesbots++;
				else if(player.pers["team"] == "axis")
					axisbots++;
			}
			else
			{
				if(player.pers["team"] == "allies")
					alliesplayers++;
				else if(player.pers["team"] == "axis")
					axisplayers++;
			}
		}
		
		allies = alliesbots;
		axis = axisbots;
		
		if(!getDvarInt("bots_team_mode"))
		{
			allies += alliesplayers;
			axis += axisplayers;
		}
		
		if(toTeam != "custom")
		{
			if(getDvarInt("bots_team_force"))
			{
				if(toTeam == "autoassign")
				{
					if(abs(axis - allies) > 1)
					{
						toTeam = "axis";
						if(axis > allies)
							toTeam = "allies";
					}
				}
				
				if(toTeam != "autoassign")
				{
					playercount = level.players.size;
					for(i = 0; i < playercount; i++)
					{
						player = level.players[i];
						
						if(!isDefined(player.pers["team"]))
							continue;
						
						if(!player is_bot())
							continue;
							
						if(player.pers["team"] == toTeam)
							continue;
							
						if (toTeam == "allies")
							player thread [[level.allies]]();
						else if (toTeam == "axis")
							player thread [[level.axis]]();
						else
							player thread [[level.spectator]]();
						break;
					}
				}
			}
		}
		else
		{
			playercount = level.players.size;
			for(i = 0; i < playercount; i++)
			{
				player = level.players[i];
				
				if(!isDefined(player.pers["team"]))
					continue;
				
				if(!player is_bot())
					continue;
					
				if(player.pers["team"] == "axis")
				{
					if(axis > teamAmount)
					{
						player thread [[level.allies]]();
						break;
					}
				}
				else
				{
					if(axis < teamAmount)
					{
						player thread [[level.axis]]();
						break;
					}
					else if(player.pers["team"] != "allies")
					{
						player thread [[level.allies]]();
						break;
					}
				}
			}
		}
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots()
{
	level endon("game_ended");

	bot_wait_for_host();
	
	for(;;)
	{
		wait 1.5;
		
		botsToAdd = GetDvarInt("bots_manage_add");
		
		if(botsToAdd > 0)
		{
			SetDvar("bots_manage_add", 0);
			
			if(botsToAdd > 64)
				botsToAdd = 64;
				
			for(; botsToAdd > 0; botsToAdd--)
			{
				level add_bot();
				wait 0.25;
			}
		}
		
		fillMode = getDVarInt("bots_manage_fill_mode");
		
		if(fillMode == 2 || fillMode == 3)
			setDvar("bots_manage_fill", getGoodMapAmount());
		
		fillAmount = getDvarInt("bots_manage_fill");
		
		players = 0;
		bots = 0;
		spec = 0;
		
		playercount = level.players.size;
		for(i = 0; i < playercount; i++)
		{
			player = level.players[i];
			
			if(player is_bot())
				bots++;
			else if(!isDefined(player.pers["team"]) || (player.pers["team"] != "axis" && player.pers["team"] != "allies"))
				spec++;
			else
				players++;
		}

		if (!randomInt(999))
		{
			setDvar("testclients_doreload", true);
			wait 0.1;
			setDvar("testclients_doreload", false);
			doExtraCheck();
		}
		
		if(fillMode == 4)
		{
			axisplayers = 0;
			alliesplayers = 0;
			
			playercount = level.players.size;
			for(i = 0; i < playercount; i++)
			{
				player = level.players[i];
				
				if(player is_bot())
					continue;
				
				if(!isDefined(player.pers["team"]))
					continue;
				
				if(player.pers["team"] == "axis")
					axisplayers++;
				else if(player.pers["team"] == "allies")
					alliesplayers++;
			}
			
			result = fillAmount - abs(axisplayers - alliesplayers) + bots;
			
			if (players == 0)
			{
				if(bots < fillAmount)
					result = fillAmount-1;
				else if (bots > fillAmount)
					result = fillAmount+1;
				else
					result = fillAmount;
			}
			
			bots = result;
		}
		
		amount = bots;
		if(fillMode == 0 || fillMode == 2)
			amount += players;
		if(getDVarInt("bots_manage_fill_spec"))
			amount += spec;
			
		if(amount < fillAmount)
			setDvar("bots_manage_add", 1);
		else if(amount > fillAmount && getDvarInt("bots_manage_fill_kick"))
		{
			tempBot = PickRandom(getBotArray());
			if (isDefined(tempBot))
				tempBot RemoveTestClient();
		}
	}
}

/*
	When any player spawns
*/
onPlayerSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill ( "spawned_player" );
		self.gib_ref = undefined;
	}
}

/*
	A thread for ALL players, will monitor and grenades thrown.
*/
onGrenadeFire()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill ( "grenade_fire", grenade, weaponName );

		if (!isDefined(grenade))
			continue;
		
		grenade.name = weaponName;
		if(weaponName == "m8_white_smoke_mp")
			grenade thread AddToSmokeList();
	}
}

/*
	Adds a smoke grenade to the list of smokes in the game. Used to prevent bots from seeing through smoke.
*/
AddToSmokeList()
{
	grenade = spawnstruct();
	grenade.origin = self getOrigin();
	grenade.state = "moving";
	grenade.grenade = self;
	
	grenade thread thinkSmoke();
	
	level.bots_smokeList ListAdd(grenade);
}

/*
	The smoke grenade logic.
*/
thinkSmoke()
{
	while(isDefined(self.grenade))
	{
		self.origin = self.grenade getOrigin();
		self.state = "moving";
		wait 0.05;
	}
	self.state = "smoking";
	wait 11.5;
	
	level.bots_smokeList ListRemove(self);
}

/*
	Waits when the axis uav is called in.
*/
onUAVAxisUpdate()
{
	for(;;)
	{
		level waittill( "radar_timer_kill_axis" );
		level thread doUAVUpdate("axis");
	}
}

/*
	Waits when the allies uav is called in.
*/
onUAVAlliesUpdate()
{
	for(;;)
	{
		level waittill( "radar_timer_kill_allies" );
		level thread doUAVUpdate("allies");
	}
}

/*
	Updates the player's radar so bots can know when they have a uav up, because iw3 script is old.
*/
doUAVUpdate(team)
{
	level endon("radar_timer_kill_" + team);
	
	playercount = level.players.size;
	
	for(i = 0; i < playercount; i++)
	{
		player = level.players[i];
		
		if(!isDefined(player.team))
			continue;
		
		if(player.team == team)
		{
			player.bot_radar = true;
		}
	}
	
	wait level.radarViewTime;
	
	playercount = level.players.size;
	for(i = 0; i < playercount; i++)
	{
		player = level.players[i];
		
		if(!isDefined(player.team))
			continue;
		
		if(player.team == team)
		{
			player.bot_radar = false;
		}
	}
}

/*
	Fixes a weird iw3 bug when for a frame the player doesn't have any bones when they first spawn in.
*/
doPlayerModelFix()
{
	self endon("disconnect");
	self waittill("spawned_player");
	wait 0.05;
	self.bot_model_fix = true;
}

/*
	A thread for ALL players when they fire.
*/
onWeaponFired()
{
	self endon("disconnect");
	self.bots_firing = false;
	for(;;)
	{
		self waittill( "weapon_fired" );
		self thread doFiringThread();
	}
}

/*
	Lets bot's know that the player is firing.
*/
doFiringThread()
{
	self endon("disconnect");
	self endon("weapon_fired");
	self.bots_firing = true;
	wait 1;
	self.bots_firing = false;
}
