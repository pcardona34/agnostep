#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

. SCRIPTS/colors.sh

#########################################
### Check if the app is ok
### $1: the name of the installed App.
#########################################
function check()
{
### VARS ENV
__PWD=`pwd`
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
if [ -z "$INSTALL_DIR" ];then
	INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
fi
GNUSTEP_APPS_DIR=$INSTALL_DIR
ISSUES=https://github.com/pcardona34/pi-step-initiative/issues

if ! [ -d $GNUSTEP_APPS_DIR ];then
	alert "$GNUSTEP_APPS_DIR was not found!"
	exit 1
fi

if [ -n "$1" ];then
	APP="$1"
else
	alert "The APP name is empty."
	printf "Use:"
	cli "$0 <APP_NAME>"
	exit 1
fi

cd $GNUSTEP_APPS_DIR || exit 1
if [ -d "${APP}" ] || [ -d "${APP}.app" ];then
	info "The application ${APP} has been found: ok."
else
	alert "ERROR! The application ${APP} was not found in ${GNUSTEP_APPS_DIR}.\nPlease, report this issue at:\n${ISSUES}"
	exit 1
fi

cd $__PWD
}

#########################################
### Check if the FW is ok
### $1: the name of the installed FW.
#########################################

function check_FW()
{
### VARS ENV
__PWD=`pwd`
if [ -z "$INSTALL_DIR" ];then
	INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_LIBRARY)
	INSTALL_DIR=${INSTALL_DIR}/Frameworks
fi
ISSUES=https://github.com/pcardona34/pi-step-initiative/issues

if ! [ -d ${INSTALL_DIR} ];then
	printf "\nError: ${INSTALL_DIR} was not found.\n";exit 1
fi

if [ -n "$1" ];then
	APP="$1"
else
	alert "The Framework name is empty."
	printf "Use:"
	cli "$0 <APP_NAME>"
	exit 1
fi

cd ${INSTALL_DIR} || exit 1
if [ -d "${APP}.framework" ];then
	info "The Framework ${APP} has been found: ok."
else
	alert "ERROR! The Framework ${APP} was not found in ${GNUSTEP_FW_DIR}.\nPlease, report this issue at:\n${ISSUES}"
	exit 1
fi

cd $__PWD
}

#####################################
### Case of Renaissance, Performance
function check_LIB()
{
### VARS ENV
LIB="$1"
__PWD=`pwd`
ISSUES=https://github.com/pcardona34/pi-step-initiative/issues


if [ -z "$LIB_DIR" ];then
	LIB_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_LIBRARY)
	LIB_DIR=${LIB_DIR}/Libraries
fi

cd ${LIB_DIR} || exit 1
if [ -f "lib${LIB}.so" ];then
	info "The lib ${LIB} has been found: ok."
else
	alert "ERROR! The lib ${LIB} was not found in ${LIB_DIR}.\nPlease, report this issue at:\n${ISSUES}"
	exit 1
fi

cd $__PWD
}


#########################################
### Check if the THEME is ok
### $1: the name of the installed THEME.
#########################################

function check_THEME()
{
### VARS ENV
__PWD=`pwd`
if [ -z "$INSTALL_DIR" ];then
	INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_USER_LIBRARY)
fi
GNUSTEP_THEMES_DIR=$INSTALL_DIR/Themes
ISSUES=https://github.com/pcardona34/pi-step-initiative/issues

if ! [ -d $GNUSTEP_THEMES_DIR ];then
	sudo mkdir -p $GNUSTEP_THEMES_DIR
fi

if [ -n "$1" ];then
	APP="$1"
else
	alert "The THEME name is empty."
	printf "Use:"
	cli "$0 <THEME_NAME>"
	exit 1
fi

cd $GNUSTEP_FW_DIR || exit 1
if [ -d "${APP}" ] || [ -d "${APP}.theme" ];then
	info "The Theme ${APP} has been found: ok."
else
	alert "ERROR! The Theme ${APP} was not found in ${GNUSTEP_THEMES_DIR}.\nPlease, report this issue at:\n${ISSUES}"
	exit 1
fi

cd $__PWD
}


############################################"

### Test
### check "Terminal"
