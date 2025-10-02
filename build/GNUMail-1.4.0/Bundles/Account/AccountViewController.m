/*
**  AccountViewController.m
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

#import "AccountViewController.h"

#import "AccountEditorWindowController.h"
#import "GNUMail.h"
#import "Constants.h"
#import "MailboxManagerController.h"

#import <Pantomime/NSString+Extensions.h>

#ifndef MACOSX
#import "AccountView.h"
#endif

static NSMutableDictionary *allAccounts = nil;

#define KEY_FROM_VALUE(value) ({ \
  NSEnumerator *theEnumerator; \
  id aKey; \
  \
  theEnumerator = [allAccounts keyEnumerator]; \
  \
  while ((aKey = [theEnumerator nextObject])) \
    { \
      if ([allAccounts objectForKey: aKey] == value) \
	{ \
	  break; \
	} \
    } \
  aKey; \
})


//
// Function used to sort account entries  
//
NSComparisonResult sortAccountEntries(id se1, id se2, void *context)
{
  NSNumber *aNumber;
  int se1Type, se2Type;
  int se1Order, se2Order;

  aNumber = [[se1 objectForKey: @"RECEIVE"] objectForKey: @"SERVERTYPE"];
  if ( !aNumber )
    se1Type = POP3;
  else 
    se1Type = [aNumber intValue];


  aNumber = [[se2 objectForKey: @"RECEIVE"] objectForKey: @"SERVERTYPE"];
  if ( !aNumber )
    se2Type = POP3;
  else 
    se2Type = [aNumber intValue];

  if (se1Type == UNIX)
    se1Order = 0;
  else if (se1Type == POP3)
    se1Order = 5;
  else if (se1Type == IMAP)
    se1Order = 10;
  else
    se1Order = 20;


  if (se2Type == UNIX)
    se2Order = 0;
  else if (se2Type == POP3)
    se2Order = 5;
  else if (se2Type == IMAP)
    se2Order = 10;
  else
    se2Order = 20;

  if (se1Order < se2Order)
    return NSOrderedAscending;
  if (se1Order > se2Order)
    return NSOrderedDescending;

  if (se1Type == POP3 || se1Type == IMAP)
    {
      int rvalue;
      id k1, k2;

      k1 = [[se1 objectForKey: @"RECEIVE"] objectForKey: @"SERVERNAME"];
      k2 = [[se2 objectForKey: @"RECEIVE"] objectForKey: @"SERVERNAME"];

      if ( k1 && k2 )
	rvalue = [k1 compare: k2];
      else 
	return (k1 ? NSOrderedDescending : NSOrderedAscending);

      if (rvalue != NSOrderedSame)
	return rvalue;

      k1 = [[se1 objectForKey: @"RECEIVE"] objectForKey: @"USERNAME"];
      k2 = [[se2 objectForKey: @"RECEIVE"] objectForKey: @"USERNAME"];

      if ( k1 && k2 )
	rvalue = [k1 compare: k2];
      else 
	return (k1 ? NSOrderedDescending : NSOrderedAscending);
      
      if (rvalue != NSOrderedSame)
	return rvalue;
      
      // We have a problem, the server name and the username are equal.
      // Let's compare the account name.
      k1 = KEY_FROM_VALUE(se1);
      k2 = KEY_FROM_VALUE(se2);

      if ( k1 && k2 )
	return [k1 compare: k2];
      else
	return NSOrderedSame;
    }
  else // se1Type == UNIX
    {
      return [[[se1 objectForKey: @"RECEIVE"] objectForKey: @"MAILSPOOLFILE"]
	       compare: [[se2 objectForKey: @"RECEIVE"] objectForKey: @"MAILSPOOLFILE"]];
    }
  
}


static AccountViewController *singleInstance = nil;

// 
// Private methods
//
@interface AccountViewController (Private)
- (void) _updateAccountsListBecause: (UpdateReason) reason;
@end


//
//
//
@implementation AccountViewController

- (id) initWithNibName: (NSString *) theName
{  
  NSButtonCell *cell;

  self = [super init];

#ifdef MACOSX
  if (![NSBundle loadNibNamed: theName  owner: self] )
    {
      NSDebugLog(@"Fatal error occurred while loading the ColorsView nib file");
      AUTORELEASE(self);
      return nil;
    }

  RETAIN(view);
  
  [tableView setTarget: self];
  [tableView setDoubleAction: @selector(editClicked:)];

#else
  // We link our view and our outlets
  view = [[AccountView alloc] initWithParent: self];
  [view layoutView];
  tableView = ((AccountView *)view)->tableView;
#endif
  
  cell = [[NSButtonCell alloc] init];
  [cell setButtonType: NSSwitchButton];
  [cell setImagePosition: NSImageOnly];
  [cell setControlSize: NSSmallControlSize];
  [[tableView tableColumnWithIdentifier: @"Enabled"] setDataCell: cell];
  RELEASE(cell);
    
  allAccounts = [[NSMutableDictionary alloc] init];

  // We get our defaults for this panel
  [self initializeFromDefaults];
  [self _updateAccountsListBecause: FirstTime];

  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"AccountViewController: -dealloc");
  
  singleInstance = nil;

  // Cocoa bug?
#ifdef MACOSX
  [tableView setDataSource: nil];
#endif

  DESTROY(allAccounts);
  RELEASE(view);

  [super dealloc];
}


//
// action methods
//
- (IBAction) addClicked: (id) sender
{
  AccountEditorWindowController *aAccountEditorWindowController;
  int result;

  aAccountEditorWindowController = [[AccountEditorWindowController alloc]
				     initWithWindowNibName: @"AccountEditorWindow"];
  [aAccountEditorWindowController setOperation: ACCOUNT_ADD];
  
  result = [NSApp runModalForWindow: [aAccountEditorWindowController window]];
  
  // We must update our preferences
  if (result == NSRunStoppedResponse)
    {
      [self _updateAccountsListBecause: DidAdd];
    }

  // We release our controller
  RELEASE(aAccountEditorWindowController);
  
  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];
}


//
//
//
- (IBAction) defaultClicked: (id) sender
{
  NSMutableDictionary *theAccount, *allPreferences;
  NSEnumerator *theEnumerator;
  NSArray *theArray;
  NSString *aKey;

  if ([tableView selectedRow] < 0)
    {
      NSBeep();
      return;
    }
  
  theArray = [[allAccounts allValues]
	       sortedArrayUsingFunction: sortAccountEntries
	       context: nil];
  DESTROY(allAccounts);
    
  allPreferences = [[NSMutableDictionary alloc] init];
  allAccounts = [[NSMutableDictionary alloc] init];
 
  [allPreferences addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]];
  
  if ( [allPreferences objectForKey: @"ACCOUNTS"] )
    {
      [allAccounts addEntriesFromDictionary: [allPreferences objectForKey: @"ACCOUNTS"]];
    }

  // We set all the accounts as being not the default one. If we see the key at the selected row,
  // we set that one to the default one.
  theEnumerator = [allAccounts keyEnumerator];
  
  while ( (aKey = [theEnumerator nextObject]) )
    {
      theAccount = [[NSMutableDictionary alloc] initWithDictionary: [allAccounts objectForKey: aKey]];

      if ( [aKey isEqualToString: KEY_FROM_VALUE([theArray objectAtIndex: [tableView selectedRow]])] )
	{
	  [theAccount setObject: [NSNumber numberWithBool: YES]  forKey: @"DEFAULT"];
	}
      else
	{
	  [theAccount setObject: [NSNumber numberWithBool: NO]  forKey: @"DEFAULT"];
	}

      [allAccounts setObject: theAccount  forKey: aKey];
      RELEASE(theAccount);
    }

  [allPreferences setObject: allAccounts  forKey: @"ACCOUNTS"];

  // FIXME - This is causing a segfault under OS X
#ifndef MACOSX
  [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
  [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences
					 forName: @"PREFERENCES"];
  RELEASE(allPreferences);
  [self _updateAccountsListBecause: DidModify];
}


//
//
//
- (IBAction) deleteClicked: (id) sender
{
  NSDictionary *allValues;
  NSArray *theArray;
  NSString *aKey;
  int choice;
  
  if ( [tableView selectedRow] < 0 ) 
    {
      NSBeep();
      return;
    }

  theArray = [[allAccounts allValues]
	       sortedArrayUsingFunction: sortAccountEntries
	       context: nil];

  aKey = KEY_FROM_VALUE([theArray objectAtIndex: [tableView selectedRow]]);
  if (aKey == nil)
    {
      [[NSException exceptionWithName:@"Exception" reason:@"[AccountViewController deleteClicked] Item selected not found among accounts, internal error" userInfo:nil] raise];
      return;
    }

  allValues = [[allAccounts objectForKey: aKey] objectForKey: @"RECEIVE"];
  
  if ( [[MailboxManagerController singleInstance] storeForName: [allValues objectForKey: @"SERVERNAME"]
						  username: [allValues objectForKey: @"USERNAME"]] )
    {
      NSRunInformationalAlertPanel(_(@"Error!"),
				   _(@"To delete this account, you must first close the connection with the server."),
				   _(@"OK"),
				   NULL, 
				   NULL,
				   NULL);
      return;
    } 
  
  choice = NSRunAlertPanel(_(@"Delete..."),
			   _(@"Are you sure you want to delete this account?"),
			   _(@"Cancel"), // default
			   _(@"Yes"),    // alternate
			   NULL);
  
  if (choice == NSAlertAlternateReturn)
    {
      // We remove the entry from the user defaults db
      NSMutableDictionary *allPreferences;
      
      allPreferences = [[NSMutableDictionary alloc] init];
      [allPreferences addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] 
						  volatileDomainForName: @"PREFERENCES"]];

      // We remove our entry from our dictionary of servers
      [allAccounts removeObjectForKey: aKey];
      
      // We update the volatile user defaults with the new receiving servers list
      [allPreferences setObject: allAccounts  forKey: @"ACCOUNTS"];
#ifndef MACOSX
      [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
      [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences
					     forName: @"PREFERENCES"];
      RELEASE(allPreferences);

      [self _updateAccountsListBecause: DidRemove];
      
      if ( [allAccounts count] > 0 ) 
	{
	  [tableView selectRow: 0 
		     byExtendingSelection: NO];
	}
    }
}


//
//
//
- (IBAction) editClicked: (id) sender
{
  AccountEditorWindowController *aAccountEditorWindowController;
  NSArray *theArray;
  NSInteger result;
  
  if ([tableView selectedRow] < 0)
    {
      NSBeep();
      return;
    }
  
  theArray = [[allAccounts allValues]
	       sortedArrayUsingFunction: sortAccountEntries
	       context: nil];
  
  aAccountEditorWindowController = [[AccountEditorWindowController alloc]
				     initWithWindowNibName: @"AccountEditorWindow"];
  [aAccountEditorWindowController setKey: KEY_FROM_VALUE([theArray objectAtIndex: [tableView selectedRow]])];
  [aAccountEditorWindowController setOperation: ACCOUNT_EDIT];
  [aAccountEditorWindowController initializeFromDefaults];
  
  result = [NSApp runModalForWindow: [aAccountEditorWindowController window]];
  
  // We must update our preferences
  if (result == NSRunStoppedResponse)
    {
      [self _updateAccountsListBecause: DidModify];
    }
  
  // We release our controller
  RELEASE(aAccountEditorWindowController);

  // We reorder our Preferences window to the front
  [[view window] orderFrontRegardless];
}


//
// Data Source methods
//
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  return [allAccounts count];
}


//
//
//
- (id)           tableView: (NSTableView *) aTableView
 objectValueForTableColumn: (NSTableColumn *) aTableColumn 
		       row: (NSInteger) rowIndex
{
  NSDictionary *allValues, *theAccount;
  NSArray *theArray;
  NSString *aKey;

  theArray = [[allAccounts allValues]
	       sortedArrayUsingFunction: sortAccountEntries
	       context: nil];
  
  aKey = KEY_FROM_VALUE([theArray objectAtIndex: rowIndex]);
  theAccount = [theArray objectAtIndex: rowIndex];
  allValues = [theAccount objectForKey: @"RECEIVE"];
  
  if ([[[aTableColumn headerCell] stringValue] isEqualToString: _(@"Enabled")])
    {
      return [theAccount objectForKey: @"ENABLED"];
    }
  else
    {
      NSMutableString *aMutableString;
      NSNumber *aNumber;

      aNumber = [allValues objectForKey: @"SERVERTYPE"];
      aMutableString = AUTORELEASE([[NSMutableString alloc] init]);

      if ( !aNumber )
	{
	  aNumber = [NSNumber numberWithInt: POP3];
	}
      
      if ( [aNumber intValue] == POP3 || [aNumber intValue] == IMAP )
	{
	  [aMutableString appendString: [NSString stringWithFormat: @"%@ - %@ @ %@ [%@]", aKey,
						  ([allValues objectForKey: @"USERNAME"] ? (id)[allValues objectForKey: @"USERNAME"] :
						   (id)_(@"No username")),
						  ([allValues objectForKey: @"SERVERNAME"] ? (id)[allValues objectForKey: @"SERVERNAME"] : 
						   (id)_(@"No server name")),
						  ([aNumber intValue] == POP3 ? (id)_(@"POP3") : (id)_(@"IMAP"))]];
	}
      else
	{
	  [aMutableString appendString: [NSString stringWithFormat: _(@"%@ [UNIX]"),
						  [allValues objectForKey: @"MAILSPOOLFILE"]]];
	}

      if ( [[theAccount objectForKey: @"DEFAULT"] boolValue] )
	{
	  [aMutableString appendString: _(@" - default")];
	}

      return aMutableString;
    }
  
  // Never reached
  return @"";
}


//
//
//
- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
	       row: (NSInteger) rowIndex
{
  NSMutableDictionary *theAccount, *allPreferences;
  NSArray *theArray;
  NSString *aKey;

  theArray = [[allAccounts allValues]
	       sortedArrayUsingFunction: sortAccountEntries
	       context: nil];
  aKey = KEY_FROM_VALUE([theArray objectAtIndex: rowIndex]);
  if (aKey == nil)
    {
      NSLog(@"Account not found, returning");
      return;
    }

  theAccount = [[NSMutableDictionary alloc] initWithDictionary: [theArray objectAtIndex: rowIndex]];
  
  if (![[theAccount objectForKey: @"ENABLED"] boolValue])
    {
      [theAccount setObject: [NSNumber numberWithBool: YES]  forKey: @"ENABLED"];
    }
  else
    {
      [theAccount setObject: [NSNumber numberWithBool: NO]  forKey: @"ENABLED"];
    }

  DESTROY(allAccounts);

  allPreferences = [[NSMutableDictionary alloc] init];
  allAccounts = [[NSMutableDictionary alloc] init];
 
  [allPreferences addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]];
  
  if ([allPreferences objectForKey: @"ACCOUNTS"])
    {
      [allAccounts addEntriesFromDictionary: [allPreferences objectForKey: @"ACCOUNTS"]];
    }

  [allAccounts setObject: theAccount  forKey: aKey];
  RELEASE(theAccount);
  [allPreferences setObject: allAccounts  forKey: @"ACCOUNTS"];

  // FIXME - This is causing a segfault under OS X
#ifndef MACOSX
  [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
  [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences
					 forName: @"PREFERENCES"];
  RELEASE(allPreferences);
  [self _updateAccountsListBecause: DidModify];
}

//
// access methods
//
- (NSImage *) image
{
  NSBundle *aBundle;
  
  aBundle = [NSBundle bundleForClass: [self class]];

  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile:
					[aBundle pathForResource: @"account" ofType: @"tiff"]]);
}


//
//
//
- (NSString *) name
{
  return _(@"Account");
}


//
//
//
- (NSView *) view
{
  return view;
}


//
//
//
- (BOOL) hasChangesPending
{
  NSUserDefaults *aUserDefaults;

  aUserDefaults = [NSUserDefaults standardUserDefaults];
  
  return !([[aUserDefaults objectForKey: @"ACCOUNTS"]
	     isEqual: [[aUserDefaults volatileDomainForName: @"PREFERENCES"] 
			objectForKey: @"ACCOUNTS"]]);
}


//
// This method is used to initialize the fields in this view to
// the values from the user defaults database. We must take care
// of nil values since MacOS-X doesn't like that.
//
- (void) initializeFromDefaults
{  
  [tableView reloadData];
  [tableView setNeedsDisplay: YES];
}


//
//
//
- (void) saveChanges
{
  
#warning FIXME remove the cache files of deleted accounts
  //    //
//    // We verify which accounts have been renamed or deleted
//    //
//    serversEnumerator = [(NSDictionary *)[[NSUserDefaults standardUserDefaults] 
//  					 objectForKey: @"RECEIVING"] keyEnumerator];
  
//    while ( (aKey = [serversEnumerator nextObject]) )
//      {
//        if ( ![_values.allServers objectForKey: aKey] )
//  	{
//  	  // We remove our cache files
//  	  NSDebugLog(@"Deleting cache files associated with %@", aKey);
	  
//  	  filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: GNUMailUserLibraryPath()];
      
//  	  while ( (aString = [filesEnumerator nextObject]) )
//  	    {
//  	      // We verify for POP3Cache_server.name.com
//  	      if ( [aString isEqualToString: [NSString stringWithFormat: @"POP3Cache_%@", 
//  						       [Utilities flattenPathFromString: aKey
//  								  separator: @"/"]]] )
//  		{
//  		  [[NSFileManager defaultManager] removeFileAtPath: [NSString stringWithFormat: @"%@/%@",
//  									      GNUMailUserLibraryPath(), aString]
//  						  handler: nil];
//  		}
	      
//  	      // We verify for IMAPCache_server.name.com_mailbox
//  	      if ( [aString hasPrefix: [NSString stringWithFormat: @"IMAPCache_%@_",
//  						 [Utilities flattenPathFromString: aKey
//  							    separator: @"/"]]] )
//  		{
//  		  [[NSFileManager defaultManager] removeFileAtPath: [NSString stringWithFormat: @"%@/%@",
//  									      GNUMailUserLibraryPath(), aString]
//  						  handler: nil];
//  		}
//  	    }
//  	}
//      }
    
  if ([self hasChangesPending])
    {
      NSUserDefaults *aUserDefaults;
      
      aUserDefaults = [NSUserDefaults standardUserDefaults];
      
      [aUserDefaults setObject: [[aUserDefaults volatileDomainForName: @"PREFERENCES"] 
				  objectForKey: @"ACCOUNTS"]
		     forKey: @"ACCOUNTS"];
      
      // We inform that our account profiles have changed
      [[NSNotificationCenter defaultCenter]
	postNotificationName: AccountsHaveChanged
	object: nil
	userInfo: nil];
    }
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[AccountViewController alloc] initWithNibName: @"AccountView"];
    }

  return singleInstance;
}

@end



// 
// Private methods
//
@implementation AccountViewController (Private)

- (void) _updateAccountsListBecause: (UpdateReason) reason
{
  NSMutableDictionary *allPreferences;
  NSMutableDictionary *oldAccounts;

  oldAccounts = allAccounts;

  // We now get the servers list from the volatile user defaults
  allPreferences = [[NSMutableDictionary alloc] init];
  allAccounts = [[NSMutableDictionary alloc] init];
  
  [allPreferences addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] volatileDomainForName: @"PREFERENCES"]];

  if ([allPreferences objectForKey: @"ACCOUNTS"])
    {
      [allAccounts addEntriesFromDictionary: [allPreferences objectForKey: @"ACCOUNTS"]];
    }
  
  // We update the volatile user defaults with the new receiving servers list
  [allPreferences setObject: allAccounts  forKey: @"ACCOUNTS"];
  // FIXME - This is causing a segfault under OS X
#ifndef MACOSX
  [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName: @"PREFERENCES"];
#endif
  [[NSUserDefaults standardUserDefaults] setVolatileDomain: allPreferences
					 forName: @"PREFERENCES"];
  
  RELEASE(allPreferences);


  if (reason == FirstTime || reason == DidRemove)
    {
      [tableView deselectAll: self];
      [tableView reloadData];
    }
  else if (reason == DidModify || reason == DidAdd)
    {
      NSArray *a1 = [[oldAccounts allValues] 	      
		      sortedArrayUsingFunction: sortAccountEntries
		      context: nil];
      NSArray *a2 = [[allAccounts allValues]
		      sortedArrayUsingFunction: sortAccountEntries
		      context: nil];
      NSInteger i, j;
      NSUInteger count = [a1 count];

      [tableView deselectAll: self];
      [tableView reloadData];

      for ( i = 0; i < count; i++ )
	{
	  j = [a1 indexOfObject: [a2 objectAtIndex: i]];
	  if (j == NSNotFound)
	    {
	      [tableView selectRow: i
			 byExtendingSelection: NO];
	      break;
	    }
	}
    }

  TEST_RELEASE(oldAccounts);
}

@end
