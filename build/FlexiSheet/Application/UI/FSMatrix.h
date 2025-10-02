//
//  FSMatrix.h
//  FlexiSheet
//
//  Created by Stefan Leuker on Mon Aug 27 2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSMatrix.h,v 1.1 2008/10/28 13:10:31 hns Exp $

#import <AppKit/AppKit.h>
#import <FSMatrixDataSource.h>


@interface FSMatrix : NSControl {
    id<FSMatrixDataSource> _dataSource; /*" where the data comes from "*/
    int               _numRows;         /*" number of rows, cached from DS "*/
    int               _numCols;         /*" number of columns, cached from DS "*/
    float            *_colWidths;       /*" column sizes, cached from DS "*/
    float            *_rowHeights;      /*" row sizes, cached from DS "*/
    BOOL              _isHeader;        /*" header matrix has different look "*/
    
    // Editing
    BOOL              _isEditing;       /*" is the field editor active? "*/
    FSCell            _editorCell;      /*" the cell that is being edited "*/
    BOOL              _vRezAllowed;     /*" vertical resizing of cells is allowed "*/
    BOOL              _hRezAllowed;     /*" horizontal resizing of cells is allowed "*/

    // Focus ring
    BOOL   shouldDrawFocusRing;
    id     lastResp;
}

- (NSRect)frameForRow:(int)row column:(int)col;
- (float)widthForColumn:(int)col;
- (float)heightForRow:(int)row;

- (void)reloadData;
- (void)reloadColumnWidthsInRange:(NSRange)columns;
- (void)reloadRowHeightsInRange:(NSRange)rows;

- (id<FSMatrixDataSource>)dataSource;
- (void)setDataSource:(id<FSMatrixDataSource>)dataSource;

- (BOOL)isHeaderMatrix;
- (void)setHeaderMatrix:(BOOL)flag;

- (int)numberOfRows;
- (int)numberOfColumns;

- (void)startEditingCell:(FSCell)cell withEvent:(NSEvent*)event;

// Mere private API

- (BOOL)_editCell:(FSCell)cell selectAll:(BOOL)select;
- (BOOL)_endEditing;

// Selection; mostly handled by the data source.
- (FSCell)cellAtPoint:(NSPoint)point;
- (FSCell)cellAtPoint:(NSPoint)point origin:(NSPoint*)origin;

@end

@interface NSObject (FSMatrixDelegate)

- (void)matrixDidBeginEditing:(FSMatrix*)matrix;
- (void)matrixDidEndEditing:(FSMatrix *)matrix;
- (void)matrixDidChangeSelection:(FSMatrix *)matrix;

@end
