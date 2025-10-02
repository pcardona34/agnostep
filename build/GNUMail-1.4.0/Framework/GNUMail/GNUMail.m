/*
**  GNUMail.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2014-2023 Riccardo Mottola
**
**  Authors: Ludovic Marcotte <ludovic@Sophos.ca>
**           Riccardo Mottola <rm@gnu.org>
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

#import "GNUMail.h"

#import "AboutPanelController.h"
#import "AddressBookController.h"
#import "ApplicationIconController.h"
#import "ConsoleWindowController.h"
#import "EditWindowController.h"
#import "ExtendedMenuItem.h"
#import "ExtendedWindow.h"
#import "Filter.h"
#import "FilterManager.h"
#import "FindWindowController.h"
#import "FolderNode.h"
#import "GNUMail+Extensions.h"
#import "GNUMailBundle.h"
#import "Constants.h"
#import "MailWindowController.h"
#import "MailboxInspectorPanelController.h"
#import "MailboxManagerCache.h"
#import "MailboxManagerController.h"
#import "MessageViewWindowController.h"
#import "MimeTypeManager.h"
#import "MimeType.h"
#import "NSAttributedString+Extensions.h"
#import "NSBundle+Extensions.h"
#import "NSPasteboard+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "PreferencesWindowController.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"
#import "MessageComposition.h"
#import "STScriptingSupport.h"
#import "WelcomePanel.h"

#import <Pantomime/CWCharset.h>
#import <Pantomime/CWConstants.h>
#import <Pantomime/CWContainer.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWIMAPCacheManager.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWStore.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/NSFileManager+Extensions.h>


// GNUMail's download page -- where to download from
#define DOWNLOAD_URL	@"http://www.collaboration-world.com/cgi-bin/collaboration-world/project/release.cgi?pid=2"

// GNUMail's Version Property Page
#define PROPERTY_URL	@"http://www.nongnu.org/gnustep-nonfsf/gnumail/VERSION"

#define TOGGLE_WINDOW(controller) \
  if ([[[controller singleInstance] window] isVisible]) [[[controller singleInstance] window] orderOut: self]; \
  else [[controller singleInstance] showWindow: self];

// Static variables
static NSMutableArray *allEditWindows = nil;
static NSMutableArray *allEditWindowControllers = nil;
static NSMutableArray *allMailWindows = nil;
static NSMutableArray *allMailWindowControllers = nil;
static NSMutableArray *allBundles;

static NSString *currentWorkingPath = nil;

static id lastAddressTakerWindowOnTop = nil;
static id lastMailWindowOnTop = nil;
static id requestLastMailWindowOnTop = nil;
static BOOL doneInit = NO;


//
// Private methods
//
@interface GNUMail (Private)
- (BOOL) _checkForUpdate;
- (BOOL) _checkDictionary: (NSDictionary *) theDictionary;
- (void) _connectToIMAPServers;
- (void) _loadBundles;
- (void) _makeFilter: (int) theSource;
- (void) _newVersionAvailable: (NSString *) theVersion;
- (void) _removeAllItemsFromMenu: (NSMenu *) theMenu;
- (void) _savePanelDidEnd: (NSSavePanel *) theSheet 
               returnCode: (int) returnCode
              contextInfo: (void  *) contextInfo;
- (void) _updateFilterMenuItems: (id) sender;
- (void) _updateGetNewMailMenuItems: (id) sender;
- (void) _updateTextEncodingsMenu: (id) sender;
- (void) _updateVisibleColumns;
@end


//
//
//
@implementation GNUMail

- (id) init
{
  self = [super init];

#ifdef MACOSX
  _messageCompositions = [[NSMutableArray alloc] init];
#endif
  return self;
}


//
//
//
- (void) dealloc
{
#ifdef MACOSX
  RELEASE(dock);
  RELEASE(_messageCompositions);
#endif  

  [super dealloc];
}

//
// action methods
//
- (IBAction) addSenderToAddressBook: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      id aController;

      aController = [[GNUMail lastMailWindowOnTop] windowController];

      if ([[aController dataView] numberOfSelectedRows] != 1)
	{
	  NSBeep();
	  return;
	}

      [[AddressBookController singleInstance] addSenderToAddressBook: [aController selectedMessage]];
    }
}

- (IBAction) applyManualFilter: (id) sender
{
  if ([GNUMail lastMailWindowOnTop]) 
    {
      MailWindowController *aMailWindowController;
      FilterManager *aFilterManager;
      CWFolder *aSourceFolder;

      NSArray *selectedMessages;
      NSUInteger i;
      int aTag, aType;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      selectedMessages = [aMailWindowController selectedMessages];

      if (!selectedMessages || [selectedMessages count] == 0)
	{
	  NSBeep();
	  return;
	}

      aSourceFolder = [aMailWindowController folder];
      aTag = [sender tag];

      // If we are in the Sent, we consider ONLY outgoing filters. 
      // Otherwise, we always consider ONLY incoming filters.
      if ([Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: aSourceFolder]  
		      isEqualTo: @"SENTFOLDERNAME"])
	{
	  aType = TYPE_OUTGOING;
	}
      else
	{
	  aType = TYPE_INCOMING;
	}

      aFilterManager = [FilterManager singleInstance];
      
      for (i = 0; i < [selectedMessages count]; i++)
	{
	  CWMessage *aMessage;
	  Filter *aFilter;

	  aMessage = [selectedMessages objectAtIndex: i];
	  
	  // If we have selected ALL our filters...
	  if (aTag < 0)
	    {
	      aFilter = [aFilterManager matchedFilterForMessage: aMessage  type: aType];
	    }
	  else
	    {
	      aFilter = [aFilterManager filterAtIndex: aTag];
	    }

	  // We verify if the filter matches the message
	  if (aFilter && [aFilterManager matchExistsForFilter: aFilter  message: aMessage] &&
	      ([aFilter action] == TRANSFER_TO_FOLDER || [aFilter action] == DELETE))
	    {
	      CWFolder *aDestinationFolder;
	      CWURLName *theURLName;
	      
	      if ([aFilter action] == DELETE)
		{
		  NSString *aString;
		  
		  aString = [Utilities accountNameForMessage: aMessage];
		  theURLName = [[CWURLName alloc] initWithString: [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: aString] 
								     objectForKey: @"MAILBOXES"] objectForKey: @"TRASHFOLDERNAME"]
						  path: [[NSUserDefaults standardUserDefaults] 
							  objectForKey: @"LOCALMAILDIR"]];
		}
	      else
		{
		  theURLName = [[CWURLName alloc] initWithString: [aFilter actionFolderName]
						  path: [[NSUserDefaults standardUserDefaults] 
							  objectForKey: @"LOCALMAILDIR"]];
		}
	      
	      AUTORELEASE(theURLName);
	      
	      aDestinationFolder = [[MailboxManagerController singleInstance] folderForURLName: theURLName];
	      
	      if (!aDestinationFolder)
		{
		  NSRunAlertPanel(_(@"Error!"),
				  _(@"An error occurred while trying to open the %@ mailbox. This mailbox was probably\ndeleted and a filter is trying to save mails in it. Check your filters."),
				  _(@"OK"),
				  NULL,
				  NULL,
				  [theURLName foldername]);
		  return;
		}
	      
	      //
	      // We verify that our target folder isn't the one that is currently open (and last on top)
	      // If so, we do nothing.
	      //
	      if (aDestinationFolder == aSourceFolder)
		{
		  return;
		}
	      
	      [aDestinationFolder setProperty: [NSDate date]  forKey: FolderExpireDate];
	      
	      [[MailboxManagerController singleInstance] transferMessages: [NSArray arrayWithObject: aMessage]
							 fromStore: [aSourceFolder store]
							 fromFolder: aSourceFolder
							 toStore: [aDestinationFolder store]
							 toFolder: aDestinationFolder
							 operation: MOVE_MESSAGES];
	    } // if ( aFilter && [aFilterManager ...] )
	} // for (...)
    }
  else
    {
      NSBeep();
    }
}


#ifdef MACOSX
//
//
//
- (void) awakeFromNib
{
  NSMenuItem *item;
 
  dock = [[NSMenu alloc] init];
  [dock setAutoenablesItems: NO];
  
  item = [[NSMenuItem alloc] initWithTitle: _(@"New Message")
			     action: @selector(composeMessage:)
			     keyEquivalent: @""];
  [dock addItem: item];
  RELEASE(item);
}

//
//
//
- (NSMenu *) applicationDockMenu: (NSApplication *) sender
{
  return dock; 
}

//
//
//
- (BOOL) applicationShouldHandleReopen: (NSApplication *) theApplication  hasVisibleWindows: (BOOL) theBOOL
{
  if (![[GNUMail allMailWindows] count])
    {
      [self newViewerWindow: theApplication];
    }
 
  return NO;
}
#endif


//
//
//
- (IBAction) changeTextEncoding: (id) sender
{
  NSWindow *aWindow;

  aWindow = [NSApp keyWindow];

  if (!aWindow)
    {
      NSBeep();
      return;
    }
  else
    {
      id aWindowController;

      aWindowController = [aWindow windowController];

      //
      // We are working with a MailWindowController / MessageViewWindowController
      //
      if ([aWindowController isKindOfClass: [MailWindowController class]] ||
	  [aWindowController isKindOfClass: [MessageViewWindowController class]])
	{
	  CWMessage *theMessage;
	  
	  if ([aWindowController isKindOfClass: [MailWindowController class]])
	    {
	      theMessage = [aWindowController selectedMessage];
	    }
	  else
	    {
	      theMessage = [(MessageViewWindowController *)aWindowController message];
	    }

	  if (theMessage)
	    {
	      NSString *theCharset;
	      NSData *aData;
	      id aDataView;

	      aDataView = [aWindowController dataView];
	      
	      if ([sender tag] == -1)
		{
		  theCharset = [theMessage charset];
		}
	      else
		{
		  theCharset = [[[CWCharset allCharsets] allKeysForObject: [sender title]] objectAtIndex: 0];
		}

	      [theMessage setDefaultCharset: theCharset];
	      aData = [theMessage rawSource];
	      
	      if (aData)
		{
		  NSAutoreleasePool *pool;
		  CWMessage *aMessage;

		  pool = [[NSAutoreleasePool alloc] init];
		  
		  aMessage = [[CWMessage alloc] initWithData: aData  charset: theCharset];
		  
		  // We show the new message
		  [Utilities showMessage: aMessage
			     target: [aWindowController textView]
			     showAllHeaders: [aWindowController showAllHeaders]];

		  // We set the new headers of the message and we refresh the selected row in our data view
		  [theMessage setHeaders: [aMessage allHeaders]];
		  [aDataView setNeedsDisplayInRect: [aDataView rectOfRow: [aDataView selectedRow]]];	

		  RELEASE(aMessage);
		  RELEASE(pool);
		}
	      else
		{
		  Task *aTask;
		  
		  [theMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageLoading];
		  [theMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageDestinationChangeEncoding];

		  aTask = [[Task alloc] init];
		  [aTask setKey: [Utilities accountNameForFolder: [theMessage folder]]];
		  aTask->op = LOAD_ASYNC;
		  aTask->immediate = YES;
 		  aTask->total_size = (float)[theMessage size]/(float)1024;
		  [aTask setMessage: theMessage];
		  [aTask addController: aWindowController];
		  [[TaskManager singleInstance] addTask: aTask];
		  RELEASE(aTask);
		}
	    }
	  else
	    {
	      NSBeep();
	    }
	}
      //
      // We are working with an EditWindowController
      //
      else if ([aWindowController isKindOfClass: [EditWindowController class]])
	{
	  [aWindowController setCharset: [sender title]];
	}
      //
      // The rest, just beep!
      //
      else
	{
	  NSBeep();
	}
    }
}


//
// Handles the 'check for update' request
//
- (IBAction) checkForUpdates: (id) sender
{
  NSString *msg, *error;
  
  msg = nil;
  error = nil;

  NS_DURING
    {
      if (![self _checkForUpdate])
        {
          msg = [NSString stringWithFormat: _(@"There is no new version of %@ available."),
			  [[NSProcessInfo processInfo] processName]];
          error = @"";
        }
    }
  NS_HANDLER
    {
      msg = _(@"Unable to check for new software.");
      error = [NSString stringWithFormat: _(@"Check failed due to the following reason:\n%@"),
			[localException reason]];
    }
  NS_ENDHANDLER {}
  
  if (msg)
    {
      NSRunInformationalAlertPanel(msg, error, _(@"OK"), NULL, NULL);
    }
  
  return;
}


//
//
//
- (IBAction) close: (id) sender
{
  if ([NSApp keyWindow])
    {
      [[NSApp keyWindow] performClose: sender];
    }
}


//
//
//
- (IBAction) compactMailbox: (id) sender
{
  if ([GNUMail lastMailWindowOnTop]) 
    {
      int choice;
      
      choice = NSAlertDefaultReturn;

      if (![[NSUserDefaults standardUserDefaults] objectForKey: @"PROMPT_BEFORE_COMPACT"] ||
	  [[NSUserDefaults standardUserDefaults] boolForKey: @"PROMPT_BEFORE_COMPACT"])
	{
	  choice = NSRunAlertPanel(_(@"Compact..."),
				   _(@"Compacting a mailbox will permanently remove deleted messages.\nDo you want to continue?"),
				   _(@"Compact"),  // default
				   _(@"Cancel"),   // alternate
				   NULL);
	}
      
      if (choice == NSAlertDefaultReturn)
	{
	  CWFolder* aFolder;

	  aFolder = [(MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate] folder];
	  
	  ADD_CONSOLE_MESSAGE(_(@"Compacting mailbox, please wait..."), [aFolder name]);
	  [aFolder expunge];
	  
	  if ([aFolder isKindOfClass: [CWIMAPFolder class]])
	    {
	      Task *aTask;
	      
	      aTask = [[Task alloc] init];
	      aTask->op = EXPUNGE_ASYNC;
	      [aTask setKey: [Utilities accountNameForFolder: aFolder]];
	      aTask->immediate = YES;
	      [[TaskManager singleInstance] addTask: aTask];
	      RELEASE(aTask);
	    }
	}
    }
  else
    {
      NSBeep();
    }
}


//
// This method is used to compose a new message, with an empty content.
//
- (IBAction) composeMessage: (id) sender
{
  EditWindowController *editWindowController;
  CWMessage *aMessage;
  
  // We create an empty message
  aMessage = [[CWMessage alloc] init];
  
  // We create our controller and we show the window
  editWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
  
  [allEditWindowControllers addObject: editWindowController];
  [editWindowController release];

  if (editWindowController)
    {
      id aMailWindowController;

      [[editWindowController window] setTitle: _(@"New message...")];
      [editWindowController setMessage: aMessage];
      [editWindowController setShowCc: NO];
            
      // We try to guess the best account to use
      aMailWindowController = [GNUMail lastMailWindowOnTop];
      
      if (aMailWindowController)
	{
	  [editWindowController setAccountName: [Utilities accountNameForFolder: [[aMailWindowController windowController] folder]]];
	}
      else
	{
	  [editWindowController setAccountName: nil];
	}

      [editWindowController showWindow: self];
    }

  RELEASE(aMessage);
}



//
//
//
- (IBAction) copy: (id) sender
{
  NSPasteboard *aPasteboard;

  aPasteboard = [NSPasteboard generalPasteboard];
  
  if ([[[NSApp keyWindow] delegate] isKindOfClass: [MailWindowController class]] && [GNUMail lastMailWindowOnTop])
    {
      MailWindowController *aMailWindowController;
      NSMutableArray *messagesToLoad;
      NSArray *allMessages;
      CWMessage *aMessage;
      Task *aTask;
      int count;

      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      allMessages = [aMailWindowController selectedMessages];
      count = [allMessages count];
      aMessage = nil;
      
      if (count)
	{
	  messagesToLoad = [NSMutableArray array];
	  aTask = [[Task alloc] init];
	  aTask->op = LOAD_ASYNC;
	  aTask->immediate = YES;

	  // First, we clear our existing property list.
	  [aPasteboard setPropertyList: [NSArray array]  forType: MessagePboardType];

	  while (count--)
	    {
	      aMessage = (CWMessage *)[allMessages objectAtIndex: count];
	      
	      if ([aMessage rawSource])
		{
		  [aPasteboard addMessage: [allMessages objectAtIndex: count]];
		}
	      else
		{	  
		  [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageLoading];
		  [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageDestinationPasteboard];
		  [messagesToLoad addObject: aMessage];
		  aTask->total_size += (float)[aMessage size]/(float)1024;
		}
	    }


	  if ([messagesToLoad count])
	    {
	      [aTask setKey: [Utilities accountNameForFolder: [aMessage folder]]];
	      [aTask setMessage: messagesToLoad];
	      aTask->total_count = [messagesToLoad count];
	      [[TaskManager singleInstance] addTask: aTask];
	    }

	  RELEASE(aTask);

	  // If the sender is self, that means we performed a "cut" operation.
	  // Let's mark the messages as deleted and refresh the associated view.
	  if (sender == self)
	    {
	      CWFlags *theFlags;

	      count = [allMessages count];

	      while (count--)
		{
		  aMessage = [allMessages objectAtIndex: count];
		  theFlags = [[aMessage flags] copy];
		  
		  // We set the flag PantomimeDeleted to the message
		  [theFlags add: PantomimeDeleted];
		  [aMessage setFlags: theFlags];
		  RELEASE(theFlags);
		}

	      [[aMailWindowController folder] updateCache];
	      [aMailWindowController tableViewShouldReloadData];
	      [aMailWindowController updateStatusLabel];
	    }
	}
      else
	{
	  NSBeep();
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
//
//
//
- (IBAction) customizeToolbar: (id) sender
{
  NSWindow *aWindow;

  aWindow = [NSApp keyWindow];

  if (aWindow && [aWindow toolbar])
    {
      [[aWindow toolbar] runCustomizationPalette: sender];
    }
}

//
//
//
- (IBAction) cut: (id) sender
{
  [self copy: self];
}


//
//
//
- (IBAction) enterSelectionInFindPanel: (id) sender
{
  if ([GNUMail lastMailWindowOnTop]) 
    {
      MailWindowController *aMailWindowController;
      NSTextView *aTextView;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      aTextView = [aMailWindowController textView];
      
      [[[FindWindowController singleInstance] 
	 findField] setStringValue: [[aTextView string] substringWithRange: [aTextView selectedRange]]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) findNext: (id) sender
{
  [[FindWindowController singleInstance] nextMessage: nil];
}


//
//
//
- (IBAction) findPrevious: (id) sender
{
  [[FindWindowController singleInstance] previousMessage: nil];
}


// 
// This method is used to forward the selected messsage from the last
// mail window that was on top.
//
- (IBAction) forwardMessage: (id) sender
{  
  if ([GNUMail lastMailWindowOnTop])
    {
      CWMessage *aMessage;
      int tag;
      
      aMessage = [[[GNUMail lastMailWindowOnTop] delegate] selectedMessage];

      if (!aMessage)
	{
	  NSBeep();
	  return;
	}

      tag = [sender tag];

      if (tag == PantomimeAttachmentForwardMode)
	{
	  [Utilities forwardMessage: aMessage  mode: PantomimeAttachmentForwardMode];
	}
      else
	{
	  [Utilities forwardMessage: aMessage  mode: PantomimeInlineForwardMode];
	}
    }
  else
    {
      NSBeep();
    }
}


//
// This method is used to get the new messages if the LocalInboxWindow
// is currently opened and visible.
//
- (IBAction) getNewMessages: (id) sender
{
  id aController;
  
  aController = [GNUMail lastMailWindowOnTop];

  if (aController)
    {
      aController = [[GNUMail lastMailWindowOnTop] windowController];

      if ([aController isKindOfClass: [MessageViewWindowController class]])
	{
	  aController = [(MessageViewWindowController *)aController mailWindowController];
	}
    }
 
  [[TaskManager singleInstance] checkForNewMail: sender  controller: aController];
}


//
//
//
- (IBAction) importMailboxes: (id) sender
{
  NSString *aString;
  NSBundle *aBundle;

#ifdef MACOSX
  aString = [[[NSBundle mainBundle] builtInPlugInsPath] 
	      stringByAppendingPathComponent: @"Import.bundle"];
#else
  NSArray *allPaths;
  BOOL b;
  NSUInteger i;

  allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
						 NSLocalDomainMask|
						 NSNetworkDomainMask|
						 NSSystemDomainMask|
						 NSUserDomainMask,
						 YES);
  aString = nil;

  for (i = 0; i < [allPaths count]; i++)
    {
      aString = [NSString stringWithFormat: @"%@/GNUMail/Import.bundle", [allPaths objectAtIndex: i]];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath: aString  isDirectory: &b] && b)
	{
	  break;
	}
    }
#endif
	
  aBundle = [NSBundle bundleWithPath: aString];

  if (aBundle)
    {
      [[[aBundle principalClass] singleInstance] showWindow: self];
      return;
    }

  // We were unable to load the Import bundle.
  NSBeep();
}


//
//
//
- (IBAction) makeFilterFromListId: (id) sender
{
  [self _makeFilter: EXPERT];
}

//
//
//
- (IBAction) makeFilterFromSender: (id) sender
{
  [self _makeFilter: FROM];
}

//
//
//
- (IBAction) makeFilterFromTo: (id) sender
{
  [self _makeFilter: TO];
}

//
//
//
- (IBAction) makeFilterFromCc: (id) sender
{
  [self _makeFilter: CC];
}


//
//
//
- (IBAction) makeFilterFromSubject: (id)sender
{
  [self _makeFilter: SUBJECT];
}



//
//
//
- (IBAction) nextUnreadMessage: (id) sender
{
  if ( [GNUMail lastMailWindowOnTop] &&
       [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]] )
    {
      [[[GNUMail lastMailWindowOnTop] delegate] nextUnreadMessage: sender];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) newViewerWindow: (id) sender
{
  MailWindowController *aMailWindowController;
  
  aMailWindowController = [[MailWindowController alloc] initWithWindowNibName: @"MailWindow"];
  [allMailWindowControllers addObject: aMailWindowController];
  [aMailWindowController release];
  
  [aMailWindowController setFolder: nil];
  [[aMailWindowController window] orderFrontRegardless];
  [[aMailWindowController window] makeKeyAndOrderFront: nil];
}


//
//
//
- (IBAction) paste: (id) sender
{
  NSArray *types, *propertyList;
  NSPasteboard *pboard;
  NSString *aType;
  NSUInteger i;
  
  // We verify every supported pasteboard type  
  pboard = [NSPasteboard generalPasteboard];
  types = [pboard types];

  for (i = 0; i < [types count]; i++)
    {
      aType = (NSString*)[types objectAtIndex: i];
            
      //
      // MessagePboardType
      //
      if ([MessagePboardType isEqualToString: aType])
	{
	  propertyList = [pboard propertyListForType: MessagePboardType];

	  if (propertyList)
	    {
	      MailWindowController *aMailWindowController;
	      int count;

	      aMailWindowController = nil;


	      if (([[[NSApp keyWindow] delegate] isKindOfClass: [MailWindowController class]] && [GNUMail lastMailWindowOnTop]) ||
		  aMailWindowController)
		{
		  if (!aMailWindowController)
		    {
		      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
		    }

		  count = [propertyList count];
		  	      
		  while (count--)
		    {
		      // We retrieve the message from the property list
		      NSDictionary *aDictionary;
		      CWFlags *theFlags;	
		      NSData *aData;
		      
		      aDictionary = (NSDictionary*)[propertyList objectAtIndex: count];
		      aData = [aDictionary objectForKey: @"Message"];
		      theFlags = (CWFlags*)[NSUnarchiver unarchiveObjectWithData: (NSData*)[aDictionary objectForKey: @"Flags"]];
		      
		      if (aData && theFlags)
			{
			  [[MailboxManagerController singleInstance] transferMessage: aData
								     flags: theFlags
								     folder: [aMailWindowController folder]];
			}
		    }
		  
		  if ([propertyList count] > 0)
		    {
		      [aMailWindowController tableViewShouldReloadData];      
		      [aMailWindowController updateStatusLabel];
		    }
		}
	      else
		{
		  NSBeep();
		}
	    }
	}

    }
}


//
//
//
- (IBAction) previousUnreadMessage: (id) sender
{
  if ([GNUMail lastMailWindowOnTop] &&
      [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]])
    {
      [[[GNUMail lastMailWindowOnTop] delegate] previousUnreadMessage: sender];
    }
  else
    {
      NSBeep();
    }
}


//
// This method prints the current selected message - ie., the one
// shown in the MailWindow's (or MessageViewWindow) text view.
//
- (IBAction) printMessage: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      NSPrintInfo *aPrintInfo;
      id aWindowController;

      aWindowController = [[GNUMail lastMailWindowOnTop] delegate];
      aPrintInfo = [NSPrintInfo sharedPrintInfo];
      [aPrintInfo setHorizontalPagination: NSFitPagination];
      
      [[NSPrintOperation printOperationWithView: [aWindowController textView]  printInfo: aPrintInfo] runOperation];
    }
  else
    {
      NSBeep();
    }
}

// this method is needed due to changes in Framework/GNUMail/MessageViewWindowToolbar.m
// now using NSToolbarPrintItemIdentifier instead of the custom print method
// needs to be changed when the MainMenu NIB can be updated to use printDocument
// instead of printMessage, then the printMessage can just be renamed.
- (void) printDocument: (id)sender
{
  [self printMessage: sender];
}


//
//
//
- (IBAction) redirectMessage: (id) sender
{
  if ([GNUMail lastMailWindowOnTop]) 
    {
      id aWindowController;
      CWMessage *theMessage;
      
      aWindowController = [[GNUMail lastMailWindowOnTop] delegate];
      theMessage = [aWindowController selectedMessage];
      
      if (theMessage)
	{
	  EditWindowController *aController;
	  
	  aController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
	  
	  [theMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageRedirecting];
	  [aController setMode: GNUMailRedirectMessage];
	  [aController setMessage: theMessage];
	  [aController setShowCc: NO];
	  [aController setAccountName: nil];
	  [aController showWindow: self];
	}
      else
	{
	  NSBeep();
	}
    }
  else
    {
      NSBeep();
    }
}


//
// This method is used to reply to the selected message.
//
- (IBAction) replyToMessage: (id) sender
{  
  if ([GNUMail lastMailWindowOnTop])
    {
      [[[GNUMail lastMailWindowOnTop] delegate] replyToMessage: sender];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) restoreDraft: (id) sender
{
  CWMessage *aMessage;
    
  aMessage = [[MailboxManagerController singleInstance] messageFromDraftsFolder];

  // We create our controller and we show the window if we have a valid message
  if (aMessage)
    {
      EditWindowController *aController;

      // Initialize the the message if it has not been already
      if (![aMessage isInitialized])
	{
	  [aMessage setInitialized: YES];
	  [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: @"RestoringFromDrafts"];
	}
      
      aController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
      [aController setMode: GNUMailRestoreFromDrafts];
      [aController setMessageFromDraftsFolder: aMessage];
      [aController updateWithMessage: aMessage];
      [aController showWindow: self];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) saveInDrafts: (id) sender
{
  if ([GNUMail lastAddressTakerWindowOnTop])
    {
      [[MailboxManagerController singleInstance] saveMessageInDraftsFolderForController: [GNUMail lastAddressTakerWindowOnTop]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) saveAttachment: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      NSTextAttachment *aTextAttachment;
      
      aTextAttachment = [sender textAttachment];
      
      [Utilities clickedOnCell: [aTextAttachment attachmentCell]
		 inRect: NSZeroRect
		 atIndex: 0
		 sender: self];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) saveAllAttachments: (id) sender
{
  NSTextAttachment *aTextAttachment;
  NSFileWrapper *aFilewrapper;
  NSSavePanel *aSavePanel;

  BOOL useSameDir, ask;
  NSInteger i;

  aSavePanel = [NSSavePanel savePanel];
  [aSavePanel setAccessoryView: nil];
  [aSavePanel setRequiredFileType: @""];

  useSameDir = NO;
  ask = YES;

  for (i = 2; i < [save numberOfItems]; i++ )
    {
      aTextAttachment = [(ExtendedMenuItem *)[save itemAtIndex: i] textAttachment];
      aFilewrapper = [aTextAttachment fileWrapper];
      
      if (!useSameDir)
        {
          int aChoice;

          aChoice = [aSavePanel runModalForDirectory: [GNUMail currentWorkingPath]
                                file: [aFilewrapper preferredFilename]];
	  
          // if successful, save file under designated name
          if ( aChoice == NSOKButton )
            {
              if (![aFilewrapper writeToFile: [aSavePanel filename]
				 atomically: YES
				 updateFilenames: YES])
                {
                  NSBeep();
                }
	      else
		{
		  [[NSFileManager defaultManager] enforceMode: 0600  atPath: [aSavePanel filename]];
		}
	      
              [GNUMail setCurrentWorkingPath: [[aSavePanel filename] stringByDeletingLastPathComponent]];
            }
        }
      else
        {
          // We save the file in the same directory
          if (![aFilewrapper writeToFile: [[GNUMail currentWorkingPath] stringByAppendingPathComponent:
									  [aFilewrapper preferredFilename]]
			     atomically: YES
			     updateFilenames: YES])
            {
              NSBeep();
            }
	  else
	    {
	      [[NSFileManager defaultManager] enforceMode: 0600  atPath: [[GNUMail currentWorkingPath] stringByAppendingPathComponent:
													 [aFilewrapper preferredFilename]]];
	    }
        }

      if ( ask )
        {
          int use = NSRunAlertPanel(_(@"Information"),
                                    _(@"Use the same directory (%@) to save all other attachments? (override the files with the same name)."),
                                    _(@"Yes"),
                                    _(@"No"),
                                    NULL,
                                    [GNUMail currentWorkingPath]);
          
	  if ( use == NSAlertDefaultReturn )
            {
              useSameDir = YES;
            }
          else if ( use == NSAlertAlternateReturn )
            {
              useSameDir = NO;
            }
	  
          ask = NO;
        }
    }
}



//
// This method is used to save only the textual content of a message
// to the local file system. It skips attachments.
//
- (IBAction) saveTextFromMessage: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      NSSavePanel *aSavePanel;
      id aWindowController;
      CWMessage *aMessage;
      NSWindow *aWindow;
      
      // We get a reference to our mail window controller
      aWindowController = [[GNUMail lastMailWindowOnTop] delegate];
      aMessage = [aWindowController selectedMessage];

      if (aMessage)
	{
	  NSMutableAttributedString *aMutableAttributedString;
	  NSMutableString *aMutableString;
	  NSData *aData;
	  unichar c;

	  //
	  // We don't use [[aWindowController textView] string] directly since the string might
	  // have been modified by bundles (ie., the Emoticon bundle).
	  //
	  aMutableAttributedString = [[NSMutableAttributedString alloc]
				       initWithAttributedString: [NSAttributedString attributedStringFromContentForPart: aMessage
										     controller: aWindowController]];
	  [aMutableAttributedString quote];
	  [aMutableAttributedString format];
      									  
	  aMutableString = [NSMutableString stringWithString: [aMutableAttributedString string]];
	  RELEASE(aMutableAttributedString);
	  c = NSAttachmentCharacter;
	      
	  // We replace all attachments with an asterisk
	  [aMutableString replaceOccurrencesOfString: [NSString stringWithCharacters: &c  length: 1]
			  withString: @"*"
			  options: 0
			  range: NSMakeRange(0, [aMutableString length])];
			  
	  // We get our content of a message (just the text displayed in mail window)
	  aData = [aMutableString dataUsingEncoding: NSUTF8StringEncoding
				  allowLossyConversion: YES];

	  aSavePanel = [NSSavePanel savePanel];
	  [aSavePanel setAccessoryView: nil];
	  [aSavePanel setRequiredFileType: @""];

	  RETAIN(aData);
	  if ([sender respondsToSelector:@selector(window)])
	    {
	      aWindow = [sender window];
	    }
	  else
	    {
	      aWindow = [GNUMail lastMailWindowOnTop];
	    }
	  [aSavePanel beginSheetForDirectory: [GNUMail currentWorkingPath]
		      file: [[aWindowController selectedMessage] subject]
		      modalForWindow: aWindow
		      modalDelegate: self
		      didEndSelector: @selector(_savePanelDidEnd: returnCode: contextInfo:)
		      contextInfo: aData];
	}
      else
	{
	  NSBeep();
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
- (IBAction) selectAllMessagesInThread: (id) sender
{
  MailWindowController *aController;
  CWMessage *aMessage;

  aController = [[GNUMail lastMailWindowOnTop] windowController];
  aMessage = [aController selectedMessage];

  if (aMessage)
    {
      NSEnumerator *theEnumerator;
      CWContainer *aContainer;
      NSUInteger msgIndex;

      //
      // Find the root container
      //
      aContainer = [aMessage propertyForKey: @"Container"];
      
      // We check if we found a container
      if (!aContainer)
	{
	  return;
	}
      
      while (aContainer->parent) aContainer = aContainer->parent;
      
      // We check for the associated message
      if (!aContainer->message)
	{
	  return;
	}
      
      //
      // We now get all children of the root container. We need them
      // in order to select all messages
      //
      msgIndex = [[aController allMessages] indexOfObject: aContainer->message];
      
      if (msgIndex != NSNotFound)
	{
	  [[aController dataView] selectRow: msgIndex  byExtendingSelection: NO];
	}

      theEnumerator = [aContainer childrenEnumerator];

      while ((aContainer = [theEnumerator nextObject]))
	{
	  msgIndex = [[aController allMessages] indexOfObject: aContainer->message];
	  
	  if (msgIndex != NSNotFound)
	    {
	      [[aController dataView] selectRow: msgIndex  byExtendingSelection: YES];
	    }
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
- (IBAction) showAboutPanel: (id) sender
{
  TOGGLE_WINDOW(AboutPanelController);
}


//
//
//
- (IBAction) sortByNumber: (id) sender
{
  if ([GNUMail lastMailWindowOnTop] &&
      [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]]) 
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      [aMailWindowController
	tableView: [aMailWindowController dataView]
	didClickTableColumn: [[aMailWindowController dataView]
			       tableColumnWithIdentifier: @"#"]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) sortByDate: (id) sender
{
  if ( [GNUMail lastMailWindowOnTop] &&
       [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]] ) 
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      [aMailWindowController
	tableView: [aMailWindowController dataView]
	didClickTableColumn: [[aMailWindowController dataView]
			       tableColumnWithIdentifier: @"Date"]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) sortByName: (id) sender
{
  if ( [GNUMail lastMailWindowOnTop] &&
       [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]] ) 
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      [aMailWindowController
	tableView: [aMailWindowController dataView]
	didClickTableColumn: [[aMailWindowController dataView]
			       tableColumnWithIdentifier: @"From"]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) sortBySubject: (id) sender
{
  if ( [GNUMail lastMailWindowOnTop] &&
       [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]] ) 
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      [aMailWindowController
	tableView: [aMailWindowController dataView]
	didClickTableColumn: [[aMailWindowController dataView]
			       tableColumnWithIdentifier: @"Subject"]];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) sortBySize: (id) sender
{
  if ( [GNUMail lastMailWindowOnTop] &&
       [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]] ) 
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];
      
      [aMailWindowController
	tableView: [aMailWindowController dataView]
	didClickTableColumn: [[aMailWindowController dataView]
			       tableColumnWithIdentifier: @"Size"]];
    }
  else
    {
      NSBeep();
    }
}



//
// This method is used to show the address book on the screen.
// We use a singleton.
//
- (IBAction) showAddressBook: (id) sender
{
  TOGGLE_WINDOW(AddressBookController);
}


//
// This method is used to view or hide all headers in the 
// last mail window on top.
//
- (IBAction) showAllHeaders: (id) sender
{ 
  if ([GNUMail lastMailWindowOnTop])
    {
      id aWindowController;
      CWMessage *aMessage;
      
      BOOL aBOOL;
      NSInteger row;
      
      aWindowController = [[GNUMail lastMailWindowOnTop] delegate];

      if ([aWindowController isKindOfClass: [MailWindowController class]] &&
	  (row = [[aWindowController dataView] selectedRow]) &&
	  ([[aWindowController dataView] numberOfSelectedRows] > 1))
	{
	  NSBeep();
	  return;
	}
      
      if ([sender tag] == SHOW_ALL_HEADERS)
	{
	  aBOOL = YES;
	  [aWindowController setShowAllHeaders: aBOOL];
          
          if ([sender isKindOfClass: [NSButton class]] ||
	      [sender isKindOfClass: [NSMenuItem class]])
            {
	      [sender setTitle: _(@"Filtered Headers")];
            }
          else
            {
              [sender setLabel: _(@"Filtered Headers")];
            }
        
	  [sender setTag: HIDE_ALL_HEADERS];
	}
      else
	{
	  aBOOL = NO;
	  [aWindowController setShowAllHeaders: aBOOL];	
          
          if ([sender isKindOfClass: [NSButton class]] ||
	      [sender isKindOfClass: [NSMenuItem class]])
            {
	      [sender setTitle: _(@"All Headers")];
            }
          else
            {
              [sender setLabel: _(@"All Headers")];
            }

	  [sender setTag: SHOW_ALL_HEADERS];
	}
      
      [menu sizeToFit];

      if ([aWindowController isKindOfClass: [MailWindowController class]])
	{
	  aMessage = [aWindowController selectedMessage];
	}
      else
	{
	  aMessage = [(MessageViewWindowController *)aWindowController message];
	}
      
      [Utilities showMessage: aMessage
		 target: [aWindowController textView]
		 showAllHeaders: aBOOL];

      //
      // Whenever we click on this menu item, we reset the "Raw Source" / "Normal Display"
      // menu item to "Raw Source" since it doesn't really make senses to view filtered
      // headers on the raw source of a message!
      // 
      [aWindowController setShowRawSource: NO];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
- (IBAction) showConsoleWindow: (id) sender
{
  TOGGLE_WINDOW(ConsoleWindowController);
}


//
// This method is used to show the find window on the screen.
// We use a singleton.
//
- (IBAction) showFindWindow: (id) sender
{
  TOGGLE_WINDOW(FindWindowController);
}


//
//
//
- (IBAction) showMailboxInspectorPanel: (id) sender
{
  TOGGLE_WINDOW(MailboxInspectorPanelController);
}


//
// This method is used to show the mailbox manager window on the screen.
// We use a singleton.
//
- (IBAction) showMailboxManager: (id) sender
{
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailDrawerView)
    {
      if ([GNUMail lastMailWindowOnTop] &&
	  [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]])
	{
	  [[[GNUMail lastMailWindowOnTop] delegate] openOrCloseDrawer: self];
	}
    }
  else
    {
      TOGGLE_WINDOW(MailboxManagerController);
    }
}


//
// 
//
- (IBAction) showOrHideDeletedMessages: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];

      if ([[aMailWindowController folder] showDeleted])
	{
	  [[aMailWindowController folder] setShowDeleted: NO];
	}
      else
	{
	  [[aMailWindowController folder] setShowDeleted: YES];
	}
      
      [aMailWindowController tableViewShouldReloadData];
      [aMailWindowController updateStatusLabel];
    }
  else
    {
      NSBeep();
    }
}


//
// 
//
- (IBAction) showOrHideReadMessages: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      MailWindowController *aMailWindowController;
      
      aMailWindowController = (MailWindowController *)[[GNUMail lastMailWindowOnTop] delegate];

      if ([[aMailWindowController folder] showRead])
	{
	  [[aMailWindowController folder] setShowRead: NO];
	}
      else
	{
	  [[aMailWindowController folder] setShowRead: YES];
	}
      
      [aMailWindowController tableViewShouldReloadData];
      [aMailWindowController updateStatusLabel];
    }
  else
    {
      NSBeep();
    }
}

//
//
//
- (IBAction) showOrHideTableColumns: (id) sender
{
  NSMutableArray *theColumns;
  NSMenuItem *theItem;
  int i, count;

  theColumns = [[NSMutableArray alloc] init];

  if ([sender state] == NSOnState)
    {
      [sender setState: NSOffState];
    }
  else
    {
      [sender setState: NSOnState];
    }

  count = [columns numberOfItems];

  for (i = 0; i < count; i++)
    {
      theItem = (NSMenuItem *)[columns itemAtIndex: i];

      if ([theItem state] == NSOffState)
	{
	  continue;
	}
      
      switch ([theItem tag])
	{
	case GNUMailDateColumn:
	  [theColumns addObject: @"Date"];
	  break;

	case GNUMailFlagsColumn:
	  [theColumns addObject: @"Flagged"];
	  break;

	case GNUMailFromColumn:
	  [theColumns addObject: @"From"];
	  break;

	case GNUMailNumberColumn:
	  [theColumns addObject: @"Number"];
	  break;

	case GNUMailSizeColumn:
	  [theColumns addObject: @"Size"];
	  break;

	case GNUMailStatusColumn:
	  [theColumns addObject: @"Status"];
	  break;

	case GNUMailSubjectColumn:
	  [theColumns addObject: @"Subject"];
	  break;
	}
    }

  [[NSUserDefaults standardUserDefaults] setObject: theColumns
					 forKey: @"SHOWNTABLECOLUMNS"];
  RELEASE(theColumns);

  [[NSNotificationCenter defaultCenter]
    postNotificationName: TableColumnsHaveChanged
    object: nil
    userInfo: nil];
}

//
//
//
- (IBAction) showOrHideToolbar: (id) sender
{
  NSWindow *aWindow;

  aWindow = [NSApp keyWindow];

  if (aWindow && [aWindow toolbar])
    {
      [[aWindow toolbar] setVisible: ([[aWindow toolbar] isVisible] ? NO : YES)];
    }
}

//
// This method is used to show the preferences window on the screen.
// The window is modal.
//
- (IBAction) showPreferencesWindow: (id) sender
{
  [[PreferencesWindowController singleInstance] showWindow: self];
}


//
// This method is used to show the raw source of the selected message
// from the last mail window on top.
//
- (IBAction) showRawSource: (id) sender
{
  if ([GNUMail lastMailWindowOnTop])
    {
      id aWindowController;
      CWMessage *aMessage;
      
      aWindowController = [[GNUMail lastMailWindowOnTop] delegate];
      
      if (!aWindowController)
	{
	  NSBeep();
	  return;
	}
      
      if ([aWindowController isKindOfClass: [MailWindowController class]])
	{
	  aMessage = [aWindowController selectedMessage];
	}
      else
	{
	  aMessage = [(MessageViewWindowController *)aWindowController message];
	}
      
      if (aMessage)
	{
	  if (![aWindowController showRawSource] )
	    {
	      [aWindowController setShowRawSource: YES];	      
	      if ([sender isKindOfClass: [NSButton class]] ||
		  [sender isKindOfClass: [NSMenuItem class]] )
		{
		  [sender setTitle: _(@"Normal Display")];
		}
	      else
		{
		  [sender setLabel: _(@"Normal Display")];
		}
	      
	      [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageViewing];
	      [Utilities showMessageRawSource: aMessage  target: [aWindowController textView]];
	    }
	  else
	    {
	      [aWindowController setShowRawSource: NO];
	      
	      if ([sender isKindOfClass: [NSButton class]] ||
		  [sender isKindOfClass: [NSMenuItem class]])
		{
		  [sender setTitle: _(@"Raw Source")];
		}
	      else
		{
		  [sender setLabel: _(@"Raw Source")];
		}

	      [Utilities showMessage: aMessage
			 target: [aWindowController textView]
			 showAllHeaders: [aWindowController showAllHeaders]];
	    }
	}
      else
	{
	  NSBeep();
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
- (IBAction) threadOrUnthreadMessages: (id) sender
{
  if ([GNUMail lastMailWindowOnTop] &&
      [[[GNUMail lastMailWindowOnTop] delegate] isKindOfClass: [MailWindowController class]])
    {
      MailWindowController *aMailWindowController;

      aMailWindowController = [[GNUMail lastMailWindowOnTop] delegate];

      if ([[aMailWindowController folder] allContainers])
	{
	  [[aMailWindowController folder] unthread];
	}
      else
	{
	  [[aMailWindowController folder] thread];
	}

      [aMailWindowController tableViewShouldReloadData];
      [[NSNotificationCenter defaultCenter] postNotificationName: MessageThreadingNotification
					    object: [aMailWindowController folder]];
    }
  else
    {
      NSBeep();
    }
}


//
// delegate methods
//
- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) theSender
{
  NSMutableArray *foldersToOpen;
  NSEnumerator *theEnumerator;
  id aStore, aWindow;
  NSInteger choice;
  int i;
  
  if ([[[TaskManager singleInstance] allTasks] count] > 0)
    {
      choice = NSRunAlertPanel(_(@"Error!"),
			       _(@"Not all tasks finished their execution. You must wait before quitting the application.\nOpen the Console (Windows -> Console) if you want to manage those tasks."),
			       _(@"OK"),          // default
			       _(@"Quit Anyway"), // alternate
			       NULL);
      
      if (choice == NSAlertDefaultReturn)
	{
	  return NSTerminateCancel;
	}
    }

  
  // If the user has left any "edited" EditWindow:s open, we warn him/her about this
  if ([allEditWindows count] > 0)
    {
      for (i = 0; i < [allEditWindows count]; i++)
	{
	  if ([[allEditWindows objectAtIndex: i] isDocumentEdited])
	    {
	      choice = NSRunAlertPanel(_(@"Quit"),
				       _(@"There are unsent Compose window."),
				       _(@"Review Unsent"), // default
				       _(@"Quit Anyway"),   // alternate
				       _(@"Cancel"),        // other return
				       NULL);
	      
	      // We want to review unsent Compose windows
	      if (choice == NSAlertDefaultReturn)
		{
		  [[allEditWindows objectAtIndex: i] makeKeyAndOrderFront: self];
		  return NSTerminateCancel;
		}
	      // We want to quit
	      else if (choice == NSAlertAlternateReturn)
		{
		  break;
		}
	      // We want to cancel the quit operation
	      else
		{
		  return NSTerminateCancel;
		}
	    }
	}
    }
  
  // We first remove all observers
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  
  // We release our array containing all our EditWindow:s
  DESTROY(allEditWindows);
  // and its controllers
  DESTROY(allEditWindowControllers);

  // We closes all open MailWindow:s. Before doing so, we
  // save them in the FOLDERS_TO_OPEN default variable in order
  // to reopen them upon the application's startup.
  foldersToOpen = [[NSMutableArray alloc] init];

  for (i = ([allMailWindows count]-1); i >= 0; i--)
    {
      aWindow = [allMailWindows objectAtIndex: i];

      if (![[aWindow delegate] folder])
	{
	  [aWindow close];
	  continue;
	}

      if ([[[aWindow delegate] folder] isKindOfClass: [CWLocalFolder class]])
	{
	  [foldersToOpen addObject: [NSString stringWithFormat: @"local://%@/%@",
					      [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
					      [[[aWindow delegate] folder] name]]];
	}
      else if ([[[aWindow delegate] folder] isKindOfClass: [CWIMAPFolder class]])
	{
	  [foldersToOpen addObject: [NSString stringWithFormat: @"imap://%@@%@/%@",
					      [(CWIMAPStore *)[[[aWindow delegate] folder] store] username],
					      [(CWIMAPStore *)[[[aWindow delegate] folder] store] name],
					      [[[aWindow delegate] folder] name]]];
											     
	}

      [aWindow close];
    }


  // We save our FOLDERS_TO_OPEN value in the user's defaults
  [[NSUserDefaults standardUserDefaults] setObject: foldersToOpen
					 forKey: @"FOLDERS_TO_OPEN"];
  [[NSUserDefaults standardUserDefaults] synchronize];


  // We wait until all our windows are closed
  while ([allMailWindows count] > 0)
    {
      [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
				  beforeDate: [NSDate distantFuture]];
    }

  // We release our array containing all our MailWindow:s
  DESTROY(allMailWindows);
  // and the corresponding controllers
  DESTROY(allMailWindowControllers);

  // We close all remaining open Store:s
  theEnumerator = [[[MailboxManagerController singleInstance] allStores] objectEnumerator];

  while ((aStore = [theEnumerator nextObject]))
    {
      NS_DURING
	[aStore close];
      NS_HANDLER
	// Do nothing
      NS_ENDHANDLER
    }

  // We synchronize our MailboxManagerCache and we close all Stores
  [[(MailboxManagerController *)[MailboxManagerController singleInstance] cache] synchronize];

  // Under GNUstep, we also close the window before releasing the singleton
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailFloatingView)
    {
      [[[MailboxManagerController singleInstance] window] close];
    }

  RELEASE([MailboxManagerController singleInstance]);

  // We close our Console
  [[[ConsoleWindowController singleInstance] window] close];
  RELEASE([ConsoleWindowController singleInstance]);

  // We release our current working path
  TEST_RELEASE(currentWorkingPath);

  // We release our array containing all our bundles
  RELEASE(allBundles);

  // We release our array containing our password cache
  RELEASE([Utilities passwordCache]);

  // We release our MimeType, our Filters and our AddressBook
  RELEASE([MimeTypeManager singleInstance]);
  RELEASE([FilterManager singleInstance]);
  RELEASE([AddressBookController singleInstance]);

  // We stop our task manager
  [(TaskManager *)[TaskManager singleInstance] stop];

  // We finally remove all temporary files and then, we are ready to really close the application.
  [self removeTemporaryFiles];

  // We restore the application image under OS X since if we have drawn to it (by showing
  // the unread messages count), this image will stay put.
#ifdef MACOSX
  [NSApp setApplicationIconImage: [NSImage imageNamed: @"NSApplicationIcon"]];
#endif

  return NSTerminateNow;
}


//
//
//
- (void) applicationWillFinishLaunching: (NSNotification *) theNotification
{
#ifdef MACOSX
  // We begin by setting our NSApp's icon
  [ApplicationIconController singleInstance];
#else
  SEL action = NULL;
  unichar del, up, down;
  NSMenuItem *tempMenuItem;

  del = NSDeleteCharacter;       // FIXME: We might want to display, instead:
  up = NSUpArrowFunctionKey;     // 8593 (0x2191) U+2191 arrowup UPWARDS ARROW
  down = NSDownArrowFunctionKey; // 8595 (0x2193) U+2193 arrowup DOWNWARDS ARROW

  // We begin by setting our NSApp's icon
  [ApplicationIconController singleInstance];

  // We continue by creating our NSMenu
  menu = [[NSMenu alloc] init];
  
  [menu addItemWithTitle: _(@"Info") 
	action: action 
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Message") 
	action: action 
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Mailbox") 
	action: action 
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Edit")
	action: action
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Find")
	action: action
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"View")
	action: action
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Windows")
	action: action
	keyEquivalent: @""];

  // We verify if scrippting is supported by the application.
  if ( [NSApp isScriptingSupported] )
    {
      [menu addItemWithTitle: _(@"Scripting")
	    action: action
	    keyEquivalent: @""];
    }
  
  [menu addItemWithTitle: _(@"Services")
	action: action
	keyEquivalent: @""];
  [menu addItemWithTitle: _(@"Hide")
	action: @selector (hide:)
	keyEquivalent: @"h"];
  [menu addItemWithTitle: _(@"Quit")
	action: @selector(terminate:)
	keyEquivalent: @"q"];
  
  //
  // Info menu / submenus
  //
  info = [[NSMenu alloc] init];
  [menu setSubmenu: info  forItem: [menu itemWithTitle: _(@"Info")]];
  [info addItemWithTitle: _(@"About GNUMail...")
	action: @selector(showAboutPanel:)   
	keyEquivalent: @""];
  [info addItemWithTitle: _(@"Check for Updates...")
	action: @selector(checkForUpdates:)   
	keyEquivalent: @""];
  [info addItemWithTitle: _(@"Preferences...")
	action: @selector(showPreferencesWindow:)
	keyEquivalent: @","];
  [info addItemWithTitle: _(@"Help...")
	action: action
	keyEquivalent: @"?"];
  RELEASE(info);
  

  //
  // Our Message menu / submenus
  //
  message = [[NSMenu alloc] init];
  [menu setSubmenu: message  forItem: [menu itemWithTitle: _(@"Message")]];

  [message addItemWithTitle: _(@"Compose")
	   action: @selector(composeMessage:) 
	   keyEquivalent: @"n"];

  //
  // Our reply submenu
  //
  [message addItemWithTitle: _(@"Reply")
	   action: action
	   keyEquivalent: @""];

  reply = [[NSMenu alloc] init];
  [message setSubmenu: reply  forItem: [message itemWithTitle: _(@"Reply")]]; 
  
  [reply addItemWithTitle: _(@"Normal")
	 action: @selector(replyToMessage:)  
	 keyEquivalent: @"R"];
  [[reply itemAtIndex: 0] setTag: PantomimeNormalReplyMode];
  [reply addItemWithTitle: _(@"Simple")
	 action: @selector(replyToMessage:)   
	 keyEquivalent: @""];
  [[reply itemAtIndex: 1] setTag: PantomimeSimpleReplyMode];
  [reply addItemWithTitle: _(@"All")
	 action: @selector(replyToMessage:)   
	 keyEquivalent: @"E"];
  [[reply itemAtIndex: 2] setTag: (PantomimeNormalReplyMode|PantomimeReplyAllMode)];


  //
  // Our forward submenu
  //
  [message addItemWithTitle: _(@"Forward")
	   action: action
	   keyEquivalent: @""];
  
  forward = [[NSMenu alloc] init];
  [message setSubmenu: forward  forItem: [message itemWithTitle: _(@"Forward")]];

  [forward addItemWithTitle: _(@"Attachment")
	   action: @selector(forwardMessage:)  
	   keyEquivalent: @""];
  [[forward itemAtIndex: 0] setTag: PantomimeAttachmentForwardMode];
  [forward addItemWithTitle: _(@"Inline")
	   action: @selector(forwardMessage:)  
	   keyEquivalent: @"W"];
  [[forward itemAtIndex: 1] setTag: PantomimeInlineForwardMode];
  RELEASE(forward);

  [message addItemWithTitle: _(@"Redirect")
	   action: @selector(redirectMessage:)  
	   keyEquivalent: @""];
  
  [message addItemWithTitle: _(@"Make Filter from")
	             action: action
	   keyEquivalent: @""];

  //
  // Submenu for creating filter rules from messages
  //
  messageFilter = [[NSMenu alloc] init];
  [message setSubmenu: messageFilter forItem: [message itemWithTitle: _(@"Make Filter from")]];
  [messageFilter addItemWithTitle: _(@"Sender")
		 action: @selector(makeFilterFromSender:)
		 keyEquivalent: @""];
  [messageFilter addItemWithTitle: _(@"To")
                           action: @selector(makeFilterFromTo:)
                    keyEquivalent: @""];
  [messageFilter addItemWithTitle: _(@"Cc")
                           action: @selector(makeFilterFromCc:)
                    keyEquivalent: @""];
  [messageFilter addItemWithTitle: _(@"List-Id")
                           action: @selector(makeFilterFromListId:)
                    keyEquivalent: @""];
  [messageFilter addItemWithTitle: _(@"Subject")
		 action: @selector(makeFilterFromSubject:)
		 keyEquivalent: @""];
  
  RELEASE(messageFilter);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Deliver")];
  [tempMenuItem setAction: @selector(sendMessage:)];
  [tempMenuItem setKeyEquivalent: @"D"];
  [message addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Mark as Read")];
  [tempMenuItem setAction: @selector(markMessageAsReadOrUnread:)];
  [tempMenuItem setKeyEquivalent: @"U"];
  [message addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Mark as Flagged")];
  [tempMenuItem setAction: @selector(markMessageAsFlaggedOrUnflagged:)];
  [tempMenuItem setKeyEquivalent: @""];
  [message addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Undelete")];
  [tempMenuItem setAction: @selector(deleteMessage:)];
  [tempMenuItem setKeyEquivalent: [NSString stringWithCharacters: &del  length: 1]];
  [message addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  [message addItemWithTitle: _(@"Save")
	   action: action
	   keyEquivalent: @""];
  
  save = [[NSMenu alloc] init];
  [message setSubmenu: save  forItem: [message itemWithTitle: _(@"Save")]];  
  [save addItemWithTitle: _(@"Text from Message")
	action: @selector(saveTextFromMessage:)  
	keyEquivalent: @""];
  RELEASE(save);

  [message addItemWithTitle: _(@"Drafts")
	   action: action
	   keyEquivalent: @""];
  
  //
  //
  //
  drafts = [[NSMenu alloc] init];
  tempMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"Save in Drafts")
				     action: @selector(saveInDrafts:)
				     keyEquivalent: @"s"];
  [drafts addItem: tempMenuItem];
  RELEASE(tempMenuItem);
  
  [drafts addItemWithTitle: _(@"Restore Draft")
	  action: @selector(restoreDraft:)
	  keyEquivalent: @""];
  [[message itemWithTitle: _(@"Drafts")] setSubmenu: drafts];
  RELEASE(drafts);

  [message addItemWithTitle: _(@"Text Encodings")
	   action: action
	   keyEquivalent: @""];

  textEncodings = [[NSMenu alloc] init];
  [message setSubmenu: textEncodings  forItem: [message itemWithTitle: _(@"Text Encodings")]];
  RELEASE(textEncodings);

  [message addItemWithTitle: _(@"Add Sender to Address Book")
	   action: @selector(addSenderToAddressBook:)
	   keyEquivalent: @""];

  [message addItemWithTitle: _(@"Apply Manual Filters")
	   action: action
	   keyEquivalent: @""];

  filters = [[NSMenu alloc] init];
  [[message itemWithTitle: _(@"Apply Manual Filters")] setSubmenu: filters];
  RELEASE(filters);

  [message addItemWithTitle: _(@"Print...")
	   action: @selector(printMessage:)
	   keyEquivalent: @"p"];
  RELEASE(message);

  //
  // Mailbox menu / submenus
  //
  mailbox = [[NSMenu alloc] init];
  [menu setSubmenu: mailbox  forItem: [menu itemWithTitle: _(@"Mailbox")]];
  [mailbox addItemWithTitle: _(@"Mailboxes...")
	   action: @selector(showMailboxManager:) 
	   keyEquivalent: @"M"];
  
  incomingMailServers = [[NSMenu alloc] init];
  [mailbox addItemWithTitle: _(@"Get New Mail")
	   action: action
	   keyEquivalent: @""];
  [[mailbox itemAtIndex: 1] setSubmenu: incomingMailServers];
  RELEASE(incomingMailServers);

  [mailbox addItemWithTitle: _(@"New Viewer Window")
	   action: @selector(newViewerWindow:)
	   keyEquivalent: @""];
  [mailbox addItemWithTitle: _(@"Import Mailboxes...")
	   action: @selector(importMailboxes:)
	   keyEquivalent: @""];
  [mailbox addItemWithTitle: _(@"Inspector...")
	   action: @selector(showMailboxInspectorPanel:)
	   keyEquivalent: @""];
  [mailbox addItemWithTitle: _(@"Compact...")
	   action: @selector(compactMailbox:)
	   keyEquivalent: @"K"];
  RELEASE(mailbox);
  
  
  //
  // Edit menu / submenus
  //
  edit = [[NSMenu alloc] init];
  [menu setSubmenu: edit  forItem: [menu itemWithTitle: _(@"Edit")]];

  [edit addItemWithTitle: _(@"Cut")
	action: @selector(cut:)
	keyEquivalent: @"x"];
  [edit addItemWithTitle: _(@"Copy")
	action: @selector(copy:)
	keyEquivalent: @"c"];
  [edit addItemWithTitle: _(@"Paste")
	action: @selector(paste:)
	keyEquivalent: @"v"];
  [edit addItemWithTitle: _(@"Paste As Quoted Text")
	action: @selector(pasteAsQuoted:)
	keyEquivalent: @"V"];
  [edit addItemWithTitle: _(@"Undo")
	action: action
	keyEquivalent: @"z"];
  [edit addItemWithTitle: _(@"Spelling...")
	action: @selector(checkSpelling:)
	keyEquivalent: @":"];
  [edit addItemWithTitle: _(@"Check Spelling")
	action: @selector(showGuessPanel:)
	keyEquivalent: @";"];
  [edit addItemWithTitle: _(@"Select All")
	action: @selector(selectAll:)
	keyEquivalent: @"a"];

  selectAllMessagesInThread = [[NSMenuItem alloc] initWithTitle: _(@"Select All Messages in Thread")
	action: @selector(selectAllMessagesInThread:)
	keyEquivalent: @""];
  [edit addItem: selectAllMessagesInThread];
  RELEASE(selectAllMessagesInThread);
  RELEASE(edit);


  //
  // Find menu / submenus
  //
  find = [[NSMenu alloc] init];
  [menu setSubmenu: find  forItem: [menu itemWithTitle: _(@"Find")]];

  [find addItemWithTitle: _(@"Find Messages...")
	action: @selector(showFindWindow:)
	keyEquivalent: @"F"];
  [find addItemWithTitle: _(@"Find Text...")
	action: action
	keyEquivalent: @"f"];
  [find addItemWithTitle: _(@"Find Next")
	action: @selector(findNext:)
	keyEquivalent: @"g"];
  [find addItemWithTitle: _(@"Find Previous")
	action: @selector(findPrevious:)
	keyEquivalent: @"d"];

  enterSelection = [[NSMenuItem alloc] initWithTitle: _(@"Enter Selection")
				       action: action
				       keyEquivalent: @"e"];
  [find addItem: enterSelection];
  RELEASE(enterSelection);
  RELEASE(find);

  
  //
  // Our View menu / submenus
  //
  view =  [[NSMenu alloc] init];
  [menu setSubmenu: view  forItem: [menu itemWithTitle: _(@"View")]];
    
  threadOrUnthreadMessages = [[NSMenuItem alloc] init];
  [threadOrUnthreadMessages setTitle: _(@"Thread Messages")];
  [threadOrUnthreadMessages setAction: @selector(threadOrUnthreadMessages:)];
  [threadOrUnthreadMessages setKeyEquivalent: @""];
  [threadOrUnthreadMessages setTag: THREAD_MESSAGES];
  [view addItem: threadOrUnthreadMessages];
  RELEASE(threadOrUnthreadMessages);

  [view addItemWithTitle: _(@"Columns")
	action: action 
	keyEquivalent: @""];
  
  columns = [[NSMenu alloc] init];
  [[view itemAtIndex: 1] setSubmenu: columns];
  
  [columns addItemWithTitle: _(@"Date")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"Flags")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"From")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"Number")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"Size")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"Status")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [columns addItemWithTitle: _(@"Subject")
	   action: @selector(showOrHideTableColumns:)
	   keyEquivalent: @""];
  [[columns itemAtIndex: 0] setTag: GNUMailDateColumn];
  [[columns itemAtIndex: 1] setTag: GNUMailFlagsColumn];
  [[columns itemAtIndex: 2] setTag: GNUMailFromColumn];
  [[columns itemAtIndex: 3] setTag: GNUMailNumberColumn];
  [[columns itemAtIndex: 4] setTag: GNUMailSizeColumn];
  [[columns itemAtIndex: 5] setTag: GNUMailStatusColumn];
  [[columns itemAtIndex: 6] setTag: GNUMailSubjectColumn];
  RELEASE(columns);

  [view addItemWithTitle: _(@"Sorting")
	action: action 
	keyEquivalent: @""];

  sorting = [[NSMenu alloc] init];
  [[view itemAtIndex: 2] setSubmenu: sorting];

  [sorting addItemWithTitle: _(@"Sort by Date")
	   action: @selector(sortByDate:) 
	   keyEquivalent: @""];
  [sorting addItemWithTitle: _(@"Sort by Name")
	   action: @selector(sortByName:)
	   keyEquivalent: @"S"];
  [sorting addItemWithTitle: _(@"Sort by Number")
	   action: @selector(sortByNumber:)
	   keyEquivalent: @""];
  [sorting addItemWithTitle: _(@"Sort by Size")
	   action: @selector(sortBySize:)
	   keyEquivalent: @""];
  [sorting addItemWithTitle: _(@"Sort by Subject")
	   action: @selector(sortBySubject:)
	   keyEquivalent: @""];
  RELEASE(sorting);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Hide Deleted")];
  [tempMenuItem setAction: @selector(showOrHideDeletedMessages:)];
  [tempMenuItem setKeyEquivalent: @""];
  [tempMenuItem setTag: HIDE_DELETED_MESSAGES];
  [view addItem: tempMenuItem];
  RELEASE(tempMenuItem);
	  
  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Hide Read")];
  [tempMenuItem setAction: @selector(showOrHideReadMessages:)];
  [tempMenuItem setKeyEquivalent: @""];
  [tempMenuItem setTag: HIDE_READ_MESSAGES];
  [view addItem: tempMenuItem];
  RELEASE(tempMenuItem);
  
  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"All Headers")];
  [tempMenuItem setAction: @selector(showAllHeaders:)];
  [tempMenuItem setKeyEquivalent: @""];
  [tempMenuItem setTag: SHOW_ALL_HEADERS];
  [view addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  tempMenuItem = [[NSMenuItem alloc] init];
  [tempMenuItem setTitle: _(@"Raw Source")];
  [tempMenuItem setAction: @selector(showRawSource:)];
  [tempMenuItem setKeyEquivalent: @""];
  [view addItem: tempMenuItem];
  RELEASE(tempMenuItem);

  [view addItemWithTitle: _(@"Previous Unread")
	action: @selector(previousUnreadMessage:)
	keyEquivalent: [NSString stringWithCharacters: &up  length: 1]];
  [[view itemWithTitle: _(@"Previous Unread")] setKeyEquivalentModifierMask: NSControlKeyMask];

  [view addItemWithTitle: _(@"Next Unread")
	action: @selector(nextUnreadMessage:)
	keyEquivalent: [NSString stringWithCharacters: &down  length: 1]];
  [[view itemWithTitle: _(@"Next Unread")] setKeyEquivalentModifierMask: NSControlKeyMask];

  showOrHideToolbar = [[NSMenuItem alloc] init];
  [showOrHideToolbar setTitle: _(@"Hide Toolbar")];
  [showOrHideToolbar setAction: @selector(showOrHideToolbar:)];
  [showOrHideToolbar setKeyEquivalent: @""];
  [view addItem: showOrHideToolbar];
  RELEASE(showOrHideToolbar);

  customizeToolbar = [[NSMenuItem alloc] init];
  [customizeToolbar setTitle: _(@"Customize Toolbar...")];
  [customizeToolbar setAction: @selector(customizeToolbar:)];
  [customizeToolbar setKeyEquivalent: @""];
  [view addItem: customizeToolbar];
  RELEASE(customizeToolbar);

  RELEASE(view);
  

  //
  // Windows menu
  //
  windows = [[NSMenu alloc] init];
  [menu setSubmenu: windows  forItem: [menu itemWithTitle: _(@"Windows")]];
  [windows addItemWithTitle: _(@"Address Book")
	   action: @selector(showAddressBook:)
	   keyEquivalent: @"A"];
  [windows addItemWithTitle: _(@"Console")
	   action: @selector(showConsoleWindow:)
	   keyEquivalent: @"C"];
  [windows addItemWithTitle: _(@"Arrange")
	   action: @selector(arrangeInFront:)
	   keyEquivalent: @""];
  [windows addItemWithTitle: _(@"Miniaturize")
	   action: @selector(performMiniaturize:)
	   keyEquivalent: @"m"];
  [windows addItemWithTitle: _(@"Close")
	   action: @selector(close:)
	   keyEquivalent: @"w"];
  RELEASE(windows);
  
  if ([NSApp isScriptingSupported])
    {
      [menu setSubmenu: [NSApp scriptingMenu]
	    forItem: [menu itemWithTitle: _(@"Scripting")]];
    }
  
  // Our Services menu
  services = [[NSMenu alloc] init];
  [menu setSubmenu: services  forItem: [menu itemWithTitle: _(@"Services")]];
  [NSApp setServicesMenu: services];
  RELEASE(services);
  
  [NSApp setMainMenu: menu];
  [NSApp setWindowsMenu: windows];
  RELEASE(menu);
#endif
}


//
//
//
- (void) applicationDidFinishLaunching: (NSNotification *) theNotification
{
  NSUserDefaults *aUserDefaults;
  NSString *pathToLocalMailDir;
  NSFileManager *aFileManager;
  CWLocalStore *aLocalStore;  
  
  BOOL isDir, mustShowPreferencesWindow;

  aUserDefaults = [NSUserDefaults standardUserDefaults];
  aFileManager = [NSFileManager defaultManager];
  mustShowPreferencesWindow = NO;
  aLocalStore = nil;

  //
  // We check we if must update our view style
  //
  if ([aUserDefaults objectForKey: @"PreferredViewStyleAfterRestart"])
    {
      [aUserDefaults setInteger: [aUserDefaults integerForKey: @"PreferredViewStyleAfterRestart"]
		     forKey: @"PreferredViewStyle"];
      [aUserDefaults removeObjectForKey: @"PreferredViewStyleAfterRestart"];
    }
  
  // We now verify if the User's Library directory does exist (to store 
  // the AddressBook, the MimeTypes, etc) and if not, we create it.
  if ([aFileManager fileExistsAtPath: (NSString *)GNUMailUserLibraryPath()
		    isDirectory: &isDir])
    {
      if (!isDir)
	{ 
	  NSRunCriticalAlertPanel(_(@"Fatal error!"),
				  _(@"%@ exists but it is a file not a directory.\nThe application will now terminate."),
				  @"OK",
				  NULL,
				  NULL,
				  GNUMailUserLibraryPath());
	  exit(1);
	}
    }
  else 
    {
      if (![aFileManager createDirectoryAtPath: (NSString *)GNUMailUserLibraryPath()
			 attributes: nil] )
	{
	  // Directory creation failed. We warn the user, then quit.
	  NSRunCriticalAlertPanel(_(@"Fatal error!"),
				  _(@"Could not create directory: %@\nThe application will now terminate."),
				  @"OK",
				  NULL,
				  NULL,
				  GNUMailUserLibraryPath());
	  exit(1);
	}
    }
  
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_updateGetNewMailMenuItems:)
    name: AccountsHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_updateFilterMenuItems:)
    name: FiltersHaveChanged
    object: nil];

  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(selectionInTextViewHasChanged:)
    name: NSTextViewDidChangeSelectionNotification
    object: nil];
  
  // We initialize our mutable array containing all open EditWindow:s
  allEditWindows = [[NSMutableArray alloc] init];
  // and their controllers
  allEditWindowControllers = [[NSMutableArray alloc] init];
  
  // We initialize our mutable array containing all open MailWindow:s
  allMailWindows = [[NSMutableArray alloc] init];
  // and their controllers
  allMailWindowControllers = [[NSMutableArray alloc] init];

  // We initialize our mutable array containing all our bundles
  allBundles = [[NSMutableArray alloc] init];

  // We set the current working path of GNUMail to the user's home directory
  [GNUMail setCurrentWorkingPath: NSHomeDirectory()];
  
  
  // Setup our mailbox locations, if LOCALMAILDIR isn't defined, we define
  // it to ~/Mailboxes (if the mbox format is used, ~/Maildir otherwise)
  // under GNUstep and to ~/Library/GNUMail/Mailboxes under Mac OS X
  if (![[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"])
    {
#ifdef MACOSX
      pathToLocalMailDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Library/GNUMail/Mailboxes"];
#else
      pathToLocalMailDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Mailboxes"];
#endif
      
      [[NSUserDefaults standardUserDefaults] setObject: pathToLocalMailDir  forKey: @"LOCALMAILDIR"];
      [[NSUserDefaults standardUserDefaults] setObject: pathToLocalMailDir  forKey: @"LOCALMAILDIR_PREVIOUS"];
    }
  else
    {
      NSString *aString;

      pathToLocalMailDir = [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"];
      
      // We remove the trailing slash, if any.
      if ([pathToLocalMailDir length] > 1 && [pathToLocalMailDir hasSuffix: @"/"])
	{
	  pathToLocalMailDir = [pathToLocalMailDir substringToIndex: ([pathToLocalMailDir length] - 1)];
	  [[NSUserDefaults standardUserDefaults] setObject: pathToLocalMailDir forKey: @"LOCALMAILDIR"];
	}

      // If LOCALMAILDIR_PREVIOUS isn't set, we set it to LOCALMAILDIR
      if (![[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR_PREVIOUS"])
	{
	  [[NSUserDefaults standardUserDefaults] setObject: pathToLocalMailDir  forKey: @"LOCALMAILDIR_PREVIOUS"];
	}

      aString = [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR_PREVIOUS"];

#warning IF THE DESTINATION PATH ALREADY EXISTS, WARN AND QUIT THE APP
      if (![pathToLocalMailDir isEqualToString: aString])
	{
	  [self moveLocalMailDirectoryFromPath: aString  toPath: pathToLocalMailDir];
	}
    }

  //
  // We migrate our preferences (and other things) from previous GNUMail versions.
  // Currently, we can migrate from:  1.1.2 to 1.2.0
  //
  [self update_112_to_120];

  //
  // We verify if GNUMail has been configured, if not, we suggest the user to do so.
  //
  if (![[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"])
    {
      NSMutableDictionary *allValues, *theAccount;
      WelcomePanel *aWelcomePanel;
      int type;

      aWelcomePanel = [[WelcomePanel alloc] init];
      [aWelcomePanel layoutWindow];
      
      if ([NSApp runModalForWindow: aWelcomePanel] == NSRunAbortedResponse)
	{
	  [NSApp terminate: self];
	}
      
      type = ([[aWelcomePanel matrix] selectedRow] ? PantomimeFormatMaildir : PantomimeFormatMbox);
      
      RELEASE(aWelcomePanel);
      
      // We create the mailboxes directory for GNUMail
      if (![[NSFileManager defaultManager]
	     fileExistsAtPath: pathToLocalMailDir
	     isDirectory: &isDir])
	{
	  [[NSFileManager defaultManager] createDirectoryAtPath: pathToLocalMailDir
					  attributes: nil]; 
	}
      else
	{
	  // If it's a file
	  if (!isDir)
	    {
	      NSRunAlertPanel(_(@"Error!"),
			      _(@"%@ is a file and not a directory. Please remove that file before restarting GNUMail."),
			      _(@"OK"),
			      NULL,
			      NULL,
			      pathToLocalMailDir);
	      [NSApp terminate: self];
	    }
	}
      
      //
      // We create the following Mailboxes automatically, only if we need to:
      //
      // - Inbox  : for the newly received messages
      // - Sent   : for the messages that have been sent
      // - Trash  : for the messages we want to delete and transfer locally in IMAP
      // - Drafts : for un-sent messages
      //     
      aLocalStore = [[CWLocalStore alloc] initWithPath: pathToLocalMailDir];

      [aLocalStore createFolderWithName: @"Inbox"
		   type: type
		   contents: [NSData dataWithContentsOfFile: [NSString stringWithFormat: @"%@/Welcome", [[NSBundle mainBundle] resourcePath]]]];

      [aLocalStore createFolderWithName: @"Sent"
		   type: type
		   contents: nil];

      [aLocalStore createFolderWithName: @"Trash"
		   type: type
		   contents: nil];

      [aLocalStore createFolderWithName: @"Drafts"
		   type: type
		   contents: nil];

      if (type == PantomimeFormatMaildir)
	{
	  [[NSUserDefaults standardUserDefaults] setInteger: 1  forKey: @"UseMaildirMailboxFormat"];
	}

      //
      // We create a basic account with default preferences values just to get the user started.
      //
      theAccount = [[NSMutableDictionary alloc] init];
      

      //
      // We set the default PERSONAL values.
      //
      allValues = [[NSMutableDictionary alloc] init];
      [allValues setObject: _(@"Your name")           forKey: @"NAME"];
      [allValues setObject: _(@"Your E-Mail address") forKey: @"EMAILADDR"];
      [theAccount setObject: allValues  forKey: @"PERSONAL"];      
      RELEASE(allValues);
      
      //
      // MAILBOXES, we set the INBOX, SENT, .. for this account.
      //
      allValues = [[NSMutableDictionary alloc] init];
      [allValues setObject: [NSString stringWithFormat: @"local://%@", [pathToLocalMailDir stringByAppendingPathComponent: @"Inbox"]]   forKey: @"INBOXFOLDERNAME"];
      [allValues setObject: [NSString stringWithFormat: @"local://%@", [pathToLocalMailDir stringByAppendingPathComponent: @"Sent"]]    forKey: @"SENTFOLDERNAME"];
      [allValues setObject: [NSString stringWithFormat: @"local://%@", [pathToLocalMailDir stringByAppendingPathComponent: @"Drafts"]]  forKey: @"DRAFTSFOLDERNAME"];
      [allValues setObject: [NSString stringWithFormat: @"local://%@", [pathToLocalMailDir stringByAppendingPathComponent: @"Trash"]]   forKey: @"TRASHFOLDERNAME"];
      [theAccount setObject: allValues  forKey: @"MAILBOXES"];      
      RELEASE(allValues);
      
      //
      // SEND, we set the transport method to SMTP
      //
      allValues = [[NSMutableDictionary alloc] init];
      [allValues setObject: [NSNumber numberWithInt: 2]  forKey: @"TRANSPORT_METHOD"];
      [allValues setObject: @"smtp.server.com"  forKey: @"SMTP_HOST"];
      [theAccount setObject: allValues  forKey: @"SEND"];      
      RELEASE(allValues);
      
      //
      // We finally save the account's information
      //
      [[NSUserDefaults standardUserDefaults] setObject: [NSDictionary dictionaryWithObject: theAccount
								      forKey: @"General"]
					     forKey: @"ACCOUNTS"];
      RELEASE(theAccount);
      
      //
      // We create the basic set of shown headers and other preference values.
      //
      [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithObjects: @"Date", @"From", @"To", @"Cc", @"Subject", nil]
					     forKey: @"SHOWNHEADERS"];
      [[NSUserDefaults standardUserDefaults] setBool: YES  forKey: @"HIDE_DELETED_MESSAGES"];
      [[NSUserDefaults standardUserDefaults] setBool: YES  forKey: @"HIGHLIGHT_URL"];

      //
      // We add our "Inbox" folder to the list of folders to open.
      //
      [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithObject: [NSString stringWithFormat: @"local://%@", 
											    [pathToLocalMailDir stringByAppendingPathComponent: @"Inbox"]]]
					     forKey: @"FOLDERS_TO_OPEN"];
      
      mustShowPreferencesWindow = YES;
    } // if ( ![[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] )
  

  //
  // We initialize our store
  //
  if (!aLocalStore)
    {
      aLocalStore = [[CWLocalStore alloc] initWithPath: pathToLocalMailDir];
    }

  if (!aLocalStore)
    {
      NSString *aString;

#ifdef MACOSX
      aString = _(@"Could not open the Local Store.\nThat means GNUMail is not properly configured.\nTo fix this problem, do the following commands:\n\n%% mkdir ~/Library/GNUMail/Mailboxes\n%% touch ~/Library/GNUMail/Mailboxes/Inbox\n%% touch ~/Library/GNUMail/Mailboxes/Sent\n%% touch ~/Library/GNUMail/Mailboxes/Trash\n%% touch ~/Library/GNUMail/Mailboxes/Drafts\n\nand restart GNUMail after that! You can also remove the ~/Library/Preferences/com.collaboration-world.GNUMail.plist file instead of doing the commands mentioned above.");
#else
      aString = _(@"Could not open the Local Store.\nThat means GNUMail is not properly configured.\nTo fix this problem, do the following commands:\n\n%% mkdir ~/Mailboxes\n%% touch ~/Mailboxes/Inbox\n%% touch ~/Mailboxes/Sent\n%% touch ~/Mailboxes/Trash\n%% touch ~/Mailboxes/Drafts\n\nand restart GNUMail after that!");
#endif

      NSRunCriticalAlertPanel(_(@"Fatal error!"),
			      aString,
			      @"OK",
			      NULL,
			      NULL);
      
      [NSApp terminate: self];
    }

  [aLocalStore setDelegate: [TaskManager singleInstance]];

  // We got a valid Local store, let's add it to our list of open Store:s in the MailboxManagerController
  [[MailboxManagerController singleInstance] setStore: aLocalStore
					     name: @"GNUMAIL_LOCAL_STORE"
					     username: NSUserName()];
  
  [[MailboxManagerController singleInstance] reloadAllFolders];
  
  // Now we set the target to our items for creating/deleting/renaming mailboxes
  [create setTarget: [MailboxManagerController singleInstance]];
  [create setAction: @selector(create:)];
  [delete setTarget: [MailboxManagerController singleInstance]];
  [delete setAction: @selector(delete:)];
  [rename setTarget: [MailboxManagerController singleInstance]];
  [rename setAction: @selector(rename:)];
  
  // Sync with the user's defaults
  [[NSUserDefaults standardUserDefaults] synchronize];

  // We create our console
  [ConsoleWindowController singleInstance];

  // We load all our bundles
  [self _loadBundles];

  // We start our task manager and our global timer
  [[TaskManager singleInstance] run];

   //
  // We show of MailboxManager window, if we need to.
  // Under GNUstep, we MUST do this _before_ showing any MailWindow:s.
  //
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PreferredViewStyle"  default: GNUMailDrawerView] == GNUMailFloatingView)
    {
      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"OPEN_MAILBOXMANAGER_ON_STARTUP"])
	{
	  [self showMailboxManager: nil];
	}
    }
    
  // We show the Console window, if we need to.
  if ([[NSUserDefaults standardUserDefaults] boolForKey: @"OPEN_CONSOLE_ON_STARTUP"])
    {
      [self showConsoleWindow: nil];
    }  

  [Utilities restoreOpenFoldersForStore: aLocalStore];
  [self _connectToIMAPServers];
    
  // If we must show the Preferences window, we show it right now. That happens if for example,
  // we started GNUMail for the first time and the user has chosen to configure it.
  if (mustShowPreferencesWindow)
    {
      [self showPreferencesWindow: nil];
    }

  // We register our service
  [NSApp setServicesProvider: self];

  // We set up our initial list of incoming mail servers
  [self _updateGetNewMailMenuItems: nil];

  // We set up our initial list of filters for the menu
  [self _updateFilterMenuItems: nil];

  // We load all the items for the supported encodings (in Pantomime) in the encoding menu
  [self _updateTextEncodingsMenu: self];

  [self _updateVisibleColumns];

  [[MailboxManagerController singleInstance] restoreUnsentMessages];

  // We finally check for new mails on startup, if we need to.
#warning FIXME move once we are done initializing any specific IMAP store and do it right away for POP3 accounts
  [[TaskManager singleInstance] checkForNewMail: self  controller: nil];

  // We are done initing
  doneInit = YES;

  // If a window has requested to be on top, do it now.
  if (requestLastMailWindowOnTop != nil)
    {
      [requestLastMailWindowOnTop makeKeyAndOrderFront: self];
      [GNUMail setLastMailWindowOnTop: requestLastMailWindowOnTop];
      requestLastMailWindowOnTop = nil;
    }

}


//
// methods invoked by notifications
//
- (void) selectionInTextViewHasChanged: (id) sender
{
  if ([[sender object] selectedRange].length)
    {
      [enterSelection setAction: @selector(enterSelectionInFindPanel:)];
    }
  else
    {
      [enterSelection setAction: NULL];
    }
}


//
// access / mutation methods
//
+ (NSArray *) allBundles
{
  return allBundles;
}


+ (NSArray *) allMailWindows
{
  return allMailWindows;
}


+ (NSString *) currentWorkingPath
{
  return currentWorkingPath;
}


+ (void) setCurrentWorkingPath: (NSString *) thePath
{
  ASSIGN(currentWorkingPath, thePath);
}


+ (id) lastAddressTakerWindowOnTop
{
  return lastAddressTakerWindowOnTop;
}


+ (void) setLastAddressTakerWindowOnTop: (id) aWindow
{
  lastAddressTakerWindowOnTop = aWindow;
}


+ (id) lastMailWindowOnTop
{ 
  return lastMailWindowOnTop;
}


//
//
//
+ (void) setLastMailWindowOnTop: (id) aWindow
{
  lastMailWindowOnTop = aWindow;
}

//
//
//
- (NSMenu *) saveMenu
{
  return save;
}

//
// other methods
//
- (void) addItemToMenuFromTextAttachment: (NSTextAttachment *) theTextAttachment
{
  NSFileWrapper *aFileWrapper;
  ExtendedMenuItem *menuItem;

  aFileWrapper = [theTextAttachment fileWrapper];
 
  menuItem = [[ExtendedMenuItem alloc] initWithTitle: [aFileWrapper preferredFilename]
				       action: @selector(saveAttachment:)
				       keyEquivalent: @""];
  [menuItem setTextAttachment: theTextAttachment];
  [save addItem: menuItem];
  RELEASE(menuItem);
}


//
//
//
+ (void) addEditWindow: (id) theEditWindow
{
  if (allEditWindows && theEditWindow )
    {
      [allEditWindows addObject: theEditWindow];
    }
}


//
//
//
+ (void) addMailWindow: (id) theMailWindow
{
  if (theMailWindow)
    {
      [allMailWindows addObject: theMailWindow];
    }
}

//
// Used on OS X for AppleScript support. It is also used
// in the newMessageWithRecipient: userData: error: method
// defined in GNUMail+Services.
//
- (void) newMessageWithRecipient: (NSString *) aString
{
  CWInternetAddress *anInternetAddress;
  EditWindowController *aController;
  CWMessage *aMessage;
  
  // We create a new message and we set the recipient
  [aString retain];
  aMessage = [[CWMessage alloc] init];
  anInternetAddress = [[CWInternetAddress alloc] initWithString: aString];
  [aString retain];
  [anInternetAddress setType: PantomimeToRecipient];
  [aMessage addRecipient: anInternetAddress];
  RELEASE(anInternetAddress);
  
  // We create our controller and we show the window
  aController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
  [allEditWindowControllers addObject:aController];
  
  if (aController)
    {
      [[aController window] setTitle: _(@"New message...")];
      [aController setMessage: aMessage];
      [aController setShowCc: NO];
      [aController setAccountName: nil];
      
      // If we just got launched, as to to be put on top after we are done initing
      if (!doneInit)
	{
	  requestLastMailWindowOnTop = [aController window];
	}
      else
	{
	  [[aController window] makeKeyAndOrderFront: self];
	}
    }
  
  RELEASE(aMessage);
}


//
//
//
+ (void) removeEditWindow: (id) theEditWindow
{
  if (allEditWindows && theEditWindow )
    {
      unsigned i;
    
      for (i = 0; i < [allEditWindowControllers count]; i++)
        {
          if ([[allEditWindowControllers objectAtIndex: i] window] == theEditWindow)
            [allEditWindowControllers removeObjectAtIndex: i];
        }
      [allEditWindows removeObject: theEditWindow];
    }
}


//
//
//
+ (void) removeMailWindow: (id) theMailWindow
{
  if (theMailWindow)
    {
      unsigned i;
    
      for (i = 0; i < [allMailWindowControllers count]; i++)
        {
          if ([[allMailWindowControllers objectAtIndex: i] window] == theMailWindow)
            [allMailWindowControllers removeObjectAtIndex: i];
        }
      [allMailWindows removeObject: theMailWindow];
    }
}

@end

//
// Scripting support; still experimental code.
//
#ifdef MACOSX
@implementation GNUMail (KeyValueCoding)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
  return [key isEqualToString:@"messageCompositions"];
}

// accessors for to-many relationships:
-(NSMutableArray*)messageCompositions
{
  return _messageCompositions;
}

-(void)setMessageCompositions: (NSMutableArray*)messageCompositions
{
  [_messageCompositions setArray: messageCompositions];
}


//
// Accessors for to-many relationships (See NSScriptKeyValueCoding.h)
//
- (void) addInMessageCompositions: (MessageComposition *) object
{
  [self insertInMessageCompositions: object atIndex: [_messageCompositions count]];
}

- (void) insertInMessageCompositions: (MessageComposition *) object
{
  [self insertInMessageCompositions: object atIndex: [_messageCompositions count]];
}

- (void) insertInMessageCompositions: (MessageComposition *) object atIndex: (NSUInteger) anIndex
{
  [_messageCompositions insertObject: object atIndex: anIndex];
  
}

- (void) replaceInMessageCompositions: (MessageComposition *) object atIndex: (NSUInteger) anIndex
{
  [_messageCompositions replaceObjectAtIndex: anIndex withObject: object];
}

- (void) removeFromMessageCompositionsAtIndex: (NSUInteger) anIndex
{
  [_messageCompositions removeObjectAtIndex: anIndex];
}

- (id) valueInMessageCompositionsAtIndex: (NSUInteger) anIndex
{
  return ([_messageCompositions objectAtIndex: anIndex]);
}

@end
#endif


//
// Private methods
//
@implementation GNUMail (Private)

//
// Tries to load the property page. Returns NO in case of a failure
// or if there's no update available.
//
- (BOOL) _checkForUpdate
{
  BOOL checked;

  checked = NO;
  
  NS_DURING
    {
      NSString *aString;
      NSData *aData;
      NSURL *aURL;

      aURL = [NSURL URLWithString: PROPERTY_URL];
      
      // Fetch the property list from PROPERTY_URL
      aData = [aURL resourceDataUsingCache: NO];

      // Decode the property list
      aString = [[NSString alloc] initWithData: aData
				   encoding: NSUTF8StringEncoding];
      
      // Check the content
      checked = [self _checkDictionary: [aString propertyList]];
      RELEASE(aString);
    }
  NS_HANDLER
    {
      // Something went wrong, eg. page unavailable
      [localException raise];
      checked = NO;
    }
  NS_ENDHANDLER
  
  return checked;
}


//
// Retrieves the current (running application) and the latest
// (from the web) version numbers
//
- (BOOL) _checkDictionary: (NSDictionary *) theDictionary
{
  NSString *latestVersion;
  NSComparisonResult result;
  
  //
  // If dictionary is empty, raise an exception and return
  //
  if (!theDictionary)
    {
      [NSException raise: @"UpdateException"
                  format: @"%@",
                   _(@"Unable to retrieve software information.")];
      return NO;
    }
  
  //
  // Get the latest version number as posted on "the net"
  //
  latestVersion = [theDictionary objectForKey: [[NSProcessInfo processInfo] processName]];
  
  //
  // Now compare them 
  //
  result = CompareVersion(GNUMailVersion(), latestVersion);
  
  if (result == NSOrderedDescending || result == NSOrderedSame)
    {
      return NO;
    }

  //
  // Cool, a new version...
  //
  [self _newVersionAvailable: latestVersion];
  
  return YES;
}


//
//
//
- (void) _connectToIMAPServers
{ 
  NSDictionary *allAccounts, *allValues;
  NSArray *allKeys;
  NSUInteger i;
  
  allAccounts = [Utilities allEnabledAccounts];
  allKeys = [allAccounts allKeys];

  for (i = 0; i < [allKeys count]; i++)
    {
      allValues = [[allAccounts objectForKey: [allKeys objectAtIndex: i]] objectForKey: @"RECEIVE"];
      
      if ([[allValues objectForKey: @"SERVERTYPE"] intValue] == IMAP)
	{
	  CWURLName *theURLName;
	  
	  theURLName = [[CWURLName alloc] initWithString: [NSString stringWithFormat: @"imap://%@@%@/", 
								    [allValues objectForKey: @"USERNAME"],
								    [allValues objectForKey: @"SERVERNAME"]]];

	  [[MailboxManagerController singleInstance] storeForURLName: theURLName];
	  RELEASE(theURLName);
	}
    }
}


//
// Method used to load all bundles in all domains.
// FIXME: Offer a way to the user to specify a list of bundles
//        that he/she DOES NOT want to load automatically.
//
- (void) _loadBundles
{
  NSFileManager *aFileManager;
  NSMutableArray *allPaths;
  NSMutableArray *allBundlePaths;
  NSArray *appPlugins;
  NSArray *allFiles;
  NSString *aPath;
  NSUInteger i, j;

  aFileManager = [NSFileManager defaultManager];
  
  allPaths =  [[NSMutableArray alloc] initWithArray: NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
											 NSLocalDomainMask|
											 NSNetworkDomainMask|
											 NSSystemDomainMask|
											 NSUserDomainMask,
											 YES)];
  appPlugins = [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" inDirectory:@"../PlugIns"];
  
  allBundlePaths =  [[NSMutableArray alloc] initWithArray:appPlugins];

  for (i = 0; i < [allPaths count]; i++)
    {
      // We remove any potential duplicate paths in our allPaths array.
      [allPaths removeObject: [allPaths objectAtIndex: i] inRange: NSMakeRange(i+1, [allPaths count]-i-1)];
      
      aPath = [[allPaths objectAtIndex: i] stringByAppendingPathComponent:@"GNUMail"];
      allFiles = [aFileManager directoryContentsAtPath: aPath];
      
      for (j = 0; j < [allFiles count]; j++)
	{
	  NSString *aString;
	  
	  aString = [allFiles objectAtIndex: j];
   
	  // If we found a bundle, let's load it!
	  if ([[aString pathExtension] isEqualToString: @"bundle"])
	    {
	      NSString *path;
	      
	      path = [aPath stringByAppendingPathComponent:aString],
              [allBundlePaths addObject:path];
            }
        }
    }
  [allPaths release];
  
  for (i = 0; i < [allBundlePaths count]; i++)
    {
      id<GNUMailBundle> aModule;
      NSBundle *aBundle;
      NSString *path;
      
      path = [allBundlePaths objectAtIndex: i];
      aBundle = [NSBundle bundleWithPath: path];
	      
      if (aBundle)
        {
          Class aClass;
          
          aClass = [aBundle principalClass];
          
          // We ensure our bundle is really a GNUMail bundle.
          if (![aClass conformsToProtocol: @protocol(GNUMailBundle)])
            {
              continue;
            }
          
          aModule = [aClass singleInstance];
          
          if (aModule)
            {
              [aModule setOwner: self];
              [allBundles addObject: aModule];
              ADD_CONSOLE_MESSAGE(_(@"Loaded %@ bundle at path %@"), [path lastPathComponent], path);
            }
          else
            {
              ADD_CONSOLE_MESSAGE((@"Failed to initialize bundle at path %@"), path);
            }
        }
      else
        {
          ADD_CONSOLE_MESSAGE(_(@"Error loading bundle at path %@"), path);
        }
    }
  [allBundlePaths release];
}


//
//
//
- (void) _makeFilter: (int) theSource
{
  id aFilteringModule, aWindowController;
  FilterCriteria *aCriteria;
  CWMessage *theMessage;
  NSString *aString;
  Filter *aFilter;
  NSRange aRange;
  NSInteger filterIndex;

  aWindowController = [[GNUMail lastMailWindowOnTop] delegate];
  theMessage = [aWindowController selectedMessage];

  aCriteria = AUTORELEASE([[FilterCriteria alloc] init]);
  aFilter = AUTORELEASE([[Filter alloc] init]);

#warning add support for merging one to three messages into one rule
  
  switch (theSource)
    {
    case EXPERT:
      aString = [[theMessage allHeaders] objectForKey: @"List-Id"];
      
      if (!aString)
	{
	  NSBeep();
	  return;
	}
      
      aRange = [aString rangeOfString: @"<"  options: NSBackwardsSearch];

      if (aRange.length)
	{
	  aString = [aString substringWithRange: NSMakeRange(aRange.location+1,[aString length]-aRange.location-2)];
	}
      else
	{
	  NSBeep();
	  return;
	}

      [aCriteria setCriteriaString: aString];
      [aCriteria setCriteriaSource: EXPERT];
      [aCriteria setCriteriaHeaders: [NSArray arrayWithObject: @"List-Id"]];
      [aFilter setDescription: [NSString stringWithFormat: _(@"%@ mailing list"), aString]];
      break;

    case FROM:
      [aCriteria setCriteriaString: [[theMessage from] address]];
      [aCriteria setCriteriaSource: FROM];
      [aFilter setDescription: [[theMessage from] personal]];
      break;

    case TO:
      {
        NSArray *recps;
        CWInternetAddress *ia;
        NSUInteger i;
        
        recps = [theMessage recipients];
        i = 0;
        ia = nil;
        while (i < [recps count] && [ia type] != PantomimeToRecipient)
          ia = [recps objectAtIndex:i++];
        if (ia)
          {
            NSString *desc;
          
            [aCriteria setCriteriaString: [ia address]];
            [aCriteria setCriteriaSource: TO];
            desc = [ia personal];
            if (!desc)
              desc = [ia address];
            [aFilter setDescription: desc];
          }
      }
      break;

    case CC:
      {
        NSArray *recps;
        CWInternetAddress *ia;
        NSUInteger i;
        
        recps = [theMessage recipients];
        i = 0;
        ia = nil;
        while (i < [recps count] && [ia type] != PantomimeCcRecipient)
          ia = [recps objectAtIndex:i++];
        if (ia)
          {
            NSString *desc;

            [aCriteria setCriteriaString: [ia address]];
            [aCriteria setCriteriaSource: CC];
            desc = [ia personal];
            if (!desc)
              desc = [ia address];
            [aFilter setDescription: desc];
          }
      }
      break;
      
    case SUBJECT:
    default:
      [aCriteria setCriteriaString: [theMessage subject]];
      [aCriteria setCriteriaSource: SUBJECT];
      [aFilter setDescription: [theMessage subject]];
    }

  [aCriteria setCriteriaCondition: AND];
  [aFilter setCriterias: [NSArray arrayWithObjects: aCriteria,
				  AUTORELEASE([[FilterCriteria alloc] init]), 
				  AUTORELEASE([[FilterCriteria alloc] init]), nil]];

  [[FilterManager singleInstance] addFilter: aFilter];
  
  aFilteringModule = [NSBundle instanceForBundleWithName: @"Filtering"];
  filterIndex = [[[FilterManager singleInstance] filters] count]-1;
  
  if ([[aFilteringModule performSelector: @selector(editFilter:)
			 withObject: [NSNumber numberWithInt: filterIndex]] intValue] == NSRunAbortedResponse)
    {
      [[FilterManager singleInstance] removeFilter: aFilter];
      [aFilteringModule performSelector: @selector(updateView)];
    }
}


//
// Opens the 'new version available' dialog and offers to
// download if possible (read: on Mac OS X)
//
- (void) _newVersionAvailable: (NSString *) theVersion
{
  NSString *aURL;         // The URL where to get it from
  NSString *firstButton;  // Default (OK) button
  NSString *secondButton; // Alternate (Cancel) button
  NSString *aMessage;     // The message we display to the user.
  
  int result;
  
  aMessage = [NSString stringWithFormat: _(@"The latest version of GNUMail is %@.\n"),
		       theVersion];
  
  //
  // GNUstep's NSWorkspace doesn't react to -openURL:
  // but MACOSX does...
  //
#ifdef MACOSX
  aMessage = [aMessage stringByAppendingString: _(@"Would you like to download the new version now?")];
  aURL = DOWNLOAD_URL;
  firstButton = _(@"Update now");
  secondButton = _(@"Update later");
#else
  aMessage = [aMessage stringByAppendingFormat: _(@"Check < %@ > for more details."), GNUMailBaseURL()];
  aURL = nil;
  firstButton = _(@"OK");
  secondButton = NULL;
#endif
  
  result = NSRunInformationalAlertPanel(_(@"A new version of GNUMail is now available."),
					aMessage,
					firstButton,
					secondButton,
					NULL);
  
  if (result == NSAlertDefaultReturn)
    {
      if (aURL)
	{
	  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: aURL]];
	}
    }
}


//
//
//
- (void) _removeAllItemsFromMenu: (NSMenu *) theMenu
{
  NSInteger i;
  
  for (i = ([theMenu numberOfItems] - 1); i >= 0; i--)
    {
      [theMenu removeItemAtIndex: i];
    }
}


//
//
//
- (void) _savePanelDidEnd: (NSSavePanel *) theSheet
	       returnCode: (int) returnCode
	      contextInfo: (void  *) contextInfo
{
  
  NSString *aFilename;
  NSData *aData;

  aFilename = [theSheet filename];
  aData = (NSData *)contextInfo;

  // if successful, save file under designated name
  if (returnCode == NSAlertDefaultReturn)
    {
      if (![aData writeToFile: aFilename atomically: YES])
        {
	  NSBeep();
        }
      else
	{
	  [[NSFileManager defaultManager] enforceMode: 0600  atPath: aFilename];
	}

      [GNUMail setCurrentWorkingPath: [aFilename stringByDeletingLastPathComponent]];
    }
  
  RELEASE(aData);
}


//
//
//
- (void) _updateFilterMenuItems: (id) sender
{
  BOOL isDir;
  
  if ([[NSFileManager defaultManager] fileExistsAtPath: PathToFilters()
				      isDirectory: &isDir] &&
      !isDir)
    {
      FilterManager *aFilterManager;
      NSMenuItem *aMenuItem;
      NSUInteger i;
  
      // We first remove all our items in the current menu
      [self _removeAllItemsFromMenu: filters];
    
      aFilterManager = [FilterManager singleInstance];
      
      // Our "All" menu item
      aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"All")
				      action: @selector(applyManualFilter:)
				      keyEquivalent: @""];
      [aMenuItem setTag: -1];
      [filters addItem: aMenuItem];
      RELEASE(aMenuItem);

      for (i = 0; i < [[aFilterManager filters] count]; i++)
	{
	  Filter *aFilter;
	  
	  aFilter = [[aFilterManager filters] objectAtIndex: i];
	  
	  aMenuItem = [[NSMenuItem alloc] initWithTitle: [aFilter description]
					  action: @selector(applyManualFilter:)
					  keyEquivalent: @""];
	  [aMenuItem setTag: i];
	  [filters addItem: aMenuItem];
	  RELEASE(aMenuItem);
	}
    }
}


//
//
//
- (void) _updateGetNewMailMenuItems: (id) sender
{
  NSDictionary *allValues;
  NSMenuItem *aMenuItem;
  NSArray *allKeys;
  NSString *aKey;
  NSUInteger i;
  
  // We first remove all our items in the current menu
  [self _removeAllItemsFromMenu: incomingMailServers];
  
  // Our "All" menu item
  aMenuItem = [[NSMenuItem alloc] initWithTitle: _(@"All")
				  action: @selector(getNewMessages:)
				  keyEquivalent: @"N"];
  [aMenuItem setTarget: self];
  [aMenuItem setTag: -1];
  [incomingMailServers addItem: aMenuItem];
  RELEASE(aMenuItem);

  // We sort the array to be sure to keep the order.
  allKeys = [[[Utilities allEnabledAccounts] allKeys]
	      sortedArrayUsingSelector: @selector(compare:)];

  for (i = 0; i < [allKeys count]; i++)
    {
      aKey = [allKeys objectAtIndex: i];
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: aKey]
		    objectForKey: @"RECEIVE"];
      
      // We only consider our POP3 and UNIX receiving accounts - both
      // being NOT set to never check mails
      if ((![allValues objectForKey: @"SERVERTYPE"] ||
	   [[allValues objectForKey: @"SERVERTYPE"] intValue] == POP3 || 
	   [[allValues objectForKey: @"SERVERTYPE"] intValue] == UNIX) &&
	  [[allValues objectForKey: @"RETRIEVEMETHOD"] intValue] != NEVER)
	{
	  aMenuItem = [[NSMenuItem alloc] initWithTitle: aKey
					  action: @selector(getNewMessages:)
					  keyEquivalent: @""];
	  [aMenuItem setTarget: self];
	  [aMenuItem setTag: i];
	  [incomingMailServers addItem: aMenuItem];
	  RELEASE(aMenuItem);
	}
    }
}


//
//
//
- (void) _updateTextEncodingsMenu: (id) sender
{
  NSMutableArray *aMutableArray;
  NSMenuItem *item;
  NSUInteger i;

  [self _removeAllItemsFromMenu: textEncodings];
  
  item = [[NSMenuItem alloc] initWithTitle: _(@"Default")
			     action: @selector(changeTextEncoding:)
			     keyEquivalent: @""];
  [item setTag: -1];
  [textEncodings addItem: item];
  RELEASE(item);

  aMutableArray = [[NSMutableArray alloc] init];
  [aMutableArray addObjectsFromArray: [[CWCharset allCharsets] allValues]];
  [aMutableArray sortUsingSelector: @selector(compare:)];

  for (i = 0; i < [aMutableArray count]; i++)
    {
      item = [[NSMenuItem alloc] initWithTitle: [aMutableArray objectAtIndex: i]
				 action: @selector(changeTextEncoding:)
				 keyEquivalent: @""];
      [item setTag: i];
      [textEncodings addItem: item];
      RELEASE(item);
    }

  RELEASE(aMutableArray);
}


//
//
//
- (void) _updateVisibleColumns
{
  NSArray *theColumns;
  NSUInteger i;

  theColumns = [[NSUserDefaults standardUserDefaults] objectForKey: @"SHOWNTABLECOLUMNS"];
  
  if (theColumns)
    {
      for (i = 0; i < [theColumns count]; i++)
	{
	  NSString *column;
	  
	  column = [theColumns objectAtIndex: i];
	  
	  if ([column isEqualToString: @"Date"])
	    {
	      [[columns itemWithTag: GNUMailDateColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"Flagged"])
	    {
	      [[columns itemWithTag: GNUMailFlagsColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"From"])
	    {
	      [[columns itemWithTag: GNUMailFromColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"Number"] )
	    {
	      [[columns itemWithTag: GNUMailNumberColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"Size"])
	    {
	      [[columns itemWithTag: GNUMailSizeColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"Status"])
	    {
	      [[columns itemWithTag: GNUMailStatusColumn] setState: NSOnState];
	    }
	  else if ([column isEqualToString: @"Subject"])
	    {
	      [[columns itemWithTag: GNUMailSubjectColumn] setState: NSOnState];
	    }
	}
    }
  else
    {
      for (i = 0; i < [columns numberOfItems]; i++)
	{
	  [[columns itemAtIndex: i] setState: NSOnState];
	}
    }
}

@end
