//
//  FSMatrixDataSource.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 09-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSMatrixDataSource.h,v 1.1 2008/10/28 13:10:31 hns Exp $


typedef struct _FSCell {
    long    row;
    long    column;
    float   dx;
    float   dy;
} FSCell;

static inline FSCell FSMakeCell(int row, int col) {
    FSCell cell;
    cell.row = row;
    cell.column = col;
    cell.dx = 0;
    cell.dy = 0;
    return cell;
}

typedef enum _FSLineStyle {
    FSNormalLine   = 0,
    FSDashedLine   = 1,
    FSDoubleLine   = 2,
    FSBigFatLine   = 3
} FSLineStyle;

@class FSMatrix, FSCellStyle;

@protocol FSMatrixDataSource <NSObject>

//
// Matrix size and data
//
- (int)numberOfRowsInMatrix:(FSMatrix*)mx;
/*" Must return the number of rows. "*/

- (int)numberOfColumnsInMatrix:(FSMatrix*)mx;
/*" Must return the number of columns. "*/

- (id)matrix:(FSMatrix*)mx objectValueForCell:(FSCell)cell;
- (FSCellStyle*)matrix:(FSMatrix*)mx styleForCell:(FSCell)cell;
- (FSLineStyle)matrix:(FSMatrix*)mx lineStyleForRow:(long)row;
- (FSLineStyle)matrix:(FSMatrix*)mx lineStyleForColumn:(long)column;
- (void)matrix:(FSMatrix*)mx setObjectValue:(id)object forCell:(FSCell)cell;

//
// Cell size
//
- (NSSize)matrix:(FSMatrix*)mx sizeForCell:(FSCell)cell;
- (NSSize)matrix:(FSMatrix*)mx setSize:(NSSize)size forCell:(FSCell)cell;

//
// Selection
//
- (FSCell)matrix:(FSMatrix*)mx selectCell:(FSCell)cell extendExistingSelection:(BOOL)extend;
- (void)matrix:(FSMatrix*)mx selectFromCell:(FSCell)c1 toCell:(FSCell)c2 extendExistingSelection:(BOOL)extend;
- (BOOL)matrix:(FSMatrix*)mx cellIsSelected:(FSCell)cell;
- (FSCell)matrixSelectedCell:(FSMatrix*)mx;

//
// Editing
//
- (BOOL)matrix:(FSMatrix*)mx shouldEditCell:(FSCell)cell;
- (void)matrix:(FSMatrix*)mx willChangeWidthOfCell:(FSCell)cell;
- (void)matrix:(FSMatrix*)mx willChangeHeightOfCell:(FSCell)cell;

//
// First Responder
// called to determine whether the Matrix should draw with focus.
// eg. when editing a formula, clicking a cell does not change FR.
//
- (BOOL)matrixShouldBecomeFirstResponder:(FSMatrix*)mx;

@end

