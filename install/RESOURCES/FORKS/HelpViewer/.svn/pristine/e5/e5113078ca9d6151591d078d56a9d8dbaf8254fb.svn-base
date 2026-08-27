/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003      Nicolas Roard <nicolas@roard.com>
                  2020-2025 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#include "ModNSString.h"

@implementation NSDecimalNumber (String)
- (NSString*) stringValue
{
  return [NSString stringWithFormat: @"%d", (int)[self doubleValue]];
}
@end

@implementation NSString (Trim)

+ (NSString*) stringWithStringByTrimmingSpaces: (NSString*) str
{
  return [NSString stringWithStringByTrimmingSpaces: str skipStart:YES];
}

+ (NSString*) stringWithStringByTrimmingSpaces: (NSString*) str skipStart: (BOOL)skipStart
{
  return [str stringByTrimmingSpacesSkippingStart: skipStart];
}

- (NSString*) stringByTrimmingSpaces;
{
  return [self stringByTrimmingSpacesSkippingStart:YES];
}

- (NSString*) stringByTrimmingSpacesSkippingStart: (BOOL)flag
{
  NSMutableString *retStr; 
  BOOL space;;
  NSUInteger i;

  space = flag;
  retStr = [[NSMutableString alloc] initWithString: @""];
  for (i = 0; i < [self length]; i++)
    {
      unichar ch = [self characterAtIndex: i];

      if (ch == ' ')
        {
          if (!space) 
            {
              [retStr appendString: [NSString stringWithCharacters:&ch length:1]];
              space = YES;
            }
        }
      else if (ch == '\n' || ch == '\r')
        {
        }
      else if (ch == '\t')
        {
          if (!space)
            {
              [retStr appendString: @" "];
              space = YES;
            }
        }
      else
        {
          [retStr appendString: [NSString stringWithCharacters:&ch length:1]];
          space = NO;
        }
    }

  NSLog (@"trimmed string : |%@|", retStr);
  return [retStr autorelease];
}

@end
