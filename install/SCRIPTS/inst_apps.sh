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
### GNUstep-apps
#####################################

### Install Applications: Preferences, GWorkspace, etc
### See RELEASE for a complete list
### N.B.: Developer apps are divided into inst_devel.sh

################################
### ENV

_PWD=`pwd`
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
GSMAKE=$(gnustep-config --variable=GNUSTEP_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
LOG="$HOME/AGNOSTEP_BUILD_APPS.log"
SPIN='/-\|'
INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
#INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"
### End of VARS
################################

################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/check_app.sh
. SCRIPTS/size.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_inst_apps.sh
. SCRIPTS/functions_inst_wrappers.sh
. SCRIPTS/std_build.sh

### End of Include functions
################################

clear
title "A G N o S t e p  -  Main applications and Tools"

################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir -p ../build
fi

################################
### Is there a USER APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	alert "$INSTALL_DIR was not found!"
	exit 1
fi

#################################################
### New LOG

echo "$0" >$LOG

##############################################
## If you do not want any app to be installed
## Just comment the relevant line, below,
## save and run...
##############################################

install_systempreferences
install_gworkspace
install_helpviewer
install_textedit
install_openup
install_addressmanager
install_gnumail
install_grr
install_agenda
install_terminal
install_gspdf
install_imageviewer
install_cynthiune
install_player
install_librarian
install_innerspace
install_scanimage
install_screenshot
install_volumecontrol
install_ink
install_wrappers

##################
### Removed
#install_affiche
#install_timemon
##################

sudo ldconfig
make_services
