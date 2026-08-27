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

#############################################
### AClock: analogic clock for the C5C flavour
### of the desktop
#############################################

function install_aclock
{
clear
cd ../build || exit 1

APPNAME="AClock"
REPO="user-apps"
CONFIG_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME"
subtitulo

printf "Fetching...\n"
if [ -d $APPNAME ];then
	cd $APPNAME
	svn update
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/$REPO/$APPNAME
	cd $APPNAME || exit 1
fi

clear
subtitulo
ok "$APPNAME: Fetched"

_build
sleep $SLEEP
}

#######################################
## Addresses
### Repo/Release: savannah/gap svn
#######################################

function install_addressmanager()
{
clear
APPNAME=AddressManager

STR="$APPNAME"
subtitulo
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

cd ../build || exit 1

printf "Fetching...\n"
if [ -d Addresses ];then
	cd Addresses
	svn update
	cd AddressManager || exit 1
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/system-apps/Addresses
	cd Addresses
	cd AddressManager || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build
sleep $SLEEP
}


##############################################
function install_batmon
{
clear
PATCH=batmon_AGNOSTEP.patch
THEME=`defaults read NSGlobalDomain GSTheme | awk '{print $3}'`
APPNAME="batmon"
STR="Batmon";subtitulo

cd ../build || exit 1

### We must start from a clean repo
if [ -d batmon ];then
	rm -fR batmon
fi

printf "Fetching...\n"
svn co svn://svn.savannah.nongnu.org/gap/trunk/system-apps/batmon
cd batmon || exit 1

if [ "$THEME" == "AGNOSTEP" ];then
	### PATCH begins...
	cp $_PWD/RESOURCES/PATCHES/$PATCH ./
	printf "A patch must be applied... "
	TARGET=./AppController.m
	patch --forward -u ${TARGET} -i ./${PATCH}
	ok "Done"
	### End of Patch
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}

#################################################
## GNUMail (current / svn)
### Repo/Release: svn Savannah/gnustep-nonfsf
#################################################

function install_gnumail_svn()
{
clear
APPNAME=GNUMail
RELEASE="Last svn version"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME - $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d gnumail ];then
	cd gnumail
        svn update
else
    svn co svn://svn.savannah.nongnu.org/gnustep-nonfsf/apps/gnumail
	cd gnumail || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build
sleep $SLEEP
}

########################################
## GWorkspace
### Repo/Release: github/gnustep: 1.1.0
########################################

function install_gworkspace()
{
clear
APPNAME=GWorkspace
RELEASE="1.1.0"
CONFIG_ARGS="--with-inotify --enable-gwmetadata"
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-gworkspace ];then
	cd apps-gworkspace
	git pull
else
	git clone --branch=master "https://github.com/gnustep/apps-gworkspace"
	cd apps-gworkspace
fi
clear
subtitulo
ok "$APPNAME: Fetched"

### Patch: fix 'Downloads' L18N in FSNode
printf "Applying a L18N patch...\n"
PATCH=$_PWD/RESOURCES/PATCHES/GWorkspace_FSNode_L18n.patch
TARGET=FSNode/Resources/French.lproj/Localizable.strings
patch --forward -u $TARGET -i $PATCH
ok "Done"

### Patch: add GSHelpContentsFile to Info.plist
printf "Applying a patch for Help implementation...\n"
PATCH=$_PWD/RESOURCES/PATCHES/GWorkspace_InfoPlist_Help.patch
TARGET=GWorkspace/GWorkspaceInfo.plist
patch --forward -u $TARGET -i $PATCH
ok "Done"

printf "Help bundles...\n"
cp -r $HOME/SOURCES/agnostep-desktop/install/RESOURCES/HELP/en/GWorkspace.help GWorkspace/Resources/English.lproj/
cp -r $HOME/SOURCES/agnostep-desktop/install/RESOURCES/HELP/fr/GWorkspace.help GWorkspace/Resources/French.lproj/

_build

#check "Recycler"
#check "MDFinder"

sleep $SLEEP
}


#################################################
## HelpViewer
#################################################

function install_helpviewer()
{
clear
APPNAME="HelpViewer"
HUB="svn://svn.savannah.nongnu.org/gap/trunk/system-apps"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

cd ../build || exit 1

STR="$APPNAME"
subtitulo

printf "Fetching...\n"
if [ -d $APPNAME ];then
        cd $APPNAME
        svn update
else
	svn co ${HUB}/${APPNAME}
	cd $APPNAME || exit 1
fi
clear
subtitulo
ok "$APPNAME fetched"
sleep 3

CHECK="YES"
_build
}
### End of HelpViewer
##############################################

##########################
## Ink
##########################

function install_ink()
{
clear
cd ../build || exit 1

APPNAME="Ink"
REPO="tests-examples"
#OWNER="gnustep"
OWNER="pcardona34"
HUB="https://github.com"
BUILD_DIR="gui"
CONFIG_ARGS=""
INSTALL_ARGS=""
BUILD_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

printf "Fetching...\n"
if [ -d $REPO ];then
        cd $REPO
        git pull &>/dev/null
else
	git clone ${HUB}/${OWNER}/${REPO}.git &>/dev/null
	cd $REPO
fi
clear
subtitulo
ok "$APPNAME: Fetched"

cd $BUILD_DIR/$APPNAME

_build

sleep $SLEEP
}

###################################################
## InnerSpace
### Repo/Release: github/onflapp/gs-desktop: 0.1
###################################################

function install_innerspace()
{
clear
APPNAME=InnerSpace
RELEASE="0.1"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

PATCH="spordefs.patch"
TARGET="spordefs.m"
PROJ="SporView.bproj"
#PATCH2="InnerSpace_GNUMakefile.patch"
TARGET2="GNUMakefile"
STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d InnerSpace ];then
        cd InnerSpace
        svn update
else
        svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/InnerSpace
        cd InnerSpace
fi
clear
subtitulo
ok "$APPNAME: Fetched"

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
		patch --forward -u ${TARGET} -i ${PATCH} | tee -a $LOG
		ok "\tPatch applied"
	fi
	make &>>$LOG
	cd ..
	cp --recursive $SUB $HOME/GNUstep/Library/InnerSpace/
	ok "\r\tDone"
done

printf "Building Main InnerSpace...\n"
### PATCH
#cp $_PWD/RESOURCES/PATCHES/$PATCH2 ./
#printf "\tA patch must be applied...\n"
#patch --forward -u ${TARGET2} -i ${PATCH2} | tee -a $LOG
#ok "\tPatch applied"

_build

sleep $SLEEP
}
### End of InnerSpace
##############################################

##########################################
## SimpleAgenda
### Repo/Release: github/poroussel: 0.4.8
##########################################

function install_simpleagenda()
{
clear

APPNAME=SimpleAgenda
RELEASE="0.4.8"
ARCH_PATH="https://github.com/poroussel/simpleagenda/archive/refs/tags/v0.48.tar.gz"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d simpleagenda* ];then
	rm -fR simpleagenda*
fi

fetch "$ARCH_PATH"
if [ -f v0.48.tar.gz ];then
    gunzip v0.48.tar.gz && tar -xf v0.48.tar || exit 1
    rm v0.48.tar
fi

cd simpleagenda-0.48 || exit 1

clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}


#######################################
## SystemPreferences
### Repo/release: github/gnustep: 1.2.0
########################################

function install_systempreferences()
{
clear
APPNAME="SystemPreferences"
RELEASE="1.2.0"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-systempreferences ];then
	cd apps-systempreferences
	git pull
else
	git clone --branch=master https://github.com/gnustep/apps-systempreferences
	cd apps-systempreferences || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}



#############################################
## Terminal
### Repo/Release: Savannah/svn
#############################################

function install_terminal()
{
clear
APPNAME=Terminal
RELEASE="0.9.8"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"


if [ -d Terminal ];then
	cd Terminal
	svn update
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/system-apps/Terminal
	cd Terminal || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}



##########################################
## TimeMon
### Repo/Release: Savannah/gap: 4.1
##########################################

function install_timemon()
{
clear
APPNAME=TimeMon
RELEASE="4.1"
HUB=

STR="$APPNAME $RELEASE"
subtitulo

printf "Fetching...\n"
cd ../build || exit 1

if [ -d $APPNAME ];then
        cd $APPNAME
        svn update
else
        svn co svn://svn.savannah.nongnu.org/gap/trunk/ported-apps/Util/$APPNAME
        cd $APPNAME || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}


#################################################
########## ALTERNATIVE #############################

###################################################
## Mixer in the native Agnostep apps
## only consistent with RPI...
##
## VolumeControl
### Repo/Release: Github/Alexmyczko
###################################################

function install_volumecontrol()
{
clear
APPNAME=VolumeControl
RELEASE=""
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d ${APPNAME}.app ];then
	cd ${APPNAME}.app
	git pull
else
	git clone https://github.com/alexmyczko/VolumeControl.app.git
	cd ${APPNAME}.app || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

_build

sleep $SLEEP
}





#################################################
################ OBSOLETE #######################
#################################################

#################################################
## GNUMail (current / stable tarball)
### Repo/Release: Savannah/gnustep-nonfsf: 1.4.0
### Obsolete
#################################################

function install_gnumail()
{
clear
APPNAME=GNUMail
RELEASE="1.4.0 - stable release"
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME - $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d GNUMail-1.4.0 ];then
	cd GNUMail-1.4.0
else
    fetch http://download.savannah.nongnu.org/releases/gnustep-nonfsf/GNUMail-1.4.0.tar.gz
    gunzip --force GNUMail-1.4.0.tar.gz
    tar -xf GNUMail-1.4.0.tar && rm GNUMail-1.4.0.tar
	cd GNUMail-1.4.0 || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

if [ -d /Local/Applications/GNUMail.app ];then
	sudo rm -fR /Local/Applications/GNUMail.app
	make_services
fi

_build

sleep $SLEEP
}

##################################

###################################################
## TextEdit
### Repo/Release: Debian Salsa GNUstep-Team
###
### Caution! This app was very unstable and
### often froze the System
### I guess some memory leak
###################################################

function install_textedit()
{
clear
APPNAME=TextEdit
RELEASE="5.0"
HUB=https://salsa.debian.org/gnustep-team/textedit.app.git
DIR=textedit.app
CONFIG_ARGS=""
BUILD_ARGS=""
INSTALL_ARGS=""

STR="$APPNAME $RELEASE"
subtitulo

cd ../build || exit 1

printf "Fetching...\n"
if [ -d $DIR ];then
	cd $DIR
	git pull
else
	git clone $HUB
	cd $DIR || exit 1
fi
clear
subtitulo
ok "$APPNAME: Fetched"

printf "Patching...\n"
is_quilt
set_quilt
quilt push -a

_build

sleep $SLEEP
}

