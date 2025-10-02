

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = DatabaseTreeView
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

DatabaseTreeView_OBJC_FILES = \
	DatabaseTreeViewController.m

DatabaseTreeView_HEADERS = \
	DatabaseTreeViewController.h

DatabaseTreeView_PRINCIPAL_CLASS = DatabaseTreeViewController

DatabaseTreeView_LANGUAGES = English German

DatabaseTreeView_LOCALIZED_RESOURCE_FILES = \
	DatabaseTreeViewController.gorm \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
