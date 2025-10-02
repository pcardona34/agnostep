/*
**  ExtendedOutlineView.m
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

#include "ExtendedOutlineView.h"

#include "Constants.h"
#include "MailboxManagerController.h"
#include "MailWindowController.h"


/*!
 * @class ExtendedOutlineView
 * @abstract This class overwrites some methods of NSOutlineView.
 * @discussion This class is used by the MailboxManager class so
 *             all items look like folders un Mac OS X and items
 *             can be dragged on items and not inbetween nodes.
 *             
 */

@implementation ExtendedOutlineView: NSOutlineView

- (BOOL) acceptsFirstMouse: (NSEvent *) theEvent
{
  return YES;
}


//
//
//
- (NSMenu *) menuForEvent: (NSEvent *) theEvent
{
  int row;
  id item;
    
  row = [self rowAtPoint: [self convertPoint: [theEvent locationInWindow] fromView: nil]];
  
  if (row >= 0)
    {
      [self abortEditing];
      
      item = [self itemAtRow: row];
      
      if (item)
	{
	  id delegate;
	  
	  delegate = [self delegate];
	  
	  if ( [self numberOfSelectedRows] <= 1 )
	    {
	      [self selectRow: row  byExtendingSelection: NO];
	    }
	  
	  if ( [delegate respondsToSelector: @selector(outlineView:contextMenuForItem:)] ) 
	    {
	      return [delegate outlineView: self  contextMenuForItem: item];
	    }
	  else if ( [delegate respondsToSelector: @selector(dataView:contextMenuForRow:)] ) 
	    {
	      return [delegate dataView: self  contextMenuForRow: row];
	    }
	}
    }
  else
    {
      [self deselectAll: self];
      return [self menu];
    }

  return nil;
}

- (void) keyDown:(NSEvent *)ev
{
  NSString *characters = [ev characters];
  int i, c;
  for (i = 0, c = [characters length]; i < c; i++)
    {
      switch([characters characterAtIndex:i])
        {
          case '\t':
	    [[self delegate] 
	    	performSelector:@selector(_switchWindows:)
	    	withObject:self];
	    break;
	  default:
	    [super keyDown:ev];
	    return;
        }
    }
}

//
//
//
- (void) textDidEndEditing: (NSNotification *) theNotification
{
  NSMutableDictionary *aDictionary;
  
  aDictionary = [NSMutableDictionary dictionaryWithDictionary: [theNotification userInfo]];
  
  [aDictionary setObject: [NSNumber numberWithInt: NSIllegalTextMovement] forKey: @"NSTextMovement"];
  
  [super textDidEndEditing: [NSNotification notificationWithName: [theNotification name]
					    object: [theNotification object]
					    userInfo: aDictionary]];
}


/*!
 * @method shouldCollapseAutoExpandedItemsForDeposited:
 * @abstract Indicate if auto expanded items should return to
 *           their original collapsed state. 
 * @discussion
 * @param deposited Tells whether or not the drop terminated due
 *                  to a successful drop.
 * @result Always returns NO, so that items never return to
 *         their original collapsed state.
 */
- (BOOL) shouldCollapseAutoExpandedItemsForDeposited: (BOOL) deposited
{
  return NO;
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
@end
