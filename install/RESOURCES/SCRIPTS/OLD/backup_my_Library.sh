#!/bin/bash

DEST=$HOME/BUML

### Backup my Library
if [ -d $DEST ];then
	rm -fR $DEST
fi

mkdir $DEST && cd $DEST

mkdir Library && cd Library

for L in Addresses \
Affiche \
SimpleAgenda \
WindowMaker
do
	if [ -d $HOME/GNUstep/Library/$L ];then
		cp --recursive $HOME/GNUstep/Library/$L ./
	fi
done

cd ..
mkdir Defaults && cd Defaults
cp $HOME/GNUstep/Defaults/*.plist ./

cd $HOME
tar cvf BUML.tar BUML && gzip BUML.tar
rm -fR BUML
