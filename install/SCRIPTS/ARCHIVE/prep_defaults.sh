#!/bin/bash

####################################################
### P i S i N    Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Prep defaults...
################################

_PWD=`pwd`
GWDEF="org.gnustep.GWorkspace"
DEFDIR=$_PWD/RESOURCES/DEFAULTS

cd $DEFDIR || exit 1

if [ "$USER" == "patrick" ];then
	### Default user...
	cp --force ${GWDEF}.TEMPLATE ${GWDEF}.plist
else
	cat ${GWDEF}.TEMPLATE | sed -e s/patrick/$USER/g > ${GWDEF}.plist
fi

cd $_PWD
