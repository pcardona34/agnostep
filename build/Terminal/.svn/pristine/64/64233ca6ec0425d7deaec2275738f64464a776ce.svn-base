# copyright 2002-2003 Alexander Malmberg <alexander@malmberg.org>
# copyright 2008-2018 Riccardo Mottola
#
# This file is a part of Terminal.app. Terminal.app is free software; you
# can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation; version 2
# of the License. See COPYING or main.m for more information.

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

APP_NAME = Terminal
PACKAGE_NAME = Terminal
VERSION = 0.9.9


# Useful warnings:
#	-W -Wformat=2 -Wno-sign-compare -Wpointer-arith \
#	-Wbad-function-cast -Wcast-align -Wwrite-strings -Wstrict-prototypes \
#	-Wmissing-prototypes -Wmissing-declarations \
#	-Wnested-externs -Wno-unused-parameter

Terminal_OBJC_FILES = \
	main.m \
	\
	Services.m \
	ServicesPrefs.m \
	ServicesParameterWindowController.m \
	\
	TerminalWindow.m \
	TerminalWindowPrefs.m \
	\
	StringClasses.m \
	TerminalView.m \
	TerminalViewPrefs.m \
	\
	TerminalParser_Linux.m \
	TerminalParser_LinuxPrefs.m \
	\
	PreferencesWindowController.m \
	autokeyviewchain.m \
	\
	Label.m



ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
 Terminal_TOOL_LIBS += -liconv
else

ifeq ($(findstring freebsd, $(GNUSTEP_TARGET_OS)), freebsd)
# Exclude GNU/kFreeBSD (kfreebsd-gnu) where iconv is part of glibc.
ifeq ($(findstring gnu, $(GNUSTEP_TARGET_OS)),)
 Terminal_TOOL_LIBS += -liconv 
endif
endif

 Terminal_TOOL_LIBS += -lutil
endif

ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
 Terminal_TOOL_LIBS += -liconv
endif

Terminal_LOCALIZED_RESOURCE_FILES = Localizable.strings
Terminal_LANGUAGES = English Swedish German French Spanish Hungarian Turkish Norwegian Russian Italian Japanese

Terminal_APPLICATION_ICON = Terminal.tiff
Terminal_RESOURCE_FILES = \
	Resources/Terminal.tiff \
	Resources/DefaultTerminalServices.svcs \
	Resources/cursor_line.tiff \
	Resources/cursor_stroked.tiff \
	Resources/cursor_filled.tiff \
	Resources/cursor_inverted.tiff \
	TerminalInfo.plist

MAKE_STRINGS_OPTIONS = --aggressive-match --aggressive-remove



include $(GNUSTEP_MAKEFILES)/application.make

