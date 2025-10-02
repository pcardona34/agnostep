/*
**  NSUserDefaults+Extensions.m
**
**  Copyright (C) 2002-2007 Ludovic Marcotte
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

#include "NSUserDefaults+Extensions.h"

@implementation NSUserDefaults (GNUMailColorExtensions)

- (NSColor *) colorForKey: (NSString *) theKey
{
  NSString *aString;
  NSColor *aColor;
  float r, g, b;
  
  aString = [self objectForKey: theKey];

  if ( !aString )
    {
      return nil;
    }

  if (sscanf([aString cString], "%f %f %f", &r, &g, &b) != 3)
    {
      return nil;
    }

  aColor = [NSColor colorWithCalibratedRed: r
		    green: g 
		    blue: b
		    alpha: 1.0];
  
  return aColor;
}


//
//
//
- (void) setColor: (NSColor *) theColor
           forKey: (NSString *) theKey
{
  NSString *aString;

  if ( !theColor || !theKey )
    {
      return;
    }

#ifdef MACOSX
  theColor = [theColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
#endif
  
  aString = [NSString stringWithFormat: @"%f %f %f",
		      [theColor redComponent],
		      [theColor greenComponent],
		      [theColor blueComponent]];

  [self setObject: aString  forKey: theKey];
}


//
//
//
- (int) integerForKey: (NSString *) theKey
              default: (int) theValue
{
  id o;

  o = [self objectForKey: theKey];

  if (o)
    {
      return [o intValue];
    }
  
  return theValue;
}

@end
