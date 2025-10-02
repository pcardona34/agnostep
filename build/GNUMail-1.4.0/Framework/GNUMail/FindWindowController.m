/*
**  FindWindowController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2014-2023 Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#import "FindWindowController.h"

#import "GNUMail.h"
#import "ConsoleWindowController.h"
#import "Constants.h"
#import "MailboxManagerController.h"
#import "MailWindowController.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWContainer.h>
#include <Pantomime/CWFolder.h>
#include <Pantomime/CWIMAPFolder.h>
#include <Pantomime/CWIMAPStore.h>
#include <Pantomime/CWMessage.h>
#include <Pantomime/NSString+Extensions.h>

static FindWindowController *singleInstance = nil;

//
// FindWindowController Private interface
//
@interface FindWindowController (Private)
- (void) _folderCloseCompleted: (NSNotification *) theNotification;
- (void) _selectIndexesFromResults: (NSArray *) theResults
                        controller: (MailWindowController *) theMailWindowController;
- (void) _setState: (BOOL) theState;
@end


//
//
//
@implementation FindWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
  self = [super initWithWindowNibName: windowNibName];

  [[self window] setTitle: _(@"Find")];

  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"FindWindow"];
  [[self window] setFrameUsingName: @"FindWindow"];
  
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderCloseCompleted:)
    name: PantomimeFolderCloseCompleted
    object: nil];

  return self;
}


//
//
//
- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  RELEASE(_indexes);
  RELEASE(_folder);
  [super dealloc];
}


//
// action methods
//
- (IBAction) findAll: (id) sender
{
  NSString *aString;

  aString = [findField stringValue];
  _location = 0;
  
  if ([GNUMail lastMailWindowOnTop] && 
      ([[aString stringByTrimmingWhiteSpaces] length] > 0)) 
    {
      MailWindowController *aMailWindowController;
      CWFolder *aFolder;
      int mask, options;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];

      // First clear searchField before find
      [ aMailWindowController resetSearchField ];
      aFolder = [aMailWindowController folder];
      
      ADD_CONSOLE_MESSAGE(_(@"Searching for %@..."), aString);
      
      //
      // We get our mask
      //
      if ([[matrix cellAtRow: 0  column: 0] state] == NSOnState)
	{
	  mask = PantomimeFrom;
	}
      else if ([[matrix cellAtRow: 1  column: 0] state] == NSOnState)
	{
	  mask = PantomimeTo;
	}
      else if ([[matrix cellAtRow: 1  column: 1] state] == NSOnState)
	{
	  mask = PantomimeContent;
	}
      else
	{
	  mask = PantomimeSubject;
	}

      //
      // We get our options
      //
      options = 0;

      if ([ignoreCaseButton state] == NSOnState)
	{
	  options = options|PantomimeCaseInsensitiveSearch;
	}
      
      if ([regularExpressionButton state] == NSOnState)
	{
	  options = options|PantomimeRegularExpression;
	}



      [aFolder search: aString  mask: mask  options: options];

      //
      // We must only start the animation for a IMAP folder
      // since for a local folder, we will receive the PantomimeFolderSearchCompleted
      // notification BEFORE starting the actual animation!
      //
      if ([aFolder isKindOfClass: [CWIMAPFolder class]])
	{
	  Task *aTask;

	  aTask = [[Task alloc] init];
	  aTask->op = SEARCH_ASYNC;
	  [aTask setKey: [Utilities accountNameForFolder: aFolder]];
	  aTask->immediate = YES;
	  [[TaskManager singleInstance] addTask: aTask];
	  RELEASE(aTask);

	  [foundLabel setStringValue: _(@"Searching...")];
	  [self _setState: NO];
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
- (IBAction) nextMessage: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      MailWindowController *aMailWindowController;
      id dataView; 

      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      dataView = [aMailWindowController dataView];
      
      if ([_indexes count] < 2)
	{
	  NSBeep();
	  return;
	}
      else
	{
	  [dataView selectRow: [[_indexes objectAtIndex: _location] intValue] 
		    byExtendingSelection: NO];
	  [dataView scrollRowToVisible: [[_indexes objectAtIndex: _location] intValue]];
	  _location += 1;
	  
	  if (_location == [_indexes count])
	    {
	      _location = 0;
	    }
	  
	  [dataView setNeedsDisplay:YES];
	}
    }
}


//
//
//
- (IBAction) previousMessage: (id) sender
{  
  if ([GNUMail lastMailWindowOnTop])
    {
      MailWindowController *aMailWindowController;
      id dataView; 
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      dataView = [aMailWindowController dataView];
      
      if ([_indexes count] < 2)
	{
	  NSBeep();
	  return;
	}
      else
	{
	  [dataView selectRow: [[_indexes objectAtIndex: _location] intValue] 
		    byExtendingSelection: NO];
	  [dataView scrollRowToVisible: [[_indexes objectAtIndex: _location] intValue]];
	  _location -= 1;
	  
	  if (_location < 0)
	    {
	      _location = [_indexes count]-1;
	    }

	  [dataView setNeedsDisplay:YES];
	}
    }
}


//
// delegate methods
//
- (void) windowDidLoad
{
  _indexes = [[NSMutableArray alloc] init];
  _location = 0;  
  _folder = nil;
}


//
// access / mutation
//
- (NSTextField *) findField
{
  return findField;
}

- (void) setSearchResults: (NSArray *) theResults  forFolder: (CWFolder *) theFolder
{
  if (theResults && theFolder)
    {
      MailWindowController *aMailWindowController;
      
      ASSIGN(_folder, theFolder);

      aMailWindowController = [[Utilities windowForFolderName: [_folder name]  store: [_folder store]] delegate];
      
      if (!aMailWindowController)
	{
	  DESTROY(_folder);
	  return;
	}
      
      if ([[aMailWindowController folder] isKindOfClass: [CWIMAPFolder class]])
	{
	  [self _setState: YES];
	}
      
      // We get all the indexes from our messages found
      if ([theResults count])
	{
	  id dataView;
	  
	  dataView = [aMailWindowController dataView];	  
	  
	  [dataView deselectAll: nil];
	  [_indexes removeAllObjects];
	  
	  // We add the index of our rows.. and we select the rows..
	  [[FindWindowController singleInstance] _selectIndexesFromResults: theResults
						 controller: aMailWindowController];
	  
	  // If we found only one result, we automatically scroll to that row
	  if ([theResults count] == 1 && [_indexes count] > 0)
	    {
	      [dataView scrollRowToVisible: [[_indexes objectAtIndex: 0] intValue]];
	    }
	  
	  [dataView setNeedsDisplay: YES];
	}
      else
	{
	  NSBeep();
	}
      
      [foundLabel setStringValue: 
	[NSString stringWithFormat: @"%lu found", (long unsigned)[theResults count]]];
      ADD_CONSOLE_MESSAGE(_(@"Done searching. %lu results found."), (long unsigned)[theResults count]);
    }
  else
    {
      [foundLabel setStringValue: _(@"Search failed.")];
      [self _setState: YES];
    }
}

//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[FindWindowController alloc] initWithWindowNibName: @"FindWindow"];
    }
  
  return singleInstance;
}

@end


//
// FindWindowController Private implementation
//
@implementation FindWindowController (Private)

- (void) _folderCloseCompleted: (NSNotification *) theNotification
{
  if ([[theNotification userInfo] objectForKey: @"Folder"] == _folder)
    {
      [foundLabel setStringValue: @""];
      [_indexes removeAllObjects];
      DESTROY(_folder);
      _location = 0;
    }
}

//
//
//
- (void) _selectIndexesFromResults: (NSArray *) theResults
                        controller: (MailWindowController *) theMailWindowController
{
  NSArray *allMessages;

  NSUInteger i, msgIndex, count;
  id tableView;
 
  tableView = [theMailWindowController dataView];

  allMessages = [theMailWindowController allMessages];
  count = [theResults count];
  
  for (i = 0; i < count; i++)
    {
      msgIndex = [allMessages indexOfObject: [theResults objectAtIndex: i]];
      
      if ( msgIndex != NSNotFound )
	{
	  [_indexes addObject: [NSNumber numberWithInt: msgIndex]];
	  [tableView selectRow: msgIndex  byExtendingSelection: YES];
	}
    }
}

//
//
//
- (void) _setState: (BOOL) theState
{
  [findAllButton setEnabled: theState];
  [nextButton setEnabled: theState];
  [previousButton setEnabled: theState];
}

@end
