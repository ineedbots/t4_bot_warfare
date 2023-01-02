#/bin/bash

# For anyone that might be asking for steamdeck support for plutonium:

# Install Lutris's flatpack via Discover
# Use this install script https://lutris.net/games/install/30919/view to install the wine prefix with needed dependencies
# Open the recently installed Wine's configuration, and set all of the xinput library overrides to builtin, native.
# Add Lutris or the recently installed Modern Warfare 3 to Steam as a non steam game
# Play in game-mode, steam deck controls should work (hold Steam button and use touch pad to move and click mouse)
# For MW3, for calling in killstreaks, one could add a radial menu to the left touch pad to press 4, 5 and 6.


# Beware of installing other apps in the wine prefix (like steam), it could break xinput for some reason


# your WINEPREFIX
export WINEPREFIX="/home/deck/Games/call-of-duty-modern-warfare-3-multiplayer/"

# which wine runner you are using
export WINE_LOCATION="/home/deck/.var/app/net.lutris.Lutris/data/lutris/runners/wine/lutris-7.2-2-x86_64/bin/wine"

# which bat to execute
export SERVER_BAT_LOCATION="./z_server.bat"


# exec it
$WINE_LOCATION $SERVER_BAT_LOCATION
