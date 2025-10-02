/*
**  MessageViewWindowController.m
**
**  Copyright (c) 2001-2006 Ujwal S. Sathyam, Ludovic Marcotte
**  Copyright (C) 2017-2018 Riccardo Mottola
**
**  Author: Ujwal S. Sathyam <ujwal@setlurgroup.com>
**          Ludovic Marcotte <ludovic@Sophos.ca>
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

#import "MessageViewWindowController.h"

#import "GNUMail.h"
#import "GNUMailBundle.h"
#import "Constants.h"
#import "ExtendedCell.h"
#import "MailHeaderCell.h"
#import "MailWindowController.h"
#import "MimeType.h"
#import "MimeTypeManager.h"
#import "ThreadArcsCell.h"
#import "Utilities.h"

#ifndef MACOSX
#import "MessageViewWindow.h"
#endif

#import <Pantomime/CWContainer.h>
#import <Pantomime/CWConstants.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolder.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>


//
//
//
@implementation MessageViewWindowController

- (id) initWithWindowNibName: (NSString *) theWindowNibName
{
  NSToolbar *aToolbar;

#ifdef MACOSX
  self = [super initWithWindowNibName: theWindowNibName];
#else
  MessageViewWindow *aMessageViewWindow;
  
  aMessageViewWindow = [[MessageViewWindow alloc] initWithContentRect: NSMakeRect(150,100,720,600)
						  styleMask: NSClosableWindowMask|NSTitledWindowMask|
						  NSMiniaturizableWindowMask|NSResizableWindowMask
						  backing: NSBackingStoreRetained
						  defer: NO];

  self = [super initWithWindow: aMessageViewWindow];
  
  [aMessageViewWindow layoutWindow];
  [aMessageViewWindow setDelegate: self];
  textView = aMessageViewWindow->textView;
  RELEASE(aMessageViewWindow);
#endif
  
  [[self window] setTitle: @""];
  
  aToolbar = [[NSToolbar alloc] initWithIdentifier: @"MessageViewWindowToolbar"];
  [aToolbar setDelegate: self];
  [aToolbar setAllowsUserCustomization: YES];
  [aToolbar setAutosavesConfiguration: YES];
  [[self window] setToolbar: aToolbar];
  RELEASE(aToolbar);
  
  [[self window] setFrameAutosaveName: @"MessageViewWindow"];
  [[self window] setFrameUsingName: @"MessageViewWindow"];
  
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

  // We create our mail header cell
  mailHeaderCell = [[MailHeaderCell alloc] init];
  [mailHeaderCell setController: self];

  // We create our thread arcs cell
  threadArcsCell = [[ThreadArcsCell alloc] init];
  [threadArcsCell setController: self];

  // We load our accessory views
  [self _loadAccessoryViews];
  
  // Set out textview to non-editable
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
  NSDebugLog(@"MessageViewWindowController: dealloc called for message window: %@", [message subject]);
  
  [[self window] setDelegate: nil]; // FIXME not necessary in coca and in gnustep as of 2014-02-11, only for compatibility with old releases
  [[NSNotificationCenter defaultCenter] removeObserver: mailHeaderCell
					name: @"NSViewFrameDidChangeNotification" 
					object: textView];

  [[NSNotificationCenter defaultCenter] removeObserver: self];

  RELEASE(mailHeaderCell);
  RELEASE(threadArcsCell);
  RELEASE(message);

  [super dealloc];
}



//
// action methods
//
- (IBAction) deleteMessage: (id) sender
{
  CWFlags *theFlags;
  NSUInteger aRow;

  theFlags = [[[self message] flags] copy];
  [theFlags add: PantomimeDeleted];
  [[self message] setFlags: theFlags];
  RELEASE(theFlags);

  aRow = [[mailWindowController allMessages] indexOfObject: [self message]];
  [[mailWindowController dataView] setNeedsDisplayInRect: [[mailWindowController dataView] rectOfRow: aRow]];

  // FIXME: Review all the code when "hiding" deleted messages.
  // If we are hiding deleted message, we must reload our table data
  //if ( ![[self folder] showDeleted] )
  //  {
  //    [[self folder] updateCache];
  //    [mailWindowController dataViewShouldReloadData];
  //  }

  [self nextMessage: self];
}


//
// Invoke the message Utility class method to reply to this message.
//
- (IBAction) replyToMessage: (id) sender
{
  [Utilities replyToMessage: [self message]
	     folder: [self folder]
	     mode: [sender tag]];
}

//
//
//
- (IBAction) markMessageAsReadOrUnread: (id) sender
{
  [mailWindowController markMessageAsReadOrUnread:sender];
}

//
//
//
- (IBAction) markMessageAsFlaggedOrUnflagged: (id) sender
{
  [mailWindowController markMessageAsFlaggedOrUnflagged:sender];
}

//
//
//
- (IBAction) previousMessage: (id) sender
{
  CWMessage *aMessage;
  NSInteger row;

  indexOffset--;
  row = [[mailWindowController dataView] selectedRow] + indexOffset;
  
  NSDebugLog(@"row = %ld, offset = %d", (long int)[[mailWindowController dataView] selectedRow], indexOffset);

  if (row < 0) 
    {
      NSBeep();
      indexOffset++;
      return;
    }
  
  [[mailWindowController dataView] selectRow: row  byExtendingSelection: NO];
  aMessage = [[mailWindowController allMessages] objectAtIndex: row];
  
  if (aMessage)
    {
      [self setMessage: aMessage];
      [Utilities showMessage: [self message]
		 target: [self textView]
		 showAllHeaders: [self showAllHeaders]];
      [self windowDidBecomeKey: nil];
    }
}


//
//
//
- (IBAction) nextMessage: (id) sender
{
  CWMessage *aMessage;
  NSInteger row;

  indexOffset++;
  row = [[mailWindowController dataView] selectedRow] + indexOffset;
  
  NSDebugLog(@"row = %ld, offset = %d", (long int)[[mailWindowController dataView] selectedRow], indexOffset);

  if (row == -1 ||
      row > ([[mailWindowController dataView] numberOfRows] - 1)) 
    {
      // We do NOT beep if sender == self
      // This happens if we clicked on the Delete button and our current
      // index in the dataView is the last one.
      if ( sender != self )
	{
	  NSBeep();
	}

      indexOffset--;
      return;
    }


  [[mailWindowController dataView] selectRow: row  byExtendingSelection: NO];
  aMessage = [[mailWindowController allMessages] objectAtIndex: row];
  
  if (aMessage)
    {
      [self setMessage: aMessage];
      [Utilities showMessage: [self message]
		 target: [self textView]
		 showAllHeaders: [self showAllHeaders]];
      [self windowDidBecomeKey: nil];
    }
  
}


//
// 
//
- (IBAction) firstMessage: (id) sender
{  
  if ( [[mailWindowController dataView] numberOfRows] > 0 )
    {
      CWMessage *aMessage;
      
      aMessage = [[mailWindowController allMessages] objectAtIndex: 0];
      
      if (aMessage)
	{
	  [self setMessage: aMessage];
	  [Utilities showMessage: [self message]
		     target: [self textView]
		     showAllHeaders: [self showAllHeaders]];
	  [self windowDidBecomeKey: nil];
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
- (IBAction) lastMessage: (id) sender
{
  NSInteger row;

  row = [[mailWindowController dataView] numberOfRows] - 1;
  
  if ( row >= 0 )
    {
      CWMessage *aMessage;
      
      aMessage = [[mailWindowController allMessages] objectAtIndex: row];
      
      if (aMessage)
	{
	  [self setMessage: aMessage];
	  [Utilities showMessage: [self message]
		     target: [self textView]
		     showAllHeaders: [self showAllHeaders]];
	  [self windowDidBecomeKey: nil];
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
- (IBAction) showOrHideAllHeaders: (id) sender
{
  [(GNUMail *)[NSApp delegate] showAllHeaders: sender];
}


//
//
//
- (IBAction) pageDownMessage: (id) sender
{
  NSScrollView *textScrollView;
  NSRect aRect;
  double origin;

  textScrollView = [textView enclosingScrollView];
  aRect = [textScrollView documentVisibleRect];
  origin = aRect.origin.y;
  
  aRect.origin.y += aRect.size.height - [textScrollView verticalPageScroll];
  [textView scrollRectToVisible: aRect];
  
  aRect = [textScrollView documentVisibleRect];
  
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
  NSScrollView *textScrollView;
  NSRect aRect;
  double origin;

  textScrollView = [textView enclosingScrollView];
  aRect = [textScrollView documentVisibleRect];
  origin = aRect.origin.y;

  aRect.origin.y -= aRect.size.height - [textScrollView verticalPageScroll];
  [textView scrollRectToVisible: aRect];

  aRect = [textScrollView documentVisibleRect];

  if (aRect.origin.y == origin)
    {
      [self previousMessage: nil];
    }
}



//
// accessor/mutator methods
//
- (NSTextView *) textView
{
  return textView;
}

//
//
//
- (CWMessage *) message
{
  return message;
}


//
// This is the same as the above method. It exists just so that it matches the one in
// MailWindowController.
//
- (CWMessage *) selectedMessage
{
  return message;
}


//
// Needed by ThreadArcsCell.
//
- (NSArray *) allMessages
{
  return [mailWindowController allMessages];
}

//
//
//
- (void) setMessage: (CWMessage *) aMessage
{
  if (aMessage)
    {
      ASSIGN(message, aMessage);
     
      if ([message subject])
	{
	  [[self window] setTitle: [message subject]];
	}
    }
}


//
//
//
- (CWFolder *) folder
{
  return folder;
}


//
// 
//
- (void) setFolder: (CWFolder *) aFolder
{
  folder = aFolder;
}


//
//
//
- (MailWindowController *) mailWindowController
{
  return mailWindowController;
}


//
//
//
- (void) setMailWindowController: (MailWindowController *) aMailWindowController
{
  if (aMailWindowController)
    {
      mailWindowController = aMailWindowController;
    }
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
- (void) setShowAllHeaders: (BOOL) aBool
{
  showAllHeaders = aBool;
}


//
//
//
- (BOOL) showRawSource
{
  return showRawSource;
}


//
//
//
- (void) setShowRawSource: (BOOL) aBool
{
  showRawSource = aBool;
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
- (NSInteger) indexOffset
{
  return indexOffset;
}


//
//
//
- (void) setIndexOffset: (NSInteger) theIndexOffset
{
  indexOffset = theIndexOffset;
}


//
// delegate methods
//
- (void) windowDidLoad
{
#ifdef MACOSX
  [[self window] setFrameAutosaveName: @"MessageViewWindow"];
  [[self window] setFrameUsingName: @"MessageViewWindow"];
#endif  

  // We set the last window on top
  [GNUMail setLastMailWindowOnTop: [self window]]; 
}


//
//
//
- (void) windowDidBecomeKey: (NSNotification *) aNotification
{  
  NSInteger count;

  // We clear our 'Save' menu
  count = [[(GNUMail *)[NSApp delegate] saveMenu] numberOfItems];
  while (count > 1)
    {
      count--;
      [[(GNUMail *)[NSApp delegate] saveMenu] removeItemAtIndex: count];
    }
  
  [GNUMail setLastMailWindowOnTop: [self window]];
}


//
//
//
- (void) windowDidResize: (NSNotification *) theNotification
{
  if (!showRawSource)
    {
      [Utilities showMessage: [self message]
		 target: [self textView]
		 showAllHeaders: [self showAllHeaders]];
    }
}


//
//
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  // We update our last mail window on top
  if ([GNUMail lastMailWindowOnTop] == [self window])
    {
      [GNUMail setLastMailWindowOnTop: nil];
    }

  // We remove our window controller from the list of opened window controllers
  // of the "parent" MailWindowController object.
  [[[self mailWindowController] allMessageViewWindowControllers] removeObject: self];
  
  AUTORELEASE(self);
}


//
//
//
-  (void) textView: (NSTextView *) aTextView
     clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	    inRect: (NSRect) cellFrame
	   atIndex: (unsigned) charIndex
  
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
	  atIndex: (unsigned) charIndex
{
  NSDebugLog(@"Opening %@...", [link description]);
  return [[NSWorkspace sharedWorkspace] openURL: link];
}


//
//
//
- (void) updateDataView
{
  [mailWindowController updateDataView];
}

//
//
//
- (id) dataView
{
  return [mailWindowController dataView];
}

//
// Menu validation
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
      if (!aMessage) return NO;
      
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
  // Mark as Flagged / Unflagged
  //
  else if (sel_isEqual(action, @selector(markMessageAsFlaggedOrUnflagged:)))
    {
      return [mailWindowController validateMenuItem:theMenuItem];
    }
  //
  // Mark as Read / Unread
  //
  else if (sel_isEqual(action, @selector(markMessageAsReadOrUnread:)))
    {
      return [mailWindowController validateMenuItem:theMenuItem];
    }
  
  return YES;
}

@end


//
// Private interface
//
@implementation MessageViewWindowController (Private)

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
	}

      // We also set the current superview
      [aBundle setCurrentSuperview: [[self window] contentView]];
    }
}

@end
