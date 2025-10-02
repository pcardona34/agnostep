/*
**  AccountEditorWindowController.m
**
**  Copyright (C) 2003-2007 Ludovic Marcotte
**  Copyright (C) 2014-2017 Riccardo Mottola
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "AccountEditorWindowController.h"

#import "Constants.h"
#import "FolderNode.h"
#import "FolderNodePopUpItem.h"
#import "GNUMail.h"
#import "MailboxManagerController.h"
#import "PasswordPanelController.h"
#import "Utilities.h"

#ifndef MACOSX
#import "AccountEditorWindow.h"
#import "IMAPView.h"
#import "PersonalView.h"
#import "POP3View.h"
#import "ReceiveView.h"
#import "SendView.h"
#import "UNIXView.h"
#endif

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWSMTP.h>
#import <Pantomime/CWTCPConnection.h>
#import <Pantomime/NSString+Extensions.h>

#define IMAP_SERVICE_PORT  143
#define POP3_SERVICE_PORT  110
#define IMAPS_SERVICE_PORT 993
#define POP3S_SERVICE_PORT 995

#define SMTP_PORT  25
#define SSMTP_PORT 465

//
// Private interface
//
@interface AccountEditorWindowController (Private)
- (BOOL) _accountNameIsValid;
- (void) _bestGuessMailspoolFile;
- (void) _connectToIMAPServer;
- (BOOL) _mailboxesSelectionIsValid;
- (BOOL) _nameAndAddressAreSpecified;
- (void) _rebuildListOfSubscribedFolders;
- (BOOL) _receiveInformationIsValid;
- (void) _saveChangesForMailboxesPopUpButton: (NSPopUpButton *) thePopUpButton
					name: (NSString *) theName
                                  dictionary: (NSMutableDictionary *) theMutableDictionary;
- (BOOL) _sendInformationIsValid;
- (void) _setEnableReceiveUIElements: (BOOL) aBOOL;
@end

//
//
//
@implementation AccountEditorWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
  NSButtonCell *cell;
#ifndef MACOSX
  AccountEditorWindow *aWindow;
#endif

#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
 
#else
  aWindow = [[AccountEditorWindow alloc] initWithContentRect: NSMakeRect(200,200,410,400)
					 styleMask: NSTitledWindowMask|NSMiniaturizableWindowMask
					 backing: NSBackingStoreBuffered
					 defer: YES];
  
  self = [super initWithWindow: aWindow];

  RELEASE(aWindow);
#endif

 // First initializations of some variables
  allNodes = [Utilities initializeFolderNodesUsingAccounts: [[[NSUserDefaults standardUserDefaults] 
							       volatileDomainForName: @"PREFERENCES"] 
							      objectForKey: @"ACCOUNTS"]];
  RETAIN(allNodes);

  allFolders = [[FolderNode alloc] init];
  [allFolders setName: _(@"All Mailboxes")];
  store = nil;
  checkSMTP = nil;

#ifndef MACOSX
  
  [aWindow layoutWindow];
  [aWindow setDelegate: self];

  // We link our standard outlets
  tabView = aWindow->tabView;

  // We load our Personal view
  personalView = [[PersonalView alloc] initWithParent: self];
  [personalView layoutView];
  personalAccountNameField = ((PersonalView *)personalView)->personalAccountNameField;
  personalNameField = ((PersonalView *)personalView)->personalNameField;
  personalEMailField = ((PersonalView *)personalView)->personalEMailField;
  personalReplyToField = ((PersonalView *)personalView)->personalReplyToField;
  personalOrganizationField = ((PersonalView *)personalView)->personalOrganizationField;
  personalSignaturePopUp = ((PersonalView *)personalView)->personalSignaturePopUp;
  personalSignatureField = ((PersonalView *)personalView)->personalSignatureField;
  personalLocationButton = ((PersonalView *)personalView)->personalLocationButton;
  personalLocationLabel = (NSTextField *)((PersonalView *)personalView)->personalLocationLabel;
  
  // We load our Receive view
  receiveView = [[ReceiveView alloc] initWithParent: self];
  [receiveView layoutView];
  receiveServerNameField = ((ReceiveView *)receiveView)->receiveServerNameField;
  receiveServerPortField = ((ReceiveView *)receiveView)->receiveServerPortField;
  receiveUsernameField = ((ReceiveView *)receiveView)->receiveUsernameField;
  receivePopUp = ((ReceiveView *)receiveView)->receivePopUp;
  receivePasswordSecureField = ((ReceiveView *)receiveView)->receivePasswordSecureField;
  receiveRememberPassword = ((ReceiveView *)receiveView)->receiveRememberPassword;
  receiveCheckOnStartup = ((ReceiveView *)receiveView)->receiveCheckOnStartup;
  receiveUseSecureConnection = ((ReceiveView *)receiveView)->receiveUseSecureConnection;
  receiveMatrix = ((ReceiveView *)receiveView)->receiveMatrix;
  receiveMinutesField = ((ReceiveView *)receiveView)->receiveMinutesField;
  
  // IMAPView
  imapView = [[IMAPView alloc] initWithParent: self];
  [imapView layoutView];

  imapSupportedMechanismsPopUp = ((IMAPView *)imapView)->imapSupportedMechanismsPopUp;
  imapViewMailboxColumn = ((IMAPView *)imapView)->imapViewMailboxColumn;
  imapSubscriptionColumn = ((IMAPView *)imapView)->imapSubscriptionColumn;
  imapOutlineView = ((IMAPView *)imapView)->imapOutlineView;
  imapMatrix = ((IMAPView *)imapView)->imapMatrix;

  // POP3View
  pop3View = [[POP3View alloc] initWithParent: self];
  [pop3View layoutView];
  pop3LeaveOnServer = ((POP3View *)pop3View)->pop3LeaveOnServer;
  pop3DaysField = ((POP3View *)pop3View)->pop3DaysField;
  pop3UseAPOP = ((POP3View *)pop3View)->pop3UseAPOP;
  pop3DefaultInboxPopUpButton = ((POP3View *)pop3View)->pop3DefaultInboxPopUpButton;

  // UNIXView
  unixView = [[UNIXView alloc] initWithParent: self];
  [unixView layoutView];
  unixMailspoolFileField = ((UNIXView *)unixView)->unixMailspoolFileField;
  unixDefaultInboxPopUpButton = ((UNIXView *)unixView)->unixDefaultInboxPopUpButton;

  // We load our Send view
  sendView = [[SendView alloc] initWithParent: self];
  [sendView layoutView];
  sendTransportMethodPopUpButton = ((SendView *)sendView)->sendTransportMethodPopUpButton;

  sendMailerView = [[SendMailerView alloc] initWithParent: self];
  [sendMailerView layoutView];
  sendMailerField = ((SendMailerView *)sendMailerView)->sendMailerField;

  sendSMTPView = [[SendSMTPView alloc] initWithParent: self];
  [sendSMTPView layoutView];
  sendSMTPHostField = ((SendSMTPView *)sendSMTPView)->sendSMTPHostField;
  sendSMTPPortField = ((SendSMTPView *)sendSMTPView)->sendSMTPPortField;
  sendSMTPUsernameField = ((SendSMTPView *)sendSMTPView)->sendSMTPUsernameField;
  sendSMTPPasswordSecureField = ((SendSMTPView *)sendSMTPView)->sendSMTPPasswordSecureField;
  sendRememberPassword = ((SendSMTPView *)sendSMTPView)->sendRememberPassword;
  sendUseSecureConnection = ((SendSMTPView *)sendSMTPView)->sendUseSecureConnection;
  sendAuthenticateUsingButton = ((SendSMTPView *)sendSMTPView)->sendAuthenticateUsingButton;
  sendSupportedMechanismsButton = ((SendSMTPView *)sendSMTPView)->sendSupportedMechanismsButton;
  sendSupportedMechanismsPopUp = ((SendSMTPView *)sendSMTPView)->sendSupportedMechanismsPopUp;
#endif


  [[self window] setTitle: _(@"")];
  
  // We add all our views
#ifndef MACOSX
  [[tabView tabViewItemAtIndex: 0] setView: personalView];
  [[tabView tabViewItemAtIndex: 1] setView: receiveView];
  [[tabView tabViewItemAtIndex: 3] setView: sendView];
#endif
  [[tabView tabViewItemAtIndex: 2] setView: pop3View];

  // We set our custom cell for the IMAP view.
  cell = AUTORELEASE([[NSButtonCell alloc] init]);
  [cell setButtonType: NSSwitchButton];
  [cell setImagePosition: NSImageOnly];
  [cell setControlSize: NSSmallControlSize];  
  [imapSubscriptionColumn setDataCell: cell];

  // We populate our popup buttons
  [Utilities addItemsToPopUpButton: pop3DefaultInboxPopUpButton   usingFolderNodes: allNodes];
  [Utilities addItemsToPopUpButton: unixDefaultInboxPopUpButton    usingFolderNodes: allNodes];
  
  [receiveUseSecureConnection removeAllItems];
  [receiveUseSecureConnection addItemWithTitle: _(@"No")];
  [receiveUseSecureConnection addItemWithTitle: _(@"SSL")];
  [receiveUseSecureConnection addItemWithTitle: _(@"TLS, if available")];
  [receiveUseSecureConnection addItemWithTitle: _(@"TLS")];
  [sendUseSecureConnection removeAllItems];
  [sendUseSecureConnection addItemWithTitle: _(@"No")];
  [sendUseSecureConnection addItemWithTitle: _(@"SSL")];
  [sendUseSecureConnection addItemWithTitle: _(@"TLS, if available")];
  [sendUseSecureConnection addItemWithTitle: _(@"TLS")];

  // We select default items in various popups and we refresh the view
  [personalSignaturePopUp selectItemAtIndex: 0];
  [receiveUseSecureConnection selectItemAtIndex: 0];
  [sendUseSecureConnection selectItemAtIndex: 0];
  [sendSupportedMechanismsPopUp selectItemAtIndex: 0];
  [receivePopUp selectItemWithTitle: _(@"POP3")];
  [self setType: nil];

  // We set the supported IMAP AUTH mechanism. We must NOT localize the "Password" item.
  [imapSupportedMechanismsPopUp removeAllItems];
  [imapSupportedMechanismsPopUp addItemWithTitle: @"Password"];

  // We select a default item in our send popup and we refresh the view
  [sendTransportMethodPopUpButton selectItemWithTitle: _(@"SMTP")];
  [self sendTransportMethodHasChanged: nil];

  // We set the supported SMTP AUTH mechanisms
  [sendSupportedMechanismsPopUp removeAllItems];
  //  [sendSupportedMechanismsPopUp addItemWithTitle: _(@"None")];
  [sendSupportedMechanismsPopUp addItemWithTitle: _(@"Plain")];
  [sendSupportedMechanismsPopUp addItemWithTitle: _(@"Login")];
  [sendSupportedMechanismsButton setEnabled:NO];

  // We initialize some ivars
  allVisibleFolders = [[NSMutableArray alloc] init];
  store = nil;
  _ready = NO;

  // We select again the first tab view item.
  // If not, this is shown as empty.
  [tabView selectFirstTabViewItem: self];

  [[self window] setFrameAutosaveName: @"AccountEditorWindow"];
  [[self window] setFrameUsingName: @"AccountEditorWindow"];

  return self;
}


//
//
//
- (void) dealloc
{
  // We release our ivars
  RELEASE(allVisibleFolders);
  RELEASE(key);
  RELEASE(allFolders);
  RELEASE(allNodes);

#ifndef MACOSX
  // We release all our views
  RELEASE(personalView);
  RELEASE(receiveView);
  RELEASE(sendView);
  RELEASE(sendMailerView);
  RELEASE(sendSMTPView);
  RELEASE(imapView);
  RELEASE(pop3View);
  RELEASE(unixView);
#else
  [imapOutlineView setDataSource: nil];
#endif
  
  // We close our IMAP connection, if it was open
  // The delegate method -connectionTerminated: will NOT
  // be invoked (and that's what we want) since we set
  // the store's delegate to nil before invoking the
  // -close method.
  if (store)
    {
      [store setDelegate: nil];
      [store close];

      while ([store isConnected])
	{
	  [[NSRunLoop currentRunLoop] acceptInputForMode: NSDefaultRunLoopMode
				      beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
	}
    }

  if (checkSMTP)
    {
      [checkSMTP setDelegate: nil];
      [checkSMTP close];
      DESTROY(checkSMTP);
    }
  [super dealloc];
}


//
// action methods
//
- (IBAction) cancelClicked: (id) sender
{
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


//
// Dummy method so the supportedAuthenticationMechanisms NSPopUpButton doesn't disable
// itself when selecting an enabled item in it.
//
-(void) foo: (id) sender {}


//
//
//
- (IBAction) imapList: (id) sender
{  
  NSEnumerator *theEnumerator;
  FolderNode *nodes;
   
  [self _connectToIMAPServer];

  if (!_ready)
    {
      return;
    }

  [allFolders setChildren: nil];

  theEnumerator = [store folderEnumerator];
  
  if (!theEnumerator)
    {
      return;
    }
  
  nodes = [Utilities folderNodesFromFolders: theEnumerator
		     separator: [store folderSeparator]];
  RETAIN(nodes);
  
  [allFolders setChildren: [nodes children]];
  RELEASE(nodes);
  
  [self _rebuildListOfSubscribedFolders];

  [imapOutlineView reloadData];
}


//
//
//
//
- (IBAction) imapSupportedMechanismsButtonClicked: (id) sender
{
  NSMenuItem *theItem;
  NSArray *theArray;
  NSString *aString;
  int i;

  [self _connectToIMAPServer];

  if (!_ready)
    {
      return;
    }

  [imapSupportedMechanismsPopUp removeAllItems];

  // The standard "password" authentication
  theItem = [[NSMenuItem alloc] initWithTitle: @"Password"
				action: NULL
				keyEquivalent: @""];
  [theItem setAction: @selector(foo:)];
  [theItem setEnabled: YES];
  [theItem setTarget: self];
  [[imapSupportedMechanismsPopUp menu] addItem: theItem];
  [theItem release];
  
  theArray = [store supportedMechanisms];
  
  for (i = 0; i < [theArray count]; i++)
    {
      aString = [theArray objectAtIndex: i];

      theItem = [[NSMenuItem alloc] initWithTitle: aString
				    action: NULL
				    keyEquivalent: @""];
      
      if ( [aString caseInsensitiveCompare: @"CRAM-MD5"] == NSOrderedSame || 
	   [aString caseInsensitiveCompare: @"LOGIN"] == NSOrderedSame )
	{
	  [theItem setAction: @selector(foo:)];
	  [theItem setEnabled: YES];
	}
      else
	{
	  [theItem setAction: NULL];
	  [theItem setEnabled: NO];
	}

      [theItem setTarget: self];
      [[imapSupportedMechanismsPopUp menu] addItem: theItem];
      RELEASE(theItem);
    }

  [imapSupportedMechanismsPopUp selectItemAtIndex: 0];
}


//
//
//
- (IBAction) okClicked: (id) sender
{
  NSMutableDictionary *aMutableDictionary, *allValues, *allPreferences, *allAccounts;
  NSNumber *serverTypeValue;
  NSString *theKey;
  int value;

  // Before doing anything, we verify if we got any invalid preferences set
  if (![self _accountNameIsValid])
    {
      return;
    }

  if (![self _nameAndAddressAreSpecified])
    {
      return;
    }

  if (![self _receiveInformationIsValid])
    {
      return;
    }

  if (![self _sendInformationIsValid])
    {
      return;
    }

  if (![self _mailboxesSelectionIsValid])
    {
      return;
    }
  

  // We are now ready to save the new account (or the edited account);
  allPreferences = [[NSMutableDictionary alloc] init];
  allAccounts = [[NSMutableDictionary alloc] init];

  [allPreferences addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]];

  if ([allPreferences objectForKey: @"ACCOUNTS"])
    {
      [allAccounts addEntriesFromDictionary: [allPreferences objectForKey: @"ACCOUNTS"]];
    }

  if ([self key])
    {
      allValues = AUTORELEASE([[NSMutableDictionary alloc] initWithDictionary: [allAccounts objectForKey: [self key]]]);
    }
  else
    {
      allValues = AUTORELEASE([[NSMutableDictionary alloc] init]);
    }
  
  //
  // PERSONAL
  //
  aMutableDictionary = [[NSMutableDictionary alloc] init];
  [personalSignaturePopUp synchronizeTitleAndSelectedItem];

  [aMutableDictionary setObject: [personalNameField stringValue]  forKey: @"NAME"];
  [aMutableDictionary setObject: [personalEMailField stringValue]  forKey: @"EMAILADDR"];
  [aMutableDictionary setObject: [personalReplyToField stringValue]  forKey: @"REPLYTOADDR"];
  [aMutableDictionary setObject: [personalOrganizationField stringValue]  forKey: @"ORGANIZATION"];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [personalSignaturePopUp indexOfSelectedItem]]  forKey: @"SIGNATURE_SOURCE"];
  [aMutableDictionary setObject: [personalSignatureField stringValue]  forKey: @"SIGNATURE"];
  [allValues setObject: aMutableDictionary  forKey: @"PERSONAL"];
  RELEASE(aMutableDictionary);
  
  //
  // RECEIVE
  //
  aMutableDictionary = [[NSMutableDictionary alloc] init];
  [receivePopUp synchronizeTitleAndSelectedItem];

  // We set the type of our server and our port
  if ([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"POP3")])
    {
      serverTypeValue = [NSNumber numberWithInt: POP3];
      
      if ([receiveServerPortField intValue] > 0)
	{
	  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveServerPortField intValue]]  forKey: @"PORT"];
	}
      else
	{
	  [aMutableDictionary setObject: [NSNumber numberWithInt: POP3_SERVICE_PORT]  forKey: @"PORT"];
	}
    }
  else if ([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"IMAP")])
    {
      serverTypeValue = [NSNumber numberWithInt: IMAP];
      
      if ([receiveServerPortField intValue] > 0)
	{
	  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveServerPortField intValue]]  forKey: @"PORT"];
	}     
      else
	{
	  [aMutableDictionary setObject: [NSNumber numberWithInt: IMAP_SERVICE_PORT]  forKey: @"PORT"];
	}
    }
  else
    {
      serverTypeValue = [NSNumber numberWithInt: UNIX];
    }

  
  // We get the "new" key
  theKey = [personalAccountNameField stringValue];
  
  //
  // Before potentially removing the other values of our configuration (if for example,
  // theKey is different from [self key]), we save our list of subscribed IMAP folders.
  //
  if ([allAccounts objectForKey: [self key]] &&
      [[allValues objectForKey: @"RECEIVE"] objectForKey: @"SUBSCRIBED_FOLDERS"] &&
      [allVisibleFolders count] == 0)
    {
      [allVisibleFolders addObjectsFromArray: [[allValues objectForKey: @"RECEIVE"] objectForKey: @"SUBSCRIBED_FOLDERS"]];
    }

  if ( ![theKey isEqualToString: [self key]] )
    {
      // We don't try to remove it if it's not in there!
      if ( [allAccounts objectForKey: [self key]] )
    	{
    	  [allAccounts removeObjectForKey: [self key]];
    	}
      [self setKey: theKey];
    }
  
  // We set the SERVER TYPE pref value
  [aMutableDictionary setObject: serverTypeValue  forKey: @"SERVERTYPE"];
  
  // We set the rest of the informations
  [aMutableDictionary setObject: [receiveServerNameField stringValue]  forKey: @"SERVERNAME"];
  [aMutableDictionary setObject: [receiveUsernameField stringValue]  forKey: @"USERNAME"];
  
  // We save the password or we remove it from the defaults database
  if ( [receiveRememberPassword state] == NSOnState )
    {
      [aMutableDictionary setObject: [Utilities encryptPassword: [receivePasswordSecureField stringValue]
						withKey: [NSString stringWithFormat: @"%@ @ %@", [receiveUsernameField stringValue],
								   [receiveServerNameField stringValue]]]  
			  forKey: @"PASSWORD"];
    }
  else
    {
      // We don't try to remove it if it's not in there!
      if ( [aMutableDictionary objectForKey: @"PASSWORD"] )
	{
	  [aMutableDictionary removeObjectForKey: @"PASSWORD"];
	}
    }

  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveRememberPassword state]]  forKey: @"REMEMBERPASSWORD"];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveCheckOnStartup state]]  forKey: @"CHECKONSTARTUP"];
 
  [receiveUseSecureConnection synchronizeTitleAndSelectedItem];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveUseSecureConnection indexOfSelectedItem]]  forKey: @"USESECURECONNECTION"];

  [aMutableDictionary setObject: [NSNumber numberWithInt: [receiveMatrix selectedRow]]  forKey: @"RETRIEVEMETHOD"];  
  
  value = [receiveMinutesField intValue];

  if ( value <= 0 )
    {
      value = 1;
    }

  [aMutableDictionary setObject: [NSNumber numberWithInt: value]  forKey: @"RETRIEVEMINUTES"];

  // Our POP3 defaults
  [aMutableDictionary setObject: [NSNumber numberWithInt: [pop3LeaveOnServer state]]  forKey: @"LEAVEONSERVER"];

  value = [pop3DaysField intValue];
  [aMutableDictionary setObject: [NSNumber numberWithInt: (value <= 0 ? 365 : value)]  forKey: @"RETAINPERIOD"];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [pop3UseAPOP state]]  forKey: @"USEAPOP"];


  // Our IMAP defaults - authentication mechanism and our subscribed list of folders for IMAP
  [aMutableDictionary setObject: [imapSupportedMechanismsPopUp titleOfSelectedItem] forKey: @"AUTH_MECHANISM"];
  [aMutableDictionary setObject: allVisibleFolders  forKey: @"SUBSCRIBED_FOLDERS"];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [[imapMatrix selectedCell] tag]]
		      forKey: @"SHOW_WHICH_MAILBOXES"];

  // Our UNIX defaults
  [aMutableDictionary setObject: [unixMailspoolFileField stringValue]  forKey: @"MAILSPOOLFILE"];
  
  // We now save the new defaults pour this server
  [allValues setObject: aMutableDictionary  forKey: @"RECEIVE"];
  RELEASE(aMutableDictionary);
  

  //
  // SEND
  //
  aMutableDictionary = [[NSMutableDictionary alloc] init];
  [sendTransportMethodPopUpButton synchronizeTitleAndSelectedItem];
  [sendSupportedMechanismsPopUp synchronizeTitleAndSelectedItem];

  [aMutableDictionary setObject: [NSNumber numberWithInt: ([sendTransportMethodPopUpButton indexOfSelectedItem] + 1)] forKey: @"TRANSPORT_METHOD"];
  [aMutableDictionary setObject: [sendMailerField stringValue] forKey: @"MAILER_PATH"];
  [aMutableDictionary setObject: [sendSMTPHostField stringValue] forKey: @"SMTP_HOST"];
  
  // SMTP port
  value = [sendSMTPPortField intValue];
  
  if (value <= 0)
    {
      value = SMTP_PORT;
    }
  
  [aMutableDictionary setObject: [NSNumber numberWithInt: value] forKey: @"SMTP_PORT"];
  
  // SMTP username and password
  [aMutableDictionary setObject: [sendSMTPUsernameField stringValue] forKey: @"SMTP_USERNAME"];
  
  if ([sendRememberPassword state] == NSOnState)
    {
      [aMutableDictionary setObject: [Utilities encryptPassword: [sendSMTPPasswordSecureField stringValue]
						withKey: [NSString stringWithFormat: @"%@ @ %@", [sendSMTPUsernameField stringValue],
								   [sendSMTPHostField stringValue]]]
			  forKey: @"SMTP_PASSWORD"];
    }
  else
    {
      [aMutableDictionary removeObjectForKey: @"SMTP_PASSWORD"];
    }
  
  [aMutableDictionary setObject: [NSNumber numberWithInt: [sendRememberPassword state]] forKey: @"REMEMBERPASSWORD"];

  [sendUseSecureConnection synchronizeTitleAndSelectedItem];
  [aMutableDictionary setObject: [NSNumber numberWithInt: [sendUseSecureConnection indexOfSelectedItem]] forKey: @"USESECURECONNECTION"];
  
  [aMutableDictionary setObject: [NSNumber numberWithInt: [sendAuthenticateUsingButton state]] forKey: @"SMTP_AUTH"];
  [aMutableDictionary setObject: [sendSupportedMechanismsPopUp titleOfSelectedItem] forKey: @"SMTP_AUTH_MECHANISM"];
  [allValues setObject: aMutableDictionary  forKey: @"SEND"];
  RELEASE(aMutableDictionary);


  //
  // MAILBOXES
  //
  aMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary: [allValues objectForKey: @"MAILBOXES"]];

  if ([serverTypeValue intValue] == POP3)
    {
      [self _saveChangesForMailboxesPopUpButton: pop3DefaultInboxPopUpButton
	    name: @"INBOXFOLDERNAME"
	    dictionary: aMutableDictionary];
    }
  else if ([serverTypeValue intValue] == UNIX)
    {
      [self _saveChangesForMailboxesPopUpButton: unixDefaultInboxPopUpButton
	    name: @"INBOXFOLDERNAME"
	    dictionary: aMutableDictionary];
    }
  else
    {
      [aMutableDictionary setObject: [NSString stringWithFormat: @"imap://%@@%@/INBOX", [receiveUsernameField stringValue],
			  [receiveServerNameField stringValue]]  forKey: @"INBOXFOLDERNAME"];
    }
  
  [allValues setObject: aMutableDictionary  forKey: @"MAILBOXES"];
  RELEASE(aMutableDictionary);
  

  // We now save back all the accounts in the volatile domain
  [allAccounts setObject: allValues  forKey: [self key]];
  [allPreferences setObject: allAccounts  forKey: @"ACCOUNTS"];

  // FIXME - This is causing a segfault under OS X
#ifndef MACOSX
  [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
  [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences
					 forName: @"PREFERENCES"];

  RELEASE(allAccounts);
  RELEASE(allPreferences);
  

  // We finally warn the user if he's adding an IMAP account showing
  // all folders. That could impact the performance of GNUMail.
  if ( [self operation] == ACCOUNT_ADD &&
       [serverTypeValue intValue] == IMAP &&
       [[imapMatrix selectedCell] tag] == IMAP_SHOW_ALL )
    {
      NSRunInformationalAlertPanel(_(@"Warning!"),
				   _(@"You have created a new IMAP account showing all mailboxes.\nDepending on the IMAP server, this could slow down GNUMail.\nYou might consider modifying the newly created account so it shows only\nsubscribed mailboxes by checking the appropriate option in the \"Receive options\" tab."),
				   _(@"OK"),
				   NULL,
				   NULL,
				   NULL);
    }

  [NSApp stopModal];
  [self close];
}


//
//
//
- (IBAction) personalLocationButtonClicked: (id) sender
{
  NSOpenPanel *oPanel;
  int result;
  
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection: NO];
  result = [oPanel runModalForDirectory: [GNUMail currentWorkingPath]
		   file: nil 
		   types: nil];
  
  if (result == NSOKButton)
    {
      NSArray *fileToOpen;
      int count;
      
      fileToOpen = [oPanel filenames];
      count = [fileToOpen count];
      
      if (count > 0)
	{
	  NSString *aString;

	  aString = [fileToOpen objectAtIndex: 0];
	  [personalSignatureField setStringValue: aString];
	  [GNUMail setCurrentWorkingPath: [aString stringByDeletingLastPathComponent]];
	}
    }
}


//
//
//
- (IBAction) receiveRememberPasswordClicked: (id) sender
{
  if ([receiveRememberPassword state] == NSOnState)
    {
      [receivePasswordSecureField setEditable: YES];
      [receiveRememberPassword setNextKeyView: receivePasswordSecureField];
      [receivePasswordSecureField setNextKeyView: receiveCheckOnStartup];
    }
  else
    {
      [receivePasswordSecureField setEditable: NO];
      [receiveRememberPassword setNextKeyView: receiveCheckOnStartup];
    }
}


//
//
//
- (IBAction) receiveSetAutomatically: (id) sender
{
  [receiveMinutesField setEditable: YES];
}


//
//
//
- (IBAction) receiveSetManually: (id) sender
{
  [receiveMinutesField setEditable: NO];
}


//
//
//
- (IBAction) receiveUseSecureConnectionHasChanged: (id) sender
{
  int index;

  [receiveUseSecureConnection synchronizeTitleAndSelectedItem];
  index = [receiveUseSecureConnection indexOfSelectedItem];
  
  if ([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"POP3")])
    {
      if (index == SECURITY_NONE && POP3S_SERVICE_PORT == [receiveServerPortField intValue])
        {
          [receiveServerPortField setIntValue: POP3_SERVICE_PORT];
        }
      else if (index == SECURITY_SSL && POP3_SERVICE_PORT == [receiveServerPortField intValue])
        {
          [receiveServerPortField setIntValue: POP3S_SERVICE_PORT];
        }
    }
  else
    {
      if (index == SECURITY_NONE && IMAPS_SERVICE_PORT == [receiveServerPortField intValue])
        {
          [receiveServerPortField setIntValue: IMAP_SERVICE_PORT];
        }
      else if (index == SECURITY_SSL && IMAP_SERVICE_PORT == [receiveServerPortField intValue])
        {
          [receiveServerPortField setIntValue: IMAPS_SERVICE_PORT];
        }
    }
}


//
//
//
- (IBAction) selectionInPersonalSignaturePopUpHasChanged: (id) sender
{
  [personalSignaturePopUp synchronizeTitleAndSelectedItem];

  if ( [personalSignaturePopUp indexOfSelectedItem] == 0 )
    {
      [personalLocationLabel setStringValue: _(@"File location:")];
    }
  else
    {
      [personalLocationLabel setStringValue: _(@"Program location:")];
    }
  
  [personalLocationLabel setNeedsDisplay: YES];
}


//
//
//
- (IBAction) sendAuthenticateUsingButtonClicked: (id) sender
{
  BOOL aBOOL;

  aBOOL = ([sendAuthenticateUsingButton state] == NSOnState ? YES : NO);
  
  [sendSMTPUsernameField setEditable: aBOOL];
  [sendRememberPassword setEnabled: aBOOL];

  if ( aBOOL && [sendRememberPassword state] == NSOnState )
    {
      [sendSMTPPasswordSecureField setEditable: YES];
    }
  else
    {
      [sendSMTPPasswordSecureField setEditable: NO];
    }

  [sendSupportedMechanismsButton setEnabled: aBOOL];
  [sendSupportedMechanismsPopUp setEnabled: aBOOL];

  //
  // We adjust the next key views
  //
  if (aBOOL)
    {
      [sendAuthenticateUsingButton setNextKeyView: sendSupportedMechanismsPopUp];
      [sendSupportedMechanismsPopUp setNextKeyView: sendSupportedMechanismsButton];
      [sendSupportedMechanismsButton setNextKeyView: sendSMTPUsernameField];
      [sendSMTPUsernameField setNextKeyView: sendRememberPassword];
      [sendRememberPassword setNextKeyView: sendSMTPPasswordSecureField];
      [sendSMTPPasswordSecureField setNextKeyView: sendSMTPHostField];
    }
  else
    {
      [sendAuthenticateUsingButton setNextKeyView: sendSMTPHostField];
    }
}


//
//
//
- (IBAction) sendRememberPasswordClicked: (id) sender
{
  if ([sendRememberPassword state] == NSOnState)
    {
      [sendSMTPPasswordSecureField setEditable: YES];
    }
  else
    {
      [sendSMTPPasswordSecureField setEditable: NO];
    }
}

//
//
//
- (IBAction) sendSupportedMechanismsButtonClicked: (id) sender
{
  int value;

  [sendSupportedMechanismsPopUp removeAllItems];
  
  // We get our SMTP port value (can be other than 25!)
  value = [sendSMTPPortField intValue];

  [sendUseSecureConnection synchronizeTitleAndSelectedItem];
  
  if (value <= 0)
    {
      if ([sendUseSecureConnection indexOfSelectedItem] == SECURITY_SSL)
	{
	  value = SSMTP_PORT;
	}
      else
	{
	  value = SMTP_PORT;
	}
    }
  
  checkSMTP = [[CWSMTP alloc] initWithName: [sendSMTPHostField stringValue]
				      port: value];
  
  /* we are in a modal dialog, add to runloop before connecting */
  [checkSMTP addRunLoopMode: NSEventTrackingRunLoopMode];
  [checkSMTP addRunLoopMode: NSModalPanelRunLoopMode];

  [checkSMTP setDelegate: self];
  
  if ([checkSMTP connect] < 0)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"Unable to communicate with the SMTP server (%@).\nCheck the port you have specified."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      [sendSMTPHostField stringValue]);
      [checkSMTP setDelegate: nil];
      DESTROY(checkSMTP);
      return;
    }
  NSLog(@"connection to smtp was successful...");
  if ([sendUseSecureConnection indexOfSelectedItem] == SECURITY_SSL)
    {
      if ([(CWTCPConnection *)[checkSMTP connection] startSSL] < 0)
	{
	  NSRunAlertPanel(_(@"Error!"),
			  _(@"Unable to communicate with the SMTP server (%@).\nSSL handshake error."),
			  _(@"OK"),
			  NULL,
			  NULL,
			  [sendSMTPHostField stringValue]);
	  
	  // We abruptly close the connection.
	  [checkSMTP cancelRequest];
	}
    }
}

//
//
//
- (IBAction) sendTransportMethodHasChanged: (id) sender
{
  [sendTransportMethodPopUpButton synchronizeTitleAndSelectedItem];

  // If we selected "Mailer"
  if ( [sendTransportMethodPopUpButton indexOfSelectedItem] == 0 )
    {
      [sendSMTPView removeFromSuperviewWithoutNeedingDisplay];
      [sendView addSubview: sendMailerView];
      [sendView setNeedsDisplay: YES];
    }
  else
    {
      [sendMailerView removeFromSuperviewWithoutNeedingDisplay];
      [sendView addSubview: sendSMTPView];
      [sendView setNeedsDisplay: YES];
    }
}


//
//
//
- (IBAction) sendUseSecureConnectionHasChanged: (id) sender
{
  int index;

  [sendUseSecureConnection synchronizeTitleAndSelectedItem];
  index = [sendUseSecureConnection indexOfSelectedItem];
  
  if (index == SECURITY_NONE &&
      SSMTP_PORT == [sendSMTPPortField intValue])
    {
      [sendSMTPPortField setIntValue: SMTP_PORT];
    }
  else if (index == SECURITY_SSL &&
	   SMTP_PORT == [sendSMTPPortField intValue])
    {
      [sendSMTPPortField setIntValue: SSMTP_PORT];
    }
}


//
//
//
- (IBAction) setType: (id) sender
{
  [receivePopUp synchronizeTitleAndSelectedItem];
  [receiveUseSecureConnection synchronizeTitleAndSelectedItem];
  
  if ([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"POP3")])
    {
      [self _setEnableReceiveUIElements: YES]; 
      [[tabView tabViewItemAtIndex: 2] setView: pop3View];

      // If the number 'IMAP_SERVICE_PORT' was on the text field,
      // we set it to POP3_SERVICE_PORT. Else, we keep that custom port.
      if (([receiveServerPortField intValue] == IMAP_SERVICE_PORT || [receiveServerPortField intValue] == 0)  &&
	  [receiveUseSecureConnection indexOfSelectedItem] == SECURITY_NONE)
	{
	  [receiveServerPortField setIntValue: POP3_SERVICE_PORT];
	}
      else if ([receiveServerPortField intValue] == IMAPS_SERVICE_PORT &&
	       [receiveUseSecureConnection indexOfSelectedItem] == SECURITY_SSL)
	{
	  [receiveServerPortField setIntValue: POP3S_SERVICE_PORT];
	}
    }
  else if ( [[receivePopUp titleOfSelectedItem] isEqualToString: _(@"IMAP")] )
    {
      [self _setEnableReceiveUIElements: YES];
      [[tabView tabViewItemAtIndex: 2] setView: imapView];

      // If the number 'POP3_SERVICE_PORT' was on the text field,
      // we set it to IMAP_SERVICE_PORT. Else, we keep that custom port.
      if ([receiveServerPortField intValue] == POP3_SERVICE_PORT &&
	  [receiveUseSecureConnection indexOfSelectedItem] == SECURITY_NONE)
	{
	  [receiveServerPortField setIntValue: IMAP_SERVICE_PORT];
	}
      else if ([receiveServerPortField intValue] == POP3S_SERVICE_PORT &&
	       [receiveUseSecureConnection indexOfSelectedItem] == SECURITY_SSL)
	{
	  [receiveServerPortField setIntValue: IMAPS_SERVICE_PORT];
	}
    }
  else
    {
      [self _setEnableReceiveUIElements: NO];
      [[tabView tabViewItemAtIndex: 2] setView: unixView];
    }

  // We best guess the mail spool file
  [self _bestGuessMailspoolFile];
  
  [tabView setNeedsDisplay: YES];
}



//
//
//
- (IBAction) unixMailspoolFileButtonClicked: (id) sender
{
  NSOpenPanel *oPanel;
  int result;
 
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection:NO];
  result = [oPanel runModalForDirectory: NSHomeDirectory()  file: nil  types: nil];
  
  if (result == NSOKButton)
    {
      NSArray *fileToOpen;
      NSString *fileName;
      int count;

      fileToOpen = [oPanel filenames];
      count = [fileToOpen count];
      
      if (count > 0)
	{
	  fileName = [fileToOpen objectAtIndex:0];
	  [unixMailspoolFileField setStringValue:fileName];
	}
    }
}



//
// Datasource/delegate methods for the outline view
//
- (BOOL)    outlineView: (NSOutlineView *) outlineView
  shouldEditTableColumn: (NSTableColumn *) tableColumn
		   item: (id) item
{
  if (tableColumn == imapSubscriptionColumn)
    {
      return YES;
    }
  
  return NO;
}


//
//
//
- (id) outlineView: (NSOutlineView *) outlineView
	     child: (NSInteger) index
	    ofItem: (id) item
{
  
  // root object
  if (!item)
    {
      return allFolders;
    }
  
  if ([item isKindOfClass: [FolderNode class]])
    {
      return [(FolderNode *)item childAtIndex: index];
    }
  
  return nil;
}


//
//
//
- (BOOL) outlineView: (NSOutlineView *) outlineView
    isItemExpandable: (id) item
{
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
  // Root, always one element
  if (!item)
    {
      return 1;
    }

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
  if (tableColumn == imapViewMailboxColumn)
    {
      return [(FolderNode *)item name];
    }

  return [NSNumber numberWithBool: [(FolderNode *)item subscribed]];
}


//
//
//
- (void) outlineView: (NSOutlineView *) theOutlineView
      setObjectValue: (id) theObject
      forTableColumn: (NSTableColumn *) theTableColumn
	      byItem: (id) theItem
{
  FolderNode *aFolderNode;
  NSString *aString;
  
  aFolderNode = (FolderNode *)theItem;
  aString = [Utilities pathOfFolderFromFolderNode: aFolderNode
		       separator: [store folderSeparator]];

  if ([aFolderNode subscribed])
    {
      [store unsubscribeToFolderWithName: aString];
    }
  else
    {    
      //
      // RFC3501 does NOT explicitely say we cannot subscribe to a \Noselect mailbox but we
      // assume we can't since we cannot SELECT it, nor APPEND messages to it.
      //
      if (aFolderNode == allFolders ||
	  ([store folderTypeForFolderName: aString] & PantomimeNoSelect) == PantomimeNoSelect)
	{
	  NSRunInformationalAlertPanel(_(@"Error!"),
				       _(@"You cannot subscribe to this folder."),
				       _(@"OK"),
				       NULL,
				       NULL,
				       NULL);
	  return;
	}
      
      [store subscribeToFolderWithName: aString];
    }
}


//
// access/mutation methods
//
- (NSString *) key
{
  return key;
}

- (void) setKey: (NSString *) theKey
{
  if (theKey)
    {
      ASSIGN(key, theKey);
    }
  else
    {
      DESTROY(key);
    }
}


//
//
//
- (int) operation
{
  return operation;
}

- (void) setOperation: (int) theOperation
{
  operation = theOperation;

  if (operation == ACCOUNT_ADD)
    {
      [[self window] setTitle: _(@"Add an Account...")];

      // We initialize the state of some UI elements so when adding a new account,
      // all UI elements are correctly enabled / disabled initially.
      [personalAccountNameField setStringValue: _(@"<Specify the account name here>")];
      [receivePasswordSecureField setEditable: NO];
      [sendSMTPPortField setIntValue: SMTP_PORT];
      [self sendAuthenticateUsingButtonClicked: self];
    }
  else
    {
      [[self window] setTitle: [NSString stringWithFormat: _(@"Edit the %@ account..."), [self key]]];
    }
}


//
// other methods
//
- (void) initializeFromDefaults
{
  NSNumber *serverTypeValue, *portValue;
  FolderNodePopUpItem *aPopUpItem;
  NSDictionary *allValues;
  NSString *aString;

  //
  // Account's name
  //
  [personalAccountNameField setStringValue: [self key]];

  //
  // PERSONAL
  //
  allValues = [[[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"] objectForKey: @"ACCOUNTS"]
		 objectForKey: [self key]]
		objectForKey: @"PERSONAL"];
  [personalNameField setStringValue: ((aString = [allValues objectForKey: @"NAME"]) ? (id)aString : (id)@"")];
  [personalEMailField setStringValue: ((aString = [allValues objectForKey: @"EMAILADDR"]) ? (id)aString : (id)@"")];
  [personalReplyToField setStringValue: ((aString = [allValues objectForKey: @"REPLYTOADDR"]) ? (id)aString : (id)@"")];
  [personalOrganizationField setStringValue: ((aString = [allValues objectForKey: @"ORGANIZATION"]) ? (id)aString : (id)@"")];
  
  if ( [allValues objectForKey: @"SIGNATURE_SOURCE"] )
    {
      [personalSignaturePopUp selectItemAtIndex: [(NSNumber *)[allValues objectForKey: @"SIGNATURE_SOURCE"] intValue]];
    }
  else
    {
      [personalSignaturePopUp selectItemAtIndex: 0];
    }

  [personalSignatureField setStringValue: ((aString = [allValues objectForKey: @"SIGNATURE"]) ? (id)aString : (id)@"")];

  
  //
  // RECEIVE (and options)
  //  
  // We now get all the data from the volatile user defaults
  allValues = [[[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]  objectForKey: @"ACCOUNTS"] 
		 objectForKey: [self key]] 
		objectForKey: @"RECEIVE"];
  
  // We decode our type
  serverTypeValue = [allValues objectForKey: @"SERVERTYPE"];
  
  if (serverTypeValue && [serverTypeValue intValue] == IMAP)
    {
      [receivePopUp selectItemWithTitle: _(@"IMAP")];
    }
  else if ( !serverTypeValue ||
	    (serverTypeValue && [serverTypeValue intValue] == POP3) )
    {
      [receivePopUp selectItemWithTitle: _(@"POP3")];
    }
  else
    {
      [receivePopUp selectItemWithTitle: _(@"UNIX")];
    }
  
  // We decode our port
  portValue =  [allValues objectForKey: @"PORT"];
  
  if ( portValue )
    {
      [receiveServerPortField setIntValue: [portValue intValue]];
    }
  else
    {
      if (serverTypeValue && [serverTypeValue intValue] == IMAP)
	{
	  [receiveServerPortField setIntValue: IMAP_SERVICE_PORT];
	}
      else
	{
	  [receiveServerPortField setIntValue: POP3_SERVICE_PORT];
	}
    }

  // We decode the rest of the information. We begin with SERVERNAME.
  if ( allValues && [allValues objectForKey: @"SERVERNAME"] )
    {
      [receiveServerNameField setStringValue: [allValues objectForKey: @"SERVERNAME"] ];
    }
  else
    {
      [receiveServerNameField setStringValue: @""];
    }

  if ( allValues && [allValues objectForKey: @"USERNAME"] )
    {
      [receiveUsernameField setStringValue: [allValues objectForKey: @"USERNAME"] ];
    }
  else
    {
      [receiveUsernameField setStringValue: @""];
    }
  
  // We get our password, if we need to!
  if ( allValues && [allValues objectForKey: @"PASSWORD"] )
    {
      NSString *aPassword;
      
      aPassword = [Utilities decryptPassword: [allValues objectForKey: @"PASSWORD"]
			     withKey: [NSString stringWithFormat: @"%@ @ %@", [receiveUsernameField stringValue],
						[receiveServerNameField stringValue]]];
      
      if ( !aPassword )
	{
	  aPassword = @"";
	}

      [receivePasswordSecureField setStringValue: aPassword];
    }
  else
    {
      [receivePasswordSecureField setStringValue: @""];
    }
  
  // REMEMBERPASSWORD
  if ( allValues && [allValues objectForKey: @"REMEMBERPASSWORD"] )
    {
      [receiveRememberPassword setState: [[allValues objectForKey: @"REMEMBERPASSWORD"] intValue]];
    }
  else
    {
      [receiveRememberPassword setState: NSOffState];
    }
  
  // We update our editable/non-editable status of the password field
  [self receiveRememberPasswordClicked: self];


  // CHECKONSTARTUP
  if ( allValues && [allValues objectForKey: @"CHECKONSTARTUP"] )
    {
      [receiveCheckOnStartup setState: [[allValues objectForKey: @"CHECKONSTARTUP"] intValue]];
    }
  else
    {
      [receiveCheckOnStartup setState: NSOffState];
    }

  // USESECURECONNECTION
  if ( allValues && [allValues objectForKey: @"USESECURECONNECTION"] )
    {
      [receiveUseSecureConnection selectItemAtIndex: [[allValues objectForKey: @"USESECURECONNECTION"] intValue]];
    }
  else
    {
      [receiveUseSecureConnection selectItemAtIndex: SECURITY_NONE];
    }

  // RETRIEVEMETHOD and RETRIEVEMINUTES
  [receiveMatrix selectCellAtRow: [[allValues objectForKey: @"RETRIEVEMETHOD"] intValue]  column: 0];
  [receiveMinutesField setIntValue: [[allValues objectForKey: @"RETRIEVEMINUTES"] intValue]];;


  // POP3 - LEAVEONSERVER
  if ( allValues && [allValues objectForKey: @"LEAVEONSERVER"] )
    {
      [pop3LeaveOnServer setState: [[allValues objectForKey: @"LEAVEONSERVER"] intValue]];
    }
  else
    {
      [pop3LeaveOnServer setState: NSOnState];
    }
  
  // POP3 - RETAINPERIOD
  if ( allValues && [allValues objectForKey: @"RETAINPERIOD"] )
    {
      [pop3DaysField setIntValue: [[allValues objectForKey: @"RETAINPERIOD"] intValue]];
    }
  else
    {
      [pop3DaysField setIntValue: 365];
    }
  
  // POP3 - USEAPOP
  if ( allValues && [allValues objectForKey: @"USEAPOP"] )
    {
      [pop3UseAPOP setState: [[allValues objectForKey: @"USEAPOP"] intValue]];
    }
  else
    {
      [pop3UseAPOP setState: NSOffState];
    }

  // IMAP - AUTH MECHANISM
  if ( allValues && [allValues objectForKey: @"AUTH_MECHANISM"] )
    {    
      // If the method is not in the popup button, let's add it.
      if ( ![imapSupportedMechanismsPopUp itemWithTitle: [allValues objectForKey: @"AUTH_MECHANISM"]] )
	{
	  NSMenuItem *theItem;

	  theItem = [[NSMenuItem alloc] initWithTitle: [allValues objectForKey: @"AUTH_MECHANISM"]
					action: NULL
					keyEquivalent: @""];
	  [theItem setTarget: self];
 	  [theItem setAction: @selector(foo:)];
	  [theItem setEnabled: YES];
	  [[imapSupportedMechanismsPopUp menu] addItem: theItem];
	  RELEASE(theItem);
	}

      [imapSupportedMechanismsPopUp selectItemWithTitle: [allValues objectForKey: @"AUTH_MECHANISM"]];
    }

  // IMAP - SHOW_WHICH_MAILBOXES
  if ( allValues && [[allValues objectForKey: @"SHOW_WHICH_MAILBOXES"] intValue] == IMAP_SHOW_SUBSCRIBED_ONLY)
    {
      [imapMatrix selectCellAtRow: 0  column: 1];
    }
  else
    {
      [imapMatrix selectCellAtRow: 0  column: 0];
    }

  // UNIX - mail spool file
  if ( allValues && [allValues objectForKey: @"MAILSPOOLFILE"] )
    {
      NSString *aString;

      aString = [allValues objectForKey: @"MAILSPOOLFILE"];
   
      if ( [aString length] > 0 )
	{
	  [unixMailspoolFileField setStringValue: aString];
	}
      else
	{
	  NSProcessInfo *processInfo;
	  
	  processInfo = [NSProcessInfo processInfo];
	  aString = [[processInfo environment] objectForKey: @"MAIL"];
	  
	  if ( aString )
	    {
	      [unixMailspoolFileField setStringValue: aString];
	    }
	  else
	    {
	      [unixMailspoolFileField setStringValue: @""];
	    }
	}
    }

  // We refresh our view
  [self setType: nil];

  //
  // SEND
  //
  allValues = [[[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]  objectForKey: @"ACCOUNTS"] 
		 objectForKey: [self key]] 
		objectForKey: @"SEND"];
  
  [sendTransportMethodPopUpButton selectItemAtIndex: ([[allValues objectForKey: @"TRANSPORT_METHOD"] intValue] - 1) ];
  [sendMailerField setStringValue: ((aString = [allValues objectForKey: @"MAILER_PATH"]) ? (id)aString : (id)@"")];
  [sendSMTPHostField setStringValue: ((aString = [allValues objectForKey: @"SMTP_HOST"]) ? (id)aString : (id)@"")];
  
  if ( [allValues objectForKey: @"SMTP_PORT"] )
    {
      [sendSMTPPortField setIntValue: [[allValues objectForKey: @"SMTP_PORT"] intValue]];
    }
  else
    {
      [sendSMTPPortField setIntValue: SMTP_PORT];
    }

  [sendSMTPUsernameField setStringValue: ((aString = [allValues objectForKey: @"SMTP_USERNAME"]) ? (id)aString : (id)@"")];

  if ( [allValues objectForKey: @"SMTP_PASSWORD"] )
    {
      [sendSMTPPasswordSecureField setStringValue: 
				    [Utilities decryptPassword: [allValues objectForKey: @"SMTP_PASSWORD"]
					       withKey: [NSString stringWithFormat: @"%@ @ %@", [sendSMTPUsernameField stringValue],
								   [sendSMTPHostField stringValue]]]];
    }
  
  if ( [allValues objectForKey: @"SMTP_AUTH"] )
    {
      [sendAuthenticateUsingButton setState: [[allValues objectForKey: @"SMTP_AUTH"] intValue]];
      NSLog(@"SMTP_AUTH!");
      // If the method is not in the popup button, let's add it.
      if (![sendSupportedMechanismsPopUp itemWithTitle: [allValues objectForKey: @"SMTP_AUTH_MECHANISM"]])
	{
	  NSMenuItem *theItem;
	  
	  theItem = [[NSMenuItem alloc] initWithTitle: [allValues objectForKey: @"SMTP_AUTH_MECHANISM"]
					action: NULL
					keyEquivalent: @""];
	  [theItem setTarget: self];
 	  [theItem setAction: @selector(foo:)];
	  [theItem setEnabled: YES];
	  [[sendSupportedMechanismsPopUp menu] addItem: theItem];
	  RELEASE(theItem);
	}

      [sendSupportedMechanismsPopUp selectItemWithTitle: [allValues objectForKey: @"SMTP_AUTH_MECHANISM"]];
    }
  
  if ( [allValues objectForKey: @"REMEMBERPASSWORD"] )
    {
      [sendRememberPassword setState: [[allValues objectForKey: @"REMEMBERPASSWORD"] intValue]];
    }
  else
    {
      [sendRememberPassword setState: NSOffState];
    }
  
  if ([allValues objectForKey: @"USESECURECONNECTION"])
    {
      [sendUseSecureConnection selectItemAtIndex: [[allValues objectForKey: @"USESECURECONNECTION"] intValue]];
    }
  else
    {
      [sendUseSecureConnection selectItemAtIndex: SECURITY_NONE];
    }
  
  [self sendTransportMethodHasChanged: nil];
  [self sendAuthenticateUsingButtonClicked: nil];
  

  //
  // MAILBOXES
  //
  allValues = [[[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"] objectForKey: @"ACCOUNTS"] 
		 objectForKey: [self key]] 
		objectForKey: @"MAILBOXES"];
  
  //
  // Default mailbox for POP3
  //
  aPopUpItem = [Utilities folderNodePopUpItemForURLNameAsString: [allValues objectForKey: @"INBOXFOLDERNAME"]
			  usingFolderNodes: allNodes
			  popUpButton: pop3DefaultInboxPopUpButton
			  account: [[personalAccountNameField stringValue] stringByTrimmingWhiteSpaces]];
  
  if (aPopUpItem)
    {
      [pop3DefaultInboxPopUpButton selectItem: aPopUpItem];
    }
  else
    {
      // FIXME
    }
  
  
  //
  // Default mailbox for UNIX
  //
  aPopUpItem = [Utilities folderNodePopUpItemForURLNameAsString: [allValues objectForKey: @"INBOXFOLDERNAME"]
			  usingFolderNodes: allNodes
			  popUpButton: unixDefaultInboxPopUpButton
			  account: [[personalAccountNameField stringValue] stringByTrimmingWhiteSpaces]];
  
  if (aPopUpItem)
    {
      [unixDefaultInboxPopUpButton selectItem: aPopUpItem];
    }
  else
    {
      // FIXME
    }
}


//
// Delegate methods
//
- (void) authenticationCompleted: (NSNotification *) theNotification
{
  [store folderEnumerator];
  [store subscribedFolderEnumerator];
}


- (void) authenticationFailed: (NSNotification *) theNotification
{
  NSRunAlertPanel(_(@"Error!"),
		  _(@"Unable to authenticate to the IMAP server (%@)."),
		  _(@"OK"),
		  NULL,
		  NULL,
		  [store name]);
  [store close];
}


- (void) serviceInitialized: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];
  NSLog(@"service initialized");
  if ([o isKindOfClass: [CWSMTP class]])
    {
      NSMenuItem *theItem;
      NSArray *theArray;
      NSString *aString;
      int i;

      // We check if we must use STARTTLS
      if (![(CWTCPConnection *)[o connection] isSSL] && 
	  ([sendUseSecureConnection indexOfSelectedItem] == SECURITY_TLS_IF_AVAILABLE || [sendUseSecureConnection indexOfSelectedItem] == SECURITY_TLS))
	{
	  [o startTLS];
	  return;
	}

      theArray = [[theNotification object] supportedMechanisms];
      
      for (i = 0; i < [theArray count]; i++)
	{
	  aString = [theArray objectAtIndex: i];
	  
	  theItem = [[NSMenuItem alloc] initWithTitle: aString
					action: NULL
					keyEquivalent: @""];
	  
	  if ( [aString caseInsensitiveCompare: @"CRAM-MD5"] == NSOrderedSame || 
	       [aString caseInsensitiveCompare: @"LOGIN"] == NSOrderedSame ||
	       [aString caseInsensitiveCompare: @"PLAIN"] == NSOrderedSame )
	    {
	      [theItem setAction: @selector(foo:)];
	      [theItem setEnabled: YES];
	    }
	  else
	    {
	      [theItem setAction: NULL];
	      [theItem setEnabled: NO];
	    }
	  
	  [theItem setTarget: self];
	  [[sendSupportedMechanismsPopUp menu] addItem: theItem];
	  RELEASE(theItem);
	}

      [o close];
      
      // if we end up with no items, add the main back
      if ([sendSupportedMechanismsPopUp numberOfItems] == 0)
        {
          [sendSupportedMechanismsPopUp addItemWithTitle: _(@"Plain")];
          [sendSupportedMechanismsPopUp addItemWithTitle: _(@"Login")];
        }
    }
  else
    {
      NSString *aPassword;

      if ([receiveRememberPassword state] == NSOffState || 
	  [[[receivePasswordSecureField stringValue] stringByTrimmingWhiteSpaces] length] == 0)
	{
	  aPassword = [Utilities passwordForKey: [self key]  type: IMAP  prompt: YES];
	}
      else
	{
	  aPassword = [[receivePasswordSecureField stringValue] stringByTrimmingWhiteSpaces];
	}

      if (aPassword)
	{
	  [store authenticate: [receiveUsernameField stringValue]
		 password: aPassword
		 mechanism: nil];
	}
      else
	{
	  [self authenticationFailed: theNotification];
	}
    }
}

- (void) requestCancelled: (NSNotification *) theNotification
{
  // For now, let's do the same that we do in -connectionTerminated:.
  [self connectionTerminated: theNotification];
}

- (void) connectionLost: (NSNotification *) theNotification
{
  // For now, let's do the same that we do in -connectionTerminated:.
  [self connectionTerminated: theNotification];
}

- (void) connectionTerminated: (NSNotification *) theNotification
{
  id o;

  o = [theNotification object];

  NSLog(@"Closing...");

  if (o != checkSMTP)
    {
      DESTROY(store);
    }
  else
    {
      [checkSMTP setDelegate: nil];
      DESTROY(checkSMTP);
    }
}

- (void) folderListCompleted: (NSNotification *) theNotification
{
  //NSLog(@"Done enumerating the folders!");
}

- (void) folderListSubscribedCompleted: (NSNotification *) theNotification
{
  //NSLog(@"Done enumerating the subscribed folders!");
  _ready = YES;
  [self imapList: nil];
}

- (void) folderSubscribeCompleted: (NSNotification *) theNotification
{
  FolderNode *aFolderNode;
  NSString *aString;

  aString = [[theNotification userInfo] objectForKey: @"Name"];
  aFolderNode = [Utilities folderNodeForPath: aString
			   using: allFolders
			   separator: [store folderSeparator]];
			   
  if ( ![allVisibleFolders containsObject: aString] )
    { 
      [allVisibleFolders addObject: aString];
    }
  
  [aFolderNode setSubscribed: YES];  
  [imapOutlineView setNeedsDisplay: YES];
}

- (void) folderSubscribeFailed: (NSNotification *) theNotification
{
  NSRunInformationalAlertPanel(_(@"Error!"),
			       _(@"An error occurred while subscribing to folder:\n%@."),
			       _(@"OK"),
			       NULL,
			       NULL,
			       [[theNotification userInfo] objectForKey: @"Name"]);
}

- (void) folderUnsubscribeCompleted: (NSNotification *) theNotification
{
  NSString *aString, *pathToFile;
  FolderNode *aFolderNode;
   
  aString = [[theNotification userInfo] objectForKey: @"Name"];
  aFolderNode = [Utilities folderNodeForPath: aString
			   using: allFolders
			   separator: [store folderSeparator]];

  [allVisibleFolders removeObject: aString];
  [aFolderNode setSubscribed: NO];  
  [imapOutlineView setNeedsDisplay: YES];
  
  // We remove the cache file.
  pathToFile = [NSString stringWithFormat: @"%@/IMAPCache_%@_%@", 
			 GNUMailUserLibraryPath(),
			 [store name],
			 [Utilities flattenPathFromString: aString
				    separator: [store folderSeparator]] ];
  
  NS_DURING
    [[NSFileManager defaultManager] removeFileAtPath: pathToFile
				    handler: nil];
  NS_HANDLER
    // Under GNUstep, if we pass something that can't be converted to a cString
    // to -removeFileAtPath, it throws an exception.
    NSDebugLog(@"Exception occurred while removing the cache file.");
  NS_ENDHANDLER
  
}

- (void) folderUnsubscribeFailed: (NSNotification *) theNotification
{
  NSRunInformationalAlertPanel(_(@"Error!"),
			       _(@"An error occurred while unsubscribing to folder:\n%@."),
			       _(@"OK"),
			       NULL,
			       NULL,
			       [[theNotification userInfo] objectForKey: @"Name"]);
}

@end


//
// Private implementation
//
@implementation AccountEditorWindowController (Private)

- (BOOL) _accountNameIsValid
{
  if ([self operation] == ACCOUNT_ADD)
    {
      NSString *aString;

      aString = [[personalAccountNameField stringValue] stringByTrimmingWhiteSpaces];

      if ([aString length] == 0 ||
	  [aString isEqualToString: _(@"<Specify the account name here>")] ||
	  [[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"] 
	     objectForKey: @"ACCOUNTS"] objectForKey: aString])
	{
	  NSRunInformationalAlertPanel(_(@"Error!"),
				       _(@"You must specify a valid account name."),
				       _(@"OK"),
				       NULL,
				       NULL,
				       NULL);
	  
	  return NO;
	}  
    }

  return YES;
}

//
// If the user HAS NOT specified one or the MAIL environment variable isn't defined,
// we try to guess the best path to the mail spool file a user would use.
//
- (void) _bestGuessMailspoolFile
{
  if ( [[[unixMailspoolFileField stringValue] stringByTrimmingWhiteSpaces] length] == 0 )
    {
      BOOL isDir;
      
      if ( [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat: @"/var/mail/%@", 
    								       NSUserName()]
    					   isDirectory: &isDir] && !isDir )
	{
	  [unixMailspoolFileField setStringValue: [NSString stringWithFormat: @"/var/mail/%@",
							       NSUserName()]];
	}
      else if ( [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat: @"/var/spool/mail/%@",
    									    NSUserName()]
    						isDirectory: &isDir] && ! isDir )
	{
	  [unixMailspoolFileField setStringValue: [NSString stringWithFormat: @"/var/spool/mail/%@",
							    NSUserName()]];
	}
      else if ( [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat: @"/usr/spool/mail/%@",
    									    NSUserName()]
    						isDirectory: &isDir] && ! isDir )
	{
	  [unixMailspoolFileField setStringValue: [NSString stringWithFormat: @"/usr/spool/mail/%@",
							    NSUserName()]];
	}
      else
	{
	  [unixMailspoolFileField setStringValue: _(@"< Please choose a mail spool file >")];
	}
    }
}


//
//
//
- (void) _connectToIMAPServer
{
  int ret;

  // If we already have a connection, do nothing.
  if (store)
    {
      return;
    }

  // We must establish a new connection to the IMAP server...
  if ([[receiveServerNameField stringValue] length] == 0 || 
      [[receiveUsernameField stringValue] length] == 0)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"You must specify a valid server name and username\nin the Receive tab."),
		      _(@"OK"), // default
		      NULL,     // alternate
		      NULL);
      return;
    }
  
  store = [[CWIMAPStore alloc] initWithName: [receiveServerNameField stringValue]
			       port: [receiveServerPortField intValue]];
  [store setDelegate: self];
  ret = [store connect];

  [receiveUseSecureConnection synchronizeTitleAndSelectedItem];

#warning support TLS
  if ([receiveUseSecureConnection indexOfSelectedItem] == SECURITY_SSL)
    {
      ret = [(CWTCPConnection *)[store connection] startSSL];
    }

  if (ret < 0)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"Unable to communicate with the IMAP server (%@)."),
		      _(@"OK"),
		      NULL,
		      NULL,
		      [receiveServerNameField stringValue]);
      DESTROY(store);
    }
}


//
//
//
- (BOOL) _nameAndAddressAreSpecified
{
  if ([[[personalNameField stringValue] stringByTrimmingWhiteSpaces] length] == 0 ||
      [[[personalEMailField stringValue] stringByTrimmingWhiteSpaces] length] == 0)
    {
      NSRunInformationalAlertPanel(_(@"Error!"),
				   _(@"You must specify your name and E-Mail address."),
				   _(@"OK"),
				   NULL,
				   NULL,
				   NULL);
      
      return NO;
    }  

  return YES;
}


//
//
//
- (void) _rebuildListOfSubscribedFolders
{
  NSEnumerator *theEnumerator;
  FolderNode *aFolderNode;
  NSString *aPath;
  
  [allVisibleFolders removeAllObjects];

  if ([[imapMatrix selectedCell] tag] == 1)
    {
      [allVisibleFolders addObjectsFromArray: [[store subscribedFolderEnumerator] allObjects]];
    }
  else
    {
      [allVisibleFolders addObjectsFromArray: [[store folderEnumerator] allObjects]];
    }
      
  theEnumerator = [allVisibleFolders objectEnumerator];
  
  while ((aPath = [theEnumerator nextObject]))
    { 
      aFolderNode = [Utilities folderNodeForPath: aPath
			       using: allFolders
			       separator: [store folderSeparator]];

      if (aFolderNode &&
	  aFolderNode != allFolders)
	{
	  [aFolderNode setSubscribed: YES];
	}
      else
        {
          [aFolderNode setSubscribed: NO];
        }
    }
}


//
// This medhod is used to verify that we don't have an other IMAP account
// with the same username @ servername defined in an other profile. That
// would cause troubles since we wouldn't know which profile to use
// if we have an URLName object with something like imap://ludovic@Sophos.ca/INBOX.
//
- (BOOL) _receiveInformationIsValid
{
  NSString *theAccountName, *aServerName, *aUsername;
  NSEnumerator *theEnumerator;
  
  // We don't need to do any verification if it's a POP3/UNIX account or
  // if we are editing.
  [receivePopUp synchronizeTitleAndSelectedItem];
  if ( [receivePopUp indexOfSelectedItem] != 1 ||
       [self operation] == ACCOUNT_EDIT )
    {
      return YES;
    }

  theEnumerator = [[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"] 
		     objectForKey: @"ACCOUNTS"] keyEnumerator];

  aUsername = [[receiveUsernameField stringValue] stringByTrimmingWhiteSpaces];
  aServerName = [[receiveServerNameField stringValue] stringByTrimmingWhiteSpaces];

  while ((theAccountName = [theEnumerator nextObject]))
    {
      NSDictionary *allValues;

      allValues = [[[[[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"] 
		      objectForKey: @"ACCOUNTS"] objectForKey: theAccountName] objectForKey: @"RECEIVE"];

      if ( [[allValues objectForKey: @"SERVERTYPE"] intValue] == IMAP && 
	   [[allValues objectForKey: @"USERNAME"] isEqualToString: aUsername] &&
	   [[allValues objectForKey: @"SERVERNAME"] isEqualToString: aServerName] )
	{
	  NSRunInformationalAlertPanel(_(@"Error!"),
				       _(@"You already defined an IMAP account with the same\ninformation in the %@ account."),
				       _(@"OK"),
				       NULL,
				       NULL,
				       theAccountName);
	  return NO;
	}
    }
  
  return YES;
}


//
// This method verifies that the information specified in the Send panel
// are valid.
//
- (BOOL) _sendInformationIsValid
{
  [sendTransportMethodPopUpButton synchronizeTitleAndSelectedItem];

  if ( ([sendTransportMethodPopUpButton indexOfSelectedItem]+1) == TRANSPORT_MAILER &&
       [[[sendMailerField stringValue] stringByTrimmingWhiteSpaces] length] == 0 )
    {
      NSRunInformationalAlertPanel(_(@"Error!"),
				   _(@"You must specify a valid Mailer path in the Send tab."),
				   _(@"OK"),
				   NULL,
				   NULL,
				   NULL);
      return NO;
    }
  else if ( ([sendTransportMethodPopUpButton indexOfSelectedItem]+1) == TRANSPORT_SMTP &&
	    [[[sendSMTPHostField stringValue] stringByTrimmingWhiteSpaces] length] == 0 )
    {
      NSRunInformationalAlertPanel(_(@"Error!"),
				   _(@"You must specify a valid SMTP host name in the Send tab."),
				   _(@"OK"),
				   NULL,
				   NULL,
				   NULL);
      return NO;
    }

  return YES;
}


//
//
//
- (BOOL) _mailboxesSelectionIsValid
{
  [pop3DefaultInboxPopUpButton synchronizeTitleAndSelectedItem];
  [unixDefaultInboxPopUpButton synchronizeTitleAndSelectedItem];
  [receivePopUp synchronizeTitleAndSelectedItem];

  if (([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"POP3")] && [pop3DefaultInboxPopUpButton indexOfSelectedItem] == 0) ||
      ([[receivePopUp titleOfSelectedItem] isEqualToString: _(@"UNIX")] && [unixDefaultInboxPopUpButton indexOfSelectedItem] == 0))
    {
      NSRunInformationalAlertPanel(_(@"Error!"),
				   _(@"You must select a valid mailbox in the Receive options tab."),
				   _(@"OK"),
				   NULL,
				   NULL);
      return NO;
    }

  return YES;
}


//
//
//
- (void) _saveChangesForMailboxesPopUpButton: (NSPopUpButton *) thePopUpButton
					name: (NSString *) theName
				  dictionary: (NSMutableDictionary *) theMutableDictionary
{
  FolderNode *aFolderNode;
  NSString *aString;
  
  [thePopUpButton synchronizeTitleAndSelectedItem];
    
  //
  // FIXME: We must verify for, at least, local store if the folder is "selectable". 
  //
  aFolderNode = [(FolderNodePopUpItem *)[thePopUpButton selectedItem] folderNode];
  
  if ([aFolderNode parent] == allNodes)
    {
      NSDebugLog(@"Selected an invalid mailbox, ignoring.");
      return;
    }
  
  aString = [Utilities stringValueOfURLNameFromFolderNode: aFolderNode
		       serverName: [[receiveServerNameField stringValue] stringByTrimmingWhiteSpaces]
		       username: [[receiveUsernameField stringValue] stringByTrimmingWhiteSpaces]];
  [theMutableDictionary setObject: aString  forKey: theName];
}


//
//
//
- (void) _setEnableReceiveUIElements: (BOOL) aBOOL
{
  [receiveServerNameField setEditable: aBOOL];
  [receiveServerPortField setEditable: aBOOL];
  [receiveUsernameField setEditable: aBOOL];

  if (aBOOL && [receiveRememberPassword state] == NSOnState)
    {
      [receivePasswordSecureField setEditable: YES];
    }
  else
    {
      [receivePasswordSecureField setEditable: NO];
    }

  [receiveRememberPassword setEnabled: aBOOL];
  [receiveCheckOnStartup setEnabled: aBOOL];
}

@end
