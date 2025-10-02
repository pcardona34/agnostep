/*
**  NSFont+Extensions.h
**
**  Copyright (c) 2004 Ludovic Marcotte
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

#include "NSFont+Extensions.h"

#include "Constants.h"
#include <Foundation/NSUserDefaults.h>

static NSFont *deletedMessageFont = nil;
static NSFont *headerNameFont = nil;
static NSFont *headerValueFont = nil;
static NSFont *messageFont = nil;
static NSFont *plainTextMessageFont = nil;
static NSFont *recentMessageFont = nil;
static NSFont *seenMessageFont = nil;

//
//
//
@implementation NSFont (GNUMailFontExtensions)

+ (NSFont *) fontFromFamilyName: (NSString *) theName
			  trait: (int) theTrait
			   size: (int) theSize
{
  NSArray *allFontNames;
  NSString *aFontName;
  NSFont *aFont;
  int i;
  
  allFontNames = [[NSFontManager sharedFontManager] availableMembersOfFontFamily: theName];
  aFontName = nil;

  if (theName)
    {
      for (i = 0; i < [allFontNames count]; i++)
	{
	  NSArray *attributes;
	  
	  attributes = [allFontNames objectAtIndex: i];
	  
	  // We verify if the font name has the trait we are looking for
	  if ( [[attributes objectAtIndex: 3] intValue] == theTrait )
	    {
	      aFontName = [attributes objectAtIndex: 0];
	      break;
	    }
	}
    }

  if (aFontName)
    {
      aFont = [self fontWithName: aFontName
		    size: theSize];
    }
  else
    {
      switch (theTrait)
	{
	case NSFixedPitchFontMask:
	  aFont = [self userFixedPitchFontOfSize: theSize];
	  break;

	case NSBoldFontMask:
	  aFont = [self boldSystemFontOfSize: theSize];
	  break;
	  
	case NSUnboldFontMask:
	default:
	  aFont = [self systemFontOfSize: theSize];
	  break;
	}
    }

  return aFont;
}


//
//
//
+ (NSFont *) deletedMessageFont
{
  if (!deletedMessageFont)
    {
#ifdef MACOSX
      if ([[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_NAME"] )
	{
	  deletedMessageFont = [[NSFontManager sharedFontManager] convertFont: [self seenMessageFont]  toHaveTrait: NSItalicFontMask];
	}
      else
	{
	  deletedMessageFont = [[NSFontManager sharedFontManager] convertFont: [NSFont systemFontOfSize:
											 [NSFont smallSystemFontSize]]
								  toHaveTrait: NSItalicFontMask];
	}
#else
      deletedMessageFont = [[NSFontManager sharedFontManager] convertFont: [NSFont systemFontOfSize: 0]
							      toHaveTrait: NSItalicFontMask];
#endif
      RETAIN(deletedMessageFont);
    }

  return deletedMessageFont;
}

//
//
//
+ (NSFont *) headerNameFont
{
  if (!headerNameFont)
    {
      headerNameFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] objectForKey: @"HEADER_NAME_FONT_NAME"]
			       trait: NSBoldFontMask
			       size: [[NSUserDefaults standardUserDefaults] floatForKey: @"HEADER_NAME_FONT_SIZE"]];
      RETAIN(headerNameFont);
    }

  return headerNameFont;
}


//
//
//
+ (NSFont *) headerValueFont
{
  if (!headerValueFont)
    {
      headerValueFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] objectForKey: @"HEADER_VALUE_FONT_NAME"]
				trait: NSUnboldFontMask
				size: [[NSUserDefaults standardUserDefaults] floatForKey: @"HEADER_VALUE_FONT_SIZE"]];
      RETAIN(headerValueFont);
    }

  return headerValueFont;
}


//
//
//
+ (NSFont *) messageFont
{
  if (!messageFont)
    {
      messageFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_FONT_NAME"]
			    trait: NSUnboldFontMask
			    size: [[NSUserDefaults standardUserDefaults] floatForKey: @"MESSAGE_FONT_SIZE"]];
      RETAIN(messageFont);
    }

  return messageFont;
}


//
//
//
+ (NSFont *) plainTextMessageFont
{
  if (!plainTextMessageFont)
    {
      plainTextMessageFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] objectForKey: @"PLAIN_TEXT_MESSAGE_FONT_NAME"]
				     trait: NSFixedPitchFontMask
				     size: [[NSUserDefaults standardUserDefaults] floatForKey: @"PLAIN_TEXT_MESSAGE_FONT_SIZE"]];
      RETAIN(plainTextMessageFont);
    }

  return plainTextMessageFont;
}


//
//
//
+ (NSFont *) recentMessageFont
{
  if (!recentMessageFont)
    {
#ifdef MACOSX
      if ([[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_NAME"] )
	{
	  recentMessageFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_LIST_FONT_NAME"]
				      trait: NSBoldFontMask
				      size: [[[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_SIZE"] intValue]];
	}
      else
	{
	  recentMessageFont = [NSFont boldSystemFontOfSize: [NSFont smallSystemFontSize]];
	}
#else
      recentMessageFont = [NSFont boldSystemFontOfSize: 0];
#endif
      RETAIN(recentMessageFont);
    }

  return recentMessageFont;
}


//
//
//
+ (NSFont *) seenMessageFont
{
  if (!seenMessageFont)
    {
#ifdef MACOSX
      if ([[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_NAME"] )
	{
	  seenMessageFont = [NSFont fontFromFamilyName: [[NSUserDefaults standardUserDefaults] stringForKey: @"MESSAGE_LIST_FONT_NAME"]
				 trait: NSUnboldFontMask
				 size: [[[NSUserDefaults standardUserDefaults] objectForKey: @"MESSAGE_LIST_FONT_SIZE"] intValue]];
	}
      else
	{
	  seenMessageFont = [NSFont systemFontOfSize: [NSFont smallSystemFontSize]];
	}
#else
      seenMessageFont = [NSFont systemFontOfSize: 0];
#endif
      RETAIN(seenMessageFont);
    }

  return seenMessageFont;
}


//
//
//
+ (void) updateCache
{
  DESTROY(deletedMessageFont);
  DESTROY(headerNameFont);
  DESTROY(headerValueFont);
  DESTROY(messageFont);
  DESTROY(plainTextMessageFont);
  DESTROY(recentMessageFont);
  DESTROY(seenMessageFont);
}
@end
