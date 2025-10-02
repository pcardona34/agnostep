/*
**  FilterManager.m
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#import "FilterManager.h"

#import "AddressBookController.h"
#import "ConsoleWindowController.h"
#import "Constants.h"
#import "Filter.h"
#import "MailboxManagerController.h"
#import "Utilities.h"

#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWRegEx.h>
#import <Pantomime/CWURLName.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSFileManager+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

static FilterManager *singleInstance = nil;


//
// private methods
//
@interface FilterManager (Private)

- (CWMessage *) _newMessageFromExternalProgramUsingFilter: (Filter *) theFilter
					       message: (CWMessage *) theMessage;
- (BOOL) _matchCriteriasFromMessage: (CWMessage *) theMessage
                             filter: (Filter *) theFilter;
- (BOOL) _matchStrings: (NSArray *) theStrings
             operation: (int) theOperation
              criteria: (NSString *) theCriteria;
- (NSArray *) _stringsFromMessage: (CWMessage *) theMessage
                         criteria: (FilterCriteria *) theFilterCriteria;
@end


NSString *PathToFilters()
{
  return [NSString stringWithFormat: @"%@/%@",
		   GNUMailUserLibraryPath(), @"Filters"];
}


//
//
//
@implementation FilterManager

- (id) init
{
  self = [super init];
  if (self)
    {
      [self setFilters: [NSMutableArray array]];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_filters);
  [super dealloc];
}


//
//
//
- (BOOL) synchronize
{
  return [NSArchiver archiveRootObject: self  toFile: PathToFilters()];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [theCoder encodeObject: [self filters]];
}

- (id) initWithCoder: (NSCoder *) theCoder
{
  self = [super init];
  if (self)
    {
      [self setFilters: [theCoder decodeObject]];
    }
  return self;
}


//
// access/mutation methods
//
- (Filter *) filterAtIndex: (int) theIndex
{
  return [_filters objectAtIndex: theIndex];
}


//
//
//
- (void) addFilter: (Filter *) theFilter
{
  [_filters addObject: theFilter];
}


//
//
//
- (void) addFilter: (Filter *) theFilter
	   atIndex: (int) theIndex
{
  [_filters insertObject: theFilter  atIndex: theIndex];
}


//
//
//
- (void) removeFilter: (Filter *) theFilter;
{
  [_filters removeObject: theFilter];
}


//
//
//
- (NSArray *) filters
{
  return _filters;
}


//
//
//
- (void) setFilters: (NSArray *) theFilters
{
  RELEASE(_filters);

  if (theFilters)
    {
      _filters = [[NSMutableArray alloc] initWithArray: theFilters];
    }
  else
    {
      _filters = nil;
    }
}


//
//
//
- (BOOL) matchExistsForFilter: (Filter *) theFilter
		      message: (CWMessage *) theMessage
{
  NSAutoreleasePool *pool;
  CWMessage *aMessage;
  
  BOOL aBOOL;

  if (!theFilter || !theMessage)
    {
      return NO;
    }
  
  pool = [[NSAutoreleasePool alloc] init];

  //
  // FIXME: This can be CPU intensive.
  //
  if ([theFilter useExternalProgram])
    {
      aMessage = [self _newMessageFromExternalProgramUsingFilter: theFilter
		       message: theMessage];
      
      if (!aMessage)
	{
	  RELEASE(pool);
	  return NO;
	}
    }
  else
    {
      aMessage = theMessage;
    }
  
  aBOOL = [self _matchCriteriasFromMessage: aMessage
		filter: theFilter];
  
  if (aMessage != theMessage)
    {
      RELEASE(aMessage);
    }

  RELEASE(pool);
  
  return aBOOL;
}


//
// This method returns the *first* filter that matches
// for the specified message. If no filter matches, nil
// is returned.
//
- (Filter *) matchedFilterForMessage: (CWMessage *) theMessage
				type: (int) theType
{
  NSAutoreleasePool *pool;
  CWMessage *aMessage;
  BOOL quickCheck;
  NSUInteger i, c;

  if (!theMessage)
    {
      return nil;
    }
  quickCheck = NO;
  if (theType == TYPE_INCOMING_QUICK)
    {
      theType = TYPE_INCOMING;
      quickCheck = YES;
    }

  pool = [[NSAutoreleasePool alloc] init];
  c = [_filters count];

  for (i = 0; i < c; i++)
    {
      Filter *aFilter;

      aFilter = [_filters objectAtIndex: i];

      if ( [aFilter isActive] && [aFilter type] == theType )
	{  
	  //
	  // FIXME: This can be CPU intensive.
	  //
	  if ([aFilter useExternalProgram] && quickCheck == NO)
	    {
	      aMessage = [self _newMessageFromExternalProgramUsingFilter: aFilter
			       message: theMessage];
	      
	      if (!aMessage)
		{
		  continue;
		}
	    }
	  else
	    {
	      aMessage = theMessage;
	    }

	  //
	  // If we've a filter that matches, we stop everything. We don't need
	  // to continue searching in the other filters.
	  //
	  if ([self _matchCriteriasFromMessage: aMessage
		     filter: aFilter])
	    {
	      if (aMessage != theMessage)
		{
		  RELEASE(aMessage);
		}
	      
	      RELEASE(pool);
	      return aFilter;
	    }

	  if (aMessage != theMessage)
	    {
	      RELEASE(aMessage);
	    }
	  
	} // if ( [aFilter isActive] && [aFilter type] == theType )
    }
  
  RELEASE(pool);

  return nil;
}


//
//
//
- (Filter *) matchedFilterForMessageAsRawSource: (NSData *) theRawSource
                                           type: (int) theType
{
  Filter *aFilter;
  NSRange aRange;

  aRange = [theRawSource rangeOfCString: "\n\n"];
  aFilter = nil;

  if (aRange.length)
    {
      CWMessage *aMessage;
      
      aMessage = [[CWMessage alloc] initWithHeadersFromData: [theRawSource subdataToIndex: aRange.location + 1] ];
      [aMessage setRawSource: theRawSource];
      aFilter = [self matchedFilterForMessage: aMessage  type: theType];
      
      RELEASE(aMessage);   
    }

  return aFilter;
}


//
//
//
- (NSColor *) colorForMessage: (CWMessage *) theMessage
{
  NSAutoreleasePool *pool;
  CWMessage *aMessage;
  int i, c;

  if (!theMessage)
    {
      return nil;
    }
  
  pool = [[NSAutoreleasePool alloc] init];
  c = [_filters count];

  for (i = 0; i < c; i++)
    {
      Filter *aFilter;
      
      aFilter = [_filters objectAtIndex: i];
      
      if ([aFilter action] == SET_COLOR  && [aFilter isActive])
	{
	  //
	  // FIXME: Should we allow external programs for "coloring" filters? That
	  //        can be *very CPU intensive* 
	  // 
	  if ([aFilter useExternalProgram])
	    {
	      aMessage = [self _newMessageFromExternalProgramUsingFilter: aFilter
			       message: theMessage];
	      
	      if (!aMessage)
		{
		  continue;
		}
	    }
	  else
	    {
	      aMessage = theMessage;
	    }
	  
	  //
	  // If we've a filter that matches, we stop everything. We don't need
	  // to continue searching in the other filters.
	  //
	  if ([self _matchCriteriasFromMessage: aMessage
		     filter: aFilter])
	    {
	      if (aMessage != theMessage)
		{
		  RELEASE(aMessage);
		}
	      
	      RELEASE(pool);
	      return [aFilter actionColor];
	    }

	  if (aMessage != theMessage)
	    {
	      RELEASE(aMessage);
	    }
	} // if ( [aFilter action] == SET_COLOR  && [aFilter isActive])
    }
  
  RELEASE(pool);
  return nil;
}


//
// theKey corresponds to an account name.
//
//
- (CWURLName *) matchedURLNameFromMessage: (CWMessage *) theMessage
				     type: (int) theType
				      key: (NSString *) theKey
				   filter: (Filter *) theFilter
{
  CWURLName *aURLName, *aDefaultURLName;
  NSString *aDefaultURLNameAsString;
  NSDictionary *allValues;

  if (!theFilter)
    {
      theFilter = [self matchedFilterForMessage: theMessage
			type: theType];
    }
  
  allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		 objectForKey: theKey] objectForKey: @"MAILBOXES"];

  if (theType == TYPE_INCOMING)
    {
      aDefaultURLNameAsString = [allValues objectForKey: @"INBOXFOLDERNAME"];
      aDefaultURLName = [[CWURLName alloc] initWithString: aDefaultURLNameAsString
					   path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
    }
  else
    {  
      aDefaultURLNameAsString = [allValues objectForKey: @"SENTFOLDERNAME"];

      // No Sent mailbox was specified. We ignore it.
      if (!aDefaultURLNameAsString)
	{
	  return nil;
	}

      aDefaultURLName = [[CWURLName alloc] initWithString: aDefaultURLNameAsString
					   path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
    }
  
  AUTORELEASE(aDefaultURLName);
  
  // If we have found a filter that matches our message
  if (theFilter && [theFilter type] == theType)
    {
      // We verify if the operation is TRANSFER_TO_FOLDER and if folder DIFFERENT from our default folder
      if ([theFilter action] == TRANSFER_TO_FOLDER &&
	  ![[theFilter actionFolderName] isEqualToString: aDefaultURLNameAsString])
	{
	  aURLName = [[CWURLName alloc] initWithString: [theFilter actionFolderName]
					path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
	  AUTORELEASE(aURLName);
	}
      // We verify if the operation is DELETE. If so, we transfer the message to the trash folder.
      else if ([theFilter action] == DELETE)
	{      
#warning FIXME No Trash mailbox was specified
	  aURLName = [[CWURLName alloc] initWithString: [allValues objectForKey: @"TRASHFOLDERNAME"]
					path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
	  AUTORELEASE(aURLName);
	}
      // We have an UNKNOWN action. We simply add the message to our Inbox (our Sent) folder.
      else
	{
	  aURLName = aDefaultURLName;
	}
    }
  // We haven't found a filter, let's add it to our Inbox Folder
  else
    {
      aURLName = aDefaultURLName;
    }

  return aURLName;
}


//
//
//
- (CWURLName *) matchedURLNameFromMessageAsRawSource: (NSData *) theRawSource
						type: (int) theType
						 key: (NSString *) theKey
					      filter: (Filter *) theFilter
{
  CWURLName *aURLName;
  NSRange aRange;
 
  aRange = [theRawSource rangeOfCString: "\n\n"];
  aURLName = nil;

  if (aRange.length)
    {
      CWMessage *aMessage;
      
      aMessage = [[CWMessage alloc] initWithHeadersFromData: [theRawSource subdataToIndex: aRange.location + 1] ];
      [aMessage setRawSource: theRawSource];

      aURLName = [self matchedURLNameFromMessage: aMessage
		       type: theType
		       key: theKey
		       filter: theFilter];
      
      RELEASE(aMessage);   
    }
  else
    {
      NSDictionary *allValues;

      allValues = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] 
		     objectForKey: theKey] objectForKey: @"MAILBOXES"];

      if (theType == TYPE_INCOMING)
	{
	  NSLog(@"FilterManager: Corrupted message received for filtering. Returning default Inbox.");
	  aURLName = [[CWURLName alloc] initWithString: [allValues objectForKey: @"INBOXFOLDERNAME"]
					path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
	}
      else
	{
	  NSLog(@"FilterManager: Corrupted message received for filtering. Returning default Sent.");
	  aURLName = [[CWURLName alloc] initWithString: [allValues objectForKey: @"SENTFOLDERNAME"]
					path: [[NSUserDefaults standardUserDefaults] objectForKey: @"LOCALMAILDIR"]];
	}
      
      AUTORELEASE(aURLName);
    }
  
  return aURLName;
}


//
//
//
- (void) updateFiltersFromOldPath: (NSString *) theOldPath
			   toPath: (NSString *) thePath
{
  Filter *aFilter;
  NSUInteger i, c;
  
  c = [_filters count];

  for (i = 0; i < c; i++)
    {   
      aFilter = [_filters objectAtIndex: i];
      
      if ([aFilter action] == TRANSFER_TO_FOLDER)
	{
	  if ([[aFilter actionFolderName] isEqualToString: theOldPath])
	    {
	      [aFilter setActionFolderName: thePath];
	    }
	}
    }
  
  [self synchronize];	
}


//
// class methods
//
+ (id) singleInstance
{
  if (!singleInstance)
    {      
      NS_DURING
	singleInstance = [NSUnarchiver unarchiveObjectWithFile: PathToFilters()];
      NS_HANDLER
	NSLog(@"Caught exception while unarchiving the Filters. Ignoring.");
        singleInstance = nil;
      NS_ENDHANDLER
      
      if (singleInstance)
	{
	  RETAIN(singleInstance);
	}
      else
	{
	  singleInstance = [[FilterManager alloc] init];
	  [singleInstance synchronize];
	}
    }
  
  return singleInstance;
}

@end


//
// private methods
//
@implementation FilterManager (Private)

//
// This method returns a message with a retain count of 1 to not overload
// the main autorelease pool.
//
- (CWMessage *) _newMessageFromExternalProgramUsingFilter: (Filter *) theFilter
					       message: (CWMessage *) theMessage
{
  NSFileHandle *aFileHandle, *theInputFileHandle;
  NSTask *aTask;
  NSPipe *aPipe;
  
  NSMutableData *aMutableData;
  NSData *theRawSource;
  CWMessage *aMessage;

  NSString *aString, *aFilename;
  NSRange aRange;
    
  // We first write the raw source to a temporary file
  theRawSource = [theMessage rawSource];
  
  if (!theRawSource)
    {
      NSDebugLog(@"Unable to obtain the raw source from ...");
      return nil;
    }

  NSDebugLog(@"Using external program for processing mail.");

  aFilename = [NSString stringWithFormat:@"%@/%d_%@", GNUMailTemporaryDirectory(), 
			[[NSProcessInfo processInfo] processIdentifier],
			NSUserName()];

  if (![theRawSource writeToFile: aFilename
		     atomically: YES])
    {
      ADD_CONSOLE_MESSAGE(_(@"Unable to write the raw source of the message to %@. Aborting."), aFilename);
      return nil;
    }
  
  [[NSFileManager defaultManager] enforceMode: 0600  atPath: aFilename];
  theInputFileHandle = [NSFileHandle fileHandleForReadingAtPath: aFilename];
  
  aPipe = [NSPipe pipe];
  aFileHandle = [aPipe fileHandleForReading];
  
  aTask = [[NSTask alloc] init];
  [aTask setStandardOutput: aPipe];
  [aTask setStandardInput: theInputFileHandle];
  
  // We build our right string
  aString = [[theFilter externalProgramName] stringByTrimmingWhiteSpaces];
    
  // We verify if our program to lauch has any arguments
  aRange = [aString rangeOfString: @" "];

  if (aRange.length)
    {
      [aTask setLaunchPath: [aString substringToIndex: aRange.location]];      
      [aTask setArguments: [[aString substringFromIndex: (aRange.location + 1)] 
			     componentsSeparatedByString: @" "]];
    }
  else
    {
      [aTask setLaunchPath: aString];
    }
  
  // We launch our task
  [aTask launch];
  
  aMutableData = (NSMutableData *)[NSMutableData data];
  
  while ([aTask isRunning])
    {
      [aMutableData appendData: [aFileHandle availableData]];
    }
  
  NSDebugLog(@"The external program terminated with the %d exit code.", [aTask terminationStatus]);

  if ([aTask terminationStatus] != 0)
    {
      return nil;
   }

  aMessage = [[CWMessage alloc] initWithData: aMutableData];
  
  RELEASE(aTask);
  [theInputFileHandle closeFile];

  [[NSFileManager defaultManager] removeFileAtPath: aFilename
				  handler: nil];
  
  NSDebugLog(@"Done using external program.");
  
  return aMessage;
}


//
//
//
- (BOOL) _matchCriteriasFromMessage: (CWMessage *) theMessage
			     filter: (Filter *) theFilter
{
  FilterCriteria *aFilterCriteria;
  BOOL aBOOL;
  
  //
  // First criteria
  //
  aFilterCriteria = [[theFilter allCriterias] objectAtIndex: 0];
  aBOOL = [self _matchStrings: [self _stringsFromMessage: theMessage  criteria: aFilterCriteria]
		operation: [aFilterCriteria criteriaFindOperation]
		criteria: [aFilterCriteria criteriaString]];
  
  //
  // Second criteria
  //
  aFilterCriteria = [[theFilter allCriterias] objectAtIndex: 1];
  
  if ([aFilterCriteria criteriaSource] != NONE)
    {
      if ([aFilterCriteria criteriaCondition] == AND)
	{
	  aBOOL = aBOOL && [self _matchStrings: [self _stringsFromMessage: theMessage  criteria: aFilterCriteria]
				 operation: [aFilterCriteria criteriaFindOperation]
				 criteria: [aFilterCriteria criteriaString]];
	}
      else
	{
	  aBOOL = aBOOL || [self _matchStrings: [self _stringsFromMessage: theMessage  criteria: aFilterCriteria]
				 operation: [aFilterCriteria criteriaFindOperation]
				 criteria: [aFilterCriteria criteriaString]];
	}
    }

  //
  // Third and last criteria
  //
  aFilterCriteria = [[theFilter allCriterias] objectAtIndex: 2];
  
  if ([aFilterCriteria criteriaSource] != NONE)
    {
      if ([aFilterCriteria criteriaCondition] == AND)
	{
	  aBOOL = aBOOL && [self _matchStrings: [self _stringsFromMessage: theMessage  criteria: aFilterCriteria]
				 operation: [aFilterCriteria criteriaFindOperation]
				 criteria: [aFilterCriteria criteriaString]];
	}
      else
	{
	  aBOOL = aBOOL || [self _matchStrings: [self _stringsFromMessage: theMessage  criteria: aFilterCriteria]
				 operation: [aFilterCriteria criteriaFindOperation]
				 criteria: [aFilterCriteria criteriaString]];
	}
    }

  return aBOOL;
}


//
//
//
- (BOOL) _matchStrings: (NSArray *) theStrings
	     operation: (int) theOperation
	      criteria: (NSString *) theCriteria
{
  // Variables used in this method
  NSArray *anArray;
  NSRange aRange;
  NSUInteger i, c, len;

  // We must be sure to have a valid criteria.
  if (theOperation != IS_IN_ADDRESS_BOOK &&
      theOperation != IS_IN_ADDRESS_BOOK_GROUP &&
      (!theCriteria || [theCriteria length] == 0))
    {
      return NO;
    }
  
  c = [theStrings count];

  for (i = 0; i < c; i++)
    {
      NSString *theString;

      theString = [theStrings objectAtIndex: i];
      len = [theString length];
      
      if (len == 0)
	{
	  continue;
	}

      switch (theOperation)
	{
	case CONTAINS:
	  aRange = [theString rangeOfString: theCriteria
			      options: NSCaseInsensitiveSearch];
	  
	  if (aRange.length)
	    {
	      return YES;
	    }
	  break;
	  
	case IS_EQUAL:
	  if ([theString caseInsensitiveCompare: theCriteria] == NSOrderedSame)
	    {
	      return YES;
	    }
	  break;
	  
	case HAS_PREFIX:
	  if ([[theString lowercaseString] hasPrefix: [theCriteria lowercaseString]])
	    {
	      return YES;
	    }
	  break;
	  
	case HAS_SUFFIX:
	  //
	  // We trim the trailing > in case there is one since an user could 
	  // define a filter to match ".edu" but we receive "<foo@bar.edu>".
	  //
	  if ([theString characterAtIndex: (len-1)] == '>')
	    {
	      theString = [theString substringToIndex: (len-1)];
	    }
	  if ([[theString lowercaseString] hasSuffix: [theCriteria lowercaseString]])
	    {
	      return YES;
	    }
	  break;
	  
	case MATCH_REGEXP:
	  anArray = [CWRegEx matchString: theString
			     withPattern : theCriteria
			     isCaseSensitive: YES];
	  
	  if ([anArray count] > 0)
	    {
	      return YES;
	    }
	  break;
	  
	case IS_IN_ADDRESS_BOOK:
	  anArray = [[AddressBookController singleInstance] addressesWithSubstring: theString];
	  
	  if ([anArray count] > 0)
	    {
	      return YES;
	    }
	  break;

	case IS_IN_ADDRESS_BOOK_GROUP:
	  anArray = [[AddressBookController singleInstance]
		      addressesWithSubstring: theString
		      inGroupWithId: theCriteria];
	  if ([anArray count] > 0)
	    {
	      return YES;
	    }
	  break;
	  
	default:
	  break;
	}
    } // for (...)

  return NO;
}


//
//
//
- (NSArray *) _stringsFromMessage: (CWMessage *) theMessage
			 criteria: (FilterCriteria *) theFilterCriteria
{
  NSMutableArray *aMutableArray;
  NSArray *allRecipients;
  NSString *aString;
  NSUInteger i;
  int theSource;

  aMutableArray = [[NSMutableArray alloc] init];

  theSource = [theFilterCriteria criteriaSource];
  
  switch (theSource)
    {
    case TO:
      allRecipients = [theMessage recipients];
      
      for (i = 0; i < [allRecipients count]; i++)
	{
	  CWInternetAddress *anInternetAddress;
	  
	  anInternetAddress = [allRecipients objectAtIndex: i];
	  
	  if ([anInternetAddress type] == TO)
	    {
	      aString = [anInternetAddress stringValue];
	      
	      if (aString)
		{
		  [aMutableArray addObject: aString];
		}
	    }
	  
	}
      break;
      
    case CC:
      allRecipients = [theMessage recipients];
      
      for (i = 0; i < [allRecipients count]; i++)
	{
	  CWInternetAddress *anInternetAddress;
	  
	  anInternetAddress = [allRecipients objectAtIndex: i];
	  
	  if ([anInternetAddress type] == CC)
	    {
	      aString = [anInternetAddress stringValue];
	      
	      if (aString)
		{
		  [aMutableArray addObject: aString];
		}
	    }
	  
	}
      break;
      
    case TO_OR_CC:
      allRecipients = [theMessage recipients];
      
      for (i = 0; i < [allRecipients count]; i++)
	{
	  CWInternetAddress *anInternetAddress;
	  
	  anInternetAddress = [allRecipients objectAtIndex: i];
	  
	  if ([anInternetAddress type] == TO ||
	      [anInternetAddress type] == CC)
	    {
	      aString = [anInternetAddress stringValue];
	      
	      if (aString)
		{
		  [aMutableArray addObject: aString];
		}
	    }
	  
	}
      break;
      
    case SUBJECT:
      aString = [theMessage subject];
      
      if (aString)
	{
	  [aMutableArray addObject: aString];
	}
      break;
      
    case FROM:
      aString = [[theMessage from] stringValue];
      
      if (aString)
	{
	  [aMutableArray addObject: aString];
	}
      break;
      
    case EXPERT:
      if ([theFilterCriteria criteriaHeaders] && 
	  [[theFilterCriteria criteriaHeaders] count] > 0)
	{
	  for (i = 0; i < [[theFilterCriteria criteriaHeaders] count]; i++)
	    {
	      aString = [theMessage headerValueForName: [[theFilterCriteria criteriaHeaders] objectAtIndex: i]];
	      
	      if ( aString )
		{
		  [aMutableArray addObject: aString];
		}
	    }
	}
      else
	{
	  // We do nothing.. so we won't have any matches.
	}
      
      break;
      
      // No criteria source, we just ignore it.
    case NONE:
    default:
      break;
    }

  return AUTORELEASE(aMutableArray);
}

@end
