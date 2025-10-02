

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = Searching
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

Searching_OBJC_FILES = \
	Searching.m \
	NSSet+ArticleFiltering.m \


Searching_HEADERS = \
	Searching.h \
	NSSet+ArticleFiltering.h \


Searching_PRINCIPAL_CLASS = SearchingComponent

Searching_LANGUAGES = English German

Searching_LOCALIZED_RESOURCE_FILES = \
	Localizable.strings \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make
