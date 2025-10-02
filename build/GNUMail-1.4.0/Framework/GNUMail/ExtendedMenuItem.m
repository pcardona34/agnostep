/*
**  ExtendedMenuItem.h
**
**  Copyright (c) 2002-2004 Ludovic Marcotte
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

#include "ExtendedMenuItem.h"

#include <AppKit/NSTextAttachment.h>
#include "Constants.h"

@implementation ExtendedMenuItem

- (void) dealloc
{
  RELEASE(_key);
  [super dealloc];
}

- (NSString *) key
{
  return _key;
}

- (void) setKey: (NSString *) theKey
{
  ASSIGN(_key, theKey);
}

- (NSTextAttachment *) textAttachment
{
  return _textAttachment;
}

- (void) setTextAttachment: (NSTextAttachment *) theTextAttachment
{
  _textAttachment = theTextAttachment;
}

@end
