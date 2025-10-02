/*
**  MimeTypeManager.m
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
**                2020      Riccardo Mottola
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

#include "MimeTypeManager.h"

#include "Constants.h"
#include "MimeType.h"
#include "Utilities.h"

#include <Pantomime/NSString+Extensions.h>

static MimeTypeManager *singleInstance = nil;

NSString *PathToMimeTypes()
{
  return [NSString stringWithFormat: @"%@/%@",
		   GNUMailUserLibraryPath(), @"Mime-Types"];
}


//
//
//
@implementation MimeTypeManager

- (id) init
{
  self = [super init];
  if (self != nil)
    {
      [self setMimeTypes: [NSArray array]];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  NSDebugLog(@"MimeTypeManager: -dealloc");

  TEST_RELEASE(standardMimeTypes);
  RELEASE(mimeTypes);

  [super dealloc];
}


//
//
//
- (BOOL) synchronize
{
  return [NSArchiver archiveRootObject: self 
		     toFile: PathToMimeTypes()];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [theCoder encodeObject: [self mimeTypes]];
}


//
//
//
- (id) initWithCoder: (NSCoder *) theCoder
{
  self = [super init];
  if (self != nil)
    {
      [self setMimeTypes: [theCoder decodeObject]];
    }
  return self;
}


//
// access/mutation methods
//
- (MimeType *) mimeTypeAtIndex: (int) theIndex
{
  return [mimeTypes objectAtIndex: theIndex];
}


//
//
//
- (void) addMimeType: (MimeType *) theMimeType
{
  [mimeTypes addObject: theMimeType];
}


//
//
//
- (void) removeMimeType: (MimeType *) theMimeType;
{
  [mimeTypes removeObject: theMimeType];
}


//
//
//
- (NSArray *) mimeTypes
{
  return mimeTypes;
}


//
//
//
- (void) setMimeTypes: (NSArray *) theMimeTypes
{
  if ( theMimeTypes )
    {
      NSMutableArray *newMimeTypes;

      newMimeTypes = [[NSMutableArray alloc] initWithArray: theMimeTypes];
      RELEASE(mimeTypes);
      mimeTypes = newMimeTypes;
    }
  else
    {
      RELEASE(mimeTypes);
      mimeTypes = nil;
    }
}


//
//
//
- (MimeType *) bestMimeTypeForFileExtension: (NSString *) theFileExtension
{
  MimeType *aMimeType;

  if (!theFileExtension || [[theFileExtension stringByTrimmingWhiteSpaces] length] == 0)
    {
      return nil;
    }

  if (!standardMimeTypes )
    {
      standardMimeTypes = [[NSMutableDictionary alloc] init];
    }

  if ([standardMimeTypes count] == 0)
    {
      [self _loadStandardMimeTypes];
    }
  
  // We first search from the MIME types specified by the user
  // If we haven't found it, we try to guess the best one we could use
  aMimeType = [self mimeTypeForFileExtension: theFileExtension];

  if (!aMimeType)
    {
      NSString *aString;

      aMimeType = [[MimeType alloc] init];
      
      aString = [standardMimeTypes objectForKey: [theFileExtension  lowercaseString]];

      if (aString)
	{
	  [aMimeType setMimeType: aString];
	}
      else
	{
	  [aMimeType setMimeType: @"application/octet-stream"];
	}
      
      return AUTORELEASE(aMimeType);
    }

  return aMimeType;
}


//
//
//
- (MimeType *) mimeTypeForFileExtension: (NSString *) theFileExtension
{
  NSEnumerator *anEnumerator;
  MimeType *aMimeType;
  NSString *aString;
  NSUInteger i;

  if (!theFileExtension || [[theFileExtension stringByTrimmingWhiteSpaces] length] == 0)
    {
      return nil;
    }
  
  if (theFileExtension && [theFileExtension length] > 0)
    {
      for (i = 0; i < [[self mimeTypes] count]; i++)
	{
	  aMimeType = [[self mimeTypes] objectAtIndex: i];
	  anEnumerator = [aMimeType fileExtensions];
	  
	  while ((aString = [anEnumerator nextObject]))
	    {
	      if ([[aString stringByTrimmingWhiteSpaces] caseInsensitiveCompare: theFileExtension] == NSOrderedSame)
		{
		  return aMimeType;
		}
	    }
	}
    }

  return nil;
}


//
//
//
- (MimeType *) mimeTypeFromString: (NSString *) theString
{
  MimeType *aMimeType;
  NSUInteger i;

  if (theString && [theString length] > 0)
    {
      for (i = 0; i < [[self mimeTypes] count]; i++) 
	{
	  aMimeType = [[self mimeTypes] objectAtIndex: i];

	  if ([[aMimeType mimeType] caseInsensitiveCompare: theString] == NSOrderedSame)
	    {
	      return aMimeType;
	    }
	}
    }

  return nil;
}


//
//
//
- (NSImage *) bestIconForMimeType: (MimeType *) theMimeType
                    pathExtension: (NSString *) thePathExtension
{
  NSImage *anImage;
  
  if ( theMimeType && [theMimeType icon] )
    {
      anImage = [theMimeType icon];
    }
  else
    {
      anImage = [[NSWorkspace sharedWorkspace] iconForFileType: thePathExtension];
    }

  return anImage;
}


//
// class methods
//
+ (MimeTypeManager *) singleInstance
{
  if ( singleInstance == nil )
    {
      NS_DURING
	singleInstance = [NSUnarchiver unarchiveObjectWithFile: PathToMimeTypes()];
      NS_HANDLER
	NSLog(@"Caught exception while unarchiving the Mime-Types. Ignoring.");
	singleInstance = nil;
      NS_ENDHANDLER

      if ( singleInstance )
	{
	  RETAIN(singleInstance);
	}
      else
	{
	  singleInstance = [[MimeTypeManager alloc] init];
	  [singleInstance synchronize];
	}
    }

  return singleInstance;
}

@end


//
// Private methods
//
@implementation MimeTypeManager (Private)

- (void) _loadStandardMimeTypes
{
  //
  // We first try to load a set of system-defined MIME types defined in /etc/mime.types.
  //
  if ( [[NSFileManager defaultManager] fileExistsAtPath: @"/etc/mime.types"] )
    {
      NSString *contentOfFile;
      
      contentOfFile = [NSString stringWithContentsOfFile: @"/etc/mime.types"];

      // We got a valid file.. let's process it!
      if ( contentOfFile )
	{
	  NSArray *allLines;
	  int i;

	  allLines = [contentOfFile componentsSeparatedByString: @"\n"];

	  for (i = 0; i < [allLines count]; i++) 
	    {
	      NSString *aMimeType, *aLine;
	      NSRange aRange;
	      
	      aLine = [allLines objectAtIndex: i];

	      if ([aLine hasPrefix: @"#"])
		{
		  continue;
		}

	      // We get the MIME type
	      aRange = [aLine rangeOfCharacterFromSet: [NSCharacterSet whitespaceCharacterSet]];
	      
	      // If some file extensions were specified, we process this type. Otherwise, we simply
	      // ignore it.
	      if (aRange.length)
		{
		  aMimeType = [aLine substringToIndex: aRange.location];
		  
		  // We get all file extensions.
		  aRange = [aLine rangeOfCharacterFromSet: [[NSCharacterSet whitespaceCharacterSet] invertedSet]
				  options: 0
			      range: NSMakeRange(aRange.location, [aLine length] - aRange.location)];
		  
		  if ( aRange.length )
		    {
		      NSArray *allElements;
		      int j;

		      allElements = [[aLine substringFromIndex: aRange.location] componentsSeparatedByString: @" "];
		      
		      // We add in our dictionary the <file extension> -> <MIME type association>
		      for (j = 0; j < [allElements count]; j++)
			{
			  [standardMimeTypes setObject: aMimeType
					     forKey: [[allElements objectAtIndex: j] lowercaseString]];
			}
		    }
		}
	    }
	}
    }

  //
  // We now set a list of default MIME types
  //
  [standardMimeTypes setObject: @"application/mspowerpoint"  forKey: @"ppt"];
  [standardMimeTypes setObject: @"application/msword"  forKey: @"doc"];
  [standardMimeTypes setObject: @"application/pdf"  forKey: @"pdf"];
  [standardMimeTypes setObject: @"application/postscript"  forKey: @"ai"];
  [standardMimeTypes setObject: @"application/postscript"  forKey: @"eps"];
  [standardMimeTypes setObject: @"application/postscript"  forKey: @"ps"];
  [standardMimeTypes setObject: @"application/x-csh"  forKey: @"csh"];
  [standardMimeTypes setObject: @"application/x-gzip"  forKey: @"gz"];
  [standardMimeTypes setObject: @"application/x-tar" forKey: @"tar"];
  [standardMimeTypes setObject: @"application/zip"  forKey: @"zip"];
   
  [standardMimeTypes setObject: @"audio/midi"  forKey: @"mid"];
  [standardMimeTypes setObject: @"audio/midi"  forKey: @"midi"];
  [standardMimeTypes setObject: @"audio/mpeg"  forKey: @"mp2"];
  [standardMimeTypes setObject: @"audio/mpeg"  forKey: @"mp3"];
  [standardMimeTypes setObject: @"audio/mpeg"  forKey: @"mpga"];
  [standardMimeTypes setObject: @"audio/x-wav"  forKey: @"wav"];

  [standardMimeTypes setObject: @"image/gif"  forKey: @"gif"];
  [standardMimeTypes setObject: @"image/jpeg"  forKey: @"jpe"];
  [standardMimeTypes setObject: @"image/jpeg"  forKey: @"jpeg"];
  [standardMimeTypes setObject: @"image/jpeg"  forKey: @"jpg"];
  [standardMimeTypes setObject: @"image/png"  forKey: @"png"];
  [standardMimeTypes setObject: @"image/pnm"  forKey: @"pnm"];
  [standardMimeTypes setObject: @"image/tiff"  forKey: @"tif"];
  [standardMimeTypes setObject: @"image/tiff"  forKey: @"tiff"];

  [standardMimeTypes setObject: @"text/html"  forKey: @"htm"];
  [standardMimeTypes setObject: @"text/html"  forKey: @"html"];
  [standardMimeTypes setObject: @"text/plain"  forKey: @"c"];
  [standardMimeTypes setObject: @"text/plain"  forKey: @"cc"];
  [standardMimeTypes setObject: @"text/plain"  forKey: @"h"];
  [standardMimeTypes setObject: @"text/plain"  forKey: @"m"];
  [standardMimeTypes setObject: @"text/plain"  forKey: @"txt"];
  [standardMimeTypes setObject: @"text/rtf"  forKey: @"rtf"];
  [standardMimeTypes setObject: @"text/x-patch"  forKey: @"patch"];
  [standardMimeTypes setObject: @"text/xml"  forKey: @"xml"];
  
  [standardMimeTypes setObject: @"video/mpeg"  forKey: @"mpe"];
  [standardMimeTypes setObject: @"video/mpeg"  forKey: @"mpeg"];
  [standardMimeTypes setObject: @"video/mpeg"  forKey: @"mpg"];
  [standardMimeTypes setObject: @"video/quicktime"  forKey: @"mov"];
  [standardMimeTypes setObject: @"video/quicktime"  forKey: @"qt"];
  [standardMimeTypes setObject: @"video/x-msvideo"  forKey: @"avi"];
}

@end
