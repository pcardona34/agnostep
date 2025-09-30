#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Set the defaults
### for a PiSiN Desktop
################################

_PWD=`pwd`
DEST=$HOME/GNUstep/Defaults

############################################
### Applying a theme for WMaker:

#### Syntax: setstyle THEME-PACK
#### (in our case: THEME-PACK is 'PISIN')
setstyle --no-cursors --no-fonts $HOME/GNUstep/Library/WindowMaker/Themes/PISIN.themed

############################################
#### Applying Defaults for GNUstep
############################################

if ! [ -d $DEST ];then
	mkdir -p $DEST
fi

cd $_PWD/RESOURCES/DEFAULTS || exit 1

for PLIST in "Addresses" "NSGlobalDomain" "org.gap.InnerSpace" "org.gap.Terminal" "org.gnustep.GNUMail" "org.gnustep.GWorkspace" "org.poroussel.SimpleAgenda"
do
	if [ -f ${PLIST}.plist ];then
		printf "Setting Defaults for ${PLIST}\n"
		cp --force ${PLIST}.plist $DEST/
		if [ "$PLIST" == "org.gnustep.GWorkspace" ];then
			rm -f ${PLIST}.plist
		fi
		ok "Done"
	else
		warning "The File ${PLIST}.plist was not found."
	fi
done
