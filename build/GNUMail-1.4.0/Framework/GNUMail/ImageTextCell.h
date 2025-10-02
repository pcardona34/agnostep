/*
**  ImageTextCell.h
**
**  Copyright (c) 2003-2007 Ludovic Marcotte
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

#ifndef _GNUMail_H_ImageTextCell
#define _GNUMail_H_ImageTextCell

#import <AppKit/AppKit.h>

@interface ImageTextCell : NSTextFieldCell
{
  @private
    NSImage *_image;
    int _delta;
}

- (void) setDelta: (int) theDelta;
- (void) setImage: (NSImage *) theImage;
- (void) drawWithFrame: (NSRect) theFrame 
               inView: (NSView *) theView;
- (NSSize) cellSize;

@end

#endif // _GNUMail_H_ImageTextCell
