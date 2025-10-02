/*
**  FilteringViewController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2019      GNUstep Team
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

#include "FilteringViewController.h"

#include "Constants.h"
#include "Filter.h"
#include "FilterEditorWindowController.h"
#include "FilterManager.h"

#ifndef MACOSX
#include "FilteringView.h"
#endif

static FilteringViewController *singleInstance = nil;

static NSString *FilterPboardType = @"FilterPboardType";
static NSArray *draggedFilters;

//
//
//
@implementation FilteringViewController

- (id) initWithNibName: (NSString *) theName
{
  ExtendedButtonCell *cell;

  self = [super init];

  filterManager = [FilterManager singleInstance];
  
#ifdef MACOSX
  
  if (![NSBundle loadNibNamed: theName  owner: self])
    {
      AUTORELEASE(self);
      return nil;
    }
  
  RETAIN(view);
  
  rulesColumn = [tableView tableColumnWithIdentifier: @"rules"];
  
  [tableView setTarget: self];
  [tableView setDoubleAction: @selector(edit:)];

#else
  // We link our view
  view = [[FilteringView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  tableView = ((FilteringView *)view)->tableView;
  rulesColumn = ((FilteringView *)view)->rulesColumn;
  activeColumn = ((FilteringView *)view)->activeColumn;
  add = ((FilteringView *)view)->add;
  delete = ((FilteringView *)view)->delete;
  duplicate = ((FilteringView *)view)->duplicate;
  edit = ((FilteringView *)view)->edit;
#endif

  cell = [[ExtendedButtonCell alloc] init];
  [cell setButtonType: NSSwitchButton];
  [cell setImagePosition: NSImageOnly];
  [cell setControlSize: NSSmallControlSize];    
  [[tableView tableColumnWithIdentifier: @"active"] setDataCell: cell];
  RELEASE(cell);
  
  // We set the intercell spacing of our table view
  [tableView setIntercellSpacing: NSZeroSize];

  // We register for dragged types
  [tableView registerForDraggedTypes: [NSArray arrayWithObject: FilterPboardType]];

  // We get our defaults for this panel
  [self initializeFromDefaults];

  return self;
}


//
//
//
- (void) dealloc
{
  singleInstance = nil;

  // Cocoa bug?
#ifdef MACOSX
  [tableView setDataSource: nil];
#endif

  RELEASE(view);

  [super dealloc];
}


//
// Data Source methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  return [[filterManager filters] count];
}


//
//
//
- (id)           tableView: (NSTableView *)aTableView
 objectValueForTableColumn: (NSTableColumn *)aTableColumn 
		       row: (NSInteger)rowIndex
{
  Filter *aFilter;
  
  aFilter = [[filterManager filters] objectAtIndex: rowIndex];

  if ( aTableColumn == rulesColumn )
    { 
      return [aFilter description];
    }
  
  return [NSNumber numberWithBool: [aFilter isActive]];
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
  Filter *aFilter;
  
  aFilter = [[filterManager filters] objectAtIndex: rowIndex];
  
  if (![aFilter isActive])
    {
      [aFilter setIsActive: YES];
    }
  else   
    {
      [aFilter setIsActive: NO];
    }
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
   willDisplayCell: (id) aCell
    forTableColumn: (NSTableColumn *) aTableColumn
               row: (NSInteger) rowIndex
{
  Filter *aFilter;
  
  // Don't use the color on a selected row.
  if ([aTableView selectedRow] == rowIndex)
    {
      if ([aCell isKindOfClass: [NSTextFieldCell class]])
	{
	  [aCell setDrawsBackground: NO];
	}
      else
	{
	  [aCell setColor: nil];
	}
      return;
    }

  aFilter = [[filterManager filters] objectAtIndex: rowIndex];
  
  if ([aCell isKindOfClass: [NSTextFieldCell class]])
    {    
      if ([aFilter action] == SET_COLOR)
	{
	  [aCell setDrawsBackground: YES];
	  [aCell setBackgroundColor: [aFilter actionColor]];
	}
      else
	{
	  [aCell setDrawsBackground: NO];
	}
    }
  else
    { 
      if ([aFilter action] == SET_COLOR)
        {
          [aCell setColor: [aFilter actionColor]];
        }
      else
	{
          [aCell setColor: nil];
	}
    }
}


//
// NSTableView Drag and drop
//
- (BOOL) tableView: (NSTableView *) aTableView
	 writeRows: (NSArray *) rows
      toPasteboard: (NSPasteboard *) pboard
{
  NSMutableArray *propertyList;
  int i, row;

  draggedFilters = RETAIN(rows);
  propertyList = [[NSMutableArray alloc] initWithCapacity: [rows count]];
  
  for (i = 0; i < [rows count]; i++)
    {
      Filter *aFilter;
      
      row = [[rows objectAtIndex: i] intValue];
      aFilter = [[filterManager filterAtIndex: row] copy];
      
      [propertyList addObject: [NSArchiver archivedDataWithRootObject: aFilter]];

      RELEASE(aFilter);
    }

  [pboard declareTypes: [NSArray arrayWithObject: FilterPboardType] owner: self];
  [pboard setPropertyList: propertyList forType: FilterPboardType];
  RELEASE(propertyList);
  
  return YES;
}


//
// NSTableView Drag and drop
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
// NSTableView Drag and drop
//
- (BOOL) tableView: (NSTableView *) aTableView
	acceptDrop: (id <NSDraggingInfo>) info
	       row: (NSInteger) row
     dropOperation: (NSTableViewDropOperation) operation
{
  NSDragOperation dragOperation;
  NSArray *propertyList;
  int i, j, count;

  if ([info draggingSourceOperationMask] & NSDragOperationGeneric)
    {
      dragOperation = NSDragOperationGeneric;
    }
  else if ([info draggingSourceOperationMask] & NSDragOperationCopy)
    {
      dragOperation = NSDragOperationCopy;
    }
  else
    {
      dragOperation = NSDragOperationNone;
    }
  
  propertyList = [[info draggingPasteboard] propertyListForType: FilterPboardType];
  count = [propertyList count];
  
  for ( i = count - 1; i >= 0; i-- )
    {
      Filter *aFilter;
      
      aFilter = (Filter*)[NSUnarchiver unarchiveObjectWithData: [propertyList objectAtIndex: i]];
      [filterManager addFilter: aFilter atIndex: row];
    }
  
  if (dragOperation == NSDragOperationGeneric)
    {
      for ( i = count - 1; i >= 0; i-- )
	{
	  j = [[draggedFilters objectAtIndex: i] intValue];
	  if (j >= row)
	    {
	      j += count;
	    }
	  [filterManager removeFilter: [filterManager filterAtIndex: j]];
	}
    }
  [aTableView reloadData];

  return YES;
}


//
// action methods
//
- (IBAction) add: (id) sender
{
  FilterEditorWindowController *filterEditorWindowController;
  int result;

  filterEditorWindowController = [[FilterEditorWindowController alloc] initWithWindowNibName: @"FilterEditorWindow"];
  
  [filterEditorWindowController setFilterManager: filterManager];
  [filterEditorWindowController setFilter: nil];

  result = [NSApp runModalForWindow: [filterEditorWindowController window]];
  
  if (result == NSRunStoppedResponse)
    {
      [tableView reloadData];
    }

  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];
  [filterEditorWindowController release];
}


//
//
//
- (IBAction) delete: (id) sender
{
  int choice;

  if ([tableView numberOfSelectedRows] == 0 || [tableView numberOfSelectedRows] > 1)
    {
      NSBeep();
      return;
    }
  
  choice = NSRunAlertPanel(_(@"Delete..."),
			   _(@"Are you sure you want to delete this filter?"),
			   _(@"Cancel"), // default
			   _(@"Yes"),    // alternate
			   nil);

  // If we delete it...
  if (choice == NSAlertAlternateReturn)
    {
      [filterManager removeFilter: [filterManager filterAtIndex:[tableView selectedRow]]];
      [tableView reloadData];
    }
}


//
//
//
- (IBAction) duplicate: (id) sender
{
  if ([tableView numberOfSelectedRows] == 0 || [tableView numberOfSelectedRows] > 1)
    {
      NSBeep();
      return;
    }
  else
    {
      Filter *aFilter;
      
      aFilter = [[filterManager filterAtIndex: [tableView selectedRow]] copy];
      [aFilter setDescription: [NSString stringWithFormat: @"%@ (copy)", [aFilter description]]];
      [filterManager addFilter: aFilter];
      RELEASE(aFilter);

      [tableView reloadData];
    }
}


//
//
//
- (IBAction) edit: (id) sender 
{
  int result;
  
  if ([tableView numberOfSelectedRows] == 0 || [tableView numberOfSelectedRows] > 1)
    {
      NSBeep();
      return;
    }
  
  result = [[self editFilter: [NSNumber numberWithInt: [tableView selectedRow]]] intValue];
  
  if (result == NSRunStoppedResponse)
    {
      [tableView reloadData];
    }

  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];

}


//
//
//
- (IBAction) moveDown: (id) sender

{
  if ([tableView numberOfSelectedRows] == 0 ||
      [tableView numberOfSelectedRows] > 1 ||
      [tableView selectedRow] == ([[filterManager filters] count] - 1))
    {
      NSBeep();
      return;
    }
  else
    {
      Filter *aFilter;
      int index;
      
      index = [tableView selectedRow];
      aFilter = [filterManager filterAtIndex: index];
      RETAIN(aFilter);
      
      [filterManager removeFilter: aFilter];
      [filterManager addFilter: aFilter
		     atIndex: (index + 1)];
      [tableView reloadData];
      [tableView selectRow: (index + 1) byExtendingSelection: NO];
      
      RELEASE(aFilter);
    }
}


//
//
//
- (IBAction) moveUp: (id) sender

{
  if ([tableView numberOfSelectedRows] == 0 ||
      [tableView numberOfSelectedRows] > 1 ||
      [tableView selectedRow] == 0)
    {
      NSBeep();
      return;
    }
  else
    {
      Filter *aFilter;
      int index;
      
      index = [tableView selectedRow];
      aFilter = [filterManager filterAtIndex: index];
      RETAIN(aFilter);
      
      [filterManager removeFilter: aFilter];
      [filterManager addFilter: aFilter
		     atIndex: (index - 1)];
      [tableView reloadData];
      [tableView selectRow: (index - 1) byExtendingSelection: NO];
      
      RELEASE(aFilter);
    }
}

//
// other methods
//
- (NSNumber *) editFilter: (NSNumber *) theIndex
{
  Filter *aFilter;
  FilterEditorWindowController *filterEditorWindowController;
  NSInteger result;

  aFilter = [filterManager filterAtIndex: [theIndex intValue]];
  
  filterEditorWindowController = [[FilterEditorWindowController alloc] 
				   initWithWindowNibName: @"FilterEditorWindow"];
  
  [[filterEditorWindowController window] setTitle: _(@"Edit a filter")];
  [filterEditorWindowController setFilterManager: filterManager];
  [filterEditorWindowController setFilter: aFilter];

  result = [NSApp runModalForWindow: [filterEditorWindowController window]];
  [filterEditorWindowController release];
  return [NSNumber numberWithInt: result];
}


//
//
//
- (void) updateView
{
  [tableView reloadData];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"Filtering" ofType: @"tiff"]]);
}

- (NSString *) name
{
  return _(@"Filtering");
}

- (NSView *) view
{
  return view;
}


//
//
//
- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{

}


//
//
//
- (void) saveChanges
{
  [filterManager synchronize];

  [[NSNotificationCenter defaultCenter]
    postNotificationName: FiltersHaveChanged
    object: nil
    userInfo: nil];
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[FilteringViewController alloc] initWithNibName: @"FilteringView"];
    }

  return singleInstance;
}

@end


//
// Custom NSButton cell
//
@implementation ExtendedButtonCell

- (void) dealloc
{
  TEST_RELEASE(color);
  [super dealloc];
}

- (id) copyWithZone: (NSZone *) theZone
{
  ExtendedButtonCell *cell;
  cell = [[ExtendedButtonCell alloc] init];
  [cell setColor: color];
  return cell;
}

- (void) setColor: (NSColor *) theColor
{
  ASSIGN(color, theColor);
}


- (void) drawInteriorWithFrame: (NSRect) theRect
			inView: (NSView *) theView
{
  if (color)
    {
      [color set];
      NSRectFill(theRect);
    }

  [super drawInteriorWithFrame: theRect  inView: theView];
}

@end
