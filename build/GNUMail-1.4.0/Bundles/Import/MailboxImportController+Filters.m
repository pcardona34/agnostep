/*
**  MailboxImportController+Filters.m
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#include "MailboxImportController+Filters.h"

#include "MailboxManagerController.h"

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWLocalStore.h>
#include <Pantomime/CWStore.h>

@implementation MailboxImportController (Filters)

//
// Rationale:
//
// When Entourage exports its mailboxes, it uses the CR delimiter
// instead of LF. This method replace all occurences of CR by LF.
//
- (void) importFromEntourage
{
  NSEnumerator *theEnumerator;
  NSMutableData *aMutableData;
  CWLocalStore *aStore;
  NSString *aString;
  NSNumber *aRow;

  unsigned char *bytes;
  int i,length;
  
  theEnumerator = [tableView selectedRowEnumerator];

  aStore = [[MailboxManagerController singleInstance] storeForName: @"GNUMAIL_LOCAL_STORE"
						      username: NSUserName()];
  
  while ((aRow = [theEnumerator nextObject]))
    {
      aString = [allMailboxes objectAtIndex: [aRow intValue]];
      
      aMutableData = [NSMutableData dataWithContentsOfFile: aString];
  
      bytes = [aMutableData mutableBytes];
      length = [aMutableData length];
      
      for (i = 0; i < length; i++)
	{
	  if (*bytes == '\r')
	    {
	      *bytes = '\n';
	    }
	  
	  bytes++;
	}
      
      [aStore createFolderWithName: [self uniqueMailboxNameFromName: [aString lastPathComponent]
					  store: (CWStore *)aStore
					  index: 1
					  proposedName: [aString lastPathComponent]]
	      type: PantomimeFormatMbox
	      contents: aMutableData];
    }      
  
#warning FIXME - Optimize
  [[MailboxManagerController singleInstance] reloadAllFolders];
}


//
// We do nothing special, just move the mbox to the local store
//
- (void) importFromMbox
{
  NSEnumerator *theEnumerator;
  CWLocalStore *aStore;
  NSString *aString;
  NSNumber *aRow;
  NSData *aData;
  
  theEnumerator = [tableView selectedRowEnumerator];

  aStore = [[MailboxManagerController singleInstance] storeForName: @"GNUMAIL_LOCAL_STORE"
						      username: NSUserName()];

  while ((aRow = [theEnumerator nextObject]))
    {
      aString = [allMailboxes objectAtIndex: [aRow intValue]];
      aData = [NSData dataWithContentsOfFile: aString];
      
      [aStore createFolderWithName: [self uniqueMailboxNameFromName: [aString lastPathComponent]
					  store: (CWStore *)aStore
					  index: 1
					  proposedName: [aString lastPathComponent]]
	      type: PantomimeFormatMbox
	      contents: aData];
    }

#warning FIXME - Optimize
  [[MailboxManagerController singleInstance] reloadAllFolders];
}


//
//
//
- (NSString *) uniqueMailboxNameFromName: (NSString *) theName
                                   store: (CWStore *) theStore
				   index: (int) theIndex
			    proposedName: (NSString *) theProposedName
{
  NSEnumerator *theEnumerator;
  NSString *aString;

  theEnumerator = [(id<CWStore>)theStore folderEnumerator];

  // We verify if the folder with that name does already exist
  while ((aString = [theEnumerator nextObject]))
    {
      if ([aString compare: theProposedName
		   options: NSCaseInsensitiveSearch] == NSOrderedSame)
	{
	  return [self uniqueMailboxNameFromName: theName
		       store: theStore
		       index: (theIndex+1)
		       proposedName: [NSString stringWithFormat: @"%@.%d", theName, theIndex]];
	}
    }

  if (theIndex == 1)
    {
      return theName;
    }
  
  return theProposedName;
}

@end
