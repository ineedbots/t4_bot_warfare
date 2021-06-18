/*
	_bot_http
	Author: INeedGames
	Date: 12/16/2020
	The HTTP module
*/

#include maps\mp\bots\_bot_utility;

/*
	Will attempt to retreive waypoints from the internet
*/
getRemoteWaypoints( mapname )
{
	url = "https://raw.githubusercontent.com/ineedbots/t4m_waypoints/master/" + mapname + "_wp.csv";
	filename = "waypoints/" + mapname + "_wp.csv";

	PrintConsole( "Attempting to get remote waypoints from " + url + "\n" );
	res = getLinesFromUrl( url, filename );

	if ( !res.lines.size )
		return;

	waypointCount = int( res.lines[0] );

	waypoints = [];
	PrintConsole( "Loading remote waypoints...\n" );

	for ( i = 1; i <= waypointCount; i++ )
	{
		tokens = tokenizeLine( res.lines[i], "," );

		waypoint = parseTokensIntoWaypoint( tokens );

		waypoints[i - 1] = waypoint;
	}

	if ( waypoints.size )
	{
		level.waypoints = waypoints;
		PrintConsole( "Loaded " + waypoints.size + " waypoints from remote.\n" );
	}
}

/*
	Does the version check, if we are up too date
*/
doVersionCheck()
{
	remoteVersion = getRemoteVersion();

	if ( !isDefined( remoteVersion ) )
	{
		PrintConsole( "Error getting remote version of Bot Warfare.\n" );
		return false;
	}

	if ( level.bw_VERSION != remoteVersion )
	{
		PrintConsole( "There is a new version of Bot Warfare!\n" );
		PrintConsole( "You are on version " + level.bw_VERSION + " but " + remoteVersion + " is available!\n" );
		return false;
	}

	PrintConsole( "You are on the latest version of Bot Warfare!\n" );
	return true;
}

/*
	Returns the version of bot warfare found on the internet
*/
getRemoteVersion()
{
	data = httpGet( "https://raw.githubusercontent.com/ineedbots/t4m_waypoints/master/version.txt" );

	if ( !isDefined( data ) )
		return undefined;

	return strtok( data, "\n" )[0];
}

/*
	Returns an array of each line from the response of the http url request
*/
getLinesFromUrl( url, filename )
{
	result = spawnStruct();
	result.lines = [];

	data = HTTPGet( url );

	if ( !isDefined( data ) )
		return result;

	fileWrite( filename, data, "write" );

	line = "";

	for ( i = 0; i < data.size; i++ )
	{
		c = data[i];

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
