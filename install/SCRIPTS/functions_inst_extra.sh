#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Functions for inst_extra_extra...
####################################################


################################################
## GNUstep Examples: Ink, Calculator,PowerPaint
### Repo/Release: github/gnustep/tests-examples
################################################

##########################
## Calculator
##########################

function install_calculator()
{

cd ../build || exit 1

APPNAME="Calculator"
REPO="tests-examples"
OWNER="gnustep"
HUB="https://github.com"
BRANCH="master"
BUILD_DIR="gui"
CONFIG_ARGS=""
INSTALL_DIR="/Local/Applications"
INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"

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

cd $BUILD_DIR/$APPNAME || exit 1

_build
}



##########################
## PowerPaint
##########################

function install_powerpaint()
{

cd ../build || exit 1

APPNAME="PowerPaint"
REPO="tests-examples"
OWNER="gnustep"
HUB="https://github.com"
BRANCH="master"
BUILD_DIR="gui" # "system-apps" | "ported-apps"
CONFIG_ARGS=""
INSTALL_DIR="/Local/Applications"

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
## Vespucci: GNUstep WebBrowser with SimpleWebKit
### Repo/Release: github/gnustep/gap: 0.1
###################################################

function install_vespucci()
{

cd ../build || exit 1

APPNAME="Vespucci"
REPO="gap"
OWNER="gnustep"
HUB="https://github.com"
BRANCH="master"
BUILD_DIR="user-apps"
CONFIG_ARGS=""
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

############################################
## StepSync
### Repo/Release: github/gnustep/gap: 0.1
############################################

function install_stepsync()
{
cd ../build || exit 1

APPNAME="StepSync"
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME" >> $LOG
title "$APPNAME"

printf "Fetching...\n"
if [ -d $APPNAME ];then
        cd $APPNAME
        svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/system-apps/StepSync &>/dev/null
	cd $APPNAME
fi

_build
}

##########################################
## Graphos
### Repo/release: Savannah/gap: 0.6
##########################################

function install_graphos()
{

cd ../build || exit 1

APPNAME="Graphos"
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME" >> $LOG
title "$APPNAME"

printf "Fetching...\n"
if [ -d $APPNAME ];then
        cd $APPNAME
        svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/Graphos &>/dev/null
	cd $APPNAME
fi

_build
}

#####################################################
## DictionaryReader
### Repo/Release: github/onflapp/gs-desktop: 1.0.0
#####################################################

function install_dictionaryreader()
{

cd ../build || exit 1

APPNAME="Dictionary"
REPO="gs-desktop"
OWNER="onflapp"
HUB="https://github.com"
BRANCH="main"
BUILD_DIR="Applications"
CONFIG_ARGS=""
INSTALL_DIRS=""

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

cd "$BUILD_DIR/${APPNAME}Reader"

_build
}

################################
## Cenon
### Repo/Release: cenon: 4.0.6
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### WARNING! None of the available versions
### build with GNU runtime
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
################################

function install_cenon()
{

cd ../build || exit 1

APPNAME="Cenon"
RELEASE="4.0.6"
EXT=".tar.bz2"
HUB=https://cenon.download/source
TARGET="${APPLICATIONS}"
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d ${APPNAME} ];then
	cd ${APPNAME}
else
	wget --quiet ${HUB}/${APPNAME}-${RELEASE}${EXT}
	bunzip2 --force ${APPNAME}-${RELEASE}${EXT}
	tar -xf ${APPNAME}-${RELEASE}.tar
	cd ${APPNAME}
fi

_build
}



#############################################
## FlexiSheet
### Repo/Release: github/gnustep/gap: 0.5.7
#############################################

function install_flexisheet()
{
cd ../build || exit 1

APPNAME="FlexiSheet"
REPO="gap"
OWNER="gnustep"
HUB="https://github.com"
BRANCH="master"
BUILD_DIR="user-apps" # "system-apps" | "ported-apps"
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d $APPNAME ];then
        cd $APPNAME
        svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/user-apps/FlexiSheet &>/dev/null
	cd $APPNAME
fi

_build
}

#######################################################
## PikoPixel
### Repo/Release: github/onflapp/gs-pikopixel: 1.0.b10
#######################################################

function install_pikopixel()
{

cd ../build || exit 1

APPNAME="PikoPixel"
REPO="gs-PikoPixel"
OWNER="onflapp"
HUB="https://github.com"
BRANCH="main"
BUILD_DIR="." # "system-apps" | "ported-apps"
CONFIG_ARGS=""
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

#####################################
## PRICE
### Repo/Release: sourceforge: 1.3.0
#####################################

function install_price()
{

cd ../build || exit 1

APPNAME="PRICE"
RELEASE="1.3.0"
EXT=".tar.gz"
HUB=https://master.dl.sourceforge.net/project/price/1.3.0
TARGET="${APPLICATIONS}"
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d ${APPNAME}-${RELEASE} ];then
	cd ${APPNAME}-${RELEASE}
else
	wget --quiet ${HUB}/${APPNAME}-${RELEASE}${EXT}
	gunzip ${APPNAME}-${RELEASE}${EXT}
	tar -xf ${APPNAME}-${RELEASE}.tar
	cd ${APPNAME}-${RELEASE}
fi

_build
}

##################################################
## FontManager
### Repo/Release: github/onflapp/gs-desktop: 0.1
##################################################

function install_fontmanager()
{

cd ../build || exit 1

APPNAME="FontManager"
REPO="gs-desktop"
OWNER="onflapp"
HUB="https://github.com"
BRANCH="main"
BUILD_DIR="Applications"
CONFIG_ARGS=""
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





############################################################################
### REMOVED

###########################################################
## NoteBook
### Repo/Release: github/pcardona34/gnustep-notebook: 0.3
###########################################################

function install_notebook()
{

cd ../build || exit 1

APPNAME="NoteBook"
REPO="gnustep-notebook"
OWNER="pcardona34"
HUB="https://github.com"
BRANCH="main"
BUILD_DIR="." # "system-apps" | "ported-apps"
CONFIG_ARGS=""
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

cd "$BUILD_DIR/${APPNAME}-0.3"

_build
}
######################################

######################################
## NetSurf-GNUstep
### 3.10
#
### Dependency: duktape and duktape-dev
######################################

function install_netsurf
{

APPNAME=NetSurf
RELEASE="3.11"

echo "$APPNAME $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching NetSurf Workspace...\n"
wget --quiet https://git.netsurf-browser.org/netsurf.git/plain/docs/env.sh
unset HOST
source env.sh &>/dev/null
printf "Installing the packages...\n"
ns-package-install &>>$LOG &
PID=$!
spinner

unset HOST
source env.sh &>/dev/null
ns-clone &>>$LOG &
PID=$!
printf "\r"
spinner

ns-pull-install &>>$LOG &
PID=$!
printf "\r"
spinner

rm env.sh
cd ~/dev-netsurf/workspace
rm -fR netsurf
printf "\rFetching gnustep-netsurf...\n"
wget --quiet https://github.com/anthonyc-r/netsurf-gnustep/archive/refs/tags/3.11-gnustep.tar.gz
gunzip --force 3.11-gnustep.tar.gz
tar xf 3.11-gnustep.tar
mv netsurf-gnustep-3.11-gnustep netsurf
cd netsurf || exit 1

printf "\rBuilding...\n"
make TARGET=gnustep NETSURF_USE_DUKTAPE=YES build/Linux-gnustep/duktape/polyfill.js.inc &>>$LOG &
PID=$!
spinner

make TARGET=gnustep NETSURF_USE_DUKTAPE=YES build/Linux-gnustep/duktape/generics.js.inc &>>$LOG &
PID=$!
printf "\r"
spinner

make TARGET=gnustep &>>$LOG &
PID=$!
printf "\r"
spinner

printf "\rInstalling...\n"
export LOCAL_INSTALL_DIR=$(gnustep-config --variable=GNUSTEP_LOCAL_APPS)
sudo cp -r NetSurf.app $LOCAL_INSTALL_DIR/

### Cleaning
make clean &>/dev/null
rm -fR $HOME/dev-netsurf

ok "\rDone"

cd $_PWD

check "$APPNAME"
}
### End of NetSurf
##############################################

