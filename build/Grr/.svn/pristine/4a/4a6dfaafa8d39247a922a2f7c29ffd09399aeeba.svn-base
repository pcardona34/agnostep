
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

SUBPROJECTS = \
	Components \


ifeq ($(warnings), yes)
ADDITIONAL_OBJCFLAGS += -W
ADDITIONAL_OBJCPPFLAGS += -W
ADDITIONAL_CFLAGS += -W
ADDITIONAL_CPPFLAGS += -W
endif
ifeq ($(allwarnings), yes)
ADDITIONAL_OBJCFLAGS += -Wall
ADDITIONAL_OBJCPPFLAGS += -Wall
ADDITIONAL_CFLAGS += -Wall
ADDITIONAL_CPPFLAGS += -Wall
endif


VERSION = 1.1
APP_NAME = Grr
PACKAGE_NAME = Grr

Grr_OBJC_FILES = \
AppController.m \
Article.m \
ArticleFactory.m \
Category.m \
Components.m \
Database.m \
DatabaseElement.m \
ExtendedWindow.m \
Feed.m \
GNRatingCell.m \
Grr_main.m \
ImageTextCell.m \
NSBundle+Extensions.m \
NSURL+Proxy.m \
NumberedImageTextCell.m \
PipeType.m \
PreferencesComponent.m \
PreferencesPanel.m \


Grr_C_FILES = 
Grr_RESOURCE_FILES = \
Resources/Icons/Category.tiff \
Resources/Icons/Database.tiff \
Resources/Icons/Feed.tiff \
Resources/Icons/FeedFetching.tiff \
Resources/Icons/Filter.tiff \
Resources/Icons/Star.tiff \
Resources/Icons/Link.tiff \
Resources/Icons/FetchFeed.tiff \
Resources/Icons/FetchFeeds.tiff \
Resources/Icons/PlainArticle.tiff \
Resources/Icons/ArticleLink.tiff \
Resources/Icons/DeleteArticle.tiff \
Resources/Icons/DeleteFeed.tiff \
Resources/Icons/DeleteCategory.tiff \
Resources/Icons/AddFeed.tiff \
Resources/Icons/AddCategory.tiff \
Resources/Icons/WebProxy.tiff \
Resources/Icons/Files/ArticleFile.tiff \
Resources/Icons/Files/FeedFile.tiff \
Resources/Icons/Application/Grr-Icon.tiff \
Resources/Icons/Application/Grr-Icon-NoConnection.tiff \
Resources/Icons/Application/Grr-Icon-Anim1.tiff \
Resources/Icons/Application/Grr-Icon-Anim2.tiff \
Resources/Icons/Application/Grr-Icon-Anim3.tiff \
Resources/UI/blue-badge-left.tiff \
Resources/UI/blue-badge-mid.tiff \
Resources/UI/blue-badge-right.tiff \
Resources/UI/arrowLeft.tiff \
Resources/UI/arrowRight.tiff \
Resources/UI/arrowUp.tiff \
Resources/UI/arrowDown.tiff \
Resources/Data/HTML-Entities.plist \

 
Grr_LANGUAGES = English German \

Grr_LOCALIZED_RESOURCE_FILES = \
Grr.gorm \
PreferencesPanel.gorm \

Grr_LOCALIZED_RESOURCE_FILES += Localizable.strings


Grr_MAIN_MODEL_FILE = Grr.gorm



# The usual makefile inclusion code
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble



