#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Install Extra Apps...
################################

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
LOG="$HOME/AGNOSTEP_BUILD_EXTRA.log"
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
. SCRIPTS/functions_inst_extra.sh
. SCRIPTS/std_build.sh

### End of Include functions
#################################################

clear
title "A G N o S t e p  -  Extra applications"

#################################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir ../build
fi

#################################################
### Is there a USER APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	alert "$INSTALL_DIR was not found!" && exit 1
fi

#################################################
### New LOG

echo "$0" > $LOG

#################################################
### If you do not want any app to install
### comment the relevent install script below
#################################################

install_calculator
install_powerpaint
install_stepsync
install_graphos
install_dictionaryreader
install_flexisheet
install_pikopixel
install_price
install_fontmanager

################################################
### Removed

#install_vespucci
#install_notebook
#install_netsurf
# install_cenon ## Needs objc2 runtime?

################################################

make_services
sudo ldconfig
#print_size

