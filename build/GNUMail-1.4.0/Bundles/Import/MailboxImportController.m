/*
**  MailboxImportController.m
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#include "MailboxImportController.h"

#include "Constants.h"
#include "GNUMail.h"
#include "MailboxImportController+Filters.h"

#ifndef MACOSX
#include "Views.h"
#endif

static MailboxImportController *singleInstance = nil;

//
//
//
@implementation MailboxImportController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  self = [super initWithWindowNibName: windowNibName];
#else
  NSWindow *aWindow;
  
  aWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect(150,100,270,300)
			      styleMask: NSClosableWindowMask|NSTitledWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
			      backing: NSBackingStoreRetained
			      defer: NO];

  self = [super initWithWindow: aWindow];
  
  [aWindow setDelegate: self];

  // We link our outlets
  chooseTypeView = [[ChooseTypeView alloc] initWithOwner: self];
  [chooseTypeView layoutView];
  matrix = ((ChooseTypeView *)chooseTypeView)->matrix;

  explanationView = [[ExplanationView alloc] initWithOwner: self];
  [explanationView layoutView];
  explanationLabel = (NSTextField *)((ExplanationView *)explanationView)->explanationLabel;
  chooseButton = ((ExplanationView *)explanationView)->chooseButton;

  chooseMailboxView = [[ChooseMailboxView alloc] initWithOwner: self];
  [chooseMailboxView layoutView];
  tableView = ((ChooseMailboxView *)chooseMailboxView)->tableView;
#endif

  [[self window] setTitle: _(@"Import Mailboxes")];

  // We load our initial view
  [[self window] setContentView: chooseTypeView];

  // Our array holding the list of mailboxes to import
  allMailboxes = [[NSMutableArray alloc] init];

  // Our array holding the list of messages that we show while importing the mailboxes
  allMessages = [[NSArray alloc] initWithObjects:
				   _(@"Please export the mailboxes you want\nfrom Entourage by dragging them on\nthe Desktop. Then, choose the created\nfiles for importation by clicking on the\nbutton below."),
				 _(@"Please choose the directory that\ncontains the mbox files you would like\nto import. GNUMail will filter the\nfiles in the directory to only show\nmailboxes that can be imported."), nil];

  // We select the initial row in the matrix
  [matrix selectCellAtRow: 0  column: 0];
  [self selectionInMatrixHasChanged: self];

  return self;
}


//
//
//
- (void) dealloc
{
#ifndef MACOSX
  RELEASE(chooseTypeView);
  RELEASE(explanationView);
  RELEASE(chooseMailboxView);
#else
  [tableView setDataSource: nil];
#endif  

  RELEASE(allMailboxes);
  RELEASE(allMessages);

  [super dealloc];
}


//
// Actions methods
//
- (IBAction) chooseClicked: (id) sender
{
  NSOpenPanel *oPanel;
  int i, j, result, row;
  
  row = [matrix selectedRow];
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection: YES];

  // We allow only files to be selected...
  if (row == 0)
    {
      [oPanel setCanChooseFiles: YES];
      [oPanel setCanChooseDirectories: NO];
    }
  // We also only directories to be selected...
  else
    {
      [oPanel setCanChooseFiles: NO];
      [oPanel setCanChooseDirectories: YES];
    }

  result = [oPanel runModalForDirectory: [GNUMail currentWorkingPath]
		   file: nil 
		   types: nil];
  
  if (result == NSOKButton)
    {
      NSFileManager *aFileManager;
      NSString *aString;
      BOOL aBOOL;

      aFileManager = [NSFileManager defaultManager];

      for (i = 0; i < [[oPanel filenames] count]; i++)
	{
	  aString = [[oPanel filenames] objectAtIndex: i];

	  if ([aFileManager fileExistsAtPath: aString isDirectory: &aBOOL])
	    {
	      if (aBOOL)
		{
		  NSArray *aDirectoryContents;

		  aDirectoryContents = [aFileManager directoryContentsAtPath: aString];
		  
		  for (j = 0; j < [aDirectoryContents count]; j++)
		    {
		      [allMailboxes addObject: [NSString stringWithFormat: @"%@/%@", aString, [aDirectoryContents objectAtIndex: j]]];
		    }
		}
	      else
		{
		  [allMailboxes addObject: aString];
		}
	    }
	}

      [tableView reloadData];
    } 
}


//
//
//
- (IBAction) doneClicked: (id) sender
{
  if ([tableView numberOfSelectedRows] == 0)
    {
      NSBeep();
      return;
    }

  switch ([matrix selectedRow])
    {
    case 1:
      [self importFromMbox];
      break;
    case 0:
    default:
      [self importFromEntourage];
    }

  [self close];
}


//
//
//
- (IBAction) nextClicked: (id) sender
{
  if ([[self window] contentView] == chooseTypeView)
    {
      [[self window] setContentView: explanationView];
    }
  else if ([[self window] contentView] == explanationView)
    {
      [[self window] setContentView: chooseMailboxView];
    }
}


//
//
//
- (IBAction) previousClicked: (id) sender
{
  if ([[self window] contentView] == explanationView)
    {
      [[self window] setContentView: chooseTypeView];
    }
  else if ([[self window] contentView] == chooseMailboxView)
    {
      [[self window] setContentView: explanationView];
    }
}


//
//
//
- (IBAction) selectionInMatrixHasChanged: (id) sender
{
  int row;

  row = [matrix selectedRow];

  [allMailboxes removeAllObjects];
  [tableView reloadData];

  switch ( row )
    {
    case 1:
      [chooseButton setTitle: _(@"Choose Directory...")];
      break;
    case 0:
    default:
      [chooseButton setTitle: _(@"Choose File...")];
    }
  
  [explanationLabel setStringValue: [allMessages objectAtIndex: row]];
}


//
// NSTablieView delegate / datasource methods
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row: (NSInteger) rowIndex
{
  return [[allMailboxes objectAtIndex: rowIndex] lastPathComponent];
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView
{
  return [allMailboxes count];
}


//
// NSWindow delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  //DESTROY(singleInstance);
}


//
// Class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[MailboxImportController alloc] initWithWindowNibName: @"MailboxImport"];
    }

  return singleInstance;
}


@end
