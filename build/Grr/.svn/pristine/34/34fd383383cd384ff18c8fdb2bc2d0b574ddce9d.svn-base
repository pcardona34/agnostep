
include $(GNUSTEP_MAKEFILES)/common.make

# View Providing Components
SUBPROJECTS = \
	ArticleTable \
	ArticleView \
	DatabaseTreeView \

# Mostly independent components with preference panels
SUBPROJECTS += \
	Proxy \
	Fonts \

# Database components
SUBPROJECTS += \
	TreeDatabase \

# Operation components (Menu entries and toolbar delegates)
SUBPROJECTS += \
	DatabaseOperations \
	ArticleOperations \

# Mixed stuff
SUBPROJECTS += \
	SubscriptionPanel \
	Searching \


include $(GNUSTEP_MAKEFILES)/aggregate.make


ADDITIONAL_INCLUDE_DIRS += -I../../../../libs/
ADDITIONAL_LIB_DIRS += -L../../../../libs/RSSKit/RSSKit.framework/