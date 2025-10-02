/*
**  EditWindowController.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2014-2023 Riccardo Mottola
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

#import "EditWindowController.h"

#import "AddressBookController.h"
#import "AutoCompletingTextField.h"

#import "ExtendedMenuItem.h"
#import "ExtendedTextAttachmentCell.h"
#import "ExtendedTextView.h"
#import "GNUMail.h"
#import "GNUMailBundle.h"
#import "Constants.h"
#import "LabelWidget.h"
#import "MailboxManagerController.h"
#import "MailWindowController.h"
#import "MimeTypeManager.h"
#import "MimeType.h"
#import "NSAttributedString+Extensions.h"
#import "NSFont+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"

#import <Pantomime/CWCharset.h>
#import <Pantomime/CWConstants.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWMIMEMultipart.h>
#import <Pantomime/CWMIMEUtility.h>
#import <Pantomime/CWPart.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/CWService.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#include <math.h>
#include <time.h>

#define AB_MATCH_ELEMENT(class, property, prefix) \
	[class searchElementForProperty: property \
				  label: nil \
				    key: nil \
				  value: prefix \
			     comparison: kABEqualCaseInsensitive]

#define SHOW_ALERT_PANEL(s) \
  NSRunInformationalAlertPanel(_(@"Error!"), \
			       _(@"An error occurred while decoding %@. Please fix this address."), \
			       _(@"OK"), \
			       NULL, \
			       NULL, \
			       s);

#ifdef MACOSX
#define L_X 8
#define L_HEIGHT 17
#define L_WIDTH 55

#define Y_DELTA 26
#define W_DELTA 91

#define F_X 71
#define F_HEIGHT 22

#define S_X 0
#define S_Y 0
#else
#define L_X 5
#define L_HEIGHT 17
#define L_WIDTH 55

#define Y_DELTA 25
#define W_DELTA 79

#define F_X 65
#define F_HEIGHT 21

#define S_X 0
#define S_Y 0
#endif

//
// private methods
//
@interface EditWindowController (Private)

- (void) _adjustNextKeyViews;

- (void) _adjustWidgetsPosition;

- (void) _appendAddress: (NSArray *) theAddress
	    toTextField: (NSTextField *) theTextField;

- (NSData *) _dataValueOfRedirectedMessage;

- (float) _estimatedSizeOfMessage;

- (void) _loadAccessoryViews;

- (void) _loadAccounts;
- (void) _loadCharset;

- (NSString *) _loadSignature;

- (void) _openPanelDidEnd: (NSOpenPanel *) theOpenPanel
               returnCode: (NSInteger) theReturnCode
              contextInfo: (void *) theContextInfo;

- (void) _replaceSignature;

- (NSString *) _plainTextContentFromTextView;

- (NSArray *) _recipientsFromString: (NSString *) theString;

- (void) _setPlainTextContentFromString: (NSString *) theString
                                 inPart: (CWPart *) thePart;

#ifdef MACOSX
- (void) _sheetDidEnd: (NSWindow *) sheet
           returnCode: (NSInteger) returnCode
          contextInfo: (void *) contextInfo;

- (void) _sheetDidDismiss: (NSWindow *) sheet
               returnCode: (NSInteger) returnCode
              contextInfo: (void *) contextInfo;
#endif

- (void) _updateViewWithMessage: (CWMessage *) theMessage
                appendSignature: (BOOL) aBOOL;

- (void) _updateSizeLabel;

- (void) _updatePart: (CWPart *) thePart
 usingTextAttachment: (NSTextAttachment *) theTextAttachment;

@end


//
//
//
@implementation EditWindowController

- (id) initWithWindowNibName: (NSString *) windowNibName
{  
  NSDictionary *allAccounts;
  NSToolbar *aToolbar;
  
  allAccounts = [Utilities allEnabledAccounts];

  // We first verify if we have at least one transport agent defined
  if (!allAccounts || [allAccounts count] == 0)
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"You must have at least one transport agent defined and enabled.\nSee Preferences -> Account."),
		      _(@"OK"), // default
		      NULL,     // alternate
		      NULL);
      
      AUTORELEASE(self);
      return nil;
    }



  self = [super initWithWindowNibName: windowNibName];
  
  //
  // We create our mutable array and our mutable dictionary allowing
  // us to dynamically add toolbar items.
  //
  allowedToolbarItemIdentifiers = [[NSMutableArray alloc] initWithObjects: NSToolbarSeparatorItemIdentifier,
							  NSToolbarSpaceItemIdentifier,
							  NSToolbarFlexibleSpaceItemIdentifier,
							  NSToolbarCustomizeToolbarItemIdentifier, 
							  @"send",
							  @"insert",
							  @"add_cc",
							  @"add_bcc",
							  @"addresses",
							  @"save_in_drafts",
							  nil];
  
  additionalToolbarItems = [[NSMutableDictionary alloc] init];

  //
  // We set our window title and edited attributes
  //
  [[self window] setTitle: @""];
  [[self window] setDocumentEdited: NO];
  
  // We initialize our toolbar
  aToolbar = [[NSToolbar alloc] initWithIdentifier: @"EditWindowToolbar"];
  [aToolbar setDelegate: self];
  [aToolbar setAllowsUserCustomization: YES];
  [aToolbar setAutosavesConfiguration: YES];
  [[self window] setToolbar: aToolbar];
  RELEASE(aToolbar);
  
  RETAIN(ccLabel); RETAIN(ccText);
  RETAIN(bccLabel); RETAIN(bccText);

  // We initialize our variables
  [self setShowCc: NO];
  [self setShowBcc: NO];
  [self setUnmodifiedMessage: nil];
  [self setSignaturePosition: SIGNATURE_END];

  // We set some ivars
  _mode = GNUMailComposeMessage;
  previousSignatureValue = nil;

  // We load our accessory views
  [self _loadAccessoryViews];

  // We load our accounts and our charsets
  [self _loadAccounts];
  [self _loadCharset];

  // We finally set our autosave window frame name and restore the one from the user's defaults.
  [[self window] setFrameAutosaveName: @"EditWindow"];
  [[self window] setFrameUsingName: @"EditWindow"];
  
  // We tile our windows
  if ([GNUMail lastAddressTakerWindowOnTop])
    {
      NSRect aRect;

      aRect = [[[GNUMail lastAddressTakerWindowOnTop] window] frame];
      aRect.origin.x += 15;
      aRect.origin.y -= 10;
      [[self window] setFrame: aRect  display: NO];
    }

  // Set the data sources and delegates for the address text fields
  [toText setCommaDelimited: YES];
  [toText setDataSource: self];
  [toText setDelegate: self];

  [ccText setCommaDelimited: YES];
  [ccText setDataSource: self];
  [ccText setDelegate: self];

  [bccText setCommaDelimited: YES];
  [bccText setDataSource: self];
  [bccText setDelegate: self];
  
  // Enable spellchecking, if needed
  if ([[NSUserDefaults standardUserDefaults] boolForKey: @"ENABLE_SPELL_CHECKING"])
    {
      [textView setContinuousSpellCheckingEnabled: YES];
    }

  // Allow undo
  [textView setAllowsUndo: YES];
  [textView setImportsGraphics: YES];

  // Set updateColors
  updateColors = YES;
  
  // Set the sizes for the scroll bars
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"SCROLLER_SIZE"  default: NSOffState] == NSOffState)
    {
      [[scrollView verticalScroller] setControlSize: NSRegularControlSize];
      [[scrollView horizontalScroller] setControlSize: NSRegularControlSize];
    }
  else
    {
      [[scrollView verticalScroller] setControlSize: NSSmallControlSize];
      [[scrollView horizontalScroller] setControlSize: NSSmallControlSize];
    }
    
  // We the font to a fixed pitch, if we need to. Otherwise, we set it to the font used to view the parts
  // in the MailWindow/MessageViewWindow's textview.
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] == NSOnState)
    {
      [textView setFont: [NSFont plainTextMessageFont]];
    }
  else
    {
      [textView setFont: [NSFont messageFont]];
    }

  // We add our observer to update our size label if the size of the text view has changed
  [[NSNotificationCenter defaultCenter] 
    addObserver: self
    selector: @selector (_updateSizeLabel) 
    name: @"NSViewFrameDidChangeNotification" 
    object: textView];
  
  [[self window] setInitialFirstResponder: toText];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"EditWindowController: -dealloc");
  
  [[self window] setDelegate: nil]; // FIXME not necessary in cocoa and in gnustep as of 2014-02-11, only for compatibility with old releases
  [[NSNotificationCenter defaultCenter] removeObserver: self];

  RELEASE(ccLabel); RELEASE(ccText);
  RELEASE(bccLabel); RELEASE(bccText);

  TEST_RELEASE(message);
  TEST_RELEASE(unmodifiedMessage);
  TEST_RELEASE(previousSignatureValue);
  TEST_RELEASE(charset);

  RELEASE(send);
  RELEASE(insert);
  RELEASE(addCc);
  RELEASE(addBcc);
  RELEASE(addresses);
  RELEASE(saveInDrafts);

  RELEASE(allowedToolbarItemIdentifiers);
  RELEASE(additionalToolbarItems);
  RELEASE(addressCompletionCandidates);

  [super dealloc];
}

//
// Implementation of the AddressTaker protocol.
//
- (void) takeToAddress: (NSArray *) theAddress
{
  [self _appendAddress: theAddress  toTextField: toText];
  [self controlTextDidChange: [NSNotification notificationWithName: @"" object: toText]];
}


//
//
//
- (void) takeCcAddress: (NSArray *) theAddress
{
  if (![self showCc])
    {
      [self showCc: self];
    }
  
  [self _appendAddress: theAddress  toTextField: ccText];
  [self controlTextDidChange: [NSNotification notificationWithName: @"" object: ccText]];
}


//
//
//
- (void) takeBccAddress: (NSArray *) theAddress
{
  if (![self showBcc])
    {
      [self showBcc: self];
    }
  
  [self _appendAddress: theAddress  toTextField: bccText];
  [self controlTextDidChange: [NSNotification notificationWithName: @"" object: bccText]];
}


//
// action methods
//
- (IBAction) insertFile: (id) sender
{
  NSOpenPanel *oPanel;
  
  oPanel = [NSOpenPanel openPanel];
  [oPanel setAllowsMultipleSelection:YES];
  
#ifdef MACOSX
  [oPanel beginSheetForDirectory: [GNUMail currentWorkingPath] file:nil types:nil
	  modalForWindow: [self window] 
	  modalDelegate: self
	  didEndSelector: @selector(_openPanelDidEnd: returnCode: contextInfo:)
	  contextInfo: nil];
#else
  [self _openPanelDidEnd: oPanel 
	returnCode: [oPanel runModalForDirectory: [GNUMail currentWorkingPath]  file: nil  types: nil]
	contextInfo: nil];
#endif
}


//
//
//
- (IBAction) showBcc: (id) sender
{    
  [self setShowBcc: ![self showBcc]];
  [[[self window] contentView] setNeedsDisplay: YES];
}


//
//
//
- (IBAction) showCc: (id) sender
{ 
  [self setShowCc: ![self showCc]];
  [[[self window] contentView] setNeedsDisplay: YES];
}


//
// 
//
- (IBAction) accountSelectionHasChanged: (id) sender
{
  //NSDictionary *theAccount;
  //NSString *aString;
  //NSRange aRange;
  //int i;

  // We synchronize our selection from the popup
  [accountPopUpButton synchronizeTitleAndSelectedItem];

  /*theAccount = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [(ExtendedMenuItem *)[accountPopUpButton selectedItem] key]];
  
  for (i = 0; i < [transportMethodPopUpButton numberOfItems]; i++)
    {
      if ([[[theAccount objectForKey: @"SEND"] objectForKey: @"TRANSPORT_METHOD"] intValue] == TRANSPORT_MAILER)
	{
	  aString = [[theAccount objectForKey: @"SEND"] objectForKey: @"MAILER_PATH"];
	}
      else
	{
	  aString = [[theAccount objectForKey: @"SEND"] objectForKey: @"SMTP_HOST"];
	}

      aRange = [[transportMethodPopUpButton itemTitleAtIndex: i] rangeOfString: aString];

      if (aRange.length)
	{
	  [transportMethodPopUpButton selectItemAtIndex: i];
	  [transportMethodPopUpButton synchronizeTitleAndSelectedItem];
	  [self _replaceSignature];
	  return;
	}
    }
  
  [transportMethodPopUpButton selectItemAtIndex: 0];
  [transportMethodPopUpButton synchronizeTitleAndSelectedItem];*/
  [self _replaceSignature];
}


//
//
//
- (IBAction) sendMessage: (id) sender
{
  NSString *aKey;
  NSDictionary *allValues;
  Task *aTask;
  id aMessage;
  int op;


  // We first try to initialize our message with all the information 
  if (_mode != GNUMailRedirectMessage && ![self updateMessageContentFromTextView])
    {
      return;
    }

  // We sync our popup
  //[transportMethodPopUpButton synchronizeTitleAndSelectedItem];
  [accountPopUpButton synchronizeTitleAndSelectedItem];

  aKey = [(ExtendedMenuItem *)[accountPopUpButton selectedItem] key];

  // We check if a 'Sent' mailbox has been specified for this particular account.
  // If not, we warn the user about this.
  if (![[[[Utilities allEnabledAccounts] objectForKey: aKey] objectForKey: @"MAILBOXES"] objectForKey: @"SENTFOLDERNAME"])
    {
      int choice;

      choice = NSRunAlertPanel(_(@"Warning!"),
			       _(@"You don't have a sent mail folder set up to keep copies of your sent mail.\nTo set up the sent mail folder, bring up the contextual menu on the mailbox list\nfor the folder you want to use as a sent mail folder and choose\n\"Set Mailbox as > Sent for Account > %@\"."),
			       _(@"Send Anyway"),
			       _(@"Cancel"),
			       NULL,
			       aKey);
      
      if (choice == NSAlertAlternateReturn) return;
    }

  // We get our transport method type
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: aKey] objectForKey: @"SEND"];
										
  if ([[allValues objectForKey: @"TRANSPORT_METHOD"] intValue] == TRANSPORT_SMTP)
    {
      op = SEND_SMTP;
    }
  else
    {
      op = SEND_SENDMAIL;
    }

  aTask = [[Task alloc] init];

  // We get the message we want to assign to our Task object, depending on
  // if we are redirecting or not the original message.
  if (_mode == GNUMailRedirectMessage)
    {
      aMessage = [self _dataValueOfRedirectedMessage];
      
      if (!aMessage)
	{
	  NSRunAlertPanel(_(@"Error!"),
			  _(@"Unable to create a valid message for redirection.\nYou have to specify at least one To recipient."),
			  _(@"OK"),
			  NULL,
			  NULL);
	  RELEASE(aTask);
	  return;
	}

      aTask->total_size = (float)[(NSData *)aMessage length]/(float)1024;
    }
  else
    {
      aMessage = [self message];
      aTask->total_size = [self _estimatedSizeOfMessage];
    }
  
  aTask->op = op;
  aTask->sub_op = _mode;
  [aTask setMessage: aMessage];
  [aTask setUnmodifiedMessage: [self unmodifiedMessage]];
  [aTask setKey: aKey];
  [aTask setSendingKey: aKey];
  [[TaskManager singleInstance] addTask: aTask];
  RELEASE(aTask);

  // If this message is already in the drafts folder, set the "deleted" flag 
  // of the original message.
  if (_mode == GNUMailRestoreFromDrafts)
    {
      CWFlags *theFlags;
      
      theFlags = [[[self message] flags] copy];
      [theFlags add: PantomimeDeleted];
      [[self message] setFlags: theFlags];
      RELEASE(theFlags);
            
      [[NSNotificationCenter defaultCenter] postNotificationName: ReloadMessageList
					    object: nil
					    userInfo: nil];
    }
  
  
  // Since we're done, we close our window.
  [self close];
}


//
//
//
- (void) controlTextDidEndEditing: (NSNotification *) aNotification
{
  NSControl *theControl = [aNotification object];

  if (theControl == toText ||
      theControl == ccText ||
      theControl == bccText)
    {
      NSArray *allRecipientsFromString;
      NSMutableArray *allRecipients;
      NSString *aString;
      NSUInteger i;
      
      aString = [[theControl stringValue] stringByTrimmingWhiteSpaces];
      
      if ([aString length] == 0)
        {
	  return;
        }
      
      allRecipientsFromString = [self _recipientsFromString: aString];
      allRecipients = [NSMutableArray array];
        
      for (i = 0; i < [allRecipientsFromString count]; i++)
        {
	  ABSearchElement *aSearchElement;
	  NSArray *allMembers;
	  NSString *aValue;
	  
	  aValue = [allRecipientsFromString objectAtIndex: i];

	  aSearchElement = [ABGroup searchElementForProperty: kABGroupNameProperty
				    label: nil
				    key: nil
				    value: aValue
				    comparison: kABPrefixMatchCaseInsensitive];

	  allMembers = [[[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: aSearchElement]
			  lastObject] members];

  	  if ([allMembers count])
	    {
  	      NSUInteger j;

  	      for (j = 0; j < [allMembers count]; j++)
		{
		  /* Don't add names with invalid addresses */
		  NSArray *emails = [[allMembers objectAtIndex: j] valueForProperty: kABEmailProperty];
		  if ([emails count])
		    {
		      [allRecipients addObject: [[allMembers objectAtIndex: j] formattedValue]];
		    }
		}
	    }
	  // person
	  else
            {
	      [allRecipients addObject: aValue];
            }
        }
        
      [theControl setStringValue: [allRecipients componentsJoinedByString: @", "]];
    }
}


//
//
//
- (BOOL) isACompletion: (NSString *) theCandidate
{
  return [[self allCompletionsForPrefix: theCandidate] containsObject: theCandidate];
}


//
//
//
- (NSString *) completionForPrefix: (NSString *) thePrefix
{
  NSArray *allCompletions;
  NSString *completion;

  allCompletions = [self allCompletionsForPrefix: thePrefix];

  completion = nil;

  if ([allCompletions count] > 0)
    {
      completion = [allCompletions objectAtIndex:0];
    }

  return completion;
}


//
//
//
- (NSArray *) allCompletionsForPrefix: (NSString *) thePrefix
{
  NSArray *searchResults; NSMutableArray *retval;
  NSUInteger i;

  searchResults = [[AddressBookController singleInstance] addressesWithPrefix: thePrefix];
  retval = [NSMutableArray arrayWithCapacity: [searchResults count]];

  for(i = 0; i < [searchResults count]; i++)
    {
      if ([[searchResults objectAtIndex: i] isKindOfClass: [ABGroup class]])
	{
	  [retval addObject: [[searchResults objectAtIndex: i] valueForProperty: kABGroupNameProperty]];
	}
      else
	{
	  [retval addObjectsFromArray: [[searchResults objectAtIndex: i] formattedValuesForPrefix: thePrefix]];
	}
    }
  
  return retval;
}


//
//
//
- (void) controlTextDidChange: (NSNotification *) aNotification
{
  if ( [aNotification object] == subjectText )
    {
      if ([[subjectText stringValue] length] > 0)
	{
	  [[self window] setTitle: [subjectText stringValue]];
	}
      else
	{
	  [[self window] setTitle: _(@"(no subject)")];
	}
    }
  else if ([aNotification object] == toText ||
	   [aNotification object] == ccText ||
	   [aNotification object] == bccText)
    {
      if ((_mode == GNUMailRedirectMessage && ![message rawSource]) ||
	  (_mode == GNUMailRestoreFromDrafts && ![message content]) ||
	  ([[toText stringValue] length] == 0 &&
	   [[ccText stringValue] length] == 0 &&
	   [[bccText stringValue] length] == 0))
	{
	  [send setEnabled: NO];
        }
      else
        {
	  [send setEnabled: YES];
        }
    }
     
  if (_mode != GNUMailRedirectMessage)
    {
      [[self window] setDocumentEdited: YES];
    }
}


//
//
//
- (BOOL) shouldChangeTextInRange: (NSRange) affectedCharRange 
	       replacementString: (NSString *) replacementString
{
  NSString *aString;

  aString = [[[textView textStorage] string] substringWithRange: affectedCharRange];
  
  if ( (([replacementString length] > 0) && 
	(([replacementString characterAtIndex: 0] =='\n') ||
	 ([replacementString characterAtIndex: 0] =='>')))
       ||
       (([aString length] > 0) && ([aString characterAtIndex: 0] == '>')) )
    {
      updateColors = YES;
      affectedRangeForColors = NSMakeRange(affectedCharRange.location, [replacementString length]);
    }
  
  return YES;
}


//
//
//
- (void) textDidChange: (NSNotification *) aNotification
{
  if (_mode != GNUMailRedirectMessage)
    {
      [[self window] setDocumentEdited: YES];
    }

  [self _updateSizeLabel];

  if (updateColors)
    {
      NSTextStorage *aTextStorage;

      aTextStorage = [textView textStorage];
      
      if ([aTextStorage length] > 1)
	{
	  NSRange aRange, r;
	  
	  r = [textView selectedRange];
	  aRange = [[aTextStorage string] lineRangeForRange: affectedRangeForColors];
	  
	  if (aRange.length)
	    {
	      NSMutableAttributedString *aMutableAttributedString;

	      aMutableAttributedString = [[NSMutableAttributedString alloc]
					   initWithAttributedString: [aTextStorage attributedSubstringFromRange: aRange]];
	      [aMutableAttributedString quote];
	      [aTextStorage replaceCharactersInRange: aRange  withAttributedString: aMutableAttributedString];
	      RELEASE(aMutableAttributedString);
	    }
	  
	  [textView setSelectedRange: r];
	}
      
      updateColors = NO;
    }
}

//
//
//
- (BOOL) windowShouldClose: (id) sender
{
  if ([[self window] isDocumentEdited])
    {
#ifdef MACOSX
      NSBeginAlertSheet(_(@"Closing..."),
			_(@"Cancel"),                                        // defaultButton
			_(@"Save in Drafts"),                                // alternateButton
			_(@"No"),                                            // otherButton
			[self window],
			self,                                                // delegate
			@selector(_sheetDidEnd:returnCode:contextInfo:),     // didEndSelector
			@selector(_sheetDidDismiss:returnCode:contextInfo:), // didDismissSelector
			nil,                                                 // contextInfo
		      _(@"Would you like to save this message in the Drafts folder?"));

      return NO;
#else
      int choice;
      
      choice = NSRunAlertPanel(_(@"Closing..."),
			       _(@"Would you like to save this message in the Drafts folder?"),
			       _(@"Cancel"),         // default
			       _(@"Save in Drafts"), // alternate
			       _(@"No"));            // other return
      
      // We don't want to close the window
      if (choice == NSAlertDefaultReturn)
	{
	  return NO;
	}
      // Yes we want to close it, and we also want to save the message to the Drafts folder.
      else if (choice == NSAlertAlternateReturn)
	{
	  // We append the message to the Drafts folder. 
	  [[MailboxManagerController singleInstance] saveMessageInDraftsFolderForController: self];
	}
#endif
    }
  
  return YES;
}


//
//
//
- (void) windowWillClose: (NSNotification *) theNotification
{ 
  if ([GNUMail lastAddressTakerWindowOnTop] == self)
    {
      [GNUMail setLastAddressTakerWindowOnTop: nil];
    }
  
  [GNUMail removeEditWindow: [self window]];
}


//
//
//
- (void) windowDidBecomeMain: (NSNotification *) theNotification
{
  [GNUMail setLastAddressTakerWindowOnTop: self];
}

//
//
//
- (void) windowDidLoad
{ 
  // We add our observer for our two notifications
  [[NSNotificationCenter defaultCenter]
    addObserver: self
    selector: @selector(_loadAccounts)
    name: AccountsHaveChanged
    object: nil];

  // We add our window from our list of opened windows
  [GNUMail addEditWindow: [self window]];
}


//
//
//
- (CWMessage *) message
{
  return message;
}


//
//
//
- (void) setMessage: (CWMessage *) theMessage
{  
  if (theMessage)
    {
      ASSIGN(message, theMessage);
      [self _updateViewWithMessage: message  appendSignature: YES];
      [self _updateSizeLabel];
    }
  else
    {
      DESTROY(message);
    }
}


//
//
//
- (CWMessage *) unmodifiedMessage
{
  return unmodifiedMessage;
}


//
//
//
- (void) setUnmodifiedMessage: (CWMessage *) theUnmodifiedMessage
{
  if (theUnmodifiedMessage)
    {
      ASSIGN(unmodifiedMessage, theUnmodifiedMessage);
    }
  else
    {
      DESTROY(unmodifiedMessage);
    }
}


//
//
//
- (void) setMessageFromDraftsFolder: (CWMessage *) theMessage
{
  if (theMessage)
    {
      ASSIGN(message, theMessage);
      [self _updateViewWithMessage: message  appendSignature: NO];
      [self _updateSizeLabel];
    }
  else
    {
      DESTROY(message);
    }
}


//
//
//
- (BOOL) showCc
{
  return showCc;
}


//
//
//
- (void) setShowCc: (BOOL) theBOOL
{
  showCc = theBOOL;
  
  if (showCc)
    {
      [addCc setLabel: _(@"Remove Cc")];
      [addCc setImage: [NSImage imageNamed: @"remove_cc_32.tiff"]];
      [[[self window] contentView] addSubview: ccLabel];
      [[[self window] contentView] addSubview: ccText];
    }
  else
    {
      [addCc setLabel: _(@"Add Cc")];
      [addCc setImage: [NSImage imageNamed: @"add_cc_32.tiff"]];
      [ccLabel removeFromSuperviewWithoutNeedingDisplay];
      [ccText removeFromSuperviewWithoutNeedingDisplay];
    }
  
  [self _adjustWidgetsPosition];
  [self _adjustNextKeyViews];
}


//
//
//
- (BOOL) showBcc
{
  return showBcc;
}


//
//
//
- (void) setShowBcc: (BOOL) theBOOL
{
  showBcc = theBOOL;
 
  if (showBcc)
    {
      [addBcc setLabel: _(@"Remove Bcc")];
      [addBcc setImage: [NSImage imageNamed: @"remove_bcc_32.tiff"]];
      [[[self window] contentView] addSubview: bccLabel];
      [[[self window] contentView] addSubview: bccText];
    }
  else
    {
      [addBcc setLabel: _(@"Add Bcc")];
      [addBcc setImage: [NSImage imageNamed: @"add_bcc_32.tiff"]];
      [bccLabel removeFromSuperviewWithoutNeedingDisplay];
      [bccText removeFromSuperviewWithoutNeedingDisplay];
    }

  [self _adjustWidgetsPosition];
  [self _adjustNextKeyViews];
}


//
//
//
- (int) signaturePosition
{
  return signaturePosition;
}


//
//
//
- (void) setSignaturePosition: (int) thePosition
{
  signaturePosition = thePosition;
}


//
//
//
- (NSPopUpButton *) accountPopUpButton
{
  return accountPopUpButton;
}


//
// Changes and select the right account in the popup button.
//
- (void) setAccountName: (NSString *) theAccountName
{
  [Utilities loadAccountsInPopUpButton: accountPopUpButton  select: theAccountName];
  [self accountSelectionHasChanged: nil];
}


//
//
//
- (NSString *) charset
{
  return charset;
}

- (void) setCharset: (NSString *) theCharset
{
  if (theCharset)
    {
      ASSIGN(charset, theCharset);
    }
  else
    {
      DESTROY(charset);
    }
}


//
//
//
- (int) mode
{
  return _mode;
}

- (void) setMode: (int) theMode
{
  _mode = theMode;

  if (_mode == GNUMailRedirectMessage)
    {
      [textView setEditable: NO];
      [subjectText setEditable: NO];
      [send setEnabled: NO];
      [insert setEnabled: NO];
    }
}


//
//
//
- (NSTextView *) textView
{
  return textView;
}


//
// Other methods
//
- (BOOL) updateMessageContentFromTextView
{
  NSTextStorage *textStorage;
  NSArray *theArray;

  NSDictionary *allAdditionalHeaders, *allValues;
 
  CWInternetAddress *anInternetAddress;
  BOOL hasFoundUserAgentHeader;
  NSString *aString;
  NSUInteger i;
  
  // We initialize our boolean value to false
  hasFoundUserAgentHeader = NO;
  
  // We get the current selected account when sending this email
  [accountPopUpButton synchronizeTitleAndSelectedItem];
  
  // Then, we get our account from our user defaults
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [(ExtendedMenuItem *)[accountPopUpButton selectedItem] key]]
		objectForKey: @"PERSONAL"];
  
  // We set the From header value
  anInternetAddress = [[CWInternetAddress alloc] initWithPersonal: [allValues objectForKey: @"NAME"]
						 address: [allValues objectForKey: @"EMAILADDR"]];
  [message setFrom: anInternetAddress];
  RELEASE(anInternetAddress);
  
  // We set the Reply-To address (if we need too)
  aString = [allValues objectForKey: @"REPLYTOADDR"];
  
  if (aString && [[aString stringByTrimmingWhiteSpaces] length] > 0)
    {
      anInternetAddress = [[CWInternetAddress alloc] initWithString: aString];
      
      if (anInternetAddress)
	{
	  [message setReplyTo: [NSArray arrayWithObject: anInternetAddress]];
	  RELEASE(anInternetAddress);
	}
    }
  else
    {
      [message setReplyTo: nil];
    }
  
  // We set the Organization header value (if we need to)
  aString = [allValues objectForKey: @"ORGANIZATION"];
  
  if (aString && [[aString stringByTrimmingWhiteSpaces] length] > 0)
    {
      [message setOrganization: aString];
    }

  // For now, if there are recipients, we remove them in case a user add or changed them manually
  if ([message recipientsCount] > 0) 
    {
      [message removeAllRecipients];
    }

  // We decode our recipients, let's begin with the To field.
  if ([[[toText stringValue] stringByTrimmingWhiteSpaces] length] > 0)
    {
      theArray = [self _recipientsFromString: [toText stringValue] ];
      
      for (i = 0; i < [theArray count]; i++)
	{
	  anInternetAddress = [[CWInternetAddress alloc] initWithString: [theArray objectAtIndex:i]];
	  
	  if (!anInternetAddress)
	    {
	      SHOW_ALERT_PANEL([theArray objectAtIndex: i]);
	      return NO;
	    }
	  
	  [anInternetAddress setType: PantomimeToRecipient];
	  [message addRecipient: anInternetAddress];
	  RELEASE(anInternetAddress);
	}
    }

  // We decode our Cc field, if we need to
  if (showCc)
    {
      theArray = [self _recipientsFromString: [ccText stringValue]];
      
      for (i = 0; i < [theArray count]; i++)
	{
	  anInternetAddress = [[CWInternetAddress alloc] initWithString: [theArray objectAtIndex:i]];

	  if (!anInternetAddress)
	    {
	      SHOW_ALERT_PANEL([theArray objectAtIndex: i]);
	      return NO;
	    }

	  [anInternetAddress setType: PantomimeCcRecipient];
	  [message addRecipient: anInternetAddress];
	  RELEASE(anInternetAddress);
	}
      
    }

  // We decode our Bcc field, if we need to
  if (showBcc)
    {
      theArray = [self _recipientsFromString: [bccText stringValue]];
      
      for (i = 0; i < [theArray count]; i++)
	{
	  anInternetAddress = [[CWInternetAddress alloc] initWithString: [theArray objectAtIndex:i]];
	  
	  if (!anInternetAddress)
	    {
	      SHOW_ALERT_PANEL([theArray objectAtIndex: i]);
	      return NO;
	    }

	  [anInternetAddress setType: PantomimeBccRecipient];
	  [message addRecipient: anInternetAddress];
	  RELEASE(anInternetAddress);
	}
    }

  
  // We decode our Subject field
  [message setSubject: [subjectText stringValue]];
  
  // We finally add all our addition headers from the user defaults
  allAdditionalHeaders = [[NSUserDefaults standardUserDefaults] 
			   objectForKey: @"ADDITIONALOUTGOINGHEADERS"];
  
  if (allAdditionalHeaders)
    {
      NSEnumerator *anEnumerator;
      NSString *aKey, *aValue;

      anEnumerator = [allAdditionalHeaders keyEnumerator];
      
      while ((aKey = [anEnumerator nextObject]))
	{
	  // We get our value
	  aValue = [[allAdditionalHeaders objectForKey: aKey] stringByTrimmingWhiteSpaces];
	  
	  // We skip over additional headers with no specified value.
	  if ([aValue length] == 0)
	    {
	      continue;
	    }

	  if ([aKey compare: @"User-Agent"  options: NSCaseInsensitiveSearch] == NSOrderedSame)
	    {
	      hasFoundUserAgentHeader = YES;
	      continue;
	    }

	  // We add our X- if we don't have it
	  if (![aKey hasPrefix: @"X-"])
	    {
	      aKey = [NSString stringWithFormat: @"X-%@", aKey];
	    }
	  
	  if (![message headerValueForName: aKey])
	    {
	      [message addHeader: aKey  withValue: aValue];
	    }
	}
    }

  // We add our User-Agent: GNUMail (Version ...) header if the user hasn't defined one
  if (!hasFoundUserAgentHeader && ![message headerValueForName: @"User-Agent"])
  {
      [message addHeader: @"User-Agent"
	       withValue: [NSString stringWithFormat: @"GNUMail (Version %@)", GNUMailVersion()]];
    }

  // We get our text storage
  textStorage = [textView textStorage];
  
  // We now build our message body - considering all the attachments
  if ([textStorage length] == 1 && [textStorage containsAttachments]) 
    {
      NSTextAttachment *aTextAttachment;
      
      aTextAttachment = [textStorage attribute: NSAttachmentAttributeName		      
				     atIndex: 0
				     effectiveRange: NULL];
      
      [self _updatePart: message
	    usingTextAttachment: aTextAttachment];
    }
  else if (![textStorage containsAttachments])
    {
      [self _setPlainTextContentFromString: [textView string]
	    inPart: message];
    }
  else
    {         
      CWMIMEMultipart *aMimeMultipart;
      CWPart *aPart;      
      
      NSAutoreleasePool *pool;
      NSString *tmpString;

      // We create our local autorelease pool
      pool = [[NSAutoreleasePool alloc] init];

      aMimeMultipart = [[CWMIMEMultipart alloc] init];
      
      // We first decode our text/plain body
      aPart = [[CWPart alloc] init];

      [self _setPlainTextContentFromString: [self _plainTextContentFromTextView]
	    inPart: aPart];

      // We add our new part
      [aMimeMultipart addPart: aPart];
      RELEASE(aPart);

      // We get our text store string representation
      tmpString = [textStorage string];
      
      // We finally add all our attachments
      for (i = 0; i < [textStorage length]; i++)
	{
	  NSTextAttachment *aTextAttachment;
	  
	  if ( [tmpString characterAtIndex: i] != NSAttachmentCharacter )
	    {
	      continue;
	    }

	  aTextAttachment = [textStorage attribute: NSAttachmentAttributeName		      
					 atIndex: i 
					 effectiveRange: NULL];
	  if (aTextAttachment) 
	    {      
	      if ( [[aTextAttachment attachmentCell] respondsToSelector: @selector(part)] )
		{
		  aPart = [(ExtendedTextAttachmentCell *)[aTextAttachment attachmentCell] part];
		}
	      else
		{
		  aPart = nil;
		}

	      if (aPart)
		{
		  [aMimeMultipart addPart: (CWPart *)aPart];
		}
	      else
		{
		  aPart = [[CWPart alloc] init];
		  
		  [self _updatePart: aPart
			usingTextAttachment: aTextAttachment];
		  
		  [aMimeMultipart addPart: aPart];
		  RELEASE(aPart);		 
		}
	      
	    } // if ( aTextAttachment ) 
	  
	} // for (...)
      
      [message setContentTransferEncoding: PantomimeEncodingNone];
      [message setContentType: @"multipart/mixed"];     
      [message setContent: aMimeMultipart];
      
      // We generate a new boundary for our message
      [message setBoundary: [CWMIMEUtility globallyUniqueBoundary]];
      
      RELEASE(aMimeMultipart);
      RELEASE(pool);
    }

  //
  // We inform our bundles that our message WAS encoded
  //
  for (i = 0; i < [[GNUMail allBundles] count]; i++)
    {
      id<GNUMailBundle> aBundle;
      
      aBundle = [[GNUMail allBundles] objectAtIndex: i];
      
      if ( [aBundle respondsToSelector: @selector(messageWasEncoded:)] )
	{
	  // If AT LEAST ONE bundle failed to encode the message, we
	  // stop everything for now.
	  //
	  // FIXME: should use the returned copy successively instead of
	  //        modifying directly "message"
	  //
	  if (![aBundle messageWasEncoded: message])
	    {
	      return NO;
	    }
	}
    }

  return YES;
}


//
//
//
- (void) updateWithMessage: (CWMessage *) theMessage
{
  CWInternetAddress *aInternetAddress;
  NSEnumerator *enumerator;
  
  [self setAccountName: [Utilities accountNameForMessage: theMessage]];
  [self setShowCc: NO];
  
  if ([[theMessage subject] length] != 0)
    {
      [[self window] setTitle: [theMessage subject]];
    }
  else
    {
      [[self window] setTitle: _(@"New message...")];
    }
  
  // We verify if we need to show the Cc field
  enumerator = [[theMessage recipients] objectEnumerator];
  
  while ((aInternetAddress = [enumerator nextObject]))
    {
      if ([aInternetAddress type] == PantomimeCcRecipient)
	{
	  if (![self showCc])
	    {
	      [self setShowCc: YES];
	    }
	}
      else if ([aInternetAddress type] == PantomimeBccRecipient)
	{
	  if (![self showBcc])
	    { 
	      [self setShowBcc: YES];
	    }
	}
    }
}

//
//
//
- (BOOL) validateMenuItem: (id<NSMenuItem>) theMenuItem
{
  SEL action;
  
  action = [theMenuItem action];
  //
  // Deliver / Send Message
  //
  if (sel_isEqual(action, @selector(sendMessage:)))
    {
      return YES;
    }
  return NO;
}

@end


//
// private methods
//
@implementation EditWindowController (Private)

- (void) _adjustNextKeyViews
{
  if (showCc && showBcc)
    {
      [toText setNextKeyView: ccText];
      [ccText setNextKeyView: bccText];
      [bccText setNextKeyView: subjectText];
    }	 
  else if (showCc && !showBcc)
    {
      [toText setNextKeyView: ccText];
      [ccText setNextKeyView: subjectText];
    }
  else if (!showCc && showBcc)
    {
      [toText setNextKeyView: bccText];
      [bccText setNextKeyView: subjectText];
    }
  else
    {
      [toText setNextKeyView: subjectText];
    }
}


//
//
//
- (void) _adjustWidgetsPosition
{  
  NSRect rectOfToText;
  float widthOfScrollView;

  rectOfToText = [toText frame];
  widthOfScrollView = [scrollView frame].size.width;

  if (showCc && showBcc)
    {
      // To - Y_DELTA
      [ccLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA,L_WIDTH,L_HEIGHT)];
      [ccText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*2
      [bccLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA*2,L_WIDTH,L_HEIGHT)];
      [bccText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA*2,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*3
      [subjectLabel setFrame: NSMakeRect(L_X-5,rectOfToText.origin.y-Y_DELTA*3,L_WIDTH+5,L_HEIGHT)];
      [subjectText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA*3,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*4
      [sizeLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA*4,200,L_HEIGHT)];
      
      // Space left...
      [scrollView setFrame: NSMakeRect(S_X,S_Y,widthOfScrollView,rectOfToText.origin.y-Y_DELTA*4-5)];
    }	 
  else if (showCc && !showBcc)
    {
      // To - Y_DELTA
      [ccLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA,L_WIDTH,L_HEIGHT)];
      [ccText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*2
      [subjectLabel setFrame: NSMakeRect(L_X-5,rectOfToText.origin.y-Y_DELTA*2,L_WIDTH+5,L_HEIGHT)];
      [subjectText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA*2,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*3
      [sizeLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA*3,200,L_HEIGHT)];

      // Space left...
      [scrollView setFrame: NSMakeRect(S_X,S_Y,widthOfScrollView,rectOfToText.origin.y-Y_DELTA*3-5)];
    }
  else if (!showCc && showBcc)
    {
      // To - Y_DELTA
      [bccLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA,L_WIDTH,L_HEIGHT)];
      [bccText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*2
      [subjectLabel setFrame: NSMakeRect(L_X-5,rectOfToText.origin.y-Y_DELTA*2,L_WIDTH+5,L_HEIGHT)];
      [subjectText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA*2,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*3
      [sizeLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA*3,200,L_HEIGHT)];

      // Space left...
      [scrollView setFrame: NSMakeRect(S_X,S_Y,widthOfScrollView,rectOfToText.origin.y-Y_DELTA*3-5)];
    }
  else
    {
      // To - Y_DELTA
      [subjectLabel setFrame: NSMakeRect(L_X-5,rectOfToText.origin.y-Y_DELTA,L_WIDTH+5,L_HEIGHT)];
      [subjectText setFrame: NSMakeRect(F_X,rectOfToText.origin.y-Y_DELTA,widthOfScrollView-W_DELTA,F_HEIGHT)];
      
      // To - Y_DELTA*2
      [sizeLabel setFrame: NSMakeRect(L_X,rectOfToText.origin.y-Y_DELTA*2,200,L_HEIGHT)];
     
      // Space left...
      [scrollView setFrame: NSMakeRect(S_X,S_Y,widthOfScrollView,rectOfToText.origin.y-Y_DELTA*2-5)];
    }
}


//
//
//
- (void) _appendAddress: (NSArray *) theAddress
	    toTextField: (NSTextField *) theTextField
{
  NSString *aString;
  NSRange aRange;

  aString = [theAddress objectAtIndex: 0];

  if (aString && [aString length])
    {
      // If there's a comma in the name, we quote the whole thing.
      if ([aString indexOfCharacter: ','] != NSNotFound)
	{
	  aString = [NSString stringWithFormat: @"\"%@\"", aString];
	}

      aString = [NSString stringWithFormat: @"%@ <%@>", aString, [theAddress objectAtIndex: 1]];
    }
  else
    {
      aString = [theAddress objectAtIndex: 1];
    }

  aRange = [[theTextField stringValue] rangeOfString: aString
				       options: NSCaseInsensitiveSearch];
  
  if (aRange.location != NSNotFound)
    {
      return; 
    }
  
  if ([[theTextField stringValue] length])
    {
      [theTextField setStringValue: [NSString stringWithFormat: @"%@, %@",
					      [theTextField stringValue],
					      aString]];
    }
  else
    {
      [theTextField setStringValue: aString];
    }
}


//
//
//
- (NSData *) _dataValueOfRedirectedMessage
{
  CWInternetAddress *anInternetAddress;
  NSMutableData *aMessageAsData;
  NSData *rawSource, *aData;
  NSAutoreleasePool *pool;
  NSCalendarDate *aCalendarDate;
  NSDictionary *allValues;
  NSDictionary *aLocale;
  NSRange aRange;

  // We first verify if at least a recipient To has been defined
  if (![[[toText stringValue] stringByTrimmingWhiteSpaces] length])
    {
      return nil;
    }

  // We create our local pool
  pool = [[NSAutoreleasePool alloc] init];
  
  // We create our mutable string
  aMessageAsData = [[NSMutableData alloc] init];

  // We get the raw source of the message
  rawSource = [[self message] rawSource];
  
  // We get our headers delimiter
  aRange = [rawSource rangeOfCString: "\n\n"];

  if (aRange.length == 0)
    {
      RELEASE(aMessageAsData);
      RELEASE(pool);
      return nil;
    }
  
  // We append the content of our headers
  aData = [rawSource subdataToIndex: aRange.location + 1];

  // If we have our "From " separator, we remove it since we don't want to send this.
  if ([aData hasCPrefix: "From "])
    {
      NSRange r;
      
      r = [aData rangeOfCString: "\n"];

      if (r.length > 0)
	{
	  aData = [aData subdataWithRange: NSMakeRange(r.location + 1, [aData length] - r.location - 1)];
	}
    }

  // We append all our headers
  [aMessageAsData appendData: aData];

  // We get our locale in English
  aLocale = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle bundleForClass:[NSObject class]]
							  pathForResource: @"English"
							  ofType: nil
							  inDirectory: @"Languages"] ];

  // We set the Resent-Date
  aCalendarDate = [NSCalendarDate calendarDate]; 
  NSLog(@"Resent-Date: %@\n", [aCalendarDate descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S %z" locale: aLocale]);
  [aMessageAsData appendCFormat: @"Resent-Date: %@\n", [aCalendarDate descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S %z" locale: aLocale]]; 
  
  // We get our account from our user defaults
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [(ExtendedMenuItem *)[accountPopUpButton selectedItem] key]]
		objectForKey: @"PERSONAL"];
  
  // We set the Resent-From
  anInternetAddress = [[CWInternetAddress alloc] initWithPersonal: [allValues objectForKey: @"NAME"]
						 address: [allValues objectForKey: @"EMAILADDR"]];
  
  [aMessageAsData appendCString: "Resent-From: "];
  [aMessageAsData appendData: [anInternetAddress dataValue]];
  [aMessageAsData appendCString: "\n"];
  RELEASE(anInternetAddress);
  
  // We set the Resent-To
  [aMessageAsData appendCString: "Resent-To: "];
  [aMessageAsData appendData: [[toText stringValue] dataUsingEncoding: NSASCIIStringEncoding]];
  [aMessageAsData appendCString: "\n"];
    
  // We set the ReSent-Cc, if we need to.
  if ([[[ccText stringValue] stringByTrimmingWhiteSpaces] length])
    {
      [aMessageAsData appendCString: "Resent-Cc: "];
      [aMessageAsData appendData: [[ccText stringValue] dataUsingEncoding: NSASCIIStringEncoding]];
      [aMessageAsData appendCString: "\n"];
    }

  // We set the ReSent-Bcc, if we need to.
  if ([[[bccText stringValue] stringByTrimmingWhiteSpaces] length])
    {
      [aMessageAsData appendCString: "Resent-Bcc: "];
      [aMessageAsData appendData: [[bccText stringValue] dataUsingEncoding: NSASCIIStringEncoding]];
      [aMessageAsData appendCString: "\n"];
    }

  // We set the ReSent-Message-ID
  [aMessageAsData appendCString: "Resent-Message-ID: <"];
  [aMessageAsData appendData: [CWMIMEUtility globallyUniqueID]];
  [aMessageAsData appendCString: ">\n"];
    
  // We append our header delimiter
  [aMessageAsData appendCString: "\n"];

  // We finally append the content of our message
  [aMessageAsData appendData: [rawSource subdataFromIndex: aRange.location + 2]];
  
  RELEASE(pool);

  return AUTORELEASE(aMessageAsData);
}


//
//
//
- (float) _estimatedSizeOfMessage
{
  NSTextStorage *aTextStorage;
  NSAutoreleasePool *pool;
  float size;

  pool = [[NSAutoreleasePool alloc] init];
  size = (float)[[textView string] length];
  size = (float)(size / (float)1024);
  aTextStorage = [textView textStorage];
  
  // FIXME
  // This is _very_ slow 
  if ([aTextStorage containsAttachments])
    {
      NSTextAttachment *aTextAttachment;
      int i, len;

      len = [aTextStorage length];

      for (i = 0; i < len; i++)
	{  
	  aTextAttachment = [aTextStorage attribute: NSAttachmentAttributeName		      
					  atIndex: i 
					  effectiveRange: NULL];
	  if ( aTextAttachment ) 
	    {
	      CWPart *aPart;

	      if ([[aTextAttachment attachmentCell] respondsToSelector: @selector(part)])
		{
		  aPart = [(ExtendedTextAttachmentCell *)[aTextAttachment attachmentCell] part];
		}
	      else
		{
		  aPart = nil;
		}

	      if (aPart)
		{
		  size += (float)((float)[aPart size] / (float)1024);
		}
	      else
		{
		  NSFileWrapper *aFileWrapper;
		  
		  aFileWrapper = [aTextAttachment fileWrapper];

		  size += (float)((float)[[aFileWrapper regularFileContents] length] / (float)1024);
		}
	    }
	}
    }

  RELEASE(pool);

  return size;
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
      
      if ( [aBundle hasComposeViewAccessory] )
	{
          NSToolbarItem *aToolbarItem;
          NSToolbar *aToolbar;
          id aView;
          
          aToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: [aBundle name]];
          [allowedToolbarItemIdentifiers addObject: [aBundle name]];
          
          [additionalToolbarItems setObject: aToolbarItem
                                  forKey: [aBundle name]];
                                                      
          aView = [aBundle composeViewAccessory];
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

      // We also set the current superview
      [aBundle setCurrentSuperview: [[self window] contentView]];
    }
}


//
//
//
- (void) _loadCharset
{
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"DEFAULT_CHARSET"])
    {
      NSString *aString;
      
      aString = [[CWCharset allCharsets] objectForKey: [[[NSUserDefaults standardUserDefaults] 
							  objectForKey: @"DEFAULT_CHARSET"] lowercaseString]];
      
      if (aString)
	{
	  [self setCharset: aString];
	}
      else
	{
	  [self setCharset: nil];
	}
    }
  else
    {
      [self setCharset: nil];
    }
}


//
//
//
- (void) _loadAccounts
{
  [Utilities loadAccountsInPopUpButton: accountPopUpButton  select: nil];
  //[Utilities loadTransportMethodsInPopUpButton: transportMethodPopUpButton];
}


//
// 
//
- (NSString *) _loadSignature
{
  NSDictionary *allValues;
  NSString *aSignature;

  [accountPopUpButton synchronizeTitleAndSelectedItem];

  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		 objectForKey: [(ExtendedMenuItem *)[accountPopUpButton selectedItem] key]]
		objectForKey: @"PERSONAL"];
  
  aSignature = nil;
  
  if ([allValues objectForKey: @"SIGNATURE_SOURCE"] &&
      [[allValues objectForKey: @"SIGNATURE_SOURCE"] intValue] == 0)
    {
      aSignature = [NSString stringWithContentsOfFile:
			       [[allValues objectForKey: @"SIGNATURE"] stringByExpandingTildeInPath]];
    }
  else if ([allValues objectForKey: @"SIGNATURE_SOURCE"] &&
	   [[allValues objectForKey: @"SIGNATURE_SOURCE"] intValue] == 1)
    {
      NSFileHandle *aFileHandle;
      NSString *aString;
      NSTask *aTask;
      NSPipe *aPipe;
      NSData *aData;
      NSRange aRange;

      
      // We get our program's name (and arguments, if any)
      aString = [allValues objectForKey: @"SIGNATURE"];

      // If a signature hasn't been set, let's return.
      if (!aString)
	{
	  return nil;
	}
      
      aPipe = [NSPipe pipe];
      aFileHandle = [aPipe fileHandleForReading];
      
      aTask = [[NSTask alloc] init];
      [aTask setStandardOutput: aPipe];
      
      // We trim our string from any whitespaces
      aString = [aString stringByTrimmingWhiteSpaces];

      // We verify if our program to lauch has any arguments
      aRange = [aString rangeOfString: @" "];
      
      if (aRange.length)
	{
	  [aTask setLaunchPath: [aString substringToIndex: aRange.location]];
	  [aTask setArguments: [NSArray arrayWithObjects: [aString substringFromIndex: (aRange.location + 1)], nil]];
	}
      else
	{
	  [aTask setLaunchPath: aString];
	}
      
      // We verify if our launch path points to an executable file
      if (![[NSFileManager defaultManager] isExecutableFileAtPath: [aTask launchPath]])
	{
	  NSDebugLog(@"The signature's path doesn't point to an executable! Ignored.");
	  RELEASE(aTask);
	  return nil;
	}
      
      // We launch our task
      [aTask launch];
      
      while ([aTask isRunning])
	{
	  [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode  beforeDate: [NSDate distantFuture]];
	}
      
      aData = [aFileHandle readDataToEndOfFile];
      
      aSignature = [[NSString alloc] initWithData: aData  encoding: NSUTF8StringEncoding];
      AUTORELEASE(aSignature);
      RELEASE(aTask);
    }
  
  if (aSignature)
    {
      return [NSString stringWithFormat: @"\n\n-- \n%@", aSignature];
    }

  return nil;
}


//
//
//
- (void) _openPanelDidEnd: (NSOpenPanel *) theOpenPanel
               returnCode: (NSInteger) theReturnCode
              contextInfo: (void *) theContextInfo
{
  if (theReturnCode == NSOKButton)
    {
      NSEnumerator *filesToOpenEnumerator;
      NSFileManager *aFileManager;
      NSString *theFilename;
      
      filesToOpenEnumerator = [[theOpenPanel filenames] objectEnumerator];
      aFileManager = [NSFileManager defaultManager];

      while ((theFilename = [filesToOpenEnumerator nextObject]))
	{
	  if (![aFileManager isReadableFileAtPath: theFilename])
	    {
	      NSRunAlertPanel(_(@"Error!"),
			      _(@"The file %@ is not readable and has not been attached to this E-Mail."),
			      _(@"OK"),
			      NULL,
			      NULL,
			      theFilename);
	    }
	  else
	    {
	      [textView insertFile: theFilename];
	    }
	}
      
      [[self window] makeFirstResponder: textView];
    }
}


//
//
//
- (void) _replaceSignature
{
  NSString *aSignature;
  
  // If we don't want a signature...
  if ([self signaturePosition] == SIGNATURE_HIDDEN || _mode == GNUMailRedirectMessage)
    {
      return;
    }
  
  if (previousSignatureValue)
    {
      NSRange aRange;

      aRange.location = NSNotFound;
      aRange.length = 0;
      
      if ([self signaturePosition] == SIGNATURE_BEGINNING)
	{
	  aRange = [[[textView textStorage] string] rangeOfString: previousSignatureValue];
	}
      else if ([self signaturePosition] == SIGNATURE_END)
	{
	  aRange = [[[textView textStorage] string] rangeOfString: previousSignatureValue
						    options: NSBackwardsSearch];
	}

      if (aRange.length)
	{
	  [[textView textStorage] deleteCharactersInRange: aRange];
	}
    }

  // We load the new signature and insert it at the proper position
  aSignature = [self _loadSignature];
  ASSIGN(previousSignatureValue, aSignature);

  if (aSignature)
    {
      if ([self signaturePosition] == SIGNATURE_BEGINNING)
  	{
	  NSMutableAttributedString *theMutableAttributedString;
	  
	  if ([textView font])
	    {
	      theMutableAttributedString = [[NSMutableAttributedString alloc] initWithString: aSignature
									      attributes: [NSDictionary dictionaryWithObject: [textView font]
													forKey: NSFontAttributeName]];
	    }
	  else
	    {
	      theMutableAttributedString = [[NSMutableAttributedString alloc] initWithString: aSignature];
	    }
	  
	  //
	  // We must be careful here. GNUstep might raise an exception if we loaded the signature
	  // with the wrong encoding. The theMutableAttributedString's string will be nil!
	  //
	  if ([theMutableAttributedString string])
	    {
	      [theMutableAttributedString appendAttributedString: [textView textStorage]];
	      [[textView textStorage] setAttributedString: theMutableAttributedString];	      
	    }
	  RELEASE(theMutableAttributedString);
	}
      else if ([self signaturePosition] == SIGNATURE_END)
	{
	  NSAttributedString *theAttributedString;
	  
	  if ([textView font])
	    {
	      theAttributedString = [[NSAttributedString alloc] initWithString: aSignature
								attributes: [NSDictionary dictionaryWithObject: [textView font]
											  forKey: NSFontAttributeName]];
	    }
	  else
	    {
	      theAttributedString = [[NSAttributedString alloc] initWithString: aSignature];
	    }
	  [[textView textStorage] appendAttributedString: theAttributedString];
	  RELEASE(theAttributedString);
	}

      [textView setSelectedRange: NSMakeRange(0,0)];
    }

  // We update our size label
  [self _updateSizeLabel];
}


//
//
//
- (NSString *) _plainTextContentFromTextView
{
  NSMutableString *aMutableString;
  NSTextStorage *textStorage;

  NSAutoreleasePool *pool;
  NSUInteger i, len;
  
  textStorage = [textView textStorage];

  aMutableString = [[NSMutableString alloc] initWithString: [textStorage string]];
 
  pool = [[NSAutoreleasePool alloc] init];
  len = [aMutableString length];

  for (i = len; i > 0; i--)
    { 
      NSTextAttachment *aTextAttachment;     
      id cell;
      NSUInteger charIndex;
      
      charIndex = i-1;
      if ( [aMutableString characterAtIndex: charIndex] != NSAttachmentCharacter )
	{
	  continue;
	}

      aTextAttachment = [textStorage attribute: NSAttachmentAttributeName
				     atIndex: charIndex
				     effectiveRange: NULL];
      
      cell = (ExtendedTextAttachmentCell *)[aTextAttachment attachmentCell];
      
      if ( ![cell respondsToSelector: @selector(part)] )
	{
	  cell = nil;
	}

      if ( cell && [cell part] && [[cell part] filename] )
	{
	  [aMutableString replaceCharactersInRange: NSMakeRange(charIndex, 1)
			  withString: [NSString stringWithFormat: @"<%@>", [[cell part] filename]] ];
	}
      else if ( [[[aTextAttachment fileWrapper] filename] lastPathComponent] )
	{
	  [aMutableString replaceCharactersInRange: NSMakeRange(charIndex, 1)
			  withString: [NSString stringWithFormat: @"<%@>", [[[aTextAttachment fileWrapper] filename]
									     lastPathComponent]] ];
	}
      else
	{
	  [aMutableString replaceCharactersInRange: NSMakeRange(charIndex, 1)
			  withString: @"<unknown>"];
	}
    }
  
  RELEASE(pool);
  
  return AUTORELEASE(aMutableString);
}

/* Autocompletion might give us "last, first <email>" so check the
   previous recipient and see if it matches last. Also match just an
   email.  Give them the formattedValue.  
*/
- (void) _recipientSplitEmail: (NSMutableString *)aString 
		      inArray: (NSMutableArray *)returnArray
{
  NSRange estart, eend;
  BOOL email_only;
  NSString *last, *email;
  ABSearchElement *lastNameElement, *emailElement, *combElement;
  ABRecord *r;
  
  email_only = NO;
  estart = [aString rangeOfString: @"<"];
  eend  = [aString rangeOfString: @">"];
  if (estart.length == 0 || eend.length == 0)
    {
      /* No canonical email address (name <email>) so check if it is
         just the email by itself */
      estart = [aString rangeOfString: @"@"];
      if (estart.length == 0)
	return; /* Nope, just a plain name (will match next time
                   through) or perhaps a group */
      email_only = YES;
    }
  if (email_only == NO && [returnArray count] != 0 
      && [[returnArray lastObject] rangeOfString: @"<"].length != 0)
    {
      /* Previous address is already canonical, skip */
      /* But make sure name is upper case */
      unichar c = [aString characterAtIndex: 0];
      if (estart.length != 0 && islower(c))
	[aString replaceCharactersInRange: NSMakeRange(0, 1) withString: 
	     [[aString substringWithRange: NSMakeRange(0, 1)] uppercaseString]];
      return;
    }
  if ([returnArray count])
    last = [returnArray lastObject];
  else
    last = nil;
  if (last == nil && email_only == NO)
    {
      /* No previous string, so this email is probably already correct. */
      /* But make sure name is upper case */
      unichar c = [aString characterAtIndex: 0];
      if (islower(c))
	[aString replaceCharactersInRange: NSMakeRange(0, 1) withString: 
	     [[aString substringWithRange: NSMakeRange(0, 1)] uppercaseString]];
      return;
    }
  if (email_only)
    email = aString;
  else
    email = [aString substringWithRange: NSMakeRange(estart.location+1, eend.location-estart.location-1)];

  
  emailElement = AB_MATCH_ELEMENT(ABPerson, kABEmailProperty, email);
  if (email_only == NO)
    {
      lastNameElement = AB_MATCH_ELEMENT(ABPerson, kABLastNameProperty, last);
      combElement = [ABSearchElement searchElementForConjunction: kABSearchAnd
							children: [NSArray arrayWithObjects:
									     lastNameElement, emailElement, nil]];
    }
  else
    {
      combElement = emailElement;
    }

  r = [[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement: combElement] lastObject];
  if (r)
    {
      if (email_only == NO && [returnArray count])
	[returnArray removeLastObject];
      [aString replaceCharactersInRange: NSMakeRange(0, [aString length])
			     withString: [(ABPerson *)r formattedValue]];
    }
}

//
//
//
- (NSArray *) _recipientsFromString: (NSString *) theString
{
  NSMutableArray *pairsStack, *returnArray;
  NSMutableString *aString;
  unichar c;
  NSUInteger i;
  
  returnArray = [NSMutableArray array];
  pairsStack = [NSMutableArray array];
  aString = (NSMutableString *)[NSMutableString string];
  
  for (i = 0; i < [theString length]; i++)
    {
      c = [theString characterAtIndex: i];
      switch (c)
	{
	case ',':
	  if ([pairsStack count] == 0 && [aString length])
	    {
	      [self _recipientSplitEmail: aString inArray: returnArray];
	      [returnArray addObject: [NSString stringWithString: aString]];
	      [aString replaceCharactersInRange: NSMakeRange(0, [aString length])
		       withString: @""];
	      continue;
	    }
	  break;
	case ' ':
	  if (![aString length])
	    {
	      continue;
	    }
	  break;
	case '"':
	  if ([pairsStack count] == 0 || [(NSNumber*)[pairsStack lastObject] intValue] != '"')
	    {
	      [pairsStack addObject: [NSNumber numberWithChar: c]];
	    }
	  else
	    {
	      [pairsStack removeLastObject];
	    }
	  break;
	case '<':
	  [pairsStack addObject: [NSNumber numberWithChar: c]];
	  break;
	case '>':
	  if ([pairsStack count] && [(NSNumber*)[pairsStack lastObject] intValue] == '<')
	    {
	      [pairsStack removeLastObject];
	    }
	  break;
	case '(':
	  [pairsStack addObject: [NSNumber numberWithChar: c]];
	  break;
	case ')':
	  if ([pairsStack count] && [(NSNumber*)[pairsStack lastObject] intValue] == '(')
	    {
	      [pairsStack removeLastObject];
	    }
	  break;
	}
      [aString appendFormat: @"%C", c];
    }
  
  if ([pairsStack count] == 0 && [aString length])
    {
      [self _recipientSplitEmail: aString inArray: returnArray];
      [returnArray addObject: [NSString stringWithString: aString]];
    }

  return returnArray;
}


//
//
//
- (void) _setPlainTextContentFromString: (NSString *) theString
                                 inPart: (CWPart *) thePart
{
  // We must first verify if our string contains any non-ascii character
  if ([theString is7bitSafe])
    {
      [thePart setContentType: @"text/plain"];                     // Content-Type
      [thePart setContentTransferEncoding: PantomimeEncodingNone]; // encoding -> none
      [thePart setCharset: @"us-ascii"];
      [thePart setFormat: PantomimeFormatFlowed];
      [thePart setLineLength: [[NSUserDefaults standardUserDefaults] integerForKey: @"LINE_WRAP_LIMIT"  default: 72]];
      [thePart setContent: [theString dataUsingEncoding: NSASCIIStringEncoding]];
    }
  else
    {
      NSString *aCharset;
      
      // We verify if we are using automatic charset detection (when it's nil)
      if (![self charset])
	{
	  aCharset = [theString charset];
	}
      else
	{
	  NSArray *allKeys;

	  allKeys = [[CWCharset allCharsets] allKeysForObject: [self charset]];
	  
	  if ([allKeys count])
	    {
	      aCharset = [allKeys objectAtIndex: 0];
	    }
	  else
	    {
	      aCharset = [theString charset];
	    }
	}
      
      [thePart setContentType: @"text/plain"];               // Content-Type

      // Next, we verify if we can use an encoding other than QP for a specific
      // Content-Type. For now, we only verify for ISO-2022-JP charsets.
      if ([[aCharset lowercaseString] isEqualToString: @"iso-2022-jp"])
	{
	  [thePart setContentTransferEncoding: PantomimeEncodingNone]; // encoding -> none
	}
      else
	{
	  [thePart setContentTransferEncoding: PantomimeEncodingQuotedPrintable]; // encoding -> quoted-printable
	}
      
      [thePart setFormat: PantomimeFormatUnknown];
      [thePart setCharset: aCharset];      
      [thePart setContent: [theString dataUsingEncoding: [NSString encodingForCharset: [aCharset dataUsingEncoding: NSASCIIStringEncoding]]]];
    }
}


//
// Only called under MacOS X
//
#ifdef MACOSX
- (void) _sheetDidEnd: (NSWindow *) sheet
	   returnCode: (NSInteger) returnCode
	  contextInfo: (void *) contextInfo
{
  if ( returnCode == NSAlertAlternateReturn )
    {
      // We append the message to the Drafts folder.
      [[MailboxManagerController singleInstance] saveMessageInDraftsFolderForController: self];
    }
}


//
// Only called under MacOS X
//
- (void) _sheetDidDismiss: (NSWindow *) sheet
	       returnCode: (NSInteger) returnCode
	      contextInfo: (void *) contextInfo
{
  // We cancel the closing operation
  if (returnCode == NSAlertDefaultReturn)
    {
      return;
    }
  
  [[self window] close];
}
#endif


//
//
//
- (void) _updateViewWithMessage: (CWMessage *) theMessage
		appendSignature: (BOOL) aBOOL
{
  // We set our subject
  if ([theMessage subject])
    {
      [subjectText setStringValue: [theMessage subject]];
    }
  else
    {
      [subjectText setStringValue: @""];
    }
  
  if (_mode == GNUMailRedirectMessage)
    {
      [[textView textStorage] deleteCharactersInRange: NSMakeRange(0, [[textView textStorage] length])];

      if (![theMessage rawSource])
	{
	  [textView setString: _(@"Loading message...")];
	  
	  if (![[TaskManager singleInstance] taskForService: [[theMessage folder] store]])
	    {
	      Task *aTask;
	      aTask = [[Task alloc] init];
	      [aTask setKey: [Utilities accountNameForFolder: [theMessage folder]]];
	      aTask->op = LOAD_ASYNC;
	      aTask->immediate = YES;
	      aTask->total_size = (float)[theMessage size]/(float)1024;
	      [aTask setMessage: theMessage];
	      [aTask addController: self];
	      [[TaskManager singleInstance] addTask: aTask];
	      RELEASE(aTask);
	    }
	}
      else
	{	 
	  [[textView textStorage] appendAttributedString: [NSAttributedString attributedStringFromContentForPart: theMessage
									      controller: self]];
	  [[textView textStorage] quote];
	  [[textView textStorage] format];
	  
	  [[textView textStorage] insertAttributedString: [NSAttributedString attributedStringFromHeadersForMessage: theMessage
									      showAllHeaders: NO
									      useMailHeaderCell: NO]
				  atIndex: 0];
	}
    }
  else if (_mode == GNUMailRestoreFromDrafts && ![message content])
    {
      [textView setString: _(@"Loading message...")];
      [send setEnabled: NO];
    }
  else
    {
      NSMutableString *toString, *ccString, *bccString;
      NSEnumerator *recipientsEnumerator;
      CWInternetAddress *theRecipient;
  
      // We get all recipients and we set our To/Cc/Bcc fields.
      toString = [[NSMutableString alloc] init];
      ccString = [[NSMutableString alloc] init];
      bccString = [[NSMutableString alloc] init];
      recipientsEnumerator = [[theMessage recipients] objectEnumerator];
  
      while ((theRecipient = [recipientsEnumerator nextObject]))
	{  
	  if ([theRecipient type] == PantomimeToRecipient)
	    {
	      [toString appendString: [NSString stringWithFormat: @"%@, ", [theRecipient stringValue]]];
	    }
	  else if ([theRecipient type] == PantomimeCcRecipient) 
	    {
	      [ccString appendString: [NSString stringWithFormat: @"%@, ", [theRecipient stringValue]]];
	    }
	  else if ([theRecipient type] == PantomimeBccRecipient) 
	    {
	      [bccString appendString: [NSString stringWithFormat: @"%@, ", [theRecipient stringValue]]];
	    }
	}
      
      // We set the value to our fields, if we need to.
      if ([toString length] > 0)
	{
	  [toText setStringValue: [toString substringToIndex: ([toString length]-2)]];
	}

      if ([ccString length] > 0) 
	{
	  [ccText setStringValue: [ccString substringToIndex: ([ccString length]-2)]];
	}
      
      if ([bccString length] > 0) 
	{
	  [bccText setStringValue: [bccString substringToIndex: ([bccString length]-2)]];
	}

      RELEASE(toString);
      RELEASE(ccString);
      RELEASE(bccString);

      if ([[toText stringValue] length] == 0 && [[ccText stringValue] length] == 0 && [[bccText stringValue] length] == 0)
	{
	  [send setEnabled: NO];
	}

      // We now set the content of the message (considering all attachments)
      // in case of a forward / reply. We quote it properly.
      if ([theMessage content])
	{
	  [[textView textStorage] setAttributedString: [NSAttributedString attributedStringFromContentForPart: theMessage
									   controller: self]];
	  [[textView textStorage] quote];
	  [[textView textStorage] format];
	}
      
      // We finally set the signature, if we need to
      if (aBOOL)
	{
	  [self _replaceSignature];
	}
    }

  [textView scrollPoint: NSMakePoint(0,0)];
}


//
//
//
- (void) _updateSizeLabel
{
  NSString *aString;

  if (_mode == GNUMailRedirectMessage)
    {
      aString = _(@"Redirecting the following message....");
    }
  else
    {
      NSTextStorage *aTextStorage;
      float size;

      aTextStorage = [textView textStorage];
      size = [self _estimatedSizeOfMessage];
      
      // We finally update the string value of our label
      if ( [[NSUserDefaults standardUserDefaults] integerForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] == NSOnState )
	{
	  aString = [NSString stringWithFormat: _(@"%0.1fKB (%d characters) - %d characters per line are shown"), size, [aTextStorage length],
			      ((int)floor((float)[textView frame].size.width / (float)[[textView font] maximumAdvancement].width) - 1)];
	}
      else
	{
	  aString = [NSString stringWithFormat: _(@"%0.1fKB (%d characters)"), size, [aTextStorage length]];
	}
    }

  [sizeLabel setStringValue: aString];
  [sizeLabel setNeedsDisplay: YES];
}

//
//
//
- (void) _updatePart: (CWPart *) thePart
 usingTextAttachment: (NSTextAttachment *) theTextAttachment
{
  NSFileWrapper *aFileWrapper;
  MimeType *aMimeType;
  NSData *aData;
  
  aFileWrapper = [theTextAttachment fileWrapper];
  [thePart setFilename: [[aFileWrapper filename] lastPathComponent]];
  
  // We search for the content-type to use 
  aMimeType = [[MimeTypeManager singleInstance] bestMimeTypeForFileExtension:
						      [[[aFileWrapper filename] lastPathComponent]
							pathExtension]];
  if (aMimeType)
    {
      [thePart setContentType: [aMimeType mimeType]];
    }
  else
    {
      [thePart setContentType: @"application/octet-stream"];
    }
  
  [thePart setContentTransferEncoding: PantomimeEncodingBase64];   // always base64 encoding for now
  [thePart setContentDisposition: PantomimeAttachmentDisposition]; // always attachment for now
      
  aData = [aFileWrapper regularFileContents];
  [thePart setContent: aData];
}

@end
