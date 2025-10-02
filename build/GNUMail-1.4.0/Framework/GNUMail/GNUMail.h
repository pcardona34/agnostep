/*
**  GNUMail.h
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2018-2023 Riccardo Mottola
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_GNUMail
#define _GNUMail_H_GNUMail

#import <AppKit/AppKit.h>

@class AddressBookController;
@class CWMessage;
@class CWURLName;
@class EditWindowController;
@class MessageComposition;

@interface GNUMail : NSObject
{
  // Outlets
  IBOutlet NSMenu *drafts;
#ifdef MACOSX
  IBOutlet NSMenu *dock;
#endif
  IBOutlet NSMenu *columns;
  IBOutlet NSMenu *edit;
  IBOutlet NSMenu *filters;
  IBOutlet NSMenu *find;
  IBOutlet NSMenu *forward;
  IBOutlet NSMenu *incomingMailServers;
  IBOutlet NSMenu *info;
  IBOutlet NSMenu *mailbox;
  IBOutlet NSMenu *menu;
  IBOutlet NSMenu *message;
  IBOutlet NSMenu *messageFilter;
  IBOutlet NSMenu *reply;
  IBOutlet NSMenu *save;
  IBOutlet NSMenu *services;
  IBOutlet NSMenu *sorting;
  IBOutlet NSMenu *textEncodings;
  IBOutlet NSMenu *view;
  IBOutlet NSMenu *windows;
  
  IBOutlet NSMenuItem *create;
  IBOutlet NSMenuItem *customizeToolbar;
  IBOutlet NSMenuItem *delete;
  IBOutlet NSMenuItem *showOrHideToolbar;
  IBOutlet NSMenuItem *enterSelection;
  IBOutlet NSMenuItem *rename;
  IBOutlet NSMenuItem *selectAllMessagesInThread;
  IBOutlet NSMenuItem *threadOrUnthreadMessages;

  //
  // For scripting on Mac OS X. Simple instance variable for to-many relationships.
  //
#ifdef MACOSX
  NSMutableArray *_messageCompositions;
#endif
}

- (id) init;

//
// action methods
//
- (IBAction) addSenderToAddressBook: (id) sender;

- (IBAction) applyManualFilter: (id) sender;

- (IBAction) changeTextEncoding: (id) sender;

- (IBAction) checkForUpdates: (id) sender;

- (IBAction) close: (id) sender;

- (IBAction) compactMailbox: (id) sender;

- (IBAction) composeMessage: (id) sender;

- (IBAction) copy: (id) sender;
- (IBAction) customizeToolbar: (id) sender;
- (IBAction) cut: (id) sender;

- (IBAction) enterSelectionInFindPanel: (id) sender;

- (IBAction) findNext: (id) sender;
- (IBAction) findPrevious: (id) sender;

- (IBAction) forwardMessage: (id) sender;
- (IBAction) getNewMessages: (id) sender;

- (IBAction) importMailboxes: (id) sender;

- (IBAction) makeFilterFromListId: (id) sender;
- (IBAction) makeFilterFromSender: (id) sender;
- (IBAction) makeFilterFromTo: (id) sender;
- (IBAction) makeFilterFromCc: (id) sender;
- (IBAction) makeFilterFromSubject: (id) sender;

- (IBAction) nextUnreadMessage: (id) sender;

- (IBAction) newViewerWindow: (id) sender;

- (IBAction) paste: (id) sender;

- (IBAction) previousUnreadMessage: (id) sender;

- (IBAction) printMessage: (id) sender;

- (IBAction) redirectMessage: (id) sender;

- (IBAction) replyToMessage: (id) sender;

- (IBAction) restoreDraft: (id) sender;

- (IBAction) saveAllAttachments: (id) sender;
- (IBAction) saveAttachment: (id) sender;
- (IBAction) saveInDrafts: (id) sender;
- (IBAction) saveTextFromMessage: (id) sender;

- (IBAction) selectAllMessagesInThread: (id) sender;

- (IBAction) sortByNumber: (id) sender;
- (IBAction) sortByDate: (id) sender;
- (IBAction) sortByName: (id) sender;
- (IBAction) sortBySubject: (id) sender;
- (IBAction) sortBySize: (id) sender;

- (IBAction) showAboutPanel: (id) sender;
- (IBAction) showAddressBook: (id) sender;
- (IBAction) showAllHeaders: (id) sender;
- (IBAction) showConsoleWindow: (id) sender;
- (IBAction) showFindWindow: (id) sender;
- (IBAction) showMailboxInspectorPanel: (id) sender;
- (IBAction) showMailboxManager: (id) sender;

- (IBAction) showOrHideDeletedMessages: (id) sender;
- (IBAction) showOrHideReadMessages: (id) sender;
- (IBAction) showOrHideTableColumns: (id) sender;
- (IBAction) showOrHideToolbar: (id) sender;

- (IBAction) showPreferencesWindow: (id) sender;
- (IBAction) showRawSource: (id) sender;

- (IBAction) threadOrUnthreadMessages: (id) sender;


//
// methods invoked by notifications
//
- (void) selectionInTextViewHasChanged: (id) sender;


//
// access / mutation methods
//
+ (NSArray *) allBundles;

+ (NSArray *) allMailWindows;

+ (NSString *) currentWorkingPath;
+ (void) setCurrentWorkingPath: (NSString *) thePath;

+ (id) lastAddressTakerWindowOnTop;
+ (void) setLastAddressTakerWindowOnTop: (id) aWindow;

+ (id) lastMailWindowOnTop;
+ (void) setLastMailWindowOnTop: (id) aWindow;

- (NSMenu *) saveMenu;

//
// other methods
// 
- (void) addItemToMenuFromTextAttachment: (NSTextAttachment *) theTextAttachment;

+ (void) addEditWindow: (id) theEditWindow;
+ (void) addMailWindow: (id) theMailWindow;

- (void) newMessageWithRecipient: (NSString *) aString;

+ (void) removeEditWindow: (id) theEditWindow;
+ (void) removeMailWindow: (id) theMailWindow;

@end


//
// Experimental code used for Mac OS X scripting support.
//
#ifdef MACOSX

@interface GNUMail (KeyValueCoding)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;
- (NSMutableArray*)messageCompositions;
- (void)setMessageCompositions: (NSMutableArray*)messageCompositions;
- (void) addInMessageCompositions: (MessageComposition *)object;
- (void) insertInMessageCompositions: (MessageComposition *) object;
- (void) insertInMessageCompositions: (MessageComposition *) object atIndex: (NSUInteger) anIndex;
- (void) replaceInMessageCompositions: (MessageComposition *) object atIndex: (NSUInteger) anIndex;
- (void) removeFromMessageCompositionsAtIndex: (NSUInteger) anIndex;
- (id) valueInMessageCompositionsAtIndex: (NSUInteger) anIndex;

@end
#endif

#endif // _GNUMail_H_GNUMail
