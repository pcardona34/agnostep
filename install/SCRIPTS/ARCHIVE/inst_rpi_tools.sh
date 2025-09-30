 #!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

#####################################
### RPI Tools
#####################################

### Install Wrappers of the RPI Tools

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
LOG="$HOME/PISIN_BUILD_APPS.log"
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
. SCRIPTS/functions_inst_wrappers.sh

### End of Include functions
################################

clear
title "PiSiN - RPI Tools"

################################
### Is there a USER APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	alert "$INSTALL_DIR was not found!"
	exit 1
fi

#################################################
### LOG

echo "$0" >>$LOG

title "Dependencies of the RPI Tools"

DEPS="rpinters rpi-imager hplip printer-driver-hpcups printer-driver-cups-pdf"
sudo apt -y install ${DEPS}

##############################################
## If you do not want any app to be installed
## Just comment the relevant line, below,
## save and run...
##############################################

install_rpi_tools

sudo ldconfig
make_services
