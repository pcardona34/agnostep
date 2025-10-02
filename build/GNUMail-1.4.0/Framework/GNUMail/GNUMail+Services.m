/*
**  GNUMail+Services.m
**
**  Copyright (c) 2004-2007 Ludovic Marcotte
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

#include "GNUMail+Services.h"

#include "Constants.h"
#include "EditWindowController.h"
#include "MimeType.h"
#include "MimeTypeManager.h"

#include <Pantomime/CWMessage.h>
#include <Pantomime/CWMIMEMultipart.h>
#include <Pantomime/CWMIMEUtility.h>
#include <Pantomime/CWPart.h>

//
//
//
@implementation GNUMail (Services)

- (void) newMessageWithAttachments: (NSPasteboard *) pboard
			  userData: (NSString *) userData
                             error: (NSString **) error
{
  EditWindowController *editWindowController;
  NSAutoreleasePool *pool;

  CWMIMEMultipart *aMimeMultipart;
  CWPart *aPart;
  MimeType *aMimeType;
  CWMessage *aMessage;

  NSEnumerator *enumerator;
  NSFileManager *manager;

  NSString *aFile;
  NSArray *allFiles, *allTypes;
  BOOL isDir;

  pool = [[NSAutoreleasePool alloc] init];
  manager = [NSFileManager defaultManager];
  allTypes = [pboard types];
  aMimeMultipart = nil;
  aMessage = nil;
  
  if ( ![allTypes containsObject: NSFilenamesPboardType] )
    {
      *error = @"No filenames supplied on pasteboard";
      RELEASE(pool);
      return;
    }
  
  allFiles = [pboard propertyListForType: NSFilenamesPboardType];
  
  NSDebugLog(@"Attach %@", allFiles);
  
  if (allFiles == nil)
    {
      *error = @"No files supplied on pasteboard";
      RELEASE(pool);
      return;
    }
  
  // We create a new message with our pasteboard content
  aMessage = [[CWMessage alloc] init];

  aMimeMultipart = [[CWMIMEMultipart alloc] init];

  enumerator = [allFiles objectEnumerator];
  
  while ( (aFile = [enumerator nextObject]) )
    {
      if ( ![manager fileExistsAtPath: aFile  isDirectory: &isDir] )
        {
          NSDebugLog(@"File '%@' does not exists (not adding as attachment)", aFile);
          continue;
        }
      if ( isDir )
        {
          NSDebugLog(@"'%@' is a directory (not adding as attachment)", aFile);
          continue;
        }

      NSDebugLog(@"Adding '%@' as attachment", aFile);
      
      // We first decode our text/plain body
      aPart = [[CWPart alloc] init];
      
      aMimeType = [[MimeTypeManager singleInstance] bestMimeTypeForFileExtension:
						      [[aFile lastPathComponent] pathExtension]];
      
      if ( aMimeType )
	{
	  [aPart setContentType: [aMimeType mimeType]];
	}
      else
	{
	  [aPart setContentType: @"application/octet-stream"];
	}
      
      [aPart setContentTransferEncoding: PantomimeEncodingBase64];
      [aPart setContentDisposition: PantomimeAttachmentDisposition];
      [aPart setFilename: [aFile lastPathComponent]];
      
      [aPart setContent: [NSData dataWithContentsOfFile: aFile]];
      [aMimeMultipart addPart: aPart];
      RELEASE(aPart);
    }
  
  [aMessage setContentTransferEncoding: PantomimeEncodingNone];
  [aMessage setContentType: @"multipart/mixed"];     
  [aMessage setContent: aMimeMultipart];
  
  // We generate a new boundary for our message
  [aMessage setBoundary: [CWMIMEUtility globallyUniqueBoundary]];
  
  RELEASE(aMimeMultipart);
  
  // We create our controller and we show the window
  editWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];

  if (editWindowController)
    {
      [[editWindowController window] setTitle: _(@"New message...")];
      [editWindowController setMessage: aMessage];
      [editWindowController setShowCc: NO];
      [editWindowController setAccountName: nil];
      
      [[editWindowController window] orderFrontRegardless];
    }
  
  RELEASE(aMessage);
  RELEASE(pool);
}


//
//
//
- (void) newMessageWithContent: (NSPasteboard *) pboard
	              userData: (NSString *) userData
                         error: (NSString **) error
{
  EditWindowController *editWindowController;
  NSString *aString;
  NSArray *allTypes;
  CWMessage *aMessage;

  allTypes = [pboard types];

  if ( ![allTypes containsObject: NSStringPboardType] )
    {
      *error = @"No string type supplied on pasteboard";
      return;
    }
  
  aString = [pboard stringForType: NSStringPboardType];
  
  if (aString == nil)
    {
      *error = @"No string value supplied on pasteboard";
      return;
    }
  
  // We create a new message with our pasteboard content
  aMessage = [[CWMessage alloc] init];
  [aMessage setCharset: @"utf-8"];
  [aMessage setContent: [aString dataUsingEncoding: NSUTF8StringEncoding]];

  // We create our controller and we show the window
  editWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];

  if ( editWindowController )
    {
      [[editWindowController window] setTitle: _(@"New message...")];
      [editWindowController setMessage: aMessage];
      [editWindowController setShowCc: NO];
      [editWindowController setAccountName: nil];
    
      [[editWindowController window] orderFrontRegardless];
    }
  
  RELEASE(aMessage);
}


//
//
//
- (void) newMessageWithRecipient: (NSPasteboard *) pboard
	                userData: (NSString *) userData
                           error: (NSString **) error
{
  NSString *aString;
  NSArray *allTypes;

  allTypes = [pboard types];

  if (![allTypes containsObject: NSStringPboardType])
    {
      *error = @"No string type supplied on pasteboard";
      return;
    }
  
  aString = [pboard stringForType: NSStringPboardType];
  
  if (aString == nil)
    {
      *error = @"No string value supplied on pasteboard";
      return;
    }

  [self newMessageWithRecipient: aString];
  
}

@end






