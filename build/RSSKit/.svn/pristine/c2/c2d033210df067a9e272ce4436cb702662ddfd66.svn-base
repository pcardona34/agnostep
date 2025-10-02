
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

# Compile with gmake coverage=yes, if you want to have coverage analysis output
ifeq ($(coverage), yes)
ADDITIONAL_FLAGS += -fprofile-arcs -ftest-coverage
ADDITIONAL_OBJC_LIBS += -lgcov
endif

srcdir = .
VERSION = 0.5
PACKAGE_NAME = RSSKit
INTERFACE_VERSION = 0

# The library to be compiled
FRAMEWORK_NAME = RSSKit

# Additional libraries
RSSKit_LIBRARIES_DEPEND_UPON += $(OBJC_LIBS) $(FND_LIBS)

# The Objective-C source files to be compiled
RSSKit_OBJC_FILES = \
	RSSArticle.m \
	RSSArticle+Storage.m \
	RSSFeed.m \
	RSSFeed+Fetching.m \
	RSSFeed+Storage.m \
	DublinCore.m \
	DOMParser.m \
	FeedParser.m \
	RSS10Parser.m \
	RSS20Parser.m \
	AtomParser.m \
	Atom03Parser.m \
	Atom10Parser.m \
	RSSArticleCreationListener.m \
	RSSFactory.m \
	RSSLinks.m 

RSSKit_HEADER_FILES = \
	RSSArticle.h \
	RSSArticle+Storage.h \
	RSSArticleProtocol.h \
	RSSFeed.h \
	RSSFeedProtocol.h \
	RSSFeed+Fetching.h \
	RSSFeed+Storage.h \
	DublinCore.h \
	RSSKit.h \
	DOMParser.h \
	FeedParser.h \
	RSS10Parser.h \
	RSS20Parser.h \
	AtomParser.h \
	Atom03Parser.h \
	Atom10Parser.h \
	RSSArticleCreationListener.h \
	NewRSSArticleListener.h \
	RSSFactory.h \
	RSSLinks.h 

RSSKit_HEADER_FILES_DIR = .

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/framework.make

-include GNUmakefile.preamble
-include GNUmakefile.local
-include GNUmakefile.postamble

