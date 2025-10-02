//
//  FSTableController.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 31-JAN-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableController.h,v 1.1 2008/10/14 15:03:47 hns Exp $

#import "FSWindowController.h"

@class FSTable, FSFormulaTable;

@interface FSTableController : FSWindowController {
    IBOutlet FSFormulaTable *formulaTable;
    IBOutlet NSSplitView    *splitView;
    
    NSTableColumn           *_numberColumn;
    int                      _storedSplitPosition;
}

- (int)formulaSplitPosition;
- (void)setFormulaSplitPosition:(int)pos;

- (void)toggleFormulaArea:(id)unused;

@end

@interface FSTableController (FormulaEditing)

- (void)addFormula:(id)sender;
- (void)insertFormula:(id)sender;
- (void)deleteFormula:(id)sender;

@end

@interface FSTableController (ToolbarDelegate)

- (void)setupTableToolbar;
- (void)setupFormulaToolbar;

@end
