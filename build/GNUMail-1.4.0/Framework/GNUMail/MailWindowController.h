/*
**  MailWindowController.h
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2015-2018 Riccardo Mottola
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

#ifndef _GNUMail_H_MailWindowController
#define _GNUMail_H_MailWindowController

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSUInteger
#define NSUInteger unsigned int
#endif
#ifndef NSInteger
#define NSInteger int
#endif
#endif

@class ExtendedOutlineView;
@class CWFolder;
@class CWLocalStore;
@class CWMessage;
@class CWPOP3Folder;
@class CWURLName;
@class FolderNode;
@class LabelWidget;
@class MailHeaderCell;
@class ThreadArcsCell;
@class MailWindow;


@interface MailWindowController : NSWindowController
{
  //
  // Outlets
  //
  IBOutlet NSScrollView *tableScrollView; 
  IBOutlet NSScrollView *textScrollView;

  IBOutlet NSSplitView *splitView;
  IBOutlet NSTextView *textView;

  IBOutlet NSButton *mailboxes;
  IBOutlet NSButton *compose;
  IBOutlet NSButton *forward;
  IBOutlet NSButton *reply;
  IBOutlet NSButton *addresses;
  IBOutlet NSButton *find;

  IBOutlet NSTextField *label;
  
  IBOutlet NSTableColumn *flaggedColumn;
  IBOutlet NSTableColumn *statusColumn;
  IBOutlet NSTableColumn *idColumn;
  IBOutlet NSTableColumn *dateColumn;
  IBOutlet NSTableColumn *fromColumn;
  IBOutlet NSTableColumn *subjectColumn;
  IBOutlet NSTableColumn *sizeColumn;

  IBOutlet NSMenu *menu;
  IBOutlet NSMenuItem *markAsReadOrUnreadContextMI;
  IBOutlet NSMenuItem *markAsFlaggedOrUnflaggedContextMI;
  IBOutlet NSDrawer *drawer;
  IBOutlet ExtendedOutlineView *outlineView;

  //
  // Other ivars
  //
  NSMutableArray *allMessageViewWindowControllers;
  NSMutableArray *_allVisibleMessages;
  NSArray *_allMessages;
  
  FolderNode *allNodes;
  CWFolder *_folder;

  MailHeaderCell *mailHeaderCell;
  ThreadArcsCell *threadArcsCell;
   
  id dataView;

  BOOL _noResetSearchField;
  BOOL draftsOrSentFolder;
  BOOL showAllHeaders;
  BOOL showRawSource;
  
  NSMutableArray *allowedToolbarItemIdentifiers;
  NSMutableDictionary *additionalToolbarItems;

  //
  // Public ivars
  //
  @public
    IBOutlet NSButton *next;
    IBOutlet NSButton *previous;
    IBOutlet id get;
    IBOutlet id delete;
    IBOutlet NSButton *icon;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSSearchField *searchField;
}


//
// Action methods
//
- (IBAction) doubleClickedOnDataView: (id) sender;

- (IBAction) deleteMessage: (id) sender;

- (IBAction) lastMessage: (id) sender;
- (IBAction) firstMessage: (id) sender;

- (IBAction) pageDownMessage: (id) sender;
- (IBAction) pageUpMessage: (id) sender;

- (IBAction) nextInThread: (id) sender;
- (IBAction) nextMessage: (id) sender;
- (IBAction) nextUnreadMessage: (id) sender;
- (IBAction) previousInThread: (id) sender;
- (IBAction) previousMessage: (id) sender;
- (IBAction) previousUnreadMessage: (id) sender;

- (IBAction) replyToMessage: (id) sender;

- (IBAction) viewMessageInWindow: (id) sender;

- (IBAction) markMessageAsReadOrUnread: (id) sender;
- (IBAction) markMessageAsFlaggedOrUnflagged: (id) sender;

- (IBAction) getNewMessages: (id) sender;

- (IBAction) copyOrMoveMessages: (id) sender;
- (IBAction) openOrCloseDrawer: (id) sender;

//
// Access / mutation methods
//
- (CWFolder *) folder;
- (void) setFolder: (CWFolder *) theFolder;

- (CWMessage *) selectedMessage;
- (NSArray *) selectedMessages;

- (BOOL) showAllHeaders;
- (void) setShowAllHeaders: (BOOL) aBOOL;

- (BOOL) showRawSource;
- (void) setShowRawSource: (BOOL) aBool;

- (id) dataView;
- (void) setDataViewType: (int) theType;

- (NSTextView *) textView;

- (MailHeaderCell *) mailHeaderCell;
- (ThreadArcsCell *) threadArcsCell;

- (NSMutableArray *) allMessageViewWindowControllers;

- (NSArray *) allMessages;


//
// delegate methods
//
- (NSMenu *) dataView: (id) aDataView
    contextMenuForRow: (int) theRow;

- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView;

- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn
                       row: (NSInteger) rowIndex;

- (void) tableView: (NSTableView *) aTableView
   willDisplayCell: (id) aCell
    forTableColumn: (NSTableColumn *) aTableColumn
               row: (NSInteger) rowIndex;

- (void) tableViewSelectionDidChange: (NSNotification *) aNotification;

- (void) tableView: (NSTableView *) theTableView
  didReceiveTyping: (NSString *) theString;

-  (void) textView: (NSTextView *) aTextView
     clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	    inRect: (NSRect) cellFrame
           atIndex: (NSUInteger) charIndex;

- (BOOL) textView: (NSTextView *) textView
    clickedOnLink: (id) link 
          atIndex: (NSUInteger) charIndex;

- (void) windowWillClose: (NSNotification *) not;
- (void) windowDidLoad;
- (void) windowDidBecomeKey: (NSNotification *) aNotification;


//
// Other methods
//
- (void) tableViewShouldReloadData;

- (void) updateDataView;
- (void) updateStatusLabel;
- (void) updateWindowTitle;

- (void) doFind: (id) sender;
- (void) resetSearchField;

@end

#endif // _GNUMail_H_MailWindowController
