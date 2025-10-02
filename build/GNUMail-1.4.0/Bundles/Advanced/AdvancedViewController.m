/*
**  AdvancedViewController.m
**
**  Copyright (c) 2002-2007 Ludovic Marcotte
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

#include "AdvancedViewController.h"

#include "Constants.h"

#ifndef MACOSX
#include "AdvancedView.h"
#endif

#include <stdlib.h>


static AdvancedViewController *singleInstance = nil;

typedef struct _row
{
  NSString *option;
  NSString *key;
  int value;
} row;

static row *rows;
#ifdef MACOSX
#define COUNT 14
#else
#define COUNT 13
#endif
#define SET_VALUES(i, v1, v2, v3) \
 rows[i].option = RETAIN(v1); \
 rows[i].key = v2; \
 rows[i].value = v3


//
//
//
@implementation AdvancedViewController

- (id) initWithNibName: (NSString *) theName
{
  NSButtonCell *cell;
  
  self = [super init];

  rows = (row *)malloc(COUNT * sizeof(row));

  SET_VALUES(0, _(@"Compact mailbox when closing"), @"COMPACT_MAILBOX_ON_CLOSE", NSOffState);
  SET_VALUES(1, _(@"Prompt before compacting a mailbox"), @"PROMPT_BEFORE_COMPACT", NSOffState);
  SET_VALUES(2, _(@"Automatically thread messages"), @"AutomaticallyThreadMessages", NSOffState);
  SET_VALUES(3, _(@"Open the Console window on startup"), @"OPEN_CONSOLE_ON_STARTUP", NSOffState);
#ifndef MACOSX
  SET_VALUES(4, _(@"Open the Mailboxes window on startup"), @"OPEN_MAILBOXMANAGER_ON_STARTUP", NSOffState);
#else
  SET_VALUES(4, _(@"Open the Mailboxes drawer automatically"), @"OPEN_MAILBOXMANAGER_ON_STARTUP", NSOffState);
#endif
  SET_VALUES(5, _(@"Enable continuous spell checking"), @"ENABLE_SPELL_CHECKING", NSOffState);
  SET_VALUES(6, _(@"Open last mailbox on startup"), @"OPEN_LAST_MAILBOX", NSOnState);
  SET_VALUES(7, _(@"Do not select the first unread message"), @"DoNoSelectFirstUnread", NSOffState);

  SET_VALUES(8, _(@"Use maildir mailbox format"), @"UseMaildirMailboxFormat", NSOffState);
  SET_VALUES(9, _(@"Show unread messages count only in INBOX mailboxes"), @"ShowUnreadForInboxOnly", NSOffState);

  SET_VALUES(10, _(@"Hide deleted messages on startup"), @"HIDE_DELETED_MESSAGES", NSOnState);
  SET_VALUES(11, _(@"Hide read messages on startup"), @"HIDE_READ_MESSAGES", NSOffState);
  SET_VALUES(12, _(@"Highlight URLs in message content"), @"HIGHLIGHT_URL", NSOffState);

#ifdef MACOSX
  SET_VALUES(13, _(@"Use small scrollers"), @"SCROLLER_SIZE", NSOffState);
#endif

#ifdef MACOSX
  if (![NSBundle loadNibNamed: theName  owner: self])
    {
       AUTORELEASE(self);
      return nil;
    }

  RETAIN(view);
#else
  // We link our view
  view = [[AdvancedView alloc] initWithParent: self];
  [view layoutView];

  // We link our outlets
  tableView = ((AdvancedView*)view)->tableView;
  optionsColumn = ((AdvancedView*)view)->optionsColumn;
  enabledColumn = ((AdvancedView*)view)->enabledColumn;
#endif

  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSSwitchButton];
  [cell setImagePosition: NSImageOnly];
  [cell setControlSize: NSSmallControlSize];
  [[tableView tableColumnWithIdentifier: @"enabled"] setDataCell: cell];
  RELEASE(cell);
  
  // We get our defaults for this panel
  [self initializeFromDefaults];

  return self;
}


//
//
//
- (void) dealloc
{
  int i;

  NSDebugLog(@"AdvancedViewController: -dealloc");
  
  // Cocoa bug?
#ifdef MACOSX
  [tableView setDataSource: nil];
#endif

  for (i = 0; i < COUNT; i++)
    {
      RELEASE(rows[i].option);
    }

  free(rows);

  singleInstance = nil;
  RELEASE(view);

  [super dealloc];
}


//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];
  
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"advanced" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Advanced");
}


//
//
//
- (NSView *) view
{
  return view;
}

- (BOOL) hasChangesPending
{
  return YES;
}


//
//
//
- (void) initializeFromDefaults
{
  int i;

  for (i = 0; i < COUNT; i++)
    {
      if ([[NSUserDefaults standardUserDefaults] objectForKey: rows[i].key])
	{
	  rows[i].value = [[NSUserDefaults standardUserDefaults] integerForKey: rows[i].key];
	}
    }
}


//
//
//
- (void) saveChanges
{ 
  int i;

  for (i = 0; i < COUNT; i++)
    {
      [[NSUserDefaults standardUserDefaults] setInteger: rows[i].value
					     forKey: rows[i].key];
    }
}


//
// Data Source methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  return COUNT;
}


//
//
//
- (id)           tableView: (NSTableView *)aTableView
 objectValueForTableColumn: (NSTableColumn *)aTableColumn 
		       row: (NSInteger)rowIndex
{
  if (aTableColumn == optionsColumn)
    {
      return rows[rowIndex].option;
    }

  return [NSNumber numberWithBool: (rows[rowIndex].value == NSOnState)];
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
  if (rows[rowIndex].value == NSOnState)
    {
      rows[rowIndex].value = NSOffState;
    }
  else
    {
      rows[rowIndex].value = NSOnState;
    }
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[AdvancedViewController alloc] initWithNibName: @"AdvancedView"];
    }

  return singleInstance;
}

@end
