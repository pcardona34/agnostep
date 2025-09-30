#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Install some ported or native GNUtep Games
####################################################

####################################################
### ENV
_PWD=`pwd`
#. ./SCRIPTS/environ.sh
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
GSMAKE=$(gnustep-config --variable=GNUSTEP_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
LOG="$HOME/AGNOSTEP_BUILD_GAMES.log"
SPIN='/-\|'
INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"
#################################################

################################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/check_app.sh
. SCRIPTS/size.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_inst_games.sh
. SCRIPTS/std_build.sh

### End of Include functions
#################################################

clear
title "A G N o S t e p  -  Games"

#################################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir ../build
fi

### Is there a USER APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	mkdir $INSTALL_DIR
fi

#################################################
### New LOG

echo "$0" > $LOG


##################################

install_chess
install_gomoku
install_lapis
install_freecell
install_gshisen

###################################

make_services
sudo ldconfig
#print_size
