/*
**  MailboxManagerController.m
**
**  Copyright (C) 2001-2007 Ludovic Marcotte
**  Copyright (c) 2017-2021 Riccardo Mottola
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

#import "MailboxManagerController.h"

#import "ConsoleWindowController.h"
#import "Constants.h"
#import "EditWindowController.h"
#import "ExtendedMenuItem.h"
#import "ExtendedOutlineView.h"
#import "Filter.h"
#import "FilterManager.h"
#import "GNUMail.h"
#import "Task.h"
#import "TaskManager.h"

#import "ImageTextCell.h"
#import "MailboxManager.h"

#import "FolderNode.h"
#import "MailboxManagerCache.h"
#import "MailWindowController.h"
#import "MessageViewWindowController.h"
#import "NewMailboxPanelController.h"
#import "NSUserDefaults+Extensions.h"
#import "Utilities.h"

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolderInformation.h>
#import <Pantomime/CWIMAPCacheManager.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWTCPConnection.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/CWVirtualFolder.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#include <limits.h>

#define SET_DRAFTS   0
#define SET_SENT     1
#define SET_TRASH    2
#define TAKE_OFFLINE 0x100

#define UPDATE_PATH(name, theOldPath, thePath) ({ \
 if ([[allValues objectForKey: name] isEqualToString: theOldPath]) \
   { \
     [allValues setObject: thePath  forKey: name]; \
   } \
})

static MailboxManagerController *singleInstance = nil;


//
// Private methods
//
@interface MailboxManagerController (Private)
- (void) _accountsHaveChanged: (id) sender;
- (BOOL) _deletingDefaultMailbox: (NSString **) theMailboxName
	    usingURLNameAsString: (NSString *) theURLNameAsString;
- (void) _folderCreateCompleted: (NSNotification *) theNotification;
- (void) _folderCreateFailed: (NSNotification *) theNotification;
- (void) _folderDeleteCompleted: (NSNotification *) theNotification;
- (void) _folderDeleteFailed: (NSNotification *) theNotification;
- (void) _folderRenameCompleted: (NSNotification *) theNotification;
- (void) _folderRenameFailed: (NSNotification *) theNotification;
- (void) _folderSubscribeCompleted: (NSNotification *) theNotification;
- (void) _folderUnsubscribeCompleted: (NSNotification *) theNotification;
- (BOOL) _initializeIMAPStoreWithAccountName: (NSString *) theAccountName;
- (void) _nbOfMessages: (NSUInteger *) theNbOfMessages
    nbOfUnreadMessages: (NSUInteger *) theNbOfUnreadMessages
               forItem: (id) theItem;
- (void) _openLocalFolderWithName: (NSString *) theFolderName
                           sender: (id) theSender;
- (void) _openIMAPFolderWithName: (NSString *) theFolderName
                           store: (CWIMAPStore *) theStore
                          sender: (id) theSender;
- (void) _reloadFoldersAndExpandParentsFromNode: (FolderNode *) theNode
                             selectNodeWithPath: (NSString *) thePath;
- (NSString *) _stringValueOfURLNameFromItem: (id) theItem
                                       store: (CWStore **) theStore;
- (void) _updateMailboxesFromOldPath: (NSString *) theOldPath
                              toPath: (NSString *) thePath;
- (void) _updateContextMenu;
@end

// 
// Here's how it does work:
//
// _allFolders (NSArray) -> localNodes (FolderNode * - name == _("Local"))
// 
//                       -> IMAP FolderNode 1 (FoderNode * - name == "username @ imap.server1.com")  
//                            
//                       -> IMAP FolderNode 2 (FoderNode * - name == "username @ imap.server2.com")
//  
//                       -> ...   
//                                 
//
@implementation MailboxManagerController

- (id) init
{
  NSToolbar *aToolbar;
  id aCell;
  MailboxManager *theWindow;
  int preferredViewStyle;

  preferredViewStyle = [[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView];
  if (preferredViewStyle == GNUMailDrawerView)
    {
      self = [super init];
      if (self)
        {
          ASSIGN(_cache, [MailboxManagerCache cacheFromDisk]);
          [self windowDidLoad];
        }
    }
  else if (preferredViewStyle == GNUMailFloatingView)
    {
      theWindow = [[MailboxManager alloc] initWithContentRect: NSMakeRect(200,200,220,300)
						    styleMask: NSClosableWindowMask|NSTitledWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
						      backing: NSBackingStoreBuffered
							defer: YES];

      self = [super initWithWindow: theWindow];
      if (self)
        {
          ASSIGN(_cache, [MailboxManagerCache cacheFromDisk]);
          [self windowDidLoad];

      [theWindow layoutWindow];
      [theWindow setDelegate: self];

      // We link our outlets
      outlineView = theWindow->outlineView;
      scrollView = theWindow->scrollView;
      RELEASE(theWindow);

      // We set the title of our window (causing it to be loaded under OS X)
      [[self window] setTitle: _(@"Mailboxes")];

      aToolbar = [[NSToolbar alloc] initWithIdentifier: @"MailboxManagerToolbar"];
      [aToolbar setDelegate: self];
      [aToolbar setAllowsUserCustomization: YES];
      [aToolbar setAutosavesConfiguration: YES];
      [[self window] setToolbar: aToolbar];
      RELEASE(aToolbar);

      // We now set our data cell for the "Mailbox" column
      aCell =  [[ImageTextCell alloc] init];
      [[outlineView tableColumnWithIdentifier: @"Mailbox"] setDataCell: aCell];
      AUTORELEASE(aCell);

      // We register the outline view for dragged types
      [outlineView registerForDraggedTypes: [NSArray arrayWithObject: MessagePboardType]];

      // We set our autosave window frame name and restore the one from the user's defaults.
      [[self window] setFrameAutosaveName: @"MailboxManager"];
      [[self window] setFrameUsingName: @"MailboxManager"]; 

      // We set our autosave name for our outline view
      [outlineView setAutosaveName: @"MailboxManager"];
      [outlineView setAutosaveTableColumns: YES];

      // We set our outline view background color
      if ([[NSUserDefaults standardUserDefaults] colorForKey: @"MAILBOXMANAGER_OUTLINE_COLOR"])
	{
	  [outlineView setBackgroundColor: [[NSUserDefaults standardUserDefaults]
					     colorForKey: @"MAILBOXMANAGER_OUTLINE_COLOR"]];
	  [scrollView setBackgroundColor: [[NSUserDefaults standardUserDefaults]
					    colorForKey: @"MAILBOXMANAGER_OUTLINE_COLOR"]];
	}
        }
    }
  return self;
}


//
//
//
- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailFloatingView)
    {
      [[self window] setDelegate: nil];
    }

  RELEASE(menu);
  RELEASE(localNodes);
  RELEASE(_cache);
  RELEASE(_allFolders);
  RELEASE(allStores);

  RELEASE(_open_folder);
  RELEASE(_sort_right);
  RELEASE(_sort_down);
  RELEASE(_drafts);
  RELEASE(_inbox);
  RELEASE(_sent);
  RELEASE(_trash);
  
  [super dealloc];
}


//
// Datasource methods for the outline view
//
- (id) outlineView: (NSOutlineView *) outlineView
	     child: (NSInteger) childIndex
	    ofItem: (id) item
{
  if (!item || item == _allFolders)
    {
      return [_allFolders objectAtIndex: childIndex];
    }

  if ([item isKindOfClass: [FolderNode class]])
    {
      return [(FolderNode *)item childAtIndex: childIndex];
    }
 
  return nil;
}


//
//
//
- (BOOL) outlineView: (NSOutlineView *) outlineView
    isItemExpandable: (id) item
{
  if (item == _allFolders || [_allFolders containsObject: item])
    {
      return YES;
    }
  
  if ([item isKindOfClass: [FolderNode class]])
    {
      if ([(FolderNode *)item childCount] > 0)
	{
	  return YES;
	}
      else
	{
	  return NO;
	}
    }

  return NO;
}


//
//
//
- (NSInteger)  outlineView: (NSOutlineView *) outlineView 
    numberOfChildrenOfItem: (id) item
{
  // The root.
  if (!item || item == _allFolders)
    {
      return [_allFolders count];
    }
  
  // Children of our root, the Local folder and all the IMAP folders, subfolders, etc.
  if ([item isKindOfClass: [FolderNode class]])
    {
      return [(FolderNode *)item childCount];
    }
  
  return 0;
}


//
//
//
- (id)         outlineView: (NSOutlineView *) outlineView 
 objectValueForTableColumn: (NSTableColumn *) tableColumn 
		    byItem: (id) item
{
  if ([[[tableColumn headerCell] stringValue] isEqual: _(@"Mailbox")])
    {
      if ([item isKindOfClass: [FolderNode class]])
	{
	  return [(FolderNode *)item name];
	}
    }
  
  if ([item isKindOfClass: [FolderNode class]] && [item parent])
    {
      BOOL b;
      
      b = [[Utilities completePathForFolderNode: item  separator: '/']
	    hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]];
      
      if ([item childCount] == 0 || !b)
	{
	  NSUInteger nbOfMessages, nbOfUnreadMessages;
	  
	  [self _nbOfMessages: &nbOfMessages
		nbOfUnreadMessages: &nbOfUnreadMessages
		forItem: item];
	  
	  // If we have an IMAP folder AND the count is 0 AND it has children, do nothing.
	  if (!b && nbOfMessages == 0 && [item childCount] > 0) return nil;

	  if ([[[tableColumn headerCell] stringValue] isEqual: _(@"Messages")])
	    {
	      if (nbOfUnreadMessages > 0) return [NSString stringWithFormat: @"(%lu) %lu", (unsigned long)nbOfUnreadMessages, (unsigned long)nbOfMessages];
	      return [NSString stringWithFormat: @"%lu", (unsigned long)nbOfMessages];
	    }
	}
    }
  
  return nil;
}


//
//
//
- (void) outlineView: (NSOutlineView *) theOutlineView
      setObjectValue: (id) theObject
      forTableColumn: (NSTableColumn *) theTableColumn
	      byItem: (id) theItem
{
  NSString *aDefaultMailbox;
  id aStore;
 
  // If the previous name is the same as the new one, ignore it.
  if ([[(FolderNode *)theItem name] isEqualToString: theObject])
    return;

  //
  // If we tried to rename a special mailbox, we warn for now. This is quite
  // useful in IMAP since whenever we rename INBOX, a new INBOX is created
  // automatically. So, if a user renames by mistake his INBOX, he will
  // have to move all mails back to his INBOX as he won't be able to rename
  // the mailbox back to "INBOX".
  //
  if ([self _deletingDefaultMailbox: &aDefaultMailbox
	    usingURLNameAsString: [self _stringValueOfURLNameFromItem: theItem  store: &aStore]])
    {
      int choice;
      
      choice = NSRunAlertPanel(_(@"Warning!"),
			       _(@"You are about to rename the %@ special mailbox to %@.\nDo you want to proceed?"),
			       _(@"OK"),     // default
			       _(@"Cancel"), // alternate
			       NULL,
			       aDefaultMailbox,
			       theObject);
      
      if (choice == NSAlertAlternateReturn)
	{
	  return;
	}
    }
  
    {
      NSString *pathOfFolder;
      id aWindow;

      aStore = [self storeForFolderNode: theItem];

      //
      // pathOfFolder will hold a value like:  folderA
      //                                       folderA/folderB
      //                                       folderA/folderB/folderC
      //                                  or:
      //                                       folderA.folderB
      //                                       folderA.folderB.folderC
      //
      pathOfFolder = [Utilities pathOfFolderFromFolderNode: theItem
				separator: [(id<CWStore>)aStore folderSeparator]];
      
      [(id<CWStore>)aStore renameFolderWithName: [pathOfFolder stringByDeletingFirstPathSeparator: [(id<CWStore>)aStore folderSeparator]]
		    toName: [[NSString stringWithFormat: @"%@%c%@",
				       [pathOfFolder stringByDeletingLastPathComponentWithSeparator: [(id<CWStore>)aStore folderSeparator]],
				       [(id<CWStore>)aStore folderSeparator], theObject] 
			      stringByDeletingFirstPathSeparator: [(id<CWStore>)aStore folderSeparator]]];

      // We select the newly renamed node and update the outline view
      aWindow = [Utilities windowForFolderName: [[NSString stringWithFormat: @"%@%c%@",
							   [pathOfFolder stringByDeletingLastPathComponentWithSeparator: [(id<CWStore>)aStore folderSeparator]],
							   [(id<CWStore>)aStore folderSeparator], theObject] 
						  stringByDeletingFirstPathSeparator: [(id<CWStore>)aStore folderSeparator]]
			   store: aStore];

      if (aWindow)
	{
	  [[aWindow windowController] windowDidBecomeKey: nil];
	}
    }
}


//
// Delegate method used to prevent the user from renaming
// "invalid" mailboxes / folders.
//
- (BOOL)   outlineView: (NSOutlineView *) theOutlineView
 shouldEditTableColumn: (NSTableColumn *) theTableColumn
		  item: (id) theItem
{
  NSInteger row, level;
  id item;

  row = [theOutlineView selectedRow];

  if (row < 0)
    {
      return NO;
    }
  
  item = [theOutlineView itemAtRow: row];
  level = [theOutlineView levelForItem: item];
  
  if ([theOutlineView numberOfSelectedRows] != 1 || level < 1)
    {
      return NO;
    }

  return YES;
}


//
//
//
- (void) outlineView: (NSOutlineView *) aOutlineView
     willDisplayCell: (id) aCell
      forTableColumn: (NSTableColumn *) aTableColumn
                item: (id) item
{
  // We set our default node icon, if we need to.
  if ([[[aTableColumn headerCell] stringValue] isEqual: _(@"Mailbox")])
    {
      NSInteger level;
      
      level = [aOutlineView levelForItem: item];
      
      if (level > 0)
	{
	  NSString *aString;
	  id aStore;
	  
	  aStore = nil;
	  aString = [self _stringValueOfURLNameFromItem: item
						  store: &aStore];

	  if ([Utilities stringValueOfURLName: aString  isEqualTo: @"TRASHFOLDERNAME"])
	    {
	      [aCell setImage: _trash];
	    }
	  else if ([Utilities stringValueOfURLName: aString  isEqualTo: @"SENTFOLDERNAME"])
	    {
	      [aCell setImage: _sent];
	    }
	  else if ([Utilities stringValueOfURLName: aString  isEqualTo: @"DRAFTSFOLDERNAME"])
	    {
	      [aCell setImage: _drafts];
	    }
	  else if ([Utilities stringValueOfURLName: aString  isEqualTo: @"INBOXFOLDERNAME"])
	    { 
	      [aCell setImage: _inbox];
	    }
	  else
	    {
	      [aCell setImage: _open_folder];
	    }
	} 
      else 
	{ 
	  [aCell setImage: nil];
	}
    }

  //
  //
  //
  if ([item isKindOfClass: [FolderNode class]] && [item parent])
    {
      NSUInteger nbOfMessages, nbOfUnreadMessages;
      
      [self _nbOfMessages: &nbOfMessages
	    nbOfUnreadMessages: &nbOfUnreadMessages
	    forItem: item];

      if (nbOfUnreadMessages > 0)
	{
	  [aCell setFont: [NSFont boldSystemFontOfSize: _font_size]];
	  return;
	}
    }
  
  // We set our default font.
  [aCell setFont: [NSFont systemFontOfSize: _font_size]];
  
  // We set the right text aligment
  if ([[[aTableColumn headerCell] stringValue] isEqual: _(@"Mailbox")])
    {
      [aCell setAlignment: NSLeftTextAlignment];
    }
  else
    {
      [aCell setAlignment: NSRightTextAlignment];
    }   
}


//
//
//
- (void) outlineViewSelectionDidChange: (NSNotification *) theNotification
{
  [self open: [theNotification object]];
}


//
//
//
- (NSMenu *) outlineView: (NSOutlineView *) aOutlineView
      contextMenuForItem: (id) item
{
  id theItem, o;
  NSUInteger i;

  o = [self storeForFolderNode: [outlineView itemAtRow: [aOutlineView selectedRow]]];

  for (i = 0; i < [[menu itemArray] count]; i++)
    {
      theItem = [[menu itemArray] objectAtIndex: i];
      [theItem setEnabled: [self validateMenuItem: theItem]];

      if ([theItem tag] == TAKE_OFFLINE && [o isKindOfClass: [CWIMAPStore class]])
	{
	  if ([o isConnected])
	    {
	      [theItem setTitle: _(@"Take Account Offline")];
	    }
	  else
	    {
	      [theItem setTitle: _(@"Take Account Online")];
	    }
	}
    }

  [menu update];

  return menu;
}


//
//
//
- (BOOL) validateMenuItem: (NSMenuItem *) theItem
{
  NSInteger row, level;
  BOOL aBOOL;
  
  row = [outlineView selectedRow];
  level = [outlineView levelForItem: [outlineView itemAtRow: row]];
 
  //
  // Validation for our "Take Account Offline" item
  //
  if ([theItem tag] == TAKE_OFFLINE)
    {
      return (level == 0 && [outlineView itemAtRow: row] != localNodes);
    }

  if ([[theItem title] isEqualToString: _(@"Delete...")] ||
      [[theItem title] isEqualToString: _(@"Rename")])
    {
      aBOOL = (row > 0 && [outlineView numberOfSelectedRows] == 1 && level >= 1);
    }
  else
    {
      aBOOL = (row >= 0 && [outlineView numberOfSelectedRows] == 1 && level >= 0);
    }

  return aBOOL;
}


//
// Delegate methods
//
- (BOOL) outlineView: (NSOutlineView *) outlineView
    shouldExpandItem: (id) item
{
  if (item == _allFolders || item == localNodes)
    {
      return YES;
    }
  
  if ([_allFolders containsObject: item])
    {
      return [self _initializeIMAPStoreWithAccountName: [(FolderNode *)item name]];
    }
  
  return YES;
}


//
// NSOutlineViewDataSource Drag and drop
//
- (NSDragOperation) outlineView: (NSOutlineView*) theOutlineView
		   validateDrop: (id <NSDraggingInfo>) info
		   proposedItem: (id) item
	     proposedChildIndex: (NSInteger) childIndex
{
  if (![item respondsToSelector: @selector(childCount)] ||
      childIndex < 0 || childIndex >= [(FolderNode*)item childCount])
    {
      return NSDragOperationNone;
    }
  
  // Let's get the right item..
  item = [item childAtIndex: childIndex];
  
  if ([info draggingSourceOperationMask] & NSDragOperationGeneric)
    {
      [theOutlineView setDropItem: item
		      dropChildIndex: NSOutlineViewDropOnItemIndex];
      return NSDragOperationGeneric;
    }
  else if ([info draggingSourceOperationMask] & NSDragOperationCopy)
    {
      [theOutlineView setDropItem: item
		      dropChildIndex: NSOutlineViewDropOnItemIndex];
      return NSDragOperationCopy;
    }
  else
    {
      return NSDragOperationNone;
    }
}


//
// NSOutlineViewDataSource Drag and drop
//
- (BOOL) outlineView: (NSOutlineView*) outlineView
	  acceptDrop: (id <NSDraggingInfo>) info
		item: (id) item
	  childIndex: (NSInteger) childIndex
{
  CWFolder *aSourceFolder, *aDestinationFolder;
  CWStore *aSourceStore, *aDestinationStore;
  MailWindowController *aMailWindowController;

  FolderNode *aFolderNode;
  NSString *aFolderName;
  NSArray *propertyList;
  
  NSMutableArray *allMessages;
  NSUInteger i, count;
  
  if (!item || childIndex != NSOutlineViewDropOnItemIndex)
    {
      NSBeep();
      return NO;
    }
  
  aFolderNode = (FolderNode *)item;

  // We get our store and our folder name
  aDestinationStore = [self storeForFolderNode: aFolderNode];

  aFolderName = [Utilities pathOfFolderFromFolderNode: aFolderNode
		   separator: [(id<CWStore>)aDestinationStore folderSeparator]];
  
  // We get the MailWindowController source
  aMailWindowController = 
	(MailWindowController *)[[info draggingSource] delegate];
  
  if (!aMailWindowController ||
	![aMailWindowController isKindOfClass: [MailWindowController class]] ||
      	!aFolderName ||
	[aFolderName length] == 0)
    {
      NSBeep();
      return NO;
    }
  
  // We verify if we aren't trying to transfer to the current mbox!
  aSourceFolder = [aMailWindowController folder];
  aSourceStore = [aSourceFolder store];
  
  if (aSourceStore == aDestinationStore &&
	[[aSourceFolder name] isEqualToString: aFolderName])
    {
      NSRunInformationalAlertPanel(_(@"Transfer error!"),
	 	_(@"You cannot transfer a message inside the same mailbox!"),
		_(@"OK"),
		NULL, 
		NULL,
		NULL);
      return NO;      
    }


  // We get a reference to our destination folder,
  // w/o parsing it if it's not already open.
  // or w/o selecting it if it's an IMAP store.
  if ([(id<NSObject>)aDestinationStore isKindOfClass: [CWIMAPStore class]])
    {
      aDestinationFolder =
	(CWFolder *)[(CWIMAPStore *)aDestinationStore folderForName: aFolderName
						       	     select: NO];
    }
  else
    {
      aDestinationFolder =
	(CWFolder *)[(CWLocalStore *)aDestinationStore folderForName:
								aFolderName];

    }

  if (!aDestinationFolder)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"An error occurred while trying to open the \"%@\" mailbox.\nThe drag and drop operation has been cancelled."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      aFolderName);
      return NO;
    }

  [aDestinationFolder setProperty: [NSDate date]  forKey: FolderExpireDate];


  // We retrieve property list of messages from paste board
  propertyList = [[info draggingPasteboard] propertyListForType: MessagePboardType];
  
  if (!propertyList)
    {
      return NO;
    }

  allMessages = [[NSMutableArray alloc] init];
  count = [propertyList count];
  
  for (i = 0; i < count; i++)
    {
      [allMessages addObject:
                     [[aSourceFolder messages] objectAtIndex:
                                (NSUInteger)[[(NSDictionary *)[propertyList objectAtIndex: i]
				objectForKey: MessageNumber] intValue]-1]];
    }
  
  [self transferMessages: allMessages
	fromStore: aSourceStore
	fromFolder: aSourceFolder
	toStore: aDestinationStore
	toFolder: aDestinationFolder
	operation: (([info draggingSourceOperationMask]&NSDragOperationGeneric) == NSDragOperationGeneric ? MOVE_MESSAGES : COPY_MESSAGES)];

  RELEASE(allMessages);

  return YES;
}


//
//
//
- (void) windowDidLoad
{
  NSMenuItem *aMenuItem;
  NSMenu *aMenu;

  menu = [[NSMenu alloc] init];
  [menu setAutoenablesItems: NO];
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Create...") action: @selector(create:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Delete...") action: @selector(delete:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Rename") action: @selector(rename:)  keyEquivalent: @""];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Take Account Offline") action: @selector(takeOffline:)  keyEquivalent: @""];
  [aMenuItem setTag: TAKE_OFFLINE];
  [aMenuItem setTarget: self];
  [menu addItem: aMenuItem];
  RELEASE(aMenuItem);
  
  //
  // Our "Use..." menu with its three items
  //
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Use") action: NULL  keyEquivalent: @""];
  [menu addItem: aMenuItem];
  aMenu = [[NSMenu alloc] init];
  [aMenuItem setSubmenu: aMenu];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Small Icons") action: @selector(changeSize:)  keyEquivalent: @""];
  [aMenuItem setTag: GNUMailSmallIconSize];
  [aMenuItem setTarget: self];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
 
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Standard Icons") action: @selector(changeSize:)  keyEquivalent: @""];
  [aMenuItem setTag: GNUMailStandardIconSize];
  [aMenuItem setTarget: self];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Large Icons") action: @selector(changeSize:)  keyEquivalent: @""];
  [aMenuItem setTag: GNUMailLargeIconSize];
  [aMenuItem setTarget: self];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
  RELEASE(aMenu);

  
  //
  // Our "Set Mailbox as..." menu with its items
  //
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Set Mailbox as") action: NULL  keyEquivalent: @""];
  [menu addItem: aMenuItem];
  aMenu = [[NSMenu alloc] init];
  [aMenuItem setSubmenu: aMenu];
  RELEASE(aMenuItem);
  
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Drafts for Account") action: NULL  keyEquivalent: @""];
  [aMenuItem setTag: SET_DRAFTS];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Sent for Account") action: NULL  keyEquivalent: @""];
  [aMenuItem setTag: SET_SENT];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);

  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Trash for Account") action: NULL  keyEquivalent: @""];
  [aMenuItem setTag: SET_TRASH];
  [aMenu addItem: aMenuItem];
  RELEASE(aMenuItem);
  RELEASE(aMenu);
  
  [self _updateContextMenu];
  [self changeSize: nil];

  // We initialize our array containing all Stores and we load of folders
  _allFolders = [[NSMutableArray alloc] init];
  
  // We initialize our dictionary containing all openend CWIMAPStores
  allStores = [[NSMutableDictionary alloc] init];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_accountsHaveChanged:)
    name: AccountsHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderCreateCompleted:)
    name: PantomimeFolderCreateCompleted
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderCreateFailed:)
    name: PantomimeFolderCreateFailed
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderDeleteCompleted:)
    name: PantomimeFolderDeleteCompleted
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderDeleteFailed:)
    name: PantomimeFolderDeleteFailed
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderRenameCompleted:)
    name: PantomimeFolderRenameCompleted
    object: nil];
  
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderRenameFailed:)
    name: PantomimeFolderRenameFailed
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderSubscribeCompleted:)
    name: PantomimeFolderSubscribeCompleted
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_folderUnsubscribeCompleted:)
    name: PantomimeFolderUnsubscribeCompleted
    object: nil];
}


//
// action methods
//
- (IBAction) changeSize: (id) sender
{
  int size, height;

  if (sender)
    {
      size = [sender tag];
    }
  else
    {
      size = [[NSUserDefaults standardUserDefaults] integerForKey: @"IconSize"  default: GNUMailStandardIconSize];
    }
  
  ASSIGN(_sort_right, [NSImage imageNamed: @"sort_right"]);
  ASSIGN(_sort_down, [NSImage imageNamed: @"sort_down"]);

  switch (size)
    {
    case GNUMailSmallIconSize:
      ASSIGN(_drafts, [NSImage imageNamed: @"create_12"]);
      ASSIGN(_inbox, [NSImage imageNamed: @"retrieve_12"]);
      ASSIGN(_sent, [NSImage imageNamed: @"send_12"]);
      ASSIGN(_trash, [NSImage imageNamed: @"trash_12"]);
      ASSIGN(_open_folder, [NSImage imageNamed: @"folder_12"]);
      _font_size = 9;
      height = 12;
      break;

    case GNUMailLargeIconSize:
      ASSIGN(_drafts, [NSImage imageNamed: @"create_20"]);
      ASSIGN(_inbox, [NSImage imageNamed: @"retrieve_20"]);
      ASSIGN(_sent, [NSImage imageNamed: @"send_20"]);
      ASSIGN(_trash, [NSImage imageNamed: @"trash_20"]);
      ASSIGN(_open_folder, [NSImage imageNamed: @"folder_20"]);
      height = 20;

      _font_size = [NSFont systemFontSize];

      break;
      
    case GNUMailStandardIconSize:
    default:
      ASSIGN(_drafts, [NSImage imageNamed: @"create_16"]);
      ASSIGN(_inbox, [NSImage imageNamed: @"retrieve_16"]);
      ASSIGN(_sent, [NSImage imageNamed: @"send_16"]);
      ASSIGN(_trash, [NSImage imageNamed: @"trash_16"]);
      ASSIGN(_open_folder, [NSImage imageNamed: @"folder_16"]);
      height = 16;
#ifdef GNUSTEP
      _font_size = [NSFont systemFontSize];
#else
      _font_size = [NSFont smallSystemFontSize];
#endif
    }

  [outlineView setRowHeight: height];
  [outlineView setNeedsDisplay: YES];

  [[NSUserDefaults standardUserDefaults] setInteger: size  forKey: @"IconSize"];
}


//
//
//
- (IBAction) open: (id) sender
{
  id item;
  NSInteger row, level;
  
  row = [outlineView selectedRow];

  // If no row is selected and we had a last MailWindow on top, we set its folder to nil.
  // Otherwise, we just return.
  if (row < 0)
    {
      if ([GNUMail lastMailWindowOnTop])
	{
	  [[[[GNUMail lastMailWindowOnTop] windowController] folder] close];
	  
	  if ([[[GNUMail lastMailWindowOnTop] windowController] isKindOfClass: [MailWindowController class]])
	    {
	      [[[GNUMail lastMailWindowOnTop] windowController] setFolder: nil];
	    }
	  else
	    {
	      [[[[GNUMail lastMailWindowOnTop] windowController] mailWindowController] setFolder: nil];
	    }
	}
      return;
    }

  item = [outlineView itemAtRow: row];
  level = [outlineView levelForItem: item];
  
  //
  // We must verify that:
  //
  // a) we have at least one selected row
  // b) we haven't selected our root, or a store (local or IMAP)
  //
  if ([outlineView numberOfSelectedRows] != 1)
    {
      NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				   _(@"You must select a valid mailbox to open!"),
				   _(@"OK"),
				   NULL, 
				   NULL,
				   NULL);
      return;
    }
  else if (level < 1)
    {
      if (![outlineView isItemExpanded: item])
	{
	  [outlineView expandItem: item];
	}
      return;
    }
 
  
  // We verify if it's a local folder
  if ([[Utilities completePathForFolderNode: item  separator: '/'] 
	hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]])
    { 
      NSString *aString;
      
      aString = [Utilities pathOfFolderFromFolderNode: (FolderNode *)item
			   separator: '/'];

      [self _openLocalFolderWithName: aString  sender: sender];
    }
  // It's an IMAP folder...
  else
    {
      NSString *aServerName, *aUsername, *aString;
      CWIMAPStore *aStore;

      [Utilities storeKeyForFolderNode: item
      		 serverName: &aServerName
      		 username: &aUsername];

      aStore = (CWIMAPStore *)[self storeForName: aServerName
				    username: aUsername];
      
      aString = [[Utilities pathOfFolderFromFolderNode: (FolderNode *)item  separator: '/']
		  stringByReplacingOccurrencesOfCharacter: '/'
		  withCharacter: [aStore folderSeparator]];
      
      [self _openIMAPFolderWithName: aString
	    store: aStore
	    sender: sender];
    }
}


//
//
//
- (IBAction) create: (id) sender
{
  NewMailboxPanelController *theController;
  id aStore, item;
  NSInteger row;
  
  row = [outlineView selectedRow];

  if (row < 0 || row >= [outlineView numberOfRows])
    {
      NSBeep();
      return;
    }

  item = [outlineView itemAtRow: row];
  
  if ([outlineView numberOfSelectedRows] != 1)
    {
      NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				   _(@"You must select a valid root where to create this new mailbox."),
				   _(@"OK"),
				   NULL, 
				   NULL,
				   NULL);
      return;
    }
  
  //
  // We create our NewMailboxPanelController object. It'll be automatically deallocated when the 
  // window will be closed.
  //
  theController = [[NewMailboxPanelController alloc] initWithWindowNibName: @"NewMailboxPanel"];

  //
  // We get the right store and we disable our mailbox type popup button 
  // if we are creating an IMAP mailbox.
  //
  aStore = [self storeForFolderNode: item];

  if ([NSApp runModalForWindow: [theController window]] == NSRunStoppedResponse)
    {
      NSString *aString, *pathOfFolder;
      int type;

      pathOfFolder = [Utilities pathOfFolderFromFolderNode: item
				separator: [aStore folderSeparator]];
            
      if (!pathOfFolder || [pathOfFolder length] == 0)
	{
	  aString = [[[theController mailboxNameField] stringValue] stringByTrimmingWhiteSpaces];
	}
      else
	{
	  aString = [NSString stringWithFormat: @"%@%c%@",
			      pathOfFolder,
			      [aStore folderSeparator],
			      [[[theController mailboxNameField] stringValue] stringByTrimmingWhiteSpaces]];
	}
      
      if ([[NSUserDefaults standardUserDefaults] integerForKey: @"UseMaildirMailboxFormat"  default: NSOffState] == NSOnState)
	{
	  type = PantomimeFormatMaildir;
	}
      else
	{
	  type = PantomimeFormatMbox;
	}

      // We can now proceed with the creation of our new folder
      [aStore createFolderWithName: aString  type: type  contents: nil];
    }
 
#ifndef MACOSX
  [[self window] makeKeyAndOrderFront: self];
#endif

  RELEASE(theController);
}


//
//
//
- (IBAction) delete: (id) sender
{
  NSString *aFolderName, *aString;
  id aStore, item;
   
  int choice, row, level;
 
  
  row = [outlineView selectedRow];

  if (row < 0 || row >= [outlineView numberOfRows])
    {
      NSBeep();
      return;
    }

  item = [outlineView itemAtRow: row];
  level = [outlineView levelForItem: item];
  
  if ([outlineView numberOfSelectedRows] != 1 || level < 1)
    {
      NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				   _(@"Please select the mailbox you would like to delete."),
				   _(@"OK"),
				   NULL, 
				   NULL,
				   NULL);
      return;
    }
  
  aString = [self _stringValueOfURLNameFromItem: item  store: &aStore];
  
  // We get our folder name, respecting the folder separator
  aFolderName = [Utilities pathOfFolderFromFolderNode: (FolderNode *)item
			   separator: [(id<CWStore>)aStore folderSeparator]];
  
  // We show our prompt panel
  choice = NSRunAlertPanel(_(@"Delete..."),
			   _(@"Are you sure you want to delete the \"%@\" mailbox?"),
			   _(@"Delete"),  // default
			   _(@"Cancel"),  // alternate
			   nil,
			   aFolderName);
  
  if (choice == NSAlertDefaultReturn)
    {
      NSString *aDefaultMailbox;
      
      if ([self _deletingDefaultMailbox: &aDefaultMailbox  usingURLNameAsString: aString])
	{
	  NSRunAlertPanel(_(@"Error while deleting!"),
  			  _(@"You can't delete your default %@ mailbox. Use the Mailboxes tab in the\nAccount Preferences panel to change it before trying again."),
			  _(@"OK"),   // default
			  NULL,       // alternate
  			  NULL,
			  aDefaultMailbox);
	  return;
	}
      
      if ([aStore folderForNameIsOpen: aFolderName])
	{
	  id aWindow;

	  // Get the associated MailWindow.
	  aWindow = [Utilities windowForFolderName: aFolderName  store: aStore];
	  
	  // We just close the mailbox and leave its MailWindow empty!
	  [[[aWindow windowController] folder] close];
	  [[aWindow windowController] setFolder: nil];
	}
 
      // We now delete the mailbox...
      [aStore deleteFolderWithName: aFolderName];
    }
}


//
//
//
- (IBAction) rename: (id) sender
{
  NSInteger row;

  row = [outlineView selectedRow];

  if (row <= 0 || row >= [outlineView numberOfRows])
    {
      NSBeep();
      return;
    }

  [outlineView editColumn: 0
	       row: row
	       withEvent: nil
	       select: YES];
}


//
//
//
- (IBAction) takeOffline: (id) sender
{
  CWIMAPStore *aStore;

  aStore = [self storeForFolderNode: (FolderNode *)[outlineView itemAtRow: [outlineView selectedRow]]];

  if (aStore)
    {
      [self setStore: nil  name: [aStore name]  username: [aStore username]];
      [self closeWindowsForStore: aStore];
    }
  else
    {
      [self open: sender];
    }
}


//
//
//
- (IBAction) setMailboxAs: (id) sender
{
  NSMutableDictionary *theAccount, *allAccounts, *allValues;
  NSString *aString;
  CWStore *aStore;

  allAccounts = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] 
								   objectForKey: @"ACCOUNTS"]];
  theAccount = [NSMutableDictionary dictionaryWithDictionary: [allAccounts objectForKey: [sender title]]];
  allValues = [NSMutableDictionary dictionaryWithDictionary: [theAccount objectForKey: @"MAILBOXES"]];
  aString = [self _stringValueOfURLNameFromItem: (FolderNode *)[outlineView itemAtRow: [outlineView selectedRow]]  store: &aStore];

  switch ([sender tag])
    {
    case SET_DRAFTS:
      [allValues setObject: aString  forKey: @"DRAFTSFOLDERNAME"];
      break;
    case SET_SENT:
      [allValues setObject: aString  forKey: @"SENTFOLDERNAME"];
      break;
    case SET_TRASH:
      [allValues setObject: aString  forKey: @"TRASHFOLDERNAME"];
      break;
    }
    
  [theAccount setObject: allValues  forKey: @"MAILBOXES"];
  [allAccounts setObject: theAccount  forKey: [sender title]];
  [[NSUserDefaults standardUserDefaults] setObject: allAccounts  forKey: @"ACCOUNTS"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [allAccounts release];
  [outlineView setNeedsDisplay: YES];
}


//
// access / mutation methods
//
- (NSOutlineView *) outlineView
{
  return outlineView;
}


//
// This method returns a pointer to an open store which has
// theFolderNode as one of its children.
//
- (id) storeForFolderNode: (FolderNode *) theFolderNode
{
  CWStore *aStore;
  
  if ([[Utilities completePathForFolderNode: theFolderNode  separator: '/']
	hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]])
    {
      aStore = [self storeForName: @"GNUMAIL_LOCAL_STORE"  username: NSUserName()];
    }
  else
    {
      NSString *aServerName, *aUsername;
      
      [Utilities storeKeyForFolderNode: theFolderNode
		 serverName: &aServerName
		 username: &aUsername];
      
      aStore = [self storeForName: aServerName  username: aUsername];
    }

  return aStore;
}


//
//
//
- (id) storeForName: (NSString *) theName
	   username: (NSString *) theUsername
{
  return [allStores objectForKey: [NSString stringWithFormat: @"%@ @ %@", theUsername, theName]];
}


//
//
//
- (id) storeForURLName: (CWURLName *) theURLName
{
  id aStore;
  
  if ([[theURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame )
    {
      aStore = [self storeForName: @"GNUMAIL_LOCAL_STORE"  username: NSUserName()];
    }
  else
    {
      if ([self _initializeIMAPStoreWithAccountName: [Utilities accountNameForServerName: [theURLName host]
								username: [theURLName username]]])
	{
	  aStore = [self storeForName: [theURLName host]  username: [theURLName username]];
	}
      else
	{
	  aStore = nil;
	}
    }
  
  return aStore;
}


//
//
//
- (id) folderForURLName: (CWURLName *) theURLName
{
  id aStore, aFolder;

  aStore = [self storeForURLName: theURLName];

  if (!aStore) return nil;

  if ([aStore isKindOfClass: [CWIMAPStore class]])
    {
      aFolder = [(CWIMAPStore *)aStore folderForName: [theURLName foldername]  select: NO];
    }
  else
    {
      aFolder = [(CWLocalStore *)aStore folderForName: [theURLName foldername]];
    }

  return aFolder;
}


//
//
//
- (void) setStore: (id) theStore
	     name: (NSString *) theName
	 username: (NSString *) theUsername
{
  NSString *aString;

  aString = [NSString stringWithFormat: @"%@ @ %@", theUsername, theName];

  // We verify if we want to remove an opened store.
  if (!theStore && theName && theUsername)
    {
      FolderNode *aFolderNode;
      NSInteger row;

      // For an IMAP store, we remove all children of our root node
      aFolderNode = [self storeFolderNodeForName: [Utilities accountNameForServerName: theName  username: theUsername]];

#ifndef MACOSX
      [aFolderNode setChildren: nil];
#endif
      [outlineView collapseItem: aFolderNode];
      
      row = [outlineView rowForItem: aFolderNode];

      if (row >= 0 && row < [outlineView numberOfRows])
	{
	  [outlineView selectRow: row  byExtendingSelection: NO];
	}

      [allStores removeObjectForKey: aString];
      return;
    }
  
  // We always first "remove" the object in case we call this method
  // multiple times with the same object.
  RETAIN(theStore);
  [allStores removeObjectForKey: aString];
      
  // We {re}add it to our dictionary.
  [allStores setObject: theStore  forKey: aString];
  RELEASE(theStore);
}

//
// FIXME: support more than one MailWindow associated to the store
//
- (void) closeWindowsForStore: (id) theStore
{
  NSWindow *aWindow;
  
  if ((aWindow = [Utilities windowForFolderName: nil  store: theStore]))
    {
      [aWindow close];
    }
  
  [allStores removeObjectForKey: [NSString stringWithFormat: @"%@ @ %@", [(CWIMAPStore *)theStore username], [(CWIMAPStore *)theStore name]]];
  [theStore close];
}


//
//
//
- (MailboxManagerCache *) cache
{
  return _cache;
}


//
//
//
- (void) panic: (NSData *) theData
	folder: (NSString *) theFolder
{
  CWLocalStore *aLocalStore;
  CWLocalFolder *aFolder;
  
  NSRunAlertPanel(_(@"Error!"),
		  _(@"An error occurred while trying to open the \"%@\" mailbox. This mailbox was probably\ndeleted and a filter is trying to save mails in it. Check your filters and the special mailboxes for all accounts.\nThe message has been saved in the \"Panic\" local mailbox."),
		  _(@"OK"),
		  NULL,
		  NULL,
		  theFolder);


  aLocalStore = [self storeForName: @"GNUMAIL_LOCAL_STORE"  username: NSUserName()]; 

  if (![[NSFileManager defaultManager] fileExistsAtPath: [[aLocalStore path] stringByAppendingPathComponent: @"Panic"]])
    {
      [aLocalStore createFolderWithName: @"Panic"  type: PantomimeFormatMbox  contents: nil];
    }

  aFolder = [aLocalStore folderForName: @"Panic"];

  [aFolder appendMessageFromRawSource: theData  flags: nil];
}


//
//
//
- (void) deleteSentMessageWithID: (NSString *) theID
{
  NSMutableDictionary *allMessages;
  NSString *aPath;

  aPath = [NSString stringWithFormat: @"%@/%@", GNUMailUserLibraryPath(), @"UnsentMessages"];
  
  NS_DURING
    {
      allMessages = [NSUnarchiver unarchiveObjectWithFile: aPath];

      if (allMessages)
	{
	  [allMessages removeObjectForKey: theID];
	  [NSArchiver archiveRootObject: allMessages  toFile: aPath];
	}
    }
  NS_HANDLER
    {

    }
  NS_ENDHANDLER;
}


//
//
//
- (void) restoreUnsentMessages
{
  NSMutableDictionary *allMessages;
  NSString *aPath;

  aPath = [NSString stringWithFormat: @"%@/%@", GNUMailUserLibraryPath(), @"UnsentMessages"];
  
  NS_DURING
    {
      allMessages = [NSUnarchiver unarchiveObjectWithFile: aPath];
      
      if (allMessages && [allMessages count])
	{
	  int choice;

	  choice = NSRunAlertPanel(_(@"Unsent messages..."),
				   _(@"There are unsent messages, would you like to\nrestore them?"),
				   _(@"Yes"), // default
				   _(@"No"),  // alternate
				   NULL );
	  
	  if (choice == NSAlertDefaultReturn)
	    {
	      EditWindowController *aController;
	      NSEnumerator *theEnumerator;
	      CWMessage *aMessage;
	      NSData *aData;

	      theEnumerator = [allMessages objectEnumerator];
	      
	      while ((aData = [theEnumerator nextObject]))
		{
		  aMessage = [[CWMessage alloc] initWithData: aData];
		  aController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
		  [aController setMode: GNUMailRestoreFromDrafts];
		  [aController setMessageFromDraftsFolder: aMessage];
		  [aController updateWithMessage: aMessage];
		  [aController showWindow: self];
		  RELEASE(aMessage);
		}
	    }

	  [allMessages removeAllObjects];
	  [NSArchiver archiveRootObject: allMessages  toFile: aPath];
	}
    }
  NS_HANDLER
    {
      NSDebugLog(@"Exception while restoring Unsent Messages");
    }
  NS_ENDHANDLER;
}

//
//
//
- (void) saveUnsentMessage: (NSData *) theMessage
		    withID: (NSString *) theID
{
  NSMutableDictionary *allMessages;
  NSString *aPath;

  aPath = [NSString stringWithFormat: @"%@/%@", GNUMailUserLibraryPath(), @"UnsentMessages"];
  
  NS_DURING
    {
      allMessages = [NSUnarchiver unarchiveObjectWithFile: aPath];
     
      if (!allMessages)
	{
	  allMessages = [NSMutableDictionary dictionary];
	}

      [allMessages setObject: theMessage  forKey: theID];
      [NSArchiver archiveRootObject: allMessages  toFile: aPath];
    }
  NS_HANDLER
    {
      NSLog(@"An exception occurred while saving the unsent message to %@", aPath);
    }
  NS_ENDHANDLER;
}


//
// This method appends a message to the folder specified in theURLName.
//
- (void) addMessage: (NSData *) theMessage
	   toFolder: (CWURLName *) theURLName
{
  NSString *aFolderName;
  CWFolder *aFolder;
  
  aFolder = [self folderForURLName: theURLName];
  aFolderName = [theURLName foldername];
  
  if (!aFolder)
    {
      [self panic: theMessage  folder: aFolderName];
    }

  [aFolder setProperty: [NSDate date]  forKey: FolderExpireDate];
  [self transferMessage: theMessage  flags: nil  folder: aFolder];
}


//
// 
//
- (CWMessage *) messageFromDraftsFolder
{
  id aMailWindowController;
  CWMessage *aMessage;
  
  aMailWindowController = [[GNUMail lastMailWindowOnTop] delegate];

  // We first verify if current folder is a Drafts folder.
  if (aMailWindowController && [aMailWindowController isKindOfClass: [MailWindowController class]])
    {
      if (![Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: 
							 [aMailWindowController folder]]
		      isEqualTo: @"DRAFTSFOLDERNAME"])
	{
	  return nil;
	}
    }
   
  if ([[aMailWindowController folder] countVisible] > 0 && [aMailWindowController selectedMessage])
    {
      aMessage = [aMailWindowController selectedMessage];
    }
  else
    {
      aMessage = nil;
    }

  return aMessage;
}


//
//
//
- (NSDictionary *) allStores
{
  return [NSDictionary dictionaryWithDictionary: allStores];
}

 
//
// This method is used under OS X since we must "swap" the current
// outline view in the Mailbox Manager to match the one currently
// on top in the NSDrawer. This is needed so -open: and other methods
// can work properly with the "current" outline view.
//
- (void) setCurrentOutlineView: (id) theOutlineView
{
  outlineView = theOutlineView;
}


//
//
//
- (void) updateFolderInformation: (NSDictionary *) theInformation
{
  CWFolderInformation *aFolderInformation;
  NSString *aFolderName;


  aFolderInformation = [theInformation objectForKey: @"FOLDER_INFORMATION"];
  aFolderName = [[theInformation objectForKey: @"FOLDER_NAME"] stringByReplacingOccurrencesOfCharacter: 
								 [[theInformation objectForKey: @"FOLDER_SEPARATOR"] characterAtIndex: 0]
							       withCharacter: '/'];

  [_cache setAllValuesForStoreName: [theInformation objectForKey: @"STORE_NAME"]
	  folderName: aFolderName 
	  username: [theInformation objectForKey: @"USERNAME"]
	  nbOfMessages: [aFolderInformation nbOfMessages]
	  nbOfUnreadMessages: [aFolderInformation nbOfUnreadMessages]];
  
  //
  // We now get the right outline view item to refresh. This is considerably faster
  // than calling -setNeedsDisplay: on the entire outline view (which will result
  // in a plethora of method calls to get the "right values").
  //
  [self updateOutlineViewForFolder: aFolderName
	store: [theInformation objectForKey: @"STORE_NAME"]
	username: [theInformation objectForKey: @"USERNAME"]
	controller: nil];
}



//
// This method is used to refresh ONLY the item associated with the Store/Folder.
//
- (void) updateOutlineViewForFolder: (NSString *) theFolder
			      store: (NSString *) theStore
			   username: (NSString *) theUsername
			 controller: (id) theController
{  
  if (theController)
    {
      [[theController folder] updateCache];
      [theController tableViewShouldReloadData];
      [theController updateStatusLabel];
    }
  else
    {
      FolderNode *aFolderNode, *aRootNode;
      NSInteger row;

      if ([theStore isEqualToString: @"GNUMAIL_LOCAL_STORE"])
	{
	  aRootNode = localNodes;
	}
      else
	{
	  aRootNode = [self storeFolderNodeForName: [Utilities accountNameForServerName: theStore  username: theUsername]];
	}
      
      aFolderNode = [Utilities folderNodeForPath: theFolder
			       using: aRootNode
			       separator: '/'];
      
      row = [outlineView rowForItem: aFolderNode];
      
      if (row >= 0 && row < [outlineView numberOfRows])
	{
	  [outlineView setNeedsDisplayInRect: [outlineView rectOfRow: row]];
	}
    }
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[MailboxManagerController alloc] init];
    }
  
  return singleInstance;
}


//
// Other methods
//
- (void) openFolderWithURLName: (CWURLName *) theURLName
			sender: (id) theSender
{
  if ([[theURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame)
    {
      [self _openLocalFolderWithName: [theURLName foldername]
	    sender: theSender];
    }
  else if ([[theURLName protocol] caseInsensitiveCompare: @"IMAP"] == NSOrderedSame)
    {
      if ([self _initializeIMAPStoreWithAccountName: [Utilities accountNameForServerName: [theURLName host]
								username: [theURLName username]]])
	{
	  [self _openIMAPFolderWithName: [theURLName foldername]
		store: (CWIMAPStore *)[self storeForName: [theURLName host]  username: [theURLName username]]
		sender: theSender];
	}
    }
}


//
//
//
- (void) reloadAllFolders
{
  DESTROY(localNodes);

  // We remove all our elements
  [_allFolders removeAllObjects];

  // We add our local folder, if we need to
  localNodes = [Utilities folderNodesFromFolders: [[self storeForName: @"GNUMAIL_LOCAL_STORE"
							 username: NSUserName()] folderEnumerator]
			  separator: '/'];

  [localNodes setName: _(@"Local")];
  [localNodes setParent: nil];

  if ([localNodes childCount] > 0)
    {
      [_allFolders addObject: localNodes];
    }

  RETAIN(localNodes);

  // We verify if the ACCOUNTS preferences have been defined.
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"])
    {
      NSMutableDictionary *allAccounts;
      NSDictionary *allValues;
      NSEnumerator *allKeys;
      CWIMAPStore *aStore;
      NSString *aKey;

      allAccounts = [[NSMutableDictionary alloc] init];
      [allAccounts addEntriesFromDictionary: [Utilities allEnabledAccounts]];
      
      allKeys = [[[allAccounts allKeys] sortedArrayUsingSelector: @selector(compare:)] objectEnumerator];
      
      // We build a correct subset of all our IMAP servers defined in all accounts
      while ((aKey = [allKeys nextObject]))
	{
	  allValues = [[allAccounts objectForKey: aKey] objectForKey: @"RECEIVE"];  
	  
	  // We add it only if it's an IMAP server AND if we receive mails either
	  // manually or automatically
	  if ([[allValues objectForKey: @"SERVERTYPE"] intValue] == IMAP &&
	      [[allValues objectForKey: @"RETRIEVEMETHOD"] intValue] != NEVER)
	    {
	      NSString *aServerName, *aUsername;
	      FolderNode *aFolderNode;
	      
	      aServerName = [allValues objectForKey: @"SERVERNAME"];
	      aUsername = [allValues objectForKey: @"USERNAME"];
	      
	      aFolderNode = [FolderNode folderNodeWithName: [NSString stringWithFormat: @"%@", aKey]
					parent: nil];
	      
	      [_allFolders addObject: aFolderNode];
	      
	      // If our IMAP Store has been previously initialized, we re-initialize it in order to get
	      // the most recent values for the {subscribed} folders
	      if ((aStore = [self storeForName: aServerName  username: aUsername]))
		{
		  NSNumber *aNumber;

		  aNumber = [allValues objectForKey: @"SHOW_WHICH_MAILBOXES"];
		  
		  if (aNumber && [aNumber intValue] == IMAP_SHOW_SUBSCRIBED_ONLY)
		    {
		      [self reloadFoldersForStore: aStore  folders: [aStore subscribedFolderEnumerator]];
		    }
		  else
		    {
		      [self reloadFoldersForStore: aStore  folders: [aStore folderEnumerator]];
		    }
		}
	    }
	}
      
      RELEASE(allAccounts);
    }
 
  [outlineView abortEditing];

  // We inform our outline view to reload its data.
  [outlineView reloadData];

  // We always expand our root item
  [outlineView expandItem: _allFolders];
  
  // We now select and expand the 'Local' folder if there's no IMAP folders defined
  if ([_allFolders count] == 1 && [_allFolders lastObject] == localNodes)
    {
      [outlineView expandItem: localNodes];
      [outlineView selectRow: [outlineView rowForItem: localNodes]
  		   byExtendingSelection: NO];
   }
}


//
//
//
- (void) transferMessage: (NSData *) theMessage
		   flags: (CWFlags *) theFlags
		  folder: (CWFolder *) theFolder
{
  CWFlags *flags;

  //
  // We transfer the message. If we are transferring to a Sent folder, mark it as read.
  //
  flags = theFlags;

  if ([Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: theFolder]  
		 isEqualTo: @"SENTFOLDERNAME"])
    {
      flags = [[CWFlags alloc] initWithFlags: PantomimeSeen];
      AUTORELEASE(flags);
    }

  //
  // For IMAP mailboxes, we show some kind of progress indicators
  // when performing lengthy operations.
  //
  if ([theFolder isKindOfClass: [CWIMAPFolder class]])
    {
      Task *aTask;
      
      aTask = [[TaskManager singleInstance] taskForService: [theFolder store]];

      if (aTask)
	{
	  aTask->total_count++;
	  aTask->total_size += (float)[theMessage length]/(float)1024;
	}
      else
	{
	  aTask = [[Task alloc] init];
	  aTask->op = SAVE_ASYNC;
	  [aTask setKey: [Utilities accountNameForFolder: theFolder]];
	  [aTask setMessage: theMessage];
	  aTask->total_size = (float)[theMessage length]/(float)1024;
	  aTask->immediate = YES;
	  aTask->service = [theFolder store];
	  [[TaskManager singleInstance] addTask: aTask];
	  RELEASE(aTask);
	}
    }

  [theFolder appendMessageFromRawSource: theMessage  flags: flags];
}


//
// theOperation == COPY / MOVE
// returns the numbers of transferred messages, -1 on error.
//
- (void) transferMessages: (NSArray *) theMessages
		fromStore: (id) theSourceStore
	       fromFolder: (id) theSourceFolder
		  toStore: (id) theDestinationStore
		 toFolder: (id) theDestinationFolder
		operation: (int) theOperation
{
  if (!theMessages || [theMessages count] == 0 || !theSourceFolder || !theDestinationFolder )
    {
      NSBeep();
    }
  
  //
  // If we are transferring messages from an IMAPFolder to an IMAPFolder on the SAME
  // IMAPStore, let's use Pantomime's IMAPFolder: -copyMessage: toFolder: method
  // since the operation is gonna be server-side - so MUCH FASTER.
  //
  if ([theSourceStore isKindOfClass: [CWIMAPStore class]] && theSourceStore == theDestinationStore)
    { 
      [theSourceFolder copyMessages: theMessages
		       toFolder: [[(CWIMAPFolder *)theDestinationFolder name] 
				   stringByReplacingOccurrencesOfCharacter: '/'
				   withCharacter: [theDestinationStore folderSeparator]]];
      
      // If we are moving the messages, mark them as deleted.
      if (theOperation == MOVE_MESSAGES)
	{
	  CWMessage *aMessage;
	  CWFlags *theFlags;
	  int i, count;
	  
	  count = [theMessages count];
	  for (i = 0; i < count; i++)
	    {
	      aMessage = [theMessages objectAtIndex: i];
	      theFlags = [[aMessage flags] copy];	      
	      [theFlags add: PantomimeDeleted];
	      [aMessage setFlags: theFlags];
	      RELEASE(theFlags);
	    }
	}
    }
  //
  // We are NOT doing an IMAP-to-IMAP (on the same IMAPStore) copy.
  // Let's grab the message's data and use it. If it's not available,
  // we load it asynchronously and create a corresponding task
  // in the TaskManager for showing progress of the operation.
  // 
  else
    {
      NSMutableArray *messagesToLoad;
      NSAutoreleasePool *pool;
      CWMessage *aMessage;
      NSData *aData;
      Task *aTask;
      NSUInteger i;
	
      messagesToLoad = [NSMutableArray array];

      aTask = [[Task alloc] init];
      aTask->op = LOAD_ASYNC;
      aTask->immediate = YES;
      aTask->service = [theSourceFolder store];
      [aTask setKey: [Utilities accountNameForFolder: theSourceFolder]];

      for (i = 0; i < [theMessages count]; i++)
	{
	  pool = [[NSAutoreleasePool alloc] init];
	  
	  aMessage = [theMessages objectAtIndex: i];
	  [aMessage setProperty: [NSNumber numberWithInt: theOperation]  forKey: MessageOperation];
	  aData = [aMessage rawSource];
	  
	  if (aData)
	    {
	      CWFlags *theFlags;
	      
	      // We get our flags but we remove the PantomimeDeleted flag from them
	      theFlags = [[aMessage flags] copy];
	      [theFlags remove: PantomimeDeleted];
	      
	      [[TaskManager singleInstance] setMessage: aMessage  forHash: [aData hash]];
	      [self transferMessage: aData
		    flags: AUTORELEASE([theFlags copy])
		    folder: theDestinationFolder];
	      RELEASE(theFlags);
	    }
	  else
	    {
	      // The raw source is NOT available right now. We write the properties
	      // so we know we must transfer it once it's loaded.
	      [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageLoading];
	      [aMessage setProperty: theDestinationStore  forKey: MessageDestinationStore];
	      [aMessage setProperty: theDestinationFolder  forKey: MessageDestinationFolder];
	      [messagesToLoad addObject: aMessage];
	      aTask->total_size += (float)[aMessage size]/(float)1024;
	    }
	  
	  RELEASE(pool);
	}

      if ([messagesToLoad count])
	{
	  [aTask setMessage: messagesToLoad];
	  aTask->total_count = [messagesToLoad count];
	  [[TaskManager singleInstance] addTask: aTask];
	}

      RELEASE(aTask);
    }
}


//
//
//
- (void) reloadFoldersForStore: (id) theStore
		       folders: (NSEnumerator *) theFolders
{
  NSMutableDictionary *allAccounts, *allValues, *theAccount;
  FolderNode *aFolderNode, *nodes;
  NSString *theAccountName;
  NSArray *allFolders;

  aFolderNode = [self storeFolderNodeForName: [Utilities accountNameForServerName: [(CWService *)theStore name]
							  username: [theStore username]]];

  allFolders = [NSArray arrayWithArray: [theFolders allObjects]];
  nodes = [Utilities folderNodesFromFolders: [allFolders objectEnumerator]
		     separator: [theStore folderSeparator]];
  RETAIN(nodes);
  [aFolderNode setChildren: [nodes children]];
  RELEASE(nodes);

#warning optimize by reloading only the item
  [outlineView reloadData];
  [outlineView expandItem: aFolderNode];

  //
  // We finally cache all/subscribed folders in the user's defaults for this account
  //
  theAccountName = [Utilities accountNameForServerName: [(CWIMAPStore *)theStore name]  username: [theStore username]];
  allAccounts = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] 
								   objectForKey: @"ACCOUNTS"]];
  theAccount = [[NSMutableDictionary alloc] initWithDictionary: [allAccounts objectForKey: theAccountName]];
  allValues = [[NSMutableDictionary alloc] initWithDictionary: [theAccount objectForKey: @"RECEIVE"]];
  
  //
  // We write back the information
  //
  [allValues setObject: allFolders  forKey: @"SUBSCRIBED_FOLDERS"];
  [theAccount setObject: allValues  forKey: @"RECEIVE"];
  [allAccounts setObject: theAccount  forKey: theAccountName];
  [[NSUserDefaults standardUserDefaults] setObject: allAccounts  forKey: @"ACCOUNTS"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  RELEASE(allValues);
  RELEASE(theAccount);
  RELEASE(allAccounts);
}


//
//
//
- (FolderNode *) storeFolderNodeForName: (NSString *) theName
{
  NSUInteger i, count;

  count = [_allFolders count];
  
  for (i = 0; i < count; i++)
    {
      FolderNode *aFolderNode;
      
      aFolderNode = [_allFolders objectAtIndex: i];
      
      if ([theName isEqualToString: [aFolderNode name]])
	{
	  return aFolderNode;
	}
    }

  return nil;
}


//
//
//
- (void) saveMessageInDraftsFolderForController: (EditWindowController *) theEditWindowController
{  
  NSString *theAccountName, *aString;
  CWURLName *theURLName;
  
  //
  // We first update the current message content with the current
  // content of the view and we synchronize our popup button.
  //
  [theEditWindowController updateMessageContentFromTextView];
  [[theEditWindowController accountPopUpButton] synchronizeTitleAndSelectedItem];

  theAccountName = [(ExtendedMenuItem *)[[theEditWindowController accountPopUpButton] selectedItem] key];

  // We get the value of the Drafts folder in the user defaults. If the Drafts folder isn't set
  // for this particular account, we are the user about this and return immediately.
  aString = [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: theAccountName] 
	       objectForKey: @"MAILBOXES"] objectForKey: @"DRAFTSFOLDERNAME"];
  
  if (!aString)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"The Drafts mailbox is not set for the %@ account.\nPlease set it from the mailboxes list using\nthe contextual menu."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      theAccountName);
      return;
    }
  
  theURLName = [[CWURLName alloc] initWithString: aString
				  path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
  
  [self addMessage: [[theEditWindowController message] dataValue]  toFolder: theURLName];
  
  // If this message is already in the Drafts folder, set the "deleted" flag 
  // of the original message.
  if ([theEditWindowController mode] == GNUMailRestoreFromDrafts)
    {
      CWFlags *theFlags;
      
      theFlags = [[[theEditWindowController message] flags] copy];
      [theFlags add: PantomimeDeleted];
      [[theEditWindowController message] setFlags: theFlags];
      RELEASE(theFlags);
      
      [[NSNotificationCenter defaultCenter] postNotificationName: ReloadMessageList
					    object: nil
					    userInfo: nil];
  }
  
  // We mark the window's document as non-edited
  [[theEditWindowController window] setDocumentEdited: NO];

  RELEASE(theURLName);
}

@end


//
// Private methods
//
@implementation MailboxManagerController (Private)

- (void) _accountsHaveChanged: (id) sender
{
  NSEnumerator *theEnumerator;
  NSArray *allAccounts;
  id aStore;

  [self _updateContextMenu];
  [self reloadAllFolders];

  allAccounts = [[Utilities allEnabledAccounts] allKeys];
  theEnumerator = [allStores objectEnumerator];

  while ((aStore = [theEnumerator nextObject]))
    {
      if ([aStore isKindOfClass: [CWIMAPStore class]] &&
	  ![allAccounts containsObject: [Utilities accountNameForServerName: [(CWIMAPStore *)aStore name]  username: [(CWIMAPStore *)aStore username]]])
	{
	  [self closeWindowsForStore: aStore];
	}
    }
}


//
//
//
- (BOOL) _deletingDefaultMailbox: (NSString **) theMailboxName
	    usingURLNameAsString: (NSString *) theURLNameAsString
{
  if ([Utilities stringValueOfURLName: theURLNameAsString  isEqualTo: @"INBOXFOLDERNAME"])
    {
      *theMailboxName = _(@"Inbox");
      return YES;
    }
  else if ([Utilities stringValueOfURLName: theURLNameAsString  isEqualTo: @"SENTFOLDERNAME"])
    {
      *theMailboxName = _(@"Sent");
      return YES;
    }
  else if ([Utilities stringValueOfURLName: theURLNameAsString  isEqualTo: @"DRAFTSFOLDERNAME"])
    {
      *theMailboxName = _(@"Drafts");
      return YES;
    }
  else if ([Utilities stringValueOfURLName: theURLNameAsString  isEqualTo: @"TRASHFOLDERNAME"])
    {
      *theMailboxName = _(@"Trash");
      return YES;
    }
  
  return NO;
}


//
//
//
- (void) _folderCreateCompleted: (NSNotification *) theNotification
{
  NSString *aString, *aStoreName, *aUsername;
  id o;

  // We get the account in order to verify if we must subscribe to the IMAP mailbox
  o = [theNotification object];
  
  aStoreName = @"GNUMAIL_LOCAL_STORE";
  aUsername = NSUserName();

  if ([o isKindOfClass: [CWIMAPStore class]])
    {
      aStoreName = [(CWIMAPStore *)o name];
      aUsername = [o username];

      aString = [Utilities accountNameForServerName: aStoreName  username: aUsername];
      
      if ([[[[[Utilities allEnabledAccounts] objectForKey: aString] objectForKey: @"RECEIVE"]
	     objectForKey: @"SHOW_WHICH_MAILBOXES"] intValue] == IMAP_SHOW_SUBSCRIBED_ONLY)
	{
	  [o subscribeToFolderWithName: [[theNotification userInfo] objectForKey: @"Name"]];
	  return;
	}
    }

  // We update the cache in case we imported messages when creating the mailbox.
  [_cache setAllValuesForStoreName: aStoreName
	  folderName: [[theNotification userInfo] objectForKey: @"Name"]
	  username: aUsername
	  nbOfMessages: ([[theNotification userInfo] objectForKey: @"Count"] ? [[[theNotification userInfo] objectForKey: @"Count"] unsignedIntValue] : 0)
	  nbOfUnreadMessages: 0]; 
  
  [self _folderSubscribeCompleted: theNotification];
}


//
//
//
- (void) _folderCreateFailed: (NSNotification *) theNotification
{
  NSRunInformationalAlertPanel(_(@"Mailbox error!"),
			       _(@"An error occurred while creating the %@ mailbox. This mailbox probably already exists\nor you don't have permission to create it."),
			       _(@"OK"),
			       NULL, 
			       NULL,
			       [[theNotification userInfo] objectForKey: @"Name"]);
}


//
//
//
- (void) _folderDeleteCompleted: (NSNotification *) theNotification
{
  NSString *aStoreName, *aUsername;
  id aStore, item;

  aStoreName = @"GNUMAIL_LOCAL_STORE";
  aUsername = NSUserName();
  aStore = [theNotification object];

#warning FIXME get the right item in case the selection has changed
  item = [outlineView itemAtRow: [outlineView selectedRow]];  

  // Delete cache files, ONLY if this is an IMAP folder!
  if ([aStore isKindOfClass: [CWIMAPStore class]] )
    {
      NSString *aKey, *cacheFilePath;
      FolderNode *node;
      NSUInteger i;
      
      aStoreName = [(CWIMAPStore *)aStore name];
      aUsername = [(CWIMAPStore *)aStore username];

      aKey = [NSString stringWithFormat: @"%@ @ %@", aUsername, aStoreName];
      
      cacheFilePath = [NSString stringWithFormat: @"%@/IMAPCache_%@_%@", 
				GNUMailUserLibraryPath(),
				[Utilities flattenPathFromString: aKey
					   separator: '/'],
				[Utilities flattenPathFromString: 
					     [Utilities pathOfFolderFromFolderNode: (FolderNode *)item
							separator: [(id<CWStore>)aStore folderSeparator]]
					   separator: '/']];
      
      // We remove the file
      NS_DURING
	[[NSFileManager defaultManager] removeFileAtPath: cacheFilePath
					handler: nil];
      NS_HANDLER
	// Under GNUstep, if we pass something that can't be converted to a cString
	// to -removeFileAtPath, it throws an exception.
	NSDebugLog(@"Exception occurred while removing the cache file.");
      NS_ENDHANDLER;
      
      // We remove the cache file of the children of this folder, if any.
      for (i = 0; i < [(FolderNode *)item childCount]; i++)
	{
	  node = [(FolderNode *)item childAtIndex: i];
	  cacheFilePath = [NSString stringWithFormat: @"%@/IMAPCache_%@_%@", 
				    GNUMailUserLibraryPath(),
				    [Utilities flattenPathFromString: aKey
					       separator: '/'],
				    [Utilities flattenPathFromString: 
						 [Utilities pathOfFolderFromFolderNode: node
							    separator: [(id<CWStore>)aStore folderSeparator]]
					       separator: '/']];
	  
	  NS_DURING
	    [[NSFileManager defaultManager] removeFileAtPath: cacheFilePath
					    handler: nil];
	  NS_HANDLER
	    // Under GNUstep, if we pass something that can't be converted to a cString
	    // to -removeFileAtPath, it throws an exception.
	    NSDebugLog(@"Exception occurred while removing the cache file.");
	  NS_ENDHANDLER;
	}

      // We get the account in order to verify if we must unsubscribe to the IMAP mailbox
      aKey = [Utilities accountNameForServerName: aStoreName  username: aUsername];
      
      if ([[[[[Utilities allEnabledAccounts] objectForKey: aKey] objectForKey: @"RECEIVE"]
	     objectForKey: @"SHOW_WHICH_MAILBOXES"] intValue] == IMAP_SHOW_SUBSCRIBED_ONLY)
	{
	  [aStore unsubscribeToFolderWithName: [[theNotification userInfo] objectForKey: @"Name"]];
	  return;
	}
    }

  // We delete our cache entries
  [_cache removeAllValuesForStoreName: aStoreName
	  folderName: [Utilities pathOfFolderFromFolderNode: (FolderNode *)item  separator: '/']
	  username: aUsername];
  
  [self _reloadFoldersAndExpandParentsFromNode: [item parent]
	selectNodeWithPath: [Utilities completePathForFolderNode: [item parent]
				       separator: '/']];
}


//
//
//
- (void) _folderDeleteFailed: (NSNotification *) theNotification
{
  NSRunInformationalAlertPanel(_(@"Mailbox error!"),
			       _(@"An error occurred while deleting the %@ mailbox. This mailbox is probably already deleted\nor the server does not support deleting open mailboxes."),
			       _(@"OK"),
			       NULL, 
			       NULL,
			       [[theNotification userInfo] objectForKey: @"Name"]);
}


//
//
//
- (void) _folderRenameCompleted: (NSNotification *) theNotification
{
  NSString *aSourceURL, *aDestinationURL, *aString, *aName, *aNewName;
  id aWindow, aStore;
  
  aStore = [theNotification object];
  aName = [[theNotification userInfo] objectForKey: @"Name"];
  aNewName = [[theNotification userInfo] objectForKey: @"NewName"];

  // We build our right URLs
  if ( [(id<NSObject>)aStore isKindOfClass: [CWLocalStore class]] )
    {
      aSourceURL = [NSString stringWithFormat: @"local://%@/%@",
			     [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
			     aName];
      aDestinationURL = [NSString stringWithFormat: @"local://%@/%@",
				  [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
				  aNewName];
    }
  else
    {
      aSourceURL = [NSString stringWithFormat: @"imap://%@@%@/%@", 
			     [(CWIMAPStore *)aStore username], 
			     [(CWIMAPStore *)aStore name],
			     aName];
      aDestinationURL = [NSString stringWithFormat: @"imap://%@@%@/%@", 
				  [(CWIMAPStore *)aStore username], 
				  [(CWIMAPStore *)aStore name], 
				  aNewName];
    }
  
  // We update our filters.
  [[FilterManager singleInstance] updateFiltersFromOldPath: aSourceURL  toPath: aDestinationURL];
  
  // We update our "MAILBOXES" for all accounts
  [self _updateMailboxesFromOldPath: aSourceURL  toPath: aDestinationURL];
  
  
  //
  // Then, we must verify if we must rename our IMAP cache file.
  //
  if ([(id<NSObject>)aStore isKindOfClass: [CWIMAPStore class]])
    {
      NSString *aKey, *aSourcePath, *aDestinationPath;
      
      // FIXME - buggy? IMAPStore must be updated to update the pathToCache ivar in IMAPCacheManager
      // for an open IMAPFolder.
      aKey = [NSString stringWithFormat: @"%@ @ %@", 
		       [(CWIMAPStore *)aStore username], 
		       [(CWIMAPStore *)aStore name]];
      
      aSourcePath = [NSString stringWithFormat: @"%@/IMAPCache_%@_%@",
			      GNUMailUserLibraryPath(),
			      [Utilities flattenPathFromString: aKey
					 separator: '/'],
			      [Utilities flattenPathFromString: aName
					 separator: [(id<CWStore>)aStore folderSeparator]] ];
      
      aDestinationPath = [NSString stringWithFormat: @"%@/IMAPCache_%@_%@", 
				   GNUMailUserLibraryPath(),
				   [Utilities flattenPathFromString: aKey
					      separator: '/'],
				   [Utilities flattenPathFromString: aNewName
					      separator: [(id<CWStore>)aStore folderSeparator]] ];
      
      [[NSFileManager defaultManager] movePath: aSourcePath
				      toPath: aDestinationPath
				      handler: nil];
      
    }
  
  // Success! Let's refresh our MM. The _reloadFoldersAndExpandParentsFromNode::
  // method expects to have the store name before the node's path.
  if ( [(id<NSObject>)aStore isKindOfClass: [CWLocalStore class]] )
    {
      aString = [NSString stringWithFormat: @"/%@/%@", _(@"Local"), aNewName];
    }
  else
    {
      aString = [NSString stringWithFormat: @"/%@/%@",
			  [Utilities accountNameForServerName: [(CWIMAPStore *)aStore name]  username: [(CWIMAPStore *)aStore username]],
			  aNewName];
    }
  
  [self _reloadFoldersAndExpandParentsFromNode: [[outlineView itemAtRow: [outlineView selectedRow]] parent]
	selectNodeWithPath: aString];
  
  // We also refresh our window's title
  aWindow = [Utilities windowForFolderName: aNewName  store: aStore];

  if (aWindow)
    {
      [[aWindow windowController] updateWindowTitle];
    }
}


//
//
//
- (void) _folderRenameFailed: (NSNotification *) theNotification
{
  NSRunInformationalAlertPanel(_(@"Mailbox error!"),
			       _(@"An error occurred while renaming the %@ mailbox to %@. This mailbox probably already exists\nor you don't have permission to rename it."),
			       _(@"OK"),
			       NULL, 
			       NULL,
			       [[theNotification userInfo] objectForKey: @"Name"],
			       [[theNotification userInfo] objectForKey: @"NewName"]);
}


//
//
//
- (void) _folderSubscribeCompleted: (NSNotification *) theNotification
{
  NSString *aString;
  id item;
  NSInteger row;

#warning FIXME get the right item in case the selection has changed
  row = [outlineView selectedRow];

  if (row < 0) return;
  item = [outlineView itemAtRow: row];
  
  aString = [NSString stringWithFormat: @"%@/%@", [Utilities completePathForFolderNode: item  separator: '/'],
		      [[theNotification userInfo] objectForKey: @"Name"]];
  
  [self _reloadFoldersAndExpandParentsFromNode: item  selectNodeWithPath: aString];
}


//
//
//
- (void) _folderUnsubscribeCompleted: (NSNotification *) theNotification
{
  NSString *aString;
  id item;
  NSInteger row;

#warning FIXME get the right item in case the selection has changed
  row = [outlineView selectedRow];

  if (row < 0) return;
  item = [outlineView itemAtRow: row];
  
  aString = [NSString stringWithFormat: @"%@/%@", [Utilities completePathForFolderNode: item  separator: '/'],
		      [[theNotification userInfo] objectForKey: @"Name"]];
  
  [self _reloadFoldersAndExpandParentsFromNode: item
	selectNodeWithPath: aString];
}


//
//
//
- (BOOL) _initializeIMAPStoreWithAccountName: (NSString *) theAccountName
{
  NSString *aServerName, *aUsername;
  NSDictionary *allValues;
  CWIMAPStore *aStore;
  NSNumber *portValue;   
  Task *aTask;

  // We begin by searching in our ACCOUNTS values for the right account.
  // Now, let's get all the receive values
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: theAccountName] objectForKey: @"RECEIVE"];
  
  portValue =  [allValues objectForKey: @"PORT"];
	  
  // We use the default IMAP port if it's not defined.
  if (!portValue)
    {
      portValue = [NSNumber numberWithInt: 143];
    }
  
  // We get our username
  aUsername = [allValues objectForKey: @"USERNAME"];

  // We get our servername
  aServerName = [allValues objectForKey: @"SERVERNAME"];
  
  // We first verify if we haven't already cached our store. If so,
  // we simply return since the Store has already been initialized.
  if ([self storeForName: aServerName  username: aUsername])
    {
      return YES;
    }

  aStore = [[CWIMAPStore alloc] initWithName: aServerName
				port: [portValue intValue]];
  [aStore addRunLoopMode: NSEventTrackingRunLoopMode];
  [aStore addRunLoopMode: NSModalPanelRunLoopMode];
  [aStore setUsername: [allValues objectForKey: @"USERNAME"]]; 
  [aStore setDelegate: [TaskManager singleInstance]];  
  
  [self setStore: aStore  name: aServerName  username: aUsername];
  
  aTask = [[Task alloc] init];
  aTask->op = CONNECT_ASYNC;
  [aTask setKey: theAccountName];
  aTask->immediate = YES;
  aTask->service = aStore;
  [[TaskManager singleInstance] addTask: aTask];
  RELEASE(aTask);

  [aStore connectInBackgroundAndNotify];
  
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailFloatingView &&
      [[self window] isVisible])
    {
      [[self window] makeKeyAndOrderFront: self];
    }

  return YES;
}


//
//
//
- (void) _nbOfMessages: (NSUInteger *) theNbOfMessages
    nbOfUnreadMessages: (NSUInteger *) theNbOfUnreadMessages
               forItem: (id) theItem
{
  NSString *aString, *aStoreName, *aFolderName, *aUsername;
  
  aString = [Utilities completePathForFolderNode: theItem
		       separator: '/'];
  
  if ([aString hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]])
    {
      aStoreName = @"GNUMAIL_LOCAL_STORE";
      aFolderName = [Utilities pathOfFolderFromFolderNode: (FolderNode *)theItem
			       separator: '/'];
      aUsername = NSUserName();
    }
  else
    {
      [Utilities storeKeyForFolderNode: theItem
		 serverName: &aStoreName
		 username: &aUsername];
      
      aFolderName = [Utilities pathOfFolderFromFolderNode: (FolderNode *)theItem
			       separator: '/'];
    }
  
  [_cache allValuesForStoreName: aStoreName
	  folderName: aFolderName
	  username: aUsername
	  nbOfMessages: theNbOfMessages
	  nbOfUnreadMessages: theNbOfUnreadMessages];
}

//
// Called when the user presses Tab in the mailbox window
//
- (void) _switchWindows:(id)sender
{
  [[GNUMail lastMailWindowOnTop] makeKeyAndOrderFront:self];
}

//
//
//
- (void) _openLocalFolderWithName: (NSString *) theFolderName
			   sender: (id) theSender
{
  MailWindowController *aMailWindowController;
  CWLocalStore *localStore;
  CWLocalFolder *aFolder;
  
  BOOL reusingLastMailWindowOnTop, aMask;
  
  // We get out local store and our folder.
  localStore = [self storeForName: @"GNUMAIL_LOCAL_STORE"  username: NSUserName()];
  aFolder = nil;
  
  // We first verify if the folder is still valid. For example, it could have been
  // deleted (the file) manually while GNUMail was running.
  if (![[NSFileManager defaultManager] fileExistsAtPath: [[localStore path] stringByAppendingPathComponent: theFolderName]])
    {
      NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				   _(@"The local mailbox %@ does not exist!"),
				   _(@"OK"),
				   NULL, 
				   NULL,
				   theFolderName);
      return;
    }

  // We now verify if it's not a directory (a folder holding folders)
  if (([localStore folderTypeForFolderName: theFolderName] & PantomimeHoldsFolders) == PantomimeHoldsFolders)
    {
#warning remove that code or fix it
#if 0
      FolderNode *item;
      NSInteger i;

      item = [outlineView itemAtRow: [outlineView selectedRow]];
      
      aFolder = AUTORELEASE([[CWVirtualFolder alloc] initWithName: theFolderName]);
      
      // We add all direct sub-mailboxes
      for (i = 0; i < [item childCount]; i++)
	{
	  id o;

	  o = [localStore folderForName: [Utilities pathOfFolderFromFolderNode: [item childAtIndex: i]  separator: '/']];
	  [o parse: NO];
	  [aFolder addFolder: o];
	}
#else
      NSBeep();
      return;
#endif
    }

  // If the folder is already open, we "focus" that window
  if ([localStore folderForNameIsOpen: theFolderName])
    {
      NSWindow *aWindow;
      
      aWindow = (NSWindow *)[Utilities windowForFolderName: theFolderName 
				       store: (id<CWStore>)localStore];
      if (aWindow)
	{
	  [aWindow orderFrontRegardless];
	  return;
	}
    }
  
  // We must open (or get an open folder) the folder.
  if (!aFolder)
    {
      aFolder = [localStore folderForName: theFolderName];
    }

  if (!aFolder)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"Unable to open local mailbox %@."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      theFolderName);
      return;
    }
  
#ifdef MACOSX
  aMask = ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask;
#else
  aMask = ([[NSApp currentEvent] modifierFlags] & NSControlKeyMask) == NSControlKeyMask;
#endif

  // If we reuse our window controller...
  if ([theSender isKindOfClass: [NSMenuItem class]] || 
      [GNUMail lastMailWindowOnTop] == nil || 
       theSender == [NSApp delegate] ||
      aMask)
    {
      aMailWindowController = [[MailWindowController alloc] initWithWindowNibName: @"MailWindow"];
      reusingLastMailWindowOnTop = NO;
    }
  else
    {      
      aMailWindowController = [[GNUMail lastMailWindowOnTop] windowController];
      reusingLastMailWindowOnTop = YES;
      
      // We must NOT assume that we got a MailWindowController
      if ([aMailWindowController isKindOfClass: [MessageViewWindowController class]])
	{
	  aMailWindowController = [(MessageViewWindowController *)aMailWindowController mailWindowController];
	}
      
      // We close the previous folder.
      [[aMailWindowController folder] close];
    }
  
  // We set the new folder
  [aMailWindowController setFolder: aFolder];

  // We we are reusing our window controller, we must always reload the table view
  if (reusingLastMailWindowOnTop && [GNUMail lastMailWindowOnTop])
    {
      [aMailWindowController tableViewShouldReloadData];
    }

  // And we show the window..
  [[aMailWindowController window] orderFrontRegardless];
  [[aMailWindowController window] makeKeyAndOrderFront: nil];

  ADD_CONSOLE_MESSAGE(_(@"Local folder %@ opened."), theFolderName);

  // We must restore the image here... it's important if we switch from
  // an IMAP mailbox (over SSL) to a local mailbox (to hide the secure icon)
  [[ConsoleWindowController singleInstance] restoreImage];
  
  // If the "Local" node was collapsed in our MailboxManager, we now expend it
  if (![outlineView isItemExpanded: [self storeFolderNodeForName: _(@"Local")]])
    {
      [outlineView expandItem: [self storeFolderNodeForName: _(@"Local")]];
    }
}


//
//
//
- (void) _openIMAPFolderWithName: (NSString *) theFolderName
			   store: (CWIMAPStore *) theStore
			  sender: (id) theSender
{
  MailWindowController *aMailWindowController;
  CWIMAPCacheManager *anIMAPCacheManager;
  CWIMAPFolder *aFolder;
  NSString *aKey;
  Task *aTask;
  
  BOOL reusingLastMailWindowOnTop, aMask;

#ifdef MACOSX
  aMask = ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask;
#else
  aMask = ([[NSApp currentEvent] modifierFlags] & NSControlKeyMask) == NSControlKeyMask;
#endif

  // Using IMAP, we currently only allow the user to have one folder open
  // at the time on the same CWIMAPStore.
  if ([[[theStore openFoldersEnumerator] allObjects] count] > 0)
    {
      id aWindow;

      // We search for one open window (so folder) on the IMAP store
      aWindow = [Utilities windowForFolderName: nil  store: (id<CWStore>)theStore];

      // If the folder that the window is 'using' is the same as the one we are trying to open,
      // we simply make this window the key one and order it front. There's no need to try
      // to reopen that folder!
      if ( [[[[aWindow windowController] folder] name] isEqualToString: theFolderName] )
	{
	  [aWindow makeKeyAndOrderFront: self];
	  return;
	}

      // If we are trying to open a new MailWindow using the menu item or if we are reusing
      // a MailWindow but the current on top isn't a window 'using' our IMAP store...
      if ([theSender isKindOfClass: [NSMenuItem class]] ||
	  aMask ||
	  ([[GNUMail allMailWindows] count] > 1 && [GNUMail lastMailWindowOnTop] != aWindow))
	{
	  NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				       _(@"A mailbox (%@) is already open. Please close it first."),
				       _(@"OK"),
				       NULL, 
				       NULL,
				       [(CWIMAPFolder *)[[theStore openFoldersEnumerator] nextObject] name]);
	  return;
	}
    }
  

  //
  // We verify if we must reuse or not our window controller. The first if () is to
  // verify if we must NOT reuse it.
  //
  if ([theSender isKindOfClass: [NSMenuItem class]] || 
      [GNUMail lastMailWindowOnTop] == nil || 
      theSender == [NSApp delegate] ||
      aMask)
    {
      aMailWindowController = [[MailWindowController alloc] initWithWindowNibName: @"MailWindow"];
      reusingLastMailWindowOnTop = NO;
    }
  else
    {
      aMailWindowController = [[GNUMail lastMailWindowOnTop] windowController];
      reusingLastMailWindowOnTop = YES;
      
      // We must NOT assume that we got a MailWindowController
      if ([aMailWindowController isKindOfClass: [MessageViewWindowController class]])
	{
	  aMailWindowController = [(MessageViewWindowController *)aMailWindowController mailWindowController];
	}
      
      // We close the previous folder. No need to handle the IMAP timeout
      // as it's handled in IMAPFolder: -close.
      [[aMailWindowController folder] close];
    }

  // We send our message to the console saying we are about to open the IMAP folder
  ADD_CONSOLE_MESSAGE(_(@"Opening IMAP folder %@ on %@..."), theFolderName, [theStore name]);
  

  //
  // We obtain our folder from the IMAP store.
  //
  aFolder = (CWIMAPFolder *)[theStore folderForName: theFolderName
				      mode: PantomimeReadWriteMode
				      prefetch: NO];

  // We verify if the folder can be open. It could have been a \NoSelect folder.
  if (!aFolder)
    {
      NSRunInformationalAlertPanel(_(@"Mailbox error!"),
				   _(@"You must select a valid mailbox to open!"),
				   _(@"OK"),
				   NULL,
				   NULL,
				   NULL);
      return;
    }

  //
  // We verify if we haven't got a non-selectable folder.
  //
#warning what happens it we are DnD to this folder?
#if 0
  if (![aFolder selected])
    {
      [aFolder close];

      aFolder = (CWIMAPFolder *)[theStore folderForName: theFolderName
					  mode: PantomimeReadWriteMode
					  prefetch: NO];
    }
#endif

  // We get our cache manager for this server / folder
  aKey = [NSString stringWithFormat: @"%@ @ %@", [theStore username], [theStore name]];
  anIMAPCacheManager = [[CWIMAPCacheManager alloc] initWithPath: [NSString stringWithFormat: @"%@/IMAPCache_%@_%@",
									   GNUMailUserLibraryPath(),
									   [Utilities flattenPathFromString: aKey
										      separator: '/'],
									   [Utilities flattenPathFromString: theFolderName
										      separator: [theStore folderSeparator]]]
						   folder: aFolder];
  AUTORELEASE(anIMAPCacheManager);

  // We set the cache manager and we prefetch our messages
  [aFolder setCacheManager: anIMAPCacheManager];

  [(CWIMAPCacheManager *)[aFolder cacheManager] readAllMessages];
  
  // We set the folder
  [aMailWindowController setFolder: aFolder];

  aTask = [[Task alloc] init];
  aTask->op = OPEN_ASYNC;
  [aTask setKey: [Utilities accountNameForFolder: aFolder]];
  aTask->immediate = YES;
  aTask->service = [aFolder store];
  [[TaskManager singleInstance] addTask: aTask];
  RELEASE(aTask);
  
#if 1
#warning do not clear the view but handle when the user click on a message of a closed folder
  // We are reusing our window controller, we must always reload the table view
  if ( reusingLastMailWindowOnTop && [GNUMail lastMailWindowOnTop] )
    {
      [aMailWindowController tableViewShouldReloadData];
    }
#endif

  [[aMailWindowController window] orderFrontRegardless];
  [[aMailWindowController window] makeKeyAndOrderFront: nil];

  ADD_CONSOLE_MESSAGE(_(@"IMAP folder %@ on %@ opened."), theFolderName, [theStore name]);

  // If the "IMAP" node was collapsed in our MailboxManager, we now expand it
  if (![outlineView isItemExpanded: [self storeFolderNodeForName: 
					    [Utilities accountNameForServerName: [theStore name]
						       username: [theStore username]]]])
    {
      [outlineView expandItem: [self storeFolderNodeForName: 
				       [Utilities accountNameForServerName: [theStore name]
						  username: [theStore username]]] ];
    }
}


//
//
//
- (void) _reloadFoldersAndExpandParentsFromNode: (FolderNode *) theNode
			     selectNodeWithPath: (NSString *) thePath
{ 
  NSString *aServerName, *aUsername;
  NSMutableArray *nodesToExpand;
  
  id aParent, aRootNode;
  NSInteger i, aRow; 
  
  [Utilities storeKeyForFolderNode: theNode
		        serverName: &aServerName
		          username: &aUsername];

  // We must refresh our outline view by reload its content
  [self reloadAllFolders];
  
  // We first get our root node
  if ([thePath hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]])
    {
      aRootNode = localNodes;
    }
  else
    {
      aRootNode = [self storeFolderNodeForName: [Utilities accountNameForServerName: aServerName  username: aUsername]];
    }


  // We get our new node in our tree and also our new row index
  aParent = [Utilities folderNodeForPath: [thePath stringByDeletingLastPathComponent]
		       using: aRootNode
		       separator: '/'];

  nodesToExpand = [[NSMutableArray alloc] init];

  // We expand all our parent, to make the row visible.
  while (aParent)
    {
      [nodesToExpand addObject: aParent];
      aParent = [aParent parent];
    }
  
  // We must expand our nodes starting from the root to the children and not
  // the other way around. Otherwise, the NSOutlineView just borks.
  for (i = ([nodesToExpand count] - 1); i >= 0; i--)
    {
      [outlineView expandItem: [nodesToExpand objectAtIndex: i]];
    }

  RELEASE(nodesToExpand);

  // We now get our new node node (renamed or created). Since it's now shown on the screen,
  // we can now obtain the row for it and select it.
  aParent = [Utilities folderNodeForPath: thePath
		       using: aRootNode
		       separator: '/'];

  aRow = [outlineView rowForItem: aParent];


  if (aRow >= 0 && aRow < [outlineView numberOfRows])
    {
      [outlineView selectRow: aRow  byExtendingSelection: NO];
      [outlineView scrollRowToVisible: aRow];
    }
}


//
//
//
- (NSString *) _stringValueOfURLNameFromItem: (id) theItem
				       store: (CWStore **) theStore
{
  NSMutableString *aMutableString;
  NSString *aString;
  
  aMutableString = [[NSMutableString alloc] init];
  
  // We verify if it's a local folder
  if ([[Utilities completePathForFolderNode: theItem  separator: '/'] 
	hasPrefix: [NSString stringWithFormat: @"/%@", _(@"Local")]])
    {
      [aMutableString appendFormat: @"local://%@", [[NSUserDefaults standardUserDefaults] 
						     objectForKey: @"LOCALMAILDIR"]];
      *theStore = [self storeForName: @"GNUMAIL_LOCAL_STORE"
			username: NSUserName()];
    }
  else
    {
      NSString *aServerName, *aUsername;
      
      [Utilities storeKeyForFolderNode: theItem
		 serverName: &aServerName 
		 username: &aUsername];
      *theStore = [self storeForName: aServerName
			username: aUsername];
  
      [aMutableString appendFormat: @"imap://%@@%@", aUsername, aServerName];
    }
  
  // We get our folder name, respecting the folder separator
  aString = [Utilities pathOfFolderFromFolderNode: (FolderNode *)theItem
		       separator: [(id<CWStore>)*theStore folderSeparator]];
  
  [aMutableString appendFormat: @"/%@", aString];

  return AUTORELEASE(aMutableString);
}


//
//
//
- (void) _updateMailboxesFromOldPath: (NSString *) theOldPath
                              toPath: (NSString *) thePath

{
  NSMutableDictionary *allAccounts, *theAccount, *allValues;
  NSEnumerator *theEnumerator;
  NSString *aKey;
  
  allAccounts = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] 
								   dictionaryForKey: @"ACCOUNTS"]];
  
  theEnumerator = [allAccounts keyEnumerator];
  
  while ((aKey = [theEnumerator nextObject]))
    {
      theAccount = [[NSMutableDictionary alloc] initWithDictionary: [allAccounts objectForKey: aKey]];
      allValues = [[NSMutableDictionary alloc] initWithDictionary: [theAccount objectForKey: @"MAILBOXES"]];
      
      UPDATE_PATH(@"DRAFTSFOLDERNAME", theOldPath, thePath);
      UPDATE_PATH(@"INBOXFOLDERNAME", theOldPath, thePath);
      UPDATE_PATH(@"SENTFOLDERNAME", theOldPath, thePath);
      UPDATE_PATH(@"TRASHFOLDERNAME", theOldPath, thePath);
      
      [theAccount setObject: allValues  forKey: @"MAILBOXES"];
      RELEASE(allValues);
      
      [allAccounts setObject: theAccount  forKey: aKey];
      RELEASE(theAccount);
    }
  
  [[NSUserDefaults standardUserDefaults] setObject: allAccounts  forKey: @"ACCOUNTS"];
  RELEASE(allAccounts);
}


//
//
//
- (void) _updateContextMenu
{
  NSMenu *aMenu, *aSubmenu;
  NSMenuItem *aMenuItem;
  NSArray *allKeys;
  NSInteger i;

  allKeys = [[Utilities allEnabledAccounts] allKeys];
  aMenu = [[[menu itemArray] lastObject] submenu];

  for (i = 0; i < 3; i++)
    {
      NSUInteger j;
      aMenuItem = (NSMenuItem *)[aMenu itemAtIndex: i];
      
      aSubmenu = [[NSMenu alloc] init];
      [aSubmenu setAutoenablesItems: NO];
      
      for (j = 0; j < [allKeys count]; j++)
	{
	  [aSubmenu addItemWithTitle: [allKeys objectAtIndex: j]  action: @selector(setMailboxAs:)  keyEquivalent: @""];
	  [[[aSubmenu itemArray] lastObject] setTarget: self];
	  [[[aSubmenu itemArray] lastObject] setTag: i];
	}

      [aMenuItem setSubmenu: aSubmenu];
      RELEASE(aSubmenu);
    }
}

@end








