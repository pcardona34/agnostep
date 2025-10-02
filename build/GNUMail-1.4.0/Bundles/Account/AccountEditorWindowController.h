/*
**  AccountEditorWindowController.h
**
**  Copyright (c) 2003-2006 Ludovic Marcotte
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

#ifndef _GNUMail_H_AccountEditorWindowController
#define _GNUMail_H_AccountEditorWindowController

#import <AppKit/AppKit.h>

#define ACCOUNT_ADD  1
#define ACCOUNT_EDIT 2

@class FolderNode;
@class CWIMAPStore;
@class CWSMTP;

@interface AccountEditorWindowController: NSWindowController
{
  // Outlets
  IBOutlet NSTabView *tabView;
  
  // Personal view
  IBOutlet id personalView;
  IBOutlet NSTextField *personalAccountNameField;
  IBOutlet NSTextField *personalNameField;
  IBOutlet NSTextField *personalEMailField;
  IBOutlet NSTextField *personalReplyToField;
  IBOutlet NSTextField *personalOrganizationField;
  IBOutlet NSPopUpButton *personalSignaturePopUp;
  IBOutlet NSTextField *personalSignatureField;
  IBOutlet NSButton *personalLocationButton;
  IBOutlet NSTextField *personalLocationLabel;
  
  // Receive view
  IBOutlet id receiveView;
  IBOutlet NSTextField *receiveServerNameField;
  IBOutlet NSTextField *receiveServerPortField;
  IBOutlet NSTextField *receiveUsernameField;
  IBOutlet NSPopUpButton *receivePopUp;
  IBOutlet NSSecureTextField *receivePasswordSecureField;
  IBOutlet NSButton *receiveRememberPassword;
  IBOutlet NSButton *receiveCheckOnStartup;
  IBOutlet NSPopUpButton *receiveUseSecureConnection;
  IBOutlet NSMatrix *receiveMatrix;
  IBOutlet NSTextField *receiveMinutesField;
  
  // IMAPView
  IBOutlet id imapView;
  IBOutlet NSPopUpButton *imapSupportedMechanismsPopUp;
  IBOutlet NSTableColumn *imapViewMailboxColumn;
  IBOutlet NSTableColumn *imapSubscriptionColumn;
  IBOutlet NSOutlineView *imapOutlineView;
  IBOutlet NSMatrix *imapMatrix;

  // POP3View
  IBOutlet id pop3View;
  IBOutlet NSButton *pop3LeaveOnServer;
  IBOutlet NSTextField *pop3DaysField;
  IBOutlet NSButton *pop3UseAPOP;
  IBOutlet NSPopUpButton *pop3DefaultInboxPopUpButton;

  // UNIXView
  IBOutlet id unixView;
  IBOutlet NSTextField *unixMailspoolFileField;
  IBOutlet NSPopUpButton *unixDefaultInboxPopUpButton;

  // Send view
  IBOutlet id sendView;
  IBOutlet id sendMailerView;
  IBOutlet id sendSMTPView;
  IBOutlet NSPopUpButton *sendTransportMethodPopUpButton;
  IBOutlet NSTextField *sendMailerField;
  IBOutlet NSTextField *sendSMTPHostField;
  IBOutlet NSTextField *sendSMTPPortField;
  IBOutlet NSTextField *sendSMTPUsernameField;
  IBOutlet NSSecureTextField *sendSMTPPasswordSecureField;
  IBOutlet NSButton *sendRememberPassword;
  IBOutlet NSPopUpButton *sendUseSecureConnection;
  IBOutlet NSButton *sendAuthenticateUsingButton;
  IBOutlet NSButton *sendSupportedMechanismsButton;
  IBOutlet NSPopUpButton *sendSupportedMechanismsPopUp;

  // Other ivars
  NSMutableArray *allVisibleFolders;
  FolderNode *allFolders, *allNodes;
  CWIMAPStore *store;
  NSString *key;
  int operation;
  BOOL _ready;
  CWSMTP *checkSMTP;
}

- (id) initWithWindowNibName: (NSString *) windowNibName;
- (void) dealloc;

//
// action methods
//
- (IBAction) cancelClicked: (id) sender;
- (IBAction) okClicked: (id) sender;
- (IBAction) imapList: (id) sender;
- (IBAction) imapSupportedMechanismsButtonClicked: (id) sender;
- (IBAction) personalLocationButtonClicked: (id) sender;
- (IBAction) receiveRememberPasswordClicked: (id) sender;
- (IBAction) receiveSetAutomatically: (id) sender;
- (IBAction) receiveSetManually: (id) sender;
- (IBAction) receiveUseSecureConnectionHasChanged: (id) sender;
- (IBAction) selectionInPersonalSignaturePopUpHasChanged: (id) sender;
- (IBAction) sendAuthenticateUsingButtonClicked: (id) sender;
- (IBAction) sendRememberPasswordClicked: (id) sender;
- (IBAction) sendSupportedMechanismsButtonClicked: (id) sender;
- (IBAction) sendTransportMethodHasChanged: (id) sender;
- (IBAction) sendUseSecureConnectionHasChanged: (id) sender;
- (IBAction) setType: (id) sender;
- (IBAction) unixMailspoolFileButtonClicked: (id) sender;

//
// access/mutation methods
//
- (NSString *) key;
- (void) setKey: (NSString *) theKey;
- (int) operation;
- (void) setOperation: (int) theOperation;


//
// other methods
//
- (void) initializeFromDefaults;

@end

#endif // _GNUMail_H_AccountEditorWindowController
