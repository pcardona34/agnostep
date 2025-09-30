#!/bin/bash

URL="$1"
MODE="-g -mode 800x600"
DOWN="-download-dir /home/patrick/Downloads"
links2 $MODE $DOWN "$1"
