/*
**  ExtendedFileWrapper.h
**
**  Copyright (c) 2004 Ludovic Marcotte
**  Copyright (C) 2019 Riccardo Mottola
**
**  Ludovic Marcotte <ludovic@Sophos.ca>
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

#include "ExtendedFileWrapper.h"

#include "Constants.h"
#include "Utilities.h"

#include <Foundation/NSFileManager.h>
#include <Foundation/NSProcessInfo.h>

//
//
//
@interface ExtendedFileWrapper (Private)

- (id) _initWithPath: (NSString *) thePath
	   pathToTar: (NSString *) thePathToTar;
- (id) _initWithPath: (NSString *) thePath
	   pathToZip: (NSString *) thePathToZip;

@end


//
//
//
@implementation ExtendedFileWrapper

- (id) initWithPath: (NSString *) thePath
{
  NSFileManager *aFileManager;

  BOOL aBOOL;

  aFileManager = [NSFileManager defaultManager];

  if ( [aFileManager fileExistsAtPath: thePath  isDirectory: &aBOOL] )
    {
      if ( aBOOL )
	{
	  NSString *aString, *pathToTar, *pathToZip;
	  NSArray *components;  
	  NSUInteger i;

	  
	  aString = [[[NSProcessInfo processInfo] environment] objectForKey: @"PATH"];  
	  components = [aString componentsSeparatedByString: @":"];
	  pathToTar = nil;
	  pathToZip = nil;

	  for (i = 0; i < [components count]; i++)
	    {
	      if ( [aFileManager isExecutableFileAtPath: [NSString stringWithFormat: @"%@/zip", [components objectAtIndex: i]]] )
		{
		  pathToZip = [NSString stringWithFormat: @"%@/zip", [components objectAtIndex: i]];
		  break;
		}
	      else if ( [aFileManager isExecutableFileAtPath: [NSString stringWithFormat: @"%@/tar", [components objectAtIndex: i]]] )
		{
		  pathToTar = [NSString stringWithFormat: @"%@/tar", [components objectAtIndex: i]];
		}
	    }

	  if ( pathToZip )
	    {
	      return [self _initWithPath: thePath  pathToZip: pathToZip];
	    }
	  else if ( pathToTar )
	    {
	      return [self _initWithPath: thePath  pathToTar: pathToTar];
	    }
	}
      else
	{
	  return [super initWithPath: thePath];
	}
    }
  
  // If the file doesn't exist or if the path to tar/zip
  // are both nil, we fall back here.
  AUTORELEASE(self);
  return nil;
}

@end

@implementation ExtendedFileWrapper (Private)

- (id) _initWithPath: (NSString *) thePath
	   pathToTar: (NSString *) thePathToTar
{
  NSTask *aTask;

  aTask = [NSTask launchedTaskWithLaunchPath: thePathToTar
		  arguments: [NSArray arrayWithObjects:
					@"-cf", 
				      [NSString stringWithFormat: @"%@/%@.tar", GNUMailTemporaryDirectory(), [thePath lastPathComponent]],
				      thePath,
				      nil]];
  
  [aTask waitUntilExit];

  return [super initWithPath: [NSString stringWithFormat: @"%@/%@.tar", GNUMailTemporaryDirectory(), [thePath lastPathComponent]]];
}


- (id) _initWithPath: (NSString *) thePath
	   pathToZip: (NSString *) thePathToZip
{
  NSTask *aTask;

  aTask = [NSTask launchedTaskWithLaunchPath: thePathToZip
		  arguments: [NSArray arrayWithObjects:
					@"-q", 
				      [NSString stringWithFormat: @"%@/%@.zip", GNUMailTemporaryDirectory(), [thePath lastPathComponent]],
				      @"-r",
				      thePath,
				      nil]];

  [aTask waitUntilExit];

  return [super initWithPath: [NSString stringWithFormat: @"%@/%@.zip", GNUMailTemporaryDirectory(), [thePath lastPathComponent]]];
}

@end
