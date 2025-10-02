/*
**  MailHeaderCell.m
**
**  Copyright (c) 2002-2012 Nicolas Roard, Ludovic Marcotte
**  Copyright (C) 2015-2020 Riccardo Mottola
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

#import "MailHeaderCell.h"

#import "GNUMail.h"
#import "Constants.h"
#import "MailWindowController.h"
#import "NSBezierPath+Extensions.h"
#import "NSUserDefaults+Extensions.h"

#import <Pantomime/CWFolder.h>


//
//
//
@implementation MailHeaderCell

- (id) init 
{
  self = [super init];
  if (self != nil)
    {
      [self setColor: nil];
      _cellSize = NSZeroRect.size;

      _allViews = [[NSMutableArray alloc] init];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_originalAttributedString);
  RELEASE(_allViews);
  RELEASE(_color);
  [super dealloc];
}

- (NSSize)calcSize:(NSSize)aSize
{
  NSSize retSize;
  
  NSTextStorage *textStorage;
  NSTextContainer *textContainer;
  NSLayoutManager *layoutManager;
  
  retSize = aSize;
  aSize.width -= 2*CELL_HORIZ_BORDER;
    
  textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedStringValue]];
  textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(aSize.width,FLT_MAX)];
  layoutManager = [[NSLayoutManager alloc] init];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textContainer setLineFragmentPadding:0.0];
  [layoutManager glyphRangeForTextContainer:textContainer]; // forces a re-layout
  retSize.height = [layoutManager usedRectForTextContainer:textContainer].size.height;
  retSize.height += 2 * CELL_VERT_INSET;
  [textContainer release];
  [layoutManager release];
  [textStorage release];
  
  //
  // We want the MailHeaderCell to be at least as high
  // as the ThreadArcsCell, which needs a minimum height.
  //
  if ([[_controller folder] allContainers])
    {
      if (retSize.height < THREAD_ARCS_CELL_MIN_HEIGHT)
        retSize.height = THREAD_ARCS_CELL_MIN_HEIGHT;
    }
  
  return retSize;
}



//
//
//
- (void) setColor: (NSColor *) theColor
{
  if (theColor)
    {
      ASSIGN(_color, theColor);
    }
  else
    {
      RELEASE(_color);

      _color = [[NSUserDefaults standardUserDefaults] colorForKey: @"MAILHEADERCELL_COLOR"];
      
      if (!_color)
	{
	  _color = [NSColor colorWithCalibratedWhite: 0.9 alpha: 1.0];
	}
      
      RETAIN(_color);
    }
}


//
// protocol method
//
- (NSSize) cellSize
{
  return _cellSize;
}


//
// other methods
//
- (void) addView: (id) theView
{
  if (theView)
    {
      [_allViews addObject: theView];
    }
}


//
//
//
- (BOOL) containsView: (id) theView
{
  return [_allViews containsObject: theView];
}


//
//
//
- (void) resize: (id) sender
{
  NSRect aRect;
  
  aRect = [[_controller textView] frame];
  
  if ([[_controller folder] allContainers])
    {
      _cellSize.width = aRect.size.width-THREAD_ARCS_CELL_WIDTH - CELL_HORIZ_BORDER;
    }
  else
    {
      _cellSize.width = aRect.size.width;
    }
  _cellSize.width -= CELL_HORIZ_BORDER;
  
  _cellSize = [self calcSize:NSMakeSize(_cellSize.width, 0)];
}


//
//
//
- (void) setAttributedStringValue: (NSAttributedString *) theAttributedString
{
  ASSIGN(_originalAttributedString, theAttributedString);
  [super setAttributedStringValue: theAttributedString];
}


//
// No need to retain here.
//
- (void) setController: (id) theController
{
  _controller = theController;
}


//
//
//
- (void) drawWithFrame: (NSRect) theFrame
		inView: (NSView *) theView
{  
  NSBezierPath *aRoundRect;
  NSView *aView;
  NSRect drawRect;
  NSSize aSize;
  
  CGFloat current_x, current_y, delta;
  NSUInteger i;
  
  if (![theView window])
    {
      return;
    }

  drawRect = theFrame;
  
  if (drawRect.size.width != [self cellSize].width)
    {
      NSLog(@"Width changed, should recalculate height. Should this happen at all?");
      [self resize:self];
    }

  // We fill our cell
  drawRect.origin.y += 5;
  //drawRect.size.width -= CELL_HORIZ_BORDER;
  
  [_color set];
  aRoundRect = [NSBezierPath bezierPath];
  [aRoundRect appendBezierPathWithRoundedRectangle: drawRect
                                        withRadius: 8.0];
  [aRoundRect fill];
  
  current_x = theFrame.origin.x + theFrame.size.width;
  delta = 0;

  for (i = 0; i < [_allViews count]; i++)
    {
      aView = [_allViews objectAtIndex: i];

      // If our bundle doesn't provide an image, we draw it's view
      if (![aView respondsToSelector: @selector(image)])
	{
	  if (NSEqualRects([aView frame], NSZeroRect))
	    {
	      continue;
	    }

	  aSize = [aView frame].size;
	  current_x = current_x - aSize.width - 10;
	  current_y = theFrame.origin.y + aSize.height + (theFrame.size.height - aSize.height)/2;
	  delta += aSize.width;

	  [aView drawRect: NSMakeRect(current_x, current_y, aSize.width, aSize.height)];
	}
      else
	{
	  NSImage *aImage;

	  aImage = [(id)aView image];
	  
	  if (!aImage)
	    {
	      continue;
	    }
	  
	  aSize = [aImage size];
	  
	  current_x = current_x - aSize.width - 10;
	  current_y = theFrame.origin.y + aSize.height + (theFrame.size.height - aSize.height)/2;
	  delta += aSize.width;

	  [aImage compositeToPoint: NSMakePoint(current_x, current_y)
		  operation: NSCompositeSourceAtop];
	}
    }

  // We adjust our frame and we draw our attributed string
  drawRect.origin.x += CELL_HORIZ_INSET; 
  drawRect.size.width -= (2*CELL_HORIZ_INSET+delta);
  drawRect.origin.y += CELL_VERT_INSET;
  drawRect.size.height -= 2*CELL_VERT_INSET;
  
  [aRoundRect stroke];
  [[self attributedStringValue] drawInRect: drawRect];
}

@end
