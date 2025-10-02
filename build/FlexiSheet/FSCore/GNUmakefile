#
#  FSCore 
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
SUBPROJECT_NAME = FSCore

OBJCFLAGS += -Wall -I.. -I../Core -I../Function -I../Operators -I../Application -I../Application/ChartView -I../Application/Inspection -I../Application/UI 

FSCore_OBJC_FILES = FSConstant.m \
FSExpression.m \
FSExpressionError.m \
FSExpressionNegator.m \
FSExpressionParenthesis.m \
FSFormula.m \
FSFormulaDefinition.m \
FSFormulaSelection.m \
FSFormulaSpace.m \
FSFunction.m \
FSGlobalHeader.m \
FSHashMap.m \
FSHeader.m \
FSKey.m \
FSKeyGroup.m \
FSKeyRange.m \
FSKeySet.m \
FSLog.m \
FSOperator.m \
FSParserFunctions.m \
FSSelection.m \
FSTable+Find.m \
FSTable+Formula.m \
FSTable.m \
FSUnit.m \
FSValue.m \
FSVariable.m \
FoundationExtentions.m


FSCore_HEADER_FILE = FSConstant.h \
FSCore.h \
FSDocumentProtocol.h \
FSExpression.h \
FSExpressionError.h \
FSExpressionNegator.h \
FSExpressionParenthesis.h \
FSFormula.h \
FSFormulaDefinition.h \
FSFormulaSelection.h \
FSFormulaSpace.h \
FSFunction.h \
FSGlobalHeader.h \
FSHashMap.h \
FSHeader.h \
FSKey.h \
FSKeyGroup.h \
FSKeyRange.h \
FSKeySet.h \
FSLog.h \
FSOperator.h \
FSParserFunctions.h \
FSSelection.h \
FSTable.h \
FSTypes.h \
FSUnit.h \
FSValue.h \
FSVariable.h \
FoundationExtentions.h


# The Resource files to be copied into the app's resources directory
FSCore_RESOURCE_FILES = 

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble
