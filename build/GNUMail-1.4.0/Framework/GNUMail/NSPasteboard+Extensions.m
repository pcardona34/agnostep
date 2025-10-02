/*
**  NSPasteboard+Extensions.m
**
**  Copyright (c) 2005 Ludovic Marcotte
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

#include "NSPasteboard+Extensions.h"

#include "Constants.h"
#include <Pantomime/CWMessage.h>

//
// This extension allows one to automatically add a message
// to an existing pasteboard's property list. The message
// has to be initialized - i.e., its raw source must be
// immediately available.
//
// If the pasteboard does NOT contain any message, it'll declare
// the new pasteboard type (MessagePboardType).
//
@implementation NSPasteboard (GNUMailPasteboardExtensions)

- (void) addMessage: (CWMessage *) theMessage
{
  NSMutableArray *aPropertyList;

  aPropertyList = [[NSMutableArray alloc] init];

  if ([[self types] containsObject: MessagePboardType])
    {
      [aPropertyList addObjectsFromArray: [self propertyListForType: MessagePboardType]];
    }
  else
    {
      [self declareTypes: [NSArray arrayWithObjects: MessagePboardType, nil]  owner: [NSApp delegate]];
    }
  
  [aPropertyList addObject: [NSDictionary dictionaryWithObjectsAndKeys:
					    [NSArchiver archivedDataWithRootObject: [theMessage flags]], @"Flags", 
					  [theMessage rawSource], @"Message", nil]];
  [self setPropertyList: aPropertyList  forType: MessagePboardType];
  RELEASE(aPropertyList);
}

@end


