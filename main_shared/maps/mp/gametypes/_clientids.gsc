init()
{
	level.clientid = 0;

	level thread onPlayerConnect();

	wait 1;
	
	if (getDvar("scr_xpscale_") == "")
		setDvar("scr_xpscale_", 1);

	level.xpScale = getDvarInt("scr_xpscale_");
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player.clientid = level.clientid;
		level.clientid++;	// Is this safe? What if a server runs for a long time and many people join/leave
	}
}
