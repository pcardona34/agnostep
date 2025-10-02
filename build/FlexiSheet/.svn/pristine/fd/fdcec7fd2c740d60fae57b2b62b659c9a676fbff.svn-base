#
#  Functions
#
#  Copyright (C) 2008 Free Software Foundation, Inc.
#
#   Written by: Fred Kiefer <FredKiefer@gmx.de>
#   Created: July 2008
#
#  This file is part of FlexiSheet.
#

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
SUBPROJECT_NAME = FSFunctions

OBJCFLAGS += -Wall -I.. -I../FSCore -I../Functions -I../Operators 

FSFunctions_OBJC_FILES = \
FSAbsFunction.m \
FSMaxFunction.m \
FSSqrtFunction.m \
FSCellnameFunction.m \
FSMinFunction.m \
FSStringFunction.m \
FSCorrelFunction.m \
FSPIFunction.m \
FSSumFunction.m \
FSCosFunction.m \
FSProdFunction.m \
FSTanFunction.m \
FSFinancialFunctions.m \
FSRandFunction.m \
FSTodayFunction.m \
FSIfFunction.m \
FSSignFunction.m \
FSLnFunction.m \
FSSinFunction.m

Functions_HEADER_FILE = \
FSAbsFunction.h \
FSMaxFunction.h \
FSSqrtFunction.h \
FSCellnameFunction.h \
FSMinFunction.h \
FSStringFunction.h \
FSCorrelFunction.h \
FSPIFunction.h \
FSSumFunction.h \
FSCosFunction.h \
FSProdFunction.h \
FSTanFunction.h \
FSFinancialFunctions.h \
FSRandFunction.h \
FSTodayFunction.h \
FSIfFunction.h \
FSSignFunction.h \
FSLnFunction.h \
FSSinFunction.h

# The Resource files to be copied into the app's resources directory
FSFunctions_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble
