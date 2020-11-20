#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Returns if player is the host
*/
is_host()
{
	return (isDefined(self.pers["bot_host"]) && self.pers["bot_host"]);
}

/*
	Setups the host variable on the player
*/
doHostCheck()
{
	self.pers["bot_host"] = false;

	if (self is_bot())
		return;

	DvarGUID = getDvar("bots_main_GUIDs");
	result = false;
	if (DvarGUID != "")
	{
		guids = strtok(DvarGUID, ",");

		for (i = 0; i < guids.size; i++)
		{
			if(self getguid() == guids[i])
				result = true;
		}
	}
	
	if (!result)
		return;

	self.pers["bot_host"] = true;
}

/*
	Returns if the player is a bot.
*/
is_bot()
{
	return ((isDefined(self.pers["isBot"]) && self.pers["isBot"]) || (isDefined(self.pers["isBotWarfare"]) && self.pers["isBotWarfare"]));
}

/*
	Bot changes to the weap
*/
BotChangeToWeapon(weap)
{
	//self maps\mp\bots\_bot_internal::changeToWeap(weap);
}

/*
	Bot presses the button for time.
*/
BotPressAttack(time)
{
//	self maps\mp\bots\_bot_internal::pressFire(time);
}

/*
	Bot presses the ads button for time.
*/
BotPressADS(time)
{
	//self maps\mp\bots\_bot_internal::pressADS(time);
}

/*
	Bot presses the frag button for time.
*/
BotPressFrag(time)
{
	//self maps\mp\bots\_bot_internal::frag(time);
}

/*
	Bot presses the smoke button for time.
*/
BotPressSmoke(time)
{
	//self maps\mp\bots\_bot_internal::smoke(time);
}

/*
	Returns the bot's random assigned number.
*/
BotGetRandom()
{
	return self.bot.rand;
}

/*
	Returns a random number thats different everytime it changes target
*/
BotGetTargetRandom()
{
	if (!isDefined(self.bot.target))
		return undefined;

	return self.bot.target.rand;
}

/*
	Returns if the bot is fragging.
*/
IsBotFragging()
{
	return self.bot.isfraggingafter;
}

/*
	Returns if the bot is pressing smoke button.
*/
IsBotSmoking()
{
	return self.bot.issmokingafter;
}

/*
	Returns if the bot is sprinting.
*/
IsBotSprinting()
{
	return self.bot.issprinting;
}

/*
	Returns if the bot is reloading.
*/
IsBotReloading()
{
	return self.bot.isreloading;
}

/*
	Is bot knifing
*/
IsBotKnifing()
{
	return self.bot.isknifingafter;
}

/*
	Freezes the bot's controls.
*/
BotFreezeControls(what)
{
	self.bot.isfrozen = what;
	if(what)
		self notify("kill_goal");
}

/*
	Returns if the bot is script frozen.
*/
BotIsFrozen()
{
	return self.bot.isfrozen;
}

/*
	Bot will stop moving
*/
BotStopMoving(what)
{
	self.bot.stop_move = what;

	if(what)
		self notify("kill_goal");
}

/*
	Returns if the bot has a script goal.
	(like t5 gsc bot)
*/
HasScriptGoal()
{
	return (isDefined(self GetScriptGoal()));
}

/*
	Returns the pos of the bot's goal
*/
GetScriptGoal()
{
	return self.bot.script_goal;
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoal(goal, dist)
{
	if (!isDefined(dist))
		dist = 16;
	self.bot.script_goal = goal;
	self.bot.script_goal_dist = dist;
	waittillframeend;
	self notify("new_goal_internal");
	self notify("new_goal");
}

/*
	Clears the bot's goal.
*/
ClearScriptGoal()
{
	self SetScriptGoal(undefined, 0);
}

/*
	Sets the aim position of the bot
*/
SetScriptAimPos(pos)
{
	self.bot.script_aimpos = pos;
}

/*
	Clears the aim position of the bot
*/
ClearScriptAimPos()
{
	self SetScriptAimPos(undefined);
}

/*
	Returns the aim position of the bot
*/
GetScriptAimPos()
{
	return self.bot.script_aimpos;
}

/*
	Returns if the bot has a aim pos
*/
HasScriptAimPos()
{
	return isDefined(self GetScriptAimPos());
}

/*
	Sets the bot's target to be this ent.
*/
SetAttacker(att)
{
	self.bot.target_this_frame = att;
}

/*
	Sets the script enemy for a bot.
*/
SetScriptEnemy(enemy, offset)
{
	self.bot.script_target = enemy;
	self.bot.script_target_offset = offset;
}

/*
	Removes the script enemy of the bot.
*/
ClearScriptEnemy()
{
	self SetScriptEnemy(undefined, undefined);
}

/*
	Returns the entity of the bot's target.
*/
GetThreat()
{
	if(!isdefined(self.bot.target))
		return undefined;
		
	return self.bot.target.entity;
}

/*
	Returns if the bot has a script enemy.
*/
HasScriptEnemy()
{
	return (isDefined(self.bot.script_target));
}

/*
	Returns if the bot has a threat.
*/
HasThreat()
{
	return (isDefined(self GetThreat()));
}

/*
	If the player is defusing
*/
IsDefusing()
{
	return (isDefined(self.isDefusing) && self.isDefusing);
}

/*
	If the play is planting
*/
isPlanting()
{
	return (isDefined(self.isPlanting) && self.isPlanting);
}

/*
	If the player is in laststand
*/
inLastStand()
{
	return (isDefined(self.lastStand) && self.lastStand);
}

/*
	Returns if we are stunned.
*/
IsStunned()
{
	return (isdefined(self.concussionEndTime) && self.concussionEndTime > gettime());
}

/*
	Returns if we are beingArtilleryShellshocked 
*/
isArtShocked()
{
	return (isDefined(self.beingArtilleryShellshocked) && self.beingArtilleryShellshocked);
}

/*
	Returns a valid grenade launcher weapon
*/
getValidTube()
{
	weaps = self getweaponslist();

	for (i = 0; i < weaps.size; i++)
	{
		weap = weaps[i];

		if(!self getAmmoCount(weap))
			continue;

		if (isSubStr(weap, "gl_") && !isSubStr(weap, "_gl_"))
			return weap;
	}

	return undefined;
}

/*
	Returns a random grenade in the bot's inventory.
*/
getValidGrenade()
{
	grenadeTypes = [];
	grenadeTypes[grenadeTypes.size] = "frag_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "smoke_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "flash_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "concussion_grenade_mp";
	
	possibles = [];
	
	for(i = 0; i < grenadeTypes.size; i++)
	{
		if ( !self hasWeapon( grenadeTypes[i] ) )
			continue;
			
		if ( !self getAmmoCount( grenadeTypes[i] ) )
			continue;
			
		possibles[possibles.size] = grenadeTypes[i];
	}
	
	return random(possibles);
}

/*
	Returns if the given weapon is full auto.
*/
WeaponIsFullAuto(weap)
{
	weaptoks = strtok(weap, "_");
	
	return isDefined(weaptoks[0]) && isString(weaptoks[0]) && isdefined(level.bots_fullautoguns[weaptoks[0]]);
}

/*
	Returns what our eye height is.
*/
GetEyeHeight()
{
	myEye = self GetEyePos();
	
	return myEye[2] - self.origin[2];
}

/*
	Returns (iw4) eye pos.
*/
GetEyePos()
{
	return self getTagOrigin("tag_eye");
}

/*
	Returns if we have the create a class object unlocked.
*/
isItemUnlocked(what, lvl)
{
	switch(what)
	{
		case "m1carbine":
			return (lvl >= 65);
		case "m1garand":
			return (lvl >= 17);
		case "mg42":
			return (lvl >= 33);
		case "mosinrifle":
			return (lvl >= 21);
		case "mp40":
			return (lvl >= 10);
		case "ppsh":
			return (lvl >= 53);
		case "ptrs41":
			return (lvl >= 57);
		case "shotgun":
			return true;
		case "springfield":
			return true;
		case "stg44":
			return (lvl >= 37);
		case "svt40":
			return true;
		case "thompson":
			return true;
		case "type99rifle":
			return true;
		case "type100smg":
			return (lvl >= 25);
		case "type99lmg":
			return true;
		case "kar98k":
			return (lvl >= 41);
		case "gewehr43":
			return (lvl >= 7);
		case "fg42":
			return (lvl >= 45);
		case "doublebarreledshotgun":
			return (lvl >= 29);
		case "bar":
			return true;
		case "30cal":
			return (lvl >= 61);
		case "dp28":
			return (lvl >= 13);
		case "walther":
			return true;
		case "357magnum":
			return (lvl >= 49);
		case "colt":
			return true;
		case "nambu":
			return true;
		case "tokarev":
			return (lvl >= 21);
		case "frag_grenade_mp":
			return true;
		case "molotov_mp":
			return (lvl >= 10);
		case "sticky_grenade_mp":
			return true;
		case "specialty_water_cooled":
			return true;
		case "specialty_greased_barrings":
			return true;
		case "specialty_ordinance":
			return (lvl >= 12);
		case "specialty_boost":
			return (lvl >= 28);
		case "specialty_leadfoot":
			return (lvl >= 40);
		case "specialty_bulletdamage":
			return true;
		case "specialty_armorvest":
			return true;
		case "specialty_fastreload":
			return (lvl >= 28);
		case "specialty_rof":
			return (lvl >= 36);
		case "specialty_twoprimaries":
			return (lvl >= 56);
		case "specialty_gpsjammer":
			return (lvl >= 12);
		case "specialty_explosivedamage":
			return true;
		case "specialty_flakjacket":
			return true;
		case "specialty_shades":
			return (lvl >= 32);
		case "specialty_gas_mask":
			return true;
		case "specialty_longersprint":
			return true;
		case "specialty_bulletaccuracy":
			return true;
		case "specialty_pistoldeath":
			return (lvl >= 9);
		case "specialty_grenadepulldeath":
			return (lvl >= 20);
		case "specialty_bulletpenetration":
			return true;
		case "specialty_holdbreath":
			return (lvl >= 60);
		case "specialty_quieter":
			return (lvl >= 52);
		case "specialty_fireproof":
			return (lvl >= 48);
		case "specialty_reconnaissance":
			return (lvl >= 64);
		case "specialty_pin_back":
			return (lvl >= 6);
		case "specialty_specialgrenade":
			return true;
		case "specialty_weapon_bouncing_betty":
			return (lvl >= 24);
		case "specialty_weapon_flamethrower":
			return (lvl >= 65);
		case "specialty_fraggrenade":
			return (lvl >= 44);
		case "specialty_extraammo":
			return (lvl >= 40);
		case "specialty_detectexplosive":
			return (lvl >= 16);
		case "specialty_weapon_bazooka":
			return true;
		case "specialty_weapon_satchel_charge":
			return true;
		default:
			return true;
	}
}

/*
	If the weapon  is allowed to be dropped
*/
isWeaponDroppable(weap)
{
	return (maps\mp\gametypes\_weapons::mayDropWeapon(weap));
}

/*
	Waits until not or tim.
*/
waittill_notify_or_timeout(not, tim)
{
	self endon(not);
	wait tim;
}

/*
	Pezbot's line sphere intersection.
*/
RaySphereIntersect(start, end, spherePos, radius)
{
   dp = end - start;
   a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
   b = 2 * (dp[0] * (start[0] - spherePos[0]) + dp[1] * (start[1] - spherePos[1]) + dp[2] * (start[2] - spherePos[2]));
   c = spherePos[0] * spherePos[0] + spherePos[1] * spherePos[1] + spherePos[2] * spherePos[2];
   c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
   c -= 2.0 * (spherePos[0] * start[0] + spherePos[1] * start[1] + spherePos[2] * start[2]);
   c -= radius * radius;
   bb4ac = b * b - 4.0 * a * c;
   
   return (bb4ac >= 0);
}

/*
	Returns if a smoke grenade would intersect start to end line.
*/
SmokeTrace(start, end, rad)
{
	for(i = level.bots_smokeList.count - 1; i >= 0; i--)
	{
		nade = level.bots_smokeList.data[i];
		
		if(nade.state != "smoking")
			continue;
			
		if(!RaySphereIntersect(start, end, nade.origin, rad))
			continue;
		
		return false;
	}
	
	return true;
}

/*
	Returns the cone dot (like fov, or distance from the center of our screen). 1.0 = directly looking at, 0.0 = completely right angle, -1.0, completely 180
*/
getConeDot(to, from, dir)
{
    dirToTarget = VectorNormalize(to-from);
    forward = AnglesToForward(dir);
    return vectordot(dirToTarget, forward);
}

/*
	Returns the distance squared in a 2d space
*/
DistanceSquared2D(to, from)
{
	to = (to[0], to[1], 0);
	from = (from[0], from[1], 0);
	
	return DistanceSquared(to, from);
}

/*
	Rounds to the nearest whole number.
*/
Round(x)
{
	y = int(x);
	
	if(abs(x) - abs(y) > 0.5)
	{
		if(x < 0)
			return y - 1;
		else
			return y + 1;
	}
	else
		return y;
}

/*
	Rounds up the given value.
*/
RoundUp( floatVal )
{
	i = int( floatVal );
	if ( i != floatVal )
		return i + 1;
	else
		return i;
}

/*
	Creates indexers for the create a class objects.
*/
cac_init_patch()
{
	// oldschool mode does not create these, we need those tho.
	if(!isDefined(level.tbl_weaponIDs))
	{
		level.tbl_weaponIDs = [];
		for( i=0; i<150; i++ )
		{
			reference_s = tableLookup( "mp/statsTable.csv", 0, i, 4 );
			if( reference_s != "" )
			{ 
				level.tbl_weaponIDs[i]["reference"] = reference_s;
				level.tbl_weaponIDs[i]["group"] = tablelookup( "mp/statstable.csv", 0, i, 2 );
				level.tbl_weaponIDs[i]["count"] = int( tablelookup( "mp/statstable.csv", 0, i, 5 ) );
				level.tbl_weaponIDs[i]["attachment"] = tablelookup( "mp/statstable.csv", 0, i, 8 );	
			}
			else
				continue;
		}
	}
	
	if(!isDefined(level.tbl_WeaponAttachment))
	{
		level.tbl_WeaponAttachment = [];
		for( i=0; i<13; i++ )
		{
			level.tbl_WeaponAttachment[i]["bitmask"] = int( tableLookup( "mp/attachmentTable.csv", 9, i, 10 ) );
			level.tbl_WeaponAttachment[i]["reference"] = tableLookup( "mp/attachmentTable.csv", 9, i, 4 );
		}
	}
	
	if(!isDefined(level.tbl_PerkData))
	{
		level.tbl_PerkData = [];
		// generating perk data vars collected form statsTable.csv
		for( i=150; i<194; i++ )
		{
			reference_s = tableLookup( "mp/statsTable.csv", 0, i, 4 );
			if( reference_s != "" )
			{
				level.tbl_PerkData[i]["reference"] = reference_s;
				level.tbl_PerkData[i]["reference_full"] = tableLookup( "mp/statsTable.csv", 0, i, 6 );
				level.tbl_PerkData[i]["count"] = int( tableLookup( "mp/statsTable.csv", 0, i, 5 ) );
				level.tbl_PerkData[i]["group"] = tableLookup( "mp/statsTable.csv", 0, i, 2 );
				level.tbl_PerkData[i]["name"] = tableLookupIString( "mp/statsTable.csv", 0, i, 3 );
				level.tbl_PerkData[i]["perk_num"] = tableLookup( "mp/statsTable.csv", 0, i, 8 );
			}
			else
				continue;
		}
	}

	level.perkReferenceToIndex = [];
	level.weaponReferenceToIndex = [];
	level.weaponAttachmentReferenceToIndex = [];
	
	for( i=0; i<150; i++ )
	{
		if(!isDefined(level.tbl_weaponIDs[i]) || !isDefined(level.tbl_weaponIDs[i]["reference"]))
			continue;
			
		level.weaponReferenceToIndex[level.tbl_weaponIDs[i]["reference"]] = i;
	}
	
	for( i=0; i<13; i++ )
	{
		if(!isDefined(level.tbl_WeaponAttachment[i]) || !isDefined(level.tbl_WeaponAttachment[i]["reference"]))
			continue;
			
		level.weaponAttachmentReferenceToIndex[level.tbl_WeaponAttachment[i]["reference"]] = i;
	}
	
	for( i=150; i<194; i++ )
	{
		if(!isDefined(level.tbl_PerkData[i]) || !isDefined(level.tbl_PerkData[i]["reference_full"]))
			continue;
	
		level.perkReferenceToIndex[ level.tbl_PerkData[i]["reference_full"] ] = i;
	}
}

/*
	Tokenizes a string (strtok has limits...) (only one char tok)
*/
tokenizeLine(line, tok)
{
  tokens = [];

  token = "";
  for (i = 0; i < line.size; i++)
  {
    c = line[i];

    if (c == tok)
    {
      tokens[tokens.size] = token;
      token = "";
      continue;
    }

    token += c;
  }
  tokens[tokens.size] = token;

  return tokens;
}

/*
	Loads the waypoints. Populating everything needed for the waypoints.
*/
load_waypoints()
{
	mapname = getDvar("mapname");
	
	level.waypointCount = 0;
	level.waypoints = [];

	switch(mapname)
	{
		case "mp_airfield":
			level.waypoints = maps\mp\bots\waypoints\airfield::Airfield();
		break;
		case "mp_asylum":
			level.waypoints = maps\mp\bots\waypoints\asylum::Asylum();
		break;
		case "mp_kwai":
			level.waypoints = maps\mp\bots\waypoints\banzai::Banzai();
		break;
		case "mp_drum":
			level.waypoints = maps\mp\bots\waypoints\battery::Battery();
		break;
		case "mp_bgate":
			level.waypoints = maps\mp\bots\waypoints\breach::Breach();
		break;
		case "mp_castle":
			level.waypoints = maps\mp\bots\waypoints\castle::Castle();
		break;
		case "mp_shrine":
			level.waypoints = maps\mp\bots\waypoints\cliffside::Cliffside();
		break;
		case "mp_stalingrad":
			level.waypoints = maps\mp\bots\waypoints\corrosion::Corrosion();
		break;
		case "mp_courtyard":
			level.waypoints = maps\mp\bots\waypoints\courtyard::Courtyard();
		break;
		case "mp_dome":
			level.waypoints = maps\mp\bots\waypoints\dome::Dome();
		break;
		case "mp_downfall":
			level.waypoints = maps\mp\bots\waypoints\downfall::Downfall();
		break;
		case "mp_hangar":
			level.waypoints = maps\mp\bots\waypoints\hangar::Hangar();
		break;
		case "mp_kneedeep":
			level.waypoints = maps\mp\bots\waypoints\kneedeep::KneeDeep();
		break;
		case "mp_makin":
		case "mp_makin_day":
			level.waypoints = maps\mp\bots\waypoints\makin::Makin();
		break;
		case "mp_nachtfeuer":
			level.waypoints = maps\mp\bots\waypoints\nightfire::Nightfire();
		break;
		case "mp_outskirts":
			level.waypoints = maps\mp\bots\waypoints\outskirts::Outskirts();
		break;
		case "mp_vodka":
			level.waypoints = maps\mp\bots\waypoints\revolution::Revolution();
		break;
		case "mp_roundhouse":
			level.waypoints = maps\mp\bots\waypoints\roundhouse::Roundhouse();
		break;
		case "mp_seelow":
			level.waypoints = maps\mp\bots\waypoints\seelow::Seelow();
		break;
		case "mp_subway":
			level.waypoints = maps\mp\bots\waypoints\station::Station();
		break;
		case "mp_docks":
			level.waypoints = maps\mp\bots\waypoints\subpens::SubPens();
		break;
		case "mp_suburban":
			level.waypoints = maps\mp\bots\waypoints\upheaval::Upheaval();
		break;
		
		default:
			maps\mp\bots\waypoints\_custom_map::main(mapname);
		break;
	}

	if (level.waypoints.size)
		println("Loaded " + level.waypoints.size + " waypoints from script.");

	level.waypointCount = level.waypoints.size;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		level.waypoints[i].index = i;
		level.waypoints[i].bots = [];
		level.waypoints[i].bots["allies"] = 1;
		level.waypoints[i].bots["axis"] = 1;

		level.waypoints[i].childCount = level.waypoints[i].children.size;
	}
	
	level.waypointsKDTree = WaypointsToKDTree();
	
	level.waypointsCamp = [];
	level.waypointsTube = [];
	level.waypointsGren = [];
	level.waypointsClay = [];
	
	for(i = 0; i < level.waypointCount; i++)
		if(level.waypoints[i].type == "crouch" && level.waypoints[i].childCount == 1)
			level.waypointsCamp[level.waypointsCamp.size] = level.waypoints[i];
		else if(level.waypoints[i].type == "tube")
			level.waypointsTube[level.waypointsTube.size] = level.waypoints[i];
		else if(level.waypoints[i].type == "grenade")
			level.waypointsGren[level.waypointsGren.size] = level.waypoints[i];
		else if(level.waypoints[i].type == "claymore")
			level.waypointsClay[level.waypointsClay.size] = level.waypoints[i];
}

/*
	Returns a good amount of players.
*/
getGoodMapAmount()
{
	switch(getDvar("mapname"))
	{
		case "mp_kneedeep":
		case "mp_seelow":
		case "mp_outskirts":
		case "mp_downfall":
		case "mp_roundhouse":
			if(level.teamBased)
				return 14;
			else
				return 9;
			
		case "mp_suburban":
		case "mp_docks":
		case "mp_subway":
		case "mp_vodka":
		case "mp_nachtfeuer":
		case "mp_makin_day":
		case "mp_makin":
		case "mp_hangar":
		case "mp_courtyard":
		case "mp_stalingrad":
		case "mp_shrine":
		case "mp_kwai":
		case "mp_castle":
		case "mp_asylum":
		case "mp_airfield":
		case "mp_bgate":
			if(level.teamBased)
				return 12;
			else
				return 8;
			
		case "mp_dome":
		case "mp_drum":
			if(level.teamBased)
				return 8;
			else
				return 4;
	}
	
	return 2;
}

/*
	Returns the friendly user name for a given map's codename
*/
getMapName(map)
{
	switch(map)
	{
		case "mp_airfield":
			return "Airfield";
		case "mp_asylum":
			return "Asylum";
		case "mp_kwai":
			return "Banzai";
		case "mp_drum":
			return "Battery";
		case "mp_castle":
			return "Castle";
		case "mp_shrine":
			return "Cliffside";
		case "mp_stalingrad":
			return "Corrosion";
		case "mp_courtyard":
			return "Courtyard";
		case "mp_dome":
			return "Dome";
		case "mp_downfall":
			return "Downfall";
		case "mp_hangar":
			return "Hangar";
		case "mp_kneedeep":
			return "Knee Deep";
		case "mp_makin":
			return "Makin";
		case "mp_makin_day":
			return "Makin Day";
		case "mp_nachtfeuer":
			return "Nightfire";
		case "mp_outskirts":
			return "Outskirts";
		case "mp_vodka":
			return "Revolution";
		case "mp_roundhouse":
			return "Roundhouse";
		case "mp_seelow":
			return "Seelow";
		case "mp_subway":
			return "Station";
		case "mp_docks":
			return "Sub Pens";
		case "mp_suburban":
			return "Upheaval";
		case "mp_bgate":
			return "Breach";
	}
	
	return map;
}

/*
	Returns an array of all the bots in the game.
*/
getBotArray()
{
	result = [];
	playercount = level.players.size;
	for(i = 0; i < playercount; i++)
	{
		player = level.players[i];
		
		if(!player is_bot())
			continue;
			
		result[result.size] = player;
	}
	
	return result;
}

/*
	We return a balanced KDTree from the waypoints.
*/
WaypointsToKDTree()
{
	kdTree = KDTree();
	
	kdTree _WaypointsToKDTree(level.waypoints, 0);
	
	return kdTree;
}

/*
	Recurive function. We construct a balanced KD tree by sorting the waypoints using heap sort.
*/
_WaypointsToKDTree(waypoints, dem)
{
	if(!waypoints.size)
		return;

	callbacksort = undefined;
	
	switch(dem)
	{
		case 0:
			callbacksort = ::HeapSortCoordX;
		break;
		case 1:
			callbacksort = ::HeapSortCoordY;
		break;
		case 2:
			callbacksort = ::HeapSortCoordZ;
		break;
	}
	
	heap = NewHeap(callbacksort);
	
	for(i = 0; i < waypoints.size; i++)
	{
		heap HeapInsert(waypoints[i]);
	}
	
	sorted = [];
	while(heap.data.size)
	{
		sorted[sorted.size] = heap.data[0];
		heap HeapRemove();
	}
	
	median = int(sorted.size/2);//use divide and conq
	
	left = [];
	right = [];
	for(i = 0; i < sorted.size; i++)
		if(i < median)
			right[right.size] = sorted[i];
		else if(i > median)
			left[left.size] = sorted[i];
	
	self KDTreeInsert(sorted[median]);
	
	_WaypointsToKDTree(left, (dem+1)%3);
	
	_WaypointsToKDTree(right, (dem+1)%3);
}

/*
	Returns a new list.
*/
List()
{
	list = spawnStruct();
	list.count = 0;
	list.data = [];
	
	return list;
}

/*
	Adds a new thing to the list.
*/
ListAdd(thing)
{
	self.data[self.count] = thing;
	
	self.count++;
}

/*
	Adds to the start of the list.
*/
ListAddFirst(thing)
{
	for (i = self.count - 1; i >= 0; i--)
	{
		self.data[i + 1] = self.data[i];
	}

	self.data[0] = thing;
	self.count++;
}

/*
	Removes the thing from the list.
*/
ListRemove(thing)
{
	for ( i = 0; i < self.count; i++ )
	{
		if ( self.data[i] == thing )
		{
			while ( i < self.count-1 )
			{
				self.data[i] = self.data[i+1];
				i++;
			}
			
			self.data[i] = undefined;
			self.count--;
			break;
		}
	}
}

/*
	Returns a new KDTree.
*/
KDTree()
{
	kdTree = spawnStruct();
	kdTree.root = undefined;
	kdTree.count = 0;
	
	return kdTree;
}

/*
	Called on a KDTree. Will insert the object into the KDTree.
*/
KDTreeInsert(data)//as long as what you insert has a .origin attru, it will work.
{
	self.root = self _KDTreeInsert(self.root, data, 0, -9999999999, -9999999999, -9999999999, 9999999999, 9999999999, 9999999999);
}

/*
	Recurive function that insert the object into the KDTree.
*/
_KDTreeInsert(node, data, dem, x0, y0, z0, x1, y1, z1)
{
	if(!isDefined(node))
	{
		r = spawnStruct();
		r.data = data;
		r.left = undefined;
		r.right = undefined;
		r.x0 = x0;
		r.x1 = x1;
		r.y0 = y0;
		r.y1 = y1;
		r.z0 = z0;
		r.z1 = z1;
		
		self.count++;
		
		return r;
	}
	
	switch(dem)
	{
		case 0:
			if(data.origin[0] < node.data.origin[0])
				node.left = self _KDTreeInsert(node.left, data, 1, x0, y0, z0, node.data.origin[0], y1, z1);
			else
				node.right = self _KDTreeInsert(node.right, data, 1, node.data.origin[0], y0, z0, x1, y1, z1);
		break;
		case 1:
			if(data.origin[1] < node.data.origin[1])
				node.left = self _KDTreeInsert(node.left, data, 2, x0, y0, z0, x1, node.data.origin[1], z1);
			else
				node.right = self _KDTreeInsert(node.right, data, 2, x0, node.data.origin[1], z0, x1, y1, z1);
		break;
		case 2:
			if(data.origin[2] < node.data.origin[2])
				node.left = self _KDTreeInsert(node.left, data, 0, x0, y0, z0, x1, y1, node.data.origin[2]);
			else
				node.right = self _KDTreeInsert(node.right, data, 0, x0, y0, node.data.origin[2], x1, y1, z1);
		break;
	}
	
	return node;
}

/*
	Called on a KDTree, will return the nearest object to the given origin.
*/
KDTreeNearest(origin)
{
	if(!isDefined(self.root))
		return undefined;
	
	return self _KDTreeNearest(self.root, origin, self.root.data, DistanceSquared(self.root.data.origin, origin), 0);
}

/*
	Recurive function that will retrieve the closest object to the query.
*/
_KDTreeNearest(node, point, closest, closestdist, dem)
{
	if(!isDefined(node))
	{
		return closest;
	}
	
	thisDis = DistanceSquared(node.data.origin, point);
	
	if(thisDis < closestdist)
	{
		closestdist = thisDis;
		closest = node.data;
	}
	
	if(node RectDistanceSquared(point) < closestdist)
	{
		near = node.left;
		far = node.right;
		if(point[dem] > node.data.origin[dem])
		{
			near = node.right;
			far = node.left;
		}
		
		closest = self _KDTreeNearest(near, point, closest, closestdist, (dem+1)%3);
		
		closest = self _KDTreeNearest(far, point, closest, DistanceSquared(closest.origin, point), (dem+1)%3);
	}
	
	return closest;
}

/*
	Called on a rectangle, returns the distance from origin to the rectangle.
*/
RectDistanceSquared(origin)
{
	dx = 0;
	dy = 0;
	dz = 0;
	
	if(origin[0] < self.x0)
		dx = origin[0] - self.x0;
	else if(origin[0] > self.x1)
		dx = origin[0] - self.x1;
		
	if(origin[1] < self.y0)
		dy = origin[1] - self.y0;
	else if(origin[1] > self.y1)
		dy = origin[1] - self.y1;

		
	if(origin[2] < self.z0)
		dz = origin[2] - self.z0;
	else if(origin[2] > self.z1)
		dz = origin[2] - self.z1;
		
	return dx*dx + dy*dy + dz*dz;
}

/*
	A heap invarient comparitor, used for objects, objects with a higher X coord will be first in the heap.
*/
HeapSortCoordX(item, item2)
{
	return item.origin[0] > item2.origin[0];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Y coord will be first in the heap.
*/
HeapSortCoordY(item, item2)
{
	return item.origin[1] > item2.origin[1];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Z coord will be first in the heap.
*/
HeapSortCoordZ(item, item2)
{
	return item.origin[2] > item2.origin[2];
}

/*
	A heap invarient comparitor, used for numbers, numbers with the highest number will be first in the heap.
*/
Heap(item, item2)
{
	return item > item2;
}

/*
	A heap invarient comparitor, used for numbers, numbers with the lowest number will be first in the heap.
*/
ReverseHeap(item, item2)
{
	return item < item2;
}

/*
	A heap invarient comparitor, used for traces. Wanting the trace with the largest length first in the heap.
*/
HeapTraceFraction(item, item2)
{
	return item["fraction"] > item2["fraction"];
}

/*
	Returns a new heap.
*/
NewHeap(compare)
{
	heap_node = spawnStruct();
	heap_node.data = [];
	heap_node.compare = compare;
	
	return heap_node;
}

/*
	Inserts the item into the heap. Called on a heap.
*/
HeapInsert(item)
{
	insert = self.data.size;
	self.data[insert] = item;
	
	current = insert+1;
	
	while(current > 1)
	{
		last = current;
		current = int(current/2);
		
		if(![[self.compare]](item, self.data[current-1]))
			break;
			
		self.data[last-1] = self.data[current-1];
		self.data[current-1] = item;
	}
}

/*
	Helper function to determine what is the next child of the bst.
*/
_HeapNextChild(node, hsize)
{
	left = node * 2;
	right = left + 1;
	
	if(left > hsize)
		return -1;
		
	if(right > hsize)
		return left;
		
	if([[self.compare]](self.data[left-1], self.data[right-1]))
		return left;
	else
		return right;
}

/*
	Removes an item from the heap. Called on a heap.
*/
HeapRemove()
{
	remove = self.data.size;
	
	if(!remove)
		return remove;
	
	move = self.data[remove-1];
	self.data[0] = move;
	self.data[remove-1] = undefined;
	remove--;
	
	if(!remove)
		return remove;
	
	last = 1;
	next = self _HeapNextChild(1, remove);
	
	while(next != -1)
	{
		if([[self.compare]](move, self.data[next-1]))
			break;
			
		self.data[last-1] = self.data[next-1];
		self.data[next-1] = move;
		
		last = next;
		next = self _HeapNextChild(next, remove);
	}
	
	return remove;
}

/*
	A heap invarient comparitor, used for the astar's nodes, wanting the node with the lowest f to be first in the heap.
*/
ReverseHeapAStar(item, item2)
{
	return item.f < item2.f;
}

/*
	Will linearly search for the nearest waypoint to pos that has a direct line of sight.
*/
GetNearestWaypointWithSight(pos)
{
	candidate = undefined;
	dist = 9999999999;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		if(!bulletTracePassed(pos + (0, 0, 15), level.waypoints[i].origin + (0, 0, 15), false, undefined))
			continue;
		
		curdis = DistanceSquared(level.waypoints[i].origin, pos);
		if(curdis > dist)
			continue;
			
		dist = curdis;
		candidate = level.waypoints[i];
	}
	
	return candidate;
}

/*
	Modified Pezbot astar search.
	This makes use of sets for quick look up and a heap for a priority queue instead of simple lists which require to linearly search for elements everytime.
	Also makes use of the KD tree to search for the nearest node to the goal. We only use the closest node from the KD tree if it has a direct line of sight, else we will have to linearly search for one that we have a line of sight on.
	It is also modified to make paths with bots already on more expensive and will try a less congested path first. Thus spliting up the bots onto more paths instead of just one (the smallest).
*/
AStarSearch(start, goal, team, greedy_path)
{
	open = NewHeap(::ReverseHeapAStar);//heap
	openset = [];//set for quick lookup
	
	closed = [];//set for quick lookup
	
	startwp = level.waypointsKDTree KDTreeNearest(start);//balanced kdtree, for nns
	if(!isDefined(startwp))
		return [];
	_startwp = undefined;
	if(!bulletTracePassed(start + (0, 0, 15), startwp.origin + (0, 0, 15), false, undefined))
		_startwp = GetNearestWaypointWithSight(start);
	if(isDefined(_startwp))
		startwp = _startwp;
	startwp = startwp.index;
	
	goalwp = level.waypointsKDTree KDTreeNearest(goal);
	if(!isDefined(goalwp))
		return [];
	_goalwp = undefined;
	if(!bulletTracePassed(goal + (0, 0, 15), goalwp.origin + (0, 0, 15), false, undefined))
		_goalwp = GetNearestWaypointWithSight(goal);
	if(isDefined(_goalwp))
		goalwp = _goalwp;
	goalwp = goalwp.index;
	
	goalorg = level.waypoints[goalWp].origin;
	
	node = spawnStruct();
	node.g = 0; //path dist so far
	node.h = DistanceSquared(level.waypoints[startWp].origin, goalorg); //herustic, distance to goal for path finding
	//node.f = node.h + node.g; // combine path dist and heru, use reverse heap to sort the priority queue by this attru
	node.f = node.h;
	node.index = startwp;
	node.parent = undefined; //we are start, so we have no parent
	
	//push node onto queue
	openset[node.index] = node;
	open HeapInsert(node);
	
	//while the queue is not empty
	while(open.data.size)
	{
		//pop bestnode from queue
		bestNode = open.data[0];
		open HeapRemove();
		openset[bestNode.index] = undefined;
		
		//check if we made it to the goal
		if(bestNode.index == goalwp)
		{
			path = [];
		
			while(isDefined(bestNode))
			{
				if(isdefined(team))
					level.waypoints[bestNode.index].bots[team]++;
					
				//construct path
				path[path.size] = bestNode.index;
				
				bestNode = bestNode.parent;
			}
			
			return path;
		}
		
		nodeorg = level.waypoints[bestNode.index].origin;
		childcount = level.waypoints[bestNode.index].childCount;
		//for each child of bestnode
		for(i = 0; i < childcount; i++)
		{
			child = level.waypoints[bestNode.index].children[i];
			childorg = level.waypoints[child].origin;
			childtype = level.waypoints[child].type;
			
			penalty = 1;
			if(!greedy_path && isdefined(team))
			{
				temppen = level.waypoints[child].bots[team];//consider how many bots are taking this path
				if(temppen > 1)
					penalty = temppen;
			}

			// have certain types of nodes more expensive
			if (childtype == "climb" || childtype == "prone")
				penalty++;
			
			//calc the total path we have took
			newg = bestNode.g + DistanceSquared(nodeorg, childorg)*penalty;//bots on same team's path are more expensive
			
			//check if this child is in open or close with a g value less than newg
			inopen = isDefined(openset[child]);
			if(inopen && openset[child].g <= newg)
				continue;
			
			inclosed = isDefined(closed[child]);
			if(inclosed && closed[child].g <= newg)
				continue;
			
			if(inopen)
				node = openset[child];
			else if(inclosed)
				node = closed[child];
			else
				node = spawnStruct();
				
			node.parent = bestNode;
			node.g = newg;
			node.h = DistanceSquared(childorg, goalorg);
			node.f = node.g + node.h;
			node.index = child;
			
			//check if in closed, remove it
			if(inclosed)
				closed[child] = undefined;
			
			//check if not in open, add it
			if(!inopen)
			{
				open HeapInsert(node);
				openset[child] = node;
			}
		}
		
		//done with children, push onto closed
		closed[bestNode.index] = bestNode;
	}
	
	return [];
}

/*
	Returns the natural log of x using harmonic series.
*/
Log(x)
{
	/*if (!isDefined(level.log_cache))
		level.log_cache = [];
	
	key = x + "";
	
	if (isDefined(level.log_cache[key]))
		return level.log_cache[key];*/

	//thanks Bob__ at stackoverflow
	old_sum = 0.0;
	xmlxpl = (x - 1) / (x + 1);
	xmlxpl_2 = xmlxpl * xmlxpl;
	denom = 1.0;
	frac = xmlxpl;
	sum = frac;

	while ( sum != old_sum )
	{
		old_sum = sum;
		denom += 2.0;
		frac *= xmlxpl_2;
		sum += frac / denom;
	}
	
	answer = 2.0 * sum;
	
	//level.log_cache[key] = answer;
	return answer;
}

/*
	Taken from t5 gsc.
	Returns an array of number's average.
*/
array_average( array )
{
	assert( array.size > 0 );
	total = 0;
	for ( i = 0; i < array.size; i++ )
	{
		total += array[i];
	}
	return ( total / array.size );
}

/*
	Taken from t5 gsc.
	Returns an array of number's standard deviation.
*/
array_std_deviation( array, mean )
{
	assert( array.size > 0 );
	tmp = [];
	for ( i = 0; i < array.size; i++ )
	{
		tmp[i] = ( array[i] - mean ) * ( array[i] - mean );
	}
	total = 0;
	for ( i = 0; i < tmp.size; i++ )
	{
		total = total + tmp[i];
	}
	return Sqrt( total / array.size );
}

/*
	Taken from t5 gsc.
	Will produce a random number between lower_bound and upper_bound but with a bell curve distribution (more likely to be close to the mean).
*/
random_normal_distribution( mean, std_deviation, lower_bound, upper_bound )
{
	x1 = 0;
	x2 = 0;
	w = 1;
	y1 = 0;
	while ( w >= 1 )
	{
		x1 = 2 * RandomFloatRange( 0, 1 ) - 1;
		x2 = 2 * RandomFloatRange( 0, 1 ) - 1;
		w = x1 * x1 + x2 * x2;
	}
	w = Sqrt( ( -2.0 * Log( w ) ) / w );
	y1 = x1 * w;
	number = mean + y1 * std_deviation;
	if ( IsDefined( lower_bound ) && number < lower_bound )
	{
		number = lower_bound;
	}
	if ( IsDefined( upper_bound ) && number > upper_bound )
	{
		number = upper_bound;
	}
	
	return( number );
}
