/*
**  MailWindowController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2014-2020 Riccardo Mottola
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

#import "MailWindowController.h"

#import "AddressBookController.h"
#import "ApplicationIconController.h"
#import "ConsoleWindowController.h"
#import "Constants.h"
#import "EditWindowController.h"
#import "ExtendedCell.h"
#import "ExtendedOutlineView.h"
#import "ExtendedTableView.h"
#import "ExtendedWindow.h"
#import "GNUMail.h"
#import "GNUMailBundle.h"
#import "LabelWidget.h"

#import "Filter.h"
#import "FilterManager.h"
#import "FolderNode.h"
#import "FolderNodePopUpItem.h"
#import "ImageTextCell.h"
#import "MailboxManagerCache.h"
#import "MailboxManagerController.h"
#import "MailboxInspectorPanelController.h"
#import "MailHeaderCell.h"
#import "ThreadArcsCell.h"
#import "MessageViewWindowController.h"
#import "MimeType.h"
#import "MimeTypeManager.h"
#import "NSFont+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWContainer.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolder.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWPOP3Folder.h>
#import <Pantomime/CWPOP3Store.h>
#import <Pantomime/CWPOP3CacheManager.h>
#import <Pantomime/CWTCPConnection.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/CWVirtualFolder.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#define UPDATE_STATUS_LABEL(format, args...) \
  [label setStringValue: [NSString stringWithFormat: format, ##args]]; \
  [label setNeedsDisplay: YES];

//
// Private interface for MailWindowController
//
@interface MailWindowController (Private)

- (void) _closeAllMessageViewWindows;
- (void) _filtersHaveChanged: (NSNotification *) theNotification;
- (void) _fontValuesHaveChanged;
- (void) _loadAccessoryViews;
- (BOOL) _moveMessageToTrash: (CWMessage *) theMessage;
- (void) _reloadMessageList: (NSNotification *) theNotification;
- (void) _reloadTableColumns: (id) sender;
- (void) _restoreSortingOrder;
- (void) _restoreSplitViewSize;
- (void) _setIndicatorImageForTableColumn: (NSTableColumn *) aTableColumn;
- (void) _showMessage: (id) sender;
- (void) _zeroIndexOffset;
- (BOOL) _isMessageMatching: (NSString *) match 
		      index: (int) index;

@end


//
//
//
@implementation MailWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
  NSToolbar *aToolbar;
  NSInteger scrollerSize;

  self = [super initWithWindowNibName: windowNibName];

  _allVisibleMessages = [[NSMutableArray alloc] init];
  _noResetSearchField = NO;

  allowedToolbarItemIdentifiers = [[NSMutableArray alloc] initWithObjects: NSToolbarSeparatorItemIdentifier,
							  NSToolbarSpaceItemIdentifier,
							  NSToolbarFlexibleSpaceItemIdentifier,
							  NSToolbarCustomizeToolbarItemIdentifier, 
							  @"delete",
							  @"retrieve",
							  @"mailbox",
							  @"compose",
							  @"reply",
							  @"forward",
							  @"addresses",
							  @"find",
                                                          @"fastfind",
							  @"navigation",
							  nil];

  additionalToolbarItems = [[NSMutableDictionary alloc] init];


  // We set our window title
  [[self window] setTitle: @""];

  // We initialize our toolbar
  aToolbar = [[NSToolbar alloc] initWithIdentifier: @"MailWindowToolbar"];
  [aToolbar setDelegate: self];
  [aToolbar setAllowsUserCustomization: YES];
  [aToolbar setAutosavesConfiguration: YES];
  [[self window] setToolbar: aToolbar];
  RELEASE(aToolbar);

  //
  // We create all table columns
  //
  flaggedColumn = [[NSTableColumn alloc] initWithIdentifier: @"Flagged"];
  [flaggedColumn setEditable: YES];
  [flaggedColumn setResizable: NO];
  [[flaggedColumn headerCell] setImage: [NSImage imageNamed: @"flagged-flag.tiff"]];
  [flaggedColumn setMinWidth: 17];
  [flaggedColumn setMaxWidth: 17];

  statusColumn = [[NSTableColumn alloc] initWithIdentifier: @"Status"];
  [statusColumn setEditable: NO];
  [statusColumn setResizable: YES];
  [[statusColumn headerCell] setImage: [NSImage imageNamed: @"recent-flag.tiff"]];
  [statusColumn setMinWidth: 17];
  [statusColumn setMaxWidth: 17];

  idColumn = [[NSTableColumn alloc] initWithIdentifier: @"#"];
  [idColumn setEditable: NO];
  [idColumn setResizable: YES];
  [[idColumn headerCell] setStringValue: @"#"];
  [idColumn setMinWidth: 40];
  [idColumn setMaxWidth: 40];
  
  dateColumn = [[NSTableColumn alloc] initWithIdentifier: @"Date"];
  [dateColumn setEditable: NO];
  [dateColumn setResizable: YES];
  [[dateColumn headerCell] setStringValue: _(@"Date")];
  [dateColumn setMinWidth: 85];
  [[dateColumn headerCell] setAlignment: NSLeftTextAlignment];
  
  fromColumn = [[NSTableColumn alloc] initWithIdentifier: @"From"];
  [fromColumn setEditable: NO];
  [fromColumn setResizable: YES];
  [[fromColumn headerCell] setStringValue: _(@"From")];
#ifdef MACOSX
  [fromColumn setMinWidth: 120];
  [fromColumn setWidth: 120];
#else
  [fromColumn setMinWidth: 155];
#endif
  [[fromColumn headerCell] setAlignment: NSLeftTextAlignment];
  [[fromColumn dataCell] setWraps: NO];
  
  subjectColumn = [[NSTableColumn alloc] initWithIdentifier: @"Subject"];
  [subjectColumn setEditable: NO];
  [subjectColumn setResizable: YES];
  [[subjectColumn headerCell] setStringValue: _(@"Subject")];
  [subjectColumn setMinWidth: 195];
#ifdef MACOSX
  [subjectColumn setWidth: 260];
#endif
  [subjectColumn setWidth: 195];
  [[subjectColumn headerCell] setAlignment: NSLeftTextAlignment];
  [[subjectColumn dataCell] setWraps: NO];

  sizeColumn = [[NSTableColumn alloc] initWithIdentifier: @"Size"];
  [sizeColumn setEditable: NO];
  [sizeColumn setResizable: YES];
  [[sizeColumn headerCell] setStringValue: _(@"Size")];
  [sizeColumn setMinWidth: 50];
  [sizeColumn setMaxWidth: 70];
  [[sizeColumn headerCell] setAlignment: NSRightTextAlignment];


  // We create our mail header cell
  mailHeaderCell = [[MailHeaderCell alloc] init];
  [mailHeaderCell setController: self];

  // We create our thread arcs cell
  threadArcsCell = [[ThreadArcsCell alloc] init];
  [threadArcsCell setController: self];

  // We set our custom cell
  [flaggedColumn setDataCell: AUTORELEASE([[ExtendedCell alloc] init])];
  [statusColumn setDataCell: AUTORELEASE([[ExtendedCell alloc] init])];

  // We set our data view type
  [self setDataViewType: 0];

  // We load our accessory views
  [self _loadAccessoryViews];

  // We restore our split view knob position
  [self _restoreSplitViewSize];

  // We restore our sorting order
  [self _restoreSortingOrder];
  
  // We register the window for dragged types. This is required to show
  // our drawer when we are dragging near the window's borders.
  [[self window] registerForDraggedTypes: [NSArray arrayWithObject: MessagePboardType]];

  // We set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"MailWindow"];
  [[self window] setFrameUsingName: @"MailWindow"];
  
  // We tile our windows
  if ([GNUMail lastMailWindowOnTop] &&
      [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [self class]])
    {
      NSRect aRect;

      aRect = [[GNUMail lastMailWindowOnTop] frame];
      aRect.origin.x += 15;
      aRect.origin.y -= 10;
      [[self window] setFrame: aRect  display: NO];
    }
  
  // Set the sizes for the scroll bars
  scrollerSize = ([[NSUserDefaults standardUserDefaults] integerForKey: @"SCROLLER_SIZE" default: NSOffState] == NSOffState ? NSRegularControlSize : NSSmallControlSize);
  
  [[tableScrollView verticalScroller] setControlSize: scrollerSize];
  [[tableScrollView horizontalScroller] setControlSize: scrollerSize];
  [[textScrollView verticalScroller] setControlSize: scrollerSize];
  [[textScrollView horizontalScroller] setControlSize: scrollerSize];
  
  // Set our textview to non-editable
  [textView setEditable: NO];
  
  // Set ourselves up as the delegate
  [textView setDelegate: self];
 
  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"MailWindowController: -dealloc");

  [[self window] setDelegate: nil]; // FIXME not necessary in coca and in gnustep as of 2014-02-11, only for compatibility with old releases
  [[NSNotificationCenter defaultCenter] 
    removeObserver: mailHeaderCell
    name: @"NSViewFrameDidChangeNotification" 
    object: textView];
  
  [[NSNotificationCenter defaultCenter] removeObserver: self];

  // We relaser our header cell and our array holding all MessageViewWindow:s
  RELEASE(mailHeaderCell);
  RELEASE(threadArcsCell);
  RELEASE(allMessageViewWindowControllers);

  // We release our NSDrawer's extended outline view
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      RELEASE(outlineView);
    }

  RELEASE(_allVisibleMessages);

  // We release our context menu
  RELEASE(menu);

  // We cleanup the ivars used for our dataView's data source  
  TEST_RELEASE(_allMessages);

  // We release our table columns
  RELEASE(flaggedColumn);
  RELEASE(statusColumn);
  RELEASE(idColumn);
  RELEASE(dateColumn);
  RELEASE(fromColumn);
  RELEASE(subjectColumn);
  RELEASE(sizeColumn);

  RELEASE(allowedToolbarItemIdentifiers);
  RELEASE(additionalToolbarItems);

  RELEASE(searchField);
  
  // We finally release our folder and all the FolderNode:s
  RELEASE(_folder);
  RELEASE(allNodes);
  
  [super dealloc];
}


//
// action methods
//
- (IBAction) clickedOnDataView: (id) sender
{
  CWMessage *aMessage;
  CWFlags *theFlags;
  NSInteger row, column;
  
  column = [dataView clickedColumn];
 
  if (column != [[dataView tableColumns] indexOfObject: flaggedColumn])
    {
      return;
    }
  
  row = [dataView clickedRow];
  aMessage = [_allVisibleMessages objectAtIndex: row];

  theFlags = [[aMessage flags] copy];  
  if (![theFlags contain: PantomimeFlagged])
    {
      [theFlags add: PantomimeFlagged];
    }
   else
    {
      [theFlags remove: PantomimeFlagged];
    }

  [aMessage setFlags: theFlags];
  [dataView setNeedsDisplayInRect: [dataView rectOfRow: row]];		  
  RELEASE(theFlags);
}


//
//
//
- (IBAction) doubleClickedOnDataView: (id) sender
{
  // We ignore a double-click on a table column
  if ((sender != self) && [dataView clickedRow] < 0)
    {
      return;
    }
  
  // If we are in the Draft folder, we re-opened the selected mail for editing
  if ([Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: _folder]  
		 isEqualTo: @"DRAFTSFOLDERNAME"])
    {
      [[NSApp delegate] restoreDraft: nil];
    }
  // Or, we just 'reply' to the mail or open it in a separate window.
  else
    {
      if ([[NSUserDefaults standardUserDefaults] integerForKey: @"DOUBLECLICKACTION"  default: ACTION_VIEW_MESSAGE] == ACTION_VIEW_MESSAGE)
      	{
	  [self viewMessageInWindow: nil];
	  [self updateStatusLabel];
	}
      else if ([[NSUserDefaults standardUserDefaults] integerForKey: @"DOUBLECLICKACTION"] == ACTION_REPLY_TO_MESSAGE)
      	{
	  [self replyToMessage: sender];
	}
    }
}


// 
//
//
- (IBAction) deleteMessage: (id) sender
{
  // If we have no element (or no selection), we return!
  if ([_folder countVisible] == 0 || [dataView numberOfSelectedRows] == 0)
    {
      NSBeep();
      return;
    } 
  else
    {
      NSArray *selectedRows;      
      CWMessage *theMessage;
      CWFlags *theFlags;
      NSNumber *aRow;

      NSInteger i, last_row, first_row;
      BOOL firstFlagOfList;
      
      selectedRows = [[dataView selectedRowEnumerator] allObjects];
      _noResetSearchField = YES;
      firstFlagOfList = NO;
      first_row = -1;
      last_row = 0;
      
      for (i = 0; i < [selectedRows count]; i++)
	{
	  aRow = [selectedRows objectAtIndex: i];

	  if (first_row < 0) 
	    {
	      first_row = [aRow intValue];
	    }

	  theMessage = [_allVisibleMessages objectAtIndex: (NSUInteger)[aRow intValue]];

	  // We set the flag Deleted (or not) to the message
	  theFlags = AUTORELEASE([[theMessage flags] copy]);

          if (i == 0)
            {
              // This is the first message of the list we want to {un}delete
              // We must save the flag.
              if ([theFlags contain: PantomimeDeleted] && ![sender isKindOfClass: [ExtendedWindow class]])
                {
                  [theFlags remove: PantomimeDeleted];
                  firstFlagOfList = NO;
                }
              else
                {
                  [theFlags add: PantomimeDeleted];
                  firstFlagOfList = YES;
                }
            }
          else
            {
              if (!firstFlagOfList && [theFlags contain: PantomimeDeleted] && ![sender isKindOfClass: [ExtendedWindow class]])
                { 
                  [theFlags remove: PantomimeDeleted];
                }
              else if (firstFlagOfList && (![theFlags contain: PantomimeDeleted]))
                {
                  [theFlags add: PantomimeDeleted];
                }
            }
	  
	  last_row = [aRow intValue];

	  // If we are {un}deleting more than one message,
	  // lets optimize things (mosly for IMAP)
	  if ([selectedRows count] > 1)
	    {
	      [_folder setFlags: theFlags
		       messages: [self selectedMessages]];
	      last_row = [[selectedRows lastObject] intValue];
	      i = [selectedRows count];
	      break;
	    }
	  
	  //
	  // If we are using IMAP and hiding messages marked as "deleted", let's now move them at least
	  // to the Trash folder.
	  //
	  if (![_folder showDeleted])
	    {
	      if (![self _moveMessageToTrash: theMessage]) return;
	    }

	  // We finally set our new flags
	  [theMessage setFlags: theFlags];
	}
            
      // We always refresh our dataView after a delete operation
      _noResetSearchField = YES;
      [self _reloadMessageList: nil];
      
      // We now select the row right after the message(s) beeing deleted
      // If we're in reverse order, we select the previous row, otherwise, the next one.
      if (sender == delete || sender == self || [sender isKindOfClass: [ExtendedWindow class]])
	{
	  NSInteger count, row_to_select;
	  
	  count = [dataView numberOfRows];
	  row_to_select = last_row;

	  if (count > 0)
	    {
	      if ([dataView isReverseOrder])
		{
		  row_to_select--;

		  if ([_folder showDeleted])
		    {
		      row_to_select = --first_row;
		    }
		}
	      else
		{
		  // If we show the mails marked as DELETE, we jump to the next mail.
		  // Otherwise, we just try to show the same index again.
		  if ([_folder showDeleted])
		    {
		      row_to_select = ++last_row;
		    }
		  if (i > 1)
		    {
		      row_to_select = (last_row - i);
		    }
		}
	      
	      // We ensure ourself row_to_select is inbounds.
	      if (row_to_select >= count)
		{
		  row_to_select = (count - 1);
		}
	      else if (row_to_select < 0)
		{
		  row_to_select = 0;
		}

	      [dataView selectRow: row_to_select  byExtendingSelection: NO];
	      [dataView scrollRowToVisible: row_to_select];
	    }
	}


      // We update the status label
      [self updateStatusLabel];
    }
}


//
//
//
- (IBAction) nextInThread: (id) sender
{
  if ([_folder allContainers])
    {
      CWContainer *aContainer;
      CWMessage *aMessage;
      NSInteger row;

      aMessage = [self selectedMessage];

      // If no message is selected...
      if (!aMessage)
	{
	  return;
	}

      aContainer = [aMessage propertyForKey: @"Container"];
      aContainer = [[aContainer childrenEnumerator] nextObject];

      // If we have reached the first message...
      if (!aContainer)
	{
	  return;
	}

      row = [_allVisibleMessages indexOfObject: aContainer->message];
      [dataView selectRow: row  byExtendingSelection: NO];
      [dataView scrollRowToVisible: row];
    }
}


//
// This method selects the message after the current
// selected message and displays it.
//
- (IBAction) nextMessage: (id) sender
{
  NSInteger row;
  
  row = [dataView selectedRow];
  
  if (row == -1 ||
      row >= ([dataView numberOfRows] - 1) ) 
    {
      NSBeep();
    }
  else
    {
      [dataView selectRow: (row+1)  byExtendingSelection: NO];
      [dataView scrollRowToVisible: (row+1)];
    }
}


//
//
//
- (IBAction) nextUnreadMessage: (id) sender
{
  NSInteger count, row, i;
  
  row = [dataView selectedRow];
  
  if (row == -1)
    {
      NSBeep();
    }
  else
    {
      count = [_allVisibleMessages count];
      for (i = row; i < count; i++)
	{
	  if (![[[_allVisibleMessages objectAtIndex: i] flags] contain: PantomimeSeen])
	    {
	      [dataView selectRow: i  byExtendingSelection: NO];
	      [dataView scrollRowToVisible: i];
	      return;
	    }
	}
      
      // We haven't found an unread message, simply call -nextMessage
      [self nextMessage: sender];
    }
}


//
//
//
- (IBAction) firstMessage: (id) sender
{
  if ([dataView numberOfRows] > 0)
    {
      [dataView selectRow: 0  byExtendingSelection: NO];
      [dataView scrollRowToVisible: 0];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) lastMessage: (id) sender
{
  if ([dataView numberOfRows] > 0)
    {
      [dataView selectRow: ([dataView numberOfRows] - 1)  byExtendingSelection: NO];
      [dataView scrollRowToVisible: ([dataView numberOfRows] - 1)];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) pageDownMessage: (id) sender
{
  NSRect aRect;
  double origin;

  aRect = [textScrollView documentVisibleRect];
  origin = aRect.origin.y;
  
  aRect.origin.y += aRect.size.height - [textScrollView verticalPageScroll];
  [textView scrollRectToVisible: aRect];
  
  aRect = [textScrollView documentVisibleRect];
  
  // If we haven't scrolled at all (since the origins are equal), show the next message
  if (aRect.origin.y == origin)
    {
      [self nextMessage: nil];
    } 
}


//
//
//
- (IBAction) pageUpMessage: (id) sender
{
  NSRect aRect;
  double origin;

  aRect = [textScrollView documentVisibleRect];
  origin = aRect.origin.y;

  aRect.origin.y -= aRect.size.height - [textScrollView verticalPageScroll];
  [textView scrollRectToVisible: aRect];

  aRect = [textScrollView documentVisibleRect];

  // If we haven't scrolled at all (since the origins are equal), show the previous message
  if (aRect.origin.y == origin)
    {
      [self previousMessage: nil];
    }
}


//
//
//
- (IBAction) previousInThread: (id) sender
{
  if ([_folder allContainers])
    {
      CWContainer *aContainer;
      CWMessage *aMessage;
      NSInteger row;

      aMessage = [self selectedMessage];

      // If no message is selected...
      if (!aMessage)
	{
	  return;
	}

      aContainer = [aMessage propertyForKey: @"Container"];
      aContainer = aContainer->parent;

      // If we have reached the first message...
      if (!aContainer)
	{
	  return;
	}

      row = [_allVisibleMessages indexOfObject: aContainer->message];
      [dataView selectRow: row  byExtendingSelection: NO];
      [dataView scrollRowToVisible: row];
    }
}


//
// This method selects the message before the current
// selected message and displays it.
//
- (IBAction) previousMessage: (id) sender
{
  NSInteger row;

  row = [dataView selectedRow];
  
  if (row > 0)
    {
      [dataView selectRow: (row-1)  byExtendingSelection: NO];
      [dataView scrollRowToVisible: (row-1)];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) previousUnreadMessage: (id) sender
{
  NSInteger row, i;
  
  row = [dataView selectedRow];
  
  if (row == -1)
    {
      NSBeep();
    }
  else
    {
      for (i = row; i >= 0; i--)
	{
	  if (![[[_allVisibleMessages objectAtIndex: i] flags] contain: PantomimeSeen])
	    {
	      [dataView selectRow: i  byExtendingSelection: NO];
	      [dataView scrollRowToVisible: i];
	      return;
	    }
	}
      
      // We haven't found an unread message, simply call -previousMessage
      [self previousMessage: sender];
    }
}


//
// If the sender is the application's delegate, we reply to all
// recipients. It's only invoked that way from GNUMail: -replyAllMessage.
//
- (IBAction) replyToMessage: (id) sender
{
  if ([dataView selectedRow] < 0) 
    {
      NSBeep();
      return;
    }
  
  [Utilities replyToMessage: [self selectedMessage]
	     folder: _folder
	     mode: [sender tag]];
}


//
// This opens a new window and displays the message in it.
//
- (IBAction) viewMessageInWindow: (id) sender
{
  MessageViewWindowController *aViewWindowController;
  CWMessage *aMessage;
  
  if ([dataView selectedRow] < 0)
    {
      NSBeep();
      return;
    }
  
  // We obtain the selected entry in the table for the display informations
  aMessage = [self selectedMessage];
  
  // We create our window controller
  aViewWindowController = [[MessageViewWindowController alloc] initWithWindowNibName: @"MessageViewWindow"];
  
  // set our message and folder
  [aViewWindowController setMessage: aMessage];
  [aViewWindowController setFolder: _folder];
  [aViewWindowController setMailWindowController: self];  
  
  // show the window and the message
  [aViewWindowController showWindow: self];
  [allMessageViewWindowControllers addObject: aViewWindowController];

  [Utilities showMessage: aMessage
	     target: [aViewWindowController textView]
	     showAllHeaders: [self showAllHeaders]];

  // On MacOS X, if the mail window is not active, double-clicking on an unselected message
  // causes the message not to draw itself in the new window that pops up.
  // Let's force it to draw itself.
#ifdef MACOSX
  [[aViewWindowController textView] setNeedsDisplay: YES];
#endif

}

//
//
//
- (IBAction) markMessageAsReadOrUnread: (id) sender
{
  NSEnumerator *anEnumerator;
  CWMessage *aMessage;
    
  // We mark our message as read (or not)
  anEnumerator = [[self selectedMessages] objectEnumerator];
    
  while ((aMessage = [anEnumerator nextObject]))
    {
      // If we must mark all messages as read
      if ([sender tag] == MARK_AS_READ)
        {
          if (![[aMessage flags] contain: PantomimeSeen])
            {
              CWFlags *theFlags;
                  
              theFlags = [[aMessage flags] copy];
              [theFlags add: PantomimeSeen];
              [aMessage setFlags: theFlags];
              RELEASE(theFlags);
            }
        }
      // Else, we must mark them all as unread
      else
        {
          if ([[aMessage flags] contain: PantomimeSeen])
            {
              CWFlags *theFlags;
                  
              theFlags = [[aMessage flags] copy];
              [theFlags remove: PantomimeSeen];
              [aMessage setFlags: theFlags];
              RELEASE(theFlags);
            }
        }
      } // while (...)
    
  // We always refresh our dataView and our status label
  [[self dataView] setNeedsDisplay: YES];
  [self updateStatusLabel];
}

//
//
//
- (IBAction) markMessageAsFlaggedOrUnflagged: (id) sender
{
  NSEnumerator *anEnumerator;
  CWMessage *aMessage;
    
  // We mark our message as flagged (or not)
  anEnumerator = [[self selectedMessages] objectEnumerator];
    
  while ((aMessage = [anEnumerator nextObject]))
    {
      // If we must mark all messages as flagged
      if ([sender tag] == MARK_AS_FLAGGED)
        {
          if ( ![[aMessage flags] contain: PantomimeFlagged] )
            {
              CWFlags *theFlags;
                  
              theFlags = [[aMessage flags] copy];
              [theFlags add: PantomimeFlagged];
              [aMessage setFlags: theFlags];
              RELEASE(theFlags);
            }
        }
        // Else, we must mark them all as unflagged
      else
        {
          if ([[aMessage flags] contain: PantomimeFlagged])
            {
              CWFlags *theFlags;
                  
              theFlags = [[aMessage flags] copy];
              [theFlags remove: PantomimeFlagged];
              [aMessage setFlags: theFlags];
              RELEASE(theFlags);
            }
        }
      } // while (...)
    
  // We always refresh our dataView and our status label
  [[self dataView] setNeedsDisplay: YES];
  [self updateStatusLabel];
}

//
// This method returns the folder associated to this MailWindow.
//
- (CWFolder *) folder
{
  return _folder;
}


//
// This method sets the folder associated to this MailWindow.
//
// NOTE: This method DOES NOT close the folder. It'll release it
//       but the folder SHOULD BE CLOSED FIRST.
//
- (void) setFolder: (CWFolder *) theFolder
{ 
  ASSIGN(_folder, theFolder);

  [dataView deselectAll: self];
      
  // We close all MessageViewWindows
  [self _closeAllMessageViewWindows];
  [self updateWindowTitle];

  // We now set the window title
  if (!_folder)
    {
      UPDATE_STATUS_LABEL(_(@"No mailbox selected"));
      [self tableViewShouldReloadData];
      return;
    }

  UPDATE_STATUS_LABEL(_(@"Opening the mailbox..."));
  
  if ([_folder isKindOfClass: [CWVirtualFolder class]])
    {
      [(CWVirtualFolder *)_folder setDelegate: self];
    }
  
  // We verify if we need to rename our From column to "To" in case we are in the Sent
  // or Drafts folder.
  if ([Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: _folder]  
		 isEqualTo: @"DRAFTSFOLDERNAME"] ||
      [Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: _folder]  
		 isEqualTo: @"SENTFOLDERNAME"])
    {
      [[fromColumn headerCell] setStringValue: _(@"To")];
      draftsOrSentFolder = YES;
    }
  else
    {
      [[fromColumn headerCell] setStringValue: _(@"From")];
      draftsOrSentFolder = NO;
    }
}


//
// NSTableView delegate/datasource methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  return [_allVisibleMessages count];
}


//
//
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row: (NSInteger) rowIndex
{
  CWMessage *aMessage;
  
  aMessage = [_allVisibleMessages objectAtIndex: rowIndex];

  if (aTableColumn == idColumn)
    {
      return [NSString stringWithFormat: @"%d", [aMessage messageNumber]];
    }
  else if (aTableColumn == dateColumn)
    {   
      NSCalendarDate *date;

      date = [aMessage receivedDate];

      if (!date)
	{
	  return nil;
	}
      else
	{
	  NSUserDefaults *aUserDefaults; 
	  NSString *aString;
	  int day, today;
	  
	  aUserDefaults = [NSUserDefaults standardUserDefaults];      
	  
	  [date setTimeZone: [NSTimeZone localTimeZone]];
	  day = [date dayOfCommonEra];
	  today = [[NSCalendarDate calendarDate] dayOfCommonEra];
	  
	  if ( day == today )
	    {
	      aString = [aUserDefaults objectForKey: NSTimeFormatString];
	    }
	  else if ( day == today-1 )
	    {
	      aString = [NSString stringWithFormat: @"%@ %@",
				  [[aUserDefaults objectForKey: NSPriorDayDesignations] objectAtIndex: 0],
				  [aUserDefaults objectForKey: NSTimeFormatString]];
	    }
	  else
	    { 
	      aString = [aUserDefaults objectForKey: NSShortDateFormatString];
	    }
	  
	  if (!aString)
	    {
	      aString = @"%b %d %Y";
	    }
	  
	  return [date descriptionWithCalendarFormat: aString
		       timeZone: [date timeZone]
		       locale: nil];
	}
    }
  else if (aTableColumn == fromColumn)
    {
      CWInternetAddress *aInternetAddress;

      // If we are in Sent or Drafts, we show the first To recipient
      if (draftsOrSentFolder)
	{
	  if ([aMessage recipientsCount] > 0)
	    {
	      aInternetAddress = [[aMessage recipients] objectAtIndex: 0];
	    }
	  else
	    {
	      return nil;
	    }
	}
      else
	{
	  aInternetAddress = [aMessage from];
	}

      if (!aInternetAddress)
	{
	  return nil;
	}
      else if ([aInternetAddress personal] == nil || 
	       [[aInternetAddress personal] length] == 0)
	{
	  return [aInternetAddress address];
	}
      else
	{
	  return [aInternetAddress personal];
	}
    }
  else if (aTableColumn == subjectColumn)
    {
      return [aMessage subject];
    }
  else if (aTableColumn == sizeColumn) 
    {
      return [NSString stringWithFormat: @"%.1fKB ", ((float)[aMessage size]/(float)1024)];
    }

  return nil;
}


//
//
//
- (void) tableView: (NSTableView *) theTableView
   willDisplayCell: (id) theCell
    forTableColumn: (NSTableColumn *) theTableColumn
               row: (NSInteger) rowIndex
{
  CWMessage *aMessage;
  CWFlags *theFlags;

  aMessage = [_allVisibleMessages objectAtIndex: rowIndex];
  
  // We get the message's flags
  theFlags = [aMessage flags]; 

  // We verify for a coloring filter. We also don't draw the background color if 
  // the row is selected in the dataView.
  if ([dataView selectedRow] != rowIndex)
    {
      NSColor *aColor;
      
      aColor = [[FilterManager singleInstance] colorForMessage: aMessage];
 
      // We if have a special color coming from our filter, we set it for this cell
      if (aColor)
	{
	  [theCell setDrawsBackground: YES];
	  [theCell setBackgroundColor: aColor];
	}
      else
	{
	  [theCell setDrawsBackground: NO];
	}
    }
  else
    {
      [theCell setDrawsBackground: NO];
    }

  // If it's a new message, we set the cell's text to bold
  if ([theFlags contain: PantomimeSeen])
    {
      [theCell setFont: [NSFont seenMessageFont]];
    }
  else
    {
      [theCell setFont: [NSFont recentMessageFont]];
    }

  // If it's a deleted message, we set the cell's text to italic
  if ([theFlags contain: PantomimeDeleted])
    {
      [theCell setTextColor: [NSColor darkGrayColor]];
      [theCell setFont: [NSFont deletedMessageFont]];
    }
  else
    {
      [theCell setTextColor: [NSColor blackColor]];
    }

  // We set the right aligment for our last (ie., Size) column.
  if (theTableColumn == sizeColumn)
    {
      [theCell setAlignment: NSRightTextAlignment];
    }
  else
    {
      [theCell setAlignment: NSLeftTextAlignment];
    }

  // We set the image of our status cell
  if (theTableColumn == flaggedColumn)
    {
      if ([theFlags contain: PantomimeFlagged])
	{
	  [(ExtendedCell *)[theTableColumn dataCell] setFlags: PantomimeFlagged|PantomimeSeen];
	}
      else
	{
	  [(ExtendedCell *)[theTableColumn dataCell] setFlags: PantomimeSeen];
	}
    }
  else if (theTableColumn == statusColumn)
    {
      [(ExtendedCell *)[theTableColumn dataCell] setFlags: (theFlags->flags&(theFlags->flags^PantomimeFlagged))];
    }
}


//
//
//
- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
  if ([dataView isReloading])
    {
      return;
    }

  showAllHeaders = showRawSource = NO;

  // If we have more than one selected rows or no selection at all, 
  // we clear up the text view.
  if ([dataView numberOfSelectedRows] > 1 ||  [dataView selectedRow] < 0)
    {
      [textView setString: @""];
      
      // We redisplay our dataview since "selectAll" doesn't do it for us.
      [dataView setNeedsDisplay: YES];
    }
  else 
    {
      NSRect r1, r2;

      // We zero all our index's offset
      [self _zeroIndexOffset];
	  
      // We show our message!
      [self _showMessage: self];

      //
      // We now autoscroll intelligently our dataView.
      //
      r1 = [dataView rectOfRow: [dataView selectedRow]];
      r2 = [dataView convertRect: r1  toView: tableScrollView];
      
      if (r2.origin.y < (2*[dataView rowHeight]))
	{
	  r1.origin.y -= (2*[tableScrollView verticalPageScroll]);
	  [dataView scrollRectToVisible: r1];
	}
      else if (r2.origin.y > [tableScrollView contentSize].height)
	{
	  r1.origin.y += (2*[tableScrollView verticalPageScroll]);
	  [dataView scrollRectToVisible: r1];
	}
    }

  [self updateStatusLabel];
  [[MailboxInspectorPanelController singleInstance] setSelectedMessage: [self selectedMessage]];
}


//
//
//
- (void)   tableView: (NSTableView *) aTableView
 didClickTableColumn: (NSTableColumn *) aTableColumn
{
  NSString *newOrder;

  newOrder = [aTableColumn identifier];
  
  if (![newOrder isEqualToString: @"#"]
      && ![newOrder isEqualToString: @"Date"]
      && ![newOrder isEqualToString: @"From"]
      && ![newOrder isEqualToString: @"Subject"]
      && ![newOrder isEqualToString: @"Size"])
    {
      return;
    }
  
  [aTableView setHighlightedTableColumn: aTableColumn];
  [dataView setPreviousSortOrder: [dataView currentSortOrder]];

  if ([[dataView currentSortOrder] isEqualToString: newOrder])
    {
      [dataView setReverseOrder: ![dataView isReverseOrder]];
    }
  else
    {
      [dataView setCurrentSortOrder: newOrder];
      [dataView setReverseOrder: NO];
    }
  
  [self _setIndicatorImageForTableColumn: aTableColumn];
  
  [[NSUserDefaults standardUserDefaults] setObject: [dataView currentSortOrder]
					 forKey: @"SORTINGORDER"];

  [[NSUserDefaults standardUserDefaults] setInteger: [dataView isReverseOrder]
					 forKey: @"SORTINGSTATE"];

  _noResetSearchField = YES;
  [self tableViewShouldReloadData];
}


//
//
//
- (void) tableViewShouldReloadData
{
  NSArray *previousArray;
  SEL sortingSel;

  previousArray = [[NSArray alloc] initWithArray: _allVisibleMessages];
  sortingSel = NULL;
  
  if ([dataView currentSortOrder] == nil)
    {
      [dataView setPreviousSortOrder: @"#"];
      [dataView setCurrentSortOrder: @"#"];
    }
  
  //
  // Sort by #.
  //
  if ([[dataView currentSortOrder] isEqualToString: @"#"])
    {
      if ([dataView isReverseOrder])
	{
	  sortingSel = @selector(reverseCompareAccordingToNumber:);
	}
      else
	{
	  sortingSel = @selector(compareAccordingToNumber:);
	}
    }
  //
  // Sort by Date.
  //
  else if ([[dataView currentSortOrder] isEqualToString: @"Date"])
    {
      if ([dataView isReverseOrder])
	{
	  sortingSel = @selector(reverseCompareAccordingToDate:);
	}
      else
	{
	  sortingSel = @selector(compareAccordingToDate:);
	}
    }
  //
  // Sort by From.
  //
  else if ([[dataView currentSortOrder] isEqualToString: @"From"])
    {
      if ([dataView isReverseOrder])
	{
	  sortingSel = @selector(reverseCompareAccordingToSender:);
	}
      else
	{
	  sortingSel = @selector(compareAccordingToSender:);
	}
    }
  //
  // Sort by Subject.
  //
  else if ([[dataView currentSortOrder] isEqualToString: @"Subject"])
    {
      if ([dataView isReverseOrder])
	{
	  sortingSel = @selector(reverseCompareAccordingToSubject:);
	}
      else
	{
	  sortingSel = @selector(compareAccordingToSubject:);
	}
    }
  //
  // Sort by Size.
  //
  else if ([[dataView currentSortOrder] isEqualToString: @"Size"])
    {
      if ([dataView isReverseOrder])
	{
	  sortingSel = @selector(reverseCompareAccordingToSize:);
	}
      else
	{
	  sortingSel = @selector(compareAccordingToSize:);
	}
    }

  RELEASE(_allMessages);
  _allMessages = RETAIN([[_folder visibleMessages] sortedArrayUsingSelector: sortingSel]);

  //
  // We now select all the messages that were previously selected
  // in the previous order.
  //
  if (previousArray && _folder)
    {
      NSMutableArray *sm;
      NSArray *sc;
      id aMessage;
      
      NSInteger i, index, selectedRow, count, newCount;
      BOOL newSelection;
      NSRange range;

      sc = [[dataView selectedRowEnumerator] allObjects];
      selectedRow = [dataView selectedRow];
      
      count = [sc count];
      newCount = [_allVisibleMessages count];
      range = NSMakeRange(0, newCount);
      
      newSelection = NO;
      
      sm = [[NSMutableArray alloc] initWithCapacity: newCount];
      
      // We get all the previous selected messages (Message objects)
      for (i = 0; i < count; i++)
	{
	  [sm addObject: [previousArray objectAtIndex: (NSUInteger)[[sc objectAtIndex: i] intValue]]];
	}
      
      [sm sortUsingSelector: sortingSel];

      [dataView setReloading: YES];
      [dataView deselectAll: self];
      [dataView reloadData];

      for (i = 0; i < count; i++)
	{
	  aMessage = [sm objectAtIndex: i];
			      
	  index = [_allVisibleMessages indexOfObject: aMessage  inRange: range];

	  if (index != NSNotFound)
	    {
	      [dataView selectRow: index  byExtendingSelection: YES];
	      range = NSMakeRange(index+1, newCount-index-1);
	    }
	  else
	    {
	      newSelection = YES;
	    }
	}

      RELEASE(sm);
      
      if (selectedRow != -1)
	{
	  aMessage = [previousArray objectAtIndex: selectedRow];
	  index = [_allVisibleMessages indexOfObject: aMessage];
	  
	  if (index != NSNotFound)
	    {
	      [dataView selectRow: index
			byExtendingSelection: YES];
	    }
	}
      
      [dataView setReloading: NO];
      
      // If the selection has changed over the previous reload
      if (newSelection)
	{
	  [self tableViewSelectionDidChange: nil];
	}
      
      // We scroll back to a selected row
      if ([dataView selectedRow] != -1)
	{
	  [dataView scrollRowToVisible: [dataView selectedRow]];
	}
    }

  TEST_RELEASE(previousArray);

  [dataView setPreviousSortOrder: [dataView currentSortOrder]];
  
  if (![[searchField stringValue] length])
    {
      _noResetSearchField = NO;
    }
  
  if (!_noResetSearchField)
    {
      [self resetSearchField];
    }
  
  if (_noResetSearchField)
    {
      [self doFind: searchField]; 
      _noResetSearchField = NO;
    }
  
  // We verify if we have at least one selected row, in case we don't, we just clear our textView
  if ([dataView numberOfSelectedRows] != 1)
    {
      [textView setString: @""];
    }

}


//
//
//
- (NSMenu *) dataView: (id) aDataView
    contextMenuForRow: (int) theRow
{
  return menu;
}


//
//
//
-  (void) textView: (NSTextView *) aTextView
     clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	    inRect: (NSRect) cellFrame
	   atIndex: (NSUInteger) charIndex
  
{
  [Utilities clickedOnCell: attachmentCell
	     inRect: cellFrame
	     atIndex: charIndex
	     sender: self];
}


//
//
//
- (BOOL) textView: (NSTextView *) textView
    clickedOnLink: (id) link 
	  atIndex: (NSUInteger) charIndex
{
  return [[NSWorkspace sharedWorkspace] openURL: link];
}


//
// NSTableDataSource Drag and drop
//
- (BOOL) tableView: (NSTableView *) aTableView
	 writeRows: (NSArray *) rows
      toPasteboard: (NSPasteboard *) pboard
{
  NSMutableArray *propertyList;
  NSInteger i, count;

  propertyList = [[NSMutableArray alloc] initWithCapacity: [rows count]];
  count = [rows count];

  for (i = 0; i < count; i++)
    {
      NSMutableDictionary *aDictionary;
      CWMessage *aMessage;

      aDictionary = [[NSMutableDictionary alloc] initWithCapacity: 3];
      aMessage = [_allVisibleMessages objectAtIndex: (NSUInteger)[[rows objectAtIndex: i] intValue]];
      
      //
      // We now set all the properties we must keep in the pasteboard in order
      // to have all the information we need in order to fully transfer the
      // message to the target mailbox. Among the properties, we have:
      //
      // MessageFlags    - The flags of the message
      // MessageData     - Its raw data
      // MessageNumber   - The index of the message in the source folder. We MUST get
      //                   this index by using our folder's allMessages ivar since if 
      //                   we hide deleted messages, the MSN will change.
      //
      [aDictionary setObject: [NSArchiver archivedDataWithRootObject: [aMessage flags]]  forKey: MessageFlags];
      [aDictionary setObject: [NSData dataWithData: [aMessage rawSource]]  forKey: MessageData];   
      [aDictionary setObject: [NSNumber numberWithInt: [[_folder messages] indexOfObject: aMessage]+1]  forKey: MessageNumber];
                  
      [propertyList addObject: aDictionary];
      RELEASE(aDictionary);
    }

  // Set property list of paste board
  [pboard declareTypes: [NSArray arrayWithObject: MessagePboardType] owner: self];
  [pboard setPropertyList: propertyList forType: MessagePboardType];
  RELEASE(propertyList);
  
  return YES;
}


//
// NSTableDataSource Drag and drop
//
- (NSDragOperation) tableView: (NSTableView *) aTableView
		 validateDrop: (id <NSDraggingInfo>) info
		  proposedRow: (NSInteger) row
	proposedDropOperation: (NSTableViewDropOperation) operation

{
  if ([info draggingSource] == dataView)
    {
      // We don't allow drag'n'drop to the same dataView
      return NSDragOperationNone;
    }

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
// NSTableDataSource Drag and drop
//
- (BOOL) tableView: (NSTableView *) aTableView
	acceptDrop: (id <NSDraggingInfo>) info
	       row: (NSInteger) row
     dropOperation: (NSTableViewDropOperation) operation
{
  NSMutableArray *allMessages;
  CWFolder *aSourceFolder;
  NSArray *propertyList;
  NSInteger i, count;
  
  if ([info draggingSource] == dataView)
    {
      // We don't allow drag'n'drop to the same dataView
      return NO;
    }
  
  // We retrieve property list of messages from paste board
  propertyList = [[info draggingPasteboard] propertyListForType: MessagePboardType];
  
  if (!propertyList)
    {
      return NO;
    }

  aSourceFolder = [(MailWindowController *)[[info draggingSource] delegate] folder];
  allMessages = [[NSMutableArray alloc] init];
  count = [propertyList count];

  for (i = 0; i < count; i++)
    {
      [allMessages addObject: [[aSourceFolder messages] objectAtIndex:
					      [[(NSDictionary *)[propertyList objectAtIndex: i]
								objectForKey: MessageNumber] intValue]-1]];
    }
  
  [[MailboxManagerController singleInstance] transferMessages: allMessages
					     fromStore: [aSourceFolder store]
					     fromFolder: aSourceFolder
					     toStore: [_folder store]
					     toFolder: _folder
					     operation: (([info draggingSourceOperationMask]&NSDragOperationGeneric) == NSDragOperationGeneric ? 
							 MOVE_MESSAGES : COPY_MESSAGES)];

  RELEASE(allMessages);

  return YES;
}

//
// When the user types in the mailbox window, we move to a message that
// matches (in some way) the typing.  This is a really wimpy
// search that's really easy to use.  See 'type-ahead' on google.
//
// A message matches a string if the string is contained in the 'From' string or the 
// 'Subject' string.
//
- (void) tableView: (NSTableView *) theTableView
  didReceiveTyping: (NSString *) theString
{
  NSString *cellStringVal;
  NSArray *columns;

  NSInteger row, col, numRows, numCols, initialRow, boundaryRow, rowIncrement;
  
  if ( [[theString stringByTrimmingWhiteSpaces] length] == 0 )
    {
      return;
    }

  // the columns we'll search
  columns = [NSArray arrayWithObjects:fromColumn, subjectColumn, nil];
  
  numRows = [self numberOfRowsInTableView: theTableView];
  numCols = [columns count];
  
  // figure out which way we're going to iterate through the rows
  // if the messages are sorted chronologically, go from newest to oldest
  // otherwise go from top to bottom (of the window)
  if ([[dataView currentSortOrder] isEqualToString: @"Date"] && ![dataView isReverseOrder])
    {
      initialRow = numRows - 1;
      boundaryRow = -1;
      rowIncrement = -1;
    }
  else
    {
      initialRow = 0;
      boundaryRow = numRows;
      rowIncrement = 1;        
    }
  
  for (row = initialRow; row != boundaryRow; row = row + rowIncrement)
    {
      for (col = 0; col < numCols; col++)
        {
	  cellStringVal = [self tableView: theTableView 
				objectValueForTableColumn: [columns objectAtIndex: col]
				row: row];
	  if ( cellStringVal &&
	       ([cellStringVal rangeOfString: theString  options: NSCaseInsensitiveSearch].location != NSNotFound) )
	    {
	      [theTableView selectRow: row  byExtendingSelection: NO];
	      [theTableView scrollRowToVisible: row];
	      return;
            }
        }
    }
}


//
// MailWindowController delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  NSMutableArray *visibleTableColumns;
  NSMutableDictionary *columnWidth;
  NSString *theIdentifier;
  NSInteger i, count;

  //
  // We save the table columns order and width.
  //
  // Ideally, this should be handled by the NSTableView's autosave feature.
  // But it seems to be messing with the dynamic addition and removal of columns.
  //
  visibleTableColumns = [[NSMutableArray alloc] init];
  columnWidth = [[NSMutableDictionary alloc] init];

  count = [[dataView tableColumns] count];
  for (i = 0; i < count; i++)
    {
      theIdentifier = [[[dataView tableColumns] objectAtIndex: i] identifier];
      theIdentifier = ([theIdentifier isEqualToString: @"#"] ? (id)@"Number" : (id)theIdentifier);
 
      [columnWidth setObject: [NSNumber numberWithFloat: [[[dataView tableColumns] objectAtIndex: i] width]]
		   forKey: theIdentifier];
      [visibleTableColumns addObject: theIdentifier];
    }
  
  [[NSUserDefaults standardUserDefaults] setObject: visibleTableColumns  forKey: @"SHOWNTABLECOLUMNS"];
  [[NSUserDefaults standardUserDefaults] setObject: columnWidth  forKey: @"MailWindowColumnWidth"];
  RELEASE(visibleTableColumns);
  RELEASE(columnWidth);
  
  // We save the frames of our split view subviews
  [[NSUserDefaults standardUserDefaults] setObject: NSStringFromRect([tableScrollView frame])  forKey: @"NSTableView Frame MailWindow"];
  [[NSUserDefaults standardUserDefaults] setObject: NSStringFromRect([textScrollView frame])  forKey: @"NSTextView Frame MailWindow"];
    
  // We close all MessageViewWindows.
  [self _closeAllMessageViewWindows];
  
  // We update our last mail window on top if it was the current selected one
  // OR if we decided to re-use the MailWindow - we must set it to nil
  if ( [GNUMail lastMailWindowOnTop] == [self window] || 
       ([[NSUserDefaults standardUserDefaults] objectForKey: @"REUSE_MAILWINDOW"] &&
	[[[NSUserDefaults standardUserDefaults] objectForKey: @"REUSE_MAILWINDOW"] intValue] == NSOnState) )
    {
      [GNUMail setLastMailWindowOnTop: nil];
    }
  
  // We update our current super view for bundles (we set it to nil) and we
  // inform our bundles that the viewing view will be removed from the super view
  count = [[GNUMail allBundles] count];
  for (i = 0; i < count; i++)
    {
      id<GNUMailBundle> aBundle;
      
      aBundle = [[GNUMail allBundles] objectAtIndex: i];
      
      if ( [aBundle hasViewingViewAccessory] )
	{
	  [aBundle setCurrentSuperview: nil];

	  if ( [aBundle viewingViewAccessoryType] == ViewingViewTypeHeaderCell )
	    {
	      [aBundle viewingViewAccessoryWillBeRemovedFromSuperview: mailHeaderCell];
	    }
	  else
	    {
	      [aBundle viewingViewAccessoryWillBeRemovedFromSuperview: [[self window] contentView]];
	    }
	}
    }

#warning FIXME also do that where we close a mailbox (like in MailboxManagerController)
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"COMPACT_MAILBOX_ON_CLOSE"])
    {
      // This allows us to automatically purge messages marked as \Deleted when
      // closing the mailbox.
      if ([_folder isKindOfClass: [CWIMAPFolder class]])
	{
	  [_folder setShowDeleted: NO];
	}
      else
	{
	  [_folder expunge];
	}

      [self updateStatusLabel];
    }
  
  // We definitively close our folder.
  [_folder close];

  // We add a message to our Console
  if ([_folder isKindOfClass: [CWLocalFolder class]])
    {
      ADD_CONSOLE_MESSAGE(_(@"Closed local folder %@."), [_folder name]);
    }
  else
    {
      ADD_CONSOLE_MESSAGE(_(@"Closed IMAP folder %@ on %@."), [_folder name], [(CWIMAPStore *)[_folder store] name]);
    }

  // We clear our 'Save' menu
  count = [[(GNUMail *)[NSApp delegate] saveMenu] numberOfItems];
  while (count > 1)
    {
      count--;
      [[(GNUMail *)[NSApp delegate] saveMenu] removeItemAtIndex: count];
    }
 
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      // We finally unset the mailbox manager's current outline view
      [[MailboxManagerController singleInstance] setCurrentOutlineView: nil];
      [[NSUserDefaults standardUserDefaults] setInteger: [drawer edge]  forKey: @"DrawerPosition"];
    }
  else
    {
      // If we closed the last MailWindow, we deselect all items in
      // the Mailboxes window. We only do that under GNUstep.
      if ([[GNUMail allMailWindows] count] == 0)
	{
	  [[[MailboxManagerController singleInstance] outlineView] deselectAll: self];
	  [[[MailboxManagerController singleInstance] outlineView] setNeedsDisplay: YES];
	}
    }
  
  // We remove our window from our list of opened windows
  [GNUMail removeMailWindow: [self window]];  
}


//
//
//
- (void) windowDidLoad
{
  NSMenuItem *aMenuItem;
  NSMenu *aMenu;

  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      //
      // We set up our NSDrawer's contentView.
      //
      NSTableColumn *mailboxColumn, *messagesColumn;
      NSScrollView *scrollView;
      id aCell;
      NSSize drawerSize;

      mailboxColumn = [[NSTableColumn alloc] initWithIdentifier: @"Mailbox"];
      [mailboxColumn setEditable: YES];
      // FIXME - This is pissing me off on Cocoa.
      [mailboxColumn setMaxWidth: 150];
      [[mailboxColumn headerCell] setStringValue: _(@"Mailbox")];
      
      aCell =  [[ImageTextCell alloc] init];
      [aCell setWraps: NO];
      [mailboxColumn setDataCell: aCell];
      AUTORELEASE(aCell);
      
      messagesColumn = [[NSTableColumn alloc] initWithIdentifier: @"Messages"];
      [messagesColumn setEditable: NO];
      // FIXME - This is pissing me off on Cocoa.
      [messagesColumn setMaxWidth: 100];
      [[messagesColumn headerCell] setStringValue: _(@"Messages")];
      
      outlineView = [[ExtendedOutlineView alloc] initWithFrame: NSZeroRect];
      [outlineView addTableColumn: mailboxColumn];
      [outlineView addTableColumn: messagesColumn];
      [outlineView setOutlineTableColumn: mailboxColumn];
      [outlineView setDrawsGrid: NO];
      [outlineView setIndentationPerLevel: 10];
      [outlineView setAutoresizesOutlineColumn: YES];
      [outlineView setIndentationMarkerFollowsCell: YES];
      [outlineView setAllowsColumnSelection: NO];
      [outlineView setAllowsColumnReordering: NO];
      [outlineView setAllowsEmptySelection: YES];
      [outlineView setAllowsMultipleSelection: YES];
      /* Available on 10.4 or later */
      if ([outlineView respondsToSelector:@selector(setColumnAutoresizingStyle:)])
        [outlineView setColumnAutoresizingStyle: NSTableViewUniformColumnAutoresizingStyle];
    else
        [outlineView setAutoresizesAllColumnsToFit: YES];
    
      [outlineView sizeLastColumnToFit];
      [outlineView setDataSource: [MailboxManagerController singleInstance]];
      [outlineView setDelegate: [MailboxManagerController singleInstance]];
      [outlineView setTarget: [MailboxManagerController singleInstance]];
      
      // We register the outline view for dragged types
      [outlineView registerForDraggedTypes: [NSArray arrayWithObject: MessagePboardType]];
      
      // We set our autosave name for our outline view
      [outlineView setAutosaveName: @"MailboxManager"];
      [outlineView setAutosaveTableColumns: YES];
      
      scrollView = [[NSScrollView alloc] initWithFrame: NSZeroRect];
      [scrollView setDocumentView: outlineView];
      [scrollView setHasHorizontalScroller: NO];
      [scrollView setHasVerticalScroller: YES];
      [scrollView setBorderType: NSBezelBorder];
      [scrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
      
      [[scrollView verticalScroller] setControlSize: ([[NSUserDefaults standardUserDefaults] integerForKey: @"SCROLLER_SIZE" default: NSOffState] == NSOffState ? NSRegularControlSize : NSSmallControlSize)];
															       
															       
															       [drawer setContentView: scrollView];
															       drawerSize = [drawer contentSize];
															       drawerSize.width = 275;
															       [drawer setContentSize: drawerSize];
															       RELEASE(scrollView);
															       RELEASE(mailboxColumn);
															       RELEASE(messagesColumn);
  
  //
  // We set up our various toolbar items
  //
  [icon setTarget: [NSApp delegate]];
  [icon setAction: @selector(showConsoleWindow:)];

  [mailboxes setTarget: [NSApp delegate]];
  [mailboxes setAction: @selector(showMailboxManager:)];
  
  [addresses setTarget: [NSApp delegate]];
  [addresses setAction: @selector(showAddressBook:)];
  
  [find setTarget: [NSApp delegate]];
  [find setAction: @selector(showFindWindow:)];

  [dataView setDoubleAction: @selector(doubleClickedOnDataView:)];
    }

  // We set up our context menu
  menu = [[NSMenu alloc] init];
  [menu setAutoenablesItems: YES];
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Add Sender to Address Book") action: @selector(addSenderToAddressBook:)  keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
    
  aMenu = [[NSMenu alloc] init];
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Sender") action: @selector(makeFilterFromSender:) keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"To") action: @selector(makeFilterFromTo:) keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
    
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Cc") action: @selector(makeFilterFromCc:) keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
    
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"List-Id")  action: @selector(makeFilterFromListId:)  keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Subject") action: @selector(makeFilterFromSubject:) keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Reply") action: @selector(replyToMessage:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [aMenuItem setTag: PantomimeNormalReplyMode];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Reply Simple") action: @selector(replyToMessage:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [aMenuItem setTag: PantomimeSimpleReplyMode];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Reply All") action: @selector(replyToMessage:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [aMenuItem setTag: (PantomimeNormalReplyMode|PantomimeReplyAllMode)];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Forward") action: @selector(forwardMessage:)  keyEquivalent: @""];
  [aMenuItem setTag: PantomimeAttachmentForwardMode];
  [aMenuItem setTarget: [NSApp delegate]];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Redirect") action: @selector(redirectMessage:)  keyEquivalent: @""];
  [aMenuItem setTarget: [NSApp delegate]];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Make Filter from") action: NULL keyEquivalent: @""];
  [menu addItem: aMenuItem];
  [menu setSubmenu: aMenu forItem: aMenuItem];
  RELEASE(aMenuItem);
  RELEASE(aMenu);
  
  markAsReadOrUnreadContextMI = [[NSMenuItem alloc] init];
  [markAsReadOrUnreadContextMI setTitle: _(@"Mark as Unread")];
  [markAsReadOrUnreadContextMI setAction: @selector(markMessageAsReadOrUnread:)];
  [markAsReadOrUnreadContextMI setTarget: self];
  [menu addItem: markAsReadOrUnreadContextMI];
  RELEASE(markAsReadOrUnreadContextMI);
  
  markAsFlaggedOrUnflaggedContextMI = [[NSMenuItem alloc] init];
  [markAsFlaggedOrUnflaggedContextMI setTitle: _(@"Mark as Flagged")];
  [markAsFlaggedOrUnflaggedContextMI setAction: @selector(markMessageAsFlaggedOrUnflagged:)];
  [markAsFlaggedOrUnflaggedContextMI setTarget: self];
  [menu addItem: markAsFlaggedOrUnflaggedContextMI];
  RELEASE(markAsFlaggedOrUnflaggedContextMI);
  
  //
  // Now let's add our Copy To / Move To menus and their respective items.
  //
  //
  // FIXME: Update in the future with notifications.
  //
  allNodes = RETAIN([Utilities initializeFolderNodesUsingAccounts: [Utilities allEnabledAccounts]]);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Copy To") action: NULL  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];

  aMenu = [[NSMenu alloc] init];
  
  [Utilities addItemsToMenu: aMenu
	     tag: COPY_MESSAGES
	     action: @selector(copyOrMoveMessages:)
	     folderNodes: allNodes];
  [menu setSubmenu: aMenu  forItem: aMenuItem];
  RELEASE(aMenuItem);
  RELEASE(aMenu);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Move To") action: NULL  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];

  aMenu = [[NSMenu alloc] init];
  
  [Utilities addItemsToMenu: aMenu
	     tag: MOVE_MESSAGES
	     action: @selector(copyOrMoveMessages:)
	     folderNodes: allNodes];
  [menu setSubmenu: aMenu  forItem: aMenuItem];
  RELEASE(aMenuItem);
  RELEASE(aMenu);



  //
  // We finally add our observers
  //
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_filtersHaveChanged:)
    name: FiltersHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_fontValuesHaveChanged)
    name: FontValuesHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_showMessage:)
    name: MessageThreadingNotification
    object: nil];

  [[NSNotificationCenter defaultCenter] 
    addObserver: self
    selector: @selector(_reloadMessageList:)
    name: ReloadMessageList
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_reloadTableColumns:)
    name: TableColumnsHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_messageChanged:)
    name: PantomimeMessageChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_messageExpunged:)
    name: PantomimeMessageExpunged
    object: nil];
  
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_messageStoreCompleted:)
    name: PantomimeMessageStoreCompleted
    object: nil];
  
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_showMessage:)
    name: NSSplitViewDidResizeSubviewsNotification
    object: splitView];

  // We initialize some values
  [self setShowAllHeaders: NO];
  
  // We add our window from our list of opened windows
  [GNUMail addMailWindow: [self window]];

  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      // We show our MailboxManager window, if we need to.
      // Under OS X, we MUST do this _after_ showing any MailWindow:s
      // since we are using a drawer attached to the window.
      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"OPEN_MAILBOXMANAGER_ON_STARTUP"])
	{
	  [[NSApp delegate] showMailboxManager: nil];
	}
    }

  // We initialize some ivars
  allMessageViewWindowControllers = [[NSMutableArray alloc] init];
}


//
//
//
- (void) windowDidBecomeKey: (NSNotification *) aNotification
{
  NSUInteger i;
  
  // We set the last window on top
  [GNUMail setLastMailWindowOnTop: [self window]];
  
  // We set the current superview of our bundle having providing
  // a viewing accessory view.
  for (i = 0; i < [[GNUMail allBundles] count]; i++)
    {
      id<GNUMailBundle> aBundle;
      
      aBundle = [[GNUMail allBundles] objectAtIndex: i];
      
      if ([aBundle hasViewingViewAccessory])
	{
	  [aBundle setCurrentSuperview: [[self window] contentView]];
	}
    }
  
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      // We set the current outline view for our mailbox manager
      [[MailboxManagerController singleInstance] setCurrentOutlineView: outlineView];
    }

  // We finally select the "current" mailbox in the Mailboxes window / drawer
  if (_folder)
    {
      id aNode;
      NSInteger row;

      aNode = nil;

      // FIXME - VirtualFolder will eventually be supported on IMAP mailboxes.
      if ([_folder isKindOfClass: [CWLocalFolder class]])
	{
	  aNode = [[MailboxManagerController singleInstance] storeFolderNodeForName: _(@"Local")];
	}
      else if ([_folder isKindOfClass: [CWIMAPFolder class]])
	{
	  // We find the root node
	  aNode = [[MailboxManagerController singleInstance]
		    storeFolderNodeForName: [Utilities accountNameForServerName: [(CWIMAPStore *)[_folder store] name]
							username:  [(CWIMAPStore *)[_folder store] username]]];
	}

      // We find the node we want to select
      if (aNode)
	{
	  aNode = [Utilities folderNodeForPath: [_folder name]
			     using: aNode
			     separator: [(id<CWStore>)[_folder store] folderSeparator]];
	  
	  row = [[[MailboxManagerController singleInstance] outlineView] rowForItem: aNode];
	  
	  if (row >= 0 && row < [[[MailboxManagerController singleInstance] outlineView] numberOfRows])
	    {
	      [[[MailboxManagerController singleInstance] outlineView] selectRow: row
								       byExtendingSelection: NO];
	    }
	}
    }

  [[self window] makeFirstResponder: dataView];
}


//
//
//
- (void) windowDidResize: (NSNotification *) theNotification
{
 if (!showRawSource)
    {
      [self _showMessage: nil];
    }
}


//
//
//
- (CWMessage *) selectedMessage
{
  NSInteger index;
  
  index = [dataView selectedRow];
  
  if (index < 0 || index >= [_allVisibleMessages count])
    {
      return nil;
    }

  return [_allVisibleMessages objectAtIndex: index];
}


//
//
//
- (NSArray *) selectedMessages
{
  if ([dataView numberOfSelectedRows] == 0)
    {
      NSBeep();
    }
  else
    {
      NSMutableArray *aMutableArray;
      NSEnumerator *anEnumerator;
      CWMessage *aMessage;
      NSNumber *aRow;

      aMutableArray = [[NSMutableArray alloc] initWithCapacity: [dataView numberOfSelectedRows]];
      anEnumerator = [dataView selectedRowEnumerator];
      
      while ((aRow = [anEnumerator nextObject]))
	{
	  aMessage = [_allVisibleMessages objectAtIndex: (NSUInteger)[aRow intValue]];
	  
	  // We guard ourself against broken threads
	  if (aMessage)
	    {
	      [aMutableArray addObject: aMessage];
	    }
	}
      
      return AUTORELEASE(aMutableArray);
    }
  
  return nil;
}


//
//
//
- (id) dataView
{
  return dataView;
}


//
//
//
- (void) setDataViewType: (int) theType
{
  id aDataView;
  NSRect aRect;

  aRect = [tableScrollView frame];
  
  // We set the data source / delegate / target of our previous
  // view to nil - just to be safe.
  aDataView = [tableScrollView documentView];

  if (aDataView)
    {
      [aDataView setDataSource: nil]; 
      [aDataView setDelegate: nil];
      [aDataView setTarget: nil];
    }

  //
  // NSTableView
  //
  dataView = [[ExtendedTableView alloc] initWithFrame: aRect];
  [dataView addTableColumn: flaggedColumn];
  [dataView addTableColumn: statusColumn];
  [dataView addTableColumn: idColumn];
  [dataView addTableColumn: dateColumn];
  [dataView addTableColumn: fromColumn];
  [dataView addTableColumn: subjectColumn];
  [dataView addTableColumn: sizeColumn]; 
  
  // General methods that apply to both of them
  [dataView setDrawsGrid: NO];
  [dataView setAllowsColumnSelection: NO];
  [dataView setAllowsColumnReordering: YES];
  [dataView setAllowsColumnResizing: YES];
  [dataView setAllowsEmptySelection: YES];
  [dataView setAllowsMultipleSelection: YES];
  [dataView setIntercellSpacing: NSZeroSize];

  /* Available on 10.4 or later */
  if ([dataView respondsToSelector:@selector(setColumnAutoresizingStyle:)])
    [dataView setColumnAutoresizingStyle: NSTableViewUniformColumnAutoresizingStyle];
  else
    [dataView setAutoresizesAllColumnsToFit: YES];
  [dataView sizeLastColumnToFit];

  [dataView setDataSource: self]; 
  [dataView setDelegate: self];
  [dataView setTarget: self];
  [(NSTableView *)dataView setAction: @selector(clickedOnDataView:)];
  [dataView setDoubleAction: @selector(doubleClickedOnDataView:)];

  // We add it to our document view and we can now safely release it
  // since the scrollview will retain it.
  [tableScrollView setDocumentView: dataView];

  // We register the table view for dragged types
  [dataView registerForDraggedTypes: [NSArray arrayWithObject: MessagePboardType]];

  // We set any vertical mouse motion has being dragging
  [dataView setVerticalMotionCanBeginDrag: NO];
  [dataView setRowHeight: [[NSFont seenMessageFont] defaultLineHeightForFont]];

  // We load the right set of columns
  [self _reloadTableColumns: self];

  // We set our table view background color
  if ( [[NSUserDefaults standardUserDefaults] colorForKey: @"MAILWINDOW_TABLE_COLOR"] )
    {
      [dataView setBackgroundColor: [[NSUserDefaults standardUserDefaults]
				      colorForKey: @"MAILWINDOW_TABLE_COLOR"]];
      [tableScrollView setBackgroundColor: [[NSUserDefaults standardUserDefaults]
					     colorForKey: @"MAILWINDOW_TABLE_COLOR"]];
    }
  
  RELEASE(dataView);
}


//
//
//
- (NSTextView *) textView
{
  return textView;
}


//
//
//
- (MailHeaderCell *) mailHeaderCell
{
  return mailHeaderCell;
}


//
//
//
- (ThreadArcsCell *) threadArcsCell
{
  return threadArcsCell;
}


//
//
//
- (NSMutableArray *) allMessageViewWindowControllers
{
  return allMessageViewWindowControllers;
}


//
//
//
- (NSArray *) allMessages
{
  return _allVisibleMessages;
}


//
//
//
- (BOOL) showAllHeaders
{
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"SHOWALLHEADERS"])
    {
      return ([[[NSUserDefaults standardUserDefaults] objectForKey: @"SHOWALLHEADERS"] intValue] == NSOnState ? YES
	      : showAllHeaders);
    }

  return showAllHeaders;
}


//
//
//
- (void) setShowAllHeaders: (BOOL) aBOOL
{
  showAllHeaders = aBOOL;
}

- (BOOL) showRawSource
{
  return showRawSource;
}

- (void) setShowRawSource: (BOOL) aBool
{
  showRawSource = aBool;
}


//
//
//
- (IBAction) getNewMessages: (id) sender
{
  [[TaskManager singleInstance] checkForNewMail: sender
				controller: self];
}


//
// This method is used to either copy or move selected messages
//
- (IBAction) copyOrMoveMessages: (id) sender
{
  id aDestinationFolder;
  NSArray *theMessages;
  CWURLName *theURLName;

  theMessages = [self selectedMessages];

  if (!theMessages)
    {
      return;
    }

  theURLName = [[CWURLName alloc] initWithString: [Utilities stringValueOfURLNameFromFolderNode: [sender folderNode]
							     serverName: nil
							     username: nil]
				  path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];

  aDestinationFolder = [[MailboxManagerController singleInstance] folderForURLName: theURLName];
  
  [[MailboxManagerController singleInstance] transferMessages: theMessages
					     fromStore: [_folder store]
					     fromFolder: _folder
					     toStore: [aDestinationFolder store]
					     toFolder: aDestinationFolder
					     operation: [sender tag]];

  RELEASE(theURLName);
}

//
//
//
- (IBAction) openOrCloseDrawer: (id) sender
{
  if ([drawer state] == NSDrawerOpenState)
    {
      [drawer close];
    }
  else
    {
      if ([[NSUserDefaults standardUserDefaults] objectForKey: @"DrawerPosition"])
        {
          [drawer openOnEdge: [[NSUserDefaults standardUserDefaults] integerForKey: @"DrawerPosition"]];
        }
      else
        {
          [drawer open];
        }
    }
    
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"DrawerPosition"];
}

//
//
//
- (void) updateDataView
{
  if ([_folder countVisible] > 0) 
    {
      // We reload the data our of dataView (since it now has some)
      [self tableViewShouldReloadData];
      
      if ([dataView selectedRow] == -1)
	{
	  NSInteger i, count;

	  count = [dataView numberOfRows];
	  
	  // We search for the first message without the PantomimeSeen flag and we select it
	  for (i = 0; i < count; i++)
	    {
	      CWMessage *aMessage;
	      
	      aMessage = [_allVisibleMessages objectAtIndex: i];
	      
	      if (![[aMessage flags] contain: PantomimeSeen])
		{
		  break;
		}
	    }
	  
	  if (i == count)
	    {
	      if ([dataView isReverseOrder])
		{
		  i = 0;
		}
	      else
		{
		  i--;
		}
	    }

	  // We scroll to and select our found row
	  [dataView scrollRowToVisible: i];
	  
	  if (![[NSUserDefaults standardUserDefaults] boolForKey: @"DoNoSelectFirstUnread"])
	    {
	      [dataView selectRow: i  byExtendingSelection: NO];
	    }
	}
    }
  else
    {
      [self tableViewShouldReloadData];
    }

  [[dataView headerView] setNeedsDisplay: YES];

  // We always update our status label, if we have or not messages in our folder
  [self updateStatusLabel];
}



//
// 
//
- (void) updateStatusLabel
{
  NSString *aStoreName, *aUsername, *aFolderName;
  NSEnumerator *enumerator;
  CWMessage *aMessage;
  CWFlags *theFlags;
  Task *aTask;
  id anObject;

  NSUInteger totalSize, unreadSize, selectedSize, deletedSize;
  NSString *totalSizeStr, *unreadSizeStr, *selectedSizeStr, *deletedSizeStr;
  NSUInteger i, count, unreadCount, deletedCount, aSize, numberOfSelectedRows;
  unsigned char aSeparator;

  if ([_folder isKindOfClass: [CWIMAPFolder class]] && 
      (aTask = [[TaskManager singleInstance] taskForService: [_folder store]]) &&
      aTask->op == OPEN_ASYNC)
    {
      return;
    }
  
  totalSize = unreadCount = unreadSize = deletedCount = deletedSize = 0;
  count = [_folder countVisible];
  for (i = 0; i < count; i++)
    {
      aMessage = [[_folder visibleMessages] objectAtIndex: i];
      theFlags = [aMessage flags];
      aSize = [aMessage size];
      totalSize += aSize;

      if (![theFlags contain: PantomimeSeen])
	{
	  unreadCount++;
	  unreadSize += aSize;
	}
      if ([theFlags contain: PantomimeDeleted])
	{
	  deletedCount++;
	  deletedSize += aSize;
	}
    }
  
  numberOfSelectedRows = [dataView numberOfSelectedRows];
  selectedSize = 0;
  
  if (numberOfSelectedRows > 0)
    {
      enumerator = [dataView selectedRowEnumerator];
      
      while ((anObject = [enumerator nextObject]))
	{
	  aMessage = [_allVisibleMessages objectAtIndex: (NSUInteger)[anObject intValue]];
	 
	  // We guard ourself against broken message threads
	  if (aMessage)
	    {
	      selectedSize += [aMessage size];
	    }
	}
    }
  
  if (totalSize < 1024)
    totalSizeStr = [NSString stringWithFormat:@"%luB", (unsigned long) totalSize];
  else if (totalSize < 1024 * 1024)
    totalSizeStr = [NSString stringWithFormat:@"%0.1fKB", (float) totalSize / 1024];
  else if (totalSize < 1024 * 1024 * 1024)
    totalSizeStr = [NSString stringWithFormat:@"%0.1fMB", (float) totalSize / (1024 * 1024)];
  else
    totalSizeStr = [NSString stringWithFormat:@"%0.1fGB", (float) totalSize / (1024 * 1024 * 1024)];

  if (unreadSize < 1024)
    unreadSizeStr = [NSString stringWithFormat:@"%luB", (unsigned long) unreadSize];
  else if (unreadSize < 1024 * 1024)
    unreadSizeStr = [NSString stringWithFormat:@"%0.1fKB", (float) unreadSize / 1024];
  else
    unreadSizeStr = [NSString stringWithFormat:@"%0.1fMB", (float) unreadSize / (1024 * 1024)];
  
  if (selectedSize < 1024)
    selectedSizeStr = [NSString stringWithFormat:@"%luB", (unsigned long) selectedSize];
  else if (selectedSize < 1024 * 1024)
    selectedSizeStr = [NSString stringWithFormat:@"%0.1fKB", (float) selectedSize / 1024];
  else
    selectedSizeStr = [NSString stringWithFormat:@"%0.1fMB", (float) selectedSize / (1024 * 1024)];

  if (deletedSize < 1024)
    deletedSizeStr = [NSString stringWithFormat:@"%luB", (unsigned long) deletedSize];
  else if (deletedSize < 1024 * 1024)
    deletedSizeStr = [NSString stringWithFormat:@"%0.1fKB", (float) deletedSize / 1024];
  else
    deletedSizeStr = [NSString stringWithFormat:@"%0.1fMB", (float) deletedSize / (1024 * 1024)];
  
  UPDATE_STATUS_LABEL(_(@"%lu messages (%@) - %lu unread (%@) - %lu selected (%@) - %lu deleted (%@)"),
		      (unsigned long)count, totalSizeStr,
		      (unsigned long)unreadCount, unreadSizeStr, 
		      (unsigned long)numberOfSelectedRows, selectedSizeStr,
		      (unsigned long)deletedCount,deletedSizeStr);

  [[ApplicationIconController singleInstance] update];

  // We update our cache
  if ([(id<NSObject>)[_folder store] isKindOfClass: [CWLocalStore class]])
    {
      aStoreName = @"GNUMAIL_LOCAL_STORE";
      aUsername = NSUserName();
      aSeparator = '/';
    }
  else
    {
      aStoreName = [(CWIMAPStore *)[_folder store] name];
      aUsername = [(CWIMAPStore *)[_folder store] username];
      aSeparator = [(CWIMAPStore *)[_folder store] folderSeparator];
    }

  aFolderName = [[_folder name] stringByReplacingOccurrencesOfCharacter: aSeparator  withCharacter: '/'];

  [[(MailboxManagerController *)[MailboxManagerController singleInstance] cache]
    setAllValuesForStoreName: aStoreName
    folderName: aFolderName
    username: aUsername
    nbOfMessages: count
    nbOfUnreadMessages: unreadCount];

  [[MailboxManagerController singleInstance] updateOutlineViewForFolder: aFolderName
					     store: aStoreName
					     username: aUsername
					     controller: nil];
}


//
//
//
- (void) updateWindowTitle
{
  // We now set the window title
  if (!_folder)
    {
      [[self window] setTitle: _(@"No mailbox selected")];
    }
  else if ([_folder isKindOfClass: [CWLocalFolder class]])
    {
      [[self window] setTitle: [NSString stringWithFormat: _(@"Local - %@"), [_folder name]] ];
    }
  else if ([_folder isKindOfClass: [CWIMAPFolder class]])
    {
      
      [[self window] setTitle: [NSString stringWithFormat: _(@"IMAP on %@ - %@"), [(CWIMAPStore *)[_folder store] name], 
					 [_folder name]] ];
    }
  else
    {
      [[self window] setTitle: [NSString stringWithFormat: _(@"Virtual Folder - %@"), [_folder name]]];
    }
}


//
//
//
- (void) doFind: (id) sender
{
  CWMessage *old_selected, *msg;
  BOOL display_current_selected;
  NSInteger sel_index, i;
  
  sel_index = [dataView selectedRow];

  display_current_selected = NO;
  old_selected = nil;

  if (sel_index >= 0 && sel_index < [_allVisibleMessages count])
    {
      old_selected = [_allVisibleMessages objectAtIndex: sel_index];
      RETAIN(old_selected);
    }
  
  [dataView deselectAll: self];
  [_allVisibleMessages removeAllObjects];
  
  if ([[searchField stringValue] length])
    {
      for (i = 0; i < [_allMessages count]; i++)
        {
	  if ([self _isMessageMatching: [searchField stringValue] index: i])
            {
	      msg = [_allMessages objectAtIndex: i];
	      
	      if ([old_selected isEqual: msg])
                {
		  display_current_selected = YES;
		  sel_index = [_allVisibleMessages count];
                }
	      
	      [_allVisibleMessages addObject: msg];
            }
        }
    }
  else
    {
      [_allVisibleMessages addObjectsFromArray: _allMessages];
      
      if (sel_index >= 0)
        {
	  for (sel_index = 0; sel_index < [_allVisibleMessages count]; sel_index++)
	    {
	      if ([_allVisibleMessages objectAtIndex: sel_index] == old_selected)
		break;
            }
	  display_current_selected = YES;
        }
    }
  
  RELEASE(old_selected);
  [dataView reloadData];

  if (sel_index >= [_allVisibleMessages count])
    {
      sel_index = [_allVisibleMessages count]-1;
    }

  if (sel_index >= 0 && display_current_selected)
    {
      [dataView selectRow: sel_index byExtendingSelection: NO];
    }
}


//
//
//
- (void) resetSearchField
{
  [searchField setStringValue: @""];
  [self doFind: searchField]; 
}

//
//
//
- (BOOL) validateMenuItem: (id<NSMenuItem>) theMenuItem
{
  CWMessage *aMessage;
  SEL action;
    
  aMessage = [self selectedMessage];
  action = [theMenuItem action];
  //
  // Delete / Undelete message
  //
  if (sel_isEqual(action, @selector(deleteMessage:)))
    {
      if (nil == aMessage) return NO;
      
      if ([[aMessage flags] contain: PantomimeDeleted])
	{
	  [theMenuItem setTitle: _(@"Undelete")];
	  [theMenuItem setTag: UNDELETE_MESSAGE];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Delete")];
	  [theMenuItem setTag: DELETE_MESSAGE];
	}
    }
  //
  // Deliver / Send Message
  //
  else if (sel_isEqual(action, @selector(sendMessage:)))
    {
      return NO;
    }
  //
  // Mark as Flagged / Unflagged
  //
  else if (sel_isEqual(action, @selector(markMessageAsFlaggedOrUnflagged:)))
    {
      if (nil == aMessage) return NO;
      
      if ([[aMessage flags] contain: PantomimeFlagged])
	{
	  [theMenuItem setTitle: _(@"Mark as Unflagged")];
	  [theMenuItem setTag: MARK_AS_UNFLAGGED];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Mark as Flagged")];
	  [theMenuItem setTag: MARK_AS_FLAGGED];
	}   
    }  
  //
  // Mark as Read / Unread
  //
  else if (sel_isEqual(action, @selector(markMessageAsReadOrUnread:)))
    {
      if (nil == aMessage) return NO;
      
      if ([[aMessage flags] contain: PantomimeSeen])
	{
	  [theMenuItem setTitle: _(@"Mark as Unread")];
	  [theMenuItem setTag: MARK_AS_UNREAD];
	}
      else
	{
	  [theMenuItem setTitle: _(@"Mark as Read")];
	  [theMenuItem setTag: MARK_AS_READ];
	}   
    }
  return YES;
}

@end


//
// Private interface for MailWindowContrller
//
@implementation MailWindowController (Private)

- (void) _closeAllMessageViewWindows
{
  int i;

  // No need to actually remove the object from the array since that will
  // already be done in MessageViewWindowController: -windowWillClose.
  for (i = ([allMessageViewWindowControllers count] - 1); i >= 0; i--)
    {
      [[allMessageViewWindowControllers objectAtIndex: i] close];
    }

}


//
//
//
- (void) _filtersHaveChanged: (NSNotification *) theNotification
{
  [dataView setNeedsDisplay: YES];
}


//
//
//
- (void) _fontValuesHaveChanged
{
  [dataView setRowHeight: [[NSFont seenMessageFont] defaultLineHeightForFont]];
  [self _showMessage: self];
}


//
//
//
- (void) _loadAccessoryViews
{
  NSUInteger i;

  for (i = 0; i < [[GNUMail allBundles] count]; i++)
    {
      id<GNUMailBundle> aBundle;

      aBundle = [[GNUMail allBundles] objectAtIndex: i];
      
      if ([aBundle hasViewingViewAccessory])
	{
	  id aView;
	  
	  aView = [aBundle viewingViewAccessory];
	  
	  if ([aBundle viewingViewAccessoryType] == ViewingViewTypeHeaderCell)
	    {
	      NSDebugLog(@"Adding ViewingViewTypeHeaderCell type of Bundle...");
	      [mailHeaderCell addView: aView];
	    }
	  else
	    {
	      NSToolbarItem *aToolbarItem;
	      NSToolbar *aToolbar;

	      aToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: [aBundle name]];
	      [allowedToolbarItemIdentifiers addObject: [aBundle name]];
	      
	      [additionalToolbarItems setObject: aToolbarItem
				      forKey: [aBundle name]];
	      
	      [aToolbarItem setView: aView];
	      [aToolbarItem setLabel: [aBundle name]];               // name
	      [aToolbarItem setPaletteLabel: [aBundle description]]; // description
	      [aToolbarItem setMinSize: [aView frame].size];
	      [aToolbarItem setMaxSize: [aView frame].size];
	      RELEASE(aToolbarItem);
	      
	      aToolbar = [[self window] toolbar];
	      [aToolbar insertItemWithItemIdentifier: [aBundle name]
			atIndex: [[aToolbar visibleItems] count]];
	    }
	}

      // We also set the current superview
      [aBundle setCurrentSuperview: [[self window] contentView]];
    }
}


//
//
//
- (BOOL) _moveMessageToTrash: (CWMessage *) theMessage
{
  NSString *aString;

  aString = nil;

  if ([_folder isKindOfClass: [CWIMAPFolder class]])
    {
      aString = [[[[Utilities allEnabledAccounts] objectForKey: [Utilities accountNameForFolder: _folder]] 
		   objectForKey: @"MAILBOXES"] objectForKey: @"TRASHFOLDERNAME"];
    }
  else
    {
      NSEnumerator *theEnumerator;
      NSString *s;

      theEnumerator = [[[MailboxManagerController singleInstance]
			 storeForName: @"GNUMAIL_LOCAL_STORE"  username: NSUserName()]
			folderEnumerator];
      
       while ((aString = [theEnumerator nextObject]))
	{
	  s = [NSString stringWithFormat: @"local://%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"], aString];
	  if ([Utilities stringValueOfURLName: s  isEqualTo: @"TRASHFOLDERNAME"])
	    {
	      aString = s;
	      break;
	    }
	}
       
    }
  
  if (!aString)
    {
      int choice;
      
      choice = NSRunAlertPanel(_(@"Warning!"),
			       _(@"You don't have a trash mail folder set up to save copies of deleted mails.\nTo set up the trash mail folder, bring up the contextual menu on the mailbox list\nfor the folder you want to use as a trash mail folder and choose\n\"Set Mailbox as > Trash for Account > ..."),
			       _(@"Delete Anyway"),
			       _(@"Cancel"),
			       NULL);
      
      if (choice == NSAlertAlternateReturn)
	{
	  return NO;
	}
    }
  else if (![Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: _folder]  isEqualTo: @"TRASHFOLDERNAME"])
    {
      CWURLName *theURLName;
      id aFolder;
      
      theURLName = AUTORELEASE([[CWURLName alloc] initWithString: aString
						  path: [[NSUserDefaults standardUserDefaults] 
							  objectForKey: @"LOCALMAILDIR"]]);
      aFolder = [[MailboxManagerController singleInstance] folderForURLName: theURLName];

      [[MailboxManagerController singleInstance] transferMessages: [NSArray arrayWithObject: theMessage]
						 fromStore: [_folder store]
						 fromFolder: _folder
						 toStore: [aFolder store]
						 toFolder: aFolder
						 operation: MOVE_MESSAGES];
    }

  return YES;
}

//
//
//
#warning update only the relevant row
-(void) _messageChanged: (id) sender
{
  [self tableViewShouldReloadData];
  [self updateStatusLabel];
}


//
//
//
- (void) _messageExpunged: (id) sender
{
  [self tableViewShouldReloadData];
  [self updateStatusLabel];
}


//
//
//
- (void) _messageStoreCompleted: (NSNotification *) theNotification
{
  NSArray *theMessages;
  CWMessage *aMessage;
  NSInteger i, count, row;

  theMessages = [[theNotification userInfo] objectForKey: @"Messages"];
  count = [theMessages count];
  
  for (i = 0; i < count; i++)
    {
      aMessage = [theMessages objectAtIndex: i];
      
      if ([aMessage folder] != _folder)
	{
	  return;
	}

      row = [_allVisibleMessages indexOfObject: aMessage];

      if (row >= 0 && row < [dataView numberOfRows])
	{
	  [dataView setNeedsDisplayInRect: [dataView rectOfRow: row]];
	}
    }
}


//
// reload the message list
//
- (void) _reloadMessageList: (NSNotification *) theNotification
{
  if ([_folder showDeleted])
    {
      NSDebugLog(@"Showing deleted messages...");
      [dataView setNeedsDisplay: YES];
    }
  else
    {
      NSDebugLog(@"NOT Showing deleted messages...");
      [_folder updateCache];
      [self tableViewShouldReloadData];
    }
}


//
//
//
- (void) _reloadTableColumns: (id) sender
{
  NSArray *visibleTableColumns, *selectedRows;
  NSDictionary *columnWidth;
  int i;

  visibleTableColumns = [[NSUserDefaults standardUserDefaults] objectForKey: @"SHOWNTABLECOLUMNS"];

  // If the value doesn't exist in the user's defaults, we show all table columns.
  if (!visibleTableColumns)
    {
      return;
    }

  // We backup our selected rows
  selectedRows = [[[self dataView] selectedRowEnumerator] allObjects];
  RETAIN(selectedRows);

  [[self dataView] removeTableColumn: flaggedColumn];
  [[self dataView] removeTableColumn: statusColumn];
  [[self dataView] removeTableColumn: idColumn];
  [[self dataView] removeTableColumn: dateColumn];
  [[self dataView] removeTableColumn: fromColumn];
  [[self dataView] removeTableColumn: subjectColumn];
  [[self dataView] removeTableColumn: sizeColumn];


  columnWidth = [[NSUserDefaults standardUserDefaults] objectForKey: @"MailWindowColumnWidth"];

  for (i = 0; i < [visibleTableColumns count]; i++)
    {
      NSString *identifier;
      id aColumn;

      identifier = [visibleTableColumns objectAtIndex: i];
      aColumn = nil;

      if ([identifier isEqualToString: @"Flagged"])
	{
	  aColumn = flaggedColumn;
	}
      else if ([identifier isEqualToString: @"Status"])
	{
	  aColumn = statusColumn;
	}
      else if ([identifier isEqualToString: @"Number"])
	{
	  aColumn = idColumn;
	}
      else if ([identifier isEqualToString: @"Date"])
	{
	  aColumn = dateColumn;
	}
      else if ([identifier isEqualToString: @"From"])
	{
	  aColumn = fromColumn;
	}
      else if ([identifier isEqualToString: @"Subject"])
	{
	  aColumn = subjectColumn;
	}
      else if ([identifier isEqualToString: @"Size"])
	{
	  aColumn = sizeColumn;
	}
      
      //
      // We restore the size.
      //
      // Ideally, setting column size should be handled by the NSTableView's autosave feature.
      // But it seems to be messing with the dynamic addition and removal of columns.
      //
      if (aColumn)
	{
	  if (columnWidth && [columnWidth objectForKey: identifier])
	    {
	      [aColumn setWidth: [(NSNumber *)[columnWidth objectForKey: identifier] floatValue]];
	    }
	  
	  [[self dataView] addTableColumn: aColumn];
	}
    }
  
  
  // We restore the list of selected rows
  for (i = 0; i < [selectedRows count]; i++)
    {
      [[self dataView] selectRow: [[selectedRows objectAtIndex: i] intValue] 
		       byExtendingSelection: YES];
            
      // If we had at least one row selected, we scroll to it
      if ( i == ([selectedRows count]-1) )
        {
          [[self dataView] scrollRowToVisible: [[selectedRows objectAtIndex: i] intValue]];
        }
    }
    
  RELEASE(selectedRows);
}


//
//
//
- (void) _restoreSortingOrder
{
  // We get our default sorting order
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"SORTINGORDER"])
    {
      NSString *aString;

      aString = [[NSUserDefaults standardUserDefaults] stringForKey: @"SORTINGORDER"];

      // FIXME: Eventually remove that if (). It was renamed in 1.1.0pre1.
      if (aString && [aString isEqualToString: @"Id"])
	{
	  aString = @"#";
	}

      [dataView setCurrentSortOrder: aString];
      [dataView setReverseOrder: [[NSUserDefaults standardUserDefaults] integerForKey: @"SORTINGSTATE"]];
      
      if ([[dataView currentSortOrder] isEqualToString: @"Date"])
	{
	  [[self dataView] setHighlightedTableColumn: dateColumn];
	}
      else if ([[dataView currentSortOrder] isEqualToString: @"From"])
	{
	  [[self dataView] setHighlightedTableColumn: fromColumn];
	}
      else if ([[dataView currentSortOrder] isEqualToString: @"Subject"])
	{
	  [[self dataView] setHighlightedTableColumn: subjectColumn];
	}
      else if ([[dataView currentSortOrder] isEqualToString: @"Size"])
	{
	  [[self dataView] setHighlightedTableColumn: sizeColumn];
	}
      else
	{
	  [[self dataView] setHighlightedTableColumn: idColumn];
	}
    }
  else
    {
      [[self dataView] setHighlightedTableColumn: idColumn];
    }
    
  [self _setIndicatorImageForTableColumn: [[self dataView] highlightedTableColumn]]; 
}


//
//
//
- (void) _restoreSplitViewSize
{
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"NSTableView Frame MailWindow"] &&
      [[NSUserDefaults standardUserDefaults] objectForKey: @"NSTextView Frame MailWindow"]) 
    {
      [tableScrollView setFrame: NSRectFromString([[NSUserDefaults standardUserDefaults] objectForKey: @"NSTableView Frame MailWindow"])];
      [textScrollView setFrame: NSRectFromString([[NSUserDefaults standardUserDefaults] objectForKey: @"NSTextView Frame MailWindow"])];
      [splitView adjustSubviews];
      [splitView setNeedsDisplay: YES];
    }
}


//
//
//
- (void) _setIndicatorImageForTableColumn: (NSTableColumn *) aTableColumn
{
  NSArray *tableColumns;
  int i;
  
  tableColumns = [dataView tableColumns];
 
  for (i = 0; i < [tableColumns count]; i++)
    {
      [dataView setIndicatorImage: nil  inTableColumn: [tableColumns objectAtIndex: i]];
    }

  if ([dataView isReverseOrder])
    {
      [dataView setIndicatorImage: [NSImage imageNamed: @"NSAscendingSortIndicator"]  inTableColumn: aTableColumn];
    }
  else
    {
      [dataView setIndicatorImage: [NSImage imageNamed: @"NSDescendingSortIndicator"]  inTableColumn: aTableColumn];
    }
}

//
//
//
- (void) _showMessage: (id) sender
{
  [Utilities showMessage: [self selectedMessage]
	     target: [self textView]
	     showAllHeaders: [self showAllHeaders]];
}


//
//
//
- (void) _zeroIndexOffset
{
  int i;

  for (i = 0; i < [[self allMessageViewWindowControllers] count]; i++)
    {
      [[allMessageViewWindowControllers objectAtIndex: i] setIndexOffset: 0];
    }
}


//
//
//
- (BOOL) _isMessageMatching: (NSString *) match 
		      index: (int) index
{
  CWInternetAddress *aInternetAddress;
  NSMutableArray *allAddresses;
  CWMessage *aMessage;
  NSUInteger i;

  allAddresses = AUTORELEASE([[NSMutableArray alloc] init]);
  aMessage = [_allMessages objectAtIndex: index];
  
  if (draftsOrSentFolder)
    {
      [allAddresses addObjectsFromArray: [aMessage recipients]];
    }
  else
    {
      NSArray *recipients;
      NSUInteger j;
      BOOL isList;
      
      [allAddresses addObject: [aMessage from]];

      isList = NO;
      if ([aMessage headerValueForName:@"List-Post"] != nil)
        isList = YES;
      
      // now add only CC addresses, TO only if we think it is a list not "myself"
      recipients = [aMessage recipients];
      for (j = 0; j < [recipients count]; j++)
        {
          CWInternetAddress *recipient = [recipients objectAtIndex:j];

          if ([recipient type] == PantomimeCcRecipient)
            [allAddresses addObject:recipient];
          else if (isList && [recipient type] == PantomimeToRecipient)
            [allAddresses addObject:recipient];
        }
    }
  
  for (i = 0; i < [allAddresses count]; i++)
    {
      aInternetAddress = [allAddresses objectAtIndex: i];
      
      if ([[aInternetAddress personal] length] &&
	  [[aInternetAddress personal] rangeOfString: match  options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
	  return YES;
	}
      
      if ([[aInternetAddress address] length] &&
	  [[aInternetAddress address] rangeOfString: match  options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
	  return YES;
	}
    }
  
  if ([[aMessage subject] length] && 
      [[aMessage subject] rangeOfString: match options: NSCaseInsensitiveSearch].location != NSNotFound)
    {
      return YES;
    }

  return NO;
}


@end
