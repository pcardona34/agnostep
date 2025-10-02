#
#  UI
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
SUBPROJECT_NAME = UI

OBJCFLAGS += -Wall -I.. -I../.. -I../../FSCore -I../../Functions -I../../Operators -I../ChartView -I../Inspection

UI_OBJC_FILES = \
FSFormulaTable.m        FSTableView+Scrolling.m  SLCornerMenu.m \
FSHeaderDock.m          FSTableView+Selection.m  SLFloatingMark.m \
FSMatrix.m              FSTableView.m            SLOutlineView.m \
FSTableView+Keyboard.m  FSVarioMatrix.m          SLSplashScreen.m \
FSTableView+Layout.m    ImageAndTextCell.m

UI_HEADER_FILE = \
FSFormulaTable.h      FSTableView.h       SLFloatingMark.h \
FSHeaderDock.h        FSVarioMatrix.h     SLOutlineView.h \
FSMatrix.h            ImageAndTextCell.h  SLSplashScreen.h \
FSMatrixDataSource.h  SLCornerMenu.h

# The Resource files to be copied into the app's resources directory
UI_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble
