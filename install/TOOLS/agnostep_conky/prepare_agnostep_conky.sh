#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Create the Conky conf file
################################

################################
### VARS

TRANS=`echo ${LANG%.UTF-8} | awk -F_ '{print $1}'`

###################################################
function assemble
{
laptop-detect
if [ $? -eq 0 ];then
	cat head.txt battery.txt foot.txt >> conky.conf.$TRANS
else
	cat head.txt foot.txt >> conky.conf.$TRANS
fi
}
###################################################

if [ -n $TRANS ];then
	case $TRANS in
		"fr")
			cd fr && assemble
			mv conky.conf.fr ../conky.conf
			cd ..
			printf "The file 'conky.conf' has been generated\n";;
		"en" | *)
			cd en && assemble
			mv conky.conf.en ../conky.conf
			cd ..
			printf "The file 'conky.conf' has been generated\n";;
	esac
else
	printf "The LANG was not guessed. Aborting.\n"
	exit 1
fi
