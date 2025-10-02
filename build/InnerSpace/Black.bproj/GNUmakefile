#
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

# Black_MAIN_MODEL_FILE = Black.gmodel
Black_PRINCIPAL_CLASS = BlackView

include $(GNUSTEP_MAKEFILES)/common.make

#  include ../../Version

# The application to be compiled
BUNDLE_NAME = Black
BUNDLE_EXTENSION = .InnerSpace

# The Objective-C source files to be compiled
Black_OBJC_FILES = BlackView.m
Black_PRINCIPAL_CLASS = BlackView
Black_STANDARD_INSTALL = no

# The Resource files to be copied into the bundle's resources directory
# Black_RESOURCE_FILES = English.lproj/Black.gmodel

-include GNUmakefile.preamble

-include ../GNUmakefile.local

-include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
