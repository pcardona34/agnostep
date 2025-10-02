//
//  FSMatrix.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 27-AUG-2001.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSMatrix.m,v 1.6 2014/01/26 09:23:53 buzzdee Exp $

#import "FlexiSheet.h"

@implementation FSMatrix
/*" FSMatrix can use flexible space for rows and columns. "*/

- (void)_adjustSizeToRowsAndCols
    /* Adjusts the view size and caches row/col size in internal storage */
{
    int       row, col;
    NSSize    size = {0,0};

    for (row = 0; row < _numRows; row++) {
        _rowHeights[row] = [self heightForRow:row];
        size.height += _rowHeights[row];
    }
    for (col = 0; col < _numCols; col++) {
        _colWidths[col] = [self widthForColumn:col];
        size.width += _colWidths[col];
    }

    if(_dataSource != nil)
        [self setFrameSize:size];
}

- (void)resetCursorRects
{
    int       row, col;
    float     x = 0, y = 0;
    NSSize    size = [self bounds].size;

    if (_hRezAllowed) {
        NSCursor *hResizeCursor = [[NSCursor alloc]
            initWithImage:[NSImage imageNamed:@"HorzResizeCursor"]
                  hotSpot:NSMakePoint(8,8)];
        for (col = 0; col < _numCols; col++) {
            _colWidths[col] = [self widthForColumn:col];
            x += _colWidths[col];
            [self addCursorRect:NSMakeRect(x-2,0,2,size.height) cursor:hResizeCursor];
        }
        [hResizeCursor release];
    }

    if (_vRezAllowed) {
        NSCursor *vResizeCursor = [[NSCursor alloc]
            initWithImage:[NSImage imageNamed:@"VertResizeCursor"]
                  hotSpot:NSMakePoint(8,8)];
        for (row = 0; row < _numRows; row++) {
            _rowHeights[row] = [self heightForRow:row];
            y += _rowHeights[row];
            [self addCursorRect:NSMakeRect(0,y-2,size.width,2) cursor:vResizeCursor];
        }
        [vResizeCursor release];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _numRows = 1;
        _numCols = 1;
        _isEditing = NO;
        _hRezAllowed = NO;
        _vRezAllowed = NO;
        _colWidths = malloc(sizeof(float)*_numCols);
        _rowHeights = malloc(sizeof(float)*_numRows);
        [self _adjustSizeToRowsAndCols];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (float)widthForColumn:(int)col
    // Asks the datasource or returns default value.
{
    if (_dataSource != nil)
        return [_dataSource matrix:self sizeForCell:FSMakeCell(0,col)].width;
    return 0;
}

- (float)heightForRow:(int)row
    // Asks the datasource or returns default value.
{
    if (_dataSource != nil)
      return [_dataSource matrix:self sizeForCell:FSMakeCell(row,0)].height;
    return 0;
}


- (void)setHeaderMatrix:(BOOL)flag { _isHeader = flag; }
- (BOOL)isHeaderMatrix { return _isHeader; }

- (BOOL)isFlipped
{
    return YES;
}


- (BOOL)needsDisplay;
{
    NSResponder *resp = nil;
    FSCell       cell;

    if ([[self window] isKeyWindow]) {
        resp = [[self window] firstResponder];
        if (resp == lastResp)
            return [super needsDisplay];
    } else if (lastResp == nil) {
        return [super needsDisplay];
    }
    shouldDrawFocusRing = ([resp isKindOfClass:[NSView class]] && [(NSView *)resp isDescendantOf:self]);
    lastResp = resp;
    cell = [_dataSource matrixSelectedCell:self];
    if (cell.row != -1) {
        NSRect frame = {{0,0},{0,0}};
        frame.size.width = _colWidths[cell.column];
        frame.size.height = _rowHeights[cell.row];
        while (cell.row-- > 0) {
            frame.origin.y += _rowHeights[cell.row];
        }
        while (cell.column-- > 0) {
            frame.origin.x += _colWidths[cell.column];
        }
        [[self superview] setKeyboardFocusRingNeedsDisplayInRect:frame];
    }
    return YES;
}


- (void)drawRect:(NSRect)rect {
    NSInteger            row, col, max;
    NSRect               frame = {{0,0},{0,0}};
    FSCellStyle         *style;
    NSString            *strg;
    NSDictionary        *attributes;
    FSCell               cell;
    FSLineStyle          linestyle;
    CGFloat              dash[2] = {5,5};
    CGFloat              maxX = rect.origin.x + rect.size.width;
    CGFloat              maxY = rect.origin.y + rect.size.height;
    BOOL                 _primary = ([[self window] firstResponder] == self);
    // NSGraphicsContext   *ctx = [NSGraphicsContext currentContext]; // unused variable
    // void                *port = [ctx graphicsPort]; // unused variable
    NSColor             *primaryColor = [NSColor selectedControlColor];
    NSColor             *secondaryColor = [NSColor secondarySelectedControlColor];
    
    // Draw cell contents
    for (row = 0; row < _numRows; row++) {
        frame.origin.x = 0;
        frame.size.height = _rowHeights[row];

        for (col = 0; col < _numCols; col++) {
            frame.size.width = _colWidths[col];
            if (NSIntersectsRect(frame, rect)) {
                cell = FSMakeCell(row,col);

                // Draw cell
                if (_isEditing && (row == _editorCell.row) && (col == _editorCell.column)) {
                    [[NSColor keyboardFocusIndicatorColor] set];
                    NSFrameRectWithWidth(frame, 2);
                } else {
                    FSValue *val = [_dataSource matrix:self objectValueForCell:cell];
                    BOOL     isSelection = [_dataSource matrix:self cellIsSelected:cell];

                    style = [_dataSource matrix:self styleForCell:cell];

                    if (isSelection) {
                        if (_primary) {
                            [primaryColor set];
                        } else {
                            [secondaryColor set];
                        }
                        NSRectFill(frame);
                    } else if ([style backgroundColor]) {
                        [[style backgroundColor] set];
                        NSRectFill(frame);
                    }

                    attributes = [style textAttributes];
                    if ([[val value] isKindOfClass:[NSNumber class]]) {
                        strg = [[style numberFormatter] stringForObjectValue:[val value]];
                        if ([[val value] doubleValue] < 0) {
                            attributes = [[style numberFormatter] textAttributesForNegativeValues];
                        }
                    } else if ([[val value] isKindOfClass:[NSDate class]]) {
                        strg = [[style dateFormatter] stringForObjectValue:[val value]];
                    } else {
                        strg = [val description];
                    }
                    if ([strg length]) {
                        if ([strg length]/3 < frame.size.width-16) {
                            [strg drawInRect:NSInsetRect(frame,8,2) withAttributes:attributes];
                        } else {
                            [@"####" drawInRect:NSInsetRect(frame,8,2)
                                 withAttributes:[style textAttributes]];
                        }
                    }
                }
            }
            frame.origin.x += frame.size.width;
            if (frame.origin.x > maxX) {
                col = _numCols;
            }
        }
        frame.origin.y += frame.size.height;
        if (frame.origin.y > maxY) {
            row = _numRows;
        }
    }

    // Draw frame and lines
    [[NSColor blackColor] set];
    frame = [self bounds];
    NSFrameRect(frame);

    frame.origin.y = -1;
    frame.size.height = 1;
    max = rect.origin.y + rect.size.height;

    // CGContextSetShouldAntialias(port, 0);
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];	// WHY?
	
    for (row = 0; row < _numRows; row++) {
        frame.origin.y += _rowHeights[row];
        if (frame.origin.y >= rect.origin.y) {
            linestyle = [_dataSource matrix:self lineStyleForRow:row];
            switch (linestyle) {
                case FSDashedLine:
				{
					NSBezierPath *path = [NSBezierPath bezierPath];
//                    CGContextSetLineWidth(port, 1);
					[path setLineWidth:1.0];
//                    CGContextSetLineDash(port, 0, dash, 2);
					[path setLineDash:dash count:sizeof(dash)/sizeof(dash[0]) phase:0];
//                    CGContextBeginPath(port);
  //                  CGContextMoveToPoint(port, frame.origin.x, frame.origin.y+.5);
					[path moveToPoint:NSMakePoint(frame.origin.x, frame.origin.y+.5)];
//                    CGContextAddLineToPoint(port, frame.origin.x+frame.size.width, frame.origin.y+.5);
					 [path lineToPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+.5)];
//                    CGContextStrokePath(port);
					 [path stroke];
                    break;
					 }
                case FSBigFatLine:
                    frame.origin.y -= 1;
                    NSFrameRect(frame);
                    frame.origin.y += 1;
                    NSFrameRect(frame);
                    break;
                case FSDoubleLine:
                    frame.origin.y -= 2;
                    NSFrameRect(frame);
                    frame.origin.y += 2;
                    // Fall through
                case FSNormalLine:
                default:
                    NSFrameRect(frame);
            }
            if (frame.origin.y > max) break;
        }
    }
    frame = [self bounds];
    frame.origin.x = -1;
    frame.size.width = 1;
    max = rect.origin.x + rect.size.width;
    for (col = 0; col < _numCols; col++) {
        frame.origin.x += _colWidths[col];
        if (frame.origin.x >= rect.origin.x) {
            linestyle = [_dataSource matrix:self lineStyleForColumn:col];
            switch (linestyle) {
                case FSDashedLine:
				{
					NSBezierPath *path = [NSBezierPath bezierPath];
  //                  CGContextSetLineWidth(port, 1);
					[path setLineWidth:1.0];
    //                CGContextSetLineDash(port, 0, dash, 2);
 					[path setLineDash:dash count:sizeof(dash)/sizeof(dash[0]) phase:0];
      //              CGContextBeginPath(port);
       //             CGContextMoveToPoint(port, frame.origin.x+.5, frame.origin.y);
					[path moveToPoint:NSMakePoint(frame.origin.x+.5, frame.origin.y)];
        //            CGContextAddLineToPoint(port, frame.origin.x+.5, frame.origin.y+frame.size.height);
					[path lineToPoint:NSMakePoint(frame.origin.x+.5, frame.origin.y+frame.size.height)];
        //            CGContextStrokePath(port);
					[path stroke];
					break;
				}
                case FSBigFatLine:
                    frame.origin.x -= 1;
                    NSFrameRect(frame);
                    frame.origin.x += 1;
                    NSFrameRect(frame);
                    break;
                case FSDoubleLine:
                    frame.origin.x -= 2;
                    NSFrameRect(frame);
                    frame.origin.x += 2;
                    // Fall through
                case FSNormalLine:
                default:
                    NSFrameRect(frame);
            }
            if (frame.origin.x > max) break;
        }
    }

    if (shouldDrawFocusRing) {
        cell = [_dataSource matrixSelectedCell:self];
        if (cell.row != -1) {
            frame.origin = NSMakePoint(0,0);
            frame.size.width = _colWidths[cell.column];
            frame.size.height = _rowHeights[cell.row];
            while (cell.row-- > 0) {
                frame.origin.y += _rowHeights[cell.row];
            }
            while (cell.column-- > 0) {
                frame.origin.x += _colWidths[cell.column];
            }
            NSSetFocusRingStyle(NSFocusRingOnly);
            NSRectFill(frame);
        }
    }
}

//
//
//

- (void)setDataSource:(id<FSMatrixDataSource>)dataSource
{
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        _numRows = [_dataSource numberOfRowsInMatrix:self];
        free(_rowHeights);
        _rowHeights = malloc(sizeof(float)*_numRows);
        _numCols = [_dataSource numberOfColumnsInMatrix:self];
        free(_colWidths);
        _colWidths = malloc(sizeof(float)*_numCols);
        [self _adjustSizeToRowsAndCols];
        [[self window] invalidateCursorRectsForView:self];
    }
}

- (id<FSMatrixDataSource>)dataSource { return _dataSource; }


- (void)reloadData
{
    if (_dataSource == nil)
       return;
    _numRows = [_dataSource numberOfRowsInMatrix:self];
    free(_rowHeights);
    _rowHeights = malloc(sizeof(float)*_numRows);
    memset(_rowHeights, 0, sizeof((float*)_rowHeights));
    _numCols = [_dataSource numberOfColumnsInMatrix:self];
    free(_colWidths);
    _colWidths = malloc(sizeof(float)*_numCols);
    memset(_rowHeights, 0, sizeof((float*)_colWidths));
    [self _adjustSizeToRowsAndCols];
    [[self window] invalidateCursorRectsForView:self];
}


- (void)reloadColumnWidthsInRange:(NSRange)columns
{
    NSSize  size = [self frame].size;
    float   width;

    while (columns.length > 0) {
        size.width -= _colWidths[columns.location];
        width = [self widthForColumn:columns.location];
        size.width += width;
        _colWidths[columns.location] = width;
        columns.location++;
        columns.length--;
    }

    [self setFrameSize:size];
    [[self window] invalidateCursorRectsForView:self];
}

- (void)reloadRowHeightsInRange:(NSRange)rows
{
    NSSize  size = [self frame].size;
    float   height;

    while (rows.length > 0) {
        size.width -= _rowHeights[rows.location];
        height = [self heightForRow:rows.location];
        size.height += height;
        _rowHeights[rows.location] = height;
        rows.location++;
        rows.length--;
    }

    [self setFrameSize:size];
    [[self window] invalidateCursorRectsForView:self];
}

//
// Methods matching NSMatrix
//

- (int)numberOfRows
{
    return _numRows;
}

- (int)numberOfColumns
{
    return _numCols;
}

- (float)_originAtRow:(int)row
{
    float y = 0;
    int   r;
    for (r = 0; r < row; r++) {
        y += _rowHeights[r];
    }
    return y;
}

- (float)_originAtColumn:(int)col
{
    float x = 0;
    int   c;
    for (c = 0; c < col; c++) {
        x += _colWidths[c];
    }
    return x;
}

- (NSRect)frameForRow:(int)row column:(int)col
{
    NSRect result;
    result.origin.x = [self _originAtColumn:col];
    result.origin.y = [self _originAtRow:row];
    result.size = [_dataSource matrix:self sizeForCell:FSMakeCell(row,col)];
    return result;
}

- (BOOL)_endEditing
{
    if (_isEditing) {
        [[self window] endEditingFor:self];
        _isEditing = NO;
        //NSLog(@"End editing cell in FSMatrix");
        [[self window] makeFirstResponder:[self superview]];
    } else {
        [[self window] endEditingFor:nil];
    }
    return YES;
}


- (void)startEditingCell:(FSCell)cell withEvent:(NSEvent*)event
    /*" Should be called only when a valid selection exists. "*/
{
    if ([self _editCell:cell selectAll:YES])
        if (event)
            [[[self window] firstResponder] keyDown:event];
}


- (void)textDidEndEditing:(NSNotification *)notification
    // Called by the field editor
{
    NSText    *editor = [notification object];
    NSString  *value = [[editor string] copy];
    BOOL       next;

    [_dataSource matrix:self setObjectValue:value forCell:_editorCell];
    [self _endEditing];

    if (_isHeader) return;
    //if ([[self window] firstResponder] != self) return;
    switch ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue]) {
        case NSReturnTextMovement:
            // select the cell below.  We don't want that, really.
            //do {
            //_editorCell.row = (_editorCell.row+1)%_numRows;
            //next = [self _editCell:_editorCell selectAll:YES];
            //} while (!next);
            [[self window] makeFirstResponder:self];
            break;
        case NSTabTextMovement:
            do {
                _editorCell.row = (_editorCell.row+(_editorCell.column+1 == _numCols))%_numRows;
                _editorCell.column = (_editorCell.column+1)%_numCols;
                next = [self _editCell:_editorCell selectAll:YES];
            } while (!next);
            break;            
        case NSBacktabTextMovement:
            do {
                if (_editorCell.column) {
                    _editorCell.column--;
                } else {
                    _editorCell.row = (_editorCell.row)?(_editorCell.row-1):(_numRows-1);
                    _editorCell.column = _numCols-1;
                }
                next = [self _editCell:_editorCell selectAll:YES];
            } while (!next);
            break;
        case NSLeftTextMovement:
        case NSRightTextMovement:
        case NSUpTextMovement:
        case NSDownTextMovement:
            // Don't handle these for now.
            NSLog(@"Unhandled movement.");
            break;
        case NSIllegalTextMovement:
        default:
            ; // do nothing.
    }
}


- (NSRect)_editorFrameForCell:(FSCell)cell
{
    NSRect frame;

    frame = [self frameForRow:cell.row column:cell.column];

    return frame;
}


- (BOOL)_editCell:(FSCell)cell selectAll:(BOOL)select
{
    NSText      *editor;
    id           val;
    NSRect       frame;
    FSCellStyle *style;

    if ([_dataSource matrix:self shouldEditCell:cell] == NO) {
        return NO;
    }
    [_dataSource matrix:self selectCell:cell extendExistingSelection:NO];

    val = [_dataSource matrix:self objectValueForCell:cell];
    frame = [self _editorFrameForCell:cell];
    style = [_dataSource matrix:self styleForCell:cell];

    [FSLog logDebug:@"Start editing cell in FSMatrix"];
    if (![[self window] makeFirstResponder:self]) {
        [FSLog logError:@"Could not become first responder.  Handle me!"];
        return NO;
    }
    editor = [[self window] fieldEditor:YES forObject:self];

    [editor setString:[val description]];

    if (select) [editor selectAll:nil];
    [editor setDelegate:self];
    [editor setFont:[style font]];
    frame.origin.x += 3;
    frame.origin.y += 2;
    frame.size.width -= 6;
    frame.size.height -= 4;
    [editor setFrame:frame];
    [editor setBackgroundColor:[NSColor whiteColor]];
    [editor setDrawsBackground:YES];
    [editor setAlignment:[style alignment]];
    [self addSubview:editor];
    [self scrollRectToVisible:[editor frame]];
    [[self window] makeFirstResponder:editor];

    _editorCell = cell;
    _isEditing = YES;

    [self setNeedsDisplay:YES];
    return YES;
}


- (void)_selectMultipleCellsWithEvent:(NSEvent*)event
{ // prepare to select more
    NSPoint  click = [self convertPoint:[event locationInWindow] fromView:nil];
    FSCell   l = [self cellAtPoint:click origin:NULL];
    FSCell   cLoc, oldLoc = {-1,-1};
    NSRect   rc1, rc2, oldRect;
    BOOL     extendSelection = ([event modifierFlags] & NSShiftKeyMask);

    if ([_dataSource matrixShouldBecomeFirstResponder:self])
        [self _endEditing];

    // Selection 
    [_dataSource matrix:self selectCell:l extendExistingSelection:extendSelection];
    
    rc1 = [self frameForRow:l.row column:l.column];
    oldRect = rc1;
    [self setNeedsDisplay:YES];
    if (extendSelection) return;
    do {
        click = [self convertPoint:[event locationInWindow] fromView:nil];
        if (NSPointInRect(click, [self bounds])) {
            cLoc = [self cellAtPoint:click];
            if ((cLoc.column != oldLoc.column) || (cLoc.row != oldLoc.row)) {
                rc2 = [self frameForRow:cLoc.row column:cLoc.column];
                oldLoc = cLoc;
                if (extendSelection) {
                    [_dataSource matrix:self selectCell:cLoc extendExistingSelection:YES];
                    [self setNeedsDisplay:YES];
                } else {
                    [_dataSource matrix:self selectFromCell:l toCell:cLoc extendExistingSelection:NO];
                    [self setNeedsDisplayInRect:NSUnionRect(oldRect, rc2)];
                }
                [self setNeedsDisplayInRect:NSUnionRect(oldRect, rc2)];
                oldRect = NSUnionRect(rc1, rc2);
                [self scrollRectToVisible:rc2];
            }
        }
        event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    } while ([event type] != NSLeftMouseUp);
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint     click = [self convertPoint:[event locationInWindow] fromView:nil];
    int         clickCount = [event clickCount];
    FSCell      cell = [self cellAtPoint:click];
    NSRect      frame = [self _editorFrameForCell:cell];
    NSPoint     cellEnd;

    cellEnd.x = frame.origin.x + frame.size.width;
    cellEnd.y = frame.origin.y + frame.size.height;

    if ([_dataSource matrixShouldBecomeFirstResponder:self]) {
        [[self window] makeFirstResponder:self];
    }
    if (_hRezAllowed && (abs(click.x - cellEnd.x) < 2)) {
        NSPoint   current;
        NSSize    newSize = frame.size;
        float     width = newSize.width;
        id        floater = [[SLFloatingMark alloc] initWithLabel:@"Resizing"];
        NSPoint   scnPos = [[self window] convertBaseToScreen:[event locationInWindow]];

        cell.dx -= width-2;
        [_dataSource matrix:self willChangeWidthOfCell:cell];
        while (1) {
            current = [self convertPoint:[event locationInWindow] fromView:nil];
            newSize.width = MAX(width+(current.x-click.x), 10);
            scnPos.x += 3; scnPos.y -= 20;
            newSize = [_dataSource matrix:self setSize:newSize forCell:cell];
            [floater setLabel:[NSString stringWithFormat:@"%1.0f px", newSize.width]];
            [floater positionAt:scnPos];
            event = [[self window] nextEventMatchingMask:
                (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            scnPos = [[self window] convertBaseToScreen:[event locationInWindow]];
            if ([event type] == NSLeftMouseUp) {
                break;
            }
        }

        [floater fadeOut:self];
        [floater release];
        //
        // Now:
        // if cell belonged to a selection,
        // resize all selected cells to the same size
        //
        if ([_dataSource matrix:self cellIsSelected:cell]) {
            cell.column = 0;
            while (cell.column < _numCols) {
                if ([_dataSource matrix:self cellIsSelected:cell]) {
                    [_dataSource matrix:self setSize:newSize forCell:cell];
                }
                cell.column++;
            }
        }
        return;
    }

    if (_vRezAllowed && (abs(click.y - cellEnd.y) < 2)) {
        NSPoint   current;
        NSSize    newSize = frame.size;
        float     height = newSize.height;
        id        floater = [[SLFloatingMark alloc] initWithLabel:@"Resizing"];
        NSPoint   scnPos = [[self window] convertBaseToScreen:[event locationInWindow]];

        cell.dy -= height-2;
        [_dataSource matrix:self willChangeHeightOfCell:cell];
        while (1) {
            current = [self convertPoint:[event locationInWindow] fromView:nil];
            newSize.height = MAX(height+(current.y-click.y), 10);
            scnPos.x += 3; scnPos.y -= 20;
            newSize = [_dataSource matrix:self setSize:newSize forCell:cell];
            [floater setLabel:[NSString stringWithFormat:@"%1.0f px", newSize.height]];
            [floater positionAt:scnPos];
            event = [[self window] nextEventMatchingMask:
                (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            scnPos = [[self window] convertBaseToScreen:[event locationInWindow]];
            if ([event type] == NSLeftMouseUp) {
                break;
            }
        }
        [floater fadeOut:self];
        [floater release];
        //
        // Now:
        // if cell belonged to a selection,
        // resize all selected cells to the same size
        //
        if ([_dataSource matrix:self cellIsSelected:cell]) {
            cell.row = 0;
            while (cell.row < _numRows) {
                if ([_dataSource matrix:self cellIsSelected:cell]) {
                    [_dataSource matrix:self setSize:newSize forCell:cell];
                }
                cell.row++;
            }
        }
        return;
    }

    if (clickCount == 1) {
        [self _selectMultipleCellsWithEvent:event];
    }

    if (clickCount == 1) {
        [self setNeedsDisplay:YES];
        return;
    }

    if ([self _editCell:cell selectAll:YES] == NO) {
        FSFormula *formula = [[_dataSource matrix:self objectValueForCell:cell] calculatedByFormula];
        if (formula) {
            id floater = [[SLFloatingMark alloc] initWithLabel:@"Formula"];
            [floater positionAt:[[self window] convertBaseToScreen:[event locationInWindow]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HighlightFormula"
                                                                object:formula];
            [floater fadeOut:self];
            [floater release];
        } else {
            id floater = [[SLFloatingMark alloc] initWithLabel:@"Locked"];
            [floater positionAt:[[self window] convertBaseToScreen:[event locationInWindow]]];
            [floater fadeOut:self];
            [floater release];
        }
    }
}


/*" Selection logic: has been moved to data source. "*/

- (FSCell)cellAtPoint:(NSPoint)point
{
    return [self cellAtPoint:point origin:NULL];
}


- (FSCell)cellAtPoint:(NSPoint)point origin:(NSPoint*)origin size:(NSSize*)size
{
    FSCell   result = {0,0,0,0};
    float    x = 0;
    float    y = 0;

    while ((x += _colWidths[result.column]) < point.x) result.column++;
    while ((y += _rowHeights[result.row]) < point.y) result.row++;

    if (origin) {
        origin->x = x - _colWidths[result.column];
        origin->y = y - _rowHeights[result.row];
    }
    if (size) {
        size->width = _colWidths[result.column];
        size->height = _rowHeights[result.row];
    }

    return result;
}


- (FSCell)cellAtPoint:(NSPoint)point origin:(NSPoint*)origin
{
    return [self cellAtPoint:point origin:origin size:NULL];
}

@end
