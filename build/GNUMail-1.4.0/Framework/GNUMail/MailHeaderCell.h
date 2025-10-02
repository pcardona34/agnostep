/*
**  MailHeaderCell.h
**
**  Copyright (c) 2002-2004 Nicolas Roard, Ludovic Marcotte
**  Copyright (C) 2015-2016 Riccardo Mottola
**
**  Author: Nicolas Roard <nicolas@roard.com>
**          Ludovic Marcotte <ludovic@Sophos.ca>
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

#ifndef _GNUMail_H_MailHeaderCell
#define _GNUMail_H_MailHeaderCell

#import <AppKit/AppKit.h>

#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef CGFloat
#define CGFloat float
#endif
#endif

#define CELL_VERT_INSET 5
#define CELL_HORIZ_INSET 8
#define CELL_HORIZ_BORDER 10

#define CELL_VERT_INSET 5
#define CELL_HORIZ_INSET 8
#define CELL_HORIZ_BORDER 10

//
//
//
@interface MailHeaderCell : NSTextAttachmentCell
{
  NSAttributedString *_originalAttributedString;
  NSMutableArray *_allViews;
  NSColor *_color;
  id _controller;

  NSSize _cellSize;
}

//
// access / mutation methods
//
- (void) resize: (id) sender;
- (void) setColor: (NSColor *) theColor;

- (void) setController: (id) theController;

//
// other methods
//
- (void) addView: (id) theView;
- (BOOL) containsView: (id) theView;

@end

#endif // _GNUMail_H_MailHeaderCell
