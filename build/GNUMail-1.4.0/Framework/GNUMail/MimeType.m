/*
**  MimeType.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#import "MimeType.h"

#import "Constants.h"

static int currentMimeTypeVersion = 1;

@implementation MimeType

- (id) init
{
  self = [super init];
  if (self != nil)
    {
      [MimeType setVersion: currentMimeTypeVersion];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(mimeType);
  RELEASE(fileExtensions);
  RELEASE(description);
  RELEASE(dataHandlerCommand);
  RELEASE(icon);
  
  [super dealloc];
}


//
//
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [MimeType setVersion: currentMimeTypeVersion];
  
  [theCoder encodeObject: [self mimeType] ];
  [theCoder encodeObject: [self stringValueOfFileExtensions] ];
  [theCoder encodeObject: [self description] ];
  [theCoder encodeObject: [NSNumber numberWithInt: [self view]] ];
  [theCoder encodeObject: [NSNumber numberWithInt: [self action]] ];
  [theCoder encodeObject: [self dataHandlerCommand] ];
  [theCoder encodeObject: [self icon] ];
}


//
//
//
- (id) initWithCoder: (NSCoder *) theCoder
{
  int version, value;

  self = [super init];
  
  version = [theCoder versionForClassName: NSStringFromClass([self class])];
  
  NSDebugLog(@"MimeType's Version number = %d", version);

  [self setMimeType: [theCoder decodeObject] ];
  [self setFileExtensions: [theCoder decodeObject] ];
  [self setDescription: [theCoder decodeObject] ];
  [self setView: [[theCoder decodeObject] intValue] ];
  
  value = [[theCoder decodeObject] intValue];
  if ( version == 0 && value == 1 )
    {
      value = 2;
    }
  [self setAction: value];

  [self setDataHandlerCommand: [theCoder decodeObject] ];
  
  // Read and discard the 'Needs terminal' value.
  if ( version == 0 )
    {
      [theCoder decodeObject];
    }
  
  [self setIcon: [theCoder decodeObject] ];

  return self;
}


//
// access/mutation methods
//
- (NSString *) mimeType
{
  return mimeType;
}

- (void) setMimeType: (NSString *) theMimeType
{
  RETAIN(theMimeType);
  RELEASE(mimeType);
  mimeType = theMimeType;
}


//
//
//
- (NSString *) primaryType
{
  NSRange aRange;

  aRange = [mimeType rangeOfString: @"/"];
  
  return [mimeType substringToIndex: aRange.location];
}

- (void) setPrimaryType: (NSString *) thePrimaryType
{

}


//
//
//
- (NSString *) subType
{
  NSRange aRange;
  
  aRange = [mimeType rangeOfString: @"/"];
  
  return [mimeType substringFromIndex: (aRange.location+1)];
}

- (void) setSubType: (NSString *) theSubType
{
  
}


//
//
//
- (NSEnumerator *) fileExtensions
{
  return [[fileExtensions componentsSeparatedByString: @","] objectEnumerator];
}


//
//
//
- (NSString *) stringValueOfFileExtensions
{
  return fileExtensions;
}


//
//
//
- (void) setFileExtensions: (NSString *) theFileExtensions
{
  RETAIN(theFileExtensions);
  RELEASE(fileExtensions);
  fileExtensions = theFileExtensions;
}

- (int) view
{
  return view;
}

- (void) setView: (int) theView
{
  view = theView;
}

- (int) action
{
  return action;
}

- (void) setAction: (int) theAction
{
  action = theAction;
}

- (NSString *) dataHandlerCommand
{
  return dataHandlerCommand;
}

- (void) setDataHandlerCommand: (NSString *) theDataHandlerCommand
{
  RETAIN(theDataHandlerCommand);
  RELEASE(dataHandlerCommand);
  dataHandlerCommand = theDataHandlerCommand;
}

- (NSImage *) icon
{
  return icon;
}

- (void) setIcon: (NSImage *) theIcon
{
  RETAIN(theIcon);
  RELEASE(icon);
  icon = theIcon;
}

- (NSString *) description
{
  return description;
}

- (void) setDescription: (NSString *) theDescription
{
  RETAIN(theDescription);
  RELEASE(description);
  description = theDescription;
}

@end
