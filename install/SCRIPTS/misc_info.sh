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
### Try to Update Info.plist
### To apply theme
### after an app install
################################

function update_info_plist
{
APPNAME="$1"
if [ -z "$APPNAME" ];then
	exit 1
fi

LA=`pwd`
THEME=$(defaults read NSGlobalDomain GSTheme | awk '{print $3}')
APP_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
INFO="RESOURCES/INFOS/Info-gnustep.plist_${APPNAME}"

if [ "$THEME" != "AGNOSTEP" ] || [ -z "$APPNAME" ];then
	printf "No Info updating.\n"
else
	if [ -f $INFO ];then
	sudo -E cp -f ${INFO} ${APP_DIR}/Info-gnustep.plist
	cd ${APP_DIR} || exit 1
	TARG=$(find . -type d -name ${APPNAME}.app)
	#echo "TARGET: $TARG"
		if [ -n "$TARG" ];then
			sudo -E mv Info-gnustep.plist ${TARG}/Resources/
			if [ $? -eq 0 ];then
				 info "${APPNAME}: Info-gnustep.plist was successfully updated.\n"
			else
				warning "The INFO template was not found. Theme will not apply."
				sleep 2
			fi
		fi
	fi
fi
cd $LA
}

### Testing in install dir by cmd: bash ./SCRIPTS/misc_info.sh
### Un comment below:
#. SCRIPTS/colors.sh
#update_info_plist "EasyDiff"

