include $(GNUSTEP_MAKEFILES)/common.make


# Application
VERSION = 0.4
PACKAGE_NAME = Gemas
APP_NAME = Gemas
Gemas_APPLICATION_ICON = Gemas.tiff

# Languages
Gemas_LANGUAGES = \
  English \
  Spanish

Gemas_LOCALIZED_RESOURCE_FILES = \
Gemas.gorm \
Editor.gorm \
Preferences.gorm \
GoToLine.gorm \
Localizable.strings

# Resource files
Gemas_RESOURCE_FILES = \
Resources/Gemas.tiff \
Resources/Gemas.ico \
Resources/FileIcon_.c.tiff \
Resources/FileIcon_.cc.tiff \
Resources/FileIcon_.gsmarkup.tiff \
Resources/FileIcon_.h.tiff \
Resources/FileIcon_.m.tiff \
Resources/FileIcon_.mm.tiff \
Resources/FileIcon_.plist.tiff \
Resources/FileIcon_.strings.tiff \
Resources/FileIcon_makefile.tiff \
Resources/nonEnglishCharacters.plist \
Resources/AppResources \
Resources/ToolResources \
Resources/words.plist


# Header files
Gemas_HEADER_FILES = \
GemasController.h \
GemasEditorView.h \
GemasDocument.h \
EditorWindow.h


# Class files
Gemas_OBJC_FILES = \
GemasController.m \
GemasEditorView.m \
GemasDocument.m \
EditorWindow.m


# Other sources
Gemas_OBJC_FILES += \
Gemas_main.m


# Makefiles
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
