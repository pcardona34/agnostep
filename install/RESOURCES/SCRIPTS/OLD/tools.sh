#!/bin/bash

####################
## Spinner
####################

function spinner()
{
i=1
spin="/-\|"
echo -n ' '
while called
do
	sleep 0.1
	printf "\b${spin:i++%${#spin}:1}"
done
}


