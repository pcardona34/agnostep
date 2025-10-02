include $(GNUSTEP_MAKEFILES)/common.make

-include config.make

NEEDS_GUI = NO

TEST_TOOL_NAME=

ifeq ($(OBJC_RUNTIME_LIB),gnu)
APPLE=0
else
APPLE=1
endif

ifeq ($(APPLE),1)
ADDITIONAL_OBJC_LIBS += -lgnustep-baseadd
WebServer_LIBRARIES_DEPEND_UPON = -lgnustep-baseadd
endif

TEST_TOOL_NAME+=client
client_OBJC_FILES = client.m
client_TOOL_LIBS += -lWebServices
client_LIB_DIRS += -L../$(GNUSTEP_OBJ_DIR)

TEST_TOOL_NAME+=server
server_OBJC_FILES = server.m
server_TOOL_LIBS += -lWebServer -lWebServices
server_LIB_DIRS += -L../$(GNUSTEP_OBJ_DIR)

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/test-tool.make

-include GNUmakefile.postamble
