init()
{
	level.bot_builtins[ "printconsole" ] = ::do_printconsole;
	level.bot_builtins[ "filewrite" ] = ::do_filewrite;
	level.bot_builtins[ "fileread" ] = ::do_fileread;
	level.bot_builtins[ "fileexists" ] = ::do_fileexists;
	level.bot_builtins[ "botaction" ] = ::do_botaction;
	level.bot_builtins[ "botstop" ] = ::do_botstop;
	level.bot_builtins[ "botmovement" ] = ::do_botmovement;
	level.bot_builtins[ "botmeleeparams" ] = ::do_botmeleeparams;
	level.bot_builtins[ "isbot" ] = ::do_isbot;
}

do_printconsole( s )
{
	printconsole( s );
}

do_filewrite( file, contents, mode )
{
	file = "scriptdata/" + file;
	filewrite( file, contents, mode );
}

do_fileread( file )
{
	file = "scriptdata/" + file;
	return fileread( file );
}

do_fileexists( file )
{
	file = "scriptdata/" + file;
	return true;
}

do_botaction( action )
{
	self botaction( action );
}

do_botstop()
{
	self botstop();
}

do_botmovement( forward, right )
{
	self botmovement( forward, right );
}

do_botmeleeparams( yaw, dist )
{
	// self botmeleeparams( yaw, dist );
}

do_isbot()
{
	return self isbot();
}
