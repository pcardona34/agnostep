/*
**  NSColor+Extensions.m
**
**  Copyright (c) 2004-2005 Ludovic Marcotte
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

#include "NSColor+Extensions.h"

#include "Constants.h"
#include "NSUserDefaults+Extensions.h"

static NSMutableArray *quoteLevelColors = nil;

#define MAX_LEVEL 4

//
//
//
@implementation NSColor (GNUMailColorExtensions)

+ (NSColor *) colorForLevel: (int) theLevel
{
  if (!quoteLevelColors)
    {
      quoteLevelColors = [[NSMutableArray alloc] initWithCapacity: MAX_LEVEL];
    }
  
  if ([quoteLevelColors count] == 0)
    {
      NSUserDefaults *aUserDefaults;
      NSColor *aColor;

      aUserDefaults = [NSUserDefaults standardUserDefaults];
      
      // We look at the user preferences to get the colors...
      aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_1"];
      if ( aColor )
	{
	  [quoteLevelColors addObject: aColor];
	}	
      else
	{
	  [quoteLevelColors addObject: [NSColor blueColor]];
	}
      
      aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_2"];
      if ( aColor )
	{
	  [quoteLevelColors addObject: aColor];
	}	
      else
	{
	  [quoteLevelColors addObject: [NSColor redColor]];
	}
      
      aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_3"];
      if ( aColor )
	{
	  [quoteLevelColors addObject: aColor];
	}	
      else
	{
	  [quoteLevelColors addObject: [NSColor greenColor]];
	}
      
      aColor = [aUserDefaults colorForKey: @"QUOTE_COLOR_LEVEL_4"];
      if ( aColor )
	{
	  [quoteLevelColors addObject: aColor];
	}
      else
	{
	  [quoteLevelColors addObject: [NSColor cyanColor]];
	}
    }
  
  return [quoteLevelColors objectAtIndex: (theLevel-1)%MAX_LEVEL];
}


//
//
//
+ (void) updateCache
{
  DESTROY(quoteLevelColors);
}

@end
