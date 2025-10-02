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

#ifndef _GNUMail_H_ExtendedMenuItem
#define _GNUMail_H_ExtendedMenuItem

#include <Foundation/NSObject.h>
#include <AppKit/NSMenuItem.h>

@class NSTextAttachment;

@interface ExtendedMenuItem : NSMenuItem
{
  @private
    NSTextAttachment *_textAttachment;
    NSString *_key;
}

- (NSString *) key;
- (void) setKey: (NSString *) theKey;

- (NSTextAttachment *) textAttachment;
- (void) setTextAttachment: (NSTextAttachment *) theTextAttachment;

@end

#endif // _GNUMail_H_ExtendedMenuItem
