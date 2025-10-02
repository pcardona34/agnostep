

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = Fonts
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

Fonts_OBJC_FILES = \
	FontsComponent.m \
	FontBox.m \

Fonts_HEADERS = \
	FontsComponent.h \
	FontBox.h \

Fonts_PRINCIPAL_CLASS = FontsComponent

Fonts_LANGUAGES = English German

Fonts_LOCALIZED_RESOURCE_FILES = \
	FontsComponent.gorm \

Fonts_RESOURCE_FILES = \
	Resources/Fonts.tiff \

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make
