/*
**  ThreadArcsCell.h
**
**  Copyright (c) 2004-2005 Ludovic Marcotte
**  Copyright (C) 2016      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
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

#ifndef _GNUMail_H_ThreadArcsCell
#define _GNUMail_H_ThreadArcsCell

#import <AppKit/AppKit.h>

@class CWMessage;

//
//
//
@interface ThreadArcsCell : NSTextAttachmentCell
{
  @private
    NSColor *_color;
    NSMapTable *_rect_table;

    NSRect _right_scroll_rect;
    NSRect _left_scroll_rect;

    BOOL _uses_inspector;

    CWMessage *_last_selected_message;
    CWMessage *_start_message;
    int _start_message_nr;

    id _controller;
}

- (void) setUsesInspector: (BOOL) theBOOL;
- (void) setController: (id) theController;

@end

#endif // _GNUMail_H_ThreadArcsCell
