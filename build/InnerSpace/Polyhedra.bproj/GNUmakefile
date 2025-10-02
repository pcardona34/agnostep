#
#  Test apps makefile for GNUstep X/RAW GUI Backend
#
#  Copyright (C) 1997 Free Software Foundation, Inc.
#
#  Author: Scott Christley <scottc@net-community.com>
#  Author: Felipe A. Rodriguez <far@ix.netcom.com>
#
#  This file is part of the GNUstep X/RAW GUI Backend.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  If you are interested in a warranty or support for this source code,
#  contact Scott Christley at scottc@net-community.com
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; see the file COPYING.LIB.
#  If not, write to the Free Software Foundation,
#  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

Polyhedra_MAIN_MODEL_FILE = Polyhedra.gorm
Polyhedra_PRINCIPAL_CLASS = PolyhedraView

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
BUNDLE_NAME = Polyhedra
BUNDLE_EXTENSION = .InnerSpace

# The Objective-C source files to be compiled
Polyhedra_OBJC_FILES = PolyhedraView.m PolyhedraViewWraps.m
Polyhedra_PRINCIPAL_CLASS = PolyhedraView

# The Resource files to be copied into the bundle's resources directory
Polyhedra_RESOURCE_FILES = Polyhedra.gorm
Polyhedra_STANDARD_INSTALL=no

-include GNUmakefile.preamble

-include ../GNUmakefile.local

-include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
