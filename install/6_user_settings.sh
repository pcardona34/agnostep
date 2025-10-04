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
### User home settings
### This set GNUstep Library, defaults, .xinitrc...
####################################################

_PWD=`pwd`
SPIN='\-/|'
STOP=0 # Set to 0 to avoid stops; to 1 to make stops
MSG_STOP="Stop: type <Enter> to continue."
LOG=$HOME/AGNOSTEP_USER_SETTINGS.log
GWDEF="org.gnustep.GWorkspace"
DEFDIR=RESOURCES/DEFAULTS

echo $PATH | grep -e "/System/Tools" &>/dev/null
if [ $? -ne 0 ];then
	export PATH=/System/Tools:$PATH
fi
LOCAL_INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)

####################################################
### Include functions

. SCRIPTS/colors.sh
. SCRIPTS/spinner.sh
. SCRIPTS/functions_misc_folders.sh
. SCRIPTS/functions_inst_themes.sh
. SCRIPTS/functions_misc_themes.sh

function stop
{
if [ $STOP -ne 0 ];then
	read -p "$MSG_STOP" R
fi
}

### End of functions
####################################################

clear

####################################################
### FreeDesktop User filesystem

TITLE="Customizing the User Home folder"
echo "$TITLE" >>$LOG
title "$TITLE"

### Set or restore standard $HOME filesystem
### Do NOT use xdg-user-dirs-update!!!
for FOLD in Books Desktop Documents Downloads Favorites GNUstep Images Mailboxes Music Samples Videos
do
	if ! [ -d $HOME/$FOLD ];then
		mkdir -p $HOME/$FOLD
	fi
done

################################
### Miscellaneous for Home Folders
################################

################################
### ENV

TITLE="Miscellaneous for Home Folders"
echo $"$TITLE" >>$LOG
title "$TITLE"

###############################################
for FOLD in Books Favorites GNUstep Mailboxes Samples SOURCES
do
	printf "Setting Folder ${FOLD}\n"
	icon_folder $FOLD
	ok "Done"
done

stop

###################################################
### User WindowMaker profile
TITLE="User's WindowMaker profile"
echo "$TITLE" >>$LOG
title "$TITLE"

### We set standard first
if [ -d $HOME/GNUstep/Library/WindowMaker ];then
	printf "Already set.\n"
else
	cd
	mkdir -p $HOME/GNUstep/Library/WindowMaker
fi
cd $_PWD
ok "Done"

stop

###################################################
### Autostart

TITLE="Autostart"
echo "$TITLE" >>$LOG
title "$TITLE"
DEST_AUTO=$HOME/GNUstep/Library/WindowMaker
if [ -f ${DEST_AUTO}/autostart ];then
	rm --force ${DEST_AUTO}/autostart
fi
cd RESOURCES/SCRIPTS
cp autostart ${DEST_AUTO}/
printf "Autostart for Window Maker has been updated.\n"
cd $_PWD
ok "Done"

stop

###################################################
### .xinitrc
TITLE="Xinit"
echo "$TITLE" >>$LOG
title "$TITLE"

if ! [ -f $HOME/.xinitrc ];then
	cd RESOURCES/SCRIPTS || exit 1
	cp _xinitrc $HOME/.xinitrc
else
	warning "A xinit script is already in the user directory."
	grep -e "wmaker" $HOME/.xinitrc &>/dev/null
	if [ $? -eq 0 ];then
		info "It seems correct and it will be unchanged."
	else
		info "It is not compliant, so we replace it."
		cd RESOURCES/SCRIPTS || exit 1
		cp --remove-destination _xinitrc $HOME/.xinitrc
	fi
fi
cd $_PWD
ok "Done"

stop

#################################################
### Wallpaper
TITLE="Wallpaper"
echo "$TITLE" >>$LOG
title "$TITLE"

WP=fond_agnostep.png
#WP_FOLDER=$HOME/GNUstep/Library/WindowMaker/Backgrounds
WP_FOLDER=/usr/share/wallpapers
if [ ! -d $WP_FOLDER ];then
	sudo mkdir -p $WP_FOLDER
fi
cd RESOURCES/WALLPAPERS || exit 1
sudo cp --remove-destination ${WP} ${WP_FOLDER}/${WP}
cd $_PWD
ok "Done"

stop

#################################################
### Installing Tools and confs... Updater
TITLE="Updater tool"
echo "$TITLE" >>$LOG
title "$TITLE"

cd TOOLS/agnostep_updater || exit 1
. ./install_agnostep_updater.sh
cd $_PWD
ok "Done"

stop

### Installing Tools and confs... Setup_Printer
TITLE="Setup_Printer"
echo "$TITLE" >>$LOG
title "$TITLE"

cd TOOLS || exit 1
sudo cp Setup_Printer /usr/local/bin/
cd $_PWD
ok "Done"

stop

### Installing Tools and confs... Conky
TITLE="Conky Monitoring Board"
echo "$TITLE" >>$LOG
title "$TITLE"

cd TOOLS/agnostep_conky || exit 1
. ./prepare_agnostep_conky.sh || exit 1
. ./install_agnostep_conky.sh || exit 1
cd $_PWD
### We must complete conky symbols: icon battery
ICOBAT=RESOURCES/ICONS/battery.png
if [ ! -d /usr/local/share/icons/conky ];then
	sudo mkdir -p /usr/local/share/icons/conky
fi
sudo cp ${ICOBAT} /usr/local/share/icons/conky/
cd $_PWD
ok "Done"

stop

### Installing Tools and confs... Compton
TITLE="Compton Compositing"
echo "$TITLE" >>$LOG
title "$TITLE"

cd TOOLS/agnostep_compton || exit 1
. ./install_agnostep_compton.sh
cd $_PWD
ok "Done"

stop

###########################################
### Installing the theme
TITLE="AGNOSTEP Theme"
echo "$TITLE" >>$LOG
title "$TITLE"

printf "Window Maker Theme...\n"
install_wm_theme
cd $_PWD

printf "GNUstep Theme..."
install_gs_theme
cd $_PWD

### Some Apps known to not comply with Theme: workaround
### We need to update Info-gnustep.plist for these apps
### Adding 'CFBundleIdentifier' property in the Dictionary

update_info

cd $_PWD

stop

###########################################
### Setting the Defaults...
TITLE="GNUstep Defaults Setting"
echo "$TITLE" >>$LOG
title "$TITLE"

################################
### Prep defaults...
################################

HOME_GNUSTEP_DEF=$HOME/GNUstep/Defaults
if [ ! -d $HOME_GNUSTEP_DEF ];then
	mkdir -p $HOME_GNUSTEP_DEF
fi

cd $DEFDIR || exit 1

if [ "$USER" == "patrick" ];then
	### Default user...
	cp --force ${GWDEF}.TEMPLATE ${GWDEF}.plist
else
	cat ${GWDEF}.TEMPLATE | sed -e s/patrick/$USER/g > ${GWDEF}.plist
fi
cd $_PWD
if [ ! -f $HOME_GNUSTEP_DEF/WindowMaker ];then
	cd RESOURCES/DEFAULTS && cp WindowMaker $HOME_GNUSTEP_DEF/
fi
cd $_PWD

################################
### Set the defaults
### for a AGNoStep Desktop
################################

############################################
### Applying a theme for WMaker:
printf "Applying a theme for WMaker...\n"
#### Syntax: setstyle THEME-PACK
#### (in our case: THEME-PACK is 'AGNOSTEP')

WMSTYLE=$HOME/GNUstep/Library/WindowMaker/Themes/AGNOSTEP.themed
if [ ! -d $WMSTYLE ];then
	alert "$WMSTYLE was not found!\nThis is a major issue."
	exit 1
fi

setstyle --no-cursors --no-fonts $WMSTYLE
ok "Done"

############################################
#### Applying Defaults for GNUstep
############################################

DEST=$HOME/GNUstep/Defaults
if ! [ -d $DEST ];then
	alert "$DEST was not found!"
	exit 1
fi

cd RESOURCES/DEFAULTS || exit 1

for PLIST in "Addresses" "NSGlobalDomain" "org.gap.InnerSpace" "org.gap.Terminal" "org.gnustep.GNUMail" "org.gnustep.GWorkspace" "org.poroussel.SimpleAgenda"
do
	if [ -f ${PLIST}.plist ];then
		printf "Setting Defaults for ${PLIST}\n"
		if [ -f $DEST/${PLIST}.plist ] && [ "${PLIST}" == "org.gnustep.GNUMail" ];then
			info "We preserve GNUMail settings."
			continue;
		else
			cp --force ${PLIST}.plist $DEST/
			if [ "$PLIST" == "org.gnustep.GWorkspace" ];then
				rm -f ${PLIST}.plist
			fi
		fi
		ok "Done"
	else
		warning "The File ${PLIST}.plist was not found."
	fi
done

cd $_PWD

stop

###########################################
### Installing Tools
TITLE="User Tools"
echo "$TITLE" >>$LOG
title "$TITLE"

cd RESOURCES/SCRIPTS || exit 1
#for TOOL in Setup_Printer.sh agnostep
for TOOL in agnostep
do
	#cp -u $TOOL $HOME/.local/bin/
	sudo cp -u $TOOL /usr/local/bin/
done
cd $_PWD
stop

cd SCRIPTS || exit 1
#for TOOL in colors.sh spinner.sh
for TOOL in colors.sh
do
	sudo cp -u $TOOL /usr/local/bin/
done
cd $_PWD
ok "Done"

stop

###########################################
### Samples
TITLE="Sample Files"
echo "$TITLE" >>$LOG
title "$TITLE"

cd RESOURCES || exit 1
cp -u Samples.tar.gz $HOME/
cd $HOME
gunzip --force Samples.tar.gz
tar -xf Samples.tar && rm Samples.tar

cd Samples
for FIC in *.mp3 *.ogg; do cp --force "$FIC" $HOME/Music/ ;done
for FIC in *.mp4 *.mkv; do cp --force "$FIC" $HOME/Videos/ ;done
for FIC in *.png *.jpg *.tiff; do cp --force "$FIC" $HOME/Images/ ;done
for FIC in *.epub *.pdf; do cp --force "$FIC" $HOME/Books/ ;done

cd $_PWD
ok "Done"

stop

###########################################
### Help
TITLE="Help Files"
echo "$TITLE" >>$LOG
title "$TITLE"

cd RESOURCES/HELP
for HLP in *.help
do
	cp -ruf ${HLP} $HOME/Books/
done

cd $_PWD
ok "Done"

stop

###########################################
### Info release
TITLE="Info release"
echo "$TITLE" >>$LOG
title "$TITLE"

RELEASE=$(grep -e "Release" RELEASE | awk '{print $3}')
STATUS=$(grep -e "Status" RELEASE | awk '{print $3}')

if [ ! -d $HOME/.local/etc ];then
	mkdir -p $HOME/.local/etc
fi
echo "DESKTOP=AGNoStep" > $HOME/.local/etc/release.info
echo "REL=$RELEASE" >> $HOME/.local/etc/release.info
echo "STATUS=$STATUS" >> $HOME/.local/etc/release.info

stop

###########################################
### Installation LOGS
TITLE="Installation Logs"
echo "$TITLE" >>$LOG
title "$TITLE"

cd
for LOG in *.log
do
	if [ "$LOG" == "ENJOY.log" ];then
		continue;
	else
		mv $LOG Documents/
	fi
done

stop

###########################################

MESSAGE="A G N o S t e p   Desktop is ready to use now."

info "$MESSAGE"

info "Login/Display Manager: after testing the Desktop, log out and execute:"
cli "./7_install_DM.sh"

sleep 5
