#
#  ChartView
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
SUBPROJECT_NAME = ChartView

OBJCFLAGS += -Wall -I.. -I../.. -I../../Core -I../../Functions -I../../Operators -I../UI -I../Inspection

ChartView_OBJC_FILES = \
FSChartController.m \
FSChartView.m

ChartView_HEADER_FILE = \
FSChartController.h \
FSChartView.h

# The Resource files to be copied into the app's resources directory
ChartView_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

