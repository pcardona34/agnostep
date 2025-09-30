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
### Print free available space
################################

####################################################
### Include functions

. SCRIPTS/colors.sh

### End of include functions
####################################################

function print_size()
{
ROOT=`cat /etc/mtab | grep -e "^/" | grep -e "ext4" | awk '{print $1}'`
df -h > tmp
SIZE=`cat tmp | grep -e $ROOT | awk '{print $4}'`

info "Free space available: $SIZE"

rm tmp
}

### test
#print_size
