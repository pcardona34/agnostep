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
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
GSMAKE=$(gnustep-config --variable=GNUSTEP_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
SPIN='/-\|'
INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
CHECK="YES"
TEMPFILE=$(mktemp /tmp/agno-XXXXX)
trap "rm -f $TEMPFILE" EXIT
SLEEP=2

#INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"
#################################################

################################################
### Include functions

. SCRIPTS/log.sh
. SCRIPTS/colors.sh
. SCRIPTS/check_app.sh
. SCRIPTS/size.sh
. SCRIPTS/spinner.sh
. SCRIPTS/std_build.sh
. SCRIPTS/misc_info.sh
. SCRIPTS/patch_with_quilt.sh
. SCRIPTS/functions_remove_app.sh
. SCRIPTS/fetcher.sh
. SCRIPTS/functions_inst_extra.sh

### End of Include functions
#################################################

clear
STR="A G N o S t e p  -  Extra applications"
echo "$STR" >> $LOG
date >> $LOG

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

function extra_apps_menu
{
dialog --no-shadow --backtitle "AGNoStep Desktop" \
 --title "Extra Applications" \
 --ok-label "OK"  \
 --checklist "
The list below contains the extra apps.

Check with space bar the Applications you want to install." 20 70 13 \
"Cenon" "Vetorial Drawing" off \
"Cynthiune" "Romantic Music Player" off \
"FlexiSheet" "Quantrix like Spreadsheet" off \
"Graphos" "Vector Drawing" off \
"Grr" "Günters Reliable RSS Reader" off \
"LaternaMagica" "Image Collection Viewer" off \
"LuserNET" "News Reader for GNUstep" off \
"NetSurf" "NetSurf Web Browser ported to GNUstep" off \
"PikoPixel" "Pixel Art Editor" off \
"Player" "A Video Player from GSDE" off \
"PowerPaint" "Bitmap Drawing from GNUstep Examples" off \
"PPC" "PowerPC Emulator" off \
"Preview" "Image Viewer" off \
"PRICE" "Image Manipulation" off \
"TalkSoup" "IRC Client" off 2> $TEMPFILE

clear

# 0 if [OK] button was pushed;
# otherwise, exit the script.
if [ $? = 0 ];then
for i in `cat $TEMPFILE`
do
case "$i" in
"Cenon")
	printf "You chose Cenon\n"
	remove_ifx_app "Cenon"
	install_cenon
	update_info_plist Cenon;;
"Cynthiune")
	printf "You chose Cynthiune\n"
	remove_ifx_app "Cynthiune"
	install_cynthiune
	update_info_plist Cynthiune;;
"FlexiSheet")
	printf "You chose FlexiSheet\n"
	remove_ifx_app "FlexiSheet"
	install_flexisheet
	update_info_plist FlexiSheet;;
"Graphos")
	printf "You chose Graphos\n"
	remove_ifx_app "Graphos"
	install_graphos
	update_info_plist Graphos;;
"Grr")
	printf "You chose Grr\n"
	remove_ifx_app "Grr"
	install_grr
	update_info_plist Grr;;
"LaternaMagica")
	printf "You chose LaternaMagica\n"
	remove_ifx_app "LaternaMagica"
	install_laternamagica
	update_info_plist LaternaMagica;;
"LuserNET")
	printf "You chose LuserNET\n"
	remove_ifx_app "LuserNET"
	install_lusernet
	update_info_plist LuserNET;;
"NetSurf")
	printf "You chose NetSurf\n"
	remove_ifx_app "NetSurf"
	install_netsurf
	update_info_plist NetSurf;;
"PikoPixel")
	printf "You chose PikoPixel\n"
	remove_ifx_app "PikoPixel"
	install_pikopixel
	update_info_plist PikoPixel;;
"Player")
	printf "You chose Player\n"
	remove_ifx_app "Player"
	install_player
	update_info_plist Player;;
"PowerPaint")
	printf "You chose PowerPaint\n"
	remove_ifx_app "PowerPaint"
	install_powerpaint
	update_info_plist PowerPaint;;
"PPC")
	printf "You chose PPC\n"
	remove_ifx_app "PPC"
	install_ppc
	update_info_plist PPC;;
"Preview")
	printf "You chose Preview\n"
	remove_ifx_app "Preview"
	install_preview
	update_info_plist Preview;;
"PRICE")
	printf "You chose PRICE\n"
	remove_ifx_app "PRICE"
	install_price
	update_info_plist PRICE;;
"TalkSoup")
	printf "You chose TalkSoup\n"
	remove_ifx_app "TalkSoup"
	install_talksoup
	update_info_plist TalkSoup;;
esac
done
else exit 0
fi
}
#################################################

extra_apps_menu

################################################
### Removed

#install_vespucci
#install_notebook

################################################

printf "Linking: wait please...\n"
sudo ldconfig &>/dev/null &
PID=$!
spinner
ok "\rDone"

printf "\nUpdating Services: wait please...\n"
make_services &>/dev/null &
PID=$!
spinner
ok "\rDone"

print_size

sleep 2
