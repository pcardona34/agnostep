#
#  GNUMail Makefile for GNUstep
#
#  Copyright (C) 2001-2006 Ludovic Marcotte
#
#  Author: Ludovic Marcotte <ludovic@Sophos.ca>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = Viewing
BUNDLE_EXTENSION = .prefs

BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/GNUMail

Viewing_RESOURCE_FILES = viewing.tiff 3-pane_96x96.tiff drawer_96x96.tiff floating_96x96.tiff widescreen_96x96.tiff

Viewing_OBJC_FILES = \
	ViewingView.m \
	ViewingViewController.m \
	HeadersWindow.m \
	HeadersWindowController.m

Viewing_HEADERS = \
	ViewingView.h \
	ViewingViewController.h \
	HeadersWindow.h \
	HeadersWindowController.h

Viewing_PRINCIPAL_CLASS = \
	ViewingViewController

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import

ADDITIONAL_INCLUDE_DIRS += -I../../Framework/GNUMail
ADDITIONAL_LIB_DIRS += -L../../Framework/GNUMail/GNUMail.framework/Versions/Current/$(GNUSTEP_TARGET_LDIR)
ADDITIONAL_GUI_LIBS += -lGNUMail

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
