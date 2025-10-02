/*
**  EmoticonController.m
**
**  Copyright (c) 2003-2005 Ludovic Marcotte
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

#include "EmoticonController.h"

#include "Constants.h"

#include <Pantomime/CWMessage.h>

static EmoticonController *singleInstance = nil;

//
// The emoticon images are from gnomemeeting (http://www.gnomemeeting.org).
//
static struct { NSString *glyph; NSString *image; } emoticons[] = {
  {@":)", @"emoticon-face1.tiff"},
  {@":-)", @"emoticon-face1.tiff"},
  {@":o)", @"emoticon-face1.tiff"},
  {@"8)", @"emoticon-face2.tiff"},
  {@"8-)", @"emoticon-face2.tiff"},
  {@";)", @"emoticon-face3.tiff"},
  {@";o)", @"emoticon-face3.tiff"},
  {@";-)", @"emoticon-face3.tiff"},
  {@":-(", @"emoticon-face4.tiff"},  //  :( conflicts with objc code! like: itemAtIndex:(int)theIndex
  {@":o(", @"emoticon-face4.tiff"},  
  {@":-0", @"emoticon-face5.tiff"},  //  :0 conflicts with a time value! like: 18:00
  {@":-o", @"emoticon-face5.tiff"},
  {@":D", @"emoticon-face6.tiff"},
  {@":-D", @"emoticon-face6.tiff"},
  {@":|", @"emoticon-face8.tiff"},
  {@":-|", @"emoticon-face8.tiff"},
  {@":-/", @"emoticon-face9.tiff"},  //  :/ conflicts with URLs! like: http://foobarbaz.com
  {@":o/", @"emoticon-face9.tiff"},  
  {@":p", @"emoticon-face10.tiff"},
  {@":-p", @"emoticon-face10.tiff"},
  {@":'(", @"emoticon-face11.tiff"},
  {@":,(", @"emoticon-face11.tiff"},
  {@";o(", @"emoticon-face11.tiff"},
  {@":-*", @"emoticon-face13.tiff"},
  {@":-x", @"emoticon-face14.tiff"},
  {@"B)", @"emoticon-face15.tiff"},
  {@"B-)", @"emoticon-face15.tiff"},
  {@":-.", @"emoticon-face19.tiff"},
  {@":o", @"emoticon-face5.tiff"}
};


//
//
//
@implementation EmoticonController

- (id) initWithOwner: (id) theOwner
{
  NSBundle *aBundle;
  
  self = [super init];

  owner = theOwner;
 
  aBundle = [NSBundle bundleForClass: [self class]];
  
  resourcePath = [aBundle resourcePath];
  RETAIN(resourcePath);

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(resourcePath);

  [super dealloc];
}


//
//
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[EmoticonController alloc] initWithOwner: nil];
    }

  return singleInstance;
}


//
// access / mutation methods
//
- (NSString *) name
{
  return @"Emoticon";
}

- (NSString *) description
{
  return @"This is a simple Emoticon bundle.";
}

- (NSString *) version
{
  return @"v0.2.0";
}

- (void) setOwner: (id) theOwner
{
  owner = theOwner;
}

//
// UI elements
//
- (BOOL) hasPreferencesPanel
{
  return NO;
}

- (BOOL) hasComposeViewAccessory
{
  return NO;
}

- (BOOL) hasViewingViewAccessory
{
  return NO;
}

- (id) viewingViewAccessory
{  
  return nil;
}

//
//
//
- (enum ViewingViewType) viewingViewAccessoryType
{
  return ViewingViewTypeHeaderCell;
}

- (void) viewingViewAccessoryWillBeRemovedFromSuperview: (id) theView
{
}

- (void) setCurrentSuperview: (NSView *) theView
{
}

- (NSArray *) submenuForMenu: (NSMenu *) theMenu
{
  return nil;
}

- (NSArray *) menuItemsForMenu: (NSMenu *) theMenu
{
  return nil;
}


//
// Pantomime related methods
//
- (void) messageWasDisplayed: (CWMessage *) theMessage
                      inView: (NSTextView *) theTextView
{
  NSTextAttachment *aTextAttachment;
  NSFileWrapper *aFileWrapper;
  NSTextStorage *aTextStorage;
  NSString *aString;
 
  NSRange aRange;
  int i, j, k, len;
  char c;
 
  aTextStorage = [theTextView textStorage];
#ifdef MACOSX
  [aTextStorage beginEditing];
#endif

  aString = [aTextStorage string];
  len = [aString length];

  for (i = 0; i < len; i++)
    {
      c = [aString characterAtIndex: i];
      
      if (c == 'b' || c == 'B' || c == ':' || c == ';' || c == '8')
	{
	  char cc;

	  for (j = i+1; j < len; j++)
	    {
	      // We chop the higher bits in case we got a unichar.
	      cc = [aString characterAtIndex: j];
	      if (isspace(cc)) break;
	    }

	  if ((j-i == 2 || j-i == 3) && i-1 > 0 && isspace((cc = [aString characterAtIndex: i-1])))
	    {
	      aRange = NSMakeRange(i,j-i);
	      
	      for (k = 0; k < sizeof(emoticons)/sizeof(emoticons[0]); k++)
		{
		  if ([emoticons[k].glyph isEqualToString: [aString substringWithRange: aRange]])
		    {
		      aFileWrapper = [[NSFileWrapper alloc] initWithPath: [NSString stringWithFormat: @"%@/%@", resourcePath, emoticons[k].image]];
		      aTextAttachment = [[NSTextAttachment alloc] initWithFileWrapper: aFileWrapper];
		      
		      [aTextStorage replaceCharactersInRange: aRange
				    withAttributedString: [NSAttributedString attributedStringWithAttachment: aTextAttachment]];
		      
		      RELEASE(aTextAttachment);
		      RELEASE(aFileWrapper);

		      len = len-(j-i)+1;
		      break;
		    }
		}
	      
	      i = j-1;
	    }
	}
    }

#ifdef MACOSX
  [aTextStorage endEditing];
#endif
}

@end
