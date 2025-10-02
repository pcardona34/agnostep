

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = DatabaseOperations
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

DatabaseOperations_OBJC_FILES = \
	DatabaseOperations.m

DatabaseOperations_HEADERS = \
	DatabaseOperations.h

DatabaseOperations_PRINCIPAL_CLASS = DatabaseOperationsComponent

DatabaseOperations_LANGUAGES = English German

DatabaseOperations_LOCALIZED_RESOURCE_FILES = \
	Localizable.strings \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make
