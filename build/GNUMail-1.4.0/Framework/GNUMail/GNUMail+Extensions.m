/*
**  GNUMail+Extensions.m
**
**  Copyright (c) 2002-2004 Ludovic Marcotte
**  Copyright (C) 2019-2020 Riccardo Mottola
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
*/

#import "Filter.h"
#import "FilterManager.h"
#import "Constants.h"
#import "GNUMail+Extensions.h"
#import "Utilities.h"

#import <Foundation/NSFileManager.h>

#import <Pantomime/CWURLName.h>

@implementation GNUMail (Extensions)

#define UPDATE_PATH(name) ({ \
 aFolderName = [self updatePathForFolderName: [allValues objectForKey: name] \
			      current: theDestinationPath \
			      previous: theSourcePath]; \
 if (aFolderName) \
   { \
     [allValues setObject: aFolderName  forKey: name]; \
   } \
})


//
//
//
- (void) taskDidTerminate: (NSNotification *) theNotification
{
  // We first unregister ourself for the notification
  [[NSNotificationCenter defaultCenter] removeObserver: self
					name: NSTaskDidTerminateNotification
					object: [theNotification object]];

  // Remove the temporary file.
  [[NSFileManager defaultManager] removeFileAtPath: [[[theNotification object] arguments] lastObject]
				  handler: nil];
  // We release our task...
  AUTORELEASE([theNotification object]);	  
}

//
//
//
- (void) moveLocalMailDirectoryFromPath: (NSString *) theSourcePath
                                 toPath: (NSString *) theDestinationPath
{
  NSArray *foldersToOpen, *theFilters;
  FilterManager *aFilterManager;
  NSFileManager *aFileManager;
  NSAutoreleasePool *pool;
  NSString *aFolderName;

  BOOL aBOOL, isDir;
  
  pool = [[NSAutoreleasePool alloc] init];
  aFileManager = [NSFileManager defaultManager];

  if ([aFileManager fileExistsAtPath: theDestinationPath  isDirectory: &isDir])
    {
      //
      // The "directory" already exists but it is a file, not a directory.
      //
      if (!isDir)
	{ 
	  NSRunCriticalAlertPanel(_(@"Fatal error!"),
				  _(@"%@ exists but it is a file, not a directory.\nThe application will now terminate.\nRemove this file before trying again to start GNUMail."),
				  @"OK",
				  NULL,
				  NULL,
				  theDestinationPath);
	  exit(1);
	}
      //
      // The directory exists, let's move the files there.
      //
      else
	{
	  NSDirectoryEnumerator *aDirectoryEnumerator;
	  NSString *aFile;

	  NSDebugLog(@"The directory exists - we move the files.");

	  aDirectoryEnumerator = [aFileManager enumeratorAtPath: theSourcePath];
	  
	  while ((aFile = [aDirectoryEnumerator nextObject]))
	    {
	      if (![aFileManager movePath: [NSString stringWithFormat: @"%@/%@", theSourcePath, aFile]
				 toPath: [NSString stringWithFormat: @"%@/%@", theDestinationPath, aFile]
				 handler: nil])
		{
		  NSRunCriticalAlertPanel(_(@"Fatal error!"),
					  _(@"An error occurred while moving mailboxes to %@. Please move back manually\nthe files and directories to %@."),
					  @"OK",
					  NULL,
					  NULL,
					  theDestinationPath,
					  theSourcePath);
		  exit(1);
		}
	    }

	  // We remove the old directory.
	  [aFileManager removeFileAtPath: theSourcePath  handler: nil];
	}
    }
  //
  // The new target directory doesn't yet exist. We can safely move our current directory
  // to the new one.
  //
  else
    {
      NSDebugLog(@"The directory doesn't exist - we move the directory.");

      aBOOL = [aFileManager movePath: theSourcePath
			    toPath: theDestinationPath
			    handler: nil];
      if (!aBOOL)
	{
	  NSRunCriticalAlertPanel(_(@"Fatal error!"),
				  _(@"A fatal error occurred when moving the directory %@ to %@.\nThe application will now terminate."),
				  @"OK",
				  NULL,
				  NULL,
				  theSourcePath,
				  theDestinationPath);
	  exit(1);
	}
    }
  
  
  //
  // FOLDERS_TO_OPEN
  //
  foldersToOpen = [[NSUserDefaults standardUserDefaults] arrayForKey: @"FOLDERS_TO_OPEN"];
  
  if ( foldersToOpen && [foldersToOpen count] > 0)
    {
      NSMutableArray *aMutableArray;
      NSUInteger i;
      
      aMutableArray = [NSMutableArray array];
      
      for (i = 0; i < [foldersToOpen count]; i++)
	{
	  aFolderName = [self updatePathForFolderName: [foldersToOpen objectAtIndex: i]
			      current: theDestinationPath
			      previous: theSourcePath];
	  
	  if ( aFolderName )
	    {
	      [aMutableArray addObject: aFolderName];
	    }
	  else
	    {
	      [aMutableArray addObject: [foldersToOpen objectAtIndex: i]];
	    }
	}
      
      [[NSUserDefaults standardUserDefaults] setObject: aMutableArray  forKey: @"FOLDERS_TO_OPEN"];
    }
  
  
  //
  // Filters -> actionFolderName
  //
  aFilterManager = [FilterManager singleInstance];
  theFilters = [aFilterManager filters];
  
  if ( [theFilters count] > 0 )
    {
      Filter *aFilter;
      NSUInteger i;

      for (i = 0; i < [theFilters count]; i++)
	{
	  aFilter = [theFilters objectAtIndex: i];
	  
	  aFolderName = [self updatePathForFolderName: [aFilter actionFolderName]
			      current: theDestinationPath
			      previous: theSourcePath];
	  
	  if ( aFolderName )
	    {
	      [aFilter setActionFolderName: aFolderName];
	    }
	}
      
      [aFilterManager synchronize];
    }
  
	  
  //
  // ACCOUNTS -> [all accounts] -> RECEIVE -> DRAFTSFOLDERNAME, INBOXFOLDERNAME, SENTFOLDERNAME, TRASHFOLDERNAME
  //
  if ( [[NSUserDefaults standardUserDefaults] objectForKey: @"ACCOUNTS"] )
    {
      NSMutableDictionary *allAccounts, *theAccount, *allValues;
      NSEnumerator *theEnumerator;
      NSString *aKey;
      
      allAccounts = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] 
								       dictionaryForKey: @"ACCOUNTS"]];
      
      theEnumerator = [allAccounts keyEnumerator];

      while ( (aKey = [theEnumerator nextObject]) )
	{
	  theAccount = [[NSMutableDictionary alloc] initWithDictionary: [allAccounts objectForKey: aKey]];
	  allValues = [[NSMutableDictionary alloc] initWithDictionary: [theAccount objectForKey: @"MAILBOXES"]];

	  UPDATE_PATH(@"DRAFTSFOLDERNAME");
	  UPDATE_PATH(@"INBOXFOLDERNAME");
	  UPDATE_PATH(@"SENTFOLDERNAME");
	  UPDATE_PATH(@"TRASHFOLDERNAME");

	  [theAccount setObject: allValues  forKey: @"MAILBOXES"];
	  RELEASE(allValues);

	  [allAccounts setObject: theAccount  forKey: aKey];
	  RELEASE(theAccount);
	}
      
      [[NSUserDefaults standardUserDefaults] setObject: allAccounts  forKey: @"ACCOUNTS"];
      RELEASE(allAccounts);
    }
  
  
  // We set the path of our previous default's value and we synchronize our defaults.
  [[NSUserDefaults standardUserDefaults] setObject: theDestinationPath  forKey: @"LOCALMAILDIR_PREVIOUS"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  RELEASE(pool);
}


//
//
//
- (void) removeTemporaryFiles
{
  NSDirectoryEnumerator *theEnumerator;
  NSString *aPath;

  theEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: GNUMailTemporaryDirectory()];

  while ((aPath = [theEnumerator nextObject]))
    {
      [[NSFileManager defaultManager] removeFileAtPath: [NSString stringWithFormat: @"%@/%@", GNUMailTemporaryDirectory(), aPath] 
				      handler: nil];
    }
}

//
// From 1.1.2 -> 1.2.0
//
- (void) update_112_to_120
{
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"MAIL_WINDOW_TABLE_COLUMN_SIZES"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"TEXTSCROLLVIEW_HEIGHT"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"MAILWINDOW_REPEAT_SUBJECT"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"AUTOMATICALLY_EXPAND_THREADS"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"EnableContextMenus"];

#ifdef GNUSTEP
  if (![[NSUserDefaults standardUserDefaults] objectForKey: @"PreferredViewStyle"])
    {
      [[NSUserDefaults standardUserDefaults] setInteger: GNUMailFloatingView  forKey: @"PreferredViewStyle"];
    }
#endif
}

//
//
//
- (NSString *) updatePathForFolderName: (NSString *) theFolderName
			       current: (NSString *) theCurrentPath
			      previous: (NSString *) thePreviousPath
{
  CWURLName *aURLName;

  if (!theFolderName || 
      ![theFolderName hasPrefix: [NSString stringWithFormat: @"local://%@", thePreviousPath]] )
    {
      return nil;
    }
  
  aURLName = [[CWURLName alloc] initWithString: theFolderName  path: thePreviousPath];
  AUTORELEASE(aURLName);

  return [NSString stringWithFormat: @"local://%@/%@", theCurrentPath, [aURLName foldername]];
}

@end

#undef UPDATE_PATH



