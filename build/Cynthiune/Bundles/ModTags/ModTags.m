/* ModTags.m - this file is part of Cynthiune
 *
 * Copyright (C) 2021 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <Wolfgang@Contre.COM>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>

#import "modplug.h"

#import <Cynthiune/utils.h>

#import "ModTags.h"

#define LOCALIZED(X) _b ([ModTags class], X)


@implementation ModTags : NSObject

+ (NSString *) bundleDescription
{
  return @"A bundle to read/set the tags of .mod and similar files";
}

+ (NSArray *) bundleCopyrightStrings
{
  return [NSArray arrayWithObjects:
                    @"Copyright (C) 2021  Wolfgang Sourdeau",
                  nil];
}

+ (BOOL) readTitle: (NSString **) title
            artist: (NSString **) artist
             album: (NSString **) album
       trackNumber: (NSString **) trackNumber
             genre: (NSString **) genre
              year: (NSString **) year
        ofFilename: (NSString *) fileName
{
  ModPlugFile *mpFile;
  NSFileHandle *fileHandle;
  NSData *content;
  BOOL result;

  result = NO;
  fileHandle = [NSFileHandle fileHandleForReadingAtPath: fileName];

  if (fileHandle)
    {
      content = [fileHandle readDataToEndOfFile];
      mpFile = ModPlug_Load ([content bytes], [content length]);
      if (mpFile)
        {
          SET (*title, [NSString stringWithCString: ModPlug_GetName (mpFile)
                                          encoding: NSISOLatin1StringEncoding]);
          result = YES;
          ModPlug_Unload (mpFile);
        }
      else
        NSLog (@"Mod: could not load '%@'", fileName);
      [fileHandle closeFile];
    }

  return result;
}

@end
