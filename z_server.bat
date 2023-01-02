@echo off
::Paste the server key from https://platform.plutonium.pw/serverkeys here
set key=
::RemoteCONtrol password, needed for most management tools like IW4MADMIN and B3. Do not skip if you installing IW4MADMIN.
set rcon_password=
::Name of the config file the server should use.
set cfg=server.cfg
::Name of the server shown in the title of the cmd window. This will NOT bet shown ingame.
set name=PT4MP Bot Warfare
::Port used by the server (default: 28960)
set port=28968
::What ip to bind too
set ip=0.0.0.0
::Mod name (default "")
set mod=
::Only change this when you don't want to keep the bat files in the game folder. MOST WON'T NEED TO EDIT THIS!
set gamepath=%cd%
::Your plutonium install path (leave default!)
set pluto_path=%LOCALAPPDATA%\Plutonium
:: Gamemode; oneof t4sp, t4mp, t5sp, t5mp, iw5mp, t6mp, t6zm
set pluto_game_mode=t4mp
:: Other things to send to cmd
set cmd_extras=""


title Plutonium - %name% - Server restarter
echo Visit plutonium.pw / Join the Discord (a6JM2Tv) for NEWS and Updates!
echo Server "%name%" will load "%cfg%" and listen on port "%port%" UDP with IP "%ip%"!
echo To shut down the server close this window first!
echo (%date%)  -  (%time%) %name% server start.

cd /D %pluto_path%
:server
start /wait /abovenormal /b "%name%" "bin\plutonium-bootstrapper-win32.exe" %pluto_game_mode% "%gamepath%" -dedicated -key "%key%" +set net_ip "%ip%" +set net_port "%port%" +set rcon_password "%rcon_password%" +set fs_game "%mod%" +exec "%cfg%" %cmd_extras% +map_rotate
echo (%date%)  -  (%time%) WARNING: %name% server closed or dropped... server restarts.
goto Server
