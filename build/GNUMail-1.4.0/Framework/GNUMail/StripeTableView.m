/*
 **  StripeTableView.m
 **
 **  Copyright (c) 2003 Francis Lachapelle
 **
 **  Author: Francis Lachapelle <francis@Sophos.ca>
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

#import "StripeTableView.h"


@implementation StripeTableView


//
// Method of NSTableView.
// Highlights the region of the receiver in theRect.
// This method is invoked before drawRow:clipRect:.drawn.
//
- (void) highlightSelectionInClipRect: (NSRect) theRect
{
  [self drawStripesInRect: theRect];
  [super highlightSelectionInClipRect: theRect];
}


//
// Method of NSTableView.
// Draws the grid lines within theRect, using the grid color set with setGridColor:.
// This method draws a grid regardless of whether the receiver is set to draw
// one automatically.
//
- (void) drawGridInClipRect: (NSRect) theRect
{
  NSArray *columnsArray;
  NSRect aRect;
  int i, xPos;
  
  aRect = [self bounds];
  columnsArray = [self tableColumns];
  xPos = 0;
    
  for(i = 0 ; i < [columnsArray count] ; i++)
    {
      xPos += [[columnsArray objectAtIndex:i] width] + [self intercellSpacing].width;
      [[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.1] set];
      [NSBezierPath strokeLineFromPoint: NSMakePoint(aRect.origin.x - 0.5 + xPos,
						     aRect.origin.y)
		    toPoint: NSMakePoint(aRect.origin.x - 0.5 + xPos,
					 aRect.size.height)];
    }
}


//
//
//
- (void) drawStripesInRect: (NSRect) theRect
{
  NSRect stripeRect;
  float fullRowHeight, yClip;
  int firstStripe;
  
  fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
  yClip = NSMaxY(theRect);
  firstStripe = theRect.origin.y / fullRowHeight;
  
  if (firstStripe % 2 == 0)
    {
      firstStripe++;
    }
  
  stripeRect.origin.x = theRect.origin.x;
  stripeRect.origin.y = firstStripe * fullRowHeight;
  stripeRect.size.width = theRect.size.width;
  stripeRect.size.height = fullRowHeight;
  
  if (sStripeColor == nil)
    {
      sStripeColor = [[NSColor colorWithCalibratedRed: (237.0 / 255.0)
			       green: (243.0 / 255.0)
			       blue: (254.0 / 255.0)
			       alpha: 1.0]
		       retain];
    }
  [sStripeColor set];
  
  while (stripeRect.origin.y < yClip)
    {
      NSRectFill(stripeRect);
      stripeRect.origin.y += fullRowHeight * 2.0;
    }
}

@end
