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
### Install Developer Applications
#####################################

################################
### ENV

_PWD=`pwd`
#. SCRIPTS/environ.sh
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
GSMAKE=$(gnustep-config --variable=GNUSTEP_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
LOG="$HOME/AGNOSTEP_BUILD_DEVEL.log"
SPIN='/-\|'
INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"

### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/check_app.sh
. SCRIPTS/size.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_inst_devel.sh
. SCRIPTS/std_build.sh

### End of Include functions
################################

clear
title "A G N o S t e p  -  Devel applications and Tools"

################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir -p ../build
fi

################################
### Is there an APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	mkdir -p $INSTALL_DIR
fi

#################################################
### New LOG

echo "$0" >$LOG

##############################################
## If you do not want any app to be installed
## Just comment the relevant line, below,
## save and run...
##############################################

install_gorm
install_PC
install_easydiff
install_gemas
install_thematic

sudo ldconfig
make_services

#print_size

###############
