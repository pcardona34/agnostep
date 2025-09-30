# AGNOSTEP-Updater

This is AGNOSTEP-Updater, an applet for the [A G N o S t e p   Desktop](https://github.com/pcardona34/agnostep).
It checks if an update is available (until now, only for the OS Debian)
and then notify it via the standard `notify-send' command.

## Prerequisite

- The 'Dunst' notifyer deamon has been loaded within the Xsession: this is 
already done if you yet installed  A G N o S t e p  Desktop.

## Installing

- To add the tool script to your 'autostart' script within WindowMaker, 
just execute:

````
./install_agnostep_updater.sh
````

# Using

Options:

-d : run as an updater to check new available updates 
-g : runs as an upgrader to apply the changes needed
