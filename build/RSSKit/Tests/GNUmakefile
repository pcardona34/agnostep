
include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS = -Wno-import

BUNDLE_NAME = RSSKitTests
RSSKitTests_OBJC_FILES= RSSKitTests.m RDFTests.m RSSTests.m
RSSKitTests_HEADER_FILES = RSSKitTests.h RDFTests.h RSSTests.h

ifeq ($(FOUNDATION_LIB), apple)
	RSSKitTests_OBJC_LIBS += -framework UnitKit -lRSSKit
else
	RSSKitTests_OBJC_LIBS = -lUnitKit -lRSSKit
endif

RSSKitTests_RESOURCE_FILES = \
Resources/tests/wellformed/rdf/rdf_channel_description.xml \
Resources/tests/wellformed/rdf/rdf_channel_title.xml \
Resources/tests/wellformed/rdf/rdf_channel_link.xml \
Resources/tests/wellformed/rdf/rdf_item_description.xml \
Resources/tests/wellformed/rdf/rdf_item_link.xml \
Resources/tests/wellformed/rdf/rdf_item_rdf_about.xml \
Resources/tests/wellformed/rdf/rdf_item_title.xml \
Resources/tests/wellformed/rss/channel_title.xml \
Resources/tests/wellformed/rss/channel_title_apos.xml \
Resources/tests/wellformed/rss/channel_title_gt.xml \
Resources/tests/wellformed/rss/channel_title_lt.xml \



include $(GNUSTEP_MAKEFILES)/bundle.make

 
