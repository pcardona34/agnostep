#   GNUmakefile: main makefile for GNUstep Ink application
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
#
#   Author: Fred Kiefer <fredkiefer@gmx.de>
#   Date: 2000
#   
#   This file is part of GNUstep.
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME=gnustep-Ink
CVS_MODULE_NAME = gnustep/usr-apps/examples/gui/Ink
CVS_TAG_NAME=Ink
VERSION=1.0.0

APP_NAME = Ink
Ink_MAIN_MODEL_FILE = MainMenu.gorm

Ink_RESOURCE_FILES = \
  Ink_app.tiff \
  FileIcon_rtf.tiff \
  FileIcon_txt.tiff \
  Document.gorm \
  Ink_app.ico

Ink_LANGUAGES = English French

Ink_LOCALIZED_RESOURCE_FILES = \
MainMenu.gorm \
MainMenu_Localizable.strings \
InkInfo.plist

Ink_OBJC_FILES = \
  main.m \
  AppDelegate.m \
  Document.m

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble

