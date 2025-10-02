/*
**  MimeTypeManager.h
**
**  Copyright (c) 2001, 2002 Ludovic Marcotte
**                2020       Riccardo Mottola
**
**  Authors: Ludovic Marcotte <ludovic@Sophos.ca>
**           Riccardo Mottola
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

#ifndef _GNUMail_H_MimeTypeManager
#define _GNUMail_H_MimeTypeManager

#import <AppKit/AppKit.h>

@class MimeType;
@class NSTableView;
@class NSTableColumn;

NSString *PathToMimeTypes();

@interface MimeTypeManager: NSObject <NSCoding>
{
  NSMutableDictionary *standardMimeTypes;
  NSMutableArray *mimeTypes;
}

- (id) init;
- (void) dealloc;

- (BOOL) synchronize;

//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder;
- (id) initWithCoder: (NSCoder *) theCoder;


//
// access/mutation methods
//
- (MimeType *) mimeTypeAtIndex: (int) theIndex;
- (void) addMimeType: (MimeType *) theMimeType;
- (void) removeMimeType: (MimeType *) theMimeType;

- (NSArray *) mimeTypes;
- (void) setMimeTypes: (NSArray *) theMimeTypes;

- (MimeType *) bestMimeTypeForFileExtension: (NSString *) theFileExtension;
- (MimeType *) mimeTypeForFileExtension: (NSString *) theFileExtension;

- (MimeType *) mimeTypeFromString: (NSString *) theString;

- (NSImage *) bestIconForMimeType: (MimeType *) theMimeType
                    pathExtension: (NSString *) thePathExtension;


//
// class methods
//
+ (MimeTypeManager *) singleInstance;

@end


//
// Private methods
//
@interface MimeTypeManager (Private)

- (void) _loadStandardMimeTypes;

@end

#endif // _GNUMail_H_MimeTypeManager
