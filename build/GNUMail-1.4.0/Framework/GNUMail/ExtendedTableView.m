/*
**  ExtendedTableView.m
**
**  Copyright (c) 2002-2007 Ludovic Marcotte, Francis Lachapelle
**
**  Author: Francis Lachapelle <francis@Sophos.ca>
**          Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "ExtendedTableView.h"

#include "Constants.h"
#include "MailWindowController.h"

//
//
//
@interface ExtendedTableView (Private)

- (NSString *) _typedString;
- (void) _setTypedString: (NSString *) theString;
- (void) _appendToTypedString: (NSString *) theString;

@end


//
//
//
@implementation ExtendedTableView

- (void) dealloc
{
  TEST_RELEASE(_typedString);
  TEST_RELEASE(_currentSortOrder);
  TEST_RELEASE(_previousSortOrder);
  [super dealloc];
}


- (BOOL) acceptsFirstMouse: (NSEvent *) theEvent
{
  return YES;
}

//
//
//
- (NSImage *) dragImageForRows: (NSArray *) dragRows
			 event: (NSEvent *) dragEvent 
	       dragImageOffset: (NSPointPointer) dragImageOffset
{
  if ([dragRows count] > 1)
    {
      return [NSImage imageNamed: @"drag_mails.tiff"];
    }
  
  return [NSImage imageNamed: @"drag_mail.tiff"];
}


//
//
//
- (NSMenu *) menuForEvent: (NSEvent *) theEvent
{
  int row;

  row = [self rowAtPoint: [self convertPoint: [theEvent locationInWindow] fromView: nil]];
  
  if (row >= 0)
    {
      id delegate;
      
      delegate = [self delegate];
      
      if ([self numberOfSelectedRows] <= 1)
	{
	  [self selectRow: row  byExtendingSelection: NO];
	}
      
      if ([delegate respondsToSelector: @selector(dataView:contextMenuForRow:)]) 
	{
	  return [delegate dataView: self  contextMenuForRow: row];
	}
    }
  else
    {
      [self deselectAll: self];
      return [self menu];
    }

  return nil;
}


//
//
//
- (void) setDropRow: (int) row
      dropOperation: (NSTableViewDropOperation) operation
{
    [super setDropRow: -1
	   dropOperation: NSTableViewDropOn];
}

// DOCS FOR KEYDOWN, DOCOMMANDBYSELECTOR AND INSERTTEXT
//
// this table view accepts typing, informingits delegate
// that some string has been typed.  We use it to get 'type-ahead' behavior -
// search google for that if you want.
- (void) keyDown: (NSEvent *) theEvent
{
  [self interpretKeyEvents: [NSArray arrayWithObject: theEvent]];
  [super keyDown: theEvent];
}

- (void) doCommandBySelector: (SEL) theSelector
{
  // do nothing, we only react to insertText:
}

- (void) insertText: (id) theString
{
  [self _appendToTypedString: theString];

  [NSObject cancelPreviousPerformRequestsWithTarget: self
	    selector: @selector(_didReceiveTyping)
	    object: nil];
  [NSObject cancelPreviousPerformRequestsWithTarget: self
	    selector: @selector(_setTypedString:)
	    object: @""];

  [self performSelector: @selector(_didReceiveTyping)
	withObject: nil
	afterDelay: 0.1];
  [self performSelector: @selector(_setTypedString:)
	withObject: @""
	afterDelay: 1.0];
}

//
// We check if the row is the last selected one and is visible. The
// row must also NOT be the last one that CAN BE selected. That is,
// the current selected row is the last one visible but some more
// rows might have been added.
//
- (void) scrollIfNeeded
{
  NSRect r1, r2;
  int row;

  row = [self selectedRow];

  if (row < 0 || [self numberOfSelectedRows] > 1)
    {
      return;
    }

  // We get the rect our of selected row
  r1 = [self rectOfRow: [self selectedRow]];

  // We get the visible rect the scrollview
  r2 = [(NSScrollView *)[self superview] documentVisibleRect];
  
  if (((r1.origin.y+r1.size.height) >= (r2.origin.y+r2.size.height-r1.size.height)) &&
      (row < ([self numberOfRows]-1)) &&
      !_reverseOrder)
    {
      r2.origin.y += r1.size.height;
      [self scrollRectToVisible: r2];
    }
}


//
//
//
- (void) setReverseOrder: (BOOL) theBOOL
{
  _reverseOrder = theBOOL;
}

- (BOOL) isReverseOrder
{
  return _reverseOrder;
}


//
//
//
- (void) setReloading: (BOOL) theBOOL
{
  _reloading = theBOOL;
}

- (BOOL) isReloading
{
  return _reloading;
}


//
//
//
- (NSString *) currentSortOrder
{
  return _currentSortOrder;
}


//
//
//
- (void) setCurrentSortOrder: (NSString *) theCurrentOrder
{
  ASSIGN(_currentSortOrder, theCurrentOrder);
}


//
//
//
- (NSString *) previousSortOrder
{
  return _previousSortOrder;
}


//
//
//
- (void) setPreviousSortOrder: (NSString *) thePreviousOrder
{
  ASSIGN(_previousSortOrder, thePreviousOrder);
}
@end


//
//
//
@implementation ExtendedTableView (Private)

- (void) _didReceiveTyping
{    
  if ([[self delegate] respondsToSelector: @selector(tableView:didReceiveTyping:)])
    {
      [[self delegate] tableView: self  didReceiveTyping: [self _typedString]];
    }
}

- (NSString *) _typedString
{
  return AUTORELEASE([_typedString copy]);
}

- (void) _setTypedString: (NSString *) theString
{
  AUTORELEASE(_typedString);
  _typedString = [theString mutableCopy];
}

- (void)_appendToTypedString: (NSString *) theString
  
{
  if (!_typedString) 
    {
      [self _setTypedString: @""];
    }
  [_typedString appendString: theString];
}


@end
