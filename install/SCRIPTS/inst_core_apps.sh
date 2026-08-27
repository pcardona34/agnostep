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
### GNUstep-apps: Core apps for AGNoStep Desktop
####################################################

### Install Applications: Preferences, GWorkspace, etc
### See RELEASE for a complete list
### N.B.: Developer apps are divided into inst_devel.sh

################################
### ENV

_PWD=`pwd`
CHECK=YES
echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
GSMAKE=$(gnustep-config --variable=GNUSTEP_MAKEFILES)
. ${GSMAKE}/GNUstep.sh
SPIN='/-\|'
INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
TEMPFILE=$(mktemp /tmp/agno-XXXXX)
trap "rm -f $TEMPFILE" EXIT

#INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"
### End of VARS
################################

################################
### Include functions

. SCRIPTS/log.sh
. SCRIPTS/colors.sh
. SCRIPTS/check_app.sh
. SCRIPTS/size.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_prep.sh
. SCRIPTS/std_build.sh
. SCRIPTS/patch_with_quilt.sh
. SCRIPTS/misc_info.sh
. SCRIPTS/functions_remove_app.sh
. SCRIPTS/fetcher.sh
. SCRIPTS/functions_inst_core_apps.sh

function install_forked
 {
 FORKED="$1"
 FORKS=RESOURCES/FORKS

 if [ -n "$1" ];then
      cd ${FORKS}/${FORKED} || exit 1
      ./install.sh
      cd $_PWD
 fi
 }

### End of Include functions
################################

clear
STR="A G N o S t e p  -  Main applications and Tools"
titulo

################################
### Is there a Build Folder?

if ! [ -d ../build ];then
	mkdir -p ../build
fi

################################
### Is there a LOCAL APPS Folder?

if ! [ -d $INSTALL_DIR ];then
	alert "$INSTALL_DIR was not found!"
	exit 1
fi

###########################################
function core_apps_menu
{
dialog --no-shadow --backtitle "${STR:0:15}" --title "${STR:20:27}" \
--ok-label "OK"  \
--checklist "
The list below contains the core apps.

Check (space bar) the Applications you want to reinstall." 22 70 14 \
"AClock" "Analogic Clock for the Classic Flavour" off \
"AddressManager" "Manage the Persons: email, birthdate..." off \
"BatMon" "Monitoring the Battery on Laptops" off \
"GNUMail" "The GNUstep Mail User Agent" off \
"GWorkspace" "The NeXT like Workspace Manager" off \
"HelpViewer" "Help Viewer" off \
"Ink" "Plain text and Rich Text Format Editor" off \
"InnerSpace" "The GNUstep Screensaver" off \
"Mixer" "Install complete VolumeControl" off \
"SimpleAgenda" "A Simple Agenda to manage Events and Tasks" off \
"SystemPreferences" "Preferences of the GNUstep System" off \
"Terminal" "The GNUstep Terminal Emulator" off \
"TimeMon" "The CPU Load Monitor ported from OPENSTEP" off 2> $TEMPFILE

# 0 if [OK] button was pushed;
# otherwise, exit the script.

clear

if [ $? = 0 ];then
for i in `cat $TEMPFILE`
do
case "$i" in
"AClock")
	printf "You chose AClock\n"
	remove_ifx_app "AClock"
	install_aclock
	update_info_plist "AClock";;
"AddressManager")
	printf "You chose AddressManager\n"
	remove_ifx_app "AddressManager"
	install_addressmanager
	update_info_plist "AddressManager";;
"BatMon")
	printf "You chose BatMon\n"
	remove_ifx_app "batmon"
	install_batmon
	update_info_plist "batmon";;
"GNUMail")
	printf "You chose GNUMail\n"
	remove_ifx_app "GNUMail"
	install_gnumail_svn
	update_info_plist "GNUMail";;
"GWorkspace")
	printf "You chose GWorkspace\n"
	if [ $DISPLAY ];then
		alert "You must logout and update GWorkspace within a TTY console.";exit
	fi
	remove_ifx_app "GWorkspace"
	remove_ifx_app "MDFinder"
	install_gworkspace
	update_info_plist "GWorkspace";;
"HelpViewer")
    printf "You chose HelpViewer\n"
    remove_ifx_app "HelpViewer"
    #install_helpviewer
    install_forked "HelpViewer"
    update_info_plist "HelpViewer";;
"Ink")
	printf "You chose Ink\n"
	remove_ifx_app "Ink"
	#install_ink
    install_forked "Ink"
	update_info_plist "Ink";;
"InnerSpace")
	printf "You chose InnerSpace\n"
	remove_ifx_app "InnerSpace"
	install_innerspace
	update_info_plist "InnerSpace";;
"Mixer")
	printf "You chose VolumeControl\n"
	remove_ifx_app "VolumeControl"
	remove_ifx_app "Mixer"
	install_volumecontrol
	update_info_plist "VolumeControl";;
"SimpleAgenda")
	printf "You chose SimpleAgenda\n"
	remove_ifx_app "SimpleAgenda"
	install_simpleagenda
	update_info_plist "SimpleAgenda";;
"SystemPreferences")
	printf "You chose SystemPreferences\n"
	remove_ifx_app "SystemPreferences"
	install_systempreferences
	update_info_plist "SystemPreferences";;
"Terminal")
	printf "The GNUstep Terminal Emulator\n"
	remove_ifx_app "Terminal"
	install_terminal
	update_info_plist "Terminal";;
"TimeMon")
	printf "You chose TimeMon\n"
	remove_ifx_app "TimeMon"
	install_timemon
	update_info_plist "TimeMon";;
esac
done
else exit 0
fi
}
#########################################

core_apps_menu

#########################################

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



