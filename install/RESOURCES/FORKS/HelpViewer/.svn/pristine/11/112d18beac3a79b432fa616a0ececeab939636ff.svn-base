/* -*- mode: objc -*-

    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>

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

#ifndef __BROWSER_CELL_H__
#define __BROWSER_CELL_H__

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Section.h"

@interface BrowserCell: NSBrowserCell
{
  Section *section;
  NSImage *image;
}

- (void) setImage: (NSImage *) theImage;
- (void) drawWithFrame: (NSRect) theFrame inView: (NSView *) theView;
- (NSSize) cellSize;
- (void) setSection: (Section*) sec;
- (Section*) section;

@end

#endif
