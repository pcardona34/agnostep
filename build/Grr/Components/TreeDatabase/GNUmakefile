

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = TreeDatabase
BUNDLE_EXTENSION = .grrdb

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

TreeDatabase_OBJC_FILES = \
	TreeDatabaseComponent.m \

TreeDatabase_HEADERS = \
	TreeDatabaseComponent.h \

TreeDatabase_PRINCIPAL_CLASS = TreeDatabaseComponent


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make
