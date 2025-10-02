//
//  FSVarioMatrix.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 05-SEP-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//                2012 Free Software Foundation
//  Authors: Stefan Leuker, Riccardo Mottola
//
//  $Id: FSVarioMatrix.m,v 1.4 2012/02/06 23:40:40 rmottola Exp $

#import "FlexiSheet.h"

@interface FSMatrix (Private)

- (float)_originAtColumn:(int)col;
- (float)_originAtRow:(int)row;

@end

@implementation FSVarioMatrix

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hRezAllowed = YES;
        _vRezAllowed = YES;
    }
    return self;
}


- (void)setDataSource:(id<FSMatrixDataSource>)dataSource
{
  if ([dataSource conformsToProtocol:@protocol(FSVarioMatrixDataSource)] == NO)
    {
      [FSLog logError:@"FSVarioMatrix dataSource requires an extended protocol!"];
    }
  else
    {
      [super setDataSource:dataSource];
    }
}


- (NSRect)_editorFrameForCell:(FSCell)cell
/*" Overwritten to return the cell area minus additional area space,
    or the additional area if the dx/dy information tells us so.
    "*/
{
    id<FSVarioMatrixDataSource> datasrc = (id<FSVarioMatrixDataSource>)_dataSource;
    
    NSRect   frame;
    float    xOffset = [datasrc matrix:self xOffsetInCell:cell];
    float    yOffset = [datasrc matrix:self yOffsetInCell:cell];


    if ((cell.dx >= xOffset) && (cell.dy >= yOffset)) {
        // It is the key we want to edit.
        frame = [self frameForRow:cell.row column:cell.column];
        if (xOffset > 0) {
            frame.origin.x += xOffset;
            frame.size.width -= xOffset;
        }
        if (yOffset > 0) {
            frame.origin.y += yOffset;
            frame.size.height -= yOffset;
        }
    } else {
        // look in additional areas for the chosen one.
        CellArea  *areas;
        int        count;
        int        length;
        BOOL       found = NO;
                
        // For column:
        count = [datasrc matrix:self additionalAreas:&areas inColumn:cell.column];
        while ((count-- > 0) && !found) {
            if (NSLocationInRange(cell.row, areas[count].range)) {
                if ((cell.dx >= areas[count].offset)
                && (cell.dx < areas[count].offset + areas[count].length)) {
                    frame = [self frameForRow:areas[count].range.location column:cell.column];
                    frame.origin.x = areas[count].offset;
                    frame.size.width = areas[count].length;
                    length = areas[count].range.length;
                    frame.size.height = 0;
                    while (length-- > 0) {
                        frame.size.height += _rowHeights[areas[count].range.location+length];
                    }
                    found = YES;
                }
            }
        }
        
        // For row:
        count = [datasrc matrix:self additionalAreas:&areas inRow:cell.row];
        while ((count-- > 0) && !found) {
            if (NSLocationInRange(cell.column, areas[count].range)) {
                if ((cell.dy >= areas[count].offset)
                && (cell.dy < areas[count].offset + areas[count].length)) {
                    frame = [self frameForRow:cell.row column:areas[count].range.location];
                    frame.origin.y = areas[count].offset;
                    frame.size.height = areas[count].length;
                    length = areas[count].range.length;
                    frame.size.width = 0;
                    while (length-- > 0) {
                        frame.size.width += _colWidths[areas[count].range.location+length];
                    }
                    found = YES;
                }
            }
        }
    }
    
    return frame;
}


- (void)drawRect:(NSRect)rect
/*" FSVarioMatrix can draw cells that span multiple rows or columns.
    "*/
{
    id<FSVarioMatrixDataSource> datasrc = (id<FSVarioMatrixDataSource>)_dataSource;
    int                  row, col;
    NSRect               frame = {{0,0},{0,0}};
    NSRect               drawframe;
    NSRect               lineframe;
    FSCellStyle         *cellStyle;
    NSRange              colspan, rowspan;
    BOOL                 _primary = ([[self window] firstResponder] == self);
    FSCell               cell = {0};
    int                  offset;
    NSColor             *primaryColor = [NSColor selectedControlColor];
    NSColor             *secondaryColor = [NSColor secondarySelectedControlColor];
    
    if (_isHeader) {
        [[NSColor headerColor] set];
    } else {
        [[NSColor textBackgroundColor] set];
    }
    NSRectFill(rect);
    
    // Draw cell contents
    
    for (row = 0; row < _numRows; row++) {
        frame.origin.x = 0;
        frame.size.height = _rowHeights[row];
        
        for (col = 0; col < _numCols; col++) {
            cell = FSMakeCell(row,col);
            frame.size.width = _colWidths[col];
            
            rowspan = [datasrc matrix:self rowRangeForCell:cell];
            colspan = [datasrc matrix:self columnRangeForCell:cell];
            if ((rowspan.location == row) && (colspan.location == col)) {
                drawframe = frame;
                while (rowspan.length-- > 1) {
                    drawframe.size.height += _rowHeights[row+rowspan.length];
                }
                while (colspan.length-- > 1) {
                    drawframe.size.width += _colWidths[col+colspan.length];
                }
                if (NSIntersectsRect(drawframe, rect)) {
                    offset = [datasrc matrix:self xOffsetInCell:cell];
                    if (offset > 0) {
                        drawframe.origin.x += offset;
                        drawframe.size.width -= offset;
                        cell.dx = offset;
                    }
                    offset = [datasrc matrix:self yOffsetInCell:cell];
                    if (offset > 0) {
                        drawframe.origin.y += offset;
                        drawframe.size.height -= offset;
                        cell.dy = offset;
                    }
                    if (NSIntersectsRect(drawframe, rect)) {
                        // Draw cell
                        FSValue *val = [datasrc matrix:self objectValueForCell:cell];
                        BOOL     isSelection = [datasrc matrix:self cellIsSelected:cell];
                        FSLineStyle ls;

                        if (isSelection) {
                            if (_primary) {
                                [primaryColor set];
                            } else {
                                [secondaryColor set];
                            }
                            NSRectFill(drawframe);
                        }

                        cellStyle = [datasrc matrix:self styleForCell:cell];
                        [[val description] drawInRect:NSInsetRect(drawframe,8,2)
                                       withAttributes:[cellStyle textAttributes]];
                        // Draw right line
                        ls = [datasrc matrix:self lineStyleForColumn:col];
                        [[NSColor blackColor] set];
                        lineframe.origin = drawframe.origin;
                        lineframe.origin.x += drawframe.size.width-1;
                        lineframe.size.width = 1;
                        lineframe.size.height = drawframe.size.height;
                        switch (ls) {
                            case FSBigFatLine:
                                lineframe.origin.x -= 1;
                                lineframe.size.width += 1;
                                NSFrameRect(lineframe);
                                break;
                            case FSDoubleLine:
                                lineframe.origin.x -= 2;
                                NSFrameRect(lineframe);
                                lineframe.origin.x += 2;
                                // Fall through
                            case FSNormalLine:
                            default:
                                NSFrameRect(lineframe);
                        }
                        // Draw bottom line
                        ls = [datasrc matrix:self lineStyleForRow:row];
                        lineframe.origin = drawframe.origin;
                        lineframe.origin.y += drawframe.size.height-1;
                        lineframe.size.width = drawframe.size.width;
                        lineframe.size.height = 1;
                        switch (ls) {
                            case FSBigFatLine:
                                lineframe.origin.y -= 1;
                                lineframe.size.height += 1;
                                NSFrameRect(lineframe);
                                break;
                            case FSDoubleLine:
                                lineframe.origin.y -= 2;
                                NSFrameRect(lineframe);
                                lineframe.origin.y += 2;
                                // Fall through
                            case FSNormalLine:
                            default:
                                NSFrameRect(lineframe);
                        }
                    }
                }
            }
            frame.origin.x += frame.size.width;
        }
        frame.origin.y += frame.size.height;
    }
    // All regular cells are drawn
    // Now for the additional areas:
    //
    {
        CellArea  *areas;
        int        count;
        int        mult;
        int        mmax;
        float      moff;
        int        length;
        NSColor   *blackColor = [NSColor blackColor];
        
        col = _numCols;
        while (col-- > 0) {
            count = [datasrc matrix:self additionalAreas:&areas inColumn:col];
            cell.column = col;
            while (count-- > 0) {
                moff = 0;
                if (col > 0) {
                    rowspan = [datasrc matrix:self rowRangeForCell:FSMakeCell(0, col-1)];
                    mmax = [datasrc numberOfRowsInMatrix:self]/rowspan.length;
                    while (rowspan.length-- > 0) {
                        moff += _rowHeights[rowspan.length];
                    }
                } else {
                    mmax = 1;
                }
                for (mult = 0; mult < mmax; mult++) {
                    cell.row = areas[count].range.location;
                    frame = [self frameForRow:cell.row column:col];
                    frame.origin.x += areas[count].offset;
                    frame.origin.y += mult*moff;
                    frame.size.width = areas[count].length;
                    cell.dx = areas[count].offset;
                    length = areas[count].range.length;
                    frame.size.height = 0;
                    while (length-- > 0) {
                        frame.size.height += _rowHeights[areas[count].range.location+length];
                    }

                    if ([datasrc matrix:self cellIsSelected:cell]) {
                        if (_primary) {
                            [primaryColor set];
                        } else {
                            [secondaryColor set];
                        }
                        NSRectFill(frame);
                    }
                    cellStyle = [datasrc matrix:self styleForCell:cell];
                    [areas[count].label drawInRect:NSInsetRect(frame,8,2)
                                    withAttributes:[cellStyle textAttributes]];
                    [blackColor set];
                    lineframe.origin = frame.origin;
                    lineframe.origin.x += frame.size.width-1;
                    lineframe.size.width = 1;
                    lineframe.size.height = frame.size.height;
                    NSFrameRect(lineframe);
                    lineframe.origin = frame.origin;
                    lineframe.origin.y += frame.size.height-1;
                    lineframe.size.width = frame.size.width;
                    lineframe.size.height = 1;
                    NSFrameRect(lineframe);
                }
            }
        }

        row = _numRows;
        while (row-- > 0) {
            count = [datasrc matrix:self additionalAreas:&areas inRow:row];
            cell.row = row;
            while (count-- > 0) {
                moff = 0;
                if (row > 0) {
                    colspan = [datasrc matrix:self columnRangeForCell:FSMakeCell(row-1, 0)];
                    mmax = [datasrc numberOfColumnsInMatrix:self]/colspan.length;
                    while (colspan.length-- > 0) {
                        moff += _colWidths[colspan.length];
                    }
                } else {
                    mmax = 1;
                }
                for (mult = 0; mult < mmax; mult++) {
                    cell.column = areas[count].range.location;
                    frame = [self frameForRow:row column:cell.column];
                    frame.origin.x += mult*moff;
                    frame.origin.y += areas[count].offset;
                    frame.size.height = areas[count].length;
                    cell.dy = areas[count].offset;
                    length = areas[count].range.length;
                    frame.size.width = 0;
                    while (length-- > 0) {
                        frame.size.width += _colWidths[areas[count].range.location+length];
                    }

                    if ([datasrc matrix:self cellIsSelected:cell]) {
                        if (_primary) {
                            [primaryColor set];
                        } else {
                            [secondaryColor set];
                        }
                        NSRectFill(frame);
                    }
                    cellStyle = [datasrc matrix:self styleForCell:cell];
                    [areas[count].label drawInRect:NSInsetRect(frame,8,2)
                                    withAttributes:[cellStyle textAttributes]];
                    [blackColor set];
                    lineframe.origin = frame.origin;
                    lineframe.origin.x += frame.size.width-1;
                    lineframe.size.width = 1;
                    lineframe.size.height = frame.size.height;
                    NSFrameRect(lineframe);
                    lineframe.origin = frame.origin;
                    lineframe.origin.y += frame.size.height-1;
                    lineframe.size.width = frame.size.width;
                    lineframe.size.height = 1;
                    NSFrameRect(lineframe);
                }
            }
        }
    }
    
    // If we are editing, draw the focus ring
    if (_isEditing) {
        frame = [self _editorFrameForCell:_editorCell];
        frame.size.width -= 1;
        frame.size.height -= 1;
        [[NSColor keyboardFocusIndicatorColor] set];
        NSFrameRectWithWidth(frame, 2);
    }
    
    // and once again frame the whole matrix area
    [[NSColor blackColor] set];
    NSFrameRect([self bounds]);
}

- (void)resetCursorRects
/*" The beefed-up version. "*/
{
    id<FSVarioMatrixDataSource> datasrc = (id<FSVarioMatrixDataSource>)_dataSource;
    int       row, col, l;

    int       flags;
    FSCell    cell;

    if (datasrc == nil)
      return;

    if (_hRezAllowed || _vRezAllowed)
      {
	float     x = 0, y = 0, w, h;
	NSRange   rr, cr;
	float     ox, oy;
	NSRect    visible;
	float     maxX;
	float     maxY;

        //
        // As this is done regularly, we get away with creating
        // rects only for the visible part of the view.
        //
        NSCursor *hResizeCursor = [[NSCursor alloc]
            initWithImage:[NSImage imageNamed:@"HorzResizeCursor"]
            hotSpot:NSMakePoint(8,8)];
        NSCursor *vResizeCursor = [[NSCursor alloc]
            initWithImage:[NSImage imageNamed:@"VertResizeCursor"]
            hotSpot:NSMakePoint(8,8)];

	visible = [self visibleRect];
	maxX = visible.origin.x + visible.size.width;
	maxY = visible.origin.y + visible.size.height;

        for (row = 0; row < _numRows; row++) {
            if ((y >= visible.origin.y) && (y <= maxY)) {
                x = 0;
                for (col = 0; col < _numCols; col++) {
                    if ((x >= visible.origin.x) && (x <= maxX)) {
                        cell = FSMakeCell(row,col);
                        rr = [datasrc matrix:self rowRangeForCell:cell];
                        cr = [datasrc matrix:self columnRangeForCell:cell];
                        flags = [datasrc matrix:self resizeMaskForCell:cell];
                        if ((cr.location == col) && (rr.location == row) && flags) {
                            ox = [datasrc matrix:self xOffsetInCell:cell];
                            oy = [datasrc matrix:self yOffsetInCell:cell];
                            w = 0;
                            l = cr.length;
                            while (l-- > 0) {
                                w += _colWidths[col+l];
                            }

                            h = 0;
                            l = rr.length;
                            while (l-- > 0) {
                                h += _rowHeights[row+l];
                            }
                            if (flags & FSVM_HEIGHT)
                                [self addCursorRect:NSMakeRect(x+ox,y+h-2,w,2)
                                             cursor:vResizeCursor];
                            if (flags & FSVM_WIDTH)
                                [self addCursorRect:NSMakeRect(x+w-2,y+oy,2,h)
                                             cursor:hResizeCursor];
                        }
                    }
                    x += _colWidths[col];
                }
            }
            y += _rowHeights[row];
        }
        // Add cursors for additional lines in grouped areas
        {
            CellArea  *areas;
            int        count;
            int        mult;
            int        mmax;
            float      moff;
            int        length;
            NSRange    rowspan, colspan;
            NSRect     frame, lineframe;

            col = _numCols;
            while (col-- > 0) {
                count = [datasrc matrix:self additionalAreas:&areas inColumn:col];
                cell.column = col;
                while (count-- > 0) {
                    moff = 0;
                    if (col > 0) {
                        rowspan = [datasrc matrix:self rowRangeForCell:FSMakeCell(0, col-1)];
                        mmax = [datasrc numberOfRowsInMatrix:self]/rowspan.length;
                        while (rowspan.length-- > 0) {
                            moff += _rowHeights[rowspan.length];
                        }
                    } else {
                        mmax = 1;
                    }
                    for (mult = 0; mult < mmax; mult++) {
                        cell.row = areas[count].range.location;
                        frame = [self frameForRow:cell.row column:col];
                        frame.origin.x += areas[count].offset;
                        frame.origin.y += mult*moff;
                        frame.size.width = areas[count].length;
                        cell.dx = areas[count].offset;
                        length = areas[count].range.length;
                        frame.size.height = 0;
                        while (length-- > 0) {
                            frame.size.height += _rowHeights[areas[count].range.location+length];
                        }
                        lineframe.origin = frame.origin;
                        lineframe.origin.x += frame.size.width-1;
                        lineframe.size.width = 1;
                        lineframe.size.height = frame.size.height;
                        [self addCursorRect:lineframe cursor:hResizeCursor];
                        lineframe.origin = frame.origin;
                        lineframe.origin.y += frame.size.height-1;
                        lineframe.size.width = frame.size.width;
                        lineframe.size.height = 2;
                        [self addCursorRect:lineframe cursor:vResizeCursor];
                    }
                }
            }

            row = _numRows;
            while (row-- > 0) {
                count = [datasrc matrix:self additionalAreas:&areas inRow:row];
                cell.row = row;
                while (count-- > 0) {
                    moff = 0;
                    if (row > 0) {
                        colspan = [datasrc matrix:self columnRangeForCell:FSMakeCell(row-1, 0)];
                        mmax = [datasrc numberOfColumnsInMatrix:self]/colspan.length;
                        while (colspan.length-- > 0) {
                            moff += _colWidths[colspan.length];
                        }
                    } else {
                        mmax = 1;
                    }
                    for (mult = 0; mult < mmax; mult++) {
                        cell.column = areas[count].range.location;
                        frame = [self frameForRow:row column:cell.column];
                        frame.origin.x += mult*moff;
                        frame.origin.y += areas[count].offset;
                        frame.size.height = areas[count].length;
                        cell.dy = areas[count].offset;
                        length = areas[count].range.length;
                        frame.size.width = 0;
                        while (length-- > 0) {
                            frame.size.width += _colWidths[areas[count].range.location+length];
                        }
                        lineframe.origin = frame.origin;
                        lineframe.origin.x += frame.size.width-1;
                        lineframe.size.width = 1;
                        lineframe.size.height = frame.size.height;
                        [self addCursorRect:lineframe cursor:hResizeCursor];
                        lineframe.origin = frame.origin;
                        lineframe.origin.y += frame.size.height-1;
                        lineframe.size.width = frame.size.width;
                        lineframe.size.height = 2;
                        [self addCursorRect:lineframe cursor:vResizeCursor];
                    }
                }
            }
        }
        
        [hResizeCursor release];
        [vResizeCursor release];
    }
}


- (NSRect)frameForRow:(int)row column:(int)col
{
    id<FSVarioMatrixDataSource> datasrc = (id<FSVarioMatrixDataSource>)_dataSource;
    NSRect   result;
    NSRange  rr = [datasrc matrix:self rowRangeForCell:FSMakeCell(row,col)];
    NSRange  cr = [datasrc matrix:self columnRangeForCell:FSMakeCell(row,col)];
    
    result.origin.x = [self _originAtColumn:cr.location];
    result.origin.y = [self _originAtRow:rr.location];
    result.size.width = 0;
    while (cr.length-- > 0) {
        result.size.width += _colWidths[cr.location+cr.length];
    }
    result.size.height = 0;
    while (rr.length-- > 0) {
        result.size.height += _rowHeights[rr.location+rr.length];
    }
    return result;
}


- (FSCell)cellAtPoint:(NSPoint)point origin:(NSPoint*)origin size:(NSSize*)size
/*" Modified from the super method to look for spans. "*/
{
    id<FSVarioMatrixDataSource> datasrc = (id<FSVarioMatrixDataSource>)_dataSource;
    FSCell     result = {0,0};
    float      x = 0;
    float      y = 0;
    NSRange    span;
    NSPoint    orgn;
    
    // Look for row and column like normal.
    while ((x += _colWidths[result.column]) < point.x) result.column++;
    while ((y += _rowHeights[result.row]) < point.y) result.row++;
    
    span = [datasrc matrix:self rowRangeForCell:result];
    result.row = span.location;
    span = [datasrc matrix:self columnRangeForCell:result];
    result.column = span.location;

    orgn.x = x - _colWidths[result.column];
    orgn.y = y - _rowHeights[result.row];
    result.dx = point.x - orgn.x;
    result.dy = point.y - orgn.y;
    
    if (origin) {
        *origin = orgn;
    }
    if (size) {
        size->width = _colWidths[result.column];
        size->height = _rowHeights[result.row];
    }
    
    return result;
}

@end
