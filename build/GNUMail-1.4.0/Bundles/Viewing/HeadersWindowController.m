/*
**  HeadersWindowController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "HeadersWindowController.h"

#include "GNUMail.h"
#include "Constants.h"

#ifndef MACOSX
#include "HeadersWindow.h"
#endif

#import <Pantomime/NSString+Extensions.h>

static NSString *ShownHeadersPboardType = @"ShownHeadersPboardType";
static NSArray *draggedShownHeaders;

//
//
//
@implementation HeadersWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
 
#else
  HeadersWindow *aWindow;

  aWindow = [[HeadersWindow alloc] initWithContentRect: NSMakeRect(200,200,440,300)
				   styleMask: NSTitledWindowMask|NSMiniaturizableWindowMask
				   backing: NSBackingStoreBuffered
				   defer: YES];
  
  self = [super initWithWindow: aWindow];
  
  [aWindow layoutWindow];
  [aWindow setDelegate: self];
 
  // We link our outlets 
  showAllHeaders = aWindow->showAllHeaders;
  tableView = aWindow->tableView;
  keyField = aWindow->keyField;

  RELEASE(aWindow);
#endif

  // We set our window's title
  [[self window] setTitle: _(@"Shown headers while viewing a mail")];

  // We initialize our array containing all our headers
  shownHeaders = [[NSMutableArray alloc] init];

  // We register dragged type for
  [tableView registerForDraggedTypes: [NSArray arrayWithObject: ShownHeadersPboardType]];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"HeadersWindowController: -dealloc");
  
  // Cocoa bug?
#ifdef MACOSX
  [tableView setDataSource: nil];;
#endif

  RELEASE(shownHeaders);

  [super dealloc];
}


//
// action methods
//
- (IBAction) addDefaults: (id) sender
{
  if (![shownHeaders containsObject: @"Date"])
    {
      [shownHeaders addObject: @"Date"];
    }
  
  if (![shownHeaders containsObject: @"From"])
    {
      [shownHeaders addObject: @"From"];
    }

  if (![shownHeaders containsObject: @"To"])
    {
      [shownHeaders addObject: @"To"];
    }

  if (![shownHeaders containsObject: @"Cc"])
    {
      [shownHeaders addObject: @"Cc"];
    }
  
  if (![shownHeaders containsObject: @"Subject"])
    {
      [shownHeaders addObject: @"Subject"];
    }

  [tableView reloadData];
  [tableView setNeedsDisplay: YES];
}


//
//
//
- (IBAction) addShown: (id) sender
{
  // We verify that the value isn't empty
  if ([[[keyField stringValue] stringByTrimmingWhiteSpaces] length] > 0)
    {
      if (![shownHeaders containsObject: [[keyField stringValue] stringByTrimmingWhiteSpaces]])
	{
	  [shownHeaders addObject: [[keyField stringValue] stringByTrimmingWhiteSpaces]];
	  [keyField setStringValue: @""];
	  [tableView reloadData];
	  [tableView setNeedsDisplay: YES];
	}
      else
	{
	  NSBeep();
	}
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) removeShown: (id) sender
{
  if ([tableView selectedRow] >= 0)
    {
      id obj = [shownHeaders objectAtIndex: [tableView selectedRow]];
      
      if (obj)
	{
	  [shownHeaders removeObject: obj];
	  [tableView reloadData];
	  [tableView setNeedsDisplay:YES];
	}
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) moveUp: (id) sender
{
  int selectedRow = [tableView selectedRow];
  
  if (selectedRow <= 0)
    {
      NSBeep();
      return;
    }
  else
    {
      NSString *anHeader;
      
      anHeader = [shownHeaders objectAtIndex: selectedRow];
      [shownHeaders removeObjectAtIndex: selectedRow];
      [shownHeaders insertObject: anHeader atIndex: (selectedRow - 1)];
      [tableView reloadData];
      [tableView selectRow: (selectedRow - 1) byExtendingSelection: NO];
    }
}


//
//
//
- (IBAction) moveDown: (id) sender
{
  int selectedRow = [tableView selectedRow];
  
  if (selectedRow == ([shownHeaders count] - 1) || selectedRow < 0)
    {   
      NSBeep();
      return;
    }
  else
    {
      [shownHeaders removeObjectAtIndex: selectedRow];
      [shownHeaders insertObject: [shownHeaders objectAtIndex: selectedRow]  atIndex: (selectedRow+1)];
      [tableView reloadData];
      [tableView selectRow: (selectedRow+1) byExtendingSelection: NO];
    }
}


//
//
//
- (IBAction) okClicked: (id) sender
{
  [NSApp stopModal];
  [self close];
}


//
//
//
- (IBAction) cancelClicked: (id) sender
{
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


//
// Delegate / Datasource methods
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row:(NSInteger) rowIndex
{
  return [shownHeaders objectAtIndex: rowIndex];
}


//
//
//
- (void) tableViewSelectionDidChange:(NSNotification *) aNotification
{
  if ([tableView selectedRow] >= 0)
    {
      [keyField setStringValue: [shownHeaders objectAtIndex: [tableView selectedRow]]];
    }
}


//
//
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView
{
  return [shownHeaders count];
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
  
  [shownHeaders replaceObjectAtIndex: rowIndex withObject: anObject];
}


//
//
//
- (BOOL) tableView: (NSTableView *)aTableView
         writeRows: (NSArray *) rows
      toPasteboard: (NSPasteboard *) pboard
{
  NSMutableArray *propertyList;
  int i;
  
  // FIXME - we leak here
  draggedShownHeaders = RETAIN(rows);
  propertyList = [[NSMutableArray alloc] initWithCapacity: [rows count]];
  
  for (i = 0; i < [rows count]; i++)
    {
      [propertyList addObject: [self tableView: aTableView objectValueForTableColumn:
				       [[aTableView tableColumns] objectAtIndex: 0]
				     row: [[rows objectAtIndex: i] intValue]]];
    }
  
  [pboard declareTypes: [NSArray arrayWithObject: ShownHeadersPboardType]
	  owner: self];
  
  [pboard setPropertyList: propertyList
	  forType: ShownHeadersPboardType];
  RELEASE(propertyList);
  
  return YES;
}


//
//
//
- (NSDragOperation) tableView: (NSTableView *) aTableView
		 validateDrop: (id <NSDraggingInfo>) info
		  proposedRow: (NSInteger) row
	proposedDropOperation: (NSTableViewDropOperation) operation
  
{
  if ([info draggingSourceOperationMask] & NSDragOperationGeneric)
    {
      return NSDragOperationGeneric;
    }
  else if ([info draggingSourceOperationMask] & NSDragOperationCopy)
    {
      return NSDragOperationCopy;
    }
  else
    {
      return NSDragOperationNone;
    }
}


//
//
//
- (BOOL) tableView: (NSTableView *) aTableView
        acceptDrop: (id <NSDraggingInfo>) info
               row: (NSInteger) row
     dropOperation: (NSTableViewDropOperation) operation
{
  NSDragOperation dragOperation;
  if ([info draggingSourceOperationMask] & NSDragOperationGeneric)
    dragOperation = NSDragOperationGeneric;
  else if ([info draggingSourceOperationMask] & NSDragOperationCopy)
    dragOperation = NSDragOperationCopy;
  else
    dragOperation = NSDragOperationNone;

  {
    int i, j;
    NSArray *pl = [[info draggingPasteboard] propertyListForType: ShownHeadersPboardType];
    int count = [pl count];

    for ( i = count - 1; i >= 0; i-- )
      {
        [shownHeaders insertObject: [pl objectAtIndex: i]
                      atIndex: row];
      }

    if (dragOperation == NSDragOperationGeneric)
      {
        for (i = count - 1; i >= 0; i--)
          {
            j = [[draggedShownHeaders objectAtIndex: i] intValue];
            if (j >= row)
              {
                j += count;
              }
            [shownHeaders removeObjectAtIndex: j];
          }
      }
    [aTableView reloadData];
  }

  return YES;
}


//
// access/mutation methods
//
- (void) setShownHeaders: (NSMutableArray *) theMutableArray
{
  [shownHeaders removeAllObjects];

  if (theMutableArray)
    {
      [shownHeaders addObjectsFromArray: theMutableArray];
    }

  [tableView reloadData];
  [tableView setNeedsDisplay: YES];
}


- (NSMutableArray *) shownHeaders
{
  return shownHeaders;
}


//
//
//
- (void) setShowAllHeadersButtonState: (int) theState
{
  [showAllHeaders setState: theState];
}


- (int) showAllHeadersButtonState
{
  return [showAllHeaders state];
}

@end
