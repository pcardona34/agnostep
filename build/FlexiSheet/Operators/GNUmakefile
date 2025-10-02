#
#  Operators
#
#  Copyright (C) 2008 Free Software Foundation, Inc.
#
#   Written by: Fred Kiefer <FredKiefer@gmx.de>
#   Created: August 2008
#
#  This file is part of FlexiSheet.
#

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
SUBPROJECT_NAME = FSOperators

OBJCFLAGS += -Wall -I.. -I../FSCore -I../Functions -I../Operators 

FSOperators_OBJC_FILES = \
FSCatOperator.m \
FSMinusOperator.m \
FSPowOperator.m \
FSDivideOperator.m \
FSMultiplyOperator.m \
FSEqualOperator.m \
FSPlusOperator.m

FSOperators_HEADER_FILE = \
FSCatOperator.h \
FSMinusOperator.h \
FSPowOperator.h \
FSDivideOperator.h \
FSMultiplyOperator.h \
FSEqualOperator.h \
FSPlusOperator.h

# The Resource files to be copied into the app's resources directory
FSOperators_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble
