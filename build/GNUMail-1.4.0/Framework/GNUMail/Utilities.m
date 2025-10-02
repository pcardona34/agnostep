/*
**  Utilities.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**  Copyright (C) 2015-2020 Riccardo Mottola
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

#import "Utilities.h"

#import "EditWindowController.h"
#import "ExtendedMenuItem.h"
#import "ExtendedTextView.h"
#import "FolderNode.h"
#import "FolderNodePopUpItem.h"
#import "GNUMail.h"
#import "GNUMailBundle.h"
#import "Constants.h"
#import "MailboxManagerController.h"
#import "MailHeaderCell.h"
#import "MailWindowController.h"
#import "MessageViewWindowController.h"
#import "MimeType.h"
#import "MimeTypeManager.h"
#import "NSAttributedString+Extensions.h"
#import "NSFont+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "PasswordPanelController.h"
#import "Task.h"
#import "TaskManager.h"

#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolder.h>
#import <Pantomime/CWIMAPFolder.h>
#import <Pantomime/CWIMAPStore.h>
#import <Pantomime/CWIMAPMessage.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWLocalFolder.h>
#import <Pantomime/CWLocalStore.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWPart.h>
#import <Pantomime/CWStore.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSFileManager+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#include <limits.h>


// Our static vars
static NSMutableDictionary *passwordCache = nil;

//
// Useful macros
//
#define INITIALIZE_MESSAGE(message) ({ \
 if (![message isInitialized]) \
   { \
     [message setInitialized: YES]; \
     [message setProperty: [NSDate date]  forKey: MessageExpireDate]; \
   } \
})

//
// Utilities private interface
//
@interface Utilities (Private)
+ (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel
               returnCode: (int) theReturnCode
              contextInfo: (void *) theContextInfo;
@end


//
//
//
@implementation Utilities

+ (void) initialize
{
  if (!passwordCache)
    {
      passwordCache = [[NSMutableDictionary alloc] init];
    }
}


//
//
//
+ (NSString *) encryptPassword: (NSString *) thePassword
                       withKey: (NSString *) theKey
{
  NSMutableData *encryptedPassword;
  NSMutableString *key;
  NSString *result;
  NSUInteger i;
  unichar p, k, e;

  // The length of the key must be greater (or equal) than
  // the length of the password
  key = [[NSMutableString alloc] init];
  
  while ([key length] < [thePassword length])
    {
      [key appendString: theKey];
    }

  encryptedPassword = [[NSMutableData alloc] init];
  
  for (i = 0; i < [thePassword length]; i++)
    {
      p = [thePassword characterAtIndex: i];
      k = [key characterAtIndex: i];
      e = p ^ k;
      [encryptedPassword appendBytes: (void *)&e length: 2];
    }
  
  result = AUTORELEASE([[NSString alloc] initWithData: [encryptedPassword encodeBase64WithLineLength: 0]
					 encoding: NSASCIIStringEncoding]);
  
  RELEASE(encryptedPassword);
  RELEASE(key);

  return result;
}


//
//
//
+ (NSString *) decryptPassword: (NSString *) thePassword
                       withKey: (NSString *) theKey
{
  NSMutableString *password;
  NSMutableString *key;
  NSData *dec;
  unsigned char *decryptedPassword;
  NSString *result;
  NSUInteger i;
  unichar p, k, d;

  if (thePassword == nil || theKey == nil)
    {
      return nil;
    }

  // We 'verify' if the password is not encoded in base64
  // We should not rely on this method but it's currently the best guess we could make
  if ([thePassword length] == 0 || 
      ([thePassword length] & 0x03) || 
      [theKey length] == 0)
    {
      return thePassword;
    }

  // The length of the key must be greater (or equal) than
  // the length of the password
  key = [[NSMutableString alloc] init];
  
  while ([key length] < [thePassword length])
    {
      [key appendString: theKey];
    }

  password = [[NSMutableString alloc] init];
  
  dec = [[thePassword dataUsingEncoding: NSASCIIStringEncoding] decodeBase64];
  decryptedPassword = (unsigned char *)[dec bytes];
  
  for (i = 0; i < [dec length]; i += 2)
    {
      d = decryptedPassword[i] | decryptedPassword[i+1];
      k = [key characterAtIndex: i/2];
      p = d ^ k;
      [password appendString: [NSString stringWithCharacters: &p  length: 1]];
    }

  result = [[NSString alloc] initWithString: password];

  RELEASE(password);
  RELEASE(key);

  return AUTORELEASE(result);
}


//
//
//
+ (void) loadAccountsInPopUpButton: (NSPopUpButton *) thePopUpButton 
			    select: (NSString *) theAccount
{
  NSString *aDefaultAccount, *aKey;
  ExtendedMenuItem *aMenuItem;
  NSEnumerator *theEnumerator;
  NSDictionary *allAccounts;
  NSArray *allKeys;
 
  NSUInteger i, index;
  
  allAccounts = [Utilities allEnabledAccounts];
  allKeys = [[allAccounts allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
  aDefaultAccount = nil;

  if (theAccount)
    {
      aDefaultAccount = theAccount;
    }
  else
    {
      for (i = 0; i < [allKeys count]; i++)
	{
	  if ([[[allAccounts objectForKey: [allKeys objectAtIndex: i]] objectForKey: @"DEFAULT"] boolValue])
	    {
	      aDefaultAccount = [allKeys objectAtIndex: i];
	      break;
	    }
	}
    }

  // We initialize our popup button
  [thePopUpButton removeAllItems];
  
  theEnumerator = [allKeys objectEnumerator];
  i = index = 0;

  while ((aKey = [theEnumerator nextObject]))
    {      
      if (aDefaultAccount && [aKey isEqualToString: aDefaultAccount] ) 
	{
	  index = i;
	}
      
      aMenuItem = [[ExtendedMenuItem alloc] initWithTitle: [NSString stringWithFormat: @"%@ (%@)",
								     [[[allAccounts objectForKey: aKey] objectForKey: @"PERSONAL"]
								       objectForKey: @"EMAILADDR"], aKey]
					    action: NULL
					    keyEquivalent: @""];
      [aMenuItem setKey: aKey];
      [[thePopUpButton menu] insertItem: aMenuItem  atIndex: i];
      RELEASE(aMenuItem);
      i++;
    }
  
  [thePopUpButton selectItemAtIndex: index];
  [thePopUpButton synchronizeTitleAndSelectedItem];
}


//
//
//
+ (void) loadTransportMethodsInPopUpButton: (NSPopUpButton *) thePopUpButton
{
  ExtendedMenuItem *aMenuItem;
  NSArray *allKeys;
  int i;

  // We initialize our popup button used to select the transport methods
  [thePopUpButton removeAllItems];

  allKeys = [[Utilities allEnabledAccounts] allKeys];

  for (i = 0; i < [allKeys count]; i++)
    {
      NSDictionary *allValues;
      NSString *aString;
         
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: [allKeys objectAtIndex: i]] objectForKey: @"SEND"];
      
      if ([[allValues objectForKey: @"TRANSPORT_METHOD"] intValue] == TRANSPORT_SMTP)
	{
	  aString = [NSString stringWithFormat: @"SMTP (%@)", [allValues objectForKey: @"SMTP_HOST"]];
	}
      else
	{
	  aString = [NSString stringWithFormat: @"Mailer (%@)", [allValues objectForKey: @"MAILER_PATH"]];
	}
     
      aMenuItem = [[ExtendedMenuItem alloc] initWithTitle: aString
					    action: NULL
					    keyEquivalent: @""];
      [aMenuItem setKey: [allKeys objectAtIndex: i]];
      [[thePopUpButton menu] addItem: aMenuItem];
      RELEASE(aMenuItem);
    }
}


//
//
//
+ (NSString *) accountNameForFolder: (CWFolder *) theFolder
{
  if ([theFolder isKindOfClass: [CWIMAPFolder class]])
    {
      NSString *aUsername, *aServerName;
      CWIMAPStore *aStore;
      
      aStore = (CWIMAPStore *)[theFolder store];
      aUsername = [aStore username];
      aServerName = [aStore name];

      return [self accountNameForServerName: aServerName  username: aUsername];
  }

  return nil;
}


//
// Given a message, guesses the profile it is associated with by comparing
// recipients with profile addresses. Currently compares address domains
// only (string after '@') to handle email aliases. Once email alias support
// has been added to profiles, we will compare full email addresses.
//
+ (NSString *) accountNameForMessage: (CWMessage *) theMessage
{
  CWInternetAddress *theInternetAddress;
  NSArray *allKeys, *allRecipients;
  NSString *theAccountAddress;
  NSDictionary *theAccount;
  NSUInteger i, j;
  
  // We get all the message recipients
  allRecipients = [theMessage recipients];
  
  // We get all the keys for the personal profiles
  allKeys = [[[Utilities allEnabledAccounts] allKeys]
	      sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
  
  //
  // We go through all enabled account to first try to match one that has the exact recipient
  // defined in our message's recipients list.
  //
  for (i = 0; i < [allKeys count]; i++)
    {
      theAccount = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: [allKeys objectAtIndex: i]];

      // We get the address for this account
      theAccountAddress = [[theAccount objectForKey: @"PERSONAL"] objectForKey: @"EMAILADDR"];

      if ( theAccountAddress && allRecipients )
	{
	  // Walk through the recipients and check against profile address
	  for (j = 0; j < [allRecipients count]; j++)
	    {
	      theInternetAddress = (CWInternetAddress *)[allRecipients objectAtIndex: j];

	      if ([theInternetAddress address] && 
		  [[theAccountAddress stringByTrimmingWhiteSpaces] caseInsensitiveCompare: [theInternetAddress address]] == NSOrderedSame)
		{
		  NSDebugLog(@"Profile to be used = %@", [allKeys objectAtIndex: i]);
		  
		  // We found a matching profile, we return it.
		  return [allKeys objectAtIndex: i];
		}
	    }
	}
    }

  //
  // We haven't found one. At least, let's now try to match one that has only the domain part
  // in the message's recipients list.
  //
  for (i = 0; i < [allKeys count]; i++)
    {
      NSString *theAccountDomain;
      NSRange aRange;

      theAccount = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: [allKeys objectAtIndex: i]];
      
      // We get the address for this account
      theAccountAddress = [[theAccount objectForKey: @"PERSONAL"] objectForKey: @"EMAILADDR"];
      
      if ( theAccountAddress && allRecipients )
	{
	  // Walk through the recipients and check against profile address
	  for (j = 0; j < [allRecipients count]; j++)
	    {
	      // We check only the domain part of profile address (after '@').
	      aRange = [theAccountAddress rangeOfString: @"@"
					  options: NSBackwardsSearch];
	      
	      if ( aRange.location == NSNotFound )
		{
		  continue;
		}
	      
	      theAccountDomain = [theAccountAddress substringFromIndex: NSMaxRange(aRange)];
	      theInternetAddress = (CWInternetAddress *)[allRecipients objectAtIndex: j];
	      aRange = [[theInternetAddress address] rangeOfString: theAccountDomain
						     options: NSCaseInsensitiveSearch];
	      
	      if ( aRange.length > 0 )
		{
		  NSDebugLog(@"Profile to be used = %@", [allKeys objectAtIndex: i]);
		  
		  // We found a matching profile, we return it.
		  return [allKeys objectAtIndex: i];
		}
	    }
	}
    }
    
  // No match according to the recipients. Now let's check if we can find out the account
  // that this message belongs to. If we can't, we will simply return nil, which means no
  // profiles were found.
  return [self accountNameForFolder: [theMessage folder]];
}


//
//
//
+ (NSString *) accountNameForServerName: (NSString *) theServerName
			       username: (NSString *) theUsername
{
  NSEnumerator *theEnumerator;
  NSString *theAccountName;

  if (theServerName == nil)
    return nil;
  if (theUsername == nil)
    return nil;
  
  theEnumerator = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] keyEnumerator];

  while ((theAccountName = [theEnumerator nextObject]))
    {
      NSDictionary *allValues;

      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: theAccountName] objectForKey: @"RECEIVE"];

      if ([[allValues objectForKey: @"USERNAME"] isEqualToString: theUsername] &&
	  [[allValues objectForKey: @"SERVERNAME"] isEqualToString: theServerName])
	{
	  return theAccountName;
	}
    }
  
  return nil;
}


//
//
//
+ (NSDictionary *) allEnabledAccounts
{
  NSMutableDictionary *aMutableDictionary;

  aMutableDictionary = nil;

  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"])
    {
      NSArray *allKeys;
      NSUInteger i;

      aMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] 
									      objectForKey: @"ACCOUNTS"]];
      AUTORELEASE(aMutableDictionary);

      allKeys = [aMutableDictionary allKeys];

      for (i = 0; i < [allKeys count]; i++)
	{
	  if (![[[aMutableDictionary objectForKey: [allKeys objectAtIndex: i]]
		  objectForKey: @"ENABLED"] boolValue])
	    {
	      [aMutableDictionary removeObjectForKey: [allKeys objectAtIndex: i]];
	    }
	}
    }

  return aMutableDictionary;
}


//
// Returns the name of the default account
//
+ (NSString *) defaultAccountName
{
  NSDictionary *allAccounts;
  NSArray *allKeys;
  
  NSUInteger i;
  
  allAccounts = [Utilities allEnabledAccounts];
  allKeys = [allAccounts allKeys];
  
  for (i = 0; i < [allKeys count]; i++)
    {
      if ( [[[allAccounts objectForKey: [allKeys objectAtIndex: i]] objectForKey: @"DEFAULT"] boolValue] )
	{
	  return [allKeys objectAtIndex: i];
	}
    }
  
  return nil;
}

//
// This method returns the window associated to the folder & store.
// If the folder name is nil, it returns the first window that uses the 'store'.
//
+ (id) windowForFolderName: (NSString *) theName
		     store: (id<CWStore>) theStore
{
  NSArray *allWindows;
	      
  // We get all opened windows
  allWindows = [GNUMail allMailWindows];
  
  if (allWindows)
    {
      CWFolder *aFolder;
      id aWindow;
      NSUInteger i;
      
      for (i = 0; i < [allWindows count]; i++)
	{
	  aWindow = [allWindows objectAtIndex: i];
	  aFolder = [(MailWindowController *)[aWindow windowController] folder];
	  
	  // If we found our opened folder
	  if (theName &&
	      [[aFolder name] isEqualToString: theName] && 
	      [aFolder store] == theStore)
	    {
	      return aWindow;
	    }
	  else if (theName == nil && [aFolder store] == theStore)
	    {
	      return aWindow;
	    }
	}
    }
  
  return nil;
}


//
//
//
+ (FolderNode *) folderNodesFromFolders: (NSEnumerator *) theFolders
			      separator: (unsigned char) theSeparator
{
  NSString *aName, *aString;
  FolderNode *root;
  NSUInteger i;
 
  root = [[FolderNode alloc] init];
  [root setParent: nil];

  if (!theSeparator)
    {
      theSeparator = '/';
    }
  
  while ((aString = [theFolders nextObject]))
    {
      i = [aString indexOfCharacter: theSeparator];

      if (i != NSNotFound)
	{ 
	  FolderNode *parent;
	  NSInteger mark;
	  
	  parent = root;
	  mark = 0;
	  
	  while (i != NSNotFound && i > 0)
	    {
	      if (mark == i)
		{
		  mark += 1; 
		}
	      else
		{	  
		  aName = [aString substringWithRange: NSMakeRange(mark, i-mark)];
		  
		  if (![parent childWithName: aName])
		    {
		      [parent addChild: [FolderNode folderNodeWithName: aName  parent: parent]];
		    }
		  
		  parent = [parent childWithName: aName];
		  mark = i+1;
		}
	      
	      i = [aString indexOfCharacter: theSeparator  fromIndex: mark];
	    }
	  
	  aName = [aString substringFromIndex: mark];

	  if (![parent childWithName: aName])
	    {
	      [parent addChild: [FolderNode folderNodeWithName: aName  parent: parent]];
	    }
	}
      else
	{
	  if (![root childWithName: aString])
	    {
	      [root addChild: [FolderNode folderNodeWithName: aString  parent: root]];
	    }
	}
    }

  return AUTORELEASE(root);
}


//
// This method returns a node using a thePath to search
// and rootNode as the starting point in it's search.
//
// The path to the node MUST always use '/' as the folder separator
// if no other separtor can be specified. Otherwise, it should use
// the result of the -folderSeparator method from IMAPStore.
//
+ (FolderNode *) folderNodeForPath: (NSString *) thePath
			     using: (FolderNode *) rootNode
			 separator: (unsigned char) theSeparator
{
  NSArray *pathComponents;
  FolderNode *aFolderNode;
  NSUInteger i, j, c;
  
  pathComponents = [thePath componentsSeparatedByString: [NSString stringWithFormat: @"%c", theSeparator]];
  c = [pathComponents count];
  aFolderNode = rootNode;

  for (i = 0; i < c; i++)
    {
      NSString *aPathComponent;

      aPathComponent = [pathComponents objectAtIndex: i];
      
      if ([aPathComponent length] == 0)
	{
	  continue;
	}
      
      for (j = 0; j < [aFolderNode childCount]; j++)
	{
	  if ([[[aFolderNode childAtIndex: j] name] isEqualToString: aPathComponent])
	    {
	      aFolderNode = [aFolderNode childAtIndex: j];
	      break;
	    }
	}
    }
  
  return aFolderNode;
}


//
// This method build a complete path of a node. It will stop
// building the path when parent == nil is reached.
//
// We always return a /<Store name>/folder/subfolder/subsubfolder
// or                 /<Store name>/folder.subfolder.subsubfolder
//
+ (NSString *) completePathForFolderNode: (FolderNode *) theFolderNode
			       separator: (unsigned char) theSeparator
{
  NSMutableString *aMutableString;
  FolderNode *parent;

#warning This cache seems to cause problem especially it we transfer a message from IMAP server A Foo to IMAP server B Foo.C
#if 0
  if ([theFolderNode path])
    {
      return [theFolderNode path];
   }
#endif

  aMutableString = [[NSMutableString alloc] init];
  parent = theFolderNode;

  if (!theSeparator)
    {
      theSeparator = '/';
    }

  // We don't loop for no reason if the root was passed as the parameter
  if (![parent parent])
    {
      RELEASE(aMutableString);
      return [NSString stringWithFormat: @"/%@/", [parent name]];
    }
  
  while (parent != nil)
    {
      [aMutableString insertString: [parent name]
		      atIndex: 0];
      
      // We verify if the parent of that node has a parent.
      // If it doesn't, that means we must add our /<Store name>/
      // and break the loop.
      if ([[parent parent] parent])
	{
	  [aMutableString insertString: [NSString stringWithFormat: @"%c", theSeparator]
			  atIndex: 0];
	}
      else
	{
	  [aMutableString insertString: [NSString stringWithFormat: @"/%@/", [[parent parent] name]]
			  atIndex: 0];
	  break;
	}
      
      parent = [parent parent];
    }
  
  [theFolderNode setPath: aMutableString];

  return AUTORELEASE(aMutableString);
}


//
// We skip the first <foo bar> in  /<foo bar>/folder/subfolder/mbox
//                             or  /<foo bar>/folder.subfolder.mbox
// in order to only get the full path of the mbox.
//
// If the no mailbox was selected, we return nil.
//
+ (NSString *) pathOfFolderFromFolderNode: (FolderNode *) theFolderNode
				separator: (unsigned char) theSeparator
{
  NSString *aString;
  NSInteger i;
  
  if (!theSeparator)
    {
      theSeparator = '/';
    }

  // We build our full path (including /<Store>/) to our folder
  aString = [Utilities completePathForFolderNode: theFolderNode
		       separator: theSeparator];
  
  // We trim the /<Store>/ part.
  i = [aString indexOfCharacter: '/'  fromIndex: 1];

  if (i != NSNotFound && i > 0)
    {
      return [aString substringFromIndex: i+1];
    }
  
  return nil;
}


//
//
//
+ (NSString *) flattenPathFromString: (NSString *) theString
			   separator: (unsigned char) theSeparator
{
  // If the separator is undefined, we assume a default one.
  if (!theSeparator)
    {
      theSeparator = '/';
    }

  return [theString stringByReplacingOccurrencesOfCharacter: theSeparator  withCharacter: '_'];
}


//
// Calculates the store key from a node. The key returned is:
//
// <username> @ <store name>.
//
// The usage of this method only makes sense for FolderNode objects
// used to represent an IMAP store and its folders.
//
+ (NSString *) storeKeyForFolderNode: (FolderNode *) theFolderNode
			  serverName: (NSString **) theServerName
			    username: (NSString **) theUsername
{  
  NSString *aString = nil;
  
  if ( theFolderNode )
    {
      NSString *aServerName, *aUsername;
      NSRange aRange;
   
      aString = [Utilities completePathForFolderNode: theFolderNode
			   separator: '/'];
      
      aRange = [aString rangeOfString: @"/"
			options: 0
			range: NSMakeRange(1, [aString length] - 1)];
  
      if ( aRange.length )
	{
	  aString = [aString substringWithRange: NSMakeRange(1, aRange.location - 1)];
	}
      else
	{
	  aString = [aString substringFromIndex: 1];
	}
      
      aString = [aString stringByTrimmingWhiteSpaces];

      // We ensure that we really received a "IMAP value"
      if ( [aString isEqualToString: _(@"Local")] )
	{
	   // Seems we got a Local value.
	  aServerName = nil;
	  aUsername = NSUserName();
	}
      else
	{
	  NSDictionary *allValues;

	  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
			 objectForKey: aString] objectForKey: @"RECEIVE"];
	  
	  aServerName = [allValues objectForKey: @"SERVERNAME"];
	  aUsername = [allValues objectForKey: @"USERNAME"];
	  aString = [NSString stringWithFormat: @"%@ @ %@", aUsername, aServerName];
	}
      
      if ( theServerName != NULL )
	{
	  *theServerName = aServerName;
	}
      
      if ( theUsername != NULL )
	{
	  *theUsername = aUsername;
	}
    }
  
  return aString;
}


//
//
//
+ (BOOL) URLWithString: (NSString *) theString
           matchFolder: (CWFolder *) theFolder
{
  CWURLName *theURLName;
  
  theURLName = [[CWURLName alloc] initWithString: theString
				  path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
  
  if ([[theFolder name] isEqualToString: [theURLName foldername]])
    {
      // If's a local folder, we simply compare the protocol.
      if ([theFolder isKindOfClass: [CWLocalFolder class]])
	{
	  if ([[theURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame)
	    {
	      RELEASE(theURLName);
	      return YES;
	    }
	}
      // It's an IMAP folder, we must compare the hostname and the username.
      else
	{
	  CWIMAPStore *aStore;

	  aStore = (CWIMAPStore *)[theFolder store];
	  
	  if ([[aStore name] isEqualToString: [theURLName host]] &&
	      [[aStore username] isEqualToString: [theURLName username]])
	    {
	      RELEASE(theURLName);
	      return YES;
	    }
	}
    }

  RELEASE(theURLName);
  return NO;
}


//
//
//
+ (BOOL) stringValueOfURLName: (NSString *) theString
	            isEqualTo: (NSString *) theName
{
  NSEnumerator *theEnumerator;
  
  NSString *theAccountName;
  
  theEnumerator = [[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] keyEnumerator];

  while ((theAccountName = [theEnumerator nextObject]))
    {
      NSDictionary *allValues;

      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: theAccountName] objectForKey: @"MAILBOXES"];

      if ([[allValues objectForKey: theName] isEqualToString: theString])
	{
	  return YES;
	}
    }
  
  return NO;
}


//
//
//
+ (NSString *) stringValueOfURLNameFromFolder: (CWFolder *) theFolder
{
  NSString *aString;

  
  if ([theFolder isKindOfClass: [CWLocalFolder class]])
    {
      aString = [NSString stringWithFormat: @"local://%@/%@", 
			  [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
			  [theFolder name]];
    }
  else
    {
      aString = [NSString stringWithFormat: @"imap://%@@%@/%@", 
			  [((CWIMAPStore *)[theFolder store]) username],
			  [((CWIMAPStore *)[theFolder store]) name],
			  [theFolder name]];
    }

  return aString;
}


//
//
//
+ (NSString *) stringValueOfURLNameFromFolderNode: (FolderNode *) theFolderNode
				       serverName: (NSString *) theServerName
					 username: (NSString *) theUsername
{
  NSString *aString;

  aString = [Utilities pathOfFolderFromFolderNode: theFolderNode  separator: '/'];

  //
  // If it's a Local mailbox...
  //
  if ([aString hasPrefix: _(@"Local Mailboxes")])
    {
      // We have something like "Local Mailboxes/subfolderA/subfolderB/mbox"
      NSRange aRange;

      aRange = [aString rangeOfString: @"/"];

      // We build our URL
      aString = [NSString stringWithFormat: @"local://%@/%@",
			  [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"],
			  [aString substringFromIndex: aRange.location + 1]];
    }
  //
  // It's an IMAP mailbox.
  //
  else
    {
      NSString  *aPathToFolder;
      NSRange aRange;
      
      // We have something like <Account name>/subfolderA/subfolderB/mbox
      aRange = [aString rangeOfString: @"/"];  // we search for: <Account name>/  <- the /
      aPathToFolder = [aString substringFromIndex: aRange.location + 1];
      
      if (theServerName && theUsername)
	{
	  aString = [NSString stringWithFormat: @"imap://%@@%@/%@", theUsername, theServerName, aPathToFolder];
	}
      else
	{
	  NSString *aServername, *aUsername, *theAccountName;
	  NSDictionary *allValues;

	  theAccountName = [aString substringToIndex: aRange.location];      
	  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
			 objectForKey: theAccountName] objectForKey: @"RECEIVE"];
	  aUsername = [allValues objectForKey: @"USERNAME"];
	  aServername = [allValues objectForKey: @"SERVERNAME"];
	  
	  aString = [NSString stringWithFormat: @"imap://%@@%@/%@", aUsername, aServername, aPathToFolder];
	}
    }
  
  return aString;
}


//
//
//
+ (FolderNode *) initializeFolderNodesUsingAccounts: (NSDictionary *) theAccounts
{
  FolderNode *allNodes, *nodes;
  CWLocalStore *aStore;
  NSArray *allKeys;

  NSUInteger i;

  allNodes = [[FolderNode alloc] init];
  
  //
  // Local
  //
  aStore = [[MailboxManagerController singleInstance] storeForName: @"GNUMAIL_LOCAL_STORE"
						      username: NSUserName()];  
  
  nodes = [Utilities folderNodesFromFolders: [aStore folderEnumerator]  separator: '/'];
  
  if ([nodes childCount] > 0)
    {
      [nodes setName: _(@"Local Mailboxes")];
      [allNodes addChild: nodes];
      [nodes setParent: allNodes];
    }

  //
  // IMAP
  //
  allKeys = [[theAccounts allKeys] sortedArrayUsingSelector: @selector(compare:)];
  
  for (i = 0; i < [allKeys count]; i++)
    {
      NSDictionary *allValues;
      NSArray *theArray;

      allValues = [[theAccounts objectForKey: [allKeys objectAtIndex: i]] objectForKey: @"RECEIVE"];
      theArray = [allValues objectForKey: @"SUBSCRIBED_FOLDERS"];
      
      if (theArray && [theArray count] > 0)
	{
	  nodes = [Utilities folderNodesFromFolders: [theArray objectEnumerator]  separator: '/'];
	  [nodes setName: [allKeys objectAtIndex: i]];
	  [allNodes addChild: nodes];
	  [nodes setParent: allNodes];
	}
    }
  
  return AUTORELEASE(allNodes);
}


//
//
//
+ (void) addItemsToMenu: (NSMenu *) theMenu
		    tag: (int) theTag
		 action: (SEL) theAction
	    folderNodes: (FolderNode *) theFolderNodes
{
  NSUInteger i;

  //[theMenu removeAllItems];
  //[theMenu setAutoenablesItems: NO];
    
  // We now add all our nodes
  for (i = 0; i < [theFolderNodes childCount]; i++)
    {
      [Utilities addItem: [theFolderNodes childAtIndex: i]
		 tag: theTag
		 action: theAction
		 toMenu: theMenu];
    }
}

//
// Usually, theFolderNodes will be a pointer to a FolderNode object
// representing the "tree" of all our Local and/or IMAP nodes.
// This "tree" is usually build using:
//
// Utilities: +initializeFolderNodesUsingAccounts:
//
// We will ALWAYS have at least one node.
//
+ (void) addItemsToPopUpButton: (NSPopUpButton *) thePopUpButton
              usingFolderNodes: (FolderNode *) theFolderNodes
{
  NSUInteger i;

  [thePopUpButton removeAllItems];
  [thePopUpButton setAutoenablesItems: NO];
    
  // We now add all our nodes
  for (i = 0; i < [theFolderNodes childCount]; i++)
    {
      [Utilities addItem: [theFolderNodes childAtIndex: i]
		 level: 0
		 tag: 0
		 action: @selector(foo:)
		 toMenu: [thePopUpButton menu]];
    }
  
  [thePopUpButton selectItemAtIndex: 0];
}


//
// This method adds new items to the specified menu.
// It respects the level parameter for indenting properly
// the items in order to represent a hierarchy.
//
+ (void) addItem: (FolderNode *) theFolderNode
	   level: (int) theLevel
	     tag: (int) theTag
	  action: (SEL) theAction
	  toMenu: (NSMenu *) theMenu
{
  NSMutableString *aMutableString;
  FolderNodePopUpItem *theItem;
  NSUInteger i;

  aMutableString = [[NSMutableString alloc] init];

  for (i = 0; i < theLevel; i++)
    {
      [aMutableString appendString: @"     "];
    }

  [aMutableString appendString: [theFolderNode name]];
  
  theItem = [[FolderNodePopUpItem alloc] initWithTitle: aMutableString
					 action: NULL
					 keyEquivalent: @""];
  [theItem setTag: theTag];
  [theItem setFolderNode: theFolderNode];
  RELEASE(aMutableString);

  // We enable / disable our item
  if ( [theFolderNode childCount] > 0 )
    {    
      [theItem setAction: NULL];
      [theItem setEnabled: NO];
    }
  else
    {
      [theItem setAction: theAction];
      [theItem setEnabled: YES];
    }

  // We finally add our item
  [theMenu addItem: theItem];
  RELEASE(theItem);

  for (i = 0; i < [theFolderNode childCount]; i++)
    {
      [Utilities addItem: [theFolderNode childAtIndex: i]
		 level: (theLevel + 1)
		 tag: theTag
		 action: theAction
		 toMenu: theMenu];
    }
}


//
//
//
+ (void) addItem: (FolderNode *) theFolderNode
	     tag: (int) theTag
	  action: (SEL) theAction
	  toMenu: (NSMenu *) theMenu
{
  FolderNodePopUpItem *theItem;
  NSUInteger i;

  [theMenu setAutoenablesItems: NO];
  
  theItem = [[FolderNodePopUpItem alloc] initWithTitle: [theFolderNode name]
					 action: NULL
					 keyEquivalent: @""];
  [theItem setTag: theTag];
  [theItem setFolderNode: theFolderNode];

  // We enable / disable our item
  if ([theFolderNode childCount] > 0)
    {    
      [theItem setAction: NULL];
    }
  else
    {
      [theItem setAction: theAction];
      [theItem setEnabled: YES];
    }

  // We finally add our item
  [theMenu addItem: theItem];

  if ([theFolderNode childCount] > 0)
    {    
      NSMenu *aMenu;

      aMenu = [[NSMenu alloc] init];

      for (i = 0; i < [theFolderNode childCount]; i++)
        {
          [Utilities addItem: [theFolderNode childAtIndex: i]
		     tag: theTag
		     action: theAction
		     toMenu: aMenu];
        }
      [theMenu setSubmenu: aMenu  forItem: theItem];
      RELEASE(aMenu);
    }

  RELEASE(theItem); 
}


//
//
//
+ (FolderNodePopUpItem *) folderNodePopUpItemForFolderNode: (FolderNode *) theFolderNode
					       popUpButton: (NSPopUpButton *) thePopUpButton
{
  FolderNodePopUpItem *theItem;
  int i;

  for (i = 0; i < [thePopUpButton numberOfItems]; i++)
    {
      theItem = (FolderNodePopUpItem *)[thePopUpButton itemAtIndex: i];

      if ([theItem folderNode] == theFolderNode)
	{
	  return theItem;
	}
    }

  return nil;
}


//
//
//
+ (FolderNodePopUpItem *) folderNodePopUpItemForURLNameAsString: (NSString *) theString
					       usingFolderNodes: (FolderNode *) theFolderNodes
						    popUpButton: (NSPopUpButton *) thePopUpButton
							account: (NSString *) theAccountName
{
  FolderNodePopUpItem *aPopUpItem;
  FolderNode *aFolderNode;
  CWURLName *aURLName;

  if (!theString)
    {
      return nil; 
    }

  aURLName = [[CWURLName alloc] initWithString: theString
				path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
  
  if ([[aURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame)
    {
      aFolderNode = [Utilities folderNodeForPath: [NSString stringWithFormat: @"%@/%@", _(@"Local Mailboxes"),
							    [aURLName foldername]]
			       
			       using: theFolderNodes
			       separator: '/'];
    }
  else
    {
      if (!theAccountName)
	{
	  theAccountName = [Utilities accountNameForServerName: [aURLName host]
				      username: [aURLName username]];
	}
      
      aFolderNode = [Utilities folderNodeForPath: [NSString stringWithFormat: @"%@/%@", theAccountName, [aURLName foldername]]
			       using: theFolderNodes
			       separator: '/'];
    }
  
  aPopUpItem = [Utilities folderNodePopUpItemForFolderNode: aFolderNode
			  popUpButton: thePopUpButton];

  RELEASE(aURLName);

  return aPopUpItem;
}

//
//
//
+ (NSString *) passwordForKey: (id) theKey
			 type: (int) theType
		       prompt: (BOOL) aBOOL
{
  NSString *aPassword, *usernameKey, *passwordKey, *serverNameKey;
  NSDictionary *allValues;
  
  if (theType == POP3 || theType == IMAP)
    {
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: theKey] objectForKey: @"RECEIVE"];
      usernameKey = @"USERNAME";
      passwordKey = @"PASSWORD";
      serverNameKey = @"SERVERNAME";
    }
  else
    {
      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"]
		     objectForKey: theKey] objectForKey: @"SEND"];
      usernameKey = @"SMTP_USERNAME";
      passwordKey = @"SMTP_PASSWORD";
      serverNameKey = @"SMTP_HOST";
    }

  // We define a new key
  if ([allValues objectForKey: usernameKey] && [allValues objectForKey: serverNameKey])
    {
      theKey = [NSString stringWithFormat: @"%@ @ %@", [allValues objectForKey: usernameKey],
			 [allValues objectForKey: serverNameKey]];

      
      aPassword = [Utilities decryptPassword: [allValues objectForKey: passwordKey]  withKey: theKey];  
      
      // We verify in our cache
      if (!aPassword)
	{
	  aPassword = [passwordCache objectForKey: theKey];
	}
    }
  else
    {
      aPassword = nil;
      theKey = nil;
    }


  // If we must prompt for the password
  if (!aPassword && aBOOL)
    {
      PasswordPanelController *theController; 
      int result;
      
      theController = [[PasswordPanelController alloc] initWithWindowNibName: @"PasswordPanel"];
      [[theController window] setTitle: (theKey ? theKey : (id)@"")];
      
      result = [NSApp runModalForWindow: [theController window]];
      
      // If the user has entered a password...
      if (result == NSRunStoppedResponse)
	{
	  aPassword = [theController password];
	  
	  // Let's cache this password...
	  if (theKey) [passwordCache setObject: aPassword  forKey: theKey];
	}
      else
	{
	  aPassword = nil;
	}
      
      RELEASE(theController);
    }
  
  return aPassword;
}


//
//
//
+ (NSMutableDictionary *) passwordCache
{
  return passwordCache;
}


//
// Creates a reply
//
+ (void) replyToMessage: (CWMessage *) theMessage
		 folder: (CWFolder *) theFolder
		   mode: (PantomimeReplyMode) theMode
{
  EditWindowController *theEditWindowController;
  NSString *theAccountName, *theAccountAddress;
  CWMessage *aMessage;
  
  BOOL shouldReplyToList, aBOOL;
  
  if (!theMessage || ![theMessage content])
    {
      NSBeep();
      return;
    }

  //
  // We initialize our message, just to be safe. It SHOULD already be
  // initialized since it's selected (since the user wants to reply to
  // this selected mail)
  //
  INITIALIZE_MESSAGE(theMessage);
 
  theAccountName = [self accountNameForMessage: theMessage];
  theAccountAddress = nil;
  shouldReplyToList = NO;
  aBOOL = YES;
  
  if (theAccountName)
    {
      theAccountAddress = [[[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] objectForKey: theAccountName]
			     objectForKey: @"PERSONAL"] objectForKey: @"EMAILADDR"];
    }
  
  //
  // We verify for the List-Post header. This is definied in RFC-2369. We use it to offer
  // a "reply to list" option to the user.
  //
  if ([[theMessage allHeaders] objectForKey: @"List-Post"] &&
      [[[[theMessage allHeaders] objectForKey: @"List-Post"] stringByTrimmingWhiteSpaces] caseInsensitiveCompare: @"NO"] != NSOrderedSame)
    {
      NSInteger choice;
      
      choice = NSRunAlertPanel(_(@"List Reply..."),
			       _(@"To whom would you like to reply?"),
			       _(@"List"),     // default
			       _(@"Everyone"), // alternate
			       _(@"Sender"),
			       nil);
      
      if (choice == NSAlertDefaultReturn)
        {
	  shouldReplyToList = YES;
	}
      else if (choice == NSAlertAlternateReturn)
	{
	  theMode = theMode|PantomimeReplyAllMode;
	}
      else
	{
	  theMode = theMode&(theMode^PantomimeReplyAllMode);
	  aBOOL = NO;
	}
    }
  
  if (shouldReplyToList || (theMode&PantomimeReplyAllMode))
    {
      // We do only that (ie., we don't offer the "Reply to all" option)
    }
  else if (aBOOL && [theMessage recipientsCount] > 1)
    {
      NSInteger choice;
      
      choice = NSRunAlertPanel(_(@"Reply..."),
			       _(@"Would you like to reply to all recipients?"),
			       _(@"No"),  // default
			       _(@"Yes"), // alternate
			       nil);
      
      if (choice == NSAlertAlternateReturn)
        {
	  theMode = theMode|PantomimeReplyAllMode;
	}
      else
	{
	  theMode = theMode&(theMode^PantomimeReplyAllMode);
	}
    }  
  
  // We create our window controller
  theEditWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
  
  if (theEditWindowController)
    {
      [[theEditWindowController window] setTitle: _(@"Reply to a message...")];
      [theEditWindowController setSignaturePosition: 
				 [[NSUserDefaults standardUserDefaults]
				   integerForKey: @"SIGNATURE_REPLY_POSITION"  default: SIGNATURE_END]];
      [theEditWindowController setShowCc: ((theMode&PantomimeReplyAllMode) == PantomimeReplyAllMode)];
      [theEditWindowController setMode: GNUMailReplyToMessage];
      
      // We set the original message
      [theEditWindowController setUnmodifiedMessage: theMessage];
      
      // We create a replied copy of our message and we retain it
      aMessage = [theMessage reply: theMode];
      RETAIN(aMessage);
      
      // If we are in the Sent folder, we replace the recipient with the original recipients
      // of the messages.
      if ([Utilities stringValueOfURLName: [Utilities stringValueOfURLNameFromFolder: theFolder]  
		     isEqualTo: @"SENTFOLDERNAME"])
	{
          [aMessage setRecipients: [[theEditWindowController unmodifiedMessage] recipients]];
	}
      
      // Remove original recipient from recipient list. As a small optimization, we don't do that
      // if we reply only to a mailing list since the recipients will get replaced below.
      if (!shouldReplyToList && (theMode&PantomimeReplyAllMode) && theAccountAddress)
	{
          NSUInteger i;
	  for (i = 0; i < [aMessage recipientsCount]; i++)
	    {
	      if ([[(CWInternetAddress*)[[aMessage recipients] objectAtIndex: i] address] 
		    caseInsensitiveCompare: theAccountAddress] == NSOrderedSame)
		{
		  [aMessage removeRecipient: (CWInternetAddress *)[[aMessage recipients] objectAtIndex: i]];
		  break;
		}
	    }		  
	}
      
      // We want to include only the list address on list reply
      if (shouldReplyToList)
	{
	  CWInternetAddress *theInternetAddress;
	  NSMutableString *aMutableString;

	  aMutableString = [NSMutableString stringWithString: [theMessage headerValueForName: @"List-Post"]];
	  [aMutableString deleteCharactersInRange: [aMutableString rangeOfString: @"mailto:"]];
	  
	  theInternetAddress = [[CWInternetAddress alloc] initWithString: aMutableString];
	  [theInternetAddress setType: PantomimeToRecipient];
	  [aMessage setRecipients: [NSArray arrayWithObject: theInternetAddress]];
	  RELEASE(theInternetAddress);
	}
      
      [theEditWindowController setMessage: aMessage];
      RELEASE(aMessage);
      
      // We set the appropriate account and show our window
      [theEditWindowController setAccountName: theAccountName];
      [theEditWindowController showWindow: self];

      // When replying to a mail, focus the text view
      [[theEditWindowController window] makeFirstResponder: [theEditWindowController textView]];
    }
}


//
//
//
+ (void) forwardMessage: (CWMessage *) theMessage
		   mode: (PantomimeForwardMode) theMode
{
  EditWindowController *theEditWindowController;
  NSString *theAccountName;
  CWMessage *aMessage;
  
  if (!theMessage || ![theMessage content]) 
    {
      NSBeep();
      return;
    }

  //
  // We initialize our message, just to be safe. It SHOULD already be
  // initialized since it's selected (since the user wants to forward
  // this selected mail)
  //
  INITIALIZE_MESSAGE(theMessage);
  
  // We guess the profile we should be using
  theAccountName = [self accountNameForMessage: theMessage];
  
  // We create a forwarded copy of our message and we retain it
  aMessage = [theMessage forward: theMode];
  RETAIN(aMessage);
  
  theEditWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
  
  if (theEditWindowController)
    {
      [[theEditWindowController window] setTitle: _(@"Forward a message...")];
      [theEditWindowController setSignaturePosition: 
				 [[NSUserDefaults standardUserDefaults] 
				   integerForKey: @"SIGNATURE_FORWARD_POSITION"  default: SIGNATURE_BEGINNING]];
      [theEditWindowController setMessage: aMessage];
      [theEditWindowController setShowCc: NO];
      [theEditWindowController setMode: GNUMailForwardMessage];
      
      // We set the appropriate account and show our window
      [theEditWindowController setAccountName: theAccountName];
      [theEditWindowController showWindow: self];
    }
  
  RELEASE(aMessage);
}


//
// This method displays a message in the textView.
//
+ (void) showMessage: (CWMessage *) theMessage
	      target: (NSTextView *) theTextView 
      showAllHeaders: (BOOL) headersFlag
{
  if (theMessage)
    {
      CWFlags *theFlags;
      id aDelegate;
      NSUInteger i, count;

      if ([theMessage isKindOfClass: [CWIMAPMessage class]] && ![(CWIMAPFolder *)[theMessage folder] selected])
      	{
      	  return;
      	}

      // If the content of the message has neven been parsed before, we do it now!
      INITIALIZE_MESSAGE(theMessage);
      
      // We clear our 'Save' menu
      count = [[(GNUMail *)[NSApp delegate] saveMenu] numberOfItems];
      while (count > 1)
	{
	  count--;
	  [[(GNUMail *)[NSApp delegate] saveMenu] removeItemAtIndex: count];
	}
      
      // We begin by clearing what we have in our text view
      [[theTextView textStorage] deleteCharactersInRange: NSMakeRange(0, [[theTextView textStorage] length])];
      
      // We inform our bundles that the message WILL BE shown in the text view
      for (i = 0; i < [[GNUMail allBundles] count]; i++)
	{
	  id<GNUMailBundle> aBundle;
	  
	  aBundle = [[GNUMail allBundles] objectAtIndex: i];

	  if ([aBundle respondsToSelector: @selector(messageWillBeDisplayed:inView:)])
	    {
	      [aBundle messageWillBeDisplayed: theMessage  inView: theTextView];
	    }
	}
    
      [[theTextView textStorage] appendAttributedString: [NSAttributedString attributedStringFromContentForPart: theMessage
									     controller: [[theTextView window] windowController]]];
      [[theTextView textStorage] quote];
      [[theTextView textStorage] format];
      
      [[theTextView textStorage] insertAttributedString: [NSAttributedString attributedStringFromHeadersForMessage: theMessage
									     showAllHeaders: headersFlag
									     useMailHeaderCell: YES]
				 atIndex: 0];
				 
      
      // We update the Flags of our message (ie., we add PantomimeSeen)
      theFlags = [theMessage flags];
      
      // If the message was a new one, let's change the app icon back to GNUMail.tiff
      if (![theFlags contain: PantomimeSeen])
	{
	  [theFlags add: PantomimeSeen];
	}
      
      // We remove the potential \\Recent IMAP flag.
      [theFlags remove: PantomimeRecent];
      
      // We ensure that the selected table row is properly refreshed after changing the flags
      // FIXME: find a more elegant solution.
      aDelegate = [[GNUMail lastMailWindowOnTop] delegate];
      
      if (aDelegate)
	{
	  id aDataView;
	  
	  aDataView = nil;

	  if ([aDelegate isKindOfClass: [MailWindowController class]])
	    {
	      aDataView = [aDelegate dataView];
	    }
	  else
	    {
	      aDataView = [[aDelegate mailWindowController] dataView];
	    }

	  if ([aDataView selectedRow] >= 0)
	    {
	      [aDataView setNeedsDisplayInRect: [aDataView rectOfRow: [aDataView selectedRow]]];		  
	    }
	}
      
      // We finally highlight the URLs in our message, if we want to
      if ([[NSUserDefaults standardUserDefaults] objectForKey: @"HIGHLIGHT_URL"] &&
	  [[[NSUserDefaults standardUserDefaults] objectForKey: @"HIGHLIGHT_URL"] intValue] == NSOnState)
	{
          [[theTextView textStorage] highlightAndActivateURL];

          // We update the rects of our cursors
          [[theTextView window] invalidateCursorRectsForView: theTextView];
	}

      // We inform our bundles that the message HAS BEEN shown in the text view
      for (i = 0; i < [[GNUMail allBundles] count]; i++)
	{
	  id<GNUMailBundle> aBundle;
	  
	  aBundle = [[GNUMail allBundles] objectAtIndex: i];
	  
	  if ([aBundle respondsToSelector: @selector(messageWasDisplayed:inView:)])
	    {
	      [aBundle messageWasDisplayed: theMessage  inView: theTextView];
	    }
	}

      // If we have more than one attachement, we create a 'save all' menu at the top
      if ([[(GNUMail *)[NSApp delegate] saveMenu] numberOfItems] > 2)
        {
          NSMenuItem *aMenuItem;

	  aMenuItem = [[NSMenuItem alloc] init];
          [aMenuItem setTitle: _(@"All Attachments")];
	  [aMenuItem setTarget: [NSApp delegate]];
          [aMenuItem setAction: @selector(saveAllAttachments:)];
          [aMenuItem setKeyEquivalent: @""];
          [[(GNUMail *)[NSApp delegate] saveMenu] insertItem: aMenuItem  atIndex: 1];
	  RELEASE(aMenuItem);
        }
    }
  else
    {
      NSDebugLog(@"Unable to find the message in the hashtable!");
    }
  
  // We scroll to the beginning of the message and we remove any previous text selection
  [theTextView scrollPoint: NSMakePoint(0,0)];
  [theTextView setSelectedRange: NSMakeRange(0,0)];
}


//
//
//
+ (void) showMessageRawSource: (CWMessage *) theMessage 
		       target: (NSTextView *) theTextView
{
  if (theMessage && theTextView)
    {
      NSAttributedString *theAttributedString;
      NSDictionary *theAttributes;
      NSString *aString;
      NSData *aData;

      if ([theMessage isKindOfClass: [CWIMAPMessage class]] && ![(CWIMAPFolder *)[theMessage folder] selected])
      	{
      	  return;
      	}

      theAttributes = [NSDictionary dictionaryWithObject: [NSFont userFixedPitchFontOfSize: 0]
				    forKey: NSFontAttributeName];
      aData = [theMessage rawSource];
      
      if (!aData)
	{
	  aString = _(@"Loading message...");

	  if (![[TaskManager singleInstance] taskForService: [[theMessage folder] store]])
	    {
	      Task *aTask;

	      [theMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessageLoading];
	      
	      aTask = [[Task alloc] init];
	      [aTask setKey: [Utilities accountNameForFolder: [theMessage folder]]];
	      aTask->op = LOAD_ASYNC;
	      aTask->immediate = YES;
	      aTask->total_size = (float)[theMessage size]/(float)1024;
	      [aTask setMessage: theMessage];
	      [[TaskManager singleInstance] addTask: aTask];
	      RELEASE(aTask);
	    }

	  [[[TaskManager singleInstance] taskForService: [[theMessage folder] store]] addController: [[theTextView window] windowController]];
	}
      else
	{
	  // If the message's encoding is 8bit or binary, we try to use the message's charset
	  if ([theMessage contentTransferEncoding] == PantomimeEncoding8bit || [theMessage contentTransferEncoding] == PantomimeEncodingBinary)
	    {
	      NSData *aCharset;

	      if ([[theMessage charset] isEqualToString: @"us-ascii"])
		{
		  aCharset = [@"iso-8859-1" dataUsingEncoding: NSASCIIStringEncoding];
		}
	      else
		{
		  aCharset = [[theMessage charset] dataUsingEncoding: NSASCIIStringEncoding];
		}

	      aString = AUTORELEASE([[NSString alloc] initWithData: aData
						      encoding: [NSString encodingForCharset: aCharset]]);
	      
	      //NSLog(@"RAWSOURCE = |%@| |%@|", aString, [theMessage charset]);
	    }
	  else
	    {
	      aString = AUTORELEASE([[NSString alloc] initWithData: aData  encoding: NSASCIIStringEncoding]);

	      // Again, we check for broken MUAs.
	      // WE FORCE
	      if (!aString)
		{
		  aString = [NSString stringWithData: aData  charset: [@"iso-8859-1" dataUsingEncoding: NSASCIIStringEncoding]];
		  
		  if (!aString)
		    {
		      aString = [NSString stringWithData: aData  charset: [@"utf-8" dataUsingEncoding: NSASCIIStringEncoding]];
		    }
		}
	    }
	}
      
      theAttributedString = [[NSAttributedString alloc] initWithString: aString attributes: theAttributes];
      if (theAttributedString)
        [[theTextView textStorage] setAttributedString: theAttributedString];
      RELEASE(theAttributedString);
     
      // We scroll to the beginning of the message and we remove any previous text selection
      [theTextView scrollPoint: NSMakePoint(0,0)];
      [theTextView setSelectedRange: NSMakeRange(0,0)];
    }
  else
    {
      NSBeep();
    }
}


//
//
//
+ (void) clickedOnCell: (id <NSTextAttachmentCell>) attachmentCell
	        inRect: (NSRect) cellFrame
               atIndex: (unsigned) charIndex
		sender: (id) sender
{
  NSTextAttachment *attachment;
  NSFileWrapper *filewrapper;
  MimeType *aMimeType;
  NSString *aString;
  NSWindow *aWindow;

  // If it's our header cell, we immediately return
  if ([attachmentCell isKindOfClass: [MailHeaderCell class]])
    {
      return;
    }
  
  attachment = [attachmentCell attachment];
  filewrapper = [attachment fileWrapper];
  aMimeType = nil;

  aMimeType = [[MimeTypeManager singleInstance] mimeTypeForFileExtension:
						  [[filewrapper preferredFilename] pathExtension]];
  
  if (!aMimeType || [aMimeType action] == PROMPT_SAVE_PANEL || sender == [NSApp delegate])
    {
      NSSavePanel *aSavePanel;

      aSavePanel = [NSSavePanel savePanel];
      [aSavePanel setAccessoryView: nil];
      [aSavePanel setRequiredFileType: @""];
      
      if ([sender respondsToSelector: @selector(window)])
	{
	  aWindow = [sender window];
	}
      else
	{
	  aWindow = [GNUMail lastMailWindowOnTop];
	}
      
      [aSavePanel beginSheetForDirectory: [GNUMail currentWorkingPath] 
		  file: [filewrapper preferredFilename] 
		  modalForWindow: aWindow
		  modalDelegate: self 
		  didEndSelector: @selector(_savePanelDidEnd: returnCode: contextInfo:) 
		  contextInfo: filewrapper];
    }
  else if ([aMimeType action] == OPEN_WITH_WORKSPACE)
    {
      aString = [NSString stringWithFormat:@"%@/%d_%@", GNUMailTemporaryDirectory(), 
			  [[NSProcessInfo processInfo] processIdentifier],
			  [filewrapper preferredFilename]];
      
      if ([[filewrapper regularFileContents] writeToFile: aString
					     atomically: YES])
	{
	  [[NSFileManager defaultManager] enforceMode: 0600  atPath: aString];

	  //
	  // If we successfully open the file with the Workspace, it will be 
	  // removed when the application exists in GNUMail+Extensions: -removeTemporaryFiles.
	  //
	  if (![[NSWorkspace sharedWorkspace] openFile: aString])
	    {
	      [[NSFileManager defaultManager] removeFileAtPath: aString
					      handler: nil];
	    }
	}
    }
  else
    { 
      if (![[NSFileManager defaultManager] fileExistsAtPath: [aMimeType dataHandlerCommand]])
	{
	  
	  NSRunAlertPanel(_(@"Error!"),
			  _(@"The external program (%@) for opening this MIME-Type (%@) can't be found."),
			  _(@"OK"),
			  NULL,
			  NULL,
			  [aMimeType dataHandlerCommand], [aMimeType mimeType]);
	  return;
	}
      
      aString = [NSString stringWithFormat:@"%@/%d_%@", GNUMailTemporaryDirectory(), 
			  [[NSProcessInfo processInfo] processIdentifier],
			  [filewrapper preferredFilename]];
      
      if ([[filewrapper regularFileContents] writeToFile: aString
					     atomically: YES])
	{
	  NSMutableString *aPath;
	  NSTask *aTask;

	  [[NSFileManager defaultManager] enforceMode: 0600  atPath: aString];
	  
	  aTask = [[NSTask alloc] init];
	  
	  // Construct the launch path. If is an MacOS app wrapper, add the full path to the binary
	  aPath = [[NSMutableString alloc] initWithString: [aMimeType dataHandlerCommand]];
#ifdef MACOSX
	  if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath: aPath])
	    {
	      [aPath appendString: [NSString stringWithFormat: @"/Contents/MacOS/%@", 
					     [[aPath stringByDeletingPathExtension] lastPathComponent]]];
	    }
#endif
	  
	  // Launch task and look for exceptions
	  NS_DURING
	    {
	      // We register for our notification
	      [[NSNotificationCenter defaultCenter] 
		addObserver: [NSApp delegate]
		selector: @selector(taskDidTerminate:)
		name: NSTaskDidTerminateNotification
		object: aTask];

	      [aTask setLaunchPath: aPath];
	      [aTask setArguments: [NSArray arrayWithObjects: aString, nil]];
	      [aTask launch];
	    }
	  NS_HANDLER
	    {
	      NSRunAlertPanel(_(@"Error!"),
			      _(@"There was an error launching the external program (%@) for opening this attachment (%@)!\nException: %@"),
			      _(@"OK"),
			      NULL,
			      NULL,
			      aPath, aString, localException);
	    }
	  NS_ENDHANDLER
	}
      else
	{
	  NSBeep();
	}
    }
}


//
//
//
+ (void) restoreOpenFoldersForStore: (id) theStore
{
  if ([[NSUserDefaults standardUserDefaults] objectForKey: @"OPEN_LAST_MAILBOX"] == nil ||
      [[NSUserDefaults standardUserDefaults] boolForKey: @"OPEN_LAST_MAILBOX"])
    {
      NSMutableArray *foldersToOpen;
      
      foldersToOpen = [[NSUserDefaults standardUserDefaults] objectForKey: @"FOLDERS_TO_OPEN"];
      
      if (!foldersToOpen || [foldersToOpen count] == 0)
	{
#ifdef MACOSX
          // On OS X, we show an empty viewer window if we had no mailbox
          // to open upon GNUMail's startup
          if ([[GNUMail allMailWindows] count] == 0)
            {
              [[NSApp delegate] newViewerWindow: self];
            }
#endif
	  return;
	}
      else
	{
	  NSUInteger i;
	  
	  for (i = 0; i < [foldersToOpen count]; i++)
	    {
	      CWURLName *theURLName;
	      
	      theURLName = [[CWURLName alloc] initWithString: [foldersToOpen objectAtIndex: i]
					      path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
	      
	      if (([theStore isKindOfClass: [CWLocalStore class]] &&
		   [[theURLName protocol] caseInsensitiveCompare: @"LOCAL"] == NSOrderedSame) ||
		  ([theStore isKindOfClass: [CWIMAPStore class]] &&
		   [[theURLName protocol] caseInsensitiveCompare: @"IMAP"] == NSOrderedSame &&
		   [[theURLName host] caseInsensitiveCompare: [(CWIMAPStore *)theStore name]] == NSOrderedSame &&
		   [[theURLName username] caseInsensitiveCompare: [theStore username]] == NSOrderedSame))
		{
		  [[MailboxManagerController singleInstance] openFolderWithURLName: theURLName
							     sender: [NSApp delegate]];
		}
	      
	      RELEASE(theURLName);
	    }
	}
    }
}

@end



//
// Private implementation for Utilities
//
@implementation Utilities (Private)

//
//
//
+ (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel
	       returnCode: (int) theReturnCode
	      contextInfo: (void *) theContextInfo
{
  // If successful, save file under designated name
  if (theReturnCode == NSOKButton)
    {
      if (![[(NSFileWrapper *)theContextInfo regularFileContents] writeToFile: [theSavePanel filename]
								  atomically: YES])
	{
	  NSBeep();
	}
      else
	{
	  [[NSFileManager defaultManager] enforceMode: 0600  atPath: [theSavePanel filename]];
	}

      [GNUMail setCurrentWorkingPath: [[theSavePanel filename] stringByDeletingLastPathComponent]];
    }
}

@end


//
// C functions
//
NSComparisonResult CompareVersion(NSString *theCurrentVersion, NSString *theLatestVersion)
{
  NSArray *currentVersion, *latestVersion;
  int i, currentCount, latestCount;
  
  currentVersion = [theCurrentVersion componentsSeparatedByString: @"."];
  currentCount = [currentVersion count];

  latestVersion = [theLatestVersion componentsSeparatedByString: @"."];
  latestCount = [latestVersion count];
  
  //
  // Note: Version 1.0 < 1.0.0 < 1.0.1
  //
  for (i = 0; i < currentCount && i < latestCount; i++)
    {
      int c, l;
      
      c = [[currentVersion objectAtIndex: i] intValue];
      l = [[latestVersion objectAtIndex: i] intValue];
      
      if ( c < l )
	{
	  return NSOrderedAscending;
	}
      
      if ( c > l )
	{
	  return NSOrderedDescending;
	}
    }
  
  if ( i < latestCount )
    {
      return NSOrderedAscending;
    }
  
  return NSOrderedSame;
}


//
//
//
NSString *GNUMailTemporaryDirectory()
{
  NSFileManager *aFileManager;
  NSString *aString;
  
  aString = [NSString stringWithFormat: @"%@/GNUMail", NSTemporaryDirectory()];
  aFileManager = [NSFileManager defaultManager];

  if (![aFileManager fileExistsAtPath: aString])
    {
      [aFileManager createDirectoryAtPath: aString  
		    attributes: [aFileManager fileAttributesAtPath: NSTemporaryDirectory()  traverseLink: NO]];
      [aFileManager enforceMode: 0700  atPath: aString];
    }
  
  return aString;
}


//
//
//
NSString *GNUMailUserLibraryPath()
{
  return [NSString stringWithFormat: @"%@/GNUMail", 
		   [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)
						       objectAtIndex: 0] ];
}


//
//
//
NSString *GNUMailVersion()
{
#ifdef MACOSX
  return [[[NSBundle bundleForClass: [[NSApp delegate] class]] infoDictionary] objectForKey: @"CFBundleVersion"];
#else
  return [[[NSBundle mainBundle] infoDictionary] objectForKey: @"ApplicationRelease"];
#endif
}

//
//
//
NSString *GNUMailBaseURL()
{
  return @"http://gnustep-nonfsf.nongnu.org/gnumail/";
}

//
//
//
NSString *GNUMailCopyrightInfo()
{
#ifdef MACOSX
  return [[[NSBundle mainBundle] infoDictionary] objectForKey: @"NSHumanReadableCopyright"]; 
#else
  return [[[NSBundle mainBundle] infoDictionary] objectForKey: @"Copyright"];
#endif
}
