//
//  FSVarioMatrix.h
//  FlexiSheet
//
//  Created by Stefan Leuker on 05-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSVarioMatrix.h,v 1.1 2008/10/28 13:10:31 hns Exp $

#import <FSMatrix.h>

#define FSVM_WIDTH   1
#define FSVM_HEIGHT  2

typedef struct _CellArea {
    NSRange       range;
    float         offset;
    float         length;
    NSString     *label;
    /* FSCellStyle  *style */
} CellArea;


@interface FSVarioMatrix : FSMatrix {
}

@end


@protocol FSVarioMatrixDataSource <FSMatrixDataSource>
// Additional methods. 

- (NSRange)matrix:(FSVarioMatrix*)mx rowRangeForCell:(FSCell)cell;
- (NSRange)matrix:(FSVarioMatrix*)mx columnRangeForCell:(FSCell)cell;

- (float)matrix:(FSVarioMatrix*)mx xOffsetInCell:(FSCell)cell;
- (float)matrix:(FSVarioMatrix*)mx yOffsetInCell:(FSCell)cell;
- (int)matrix:(FSVarioMatrix*)mx additionalAreas:(CellArea**)areas inRow:(int)row;
- (int)matrix:(FSVarioMatrix*)mx additionalAreas:(CellArea**)areas inColumn:(int)col;

- (int)matrix:(FSVarioMatrix*)mx resizeMaskForCell:(FSCell)cell;

@end
