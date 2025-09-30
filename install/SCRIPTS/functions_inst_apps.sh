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
### Functions for inst_apps
####################################################

#######################################
## SystemPreferences
### Repo/release: github/gnustep: 1.2.0
########################################

function install_systempreferences()
{
APPNAME="SystemPreferences"
RELEASE="1.2.0"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-systempreferences ];then
	cd apps-systempreferences
	git pull &>/dev/null
else
	git clone --branch=master https://github.com/gnustep/apps-systempreferences &>/dev/null
	cd apps-systempreferences
fi

_build
}

########################################
## GWorkspace
### Repo/Release: github/gnustep: 1.1.0
########################################

function install_gworkspace()
{

APPNAME=GWorkspace
RELEASE="1.1.0"
CONFIG_ARGS="--with-inotify --enable-gwmetadata"
BUILD_ARGS=""
INSTALL_ARGS=""


echo "$APPNAME $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-gworkspace ];then
	cd apps-gworkspace
	git pull &> /dev/null
else
	git clone --branch=master "https://github.com/gnustep/apps-gworkspace" &> /dev/null
	cd apps-gworkspace
fi

#####################################
### GWmetadata submodule

#info "Submodules of GWorkspace: GWMetadata and MDFinder"

#cd GWMetadata || exit 1

#printf "Configuring...\n"
#./configure &>>$LOG &
#PID=$!
#spinner

#printf "\rBuilding...\n"
#make &>>$LOG &
#PID=$!
#spinner

#printf "\rInstalling...\n"
#sudo -E make install &>>$LOG &
#PID=$!
#spinner

#printf "\rSubmodule: "
#ok "Done"

#cd ..
## End of submodule
####################################

#info "Back to the main app"

_build

#check "Recycler"
#check "MDFinder"
}

#############################################
## Terminal
### Repo/Release: Savannah/svn
#############################################

function install_terminal()
{

APPNAME=Terminal
RELEASE="0.9.8"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"


if [ -d Termina ];then
	cd Terminal
	svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/system-apps/Terminal &>/dev/null
	cd Terminal
fi

_build
}


#######################################
## Addresses
### Repo/Release: savannah/gap: 0.5.0
#######################################

function install_addressmanager()
{

APPNAME=AddressManager
RELEASE="0.5.0"
# A better Icon from gs-desktop project
#ICON_APP=$_PWD/RESOURCES/ICONES_PISI/AddressManager.tiff

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

cd ../build || exit 1

printf "Fetching...\n"
if [ -d Addresses-0.5.0 ];then
	cd Addresses-0.5.0
	cd AddressManager
else
	wget --quiet http://savannah.nongnu.org/download/gap/Addresses-0.5.0.tar.gz
	gunzip --force Addresses-0.5.0.tar.gz
	tar -xf Addresses-0.5.0.tar
	cd Addresses-0.5.0
	cd AddressManager
fi

#if [ -f $ICON_APP ];then
#	cp $ICON_APP ./
#fi

_build
}

##########################################
## GSPdf
### Repo/Release: Savannah/gap: subversion
##########################################

function install_gspdf()
{
APPNAME=GSPdf
RELEASE="0.5"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d GSPdf ];then
        cd GSPdf
        svn update &>/dev/null
else
        svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/GSPdf &>/dev/null
        cd GSPdf
fi

_build
}

###############################################
## Cynthiune
### Repo/Release: Savannah/gnustep/gap: 1.0.0
### With a patch from Savannah
###############################################

function install_cynthiune()
{
APPNAME=Cynthiune
RELEASE="1.0.0"
CONFIG_ARGS="disable-audiofile=yes disable-flac=yes disable-flactags=yes \
        disable-mod=yes disable-windowsmedia=yes disable-musepack=yes \
        disable-timidity=yes disable-asdtags=yes disable-waveout=yes \
        disable-esound=yes disable-ao=yes"
BUILD_ARGS="${CONFIG_ARGS}"
INSTALL_ARGS="${BUILD_ARGS}"
PATCH="Cynthiune-1.0.0_Bundles_ALSA_fails_to_build_due_to_memcheck_inclusion.patch"

title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d Cynthiune ];then
        cd Cynthiune
        svn update &>/dev/null
else
        svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/Cynthiune &>/dev/null
        cd Cynthiune
fi

### PATCH
cp $_PWD/RESOURCES/PATCHES/$PATCH ./
printf "A patch must be applied... "
TARGET=`grep -i -e "index" ./${PATCH} | awk '{print $2}'`
TARGET=./${TARGET}
patch --forward -u ${TARGET} -i ./${PATCH}
ok "Done"

_build
}

###################################################
## TextEdit
### Repo/Release: github/onflapp/gs-textedit: 4.0
###################################################

function install_textedit()
{
APPNAME=TextEdit
RELEASE="4.0"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-textedit ];then
	cd gs-textedit
	git pull &>/dev/null
else
	git clone https://github.com/onflapp/gs-textedit.git &>/dev/null
	cd gs-textedit
fi

_build
}

##################################################
## ImageViewer
### Repo/Release: github/onflapp/gs-desktop: 0.1
##################################################

function install_imageviewer()
{
APPNAME=ImageViewer
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
        cd gs-desktop
        git pull &>/dev/null
else
        git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
        cd gs-desktop
fi

cd Applications/ImageViewer

_build
}

##########################################
## SimpleAgenda
### Repo/Release: github/poroussel: 0.4.7
##########################################

function install_agenda()
{
APPNAME=SimpleAgenda
RELEASE="0.4.7"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d simpleagenda ];then
	cd simpleagenda
	git pull &>/dev/null
else
	git clone https://github.com/poroussel/simpleagenda.git &>/dev/null
	cd simpleagenda
fi

_build
}

#################################################
## GNUMail (current / stable)
### Repo/Release: Savannah/gnustep-nonfsf: 1.4.0
#################################################

function install_gnumail()
{
APPNAME=GNUMail
RELEASE="1.4.0"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d GNUMail-1.4.0 ];then
	cd GNUMail-1.4.0
else
	wget --quiet http://download.savannah.nongnu.org/releases/gnustep-nonfsf/GNUMail-1.4.0.tar.gz
	gunzip --force GNUMail-1.4.0.tar.gz
	tar -xf GNUMail-1.4.0.tar
	cd GNUMail-1.4.0
fi

_build
}

#####################################################
## OpenUp
### Repo/Release: github/onflapp/gs-desktop: 0.1
#####################################################

function install_openup()
{
APPNAME=OpenUp
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
        cd gs-desktop
        git pull &>/dev/null
else
        git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
        cd gs-desktop
fi

cd Applications/OpenUp

_build
}

#################################################
## ScanImage
### Repo/Release: github/onflapp/gs-desktop: 0.1
#################################################

function install_scanimage()
{
APPNAME=ScanImage
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
        cd gs-desktop
        git pull &>/dev/null
else
        git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
        cd gs-desktop
fi

cd Applications/ScanImage

_build
}

##################################################
## Screenshot
### Repo/Release: github/onflapp/gs-desktop: 0.1
##################################################

function install_screenshot()
{
APPNAME=ScreenShot
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
        cd gs-desktop
        git pull &>/dev/null
else
        git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
        cd gs-desktop
fi

cd Applications/ScreenShot

_build
}

###################################################
## Player
### Repo/Release: github/onflapp/gs-desktop: 0.1
###################################################

function install_player()
{
APPNAME=Player
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
        cd gs-desktop
        git pull &>/dev/null
else
        git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
        cd gs-desktop
fi

cd Applications/Player

_build
}

###################################################
## InnerSpace
### Repo/Release: github/onflapp/gs-desktop: 0.1
###################################################

function install_innerspace()
{
APPNAME=InnerSpace
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

PATCH="spordefs.patch"
TARGET="spordefs.m"
PROJ="SporView.bproj"
PATCH2="InnerSpace_GNUMakefile.patch"
TARGET2="GNUMakefile"
title "$APPNAME $RELEASE" | tee -a $LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d InnerSpace ];then
        cd InnerSpace
        svn update &>/dev/null
else
        svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/InnerSpace &>/dev/null
        cd InnerSpace
fi

if ! [ -d $HOME/GNUstep/Library/InnerSpace ];then
	mkdir -p $HOME/GNUstep/Library/InnerSpace
fi
printf "Building and installing the subprojects...\n"
for SUB in *.bproj
do
	cd $SUB
	printf "\t${SUB}...\n"
	if [ "$SUB" == "$PROJ" ];then
		### PATCH
		cp $_PWD/RESOURCES/PATCHES/$PATCH ./
		printf "\tA patch must be applied...\n"
		patch --forward -u ${TARGET} -i ${PATCH} &>>$LOG
		ok "\tPatch applied"
	fi
	make &>>$LOG
	cd ..
	cp --recursive $SUB $HOME/GNUstep/Library/InnerSpace/
	ok "\r\tDone"
done

printf "Building Main InnerSpace...\n"
### PATCH
cp $_PWD/RESOURCES/PATCHES/$PATCH2 ./
printf "\tA patch must be applied...\n"
patch --forward -u ${TARGET2} -i ${PATCH2} &>>$LOG
ok "\tPatch applied"

_build
}
### End of InnerSpace
##############################################

#################################################
## HelpViewer
### Repo/Release: github/onflapp/gs-desktop: 0.4
#################################################

function install_helpviewer()
{

APPNAME="HelpViewer"
REPO="gs-desktop"
OWNER="onflapp"
HUB="https://github.com"
BUILD_DIR="Applications" # "system-apps" | "ported-apps"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

cd ../build || exit 1

echo "$APPNAME $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d $REPO ];then
        cd $REPO
        git pull &>/dev/null
else
	git clone ${HUB}/${OWNER}/${REPO}.git &>/dev/null
	cd $REPO
fi

cd $BUILD_DIR/$APPNAME

_build
}
### End of HelpViewer
##############################################

##########################
## Ink
##########################

function install_ink()
{

cd ../build || exit 1

APPNAME="Ink"
REPO="tests-examples"
OWNER="gnustep"
HUB="https://github.com"
BUILD_DIR="gui"
CONFIG_ARGS=""
INSTALL_ARGS=""
BUILD_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d $REPO ];then
        cd $REPO
        git pull &>/dev/null
else
	git clone ${HUB}/${OWNER}/${REPO}.git &>/dev/null
	cd $REPO
fi

cd $BUILD_DIR/$APPNAME

_build
}

#################################################
## Librarian
### Repo/Release: github/onflapp/gs-desktop: 0.1
#################################################

function install_librarian()
{

cd ../build || exit 1

APPNAME="Librarian"
RELEASE="0.1"
REPO="gs-desktop"
OWNER="onflapp"
HUB="https://github.com"
BRANCH="main"
BUILD_DIR="Applications"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d $REPO ];then
        cd $REPO
        git pull origin $BRANCH &>/dev/null
else
	git clone ${HUB}/${OWNER}/${REPO}.git &>/dev/null
	cd $REPO
fi

cd $BUILD_DIR/$APPNAME

_build
}

###################################################
## Grr
### Repo/Release: Savannah/gap: 1.1 Subversion
###################################################

function install_grr()
{

APPNAME=Grr
RELEASE="1.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d $APPNAME ];then
	cd $APPNAME
	svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/Grr &>/dev/null
	cd $APPNAME
fi

_build
}

###################################################
## VolumeConrol
### Repo/Release: Github/Alexmyczko
###################################################

function install_volumecontrol()
{

APPNAME=VolumeControl
RELEASE=""
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d ${APPNAME}.app ];then
	cd ${APPNAME}.app
	git pull &>/dev/null
else
	git clone https://github.com/alexmyczko/VolumeControl.app.git &>/dev/null
	cd ${APPNAME}.app
fi

_build
}


##############################################
### End of functions
##############################################














#################################################################################
#################################################################################
### Archive
### Removed

###################################################
## Affiche
### Repo/Release: github/onflapp/gs-desktop: 0.6.0
###################################################

function install_affiche()
{

APPNAME=Affiche
RELEASE="0.6.0"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gs-desktop ];then
	cd gs-desktop
	git pull origin master &>/dev/null
else
	git clone https://github.com/onflapp/gs-desktop.git &>/dev/null
	cd gs-desktop
fi

cd Applications/Affiche

_build
}

###

##########################################
## TimeMon
### Repo/Release: github/gnustep/gap: 4.1
##########################################

function install_timemon()
{
APPNAME=TimeMon
RELEASE="4.1"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
cd ../build || exit 1

if [ -d gap ];then
        cd gap
        git pull origin master &>/dev/null
else
        git clone https://github.com/gnustep/gap.git &>/dev/null
        cd gap
fi

cd ported-apps/Util/TimeMon

_build
}

##############################################
### /etc/skel: copy ressources (obsolete)

function cp_to_skel()
{

title "User Home Template"

printf "Copy of the User Home Template in /etc/skel/PISI..."

cd RESOURCES/SKEL
if ! [ -d /etc/skel/PISI ];then
	sudo mkdir -p /etc/skel/PISI
fi
sudo cp -r GNUstep /etc/skel/PISI/
sudo chmod --recursive 0755 /etc/skel

cd $_PWD
ok "Done"
}
### End of copy of ressources to /etc/skel
##############################################

#############################################
## TopBar
### Repo/Release: github/gnustep/topbar
#############################################

function install_topbar()
{

APPNAME=TopBar
RELEASE="0.1"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-topbar ];then
	cd apps-topbar
	git pull origin master &>/dev/null
else
	git clone https://github.com/gnustep/apps-topbar.git &>/dev/null
	cd apps-topbar
fi

_build
}

### End of TopBar
#############################################
