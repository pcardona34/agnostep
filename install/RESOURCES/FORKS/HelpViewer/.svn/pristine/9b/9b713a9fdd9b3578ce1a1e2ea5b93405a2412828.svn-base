/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
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

#include "BrowserCell.h"

@implementation BrowserCell

- (void) dealloc 
{
  DESTROY(image);
  [super dealloc];
}


- (id) copyWithZone: (NSZone *) theZone
{
  BrowserCell *aCell;

  aCell = [super copyWithZone:theZone];
  [aCell setImage: image];
  [aCell setSection: section];

  return aCell;
}

- (void) setImage: (NSImage *) theImage
{
  if ( theImage )
    {
      RETAIN(theImage);
      RELEASE(image);
      image = theImage;
    }
  else
    {
      DESTROY(image);
    }
}

- (void) drawWithFrame: (NSRect) theFrame
                inView: (NSView *) theView
{
  if (![theView window])
    return;
  
  if ( image )
    {
      NSRect aFrame;
      NSSize aSize;

      aSize = [image size];
      NSDivideRect(theFrame, &aFrame, &theFrame, 3 + aSize.width, NSMinXEdge);

      /*
      if ([self drawsBackground])
        {
          [[self backgroundColor] set];
          NSRectFill(aFrame);
        }
	*/

      aFrame.size = aSize;
/*
      if ( [theView isFlipped] )
        {
          aFrame.origin.y -= ceil((theFrame.size.height + aFrame.size.height) / 2);
        }
      else
        {
          aFrame.origin.y -= ceil((theFrame.size.height - aFrame.size.height) / 2);
        }
	*/

     aFrame.origin.y += 16;

      [image compositeToPoint: aFrame.origin
             operation: NSCompositeSourceOver];
    }

  [super drawWithFrame: theFrame
         inView: theView];
}

- (NSSize) cellSize
{
  NSSize aSize;

  aSize = [super cellSize];
  aSize.width += (image ? [image size].width : 0);// + 3;

  return aSize;
}


- (Section*) section { return section; }
- (void) setSection: (Section*) s {
	ASSIGN (section,s);
}

@end
