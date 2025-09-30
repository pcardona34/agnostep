#!/bin/sh

### Inventory of libs and apps...
R=../RELEASE
NAME="PiSi"
NUMBER="0.1"
STATUS="-alpha"
APPDIR=/usr/local/lib/GNUstep/Applications

if [ -f ../../RELEASE ];then
	mv ../../RELEASE ../../RELEASE.old
fi

printf "Pi-STEP initiative Desktop\nTribute to ${NAME} - Release: ${NUMBER}${STATUS}\n==========================\n" >> $R
wmaker --version >> $R

printf "\nApplications\n===============\n" >> $R
for APP in ${APPDIR}/*.app
do
	echo `basename ${APP%.app}` >> $R
done

if [ -f ../../RELEASE.old ];then
	rm ../../RELEASE.old
fi
