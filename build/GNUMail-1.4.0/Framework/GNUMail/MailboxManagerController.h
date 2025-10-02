/*
**  MailboxManagerController.h
**
**  Copyright (C) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2018      Riccardo Mottola
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

#ifndef _GNUMail_H_MailboxManagerController
#define _GNUMail_H_MailboxManagerController

#import <AppKit/AppKit.h>

@class CWFlags;
@class CWFolder;
@class CWIMAPFolder;
@class CWIMAPStore;
@class CWMessage;
@class CWStore;
@class CWURLName;
@class EditWindowController;
@class ExtendedOutlineView;
@class FolderNode;
@class MailboxManagerCache;

@interface MailboxManagerController: NSWindowController
{
  // Outlets - PS: _no_ view under OS X, only the model/controller.
  // The view is actually owned by the MailWindowController under OS X.
  // FIXME needs to be adapted when supporting Floating and Drawer
  IBOutlet NSScrollView *scrollView;

  IBOutlet ExtendedOutlineView *outlineView;
  IBOutlet NSMenu *menu;

  // Private ivars
  @private
    MailboxManagerCache *_cache;
    NSMutableArray *_allFolders;
    FolderNode *localNodes;
    NSMutableDictionary *allStores;

    NSImage *_open_folder;
    NSImage *_sort_right;
    NSImage *_sort_down;
    NSImage *_drafts;
    NSImage *_inbox;
    NSImage *_sent;
    NSImage *_trash;
    int _font_size;
}

//
// delegate methods
//
- (void) windowDidLoad;


//
// action methods
//
- (IBAction) changeSize: (id) sender;
- (IBAction) open: (id) sender;
- (IBAction) create: (id) sender;
- (IBAction) delete: (id) sender;
- (IBAction) rename: (id) sender;
- (IBAction) takeOffline: (id) sender;
- (IBAction) setMailboxAs: (id) sender;


//
// access/mutation methods
//
- (NSOutlineView *) outlineView;

- (id) storeForFolderNode: (FolderNode *) theFolderNode;

- (id) storeForName: (NSString *) theName
           username: (NSString *) theUsername;

- (id) storeForURLName: (CWURLName *) theURLName;
- (id) folderForURLName: (CWURLName *) theURLName;

- (void) setStore: (id) theStore
             name: (NSString *) theName
         username: (NSString *) theUsername;

- (void) closeWindowsForStore: (id) theStore;

- (MailboxManagerCache *) cache;

- (void) addMessage: (NSData *) theMessage
           toFolder: (CWURLName *) theURLName;

- (CWMessage *) messageFromDraftsFolder;

- (NSDictionary *) allStores;

- (NSMenu *) outlineView: (NSOutlineView *) aOutlineView
      contextMenuForItem: (id) item;

- (void) setCurrentOutlineView: (id) theOutlineView;

- (void) updateFolderInformation: (NSDictionary *) theInformation;

- (void) updateOutlineViewForFolder: (NSString *) theFolder
			      store: (NSString *) theStore
                           username: (NSString *) theUsername
                         controller: (id) theController;
//
// class methods
//
+ (id) singleInstance;


//
// Other methods
//
- (void) panic: (NSData *) theData
        folder: (NSString *) theFolder;

- (void) deleteSentMessageWithID: (NSString *) theID;
- (void) restoreUnsentMessages;
- (void) saveUnsentMessage: (NSData *) theMessage
                    withID: (NSString *) theID;

- (void) openFolderWithURLName: (CWURLName *) theURLName
                        sender: (id) theSender;

- (void) reloadAllFolders;

- (void) transferMessage: (NSData *) theMessage
		   flags: (CWFlags *) theFlags
                  folder: (CWFolder *) theFolder;

- (void) transferMessages: (NSArray *) theMessages
	        fromStore: (id) theSourceStore
	       fromFolder: (id) theSourceFolder
	          toStore: (id) theDestinationStore
	 	 toFolder: (id) theDestinationFolder
                operation: (int) theOperation;

- (void) reloadFoldersForStore: (id) theStore
                       folders: (NSEnumerator *) theFolders;

- (FolderNode *) storeFolderNodeForName: (NSString *) theName;

- (void) saveMessageInDraftsFolderForController: (EditWindowController *) theEditWindowController;

@end

#endif // _GNUMail_H_MailboxManagerController
