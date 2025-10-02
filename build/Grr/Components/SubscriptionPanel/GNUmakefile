

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = SubscriptionPanel
BUNDLE_EXTENSION = .grrc

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Grr.app/Resources/

SubscriptionPanel_OBJC_FILES = \
	SubscriptionPanel.m \

SubscriptionPanel_HEADERS = \
	SubscriptionPanel.h \

SubscriptionPanel_PRINCIPAL_CLASS = SubscriptionPanel

SubscriptionPanel_LANGUAGES = English German

SubscriptionPanel_LOCALIZED_RESOURCE_FILES = \
	SubscriptionPanel.gorm \
	Localizable.strings \


ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../..

include ../../GNUmakefile.preamble

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_LIB_DIRS += ../../Grr.app/Grr.exe.a
endif

include $(GNUSTEP_MAKEFILES)/bundle.make
