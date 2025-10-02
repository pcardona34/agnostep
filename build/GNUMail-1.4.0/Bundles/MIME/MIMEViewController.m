/*
**  MIMEViewController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#include "MIMEViewController.h"

#include "Constants.h"
#include "MimeTypeEditorWindowController.h"
#include "MimeType.h"
#include "MimeTypeManager.h"

#ifndef MACOSX
#include "MIMEView.h"
#endif

static MIMEViewController *singleInstance = nil;

//
//
//
@implementation MIMEViewController

- (id) initWithNibName: (NSString *) theName
{
  self = [super init];

#ifdef MACOSX
  
  if ( ![NSBundle loadNibNamed: theName
		  owner: self] )
    {
      AUTORELEASE(self);
      return nil;
    }
  
  RETAIN(view);
  
  mimeTypesColumn = [tableView tableColumnWithIdentifier: @"mime-type"];
  fileExtensionsColumn = [tableView tableColumnWithIdentifier: @"file-extensions"];

  [tableView setTarget: self];
  [tableView setDoubleAction: @selector(edit:)];

#else
  // We link our view
  view = [[MIMEView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  tableView = ((MIMEView *)view)->tableView;
  mimeTypesColumn = ((MIMEView *)view)->mimeTypesColumn;
  fileExtensionsColumn = ((MIMEView *)view)->fileExtensionsColumn;
  add = ((MIMEView *)view)->add;
  delete = ((MIMEView *)view)->delete;
  edit = ((MIMEView *)view)->edit;
#endif
    
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
  return [[[MimeTypeManager singleInstance] mimeTypes] count];
}


//
//
//
- (id) tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn 
             row: (NSInteger)rowIndex
{
  MimeType *aMimeType = [[[MimeTypeManager singleInstance] mimeTypes]
						objectAtIndex: rowIndex];
 
  if (aTableColumn == mimeTypesColumn)
    {
      return [aMimeType mimeType];
    }
  else
    {
      return [aMimeType stringValueOfFileExtensions];
    }
}


//
// action methods
//
- (IBAction) add : (id) sender
{
  MimeTypeEditorWindowController *mimeTypeEditorWindowController;
  int result;

  mimeTypeEditorWindowController = [[MimeTypeEditorWindowController alloc] 
				     initWithWindowNibName: @"MimeTypeEditorWindow"];
  [mimeTypeEditorWindowController setMimeType: nil];

  result = [NSApp runModalForWindow: [mimeTypeEditorWindowController window]];
  
  if (result == NSRunStoppedResponse)
    {
      [tableView reloadData];
    }

  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];
  [mimeTypeEditorWindowController release];
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
			   _(@"Are you sure you want to delete this MIME type entry?"),
			   _(@"Cancel"), // default
			   _(@"Yes"),    // alternate
			   nil);

  // If we delete it...
  if (choice == NSAlertAlternateReturn)
    {
      [[MimeTypeManager singleInstance] removeMimeType: [[MimeTypeManager singleInstance] mimeTypeAtIndex:[tableView selectedRow]]];
      [tableView reloadData];
    }
}


//
//
//
- (IBAction) edit: (id) sender

{
  MimeTypeEditorWindowController *mimeTypeEditorWindowController;
  MimeType *aMimeType;
  int result;

  if ([tableView numberOfSelectedRows] == 0 || [tableView numberOfSelectedRows] > 1)
    {
      NSBeep();
      return;
    }

  aMimeType = [[MimeTypeManager singleInstance] mimeTypeAtIndex: [tableView selectedRow]];
			      
  mimeTypeEditorWindowController = [[MimeTypeEditorWindowController alloc] 
				     initWithWindowNibName: @"MimeTypeEditorWindow"];
  [mimeTypeEditorWindowController setMimeType: aMimeType];


  result = [NSApp runModalForWindow: [mimeTypeEditorWindowController window]];

  if (result == NSRunStoppedResponse)
    {
      NSDebugLog(@"We update...");
      [tableView reloadData];
    }

  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];
  [mimeTypeEditorWindowController release];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"mime" ofType: @"tiff"]]);
}

- (NSString *) name
{
  return _(@"MIME");
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
  [[MimeTypeManager singleInstance] synchronize];
}


//
// class methods
//
+ (id) singleInstance
{
  if ( !singleInstance )
    {
      singleInstance = [[MIMEViewController alloc] initWithNibName: @"MIMEView"];
    }

  return singleInstance;
}

@end
