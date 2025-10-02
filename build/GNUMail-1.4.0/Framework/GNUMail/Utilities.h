/*
**  Utilities.h
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**  Copyright (C) 2017      Riccardo Mottola
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
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_Utilities
#define _GNUMail_H_Utilities

#import <AppKit/AppKit.h>

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWStore.h>

@class FolderNode;
@class FolderNodePopUpItem;
@class CWFolder;
@class CWMessage;
@class CWMimeMultipart;
@class CWPart;
@class CWURLName;
@class NSView;


//
// C functions
//
NSComparisonResult CompareVersion(NSString *theCurrentVersion, NSString *theLatestVersion);
NSString *GNUMailTemporaryDirectory();
NSString *GNUMailUserLibraryPath();
NSString *GNUMailVersion();
NSString *GNUMailBaseURL();
NSString *GNUMailCopyrightInfo();

//
//
//
@interface Utilities: NSObject

+ (NSString *) encryptPassword: (NSString *) thePassword
                       withKey: (NSString *) theKey;
+ (NSString *) decryptPassword: (NSString *) thePassword
                       withKey: (NSString *) theKey;


//
//
//
+ (void) loadAccountsInPopUpButton: (NSPopUpButton *) thePopUpButton 
                            select: (NSString *) theAccount;
+ (void) loadTransportMethodsInPopUpButton: (NSPopUpButton *) thePopUpButton;


//
//
//
+ (NSString *) accountNameForFolder: (CWFolder *) theFolder;
+ (NSString *) accountNameForMessage: (CWMessage *) theMessage;

+ (NSString *) accountNameForServerName: (NSString *) theServerName
                               username: (NSString *) theUsername;

+ (NSDictionary *) allEnabledAccounts;

+ (NSString *) defaultAccountName;

+ (id) windowForFolderName: (NSString *) theName
                     store: (id<CWStore>) theStore;

+ (FolderNode *) folderNodeForPath: (NSString *) thePath
                             using: (FolderNode *) rootNode
                         separator: (unsigned char) theSeparator;

+ (FolderNode *) folderNodesFromFolders: (NSEnumerator *) theFolders
                              separator: (unsigned char) theSeparator;


+ (NSString *) completePathForFolderNode: (FolderNode *) theFolderNode
                               separator: (unsigned char) theSeparator;

+ (NSString *) pathOfFolderFromFolderNode: (FolderNode *) theFolderNode
                                separator: (unsigned char) theSeparator;

+ (NSString *) flattenPathFromString: (NSString *) theString
                           separator: (unsigned char) theSeparator;


+ (NSString *) storeKeyForFolderNode: (FolderNode *) theFolderNode
                          serverName: (NSString **) theServerName
                            username: (NSString **) theUsername;

+ (BOOL) URLWithString: (NSString *) theString
           matchFolder: (CWFolder *) theFolder;

+ (BOOL) stringValueOfURLName: (NSString *) theString
                    isEqualTo: (NSString *) theName;
+ (NSString *) stringValueOfURLNameFromFolder: (CWFolder *) theFolder;
+ (NSString *) stringValueOfURLNameFromFolderNode: (FolderNode *) theFolderNode
				       serverName: (NSString *) theServerName
                                         username: (NSString *) theUsername;

+ (FolderNode *) initializeFolderNodesUsingAccounts: (NSDictionary *) theAccounts;

+ (void) addItemsToMenu: (NSMenu *) theMenu
                    tag: (int) theTag
		 action: (SEL) theAction
            folderNodes: (FolderNode *) theFolderNodes;

+ (void) addItemsToPopUpButton: (NSPopUpButton *) thePopUpButton
              usingFolderNodes: (FolderNode *) theFolderNodes;

+ (void) addItem: (FolderNode *) theFolderNode
             tag: (int) theTag
	  action: (SEL) theAction
          toMenu: (NSMenu *) theMenu;

+ (void) addItem: (FolderNode *) theFolderNode
	   level: (int) theLevel
             tag: (int) theTag
	  action: (SEL) theAction
          toMenu: (NSMenu *) theMenu;

+ (FolderNodePopUpItem *) folderNodePopUpItemForFolderNode: (FolderNode *) theFolderNode
                                               popUpButton: (NSPopUpButton *) thePopUpButton;

+ (FolderNodePopUpItem *) folderNodePopUpItemForURLNameAsString: (NSString *) theString
                                               usingFolderNodes: (FolderNode *) theFolderNodes
                                                    popUpButton: (NSPopUpButton *) thePopUpButton
                                                        account: (NSString *) theAccountName;

+ (NSString *) passwordForKey: (id) theKey
                         type: (int) theType
                       prompt: (BOOL) aBOOL;

+ (NSMutableDictionary *) passwordCache;

+ (void) replyToMessage: (CWMessage *) theMessage
                 folder: (CWFolder *) theFolder
                   mode: (PantomimeReplyMode) theMode;

+ (void) forwardMessage: (CWMessage *) theMessage
                   mode: (PantomimeForwardMode) theMode;

+ (void) showMessage: (CWMessage *) theMessage
              target: (NSTextView *) theTextView
      showAllHeaders: (BOOL) headersFlag;

+ (void) showMessageRawSource: (CWMessage *)theMessage
                       target: (NSTextView *)theTextView;

+ (void) clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	        inRect: (NSRect) cellFrame
               atIndex: (unsigned) charIndex
                sender: (id) sender;

+ (void) restoreOpenFoldersForStore: (id) theStore;

@end

#endif // _GNUMail_H_Utilities
