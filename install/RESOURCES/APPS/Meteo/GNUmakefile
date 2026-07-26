include $(GNUSTEP_MAKEFILES)/common.make

#
# Application
#
VERSION = 0.2
PACKAGE_NAME = Meteo
APP_NAME = Meteo
Meteo_APPLICATION_ICON = weather.tiff 

#
# Resource files
#
Meteo_RESOURCE_FILES = \
Resources/weather.tiff 

#
# Localization
#
Meteo_LANGUAGES = English French
Meteo_LOCALIZED_RESOURCE_FILES = \
Localizable.strings \
MeteoInfo.plist

#
# Header files
#
Meteo_HEADER_FILES = \
MyDelegate.h \
PreferencesController.h \
PredictionController.h

#
# Objective-C Class files
#
Meteo_OBJC_FILES = \
MyDelegate.m \
PreferencesController.m \
PredictionController.m

#
# Other sources
#
Meteo_OBJC_FILES += \
Main.m

#
# Makefiles
#
include $(GNUSTEP_MAKEFILES)/application.make
