#!/bin/bash

MOTIF="$1"
ENGINE="https://www.duckduckgo.com/?q="
MODE="-g -mode 800x600"
DOWN="-download-dir /home/patrick/Downloads"
links2 $MODE $DOWN "${ENGINE}$1"
