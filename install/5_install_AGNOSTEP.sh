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
### Desktop Main installation Script
####################################################

####################################################
### Vars

OPTION="${1:-help}"

### End of vars
####################################################

####################################################
### Include functions

. SCRIPTS/functions_install_AGNOSTEP.sh
. SCRIPTS/size.sh

### End of include functions
####################################################

case "$OPTION" in
	"APPS" | "Apps" | "apps")
		install_apps;;
	"DEVEL" | "Devel" | "devel")
		install_devel;;
	"EXTRA" | "Extra" | "extra")
		install_extra;;
	"GAMES" | "Games" | "games")
		install_games;;
	"help" | "*")
		help;;
esac

### Space available ?
print_size

### Info about 4th step
warning "Do not forget to run again './6_user_settings.sh' after each new installation of applications."
