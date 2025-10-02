/*
**  ExtendedCell.h
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_ExtendedCell
#define _GNUMail_H_ExtendedCell

#import <AppKit/AppKit.h>

@class Flags;

@interface ExtendedCell : NSTextFieldCell
{
  @private
    NSImage *_answered_flag;
    NSImage *_recent_flag;
    NSImage *_flagged_flag;
    int _flags;
}

- (void) setFlags: (int) theFlags;

@end

#endif // _GNUMail_H_ExtendedCell
