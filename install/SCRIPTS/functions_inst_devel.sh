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
### Functions for Desktop Devel - GNUstep apps
####################################################


########################################
## Gorm
### Repo/Release: github/gnustep: 1.5.0
########################################

function install_gorm()
{

APPNAME=Gorm
RELEASE="1.5.0"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-gorm ];then
        cd apps-gorm
        git pull origin master &>/dev/null
else
        git clone --branch=master "https://github.com/gnustep/apps-gorm" &>/dev/null
        cd apps-gorm
fi

_build
}

########################################
## ProjectCenter
### Repo/Release: github/gnustep: 0.7.0
########################################

function install_PC()
{

APPNAME=ProjectCenter
RELEASE="0.7.0"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-projectcenter ];then
        cd apps-projectcenter
        git pull origin master &>/dev/null
else
        git clone --branch=master "https://github.com/gnustep/apps-projectcenter" &>/dev/null
        cd apps-projectcenter
fi

_build
}

########################################
## EasyDiff
### Repo/Release: github/gnustep: 0.4.1
########################################

function install_easydiff()
{

APPNAME=EasyDiff
RELEASE="0.4.1"

echo "$APPNAME $RELEASE" >>$LOG
title "$APPNAME $RELEASE"

cd ../build || exit 1

printf "Fetching...\n"
if [ -d apps-easydiff ];then
        cd apps-easydiff
        git pull origin master &>/dev/null
	make clean &>/dev/null
else
        git clone --branch=master "https://github.com/gnustep/apps-easydiff.git" &>/dev/null
        cd apps-easydiff
fi

_build
}


################################################
## Gemas
### Repo/Release: savannah/gnustep-nonfsf: 0.4
################################################

function install_gemas()
{
cd ../build || exit 1

APPNAME="Gemas"
RELEASE="0.4"
EXT=".tar.gz"
HUB=http://download.savannah.nongnu.org/releases/gnustep-nonfsf
CONFIG_ARGS=""
INSTALL_ARGS=""

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d ${APPNAME}-${RELEASE} ];then
	cd ${APPNAME}-${RELEASE}
else
	wget --quiet ${HUB}/${APPNAME}-${RELEASE}${EXT}
	gunzip --force ${APPNAME}-${RELEASE}${EXT}
	tar -xf ${APPNAME}-${RELEASE}.tar
	cd ${APPNAME}-${RELEASE} || exit 1
fi

_build
}


################################################
## Thematic
### Repo/Release: github/gnustep
################################################

function install_thematic()
{
cd ../build || exit 1

APPNAME="Thematic"
CONFIG_ARGS=""
INSTALL_ARGS="GNUSTEP_INSTALLATION_DOMAIN=LOCAL"

echo "$APPNAME - $RELEASE" >> $LOG
title "$APPNAME $RELEASE"

printf "Fetching...\n"
if [ -d apps-thematic ];then
	cd apps-thematic
	git pull origin master
else
	git clone https://github.com/gnustep/apps-thematic.git &>/dev/null
	cd apps-thematic
fi

_build
}
