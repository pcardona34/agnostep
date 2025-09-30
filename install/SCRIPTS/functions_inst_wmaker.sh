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
### Functions for AGNoStep Desktop Base - WMaker
####################################################

####################################################
### Include functions

. SCRIPTS/check_app.sh

### End of include functions
#######################################

function check_LD_LIB_PATH
{
echo ${LD_LIBRARY_PATH} | grep -e "/usr/local/lib" &>/dev/null
if [ $? -ne 0 ];then
	export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
fi
}


#####################################
## Window Maker
### Repo: windowmaker.org
### Release: see below
#####################################

function install_wmaker()
{

REPO="https://www.windowmaker.org/pub/source/release/"
APP="WindowMaker"
APPNAME="$APP"

############ CHOICE OF THE RELEASE #################
# Install the latest release of WMaker: 0.96.0
RELEASE="0.96.0"
# Install previous stable release
#RELEASE="0.95.9"
#####################################################

CONFIG_ARGS="--disable-xinerama"
## --disable-magick
## --with-gnustepdir=/usr/GNUstep/Local
EXT=".tar.gz"
DIR="${APP}-${RELEASE}"
ARCHIVE="${DIR}${EXT}"
#LINGUAS="fr uk"

title "$APPNAME $RELEASE"
echo "$APPNAME $RELEASE" >>$LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d $DIR ];then
	cd $DIR
else
	wget --quiet "${REPO}${ARCHIVE}"
	gunzip --force ${ARCHIVE}
	tar -xf ${DIR}.tar
	cd $DIR || exit 1
fi

#if ! [ -d /usr/GNUstep/System/Applications ];then
#	sudo mkdir -p /usr/GNUstep/System/Applications
#fi

printf "Configuring...\n"
./autogen.sh ${CONFIG_ARGS} &>>$LOG
./configure ${CONFIG_ARGS} &>>$LOG &
PID=$!
spinner

printf "\rBuilding...\n"
make &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner

sudo ldconfig

### Cleaning
make clean &>/dev/null

cd $_PWD

ok "\rDone"

### Checking
VER=`wmaker --version`
if [ $? == 0 ];then
	info "$VER has been successfully installed."
else
	alert "Window Maker was not successfully installed. This is a major issue. Read $LOG.\nAnd report this issue to:\nhttps://github.com/pcardona34/pi-step-initiative/issues" && exit 1
fi
}

### End of Wmaker
######################################


##############################################
### AlsaMixer.app
### Release: 1.8
#
### launch:
### /Applications/AlsaMixer.app/AlsaMixer -L -S --card UC02 &
##############################################

function install_alsamixer_dot_app()
{
APPNAME="AlsaMixer.app"
REL="1.8.0"
PATCH=AlsaMixer.patch
RES_DIR=RESOURCES/PATCHES
TARGET=Makefile

title "${APPNAME} - ${REL}" | tee -a $LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d dockapps ];then
	cd dockapps
	git pull origin master || exit 1
else
	git clone https://repo.or.cz/dockapps.git
	cd dockapps
fi

cd AlsaMixer.app || exit 1
printf "A patch must be applied...  "
if ! [ -f $PATCH ];then
	cp $_PWD/$RES_DIR/$PATCH ./
fi
patch --forward -u $TARGET -i $PATCH
ok "Done"

printf "Building...\n"
make &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner

### Cleaning
make clean &>/dev/null

ok "\rDone"
cd $_PWD

printf "\nChecking...\n"
check "$APPNAME"
}
### End of AlsaMixer.app
##############################################


### End of functions
##############################################




#########################################################################
#########################################################################
### REMOVED

######################################
## WMClock
### Repo/Release: dockapps.net: 1.0.16
######################################

function install_wmclock
{

APPNAME=WMClock
RELEASE="1.0.16"
CONFIG_ARGS="--with-lang=french"

title "$APPNAME $RELEASE" | tee -a $LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d dockapps-daaf3aa ];then
	cd dockapps-daaf3aa
else
	wget --quiet https://www.dockapps.net/download/wmclock-1.0.16.tar.gz
	gunzip --force wmclock-1.0.16.tar.gz
	tar -xf wmclock-1.0.16.tar
	cd dockapps-daaf3aa
fi

printf "Configuring...\n"
autoreconf -i &>>$LOG
./configure ${CONFIG_ARGS} &>>$LOG &
PID=$!
spinner

printf "\rBuilding...\n"
make &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo make install &>>$LOG &
PID=$!
spinner

ok "\rDone"
cd $_PWD

### Checking
WMC=`which wmclock`
if [ $? -eq 0 ];then
	info "The app binary has been found here:\n${WMC}"
else
	alert "The app binary was not found. Please, report this issue." && exit 1
fi

}
### End of WMClock
##############################################

#################################################
### WMifs: dockapp for monitoring network if
#################################################

function install_wmifs()
{
APPNAME="wmifs"
REL="1.9"

echo "$APPNAME $REL" >> $LOG
title "$APPNAME $REL"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d ${APPNAME}-${REL} ];then
	cd ${APPNAME}-${REL}
else
	wget --quiet https://www.dockapps.net/download/${APPNAME}-${REL}.tar.gz
	gunzip --force ${APPNAME}-${REL}.tar.gz
	tar -xf ${APPNAME}-${REL}.tar
	cd ${APPNAME}-${REL}
fi

printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner

printf "\rBuilding...\n"
make &>>$LOG &
PID=$!
spinner

printf "\rInstalling...\n"
sudo -E make install &>>$LOG &
PID=$!
spinner

### Cleaning
make clean &>/dev/null

ok "\rDone"
cd $_PWD

### Checking
VER_WMIFS=$(wmifs -version) &2>1 >/dev/null
if [ $? -eq 0 ];then
	info "WMifs has been installed and checked."
	printf "Release: ${VER_WMIFS}"
else
	alert "Error: WMifs installation failed. Aborting!"
	exit 1
fi

}
### End of WMifs
#################################################

