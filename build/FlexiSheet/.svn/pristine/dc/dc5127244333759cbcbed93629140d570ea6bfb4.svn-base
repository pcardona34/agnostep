//
//  FSTableView+Keyboard.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 16-MAY-2002.
//  Copyright (c) 2002-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSTableView+Keyboard.m,v 1.2 2014/01/26 09:23:53 buzzdee Exp $

#import "FlexiSheet.h"

//
// This category to FSTableView implements First Responder
// methods for keyboard control.
//

@implementation FSTableView (Keyboard)

- (NSRect)rectForSelectionInDataMatrix
    /*" Returns the rect in data matrix that is currently selected. "*/
{
    int    row = _dataRows.location;
    int    col = _dataCols.location;
    NSRect rect = [_dataMatrix frameForRow:row column:col];
    if (_dataCols.length > 1)
        col += _dataCols.length-1;
    if (_dataRows.length > 1)
        row += _dataRows.length-1;
    rect = NSUnionRect(rect, [_dataMatrix frameForRow:row column:col]);

    return rect;
}


- (void)_moveUp:(BOOL)extend
{
    if (_dataSelected) {
        if (_dataRows.location > 0) {
            NSRect rect = [self rectForSelectionInDataMatrix];
            FSCell cell = FSMakeCell(_dataRows.location-1, _dataCols.location);
            [self matrix:_dataMatrix selectCell:cell extendExistingSelection:extend];
            [_dataMatrix setNeedsDisplayInRect:rect];
            [self scrollItemSelectionToVisible];
        } else {
            FSCell cell = FSMakeCell(_nHTop-1, _dataCols.location);
            [self matrix:_topMatrix selectCell:cell extendExistingSelection:extend];
            [[self window] makeFirstResponder:_topMatrix];
        }
    } else {
        FSKeyRange *sel = [self selectedRowItems];
        if ([sel isAtTop] == NO) {
            int pos = [sel indexRange].location-1;
            [self selectItems:
                [FSKeyRange keyRangeWithRange:NSMakeRange(pos,1)
                                      inGroup:[sel group]]];
            [self scrollItemSelectionToVisible];
        }
    }
}
- (void)moveUp:(id)sender { [self _moveUp:NO]; }
- (void)moveUpAndModifySelection:(id)sender { [self _moveUp:YES]; }


- (void)_moveDown:(BOOL)extend
{
    if (_dataSelected) {
        if (_dataRows.location < _numberOfRows-1) {
            NSRect rect = [self rectForSelectionInDataMatrix];
            FSCell cell = FSMakeCell(_dataRows.location+1, _dataCols.location);
            [self matrix:_dataMatrix selectCell:cell extendExistingSelection:extend];
            [_dataMatrix setNeedsDisplayInRect:rect];
            [self scrollItemSelectionToVisible];
        }
    } else {
        FSKeyRange *sel = [self selectedRowItems];
        if ([sel isAtBottom] == NO) {
            NSRange r = [sel indexRange];
            int pos = r.location+r.length;
            [self selectItems:
                [FSKeyRange keyRangeWithRange:NSMakeRange(pos,1)
                                      inGroup:[sel group]]];
            [self scrollItemSelectionToVisible];
        }
        if ((sel = [self selectedColumnItems])) {
            // must be a top selection.  move to data cell
            NSRange  r = [sel indexRange];
            FSCell   c1 = FSMakeCell(0, r.location);
            FSCell   c2 = FSMakeCell(0, r.location+r.length-1);
            [self matrix:_dataMatrix selectFromCell:c1 toCell:c2 extendExistingSelection:extend];
            [self scrollItemSelectionToVisible];
            [[self window] makeFirstResponder:_dataMatrix];
        }
    }
}
- (void)moveDown:(id)sender { [self _moveDown:NO]; }
- (void)moveDownAndModifySelection:(id)sender { [self _moveDown:YES]; }


- (void)_moveLeft:(BOOL)extend
{
    if (_dataSelected) {
        if (_dataCols.location > 0) {
            NSRect rect = [self rectForSelectionInDataMatrix];
            FSCell cell = FSMakeCell(_dataRows.location, _dataCols.location-1);
            [self matrix:_dataMatrix selectCell:cell extendExistingSelection:extend];
            [_dataMatrix setNeedsDisplayInRect:rect];
            [self scrollItemSelectionToVisible];
        } else {
            FSCell cell = FSMakeCell(_dataRows.location, _nHSide-1);
            [self matrix:_sideMatrix selectCell:cell extendExistingSelection:extend];
            [[self window] makeFirstResponder:_sideMatrix];
        }
    } else {
        FSKeyRange *sel = [self selectedColumnItems];
        if ([sel isAtTop] == NO) {
            int pos = [sel indexRange].location-1;
            [self selectItems:
                [FSKeyRange keyRangeWithRange:NSMakeRange(pos,1)
                                      inGroup:[sel group]]];
            [self scrollItemSelectionToVisible];
        }
    }
}
- (void)moveLeft:(id)sender { [self _moveLeft:NO]; }
- (void)moveBackwardAndModifySelection:(id)sender { [self _moveLeft:YES]; }


- (void)_moveRight:(BOOL)extend
{
    if (_dataSelected) {
        if (_dataCols.location < _numberOfCols-1) {
            NSRect rect = [self rectForSelectionInDataMatrix];
            FSCell cell = FSMakeCell(_dataRows.location, _dataCols.location+1);
            [self matrix:_dataMatrix selectCell:cell extendExistingSelection:extend];
            [_dataMatrix setNeedsDisplayInRect:rect];
            [self scrollItemSelectionToVisible];
        }
    } else {
        FSKeyRange *sel = [self selectedColumnItems];
        if ([sel isAtBottom] == NO) {
            NSRange r = [sel indexRange];
            int pos = r.location+r.length;
            [self selectItems:
                [FSKeyRange keyRangeWithRange:NSMakeRange(pos,1)
                                      inGroup:[sel group]]];
            [self scrollItemSelectionToVisible];
        }
        if ((sel = [self selectedRowItems])) {
            // must be a side selection.  move to data cell
            NSRange  r = [sel indexRange];
            FSCell   c1 = FSMakeCell(r.location, 0);
            FSCell   c2 = FSMakeCell(r.location+r.length-1, 0);
            [self matrix:_dataMatrix selectFromCell:c1 toCell:c2 extendExistingSelection:extend];
            [self scrollItemSelectionToVisible];
            [[self window] makeFirstResponder:_dataMatrix];
        }
    }
}
- (void)moveRight:(id)sender { [self _moveRight:NO]; }
- (void)moveForwardAndModifySelection:(id)sender { [self _moveRight:YES]; }

@end
