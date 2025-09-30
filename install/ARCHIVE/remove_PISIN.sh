#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Removing all the GNUstep system and user related
####################################################

####################################################
### Functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh

### wmaker #####################################
function delete_WMaker
{
### Uninstall Windowmaker: guess version
if [ -d ../build/WindowMaker-0.96.0 ];then
	cd ../build/WindowMaker-0.96.0 || exit 1
	sudo -E make uninstall &>/dev/null
	sudo ldconfig
fi

if [ -f /usr/bin/wmaker ];then
	sudo rm -f /usr/bin/wmaker
fi
}

### GNUstep ####################################
function delete_GNUstep
{

if [ -d /usr/GNUstep ];then
	sudo rm -fR /usr/GNUstep
fi
sudo rm -fR /usr/share/GNUstep
sudo rm -fR /usr/lib/GNUstep
sudo rm -fR /usr/local/lib/GNUstep
sudo rm -fR /usr/local/etc/GNUstep
sudo rm -fR /usr/local/share/GNUstep

sudo ldconfig
}
###############################################

function clean
{
################################# Cleaning
sudo rm -fR ../build
################################# user settings
rm -fR $HOME/GNUstep
rm -fR $HOME/.local
rm -f $HOME/.bashrc
cp -f RESOURCES/bashrc.bak $HOME/.bashrc
rm -f $HOME/.xinitrc
for FOL in Books Desktop Documents Downloads Favorites Images Mailboxes Music Samples Videos
do
	rm -fR $HOME/$FOL
done
rm -f $HOME/*.log
}
###################################################

clear

title "Deleting GNUstep Sytem..."

alert "This will delete all the GNUstep System and the User's defaults... Use with caution... Backup your data."

printf "Do you confirm the deletion? "
MSG="(y/n) <enter>:"
read -s -p "$MSG" ANSWER

case "$ANSWER" in
	"y"|"Y")
		printf "\n\nRemoving WMaker...\n"
		delete_WMaker &
		PID=$
		spinner
		printf "\rRemoving GNUstep...\n"
		delete_GNUstep
		printf "User settings...\n"
		clean
		ok "Done"
		info "You may reinstall PiSiN safely now. Execute:"
		cli "./enjoy.sh";;
	"n"|"N"|*) printf "\nAborting.\n\n";;
esac
