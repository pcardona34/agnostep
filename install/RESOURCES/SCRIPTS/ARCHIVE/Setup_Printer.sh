#!/bin/bash

### OS query ##
OS_ID=`cat /etc/os-release | grep -E ^ID | awk -F= '{print $2}'`
#CONF=~/.config/pisi/cups.conf


###################################"
### Dependencies
function deps()
{
# Dependencies
if [ ${OS_ID} == "debian" ];then
	PMGR="apt"
else
	printf "\nSorry: Your Operating System is not yet supported.\n"
	exit 1
fi

sudo ${PMGR} install cups cups-filters hplip libsane-hpaio -y
}

if [ ! -f $CONF ];then
	printf "\nThe File of the Printer settings could not be found:\n\t$CONF\n"
	exit 1
fi

. $CONF

#######################################
### Try to detect and install the printer
### from the network...
function auto()
{
URI=`sudo lpinfo -v | grep -e "ipps:" | awk '{print $2}'`
if [ -n "$URI" ];then
	sudo lpadmin -p $PRINTERNAME -v $URI -m $MODEL
else
	printf "\nThe auto-seup of the Printer failed.\nTrying another method...\n"
	web
fi
}

##############################################################
### web admin method to Set CUPS
function web()
{
WEBB=`xdg-settings get default-web-browser`

if [ ! $? -eq 0 ];then
	printf "\nYou must install and set your default Web Browser.\n"
	exit 1
fi

xdg-open "http://localhost:631/"
}

############################"
deps
web
