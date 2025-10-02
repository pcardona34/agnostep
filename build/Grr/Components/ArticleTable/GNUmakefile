

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ArticleTable
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

ArticleTable_OBJC_FILES = \
	ArticleTablePlugin.m

ArticleTable_HEADERS = \
	ArticleTablePlugin.h

ArticleTable_PRINCIPAL_CLASS = ArticleTablePlugin

ArticleTable_LANGUAGES = English German

ArticleTable_LOCALIZED_RESOURCE_FILES = \
	ArticleTablePlugin.gorm \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ADDITIONAL_INCLUDE_DIRS += -I../../../../libs/

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make

