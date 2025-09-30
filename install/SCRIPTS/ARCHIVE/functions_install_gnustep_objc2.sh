#!/bin/bash

####################################################
### P i S i N     Desktop - by Patrick Cardona
### pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### PISIN Installation of GNUstep: Functions
####################################################

#################################################
### Thanks to the original script
### by Patryck Laurent (plaurent @ github.com)
### See project: gnustep-build
### Folder: debian-12-clang-14.0
#################################################


function install_make
{
TITLE="Building GNUstep-make..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd make || exit 1

sudo make distclean &>/dev/null

printf "Configuring...\n"
./configure \
    --with-layout=gnustep \
    --disable-importing-config-file \
    --enable-native-objc-exceptions \
    --enable-objc-arc \
    --enable-install-ld-so-conf \
    --with-library-combo=ng-gnu-gnu &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"
sudo ldconfig
}
################################################

#################################################
# Checkout sources
function fetch_sources
{
TITLE="Checking out Sources..."
echo "$TITLE" >>$LOG
title "$TITLE"

HUB=https://github.com/
GCD=swift-corelibs-libdispatch
GSMAKE=make
OBJC2=libobjc2
BASE=base
GUI=gui
BACK=back

printf "Apple Grand Central Dispatch Lib\n"
git clone $HUB/apple/$GCD &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Tools Make\n"
git clone $HUB/gnustep/$GSMAKE &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nLib ObjC2\n"
git clone $HUB/gnustep/${OBJC2}.git &>>$LOG &
PID=$!
spinner
printf "\r"
cd $OBJC2
 	git checkout 2.1 &>>$LOG
  	git submodule init &>>$LOG
  	git submodule sync &>>$LOG
  	git submodule update &>>$LOG
cd ..
ok "Done"
printf "\nGNUstep Base\n"
git clone $HUB/gnustep/$BASE &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Gui\n"
git clone $HUB/gnustep/$GUI &>>$LOG &
PID=$!
spinner
ok "\rDone"
printf "\nGNUstep Back\n"
git clone $HUB/gnustep/$BACK &>>$LOG &
PID=$!
spinner
ok "\rDone"
}

#################################################
## Build libDispatch
function install_GCD
{
TITLE="Building Grand Central Dispatch"
echo "$TITLE">>$LOG
title "$TITLE"

cd swift-corelibs-libdispatch || exit 1

mkdir build && cd build

printf "Configuring...\n"
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	 -DCMAKE_SKIP_RPATH=ON \
	 -DCMAKE_BUILD_TYPE='None' \
	 -DCMAKE_INSTALL_PREFIX=/usr/GNUstep \
	 -DCMAKE_INSTALL_LIBDIR=/usr/GNUstep/System/Library/Libraries/ \
	 -DCMAKE_INSTALL_MANDIR=/usr/GNUstep/System/Library/Documentation/man/ \
	 -DINSTALL_DISPATCH_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/dispatch \
	 -DINSTALL_BLOCK_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/block \
	 -DINSTALL_OS_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/os \
	 -DINSTALL_PRIVATE_HEADERS=YES &>>$LOG &
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
printf "\r"
### Post_install
BLOCK_PATH=/usr/GNUstep/System/Library/Headers/block
sudo rm --force ${BLOCK_PATH}/Block.h
sudo rm --force ${BLOCK_PATH}/Block_private.h
sudo ldconfig
ok "Done"
}

#################################################
## Build libobjc2
function install_objc2
{
TITLE="Building libobjc2..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd libobjc2 || exit 1

mkdir build && cd build

printf "Configuring...\n"
cmake .. -DBUILD_STATIC_LIBOBJC=1 \
	-DGNUSTEP_INSTALL_TYPE='SYSTEM' \
	-DCMAKE_BUILD_TYPE='Release' \
	-DCMAKE_LIBRARY_PATH=/usr/lib \
	-DCMAKE_INSTALL_PREFIX=/usr/GNUstep \
    	-DCMAKE_C_COMPILER=${CC} \
    	-DCMAKE_CXX_COMPILER=${CXX} \
    	-DCMAKE_LINKER=${LD} \
    	-DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS}" &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling\n"
sudo -E make install &>>$LOG &
PID=$!
spinner
ok "\rDone"
sudo ldconfig
}
#################################################

#################################################
## Build GNUstep base
function install_base
{
TITLE="Building Fundation: GNUstep Base..."
echo "TITLE" >>$LOG
title "$TITLE"

cd base || exit 1

printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
#################################################

#################################################
## Build GNUstep GUI
function install_gui
{
TITLE="Building AppKit: GNUstep Gui"
echo "$TITLE" >>$LOG
title "$TITLE"

cd gui || exit 1

printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
#################################################

#################################################
## Build GNUstep back
function install_back
{
TITLE="Building the Backend: GNUstep Back..."
echo "$TITLE" >>$LOG
title "$TITLE"

cd back || exit 1
printf "Configuring...\n"
./configure &>>$LOG &
PID=$!
spinner
printf "\rBuilding...\n"
make -j8 &>>$LOG &
PID=$!
spinner
printf "\rInstalling...\n"
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install &>>$LOG &
PID=$!
spinner
ok "\rDone"

sudo ldconfig
}
###############################################

######################################
### is_gnustep_ok

function is_gnustep_ok
{
TITLE="Checking GNUstep installation..."
title "$TITLE"

local _COUNT=0

cd $HOME
for _LOG in *.log
do
	grep -e " Error " $_LOG &>/dev/null
	if [ $? -eq 0 ];then
		_COUNT=$(( $_COUNT + 1 ))
	fi
	grep -e " error: " $_LOG &>/dev/null
	if [ $? -eq 0 ];then
		_COUNT=$(( $_COUNT + 1 ))
	fi
done

if [ ${_COUNT} -ne 0 ];then
	alert "GNUstep installation has generated ${_COUNT} errors: check the logs in your home directory."
	exit 1
else
	info "GNUstep installation was successful. You can go forward."
fi
}
########################################

### Enf of functions
########################################
