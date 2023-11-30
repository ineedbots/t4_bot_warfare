#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Waits for the built-ins to be defined
*/
wait_for_builtins()
{
	for ( i = 0; i < 20; i++ )
	{
		if ( isDefined( level.bot_builtins ) )
			return true;

		if ( i < 18 )
			waittillframeend;
		else
			wait 0.05;
	}

	return false;
}

/*
	Prints to console without dev script on
*/
BotBuiltinPrintConsole( s )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["printconsole"] ) )
	{
		[[ level.bot_builtins["printconsole" ]]]( s );
	}
}

/*
	Writes to the file, mode can be "append" or "write"
*/
BotBuiltinFileWrite( file, contents, mode )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["filewrite"] ) )
	{
		[[ level.bot_builtins["filewrite" ]]]( file, contents, mode );
	}
}

/*
	Returns the whole file as a string
*/
BotBuiltinFileRead( file )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["fileread"] ) )
	{
		return [[ level.bot_builtins["fileread" ]]]( file );
	}

	return undefined;
}

/*
	Test if a file exists
*/
BotBuiltinFileExists( file )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["fileexists"] ) )
	{
		return [[ level.bot_builtins["fileexists" ]]]( file );
	}

	return false;
}

/*
	Bot action, does a bot action
	<client> botAction(<action string (+ or - then action like frag or smoke)>)
*/
BotBuiltinBotAction( action )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["botaction"] ) )
	{
		self [[ level.bot_builtins["botaction" ]]]( action );
	}
}

/*
	Clears the bot from movement and actions
	<client> botStop()
*/
BotBuiltinBotStop()
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["botstop"] ) )
	{
		self [[ level.bot_builtins["botstop" ]]]();
	}
}

/*
	Sets the bot's movement
	<client> botMovement(<int left>, <int forward>)
*/
BotBuiltinBotMovement( left, forward )
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["botmovement"] ) )
	{
		self [[ level.bot_builtins["botmovement" ]]]( left, forward );
	}
}

/*
	Test if is a bot
*/
BotBuiltinIsBot()
{
	if ( isDefined( level.bot_builtins ) && isDefined( level.bot_builtins["isbot"] ) )
	{
		return self [[ level.bot_builtins["isbot" ]]]();
	}

	return false;
}

/*
	Returns if player is the host
*/
is_host()
{
	return ( isDefined( self.pers["bot_host"] ) && self.pers["bot_host"] );
}

/*
	Setups the host variable on the player
*/
doHostCheck()
{
	self.pers["bot_host"] = false;

	if ( self is_bot() )
		return;

	result = false;

	if ( getDvar( "bots_main_firstIsHost" ) != "0" )
	{
		BotBuiltinPrintConsole( "WARNING: bots_main_firstIsHost is enabled" );

		if ( getDvar( "bots_main_firstIsHost" ) == "1" )
		{
			setDvar( "bots_main_firstIsHost", self getguid() );
		}

		if ( getDvar( "bots_main_firstIsHost" ) == self getguid() + "" )
			result = true;
	}

	DvarGUID = getDvar( "bots_main_GUIDs" );

	if ( DvarGUID != "" )
	{
		guids = strtok( DvarGUID, "," );

		for ( i = 0; i < guids.size; i++ )
		{
			if ( self getguid() + "" == guids[i] )
				result = true;
		}
	}

	if ( !result )
		return;

	self.pers["bot_host"] = true;
}

/*
	Returns if the player is a bot.
*/
is_bot()
{
	return self BotBuiltinIsBot();
}

/*
	Set the bot's stance
*/
BotSetStance( stance )
{
	switch ( stance )
	{
		case "stand":
			self maps\mp\bots\_bot_internal::stand();
			break;

		case "crouch":
			self maps\mp\bots\_bot_internal::crouch();
			break;

		case "prone":
			self maps\mp\bots\_bot_internal::prone();
			break;
	}
}

/*
	Bot presses the button for time.
*/
BotPressAttack( time )
{
	self maps\mp\bots\_bot_internal::pressFire( time );
}

/*
	Bot presses the ads button for time.
*/
BotPressADS( time )
{
	self maps\mp\bots\_bot_internal::pressADS( time );
}

/*
	Bot presses the use button for time.
*/
BotPressUse( time )
{
	self maps\mp\bots\_bot_internal::use( time );
}

/*
	Bot presses the frag button for time.
*/
BotPressFrag( time )
{
	self maps\mp\bots\_bot_internal::frag( time );
}

/*
	Bot presses the smoke button for time.
*/
BotPressSmoke( time )
{
	self maps\mp\bots\_bot_internal::smoke( time );
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
	if ( !isDefined( self.bot.target ) )
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
	If the model of the player is good
*/
IsPlayerModelOK()
{
	return ( isDefined( self.bot_model_fix ) && !isDefined( self.gib_ref ) );
}

/*
	Freezes the bot's controls.
*/
BotFreezeControls( what )
{
	self.bot.isfrozen = what;

	if ( what )
		self notify( "kill_goal" );
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
BotStopMoving( what )
{
	self.bot.stop_move = what;

	if ( what )
		self notify( "kill_goal" );
}

/*
	Notify the bot chat message
*/
BotNotifyBotEvent( msg, a, b, c, d, e, f, g )
{
	self notify( "bot_event", msg, a, b, c, d, e, f, g );
}

/*
	Returns if the bot has a script goal.
	(like t5 gsc bot)
*/
HasScriptGoal()
{
	return ( isDefined( self GetScriptGoal() ) );
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
SetScriptGoal( goal, dist )
{
	if ( !isDefined( dist ) )
		dist = 16;

	self.bot.script_goal = goal;
	self.bot.script_goal_dist = dist;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Clears the bot's goal.
*/
ClearScriptGoal()
{
	self SetScriptGoal( undefined, 0 );
}

/*
	Sets the aim position of the bot
*/
SetScriptAimPos( pos )
{
	self.bot.script_aimpos = pos;
}

/*
	Clears the aim position of the bot
*/
ClearScriptAimPos()
{
	self SetScriptAimPos( undefined );
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
	return isDefined( self GetScriptAimPos() );
}

/*
	Sets the bot's target to be this ent.
*/
SetAttacker( att )
{
	self.bot.target_this_frame = att;
}

/*
	Sets the script enemy for a bot.
*/
SetScriptEnemy( enemy, offset )
{
	self.bot.script_target = enemy;
	self.bot.script_target_offset = offset;
}

/*
	Removes the script enemy of the bot.
*/
ClearScriptEnemy()
{
	self SetScriptEnemy( undefined, undefined );
}

/*
	Returns the entity of the bot's target.
*/
GetThreat()
{
	if ( !isdefined( self.bot.target ) )
		return undefined;

	return self.bot.target.entity;
}

/*
	Returns if the bot has a script enemy.
*/
HasScriptEnemy()
{
	return ( isDefined( self.bot.script_target ) );
}

/*
	Returns if the bot has a threat.
*/
HasThreat()
{
	return ( isDefined( self GetThreat() ) );
}

/*
	Returns whether the bot has a priority objective
*/
HasPriorityObjective()
{
	return self.bot.prio_objective;
}

/*
	Sets the bot to prioritize the objective over targeting enemies
*/
SetPriorityObjective()
{
	self.bot.prio_objective = true;
	self notify( "kill_goal" );
}

/*
	Clears the bot's priority objective to allow the bot to target enemies automatically again
*/
ClearPriorityObjective()
{
	self.bot.prio_objective = false;
	self notify( "kill_goal" );
}

/*
	If the player is defusing
*/
IsDefusing()
{
	return ( isDefined( self.isDefusing ) && self.isDefusing );
}

/*
	If the play is planting
*/
isPlanting()
{
	return ( isDefined( self.isPlanting ) && self.isPlanting );
}

/*
	If the player is in laststand
*/
inLastStand()
{
	return ( isDefined( self.lastStand ) && self.lastStand );
}

/*
	Returns if we are beingArtilleryShellshocked
*/
isArtShocked()
{
	return ( isDefined( self.beingArtilleryShellshocked ) && self.beingArtilleryShellshocked );
}

/*
	If the player is carrying a bomb
*/
isBombCarrier()
{
	return ( isDefined( self.isBombCarrier ) && self.isBombCarrier );
}

/*
	If the site is in use
*/
isInUse()
{
	return ( isDefined( self.inUse ) && self.inUse );
}

/*
	is flared
*/
IsFlared()
{
	return ( isdefined( self.inFlareVisionArea ) && self.inFlareVisionArea && !self hasPerk( "specialty_shades" ) );
}

/*
	Is gased
*/
isGased()
{
	return ( isdefined( self.inPoisonArea ) && self.inPoisonArea && !self hasPerk( "specialty_gas_mask" ) );
}

/*
	If the player is the flag carrier
*/
isFlagCarrier()
{
	return ( isDefined( self.isFlagCarrier ) && self.isFlagCarrier );
}

/*
	Returns a valid grenade launcher weapon
*/
getValidTube()
{
	weaps = self getweaponslist();

	for ( i = 0; i < weaps.size; i++ )
	{
		weap = weaps[i];

		if ( !self getAmmoCount( weap ) )
			continue;

		if ( isSubStr( weap, "gl_" ) && !isSubStr( weap, "_gl_" ) )
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
	grenadeTypes[grenadeTypes.size] = "molotov_mp";
	grenadeTypes[grenadeTypes.size] = "m8_white_smoke_mp";
	grenadeTypes[grenadeTypes.size] = "tabun_gas_mp";
	grenadeTypes[grenadeTypes.size] = "sticky_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "signal_flare_mp";

	possibles = [];

	for ( i = 0; i < grenadeTypes.size; i++ )
	{
		if ( !self hasWeapon( grenadeTypes[i] ) )
			continue;

		if ( !self getAmmoCount( grenadeTypes[i] ) )
			continue;

		possibles[possibles.size] = grenadeTypes[i];
	}

	return PickRandom( possibles );
}

/*
	Picks a random thing
*/
PickRandom( arr )
{
	if ( !arr.size )
		return undefined;

	return arr[randomInt( arr.size )];
}

/*
	If weap is a secondary gnade
*/
isSecondaryGrenade( gnade )
{
	return ( gnade == "tabun_gas_mp" || gnade == "m8_white_smoke_mp" || gnade == "signal_flare_mp" );
}

/*
	CoD4
*/
getBaseWeaponName( weap )
{
	return strtok( weap, "_" )[0];
}

/*
	Returns if the given weapon is full auto.
*/
WeaponIsFullAuto( weap )
{
	weaptoks = strtok( weap, "_" );

	return isDefined( weaptoks[0] ) && isString( weaptoks[0] ) && isdefined( level.bots_fullautoguns[weaptoks[0]] );
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
	return self getTagOrigin( "tag_eye" );
}

/*
	helper
*/
waittill_either_return_( str1, str2 )
{
	self endon( str1 );
	self waittill( str2 );
	return true;
}

/*
	Returns which string gets notified first
*/
waittill_either_return( str1, str2 )
{
	if ( !isDefined( self waittill_either_return_( str1, str2 ) ) )
		return str1;

	return str2;
}

/*
	iw5
*/
allowClassChoice()
{
	return true;
}

/*
	iw5
*/
allowTeamChoice()
{
	return true;
}

/*
	Taken from iw4 script
*/
waittill_any_timeout( timeOut, string1, string2, string3, string4, string5 )
{
	if ( ( !isdefined( string1 ) || string1 != "death" ) &&
	    ( !isdefined( string2 ) || string2 != "death" ) &&
	    ( !isdefined( string3 ) || string3 != "death" ) &&
	    ( !isdefined( string4 ) || string4 != "death" ) &&
	    ( !isdefined( string5 ) || string5 != "death" ) )
		self endon( "death" );

	ent = spawnstruct();

	if ( isdefined( string1 ) )
		self thread waittill_string( string1, ent );

	if ( isdefined( string2 ) )
		self thread waittill_string( string2, ent );

	if ( isdefined( string3 ) )
		self thread waittill_string( string3, ent );

	if ( isdefined( string4 ) )
		self thread waittill_string( string4, ent );

	if ( isdefined( string5 ) )
		self thread waittill_string( string5, ent );

	ent thread _timeout( timeOut );

	ent waittill( "returned", msg );
	ent notify( "die" );
	return msg;
}

/*
	Used for waittill_any_timeout
*/
_timeout( delay )
{
	self endon( "die" );

	wait( delay );
	self notify( "returned", "timeout" );
}

/*
	Returns if we have the create a class object unlocked.
*/
isItemUnlocked( what, lvl )
{
	switch ( what )
	{
		case "m1carbine":
			return ( lvl >= 65 );

		case "m1garand":
			return ( lvl >= 17 );

		case "mg42":
			return ( lvl >= 33 );

		case "mosinrifle":
			return ( lvl >= 21 );

		case "mp40":
			return ( lvl >= 10 );

		case "ppsh":
			return ( lvl >= 53 );

		case "ptrs41":
			return ( lvl >= 57 );

		case "shotgun":
			return true;

		case "springfield":
			return true;

		case "stg44":
			return ( lvl >= 37 );

		case "svt40":
			return true;

		case "thompson":
			return true;

		case "type99rifle":
			return true;

		case "type100smg":
			return ( lvl >= 25 );

		case "type99lmg":
			return true;

		case "kar98k":
			return ( lvl >= 41 );

		case "gewehr43":
			return ( lvl >= 7 );

		case "fg42":
			return ( lvl >= 45 );

		case "doublebarreledshotgun":
			return ( lvl >= 29 );

		case "bar":
			return true;

		case "30cal":
			return ( lvl >= 61 );

		case "dp28":
			return ( lvl >= 13 );

		case "walther":
			return true;

		case "357magnum":
			return ( lvl >= 49 );

		case "colt":
			return true;

		case "nambu":
			return true;

		case "tokarev":
			return ( lvl >= 21 );

		case "frag_grenade_mp":
			return true;

		case "molotov_mp":
			return ( lvl >= 10 );

		case "sticky_grenade_mp":
			return true;

		case "specialty_water_cooled":
			return true;

		case "specialty_greased_barrings":
			return true;

		case "specialty_ordinance":
			return ( lvl >= 12 );

		case "specialty_boost":
			return ( lvl >= 28 );

		case "specialty_leadfoot":
			return ( lvl >= 40 );

		case "specialty_bulletdamage":
			return true;

		case "specialty_armorvest":
			return true;

		case "specialty_fastreload":
			return ( lvl >= 28 );

		case "specialty_rof":
			return ( lvl >= 36 );

		case "specialty_twoprimaries":
			return ( lvl >= 56 );

		case "specialty_gpsjammer":
			return ( lvl >= 12 );

		case "specialty_explosivedamage":
			return true;

		case "specialty_flakjacket":
			return true;

		case "specialty_shades":
			return ( lvl >= 32 );

		case "specialty_gas_mask":
			return true;

		case "specialty_longersprint":
			return true;

		case "specialty_bulletaccuracy":
			return true;

		case "specialty_pistoldeath":
			return ( lvl >= 9 );

		case "specialty_grenadepulldeath":
			return ( lvl >= 20 );

		case "specialty_bulletpenetration":
			return true;

		case "specialty_holdbreath":
			return ( lvl >= 60 );

		case "specialty_quieter":
			return ( lvl >= 52 );

		case "specialty_fireproof":
			return ( lvl >= 48 );

		case "specialty_reconnaissance":
			return ( lvl >= 64 );

		case "specialty_pin_back":
			return ( lvl >= 6 );

		case "specialty_specialgrenade":
			return true;

		case "specialty_weapon_bouncing_betty":
			return ( lvl >= 24 );

		case "specialty_weapon_flamethrower":
			return ( lvl >= 65 );

		case "specialty_fraggrenade":
			return ( lvl >= 44 );

		case "specialty_extraammo":
			return ( lvl >= 40 );

		case "specialty_detectexplosive":
			return ( lvl >= 16 );

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
isWeaponDroppable( weap )
{
	return ( maps\mp\gametypes\_weapons::mayDropWeapon( weap ) );
}

/*
	Waits until not or tim.
*/
waittill_notify_or_timeout( not, tim )
{
	self endon( not );
	wait tim;
}

/*
	Gets a player who is host
*/
GetHostPlayer()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		if ( !player is_host() )
			continue;

		return player;
	}

	return undefined;
}

/*
    Waits for a host player
*/
bot_wait_for_host()
{
	host = undefined;

	while ( !isDefined( level ) || !isDefined( level.players ) )
		wait 0.05;

	for ( i = getDvarFloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		host = GetHostPlayer();

		if ( isDefined( host ) )
			break;

		wait 0.05;
	}

	if ( !isDefined( host ) )
		return;

	for ( i = getDvarFloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		if ( IsDefined( host.pers[ "team" ] ) )
			break;

		wait 0.05;
	}

	if ( !IsDefined( host.pers[ "team" ] ) )
		return;

	for ( i = getDvarFloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		if ( host.pers[ "team" ] == "allies" || host.pers[ "team" ] == "axis" )
			break;

		wait 0.05;
	}
}

/*
	Pezbot's line sphere intersection.
	http://paulbourke.net/geometry/circlesphere/raysphere.c
*/
RaySphereIntersect( start, end, spherePos, radius )
{
	// check if the start or end points are in the sphere
	r2 = radius * radius;

	if ( DistanceSquared( start, spherePos ) < r2 )
		return true;

	if ( DistanceSquared( end, spherePos ) < r2 )
		return true;

	// check if the line made by start and end intersect the sphere
	dp = end - start;
	a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
	b = 2 * ( dp[0] * ( start[0] - spherePos[0] ) + dp[1] * ( start[1] - spherePos[1] ) + dp[2] * ( start[2] - spherePos[2] ) );
	c = spherePos[0] * spherePos[0] + spherePos[1] * spherePos[1] + spherePos[2] * spherePos[2];
	c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
	c -= 2.0 * ( spherePos[0] * start[0] + spherePos[1] * start[1] + spherePos[2] * start[2] );
	c -= radius * radius;
	bb4ac = b * b - 4.0 * a * c;

	if ( abs( a ) < 0.0001 || bb4ac < 0 )
		return false;

	mu1 = ( 0 - b + sqrt( bb4ac ) ) / ( 2 * a );
	//mu2 = (0-b - sqrt(bb4ac)) / (2 * a);

	// intersection points of the sphere
	ip1 = start + mu1 * dp;
	//ip2 = start + mu2 * dp;

	myDist = DistanceSquared( start, end );

	// check if both intersection points far
	if ( DistanceSquared( start, ip1 ) > myDist/* && DistanceSquared(start, ip2) > myDist*/ )
		return false;

	dpAngles = VectorToAngles( dp );

	// check if the point is behind us
	if ( getConeDot( ip1, start, dpAngles ) < 0/* || getConeDot(ip2, start, dpAngles) < 0*/ )
		return false;

	return true;
}

/*
	Returns if a smoke grenade would intersect start to end line.
*/
SmokeTrace( start, end, rad )
{
	for ( i = level.bots_smokeList.count - 1; i >= 0; i-- )
	{
		nade = level.bots_smokeList.data[i];

		if ( nade.state != "smoking" )
			continue;

		if ( !RaySphereIntersect( start, end, nade.origin, rad ) )
			continue;

		return false;
	}

	return true;
}

/*
	Returns the cone dot (like fov, or distance from the center of our screen). 1.0 = directly looking at, 0.0 = completely right angle, -1.0, completely 180
*/
getConeDot( to, from, dir )
{
	dirToTarget = VectorNormalize( to - from );
	forward = AnglesToForward( dir );
	return vectordot( dirToTarget, forward );
}

/*
	Returns the distance squared in a 2d space
*/
DistanceSquared2D( to, from )
{
	to = ( to[0], to[1], 0 );
	from = ( from[0], from[1], 0 );

	return DistanceSquared( to, from );
}

/*
	Rounds to the nearest whole number.
*/
Round( x )
{
	y = int( x );

	if ( abs( x ) - abs( y ) > 0.5 )
	{
		if ( x < 0 )
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
	if ( !isDefined( level.tbl_weaponIDs ) )
	{
		level.tbl_weaponIDs = [];

		for ( i = 0; i < 150; i++ )
		{
			reference_s = tableLookup( "mp/statsTable.csv", 0, i, 4 );

			if ( reference_s != "" )
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

	if ( !isDefined( level.tbl_WeaponAttachment ) )
	{
		level.tbl_WeaponAttachment = [];

		for ( i = 0; i < 13; i++ )
		{
			level.tbl_WeaponAttachment[i]["bitmask"] = int( tableLookup( "mp/attachmentTable.csv", 9, i, 10 ) );
			level.tbl_WeaponAttachment[i]["reference"] = tableLookup( "mp/attachmentTable.csv", 9, i, 4 );
		}
	}

	if ( !isDefined( level.tbl_PerkData ) )
	{
		level.tbl_PerkData = [];

		// generating perk data vars collected form statsTable.csv
		for ( i = 150; i < 194; i++ )
		{
			reference_s = tableLookup( "mp/statsTable.csv", 0, i, 4 );

			if ( reference_s != "" )
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

	for ( i = 0; i < 150; i++ )
	{
		if ( !isDefined( level.tbl_weaponIDs[i] ) || !isDefined( level.tbl_weaponIDs[i]["reference"] ) )
			continue;

		level.weaponReferenceToIndex[level.tbl_weaponIDs[i]["reference"]] = i;
	}

	for ( i = 0; i < 13; i++ )
	{
		if ( !isDefined( level.tbl_WeaponAttachment[i] ) || !isDefined( level.tbl_WeaponAttachment[i]["reference"] ) )
			continue;

		level.weaponAttachmentReferenceToIndex[level.tbl_WeaponAttachment[i]["reference"]] = i;
	}

	for ( i = 150; i < 194; i++ )
	{
		if ( !isDefined( level.tbl_PerkData[i] ) || !isDefined( level.tbl_PerkData[i]["reference_full"] ) )
			continue;

		level.perkReferenceToIndex[ level.tbl_PerkData[i]["reference_full"] ] = i;
	}
}

/*
	Clamps between value
*/
Clamp( a, minv, maxv )
{
	return max( min( a, maxv ), minv );
}

/*
	converts a string into a float
*/
float( num )
{
	setdvar( "temp_dvar_bot_util", num );

	return GetDvarFloat( "temp_dvar_bot_util" );
}

/*
	Tokenizes a string (strtok has limits...) (only one char tok)
*/
tokenizeLine( line, tok )
{
	tokens = [];

	token = "";

	for ( i = 0; i < line.size; i++ )
	{
		c = line[i];

		if ( c == tok )
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
	Parses tokens into a waypoint obj
*/
parseTokensIntoWaypoint( tokens )
{
	waypoint = spawnStruct();

	orgStr = tokens[0];
	orgToks = strtok( orgStr, " " );
	waypoint.origin = ( float( orgToks[0] ), float( orgToks[1] ), float( orgToks[2] ) );

	childStr = tokens[1];
	childToks = strtok( childStr, " " );
	waypoint.children = [];

	for ( j = 0; j < childToks.size; j++ )
		waypoint.children[j] = int( childToks[j] );

	type = tokens[2];
	waypoint.type = type;

	anglesStr = tokens[3];

	if ( isDefined( anglesStr ) && anglesStr != "" )
	{
		anglesToks = strtok( anglesStr, " " );
		waypoint.angles = ( float( anglesToks[0] ), float( anglesToks[1] ), float( anglesToks[2] ) );
	}

	return waypoint;
}

/*
	Returns an array of each line
*/
getWaypointLinesFromFile( filename )
{
	result = spawnStruct();
	result.lines = [];

	waypointStr = BotBuiltinFileRead( filename );

	if ( !isDefined( waypointStr ) )
		return result;

	line = "";

	for ( i = 0; i < waypointStr.size; i++ )
	{
		c = waypointStr[i];

		if ( c == "\n" )
		{
			result.lines[result.lines.size] = line;

			line = "";
			continue;
		}

		line += c;
	}

	result.lines[result.lines.size] = line;

	return result;
}

/*
	Read from file a csv, and returns an array of waypoints
*/
readWpsFromFile( mapname )
{
	waypoints = [];
	filename = "waypoints/" + mapname + "_wp.csv";

	if ( !BotBuiltinFileExists( filename ) )
		return waypoints;

	res = getWaypointLinesFromFile( filename );

	if ( !res.lines.size )
		return waypoints;

	BotBuiltinPrintConsole( "Attempting to read waypoints from " + filename );

	waypointCount = int( res.lines[0] );

	for ( i = 1; i <= waypointCount; i++ )
	{
		tokens = tokenizeLine( res.lines[i], "," );

		waypoint = parseTokensIntoWaypoint( tokens );

		waypoints[i - 1] = waypoint;
	}

	return waypoints;
}

/*
	Loads the waypoints. Populating everything needed for the waypoints.
*/
load_waypoints()
{
	mapname = getDvar( "mapname" );

	level.waypointCount = 0;
	level.waypoints = [];
	level.waypointUsage = [];
	level.waypointUsage["allies"] = [];
	level.waypointUsage["axis"] = [];

	wps = readWpsFromFile( mapname );

	if ( wps.size )
	{
		level.waypoints = wps;
		BotBuiltinPrintConsole( "Loaded " + wps.size + " waypoints from file" );
	}
	else
	{
		switch ( mapname )
		{
			default:
				maps\mp\bots\waypoints\_custom_map::main( mapname );
				break;
		}

		if ( level.waypoints.size )
			BotBuiltinPrintConsole( "Loaded " + level.waypoints.size + " waypoints from script" );
	}

	if ( !level.waypoints.size )
	{
		BotBuiltinPrintConsole( "No waypoints loaded!" );
	}

	level.waypointCount = level.waypoints.size;

	for ( i = 0; i < level.waypointCount; i++ )
	{
		if ( !isDefined( level.waypoints[i].children ) || !isDefined( level.waypoints[i].children.size ) )
			level.waypoints[i].children = [];

		if ( !isDefined( level.waypoints[i].origin ) )
			level.waypoints[i].origin = ( 0, 0, 0 );

		if ( !isDefined( level.waypoints[i].type ) )
			level.waypoints[i].type = "crouch";

		level.waypoints[i].childCount = undefined;
	}
}

/*
	Is bot near any of the given waypoints
*/
nearAnyOfWaypoints( dist, waypoints )
{
	dist *= dist;

	for ( i = 0; i < waypoints.size; i++ )
	{
		waypoint = level.waypoints[waypoints[i]];

		if ( DistanceSquared( waypoint.origin, self.origin ) > dist )
			continue;

		return true;
	}

	return false;
}

/*
	Returns the waypoints that are near
*/
waypointsNear( waypoints, dist )
{
	dist *= dist;

	answer = [];

	for ( i = 0; i < waypoints.size; i++ )
	{
		wp = level.waypoints[waypoints[i]];

		if ( DistanceSquared( wp.origin, self.origin ) > dist )
			continue;

		answer[answer.size] = waypoints[i];
	}

	return answer;
}

/*
	Returns nearest waypoint of waypoints
*/
getNearestWaypointOfWaypoints( waypoints )
{
	answer = undefined;
	closestDist = 2147483647;

	for ( i = 0; i < waypoints.size; i++ )
	{
		waypoint = level.waypoints[waypoints[i]];
		thisDist = DistanceSquared( self.origin, waypoint.origin );

		if ( isDefined( answer ) && thisDist > closestDist )
			continue;

		answer = waypoints[i];
		closestDist = thisDist;
	}

	return answer;
}

/*
	Returns all waypoints of type
*/
getWaypointsOfType( type )
{
	answer = [];

	for ( i = 0; i < level.waypointCount; i++ )
	{
		wp = level.waypoints[i];

		if ( type == "camp" )
		{
			if ( wp.type != "crouch" )
				continue;

			if ( wp.children.size != 1 )
				continue;
		}
		else if ( type != wp.type )
			continue;

		answer[answer.size] = i;
	}

	return answer;
}

/*
	Returns the waypoint for index
*/
getWaypointForIndex( i )
{
	if ( !isDefined( i ) )
		return undefined;

	return level.waypoints[i];
}

/*
	Returns a good amount of players.
*/
getGoodMapAmount()
{
	switch ( getDvar( "mapname" ) )
	{
		case "mp_kneedeep":
		case "mp_seelow":
		case "mp_outskirts":
		case "mp_downfall":
		case "mp_roundhouse":
			if ( level.teamBased )
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
			if ( level.teamBased )
				return 12;
			else
				return 8;

		case "mp_dome":
		case "mp_drum":
			if ( level.teamBased )
				return 8;
			else
				return 4;
	}

	return 2;
}

/*
	Matches a num to a char
*/
keyCodeToString( a )
{
	b = "";

	switch ( a )
	{
		case 0:
			b = "a";
			break;

		case 1:
			b = "b";
			break;

		case 2:
			b = "c";
			break;

		case 3:
			b = "d";
			break;

		case 4:
			b = "e";
			break;

		case 5:
			b = "f";
			break;

		case 6:
			b = "g";
			break;

		case 7:
			b = "h";
			break;

		case 8:
			b = "i";
			break;

		case 9:
			b = "j";
			break;

		case 10:
			b = "k";
			break;

		case 11:
			b = "l";
			break;

		case 12:
			b = "m";
			break;

		case 13:
			b = "n";
			break;

		case 14:
			b = "o";
			break;

		case 15:
			b = "p";
			break;

		case 16:
			b = "q";
			break;

		case 17:
			b = "r";
			break;

		case 18:
			b = "s";
			break;

		case 19:
			b = "t";
			break;

		case 20:
			b = "u";
			break;

		case 21:
			b = "v";
			break;

		case 22:
			b = "w";
			break;

		case 23:
			b = "x";
			break;

		case 24:
			b = "y";
			break;

		case 25:
			b = "z";
			break;

		case 26:
			b = ".";
			break;

		case 27:
			b = " ";
			break;
	}

	return b;
}

/*
	Returns the friendly user name for a given map's codename
*/
getMapName( map )
{
	switch ( map )
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
	Does the extra check when adding bots
*/
doExtraCheck()
{
	maps\mp\bots\_bot_internal::checkTheBots();
}

/*
	Returns an array of all the bots in the game.
*/
getBotArray()
{
	result = [];
	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( !player is_bot() )
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

	kdTree _WaypointsToKDTree( level.waypoints, 0 );

	return kdTree;
}

/*
	Recurive function. We construct a balanced KD tree by sorting the waypoints using heap sort.
*/
_WaypointsToKDTree( waypoints, dem )
{
	if ( !waypoints.size )
		return;

	callbacksort = undefined;

	switch ( dem )
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

	heap = NewHeap( callbacksort );

	for ( i = 0; i < waypoints.size; i++ )
	{
		heap HeapInsert( waypoints[i] );
	}

	sorted = [];

	while ( heap.data.size )
	{
		sorted[sorted.size] = heap.data[0];
		heap HeapRemove();
	}

	median = int( sorted.size / 2 ); //use divide and conq

	left = [];
	right = [];

	for ( i = 0; i < sorted.size; i++ )
		if ( i < median )
			right[right.size] = sorted[i];
		else if ( i > median )
			left[left.size] = sorted[i];

	self KDTreeInsert( sorted[median] );

	_WaypointsToKDTree( left, ( dem + 1 ) % 3 );

	_WaypointsToKDTree( right, ( dem + 1 ) % 3 );
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
ListAdd( thing )
{
	self.data[self.count] = thing;

	self.count++;
}

/*
	Adds to the start of the list.
*/
ListAddFirst( thing )
{
	for ( i = self.count - 1; i >= 0; i-- )
	{
		self.data[i + 1] = self.data[i];
	}

	self.data[0] = thing;
	self.count++;
}

/*
	Removes the thing from the list.
*/
ListRemove( thing )
{
	for ( i = 0; i < self.count; i++ )
	{
		if ( self.data[i] == thing )
		{
			while ( i < self.count - 1 )
			{
				self.data[i] = self.data[i + 1];
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
KDTreeInsert( data ) //as long as what you insert has a .origin attru, it will work.
{
	self.root = self _KDTreeInsert( self.root, data, 0, -2147483647, -2147483647, -2147483647, 2147483647, 2147483647, 2147483647 );
}

/*
	Recurive function that insert the object into the KDTree.
*/
_KDTreeInsert( node, data, dem, x0, y0, z0, x1, y1, z1 )
{
	if ( !isDefined( node ) )
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

	switch ( dem )
	{
		case 0:
			if ( data.origin[0] < node.data.origin[0] )
				node.left = self _KDTreeInsert( node.left, data, 1, x0, y0, z0, node.data.origin[0], y1, z1 );
			else
				node.right = self _KDTreeInsert( node.right, data, 1, node.data.origin[0], y0, z0, x1, y1, z1 );

			break;

		case 1:
			if ( data.origin[1] < node.data.origin[1] )
				node.left = self _KDTreeInsert( node.left, data, 2, x0, y0, z0, x1, node.data.origin[1], z1 );
			else
				node.right = self _KDTreeInsert( node.right, data, 2, x0, node.data.origin[1], z0, x1, y1, z1 );

			break;

		case 2:
			if ( data.origin[2] < node.data.origin[2] )
				node.left = self _KDTreeInsert( node.left, data, 0, x0, y0, z0, x1, y1, node.data.origin[2] );
			else
				node.right = self _KDTreeInsert( node.right, data, 0, x0, y0, node.data.origin[2], x1, y1, z1 );

			break;
	}

	return node;
}

/*
	Called on a KDTree, will return the nearest object to the given origin.
*/
KDTreeNearest( origin )
{
	if ( !isDefined( self.root ) )
		return undefined;

	return self _KDTreeNearest( self.root, origin, self.root.data, DistanceSquared( self.root.data.origin, origin ), 0 );
}

/*
	Recurive function that will retrieve the closest object to the query.
*/
_KDTreeNearest( node, point, closest, closestdist, dem )
{
	if ( !isDefined( node ) )
	{
		return closest;
	}

	thisDis = DistanceSquared( node.data.origin, point );

	if ( thisDis < closestdist )
	{
		closestdist = thisDis;
		closest = node.data;
	}

	if ( node RectDistanceSquared( point ) < closestdist )
	{
		near = node.left;
		far = node.right;

		if ( point[dem] > node.data.origin[dem] )
		{
			near = node.right;
			far = node.left;
		}

		closest = self _KDTreeNearest( near, point, closest, closestdist, ( dem + 1 ) % 3 );

		closest = self _KDTreeNearest( far, point, closest, DistanceSquared( closest.origin, point ), ( dem + 1 ) % 3 );
	}

	return closest;
}

/*
	Called on a rectangle, returns the distance from origin to the rectangle.
*/
RectDistanceSquared( origin )
{
	dx = 0;
	dy = 0;
	dz = 0;

	if ( origin[0] < self.x0 )
		dx = origin[0] - self.x0;
	else if ( origin[0] > self.x1 )
		dx = origin[0] - self.x1;

	if ( origin[1] < self.y0 )
		dy = origin[1] - self.y0;
	else if ( origin[1] > self.y1 )
		dy = origin[1] - self.y1;


	if ( origin[2] < self.z0 )
		dz = origin[2] - self.z0;
	else if ( origin[2] > self.z1 )
		dz = origin[2] - self.z1;

	return dx * dx + dy * dy + dz * dz;
}

/*
	A heap invarient comparitor, used for objects, objects with a higher X coord will be first in the heap.
*/
HeapSortCoordX( item, item2 )
{
	return item.origin[0] > item2.origin[0];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Y coord will be first in the heap.
*/
HeapSortCoordY( item, item2 )
{
	return item.origin[1] > item2.origin[1];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Z coord will be first in the heap.
*/
HeapSortCoordZ( item, item2 )
{
	return item.origin[2] > item2.origin[2];
}

/*
	A heap invarient comparitor, used for numbers, numbers with the highest number will be first in the heap.
*/
Heap( item, item2 )
{
	return item > item2;
}

/*
	A heap invarient comparitor, used for numbers, numbers with the lowest number will be first in the heap.
*/
ReverseHeap( item, item2 )
{
	return item < item2;
}

/*
	A heap invarient comparitor, used for traces. Wanting the trace with the largest length first in the heap.
*/
HeapTraceFraction( item, item2 )
{
	return item["fraction"] > item2["fraction"];
}

/*
	Returns a new heap.
*/
NewHeap( compare )
{
	heap_node = spawnStruct();
	heap_node.data = [];
	heap_node.compare = compare;

	return heap_node;
}

/*
	Inserts the item into the heap. Called on a heap.
*/
HeapInsert( item )
{
	insert = self.data.size;
	self.data[insert] = item;

	current = insert + 1;

	while ( current > 1 )
	{
		last = current;
		current = int( current / 2 );

		if ( ![[self.compare]]( item, self.data[current - 1] ) )
			break;

		self.data[last - 1] = self.data[current - 1];
		self.data[current - 1] = item;
	}
}

/*
	Helper function to determine what is the next child of the bst.
*/
_HeapNextChild( node, hsize )
{
	left = node * 2;
	right = left + 1;

	if ( left > hsize )
		return -1;

	if ( right > hsize )
		return left;

	if ( [[self.compare]]( self.data[left - 1], self.data[right - 1] ) )
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

	if ( !remove )
		return remove;

	move = self.data[remove - 1];
	self.data[0] = move;
	self.data[remove - 1] = undefined;
	remove--;

	if ( !remove )
		return remove;

	last = 1;
	next = self _HeapNextChild( 1, remove );

	while ( next != -1 )
	{
		if ( [[self.compare]]( move, self.data[next - 1] ) )
			break;

		self.data[last - 1] = self.data[next - 1];
		self.data[next - 1] = move;

		last = next;
		next = self _HeapNextChild( next, remove );
	}

	return remove;
}

/*
	A heap invarient comparitor, used for the astar's nodes, wanting the node with the lowest f to be first in the heap.
*/
ReverseHeapAStar( item, item2 )
{
	return item.f < item2.f;
}

/*
	Removes the waypoint usage
*/
RemoveWaypointUsage( wp, team )
{
	if ( !isDefined( level.waypointUsage ) )
		return;

	if ( !isDefined( level.waypointUsage[team][wp + ""] ) )
		return;

	level.waypointUsage[team][wp + ""]--;

	if ( level.waypointUsage[team][wp + ""] <= 0 )
		level.waypointUsage[team][wp + ""] = undefined;
}

/*
	Will linearly search for the nearest waypoint to pos that has a direct line of sight.
*/
GetNearestWaypointWithSight( pos )
{
	candidate = undefined;
	dist = 2147483647;

	for ( i = 0; i < level.waypointCount; i++ )
	{
		if ( !bulletTracePassed( pos + ( 0, 0, 15 ), level.waypoints[i].origin + ( 0, 0, 15 ), false, undefined ) )
			continue;

		curdis = DistanceSquared( level.waypoints[i].origin, pos );

		if ( curdis > dist )
			continue;

		dist = curdis;
		candidate = i;
	}

	return candidate;
}

/*
	Will linearly search for the nearest waypoint
*/
GetNearestWaypoint( pos )
{
	candidate = undefined;
	dist = 2147483647;

	for ( i = 0; i < level.waypointCount; i++ )
	{
		curdis = DistanceSquared( level.waypoints[i].origin, pos );

		if ( curdis > dist )
			continue;

		dist = curdis;
		candidate = i;
	}

	return candidate;
}

/*
	Modified Pezbot astar search.
	This makes use of sets for quick look up and a heap for a priority queue instead of simple lists which require to linearly search for elements everytime.
	It is also modified to make paths with bots already on more expensive and will try a less congested path first. Thus spliting up the bots onto more paths instead of just one (the smallest).
*/
AStarSearch( start, goal, team, greedy_path )
{
	open = NewHeap( ::ReverseHeapAStar ); //heap
	openset = [];//set for quick lookup
	closed = [];//set for quick lookup


	startWp = getNearestWaypoint( start );

	if ( !isDefined( startWp ) )
		return [];

	_startwp = undefined;

	if ( !bulletTracePassed( start + ( 0, 0, 15 ), level.waypoints[startWp].origin + ( 0, 0, 15 ), false, undefined ) )
		_startwp = GetNearestWaypointWithSight( start );

	if ( isDefined( _startwp ) )
		startWp = _startwp;


	goalWp = getNearestWaypoint( goal );

	if ( !isDefined( goalWp ) )
		return [];

	_goalWp = undefined;

	if ( !bulletTracePassed( goal + ( 0, 0, 15 ), level.waypoints[goalWp].origin + ( 0, 0, 15 ), false, undefined ) )
		_goalwp = GetNearestWaypointWithSight( goal );

	if ( isDefined( _goalwp ) )
		goalWp = _goalwp;


	node = spawnStruct();
	node.g = 0; //path dist so far
	node.h = DistanceSquared( level.waypoints[startWp].origin, level.waypoints[goalWp].origin ); //herustic, distance to goal for path finding
	node.f = node.h + node.g; // combine path dist and heru, use reverse heap to sort the priority queue by this attru
	node.index = startWp;
	node.parent = undefined; //we are start, so we have no parent

	//push node onto queue
	openset[node.index + ""] = node;
	open HeapInsert( node );

	//while the queue is not empty
	while ( open.data.size )
	{
		//pop bestnode from queue
		bestNode = open.data[0];
		open HeapRemove();
		openset[bestNode.index + ""] = undefined;
		wp = level.waypoints[bestNode.index];

		//check if we made it to the goal
		if ( bestNode.index == goalWp )
		{
			path = [];

			while ( isDefined( bestNode ) )
			{
				if ( isdefined( team ) && isDefined( level.waypointUsage ) )
				{
					if ( !isDefined( level.waypointUsage[team][bestNode.index + ""] ) )
						level.waypointUsage[team][bestNode.index + ""] = 0;

					level.waypointUsage[team][bestNode.index + ""]++;
				}

				//construct path
				path[path.size] = bestNode.index;

				bestNode = bestNode.parent;
			}

			return path;
		}

		//for each child of bestnode
		for ( i = wp.children.size - 1; i >= 0; i-- )
		{
			child = wp.children[i];
			childWp = level.waypoints[child];

			penalty = 1;

			if ( !greedy_path && isdefined( team ) && isDefined( level.waypointUsage ) )
			{
				temppen = 1;

				if ( isDefined( level.waypointUsage[team][child + ""] ) )
					temppen = level.waypointUsage[team][child + ""]; //consider how many bots are taking this path

				if ( temppen > 1 )
					penalty = temppen;
			}

			// have certain types of nodes more expensive
			if ( childWp.type == "climb" || childWp.type == "prone" )
				penalty += 4;

			//calc the total path we have took
			newg = bestNode.g + DistanceSquared( wp.origin, childWp.origin ) * penalty; //bots on same team's path are more expensive

			//check if this child is in open or close with a g value less than newg
			inopen = isDefined( openset[child + ""] );

			if ( inopen && openset[child + ""].g <= newg )
				continue;

			inclosed = isDefined( closed[child + ""] );

			if ( inclosed && closed[child + ""].g <= newg )
				continue;

			node = undefined;

			if ( inopen )
				node = openset[child + ""];
			else if ( inclosed )
				node = closed[child + ""];
			else
				node = spawnStruct();

			node.parent = bestNode;
			node.g = newg;
			node.h = DistanceSquared( childWp.origin, level.waypoints[goalWp].origin );
			node.f = node.g + node.h;
			node.index = child;

			//check if in closed, remove it
			if ( inclosed )
				closed[child + ""] = undefined;

			//check if not in open, add it
			if ( !inopen )
			{
				open HeapInsert( node );
				openset[child + ""] = node;
			}
		}

		//done with children, push onto closed
		closed[bestNode.index + ""] = bestNode;
	}

	return [];
}

/*
	Returns the natural log of x using harmonic series.
*/
Log( x )
{
	/*  if (!isDefined(level.log_cache))
		level.log_cache = [];

	    key = x + "";

	    if (isDefined(level.log_cache[key]))
		return level.log_cache[key];*/

	//thanks Bob__ at stackoverflow
	old_sum = 0.0;
	xmlxpl = ( x - 1 ) / ( x + 1 );
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

	return ( number );
}

onUsePlantObjectFix( player )
{
	// planted the bomb
	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		level thread bombPlantedFix( self, player );
		player logString( "bomb planted: " + self.label );

		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint( "BP;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n" );

		// disable all bomb zones except this one
		for ( index = 0; index < level.bombZones.size; index++ )
		{
			if ( level.bombZones[index] == self )
				continue;

			level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();
		}

		thread playSoundOnPlayers( "mx_SD_planted" + "_" + level.teamPrefix[player.pers["team"]] );
		player playSound( "mp_bomb_plant" );
		player notify ( "bomb_planted" );

		if ( !level.hardcoreMode )
			iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player );

		maps\mp\gametypes\_globallogic::leaderDialog( "bomb_planted" );

		maps\mp\gametypes\_globallogic::givePlayerScore( "plant", player );
		player thread [[level.onXPEvent]]( "plant" );
	}
}

bombPlantedFix( destroyedObj, player )
{
	maps\mp\gametypes\_globallogic::pauseTimer();
	level.bombPlanted = true;

	destroyedObj.visuals[0] thread maps\mp\gametypes\_globallogic::playTickingSound();
	level.tickingObject = destroyedObj.visuals[0];

	level.timeLimitOverride = true;
	setGameEndTime( int( gettime() + ( level.bombTimer * 1000 ) ) );
	setDvar( "ui_bomb_timer", 1 );

	if ( !level.multiBomb )
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
		level.sdBombModel = level.sdBomb.visuals[0];
	}
	else
	{

		for ( index = 0; index < level.players.size; index++ )
		{
			if ( isDefined( level.players[index].carryIcon ) )
				level.players[index].carryIcon destroyElem();
		}

		trace = bulletTrace( player.origin + ( 0, 0, 20 ), player.origin - ( 0, 0, 2000 ), false, player );

		tempAngle = randomfloat( 360 );
		forward = ( cos( tempAngle ), sin( tempAngle ), 0 );
		forward = vectornormalize( forward - vector_scale( trace["normal"], vectordot( forward, trace["normal"] ) ) );
		dropAngles = vectortoangles( forward );

		level.sdBombModel = spawn( "script_model", trace["position"] );
		level.sdBombModel.angles = dropAngles;
		level.sdBombModel setModel( "weapon_explosives" );
	}

	destroyedObj maps\mp\gametypes\_gameobjects::allowUse( "none" );
	destroyedObj maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	/*
	    destroyedObj maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", undefined );
	    destroyedObj maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", undefined );
	    destroyedObj maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", undefined );
	    destroyedObj maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", undefined );
	*/
	label = destroyedObj maps\mp\gametypes\_gameobjects::getLabel();

	// create a new object to defuse with.
	trigger = destroyedObj.bombDefuseTrig;
	trigger.origin = level.sdBombModel.origin;
	visuals = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, ( 0, 0, 32 ) );
	defuseObject maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
	defuseObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defuse" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" + label );
	defuseObject.label = label;
	defuseObject.onBeginUse = maps\mp\gametypes\sd::onBeginUse;
	defuseObject.onEndUse = maps\mp\gametypes\sd::onEndUse;
	defuseObject.onUse = maps\mp\gametypes\sd::onUseDefuseObject;
	defuseObject.useWeapon = "briefcase_bomb_defuse_mp";

	level.defuseObject = defuseObject;

	player.isBombCarrier = false;

	maps\mp\gametypes\sd::BombTimerWait();
	setDvar( "ui_bomb_timer", 0 );

	destroyedObj.visuals[0] maps\mp\gametypes\_globallogic::stopTickingSound();

	if ( level.gameEnded || level.bombDefused )
		return;

	level.bombExploded = true;

	explosionOrigin = level.sdBombModel.origin + ( 0, 0, 12 );
	level.sdBombModel hide();

	if ( isdefined( player ) )
		destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, player, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
	else
		destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );

	if ( isdefined( player ) )
		player setStatLBByName( "search_and_destroy", 1, "Targets Destroyed" );

	rot = randomfloat( 360 );
	explosionEffect = spawnFx( level._effect["bombexplosion"], explosionOrigin + ( 0, 0, 50 ), ( 0, 0, 1 ), ( cos( rot ), sin( rot ), 0 ) );
	triggerFx( explosionEffect );

	thread maps\mp\gametypes\sd::playSoundinSpace( "exp_suitcase_bomb_main", explosionOrigin );

	if ( isDefined( destroyedObj.exploderIndex ) )
		exploder( destroyedObj.exploderIndex );

	for ( index = 0; index < level.bombZones.size; index++ )
		level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();

	defuseObject maps\mp\gametypes\_gameobjects::disableObject();

	setGameEndTime( 0 );

	wait 3;

	maps\mp\gametypes\sd::sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
}
