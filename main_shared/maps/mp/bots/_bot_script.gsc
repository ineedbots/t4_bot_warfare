#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

/*
	When the bot gets added into the game.
*/
added()
{
	self endon("disconnect");
	
	rankxp = self bot_get_rank();
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, "rankxp", 0 )), rankxp );
	
	self set_diff();
	
	self set_class(rankxp);
}

/*
	When the bot connects to the game.
*/
connected()
{
	self endon("disconnect");
	
	self.killerLocation = undefined;
	
	self thread difficulty();
	self thread teamWatch();
	self thread classWatch();
	self thread onBotSpawned();
	self thread onSpawned();
	self thread onDeath();
}

/*
	The callback for when the bot gets killed.
*/
onKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self.killerLocation = undefined;

	if(!IsDefined( self ) || !isDefined(self.team))
		return;

	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
		return;

	if ( iDamage <= 0 )
		return;
	
	if(!IsDefined( eAttacker ) || !isDefined(eAttacker.team))
		return;
		
	if(eAttacker == self)
		return;
		
	if(level.teamBased && eAttacker.team == self.team)
		return;

	if ( !IsDefined( eInflictor ) || eInflictor.classname != "player")
		return;
		
	if(!isAlive(eAttacker))
		return;
	
	self.killerLocation = eAttacker.origin;
}

/*
	The callback for when the bot gets damaged.
*/
onDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if(!IsDefined( self ) || !isDefined(self.team))
		return;
		
	if(!isAlive(self))
		return;

	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
		return;

	if ( iDamage <= 0 )
		return;
	
	if(!IsDefined( eAttacker ) || !isDefined(eAttacker.team))
		return;
		
	if(eAttacker == self)
		return;
		
	if(level.teamBased && eAttacker.team == self.team)
		return;

	if ( !IsDefined( eInflictor ) || eInflictor.classname != "player")
		return;
		
	if(!isAlive(eAttacker))
		return;
		
	if (!isSubStr(sWeapon, "silenced_") && !isSubStr(sWeapon, "flash_"))
		self bot_cry_for_help( eAttacker );
	
	self SetAttacker( eAttacker );
}

/*
	When the bot gets attacked, have the bot ask for help from teammates.
*/
bot_cry_for_help( attacker )
{
	if ( !level.teamBased )
	{
		return;
	}
	
	theTime = GetTime();
	if ( IsDefined( self.help_time ) && theTime - self.help_time < 1000 )
	{
		return;
	}
	
	self.help_time = theTime;

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( !player is_bot() )
		{
			continue;
		}
		
		if(!isDefined(player.team))
			continue;

		if ( !IsAlive( player ) )
		{
			continue;
		}

		if ( player == self )
		{
			continue;
		}

		if ( player.team != self.team )
		{
			continue;
		}

		dist = player.pers["bots"]["skill"]["help_dist"];
		dist *= dist;
		if ( DistanceSquared( self.origin, player.origin ) > dist )
		{
			continue;
		}

		if ( RandomInt( 100 ) < 50 )
		{
			self SetAttacker( attacker );

			if ( RandomInt( 100 ) > 70 )
			{
				break;
			}
		}
	}
}

/*
	Allows the bot to spawn when force respawn is disabled
	Watches when the bot dies
*/
onDeath()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("death");

		self.wantSafeSpawn = true;
	}
}

/*
	Selects a class for the bot.
*/
classWatch()
{
	self endon("disconnect");

	for(;;)
	{
		while(!isdefined(self.pers["team"]) || level.oldschool)
			wait .05;
			
		wait 0.5;
		class = "";
		rank = self maps\mp\gametypes\_rank::getRankForXp( self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, "rankxp", 0 )) ) ) + 1;
		if(rank < 4 || randomInt(100) < 2)
		{
			while(class == "")
			{
				switch(randomInt(5))
				{
					case 0:
						class = "assault_mp";
						break;
					case 1:
						class = "specops_mp";
						break;
					case 2:
						class = "heavygunner_mp";
						break;
					case 3:
						if(rank >= 2)
							class = "demolitions_mp";
						break;
					case 4:
						if(rank >= 3)
							class = "sniper_mp";
						break;
				}
			}
		}
		else
		{
			class = "custom"+(randomInt(5)+1);
		}
		
		self notify("menuresponse", game["menu_changeclass"], class);
		self.bot_change_class = true;
			
		while(isdefined(self.pers["team"]) && isdefined(self.pers["class"]) && isDefined(self.bot_change_class))
			wait .05;
	}
}

/*
	Makes sure the bot is on a team.
*/
teamWatch()
{
	self endon("disconnect");

	for(;;)
	{
		while(!isdefined(self.pers["team"]))
			wait .05;
			
		wait 0.05;
		self notify("menuresponse", game["menu_team"], getDvar("bots_team"));
			
		while(isdefined(self.pers["team"]))
			wait .05;
	}
}

/*
	Updates the bot's difficulty variables.
*/
difficulty()
{
	self endon("disconnect");

	for(;;)
	{
		wait 1;
		
		rankVar = GetDvarInt("bots_skill");
		
		if(rankVar == 9)
			continue;
			
		switch(self.pers["bots"]["skill"]["base"])
		{
			case 1:
				self.pers["bots"]["skill"]["aim_time"] = 0.6;
				self.pers["bots"]["skill"]["init_react_time"] = 1500;
				self.pers["bots"]["skill"]["reaction_time"] = 1000;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 500;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 600;
				self.pers["bots"]["skill"]["remember_time"] = 750;
				self.pers["bots"]["skill"]["fov"] = 0.7;
				self.pers["bots"]["skill"]["dist"] = 1000;
				self.pers["bots"]["skill"]["spawn_time"] = 0.75;
				self.pers["bots"]["skill"]["help_dist"] = 0;
				self.pers["bots"]["skill"]["semi_time"] = 0.9;
				self.pers["bots"]["skill"]["shoot_after_time"] = 1;
				self.pers["bots"]["skill"]["aim_offset_time"] = 1.5;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 4;
				self.pers["bots"]["skill"]["bone_update_interval"] = 2;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_ankle_le,j_ankle_ri";

				self.pers["bots"]["behavior"]["strafe"] = 0;
				self.pers["bots"]["behavior"]["nade"] = 10;
				self.pers["bots"]["behavior"]["sprint"] = 10;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 70;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 0;
				break;
			case 2:
				self.pers["bots"]["skill"]["aim_time"] = 0.55;
				self.pers["bots"]["skill"]["init_react_time"] = 1000;
				self.pers["bots"]["skill"]["reaction_time"] = 800;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 1000;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 1250;
				self.pers["bots"]["skill"]["remember_time"] = 1500;
				self.pers["bots"]["skill"]["fov"] = 0.65;
				self.pers["bots"]["skill"]["dist"] = 1500;
				self.pers["bots"]["skill"]["spawn_time"] = 0.65;
				self.pers["bots"]["skill"]["help_dist"] = 500;
				self.pers["bots"]["skill"]["semi_time"] = 0.75;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0.75;
				self.pers["bots"]["skill"]["aim_offset_time"] = 1;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 3;
				self.pers["bots"]["skill"]["bone_update_interval"] = 1.5;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_ankle_le,j_ankle_ri,j_head";

				self.pers["bots"]["behavior"]["strafe"] = 10;
				self.pers["bots"]["behavior"]["nade"] = 15;
				self.pers["bots"]["behavior"]["sprint"] = 15;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 60;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 10;
				break;
			case 3:
				self.pers["bots"]["skill"]["aim_time"] = 0.4;
				self.pers["bots"]["skill"]["init_react_time"] = 750;
				self.pers["bots"]["skill"]["reaction_time"] = 500;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 1000;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 1500;
				self.pers["bots"]["skill"]["remember_time"] = 2000;
				self.pers["bots"]["skill"]["fov"] = 0.6;
				self.pers["bots"]["skill"]["dist"] = 2250;
				self.pers["bots"]["skill"]["spawn_time"] = 0.5;
				self.pers["bots"]["skill"]["help_dist"] = 750;
				self.pers["bots"]["skill"]["semi_time"] = 0.65;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0.65;
				self.pers["bots"]["skill"]["aim_offset_time"] = 0.75;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 2.5;
				self.pers["bots"]["skill"]["bone_update_interval"] = 1;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_spineupper,j_ankle_le,j_ankle_ri,j_head";

				self.pers["bots"]["behavior"]["strafe"] = 20;
				self.pers["bots"]["behavior"]["nade"] = 20;
				self.pers["bots"]["behavior"]["sprint"] = 20;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 50;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 25;
				break;
			case 4:
				self.pers["bots"]["skill"]["aim_time"] = 0.3;
				self.pers["bots"]["skill"]["init_react_time"] = 600;
				self.pers["bots"]["skill"]["reaction_time"] = 400;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 1000;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 1500;
				self.pers["bots"]["skill"]["remember_time"] = 3000;
				self.pers["bots"]["skill"]["fov"] = 0.55;
				self.pers["bots"]["skill"]["dist"] = 3350;
				self.pers["bots"]["skill"]["spawn_time"] = 0.35;
				self.pers["bots"]["skill"]["help_dist"] = 1000;
				self.pers["bots"]["skill"]["semi_time"] = 0.5;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0.5;
				self.pers["bots"]["skill"]["aim_offset_time"] = 0.5;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 2;
				self.pers["bots"]["skill"]["bone_update_interval"] = 0.75;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_spineupper,j_ankle_le,j_ankle_ri,j_head,j_head";

				self.pers["bots"]["behavior"]["strafe"] = 30;
				self.pers["bots"]["behavior"]["nade"] = 25;
				self.pers["bots"]["behavior"]["sprint"] = 30;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 40;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 35;
				break;
			case 5:
				self.pers["bots"]["skill"]["aim_time"] = 0.25;
				self.pers["bots"]["skill"]["init_react_time"] = 500;
				self.pers["bots"]["skill"]["reaction_time"] = 300;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 1500;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 2000;
				self.pers["bots"]["skill"]["remember_time"] = 4000;
				self.pers["bots"]["skill"]["fov"] = 0.5;
				self.pers["bots"]["skill"]["dist"] = 5000;
				self.pers["bots"]["skill"]["spawn_time"] = 0.25;
				self.pers["bots"]["skill"]["help_dist"] = 1500;
				self.pers["bots"]["skill"]["semi_time"] = 0.4;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0.35;
				self.pers["bots"]["skill"]["aim_offset_time"] = 0.35;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 1.5;
				self.pers["bots"]["skill"]["bone_update_interval"] = 0.5;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_head";

				self.pers["bots"]["behavior"]["strafe"] = 40;
				self.pers["bots"]["behavior"]["nade"] = 35;
				self.pers["bots"]["behavior"]["sprint"] = 40;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 30;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 50;
				break;
			case 6:
				self.pers["bots"]["skill"]["aim_time"] = 0.2;
				self.pers["bots"]["skill"]["init_react_time"] = 250;
				self.pers["bots"]["skill"]["reaction_time"] = 150;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 2000;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 3000;
				self.pers["bots"]["skill"]["remember_time"] = 5000;
				self.pers["bots"]["skill"]["fov"] = 0.45;
				self.pers["bots"]["skill"]["dist"] = 7500;
				self.pers["bots"]["skill"]["spawn_time"] = 0.2;
				self.pers["bots"]["skill"]["help_dist"] = 2000;
				self.pers["bots"]["skill"]["semi_time"] = 0.25;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0.25;
				self.pers["bots"]["skill"]["aim_offset_time"] = 0.25;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 1;
				self.pers["bots"]["skill"]["bone_update_interval"] = 0.25;
				self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_head,j_head";

				self.pers["bots"]["behavior"]["strafe"] = 50;
				self.pers["bots"]["behavior"]["nade"] = 45;
				self.pers["bots"]["behavior"]["sprint"] = 50;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 20;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 75;
				break;
			case 7:
				self.pers["bots"]["skill"]["aim_time"] = 0.1;
				self.pers["bots"]["skill"]["init_react_time"] = 100;
				self.pers["bots"]["skill"]["reaction_time"] = 50;
				self.pers["bots"]["skill"]["no_trace_ads_time"] = 2500;
				self.pers["bots"]["skill"]["no_trace_look_time"] = 4000;
				self.pers["bots"]["skill"]["remember_time"] = 7500;
				self.pers["bots"]["skill"]["fov"] = 0.4;
				self.pers["bots"]["skill"]["dist"] = 10000;
				self.pers["bots"]["skill"]["spawn_time"] = 0.05;
				self.pers["bots"]["skill"]["help_dist"] = 3000;
				self.pers["bots"]["skill"]["semi_time"] = 0.1;
				self.pers["bots"]["skill"]["shoot_after_time"] = 0;
				self.pers["bots"]["skill"]["aim_offset_time"] = 0;
				self.pers["bots"]["skill"]["aim_offset_amount"] = 0;
				self.pers["bots"]["skill"]["bone_update_interval"] = 0.05;
				self.pers["bots"]["skill"]["bones"] = "j_head";

				self.pers["bots"]["behavior"]["strafe"] = 65;
				self.pers["bots"]["behavior"]["nade"] = 65;
				self.pers["bots"]["behavior"]["sprint"] = 65;
				self.pers["bots"]["behavior"]["camp"] = 5;
				self.pers["bots"]["behavior"]["follow"] = 5;
				self.pers["bots"]["behavior"]["crouch"] = 5;
				self.pers["bots"]["behavior"]["switch"] = 2;
				self.pers["bots"]["behavior"]["class"] = 2;
				self.pers["bots"]["behavior"]["jump"] = 90;
				break;
		}
	}
}

/*
	Sets the bot difficulty.
*/
set_diff()
{
	rankVar = GetDvarInt("bots_skill");
	
	switch(rankVar)
	{
		case 0:
			self.pers["bots"]["skill"]["base"] = Round( random_normal_distribution( 3.5, 1.75, 1, 7 ) );
			break;
		case 8:
			break;
		case 9:
			self.pers["bots"]["skill"]["base"] = randomIntRange(1, 7);
			self.pers["bots"]["skill"]["aim_time"] = 0.05 * randomIntRange(1, 20);
			self.pers["bots"]["skill"]["init_react_time"] = 50 * randomInt(100);
			self.pers["bots"]["skill"]["reaction_time"] = 50 * randomInt(100);
			self.pers["bots"]["skill"]["no_trace_ads_time"] = 50 * randomInt(100);
			self.pers["bots"]["skill"]["no_trace_look_time"] = 50 * randomInt(100);
			self.pers["bots"]["skill"]["remember_time"] = 50 * randomInt(100);
			self.pers["bots"]["skill"]["fov"] = randomFloatRange(-1, 1);
			self.pers["bots"]["skill"]["dist"] = randomIntRange(500, 25000);
			self.pers["bots"]["skill"]["spawn_time"] = 0.05 * randomInt(20);
			self.pers["bots"]["skill"]["help_dist"] = randomIntRange(500, 25000);
			self.pers["bots"]["skill"]["semi_time"] = randomFloatRange(0.05, 1);
			self.pers["bots"]["skill"]["shoot_after_time"] = randomFloatRange(0.05, 1);
			self.pers["bots"]["skill"]["aim_offset_time"] = randomFloatRange(0.05, 1);
			self.pers["bots"]["skill"]["aim_offset_amount"] = randomFloatRange(0.05, 1);
			self.pers["bots"]["skill"]["bone_update_interval"] = randomFloatRange(0.05, 1);
			self.pers["bots"]["skill"]["bones"] = "j_head,j_spineupper,j_ankle_ri,j_ankle_le";

			self.pers["bots"]["behavior"]["strafe"] = randomInt(100);
			self.pers["bots"]["behavior"]["nade"] = randomInt(100);
			self.pers["bots"]["behavior"]["sprint"] = randomInt(100);
			self.pers["bots"]["behavior"]["camp"] = randomInt(100);
			self.pers["bots"]["behavior"]["follow"] = randomInt(100);
			self.pers["bots"]["behavior"]["crouch"] = randomInt(100);
			self.pers["bots"]["behavior"]["switch"] = randomInt(100);
			self.pers["bots"]["behavior"]["class"] = randomInt(100);
			self.pers["bots"]["behavior"]["jump"] = randomInt(100);
			break;
		default:
			self.pers["bots"]["skill"]["base"] = rankVar;
			break;
	}
}

/*
	Sets the bot's classes.
*/
set_class(rankxp)
{
	primaryGroups = [];
	primaryGroups[0] = "weapon_lmg";
	primaryGroups[1] = "weapon_smg";
	primaryGroups[2] = "weapon_shotgun";
	primaryGroups[3] = "weapon_sniper";
	primaryGroups[4] = "weapon_assault";
	primaryGroups[4] = "weapon_hmg";
	secondaryGroups = [];
	secondaryGroups[0] = "weapon_pistol";
	
	rank = self maps\mp\gametypes\_rank::getRankForXp( rankxp ) + 1;

	for(i=0; i < 5; i++)
	{
		primary = get_random_weapon(primaryGroups, rank);
		att1 = get_random_attachment(primary, rank);
		
		perk2 = get_random_perk("perk2", rank);

		if(perk2 != "specialty_twoprimaries")
			secondary = get_random_weapon(secondaryGroups, rank);
		else
		{
			secondary = "";

			while(secondary == "")
			{
				secondary = get_random_weapon(primaryGroups, rank);

				if (primary == secondary)
					secondary = "";
			}
		}
		att2 = get_random_attachment(secondary, rank);

		perk1 = get_random_perk("perk1", rank, att1, att2);
		
		perk3 = get_random_perk("perk3", rank);
		perk4 = get_random_perk("perk4", rank);
		secgren = get_random_sec_grenade(perk1);
		gren = get_random_grenade(perk1);
		camo = randomInt(8);
	
		self setStat ( 200+(i*10)+1, level.weaponReferenceToIndex[primary] );
		self setStat ( 200+(i*10)+2, level.weaponAttachmentReferenceToIndex[att1] );
		self setStat ( 200+(i*10)+3, level.weaponReferenceToIndex[secondary] );
		self setStat ( 200+(i*10)+4, level.weaponAttachmentReferenceToIndex[att2] );
		self setStat ( 200+(i*10)+5, level.perkReferenceToIndex[perk1] );
		self setStat ( 200+(i*10)+6, level.perkReferenceToIndex[perk2] );
		self setStat ( 200+(i*10)+7, level.perkReferenceToIndex[perk3] );
		self setStat ( 200+(i*10)+105, level.perkReferenceToIndex[perk4] );
		self setStat ( 200+(i*10)+8, level.weaponReferenceToIndex[secgren] );
		self setStat ( 200+(i*10)+0, level.weaponReferenceToIndex[gren] );
		self setStat ( 200+(i*10)+9, camo);
	}
}

/*
	Returns a random attachment for the bot.
*/
get_random_attachment(weapon, rank)
{
	if (RandomFloatRange( 0, 1 ) > (0.1 + ( rank / level.maxRank )))
		return "none";

	reasonable = GetDvarInt("bots_loadout_reasonable");
	
	id = level.tbl_weaponIDs[level.weaponReferenceToIndex[weapon]];
	atts = strtok(id["attachment"], " ");
	atts[atts.size] = "none";

	
	for(;;)
	{
		att = atts[randomInt(atts.size)];
		
		if(reasonable)
		{
			/*switch(att)
			{
				case "acog":
					if(weapon != "m40a3")
						continue;
					break;
			}*/
		}
		
		return att;
	}
}

/*
	Returns a random perk for the bot.
*/
get_random_perk(perkslot, rank, att1, att2)
{
	if(isDefined(att1) && isDefined(att2) && (att1 == "grip" || att1 == "gl" || att2 == "grip" || att2 == "gl"))
		return "specialty_null";
	
	reasonable = GetDvarInt("bots_loadout_reasonable");
	op = GetDvarInt("bots_loadout_allow_op");
	
	keys = getArrayKeys(level.tbl_PerkData);
	for(;;)
	{
		id = level.tbl_PerkData[keys[randomInt(keys.size)]];
		
		if(!isDefined(id) || !isDefined(id["perk_num"]))
			continue;
		
		if(perkslot != id["perk_num"])
			continue;
			
		ref = id["reference_full"];
		
		if(ref == "specialty_null" && randomInt(100) < 95)
			continue;
			
		if(reasonable)
		{
			switch(ref)
			{
				case "specialty_shades":
				case "specialty_pin_back":
				case "specialty_flakjacket":
				case "specialty_reconnaissance":
				case "specialty_fireproof":
				case "specialty_holdbreath":
				case "specialty_gas_mask":
				case "specialty_explosivedamage":
				case "specialty_twoprimaries":
					continue;
			}
		}
			
		if(!op)
		{
			switch(ref)
			{
				case "specialty_armorvest":
				case "specialty_pistoldeath":
				case "specialty_grenadepulldeath":
					continue;
			}
		}
		
		if(!isItemUnlocked(ref, rank))
			continue;
			
		return ref;
	}
}

/*
	Returns a random grenade for the bot.
*/
get_random_grenade(perk1)
{
	possibles = [];
	possibles[0] = "frag_grenade";
	possibles[1] = "molotov";
	possibles[2] = "sticky_grenade";
	
	reasonable = GetDvarInt("bots_loadout_reasonable");
	
	for(;;)
	{
		possible = possibles[randomInt(possibles.size)];
		
		if(reasonable)
		{
			switch(possible)
			{
				case "molotov":
					continue;
			}
		}
			
		return possible;
	}
}

/*
	Returns a random grenade for the bot.
*/
get_random_sec_grenade(perk1)
{
	possibles = [];
	possibles[0] = "m8_white_smoke";
	possibles[1] = "signal_flare";
	possibles[2] = "tabun_gas";
	
	reasonable = GetDvarInt("bots_loadout_reasonable");
	
	for(;;)
	{
		possible = possibles[randomInt(possibles.size)];
		
		if(reasonable)
		{
			switch(possible)
			{
				case "m8_white_smoke":
					continue;
			}
		}
		
		if(perk1 == "specialty_specialgrenade" && possible == "m8_white_smoke")
			continue;
			
		return possible;
	}
}

/*
	Returns a random weapon for the bot.
*/
get_random_weapon(groups, rank)
{
	reasonable = GetDvarInt("bots_loadout_reasonable");
	
	keys = getArrayKeys(level.tbl_weaponIDs);
	for(;;)
	{
		id = level.tbl_weaponIDs[keys[randomInt(keys.size)]];
		
		if(!isDefined(id))
			continue;
		
		group = id["group"];
		inGroup = false;
		for(i = groups.size - 1; i >= 0; i--)
		{
			if(groups[i] == group)
				inGroup = true;
		}
		
		if(!inGroup)
			continue;
			
		ref = id["reference"];
		
		if(reasonable)
		{
			/*switch(ref)
			{
				case "":
					continue;
			}*/
		}
		
		if(!isItemUnlocked(ref, rank))
			continue;
			
		return ref;
	}
}

/*
	Gets an exp amount for the bot that is nearish the host's xp.
*/
bot_get_rank()
{
	ranks = [];
	bot_ranks = [];
	human_ranks = [];
	
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];
	
		if ( player == self )
			continue;
		
		if ( !IsDefined( player.pers[ "rank" ] ) )
			continue;
		
		if ( player is_bot() )
		{
			bot_ranks[ bot_ranks.size ] = player.pers[ "rank" ];
		}
		else
		{
			human_ranks[ human_ranks.size ] = player.pers[ "rank" ];
		}
	}

	if( !human_ranks.size )
		human_ranks[ human_ranks.size ] = Round( random_normal_distribution( 35, 15, 0, level.maxRank ) );

	human_avg = array_average( human_ranks );

	while ( bot_ranks.size + human_ranks.size < 5 )
	{
		// add some random ranks for better random number distribution
		rank = human_avg + RandomIntRange( -10, 10 );
		human_ranks[ human_ranks.size ] = rank;
	}

	ranks = array_combine( human_ranks, bot_ranks );

	avg = array_average( ranks );
	s = array_std_deviation( ranks, avg );
	
	rank = Round( random_normal_distribution( avg, s, 0, level.maxRank ) );

	return maps\mp\gametypes\_rank::getRankInfoMinXP( rank );
}

/*
	When the bot spawns.
*/
onSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		if(randomInt(100) <= self.pers["bots"]["behavior"]["class"])
			self.bot_change_class = undefined;
		
		self.bot_lock_goal = false;
		self.help_time = undefined;
		self.bot_was_follow_script_update = undefined;
	}
}

/*
	When the bot spawned, after the difficulty wait. Start the logic for the bot.
*/
onBotSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	
	for(;;)
	{
		self waittill("bot_spawned");
		
		self thread start_bot_threads();
	}
}

/*
	Starts all the bot thinking
*/
start_bot_threads()
{
	self endon("disconnect");
	level endon("game_ended");
	self endon("death");

	while(level.inPrematchPeriod)
		wait 0.05;
}
