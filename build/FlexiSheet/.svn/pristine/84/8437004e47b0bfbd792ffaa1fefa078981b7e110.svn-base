#
#  Inspection
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
SUBPROJECT_NAME = Inspection

OBJCFLAGS += -Wall -I.. -I../.. -I../../FSCore -I../../Functions -I../../Operators -I../ChartView -I../UI

Inspection_OBJC_FILES = \
FSCellInspectorPane.m      FSItemInspectorPane.m \
FSDocumentInspectorPane.m  FSMultipleSelectionInspectorPane.m \
FSInspection.m             FSNoSelectionInspectorPane.m \
FSInspector.m              FSTableInspectorPane.m \
FSInspectorPane.m          FSViewInspectorPane.m

Inspection_HEADER_FILE = \
FSCellInspectorPane.h      FSItemInspectorPane.h \
FSDocumentInspectorPane.h  FSMultipleSelectionInspectorPane.h \
FSInspection.h             FSNoSelectionInspectorPane.h \
FSInspector.h              FSTableInspectorPane.h \
FSInspectorPane.h          FSViewInspectorPane.h

# The Resource files to be copied into the app's resources directory
Inspection_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

