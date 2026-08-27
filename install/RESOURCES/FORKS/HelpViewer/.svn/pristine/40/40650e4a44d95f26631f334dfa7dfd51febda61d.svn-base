/* -*- mode: objc -*-

    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
                  2020 Riccardo Mottola <rm@gnu.org>

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

#ifndef __FIGURE_CELL_H__
#define __FIGURE_CELL_H__

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GNUstep.h"
#import "Legend.h"

@interface FigureCell : NSTextAttachmentCell
{
  NSImage *_image;
  NSArray *_legends;
  NSSize _size;
  CGFloat border;
  CGFloat spaceMargin;
}

- (id) initWithSize: (NSSize) size; 
- (NSSize) cellSize;
- (void) setImage: (NSImage*) img;
- (void) setLegends: (NSArray*) legends;
- (void) resize: (id) sender;
- (void) resizeWithTextView: (NSTextView*) textView;
- (void) drawWithFrame: (NSRect) cellFrame
                inView: (NSView*) controlView;

@end

#endif
