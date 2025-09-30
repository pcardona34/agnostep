#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

#####################################
### DRAFT
### This is not yet available
### for daily use
#####################################

### Testing new Applications: 
### Retesting broken...

################################
### ENV

LOG="$HOME/AGNOSTEP_BUILD_DRAFT.log"
_PWD=`pwd`
SPIN='/-\|'
#. SCRIPTS/environ.sh
GSMAKE=$(gnustep-config --variable=GNUSTEP_SYSTEM_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
USER_INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_USER_APPS)
INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=USER"

### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/check_app.sh
. SCRIPTS/functions_inst_DRAFT.sh
#. SCRIPTS/std_build.sh

### End of Include functions
################################

#################################################

clear
title "A G N o S t e p  -  DRAFTS"

#################################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir ../build
fi

#################################################
### New LOG

echo "$0" > $LOG


##################################

##############################################
## If you do not want any app to be installed
## Just comment the relevant line, below,
## save and run...
##############################################

### Apps
#install_gs-webbrowser
#install_Weather

### Games
#install_nextgo

#############################################
### Frameworks


##############################################

make_services
sudo ldconfig

###############

