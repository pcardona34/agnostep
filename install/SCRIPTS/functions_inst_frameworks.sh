#!/bin/bash

####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

################################
### Functions for Install Frameworks
################################

##################################
## PDFKit
function install_pdfkit()
{

FWNAME="PDFKit"
#CONFIG_ARGS="--enable-a4-paper"

cd ../build || exit 1

title "PDFKit"
echo "PDFKit" >>$LOG
printf "Fetching...\n"

if [ -d PDFKit-1.2.0 ];then
	cd PDFKit-1.2.0
else
	wget --quiet http://savannah.nongnu.org/download/gap/PDFKit-1.2.0.tar.gz
	gunzip --force PDFKit-1.2.0.tar.gz
	tar -xf PDFKit-1.2.0.tar
	cd PDFKit-1.2.0
fi

_build_FW
}
### End of PDFKit
################################

################################
## Addresses FW
function install_fw_addresses()
{

cd ../build || exit 1

title "Addresses"
echo "Addresses" >>$LOG
printf "Fetching...\n"

if [ -d Addresses-0.5.0 ];then
	cd Addresses-0.5.0
else
	wget --quiet http://savannah.nongnu.org/download/gap/Addresses-0.5.0.tar.gz
	gunzip --force Addresses-0.5.0.tar.gz
	tar xf Addresses-0.5.0.tar
	cd Addresses-0.5.0
fi

cd Frameworks
FWNAME="Addresses"
cd Addresses

_build_FW
}
### End of Addresses
################################


################################
## Addresses and AddressView FW
function install_fw_addressview()
{

cd ../build || exit 1

title "AddressView"
echo "AddressView" >>$LOG
printf "Fetching...\n"

if [ -d Addresses-0.5.0 ];then
	cd Addresses-0.5.0
else
	wget --quiet http://savannah.nongnu.org/download/gap/Addresses-0.5.0.tar.gz
	gunzip --force Addresses-0.5.0.tar.gz
	tar xf Addresses-0.5.0.tar
	cd Addresses-0.5.0
fi

cd Frameworks
FWNAME="AddressView"
cd AddressView

_build_FW
}
### End of Addresses
################################

################################
## Pantomime
function install_pantomime()
{

cd ../build || exit 1

FWNAME="Pantomime"
title "Pantomime"
echo "Pantomime" >>$LOG
printf "Fetching...\n"

if [ -d Pantomime-1.4.0 ];then
	cd Pantomime-1.4.0
else
	wget --quiet http://download.savannah.nongnu.org/releases/gnustep-nonfsf/Pantomime-1.4.0.tar.gz
	gunzip --force Pantomime-1.4.0.tar.gz
	tar -xf Pantomime-1.4.0.tar
	cd Pantomime-1.4.0
fi

_build_FW
}
### End of Pantomime
###############################

###############################
## SimpleWebKit
function install_SWK()
{

cd ../build || exit 1

FWNAME="SimpleWebKit"
title "SimpleWebKit"
echo "SimpleWebKit" >>$LOG
printf "Fetching...\n"
if [ -d libs-simplewebkit ];then
	cd libs-simplewebkit
	git pull origin master &>/dev/null
else
	git clone https://github.com/gnustep/libs-simplewebkit.git &>/dev/null
	cd libs-simplewebkit
fi

_build_FW
}
### End of SWK
###############################



###############################
## HighLighterKit
function install_hlkit()
{

cd ../build || exit 1

FWNAME="HighlighterKit"
title "HighlighterKit"
echo "HighlighterKit" >>$LOG

printf "Fetching...\n"
if [ -d HighlighterKit-0.1.3 ];then
	cd HighlighterKit-0.1.3
else
	wget --quiet http://download.savannah.nongnu.org/releases/gnustep-nonfsf/HighlighterKit-0.1.3.tar.gz
	gunzip --force HighlighterKit-0.1.3.tar.gz
	tar -xf HighlighterKit-0.1.3.tar
	cd HighlighterKit-0.1.3
fi

_build_FW
}
### End of HighLighterKit
###############################

###############################
## Themes for HLKit
function install_hkthemes()
{

cd ../build || exit 1

title "Themes for HLKit"
echo "Themes for HLKit" >>$LOG

printf "Fetching...\n"
if [ -d HKThemes ];then
	cd HKThemes
else
	wget --quiet http://download.savannah.nongnu.org/releases/gnustep-nonfsf/HKThemes-1.0.tar.gz
	gunzip --force HKThemes-1.0.tar.gz
	tar -xf HKThemes-1.0.tar
	cd HKThemes
fi

printf "Installing..."
if [ ! -d  ${HOME}/GNUstep/Library/HKThemes ];then
        mkdir -p ${HOME}/GNUstep/Library/HKThemes
fi
printf " in ${HOME}/GNUstep/Library/HKThemes...\n"
cp --recursive "Dark.definition" ${HOME}/GNUstep/Library/HKThemes/
cp --recursive "Glow.definition" ${HOME}/GNUstep/Library/HKThemes/

ok "Done"
cd $_PWD
}
### End of Themes for HLKit
###############################

###############################
## Renaissance
function install_renaissance()
{
cd ../build || exit 1

FWNAME="Renaissance"
title "Renaissance"
echo "Renaissance" >>$LOG

printf "Fetching...\n"
if [ -d libs-renaissance ];then
	cd libs-renaissance
	git pull origin master &>/dev/null
else
	git clone https://github.com/gnustep/libs-renaissance.git &>/dev/null
	cd libs-renaissance
fi

_build_FW
}
### End of Renaissance
##############################

##############################
## Performance
function install_performance()
{

cd ../build || exit 1

FWNAME="Performance"
title "Performance"
echo "Performance" >>$LOG

printf "Fetching...\n"
if [ -d libs-performance ];then
        cd libs-performance
        git pull origin master &>/dev/null
else
        git clone https://github.com/gnustep/libs-performance.git &>/dev/null
        cd libs-performance
fi

_build_FW
}
### End of Performances
###############################

###############################
## WebServices
function install_webservices()
{

cd ../build || exit 1

FWNAME="WebServices"
title "WebServices"
echo "WebServices" >>$LOG

printf "Fetching...\n"
if [ -d WebServices-0.9.0.tar ];then
	cd WebServices-0.9.0
else
	wget --quiet ftp://ftp.gnustep.org/pub/gnustep/libs/WebServices-0.9.0.tar.gz
	gunzip --force WebServices-0.9.0.tar.gz
	tar -xf WebServices-0.9.0.tar
	cd WebServices-0.9.0
fi

_build_FW
}
### End of WebServices
###############################

##############################################
### libs-steptalk
function install_steptalk()
{
FWNAME="StepTalk"
title "$FWNAME"
echo "$FWNAME" >>$LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d libs-steptalk ];then
	cd libs-steptalk
	git pull origin master &>/dev/null
else
	git clone https://github.com/gnustep/libs-steptalk &>/dev/null
	cd libs-steptalk
fi

_build_FW

}
### End of StepTalk
###############################################

###############################
## RSSKit
function install_rsskit()
{
FWNAME="RSSKit"
title "$FWNAME"
echo "$FWNAME" >>$LOG

cd ../build || exit 1

printf "Fetching...\n"
if [ -d RSSKit ];then
	cd RSSKit
	svn update &>/dev/null
else
	svn co svn://svn.savannah.nongnu.org/gap/trunk/libs/RSSKit &>/dev/null
	cd RSSKit
fi

_build_FW

}
### End of RSSKit
###############################


##########################################################################
### ******************************************************************
### /!\ The following code is NOT functional
### ******************************************************************
##########################################################################

###############################
## DBusKit_OLD
function install_dbuskit_OLD()
{

######################################################
### Dirty code to correct headers not found issues
### within aarch64 system
cd /usr/include
sudo ln -s dbus-1.0/dbus
cd dbus
sudo ln -s /usr/lib/aarch64-linux-gnu/dbus-1.0/include/dbus/dbus-arch-deps.h
sudo ldconfig

cd $_PWD
### End of dirty code
######################################################

cd ../build || exit 1

FWNAME="libs-dbuskit"
title "DBusKit"
echo "DBusKit" >>$LOG

printf "Fetching...\n"
if [ -d libs-dbuskit ];then
        cd libs-dbuskit
        git pull origin master 
##&>/dev/null
else
        git clone https://github.com/gnustep/libs-dbuskit.git 
##&>/dev/null
        cd libs-dbuskit
fi

##################################################
### Dirty BIS...
cd Source
cp --force --update config.h.in config.h
cd ..
##################################################

printf "Configuring...\n"

##################################################
### Corrects a permission issue
chmod +x configure

### Updating config.guess and config.sub
rm --force config.guess
rm --force config.sub
if ! [ -d config ];then
	git clone https://git.savannah.gnu.org/git/config.git 
##&>/dev/null
fi
cp --force --update config/config.guess ./
cp --force --update config/config.sub ./

./configure
#&>>$LOG &
#PID=$!
#spinner

printf "\rBuilding...\n"
make
#&>>$LOG &
#PID=$!
#spinner

#printf "\rInstalling...\n"
###sudo -E make install
# &>>$LOG &
#PID=$!
#spinner

### Cleaning
sudo make clean &>/dev/null

ok "\rDone"
cd $_PWD

check_FW $FWNAME
}
### End of DbusKit_OLD
###############################

###############################
### Another try...
## DBusKit
function install_dbuskit()
{

######################################################
### Dirty code to correct headers not found issues
### within aarch64 system
cd /usr/include
sudo ln -s dbus-1.0/dbus
cd dbus
sudo ln -s /usr/lib/aarch64-linux-gnu/dbus-1.0/include/dbus/dbus-arch-deps.h
sudo ldconfig

### End of dirty code
######################################################

######################################################
### Dependencies
#sudo apt install -y libdbus-1-dev libdbus-1-3 libclang1-19 libclang-19-dev

cd $_PWD

cd ../build
git clone https://github.com/gnustep/libs-dbuskit/
cd libs-dbuskit
git checkout 5d69a35357f6e32fc2e1194194e176bf48588120

### Fix config.guess and config.sub:

curl -o config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
curl -o config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"

##################################################
### Dirty BIS...
cd Source
cp --force --update config.h.in config.h
cd ..
##################################################

./configure
make nonstrict=yes && sudo -E make install
cd Bundles
    cd ../DKUserNotification
        make
        sudo -E make install

cd $_PWD
}
### End of DbusKit
###############################



####################################################################

###############################
### OBSOLETE !!!
#### The AGNOSTEP Theme is now  provided
#### within the folder RESOURCES
###############################

## Themes
function install_themes()
{

cd ../build || exit 1

APPNAME="Sombre"

title "Theme $APPNAME for GNUstep"
echo "Theme $APPNAME for GNUstep" >>$LOG
printf "Fetching...\n"

if [ -d plugins-themes-sombre ];then
	cd plugins-themes-sombre
	git pull origin master &>/dev/null
else
	git clone https://github.com/gnustep/plugins-themes-sombre &>/dev/null
	cd plugins-themes-sombre
fi

_build_THEME
}
### End of Theme Sombre
###############################

