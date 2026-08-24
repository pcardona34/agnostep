####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### Sound: a little app to test and help to set sound...
### GNUMakefile
####################################################


include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Sound
Sound_APPLICATION_ICON = Sound.tiff

Sound_RESOURCE_FILES = \
Resources \
Resources/Sound.tiff \
Resources/cuckoo.wav

Sound_HEADER_FILES = \
Delegate.h

Sound_OBJC_FILES = \
Delegate.m \
Main.m

#
# Localization
#
Sound_LANGUAGES = English French
Sound_LOCALIZED_RESOURCE_FILES = \
Sound.help \
SoundInfo.plist \
Localizable.strings

include $(GNUSTEP_MAKEFILES)/application.make

