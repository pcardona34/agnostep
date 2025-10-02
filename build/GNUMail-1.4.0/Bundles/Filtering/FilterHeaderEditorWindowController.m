/*
**  FilterHeaderEditorWindowController.m
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

#include "FilterHeaderEditorWindowController.h"

#include "Constants.h"

#ifndef MACOSX
#include "FilterHeaderEditorWindow.h"
#endif

#include <Pantomime/NSString+Extensions.h>

@implementation FilterHeaderEditorWindowController

//
//
//
- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
  
#else
  FilterHeaderEditorWindow *filterHeaderEditorWindow;
  
  filterHeaderEditorWindow = [[FilterHeaderEditorWindow alloc] initWithContentRect: NSMakeRect(300,300,240,345)
							       styleMask: NSTitledWindowMask
							       backing: NSBackingStoreRetained
							       defer: NO];
  
  self = [super initWithWindow: filterHeaderEditorWindow];
  
  [filterHeaderEditorWindow layoutWindow];
  [filterHeaderEditorWindow setDelegate: self];

  // We link our outlets
  headerField = [filterHeaderEditorWindow headerField];
  tableView = [filterHeaderEditorWindow tableView];


  RELEASE(filterHeaderEditorWindow);
#endif

  [[self window] setTitle: _(@"Add a header")];
  
  return self;
}


- (void) dealloc
{
  NSDebugLog(@"FilterHeaderEditorWindowController: -dealloc");

// Cocoa bug?
#ifdef MACOSX
  [tableView setDataSource: nil];
#endif

  RELEASE(allHeaders);
  
  [super dealloc];
}

//
// delegate methods
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row:(NSInteger) rowIndex
{
  return [allHeaders objectAtIndex: rowIndex];
}


- (void) tableViewSelectionDidChange:(NSNotification *) aNotification
{
  if ([tableView selectedRow] >= 0)
    {
      [headerField setStringValue: [allHeaders objectAtIndex: [tableView selectedRow]]];
    }
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView
{
  return [allHeaders count];
}


- (void) windowWillClose: (NSNotification *) theNotification
{
  NSDebugLog(@"FilterHeaderEditorWindowController: -windowWillClose");
}

- (void) windowDidLoad
{
  allHeaders = [[NSMutableArray alloc] init];

  [super windowDidLoad];
}


//
// action methods
//
- (IBAction) okClicked: (id) sender
{
  [NSApp stopModal];
  [self close];
}


- (IBAction) cancelClicked: (id) sender
{
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


- (IBAction) addHeader: (id) sender
{
  if ( [[[headerField stringValue] stringByTrimmingWhiteSpaces] length] > 0 )
    {
      [allHeaders addObject: [[headerField stringValue] stringByTrimmingWhiteSpaces]];
      [tableView reloadData];
      [headerField setStringValue: @""];
    }
  else
    {
      NSBeep();
    }
}

- (IBAction) removeHeader: (id) sender
{
  if ([tableView selectedRow] >= 0)
    {
      id obj = [allHeaders objectAtIndex: [tableView selectedRow]];
      
      if ( obj )
	{
	  [allHeaders removeObject: obj];
	  [tableView reloadData];
	  [tableView setNeedsDisplay: YES];
	}
    }
  else
    {
      NSBeep();
    }
}


//
// access/mutation methods
//
- (NSMutableArray *) allHeaders
{
  return allHeaders;
}


- (void) setHeaders: (NSArray *) theHeaders
{
  if ( theHeaders )
    {
      [allHeaders addObjectsFromArray: theHeaders];
      [tableView reloadData];
    }
}

@end
