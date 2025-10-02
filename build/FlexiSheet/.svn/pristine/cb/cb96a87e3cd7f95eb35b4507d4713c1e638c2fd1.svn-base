#
#  Application
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
SUBPROJECT_NAME = Application

OBJCFLAGS += -Wall -I.. -I../FSCore -I../Functions -I../Operators -IUI -IChartView -IInspection

Application_SUBPROJECTS = \
UI \
ChartView \
Inspection

Application_OBJC_FILES = \
FSArchiving.m \
FSImporter.m \
FSCellStyle.m \
FSPasteboardHandling.m \
FSController.m \
FSPreferences.m \
FSDocument+Printing.m \
FSSortPanelController.m \
FSDocument+Quantrix.m \
FSTableController+Formula.m \
FSDocument+Scripting.m \
FSTableController+Toolbar.m \
FSDocument.m \
FSTableController.m \
FSExporter.m \
FSTableTabs.m \
FSFunctionHelp.m \
FSWindowController.m \
FSGraffleExport.m \
FSWorksheet.m \
FSHeaderLayout.m \
main.m

Application_HEADER_FILE = \
FSArchiving.h       FSFunctionHelp.h        FSSortPanelController.h \
FSCellStyle.h       FSGraffleExport.h       FSTableController.h \
FSController.h      FSHeaderLayout.h        FSTableTabs.h \
FSDocument.h        FSImporter.h            FSWindowController.h \
FSExporter.h        FSPasteboardHandling.h  FSWorksheet.h \
FSFirstResponder.h  FSPreferences.h         FlexiSheet.h

# The Resource files to be copied into the app's resources directory
Application_HAS_RESOURCE_BUNDLE = yes

Application_RESOURCE_FILES = 

Application_LANGUAGES = English German

Application_LOCALIZED_RESOURCE_FILES = \
Credits.rtf                   ItemInspector.nib \
DocumentInspector.nib         Localizable.strings \
Export.nib                    MainMenu.nib \
FSChart.nib                   MultipleSelectionInspector.nib \
FSTable.nib                   NoSelectionInspector.nib \
FlexiSheet.scriptTerminology  Preferences.nib \
Functions.nib                 SortingItems.nib \
Import.nib                    Styles.nib \
InfoPlist.strings             TableInspector.nib \
Inspector.nib                 ViewInspector.nib

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble
