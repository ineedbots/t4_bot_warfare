/*
	_wp_editor
	Author: INeedGames
	Date: 09/26/2020
	The ingame waypoint editor. Designed to be ran on the client (not the server)
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	if(getDvar("bots_main_debug") == "")
		setDvar("bots_main_debug", 0);

	if(!getDVarint("bots_main_debug"))
		return;

	if(!getDVarint("developer"))
	{
		setdvar("developer_script", 1);
		setdvar("developer", 1);

		setdvar("sv_mapRotation", "map "+getDvar("mapname"));
		exitLevel(false);
	}

	setDvar("bots_main", 0);
	setdvar("bots_main_menu", 0);
	setdvar("bots_manage_fill_mode", 0);
	setdvar("bots_manage_fill", 0);
	setdvar("bots_manage_add", 0);
	setdvar("bots_manage_fill_kick", 1);
	setDvar("bots_manage_fill_spec", 1);

	if (getDvar("bots_main_debug_distance") == "")
		setDvar("bots_main_debug_distance", 512.0);

	if (getDvar("bots_main_debug_cone") == "")
		setDvar("bots_main_debug_cone", 0.65);

	if (getDvar("bots_main_debug_minDist") == "")
		setDvar("bots_main_debug_minDist", 32.0);

	if (getDvar("bots_main_debug_drawThrough") == "")
		setDvar("bots_main_debug_drawThrough", false);

	if(getDvar("bots_main_debug_commandWait") == "")
		setDvar("bots_main_debug_commandWait", 0.5);

	setDvar("player_sustainAmmo", 1);

	level.waypoints = [];
	level.waypointCount = 0;

	level waittill( "connected", player);

	player thread onPlayerSpawned();
}

onPlayerSpawned()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		self thread beginDebug();
	}
}

beginDebug()
{
	self endon("disconnect");
	self endon("death");

	level.wpToLink = -1;
	level.autoLink = false;
	self.closest = -1;
	self.command = undefined;
	
	self clearPerks();
	self takeAllWeapons();
	self.specialty = [];
	self giveWeapon("m1garand_gl_mp");
	self SetActionSlot( 3, "altMode" );
	self giveWeapon("frag_grenade_mp");
	self freezecontrols(false);
	
	self thread debug();
	self thread addWaypoints();
	self thread linkWaypoints();
	self thread deleteWaypoints();
	self thread watchSaveWaypointsCommand();
	self thread sayExtras();
	
	self thread textScroll("^1SecondaryOffhand - ^2Add Waypoint; ^3MeleeButton - ^4Link Waypoint; ^5FragButton - ^6Delete Waypoint; ^7UseButton + AttackButton - ^8Save");
}

sayExtras()
{
	self endon("disconnect");
	self endon("death");
	self iprintln("Making a crouch waypoint with only one link...");
	self iprintln("Makes a camping waypoint.");
}

debug()
{
	self endon("disconnect");
	self endon("death");
	
	for(;;)
	{
		wait 0.05;
		
		if(isDefined(self.command))
			continue;
		
		closest = -1;
		myEye = self getTagOrigin( "j_head" );
		myAngles = self GetPlayerAngles();
		
		for(i = 0; i < level.waypointCount; i++)
		{
			if(closest == -1 || closer(self.origin, level.waypoints[i].origin, level.waypoints[closest].origin))
				closest = i;

			wpOrg = level.waypoints[i].origin + (0, 0, 25);
			
			if(distance(level.waypoints[i].origin, self.origin) < getDvarFloat("bots_main_debug_distance") && (bulletTracePassed(myEye, wpOrg, false, self) || getDVarint("bots_main_debug_drawThrough")))
			{
				for(h = 0; h < level.waypoints[i].childCount; h++)
					line(wpOrg, level.waypoints[level.waypoints[i].children[h]].origin + (0, 0, 25), (1,0,1));
				
				if(getConeDot(wpOrg, myEye, myAngles) > getDvarFloat("bots_main_debug_cone"))
					print3d(wpOrg, i, (1,0,0), 2);

				if (isDefined(level.waypoints[i].angles) && level.waypoints[i].type != "stand")
					line(wpOrg, wpOrg + AnglesToForward(level.waypoints[i].angles) * 64, (1,1,1));
			}
		}
		
		self.closest = closest;
	
		if(closest != -1)
		{
			stringChildren = "";
			for(i = 0; i < level.waypoints[closest].childCount; i++)
			{
				if(i != 0)
					stringChildren = stringChildren + "," + level.waypoints[closest].children[i];
				else
					stringChildren = stringChildren + level.waypoints[closest].children[i];
			}
			print3d(level.waypoints[closest].origin + (0, 0, 35), stringChildren, (0,1,0), 2);
			
			print3d(level.waypoints[closest].origin + (0, 0, 15), level.waypoints[closest].type, (0,1,0), 2);
		}
	}
}

AddWaypoints()
{
	self endon("disconnect");
	self endon("death");
	for(;;)
	{
		while(!self SecondaryOffhandButtonPressed() || isDefined(self.command))
			wait 0.05;
		
		pos = self getOrigin();
		self.command = true;
		
		self iprintln("Adding a waypoint...");
		self iprintln("ADS - climb; Attack + Use - tube");
		self iprintln("Attack - grenade; Use - claymore");
		self iprintln("Else(wait) - your stance");
		
		wait getDvarFloat("bots_main_debug_commandWait");
		
		self addWaypoint(pos);
		
		self.command = undefined;
		
		while(self SecondaryOffhandButtonPressed())
			wait 0.05;
	}
}

linkWaypoints()
{
	self endon("disconnect");
	self endon("death");
	for(;;)
	{
		while(!self MeleeButtonPressed() || isDefined(self.command))
			wait 0.05;
		
		self.command = true;
		
		self iprintln("ADS - Unlink; Else(wait) - Link");
		
		wait getDvarFloat("bots_main_debug_commandWait");
		
		if(!self adsButtonPressed())
			self LinkWaypoint(self.closest);
		else
			self UnLinkWaypoint(self.closest);
		
		self.command = undefined;
		
		while(self MeleeButtonPressed())
			wait 0.05;
	}
}

deleteWaypoints()
{
	self endon("disconnect");
	self endon("death");
	for(;;)
	{
		while(!self fragButtonPressed() || isDefined(self.command))
			wait 0.05;
		
		self.command = true;
		
		self iprintln("Attack - DeleteAll; ADS - Load");
		self iprintln("Else(wait) - Delete");
		
		wait getDvarFloat("bots_main_debug_commandWait");
		
		if(self attackButtonPressed())
			self deleteAllWaypoints();
		else if(self adsButtonPressed())
			self LoadWaypoints();
		else
			self DeleteWaypoint(self.closest);
		
		self.command = undefined;
		
		while(self fragButtonPressed())
			wait 0.05;
	}
}

watchSaveWaypointsCommand()
{
	self endon("death");
	self endon("disconnect");
	
	for(;;)
	{
		while(!self useButtonPressed() || !self attackButtonPressed() || isDefined(self.command))
			wait 0.05;
		
		self.command = true;
		
		self iprintln("ADS - Autolink; Else(wait) - Save");
		
		wait getDvarFloat("bots_main_debug_commandWait");
		
		if(!self adsButtonPressed())
		{
			self checkForWarnings();
			logprint("***********ABiliTy's WPDump**************\n\n");
			logprint("\n\n\n\n");
			mpnm=getMapName(getdvar("mapname"));
			logprint("\n\n"+mpnm+"()\n{\n/*");
			logprint("*/waypoints = [];\n/*");
			for(i = 0; i < level.waypointCount; i++)
			{
				logprint("*/waypoints["+i+"] = spawnstruct();\n/*");
				logprint("*/waypoints["+i+"].origin = "+level.waypoints[i].origin+";\n/*");
				logprint("*/waypoints["+i+"].type = \""+level.waypoints[i].type+"\";\n/*");
				logprint("*/waypoints["+i+"].childCount = "+level.waypoints[i].childCount+";\n/*");
				for(c = 0; c < level.waypoints[i].childCount; c++)
				{
					logprint("*/waypoints["+i+"].children["+c+"] = "+level.waypoints[i].children[c]+";\n/*");
				}
				if(isDefined(level.waypoints[i].angles) && (level.waypoints[i].type == "claymore" || level.waypoints[i].type == "tube" || (level.waypoints[i].type == "crouch" && level.waypoints[i].childCount == 1) || level.waypoints[i].type == "climb" || level.waypoints[i].type == "grenade"))
					logprint("*/waypoints["+i+"].angles = "+level.waypoints[i].angles+";\n/*");
			}
			logprint("*/return waypoints;\n}\n\n\n\n");

			PrintLn("********* Start Bot Warfare WPDump *********");
			PrintLn(level.waypointCount);
			for(i = 0; i < level.waypointCount; i++)
			{
				str = "";
				wp = level.waypoints[i];

				str += wp.origin[0] + " " + wp.origin[1] + " " + wp.origin[2] + ",";

				for(h = 0; h < wp.childCount; h++)
				{
					str += wp.children[h];

					if (h < wp.childCount - 1)
						str += " ";
				}
				str += "," + wp.type + ",";

				if (isDefined(wp.angles))
					str += wp.angles[0] + " " + wp.angles[1] + " " + wp.angles[2] + ",";
				else
					str += ",";

				str += ",";

				PrintLn(str);
			}
			PrintLn("\n\n\n\n\n\n");

			self iprintln("Saved!!!");
		}
		else
		{
			if(level.autoLink)
			{
				self iPrintlnBold("Auto link disabled");
				level.autoLink = false;
				level.wpToLink = -1;
			}
			else
			{
				self iPrintlnBold("Auto link enabled");
				level.autoLink = true;
				level.wpToLink = self.nearest;
			}
		}
		
		self.command = undefined;
		
		while(self useButtonPressed() && self attackButtonPressed())
			wait 0.05;
	}
}

LoadWaypoints()
{
	self DeleteAllWaypoints();
	self iPrintlnBold("Loading WPS...");
	load_waypoints();
	
	self checkForWarnings();
}

checkForWarnings()
{
	if(level.waypointCount <= 0)
		self iprintln("WARNING: waypointCount is "+level.waypointCount);
	
	if(level.waypointCount != level.waypoints.size)
		self iprintln("WARNING: waypointCount is not "+level.waypoints.size);
	
	for(i = 0; i < level.waypointCount; i++)
	{
		if(!isDefined(level.waypoints[i]))
		{
			self iprintln("WARNING: waypoint "+i+" is undefined");
			continue;
		}
		
		if(level.waypoints[i].childCount <= 0)
			self iprintln("WARNING: waypoint "+i+" childCount is "+level.waypoints[i].childCount);
		
		if(level.waypoints[i].childCount != level.waypoints[i].children.size)
			self iprintln("WARNING: waypoint "+i+" childCount is not "+level.waypoints[i].children.size);
		
		for(h = 0; h < level.waypoints[i].children.size; h++)
		{
			child = level.waypoints[i].children[h];
			
			if(!isDefined(level.waypoints[child]))
				self iprintln("WARNING: waypoint "+i+" child "+child+" is undefined");
			else if(child == i)
				self iprintln("WARNING: waypoint "+i+" child "+child+" is itself");
		}
		
		if(!isDefined(level.waypoints[i].type))
		{
			self iprintln("WARNING: waypoint "+i+" type is undefined");
			continue;
		}
		
		if(!isDefined(level.waypoints[i].angles) && (level.waypoints[i].type == "claymore" || level.waypoints[i].type == "tube" || (level.waypoints[i].type == "crouch" && level.waypoints[i].childCount == 1) || level.waypoints[i].type == "climb" || level.waypoints[i].type == "grenade"))
			self iprintln("WARNING: waypoint "+i+" angles is undefined");
	}
}

DeleteAllWaypoints()
{
	level.waypoints = [];
	level.waypointCount = 0;
	
	self iprintln("DelAllWps");
}

DeleteWaypoint(nwp)
{
	if(nwp == -1 || distance(self.origin, level.waypoints[nwp].origin) > getDvarFloat("bots_main_debug_minDist"))
	{
		self iprintln("No close enough waypoint to delete.");
		return;
	}
	
	level.wpToLink = -1;
	
	for(i = 0; i < level.waypoints[nwp].childCount; i++)
	{
		child = level.waypoints[nwp].children[i];
		
		level.waypoints[child].children = array_remove(level.waypoints[child].children, nwp);
		
		level.waypoints[child].childCount = level.waypoints[child].children.size;
	}
	
	for(i = 0; i < level.waypointCount; i++)
	{
		for(h = 0; h < level.waypoints[i].childCount; h++)
		{
			if(level.waypoints[i].children[h] > nwp)
				level.waypoints[i].children[h]--;
		}
	}
	
	for ( entry = 0; entry < level.waypointCount; entry++ )
	{
		if ( entry == nwp )
		{
			while ( entry < level.waypointCount-1 )
			{
				level.waypoints[entry] = level.waypoints[entry+1];
				entry++;
			}
			level.waypoints[entry] = undefined;
			break;
		}
	}
	level.waypointCount--;
	
	self iprintln("DelWp "+nwp);
}

addWaypoint(pos)
{
	level.waypoints[level.waypointCount] = spawnstruct();
	
	level.waypoints[level.waypointCount].origin = pos;
	
	if(self AdsButtonPressed())
		level.waypoints[level.waypointCount].type = "climb";
	else if(self AttackButtonPressed() && self UseButtonPressed())
		level.waypoints[level.waypointCount].type = "tube";
	else if(self AttackButtonPressed())
		level.waypoints[level.waypointCount].type = "grenade";
	else if(self UseButtonPressed())
		level.waypoints[level.waypointCount].type = "claymore";
	else
		level.waypoints[level.waypointCount].type = self getStance();
	
	level.waypoints[level.waypointCount].angles = self getPlayerAngles();
	
	level.waypoints[level.waypointCount].children = [];
	level.waypoints[level.waypointCount].childCount = 0;
	
	self iprintln(level.waypoints[level.waypointCount].type + " Waypoint "+ level.waypointCount +" Added at "+pos);
	
	if(level.autoLink)
	{
		if(level.wpToLink == -1)
			level.wpToLink = level.waypointCount - 1;
		
		level.waypointCount++;
		self LinkWaypoint(level.waypointCount - 1);
	}
	else
	{
		level.waypointCount++;
	}
}

UnLinkWaypoint(nwp)
{
	if(nwp == -1 || distance(self.origin, level.waypoints[nwp].origin) > getDvarFloat("bots_main_debug_minDist"))
	{
		self iprintln("Waypoint Unlink Cancelled "+level.wpToLink);
		level.wpToLink = -1;
		return;
	}
	
	if(level.wpToLink == -1 || nwp == level.wpToLink)
	{
		level.wpToLink = nwp;
		self iprintln("Waypoint Unlink Started "+nwp);
		return;
	}
	
	level.waypoints[nwp].children = array_remove(level.waypoints[nwp].children, level.wpToLink);
	level.waypoints[level.wpToLink].children = array_remove(level.waypoints[level.wpToLink].children, nwp);
	
	level.waypoints[nwp].childCount = level.waypoints[nwp].children.size;
	level.waypoints[level.wpToLink].childCount = level.waypoints[level.wpToLink].children.size;
	
	self iprintln("Waypoint " + nwp + " Broken to " + level.wpToLink);
	level.wpToLink = -1;
}

LinkWaypoint(nwp)
{
	if(nwp == -1 || distance(self.origin, level.waypoints[nwp].origin) > getDvarFloat("bots_main_debug_minDist"))
	{
		self iprintln("Waypoint Link Cancelled "+level.wpToLink);
		level.wpToLink = -1;
		return;
	}
	
	if(level.wpToLink == -1 || nwp == level.wpToLink)
	{
		level.wpToLink = nwp;
		self iprintln("Waypoint Link Started "+nwp);
		return;
	}
	
	weGood = true;
	for(i = 0; i < level.waypoints[level.wpToLink].childCount; i++)
	{
		if(level.waypoints[level.wpToLink].children[i] == nwp)
		{
			weGood = false;
			break;
		}
	}
	if(weGood)
	{
		for(i = 0; i < level.waypoints[nwp].childCount; i++)
		{
			if(level.waypoints[nwp].children[i] == level.wpToLink)
			{
				weGood = false;
				break;
			}
		}
	}
	
	if (!weGood )
	{
		self iprintln("Waypoint Link Cancelled "+nwp+" and "+level.wpToLink+" already linked.");
		level.wpToLink = -1;
		return;
	}
	
	level.waypoints[level.wpToLink].children[level.waypoints[level.wpToLink].childcount] = nwp;
	level.waypoints[level.wpToLink].childcount++;
	level.waypoints[nwp].children[level.waypoints[nwp].childcount] = level.wpToLink;
	level.waypoints[nwp].childcount++;
	
	self iprintln("Waypoint " + nwp + " Linked to " + level.wpToLink);
	level.wpToLink = -1;
}

destroyOnDeath(hud)
{
	hud endon("death");
	self waittill_either("death","disconnect");
	hud notify("death");
	hud destroy();
	hud = undefined;
}

textScroll(string)
{
	self endon("death");
	self endon("disconnect");
	//thanks ActionScript
	
	back = createBar((0,0,0), 1000, 30);
	back setPoint("CENTER", undefined, 0, 220);
	self thread destroyOnDeath(back);

	text = createFontString("default", 1.5);
	text setText(string);
	self thread destroyOnDeath(text);

	for (;;)
	{
		text setPoint("CENTER", undefined, 1200, 220);
		text setPoint("CENTER", undefined, -1200, 220, 20);
		wait 20;
	}
}

getConeDot(to, from, dir)
{
    dirToTarget = VectorNormalize(to-from);
    forward = AnglesToForward(dir);
    return vectordot(dirToTarget, forward);
}

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
}
