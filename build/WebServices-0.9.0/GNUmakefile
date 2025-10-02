
ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

-include config.make

PACKAGE_NAME = WebServices
PACKAGE_VERSION = 0.9.0
WebServices_INTERFACE_VERSION=0.9
CVS_MODULE_NAME = gnustep/dev-libs/WebServices
CVS_TAG_NAME = WebServices
SVN_BASE_URL=svn+ssh://svn.gna.org/svn/gnustep/libs
SVN_MODULE_NAME=webservices

NEEDS_GUI = NO

TEST_TOOL_NAME=

LIBRARY_NAME=WebServices
DOCUMENT_NAME=WebServices

WebServices_OBJC_FILES +=\
        WebServices.m \
	GWSBinding.m \
	GWSCoder.m \
	GWSDocument.m \
	GWSElement.m \
	GWSExtensibility.m \
        GWSHash.m \
	GWSMessage.m \
	GWSPort.m \
	GWSPortType.m \
	GWSService.m \
	GWSSOAPCoder.m \
	GWSXMLRPCCoder.m \
	GWSJSONCoder.m \
	WSSUsernameToken.m \


WebServices_HEADER_FILES += \
	WebServices.h \
	GWSBinding.h \
	GWSCoder.h \
	GWSConstants.h \
	GWSDocument.h \
	GWSElement.h \
	GWSExtensibility.h \
        GWSHash.h \
	GWSMessage.h \
	GWSPort.h \
	GWSPortType.h \
	GWSService.h \
	GWSType.h \
	WSSUsernameToken.h \


ADDITIONAL_OBJC_LIBS += -lPerformance
WebServices_LIBRARIES_DEPEND_UPON += -lPerformance 
ADDITIONAL_LDFLAGS += $(GNUTLS_LIBS) $(NETTLE_LIBS)
ADDITIONAL_OBJCFLAGS += $(GNUTLS_CFLAGS) $(NETTLE_CFLAGS)

WebServices_AGSDOC_FILES += \
	WebServices.gsdoc \
	WebServices.h \
	GWSBinding.h \
	GWSCoder.h \
	GWSConstants.h \
	GWSDocument.h \
	GWSElement.h \
	GWSExtensibility.h \
	GWSMessage.h \
	GWSPort.h \
	GWSPortType.h \
	GWSService.h \
	GWSType.h \
	WSSUsernameToken.h \


WebServices_AGSDOC_FLAGS = \
	-MakeFrames YES \
	-ConstantsTemplate TypesAndConstants \

# Optional Java wrappers for the library
JAVA_WRAPPER_NAME = WebServices

#
# Assume that the use of the gnu runtime means we have the gnustep
# base library and can use its extensions to build WebServices stuff.
#
BASEADD=0
ifeq ($(OBJC_RUNTIME_LIB),apple)
BASEADD=1
endif
ifeq ($(OBJC_RUNTIME_LIB),nx)
BASEADD=1
endif
ifeq ($(OBJC_RUNTIME_LIB),fd)
BASEADD=1
endif

ifeq ($(BASEADD),1)
ADDITIONAL_OBJC_LIBS += -lgnustep-baseadd
WebServices_LIBRARIES_DEPEND_UPON = -lgnustep-baseadd
endif

WebServices_HEADER_FILES_INSTALL_DIR = WebServices

TEST_TOOL_NAME += testWebServices
testWebServices_OBJC_FILES = testWebServices.m
testWebServices_TOOL_LIBS += -lWebServices
testWebServices_LIB_DIRS += -L./$(GNUSTEP_OBJ_DIR)

TEST_TOOL_NAME += testGWSJSONCoder
testGWSJSONCoder_OBJC_FILES = testGWSJSONCoder.m
testGWSJSONCoder_TOOL_LIBS += -lWebServices
testGWSJSONCoder_LIB_DIRS += -L./$(GNUSTEP_OBJ_DIR)

TEST_TOOL_NAME += testGWSSOAPCoder
testGWSSOAPCoder_OBJC_FILES = testGWSSOAPCoder.m
testGWSSOAPCoder_TOOL_LIBS += -lWebServices
testGWSSOAPCoder_LIB_DIRS += -L./$(GNUSTEP_OBJ_DIR)

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/test-tool.make
include $(GNUSTEP_MAKEFILES)/documentation.make

-include GNUmakefile.postamble

check::
	(cd tests; ./test)

