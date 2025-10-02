#
#  GNUMail Framework Makefile for GNUstep
#
#  Copyright (C) 2001-2006 Ludovic Marcotte
#                2015-2018 Riccardo Mottola
#
#  Author: Ludovic Marcotte <ludovic@Sophos.ca>
#          Riccardo Mottola <rm@gnu.org>
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

FRAMEWORK_NAME = GNUMail

GNUMAIL_MAJOR_VERSION=1
GNUMAIL_MINOR_VERSION=4
GNUMAIL_SUBMINOR_VERSION=0
GNUMAIL_VERSION=${GNUMAIL_MAJOR_VERSION}.${GNUMAIL_MINOR_VERSION}.${GNUMAIL_SUBMINOR_VERSION}
VERSION=${GNUMAIL_VERSION}

GNUMail_OBJC_FILES = \
	GSProgressIndicator.m \
	AboutPanelController.m \
	AddressBookController.m \
	AddressBookPanel.m \
	ApplicationIconController.m \
	AutoCompletingTextField.m \
	ConsoleWindowController.m \
	Constants.m \
	ExtendedCell.m \
	ExtendedFileWrapper.m \
	ExtendedMenuItem.m \
	ExtendedTableView.m \
	ExtendedTextAttachmentCell.m \
	ExtendedTextView.m \
	ExtendedOutlineView.m \
	ExtendedWindow.m \
	EditWindowController.m \
	EditWindowToolbar.m \
	Filter.m \
	FilterManager.m \
	FindWindowController.m \
	FolderNode.m \
	FolderNodePopUpItem.m \
	GNUMail.m \
	GNUMail+Extensions.m \
	GNUMail+MenuValidation.m \
	GNUMail+Services.m \
	ImageTextCell.m \
	LabelWidget.m \
	MailboxInspectorPanel.m \
	MailboxInspectorPanelController.m \
	MailboxManager.m \
	MailboxManagerCache.m \
	MailboxManagerController.m \
	MailboxManagerToolbar.m \
	MailHeaderCell.m \
	MailWindowController.m \
	MailWindowToolbar.m \
	MessageViewWindow.m \
	MessageViewWindowController.m \
	MessageViewWindowToolbar.m \
	MimeType.m \
	MimeTypeManager.m \
	NavigationToolbarItem.m \
	NewMailboxPanelController.m \
	NSAttributedString+Extensions.m \
	NSAttributedString+TextEnriched.m \
	NSBezierPath+Extensions.m \
	NSBundle+Extensions.m \
	NSColor+Extensions.m \
	NSFont+Extensions.m \
	NSPasteboard+Extensions.m \
	NSUserDefaults+Extensions.m \
	PasswordPanelController.m \
	PreferencesWindowController.m \
	STScriptingSupport.m \
	Task.m \
	TaskManager.m \
	ThreadArcsCell.m \
	Utilities.m \
	WelcomePanel.m

GNUMail_LIB_DIRS = -L../$(GNUSTEP_LIBRARIES_ROOT)
LIBRARIES_DEPEND_UPON = $(OBJC_LIBS) $(FND_LIBS) $(GUI_LIBS) -lPantomime \
			  -lAddresses -lAddressView -lm
ADDITIONAL_INCLUDE_DIRS = -I.

# We want to get all the warnings... 
ADDITIONAL_OBJCFLAGS += -Wall -Wno-import -I/usr/kerberos/include -I/usr/local/ssl/include

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
ADDITIONAL_GUI_LIBS += -lregex -liconv
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/framework.make
