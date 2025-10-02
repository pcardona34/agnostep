/*
**  ThreadArcsCell.m
**
**  Copyright (c) 2004-2007 Ludovic Marcotte
**  Copyright (C) 2015-2020 Riccardo Mottola
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

#import "ThreadArcsCell.h"

#import "GNUMail.h"
#import "Constants.h"
#import "MailboxInspectorPanelController.h"
#import "MailHeaderCell.h"
#import "MailWindowController.h"
#import "MessageViewWindowController.h"
#import "NSBezierPath+Extensions.h"
#import "NSFont+Extensions.h"
#import "Utilities.h"

#import <Pantomime/CWContainer.h>
#import <Pantomime/CWFlags.h>
#import <Pantomime/CWFolder.h>
#import <Pantomime/CWMessage.h>


#define DOT_DIAM 5
#define DOT_RAD  2.5
#define DOT_DIST 10


//
// Private interface
//
@interface ThreadArcsCell (Private)
- (void) _drawArcsInFrame: (NSRect) theFrame
		   inView: (NSView *) theView;
@end


//
//
//
@implementation ThreadArcsCell

- (id) init
{
  self = [super init];

  _color = RETAIN([NSColor colorWithCalibratedRed: 0.898
			   green: 0.988
			   blue: 0.937
			   alpha: 1.0]);

  _rect_table = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 16);
  _uses_inspector = NO;
  
  _left_scroll_rect = NSZeroRect;
  _right_scroll_rect = NSZeroRect;

  _last_selected_message = nil;
  _start_message = nil;
  _start_message_nr = 0;

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_color);
  NSFreeMapTable(_rect_table);
  [super dealloc];
}

//
//
//
- (void) setUsesInspector: (BOOL) theBOOL
{
  _uses_inspector = theBOOL;
}


//
// No need to retain here.
//
- (void) setController: (id) theController
{
  _controller = theController;
}


- (NSSize) cellSize
{
  NSSize retSize;

  retSize.width = THREAD_ARCS_CELL_WIDTH;

  if ([_controller isKindOfClass: [MailboxInspectorPanelController class]])
    retSize.height = [[_controller textView] frame].size.height;
  else
    retSize.height = [[_controller mailHeaderCell] cellSize].height;
  
  return retSize;
}

//
//
//
- (BOOL) trackMouse: (NSEvent *) theEvent
	     inRect: (NSRect) cellFrame
	     ofView: (NSView *) aTextView
   atCharacterIndex: (NSUInteger) charIndex
       untilMouseUp: (BOOL) flag
{
  NSArray *allKeys;
  NSValue *aValue;

  NSPoint aPoint;
  NSRect aRect;
  NSUInteger i;

  aPoint = [aTextView convertPoint: [theEvent locationInWindow]  fromView: nil];
  allKeys = NSAllMapTableKeys(_rect_table);
  
  if (!NSEqualRects(_left_scroll_rect, NSZeroRect) && NSMouseInRect(aPoint, _left_scroll_rect, YES))
    {
      if (_start_message_nr > 0)
	{
	  _start_message_nr -= 1;
	}

      [aTextView setNeedsDisplay: YES];
      return YES;
    }

  if (!NSEqualRects(_right_scroll_rect, NSZeroRect)  && NSMouseInRect(aPoint, _right_scroll_rect, YES))
    {
      if (_start_message_nr < [allKeys count]-5)
	{
	  _start_message_nr += 1;
	}

      [aTextView setNeedsDisplay: YES];
      return YES;
    }
  
  for (i = 0; i < [allKeys count]; i++)
    {
      aValue = [allKeys objectAtIndex: i];
      aRect = [aValue rectValue];
      
      if (NSMouseInRect(aPoint, aRect, YES))
	{
	  CWMessage *aMessage;
	  id aController;
 
	  aMessage = NSMapGet(_rect_table, aValue);
	  aController = [[GNUMail lastMailWindowOnTop] windowController];

	  if ([aController isKindOfClass: [MailWindowController class]])
	    {
	      int row;

	      row = [[aController allMessages] indexOfObject: aMessage];
	      
	      if (row >= 0 && row < [[aController allMessages] count])
		{
		  [[aController dataView] selectRow: row  byExtendingSelection: NO];
		}
	    }
	  else
	    {
	      [(MessageViewWindowController *)aController setMessage: aMessage];
	      [Utilities showMessage: aMessage
			 target: [aController textView]
			 showAllHeaders: [aController showAllHeaders]];
	    }
	}
    }

  return YES;
}

//
//
//
- (void) drawWithFrame: (NSRect) theFrame
		inView: (NSView *) theView
{
  NSBezierPath *aRoundRect;
  NSSize aFrame;
  id aCell;

  if (_uses_inspector)
    {
      aFrame = [[[_controller textView] enclosingScrollView] contentSize];
      theFrame.origin.x += 3;
      theFrame.size = aFrame;
      theFrame.size.width -= 3+9;
      theFrame.size.height -= 9;
    }
  else
    {
      aCell = [_controller mailHeaderCell];
      theFrame.size = [aCell cellSize];
      
      if (theFrame.size.height < THREAD_ARCS_CELL_MIN_HEIGHT)
	{
	  theFrame.size.height = THREAD_ARCS_CELL_MIN_HEIGHT;
	}
      theFrame.size.width = THREAD_ARCS_CELL_WIDTH;
      theFrame.origin.x += floor(CELL_HORIZ_BORDER / 2);
    }
  
  theFrame.origin.y = 5;

  [_color set];

  aRoundRect = [NSBezierPath bezierPath];
  [aRoundRect appendBezierPathWithRoundedRectangle: theFrame
                                        withRadius: 8.0];
  [aRoundRect fill];

  [self _drawArcsInFrame: theFrame  inView: theView];
}

@end

//
//
//
@implementation ThreadArcsCell (Private)

- (void) _drawArcsInFrame: (NSRect) theFrame
		   inView: (NSView *) theView
{
  NSMutableAttributedString *aMutableAttributedString;
  NSMutableArray *allMessages;
  NSEnumerator *theEnumerator;
  CWContainer *aContainer;
  CWMessage *aMessage;

  NSBezierPath *aBezierPath;
  NSPoint points[3];
  NSRect aRect;

  NSInteger i, j, origin, height, count;
  CGFloat scrollview_width;
  BOOL flip;

  NSResetMapTable(_rect_table);

  aMessage = [_controller selectedMessage];
  scrollview_width = 0;

  aMutableAttributedString = [[NSMutableAttributedString alloc] initWithString: _(@"Thread")];

  if (!_uses_inspector)
    {
      origin = (THREAD_ARCS_CELL_WIDTH-[aMutableAttributedString size].width)/2 + theFrame.origin.x;
    }
  else
    {
      scrollview_width = [[[_controller textView] enclosingScrollView] contentSize].width;
      origin = (scrollview_width-15-[aMutableAttributedString size].width)/2 + theFrame.origin.x;
    }

  [aMutableAttributedString setAttributes:
			      [NSDictionary dictionaryWithObjectsAndKeys:
					      [NSFont headerNameFont], NSFontAttributeName,
					    [NSColor colorWithCalibratedRed: 0.686  green: 0.686  blue: 0.886  alpha: 1.0],
					    NSForegroundColorAttributeName, nil]
			    range: NSMakeRange(0, [aMutableAttributedString length])];
  
  [aMutableAttributedString drawAtPoint: NSMakePoint(origin, 10)];
  AUTORELEASE(aMutableAttributedString);
  
  //
  // Find the root container
  //
  aContainer = [aMessage propertyForKey: @"Container"];

  // We check if we found a container
  if (!aContainer)
    {
      return;
    }

  while (aContainer->parent) aContainer = aContainer->parent;
  
  // We check for the associated message
  if (!aContainer->message)
    {
      return;
    }

  //
  // We now get all children of the root container. We need them
  // in order to fully draw the thread arcs.
  // 
  allMessages = [[NSMutableArray alloc] init];
  [allMessages addObject: aContainer->message];
  theEnumerator = [aContainer childrenEnumerator];

  while ((aContainer = [theEnumerator nextObject]))
    {
      aMessage = aContainer->message;
      [allMessages addObject: aMessage];
    }

  //
  // We sort the messages by date, critical for thread arcs to be useful.
  //
  [allMessages sortUsingSelector: @selector(compareAccordingToDate:)];
  count = [allMessages count];

  //
  // This will be the y position in the window
  //
  height = theFrame.size.height/2+20;
  origin = theFrame.origin.x+10;

  //
  // If the current thread has changed, we start from the first message.
  // Thread change is determined by the first message in the thread.
  //
  if (_start_message != [allMessages objectAtIndex: 0])
    {
      _start_message = [allMessages objectAtIndex: 0];
      _start_message_nr = 0;
    }

  //
  // Now move the currently selected message into the drawable area.
  // We do this only if the message selection has changed, not when
  // the user simply scrolls the arcs.
  //
  if (_last_selected_message != [_controller selectedMessage])
    {
      _last_selected_message = [_controller selectedMessage];
      i = [allMessages indexOfObject: _last_selected_message];
      if (i != NSNotFound)
        {
          if (i < _start_message_nr)
            {
              _start_message_nr = i;
            }
          if (i > (_start_message_nr-1+(THREAD_ARCS_CELL_WIDTH-10)/DOT_DIST))
            {
              _start_message_nr += (i+1-(_start_message_nr+(THREAD_ARCS_CELL_WIDTH-10)/DOT_DIST));
            }
        }
    }

  //
  // Save the current graphics state and set a clipping area
  // for the thread arcs
  //
  [[NSGraphicsContext currentContext] saveGraphicsState];
  [NSBezierPath clipRect: theFrame];

  //
  // We draw the dots
  // 
  for (i = 0; i < count; i++)
    {
      int pos = i-_start_message_nr;

      aMessage = [allMessages objectAtIndex: i];
      aRect = NSMakeRect(origin+pos*DOT_DIST, height, DOT_DIAM, DOT_DIAM);

      NSMapInsert(_rect_table, (void *)[NSValue valueWithRect: aRect], (void *)aMessage);

      if (aMessage == [_controller selectedMessage])
	{
	  [[NSColor blueColor] set];
	  [[NSBezierPath bezierPathWithOvalInRect: aRect] stroke];
	}
      else
	{
	  CWFlags *theFlags = [aMessage flags];
	  if ([theFlags contain: PantomimeSeen])
	    {
	      [[NSColor lightGrayColor] set];
	    }
	  else
	    {
	      [[NSColor blackColor] set];
	    }
	  [[NSBezierPath bezierPathWithOvalInRect: aRect] fill];
	}
    }

  //
  // We draw the scrollers
  //
  [[NSColor blackColor] set];
  
  if (_start_message_nr > 0)
    {
      _left_scroll_rect = NSMakeRect(theFrame.origin.x+10, theFrame.origin.y+10, 8, [aMutableAttributedString size].height/2);
      
      points[0] = NSMakePoint(_left_scroll_rect.origin.x, _left_scroll_rect.origin.y+[aMutableAttributedString size].height/4);
      points[1] = NSMakePoint(_left_scroll_rect.origin.x+8, _left_scroll_rect.origin.y+[aMutableAttributedString size].height/2);
      points[2] = NSMakePoint(_left_scroll_rect.origin.x+8, _left_scroll_rect.origin.y);
      
      aBezierPath = [NSBezierPath bezierPath];
      [aBezierPath appendBezierPathWithPoints: points  count: 3];
      [aBezierPath closePath];
      [aBezierPath fill];
    }
  else
    {
      _left_scroll_rect = NSZeroRect;
    }
  
  if ((_uses_inspector && (aRect.origin.x > theFrame.origin.x+scrollview_width-15)) ||
      (!_uses_inspector && (aRect.origin.x > theFrame.origin.x+THREAD_ARCS_CELL_WIDTH-10)))
    {
      _right_scroll_rect = NSMakeRect(theFrame.origin.x+theFrame.size.width-18, theFrame.origin.y+10, 8, [aMutableAttributedString size].height/2);
      
      points[0] = NSMakePoint(_right_scroll_rect.origin.x+8, _right_scroll_rect.origin.y+[aMutableAttributedString size].height/4);
      points[1] = NSMakePoint(_right_scroll_rect.origin.x, _right_scroll_rect.origin.y+[aMutableAttributedString size].height/2);
      points[2] = NSMakePoint(_right_scroll_rect.origin.x, _right_scroll_rect.origin.y);
      
      aBezierPath = [NSBezierPath bezierPath];
      [aBezierPath appendBezierPathWithPoints: points  count: 3];
      [aBezierPath closePath];
      [aBezierPath fill];
    }
  else
    {
      _right_scroll_rect = NSZeroRect;
    }

  
  //
  // We draw the arcs
  //
  for (i = 0; i < count; i++)
    {
      int posi = i-_start_message_nr;

      aMessage = [allMessages objectAtIndex: i];     
      theEnumerator = [[aMessage propertyForKey: @"Container"] childrenEnumerator];
 
      while ((aContainer = [theEnumerator nextObject]))
	{
	  // We do NOT consider the sub-children
	  if (aContainer->parent != [aMessage propertyForKey: @"Container"])
	    {
	      //NSLog(@"SKIPPING SUB-CHILDREN");
	      continue;
	    }

	  j = [allMessages indexOfObject: aContainer->message]; 
	  flip = (j%2 == 0 ? YES : NO);

	  //NSLog(@"i === %d   j ===== %d   flip = %d", i, j, flip);
	  //if (flip) NSLog(@"FLIP!");

	  //
	  // If we are drawing arcs for the selected message OR
	  // if we are drawing arcs TO the selected message
	  //
	  if (aMessage == [_controller selectedMessage] ||
	      aContainer->message == [_controller selectedMessage])
	    {
	      [[NSColor blueColor] set];
	    }
	  else
	    {
	      [[NSColor lightGrayColor] set];
	    }

	  aBezierPath = [NSBezierPath bezierPath];

          if (_uses_inspector)
            {
              int posj = j-_start_message_nr;
	      
  	      [aBezierPath appendBezierPathWithArcWithCenter:
			     NSMakePoint(origin+7.5+posi*DOT_DIST+(posj-posi-1)*5, (flip?height+5:height+1))
			   radius: 5+(posj-posi-1)*5
			   startAngle: (flip?0:180)
			   endAngle: (flip?180:0)];
            }
          else
            {
              int posj = j-_start_message_nr;
	      int ydist, ymid;
	      int radius = abs((posj-posi)*DOT_DIAM);
	      if (radius > 6*DOT_DIAM)
		{
		  radius = 6*DOT_DIAM;
		}

	      ymid = height+DOT_RAD;
	      ydist = flip ? ymid+radius : ymid-radius;
	      
	      [aBezierPath moveToPoint: NSMakePoint(origin+posi*DOT_DIST+DOT_RAD, ymid)];
	      
  	      [aBezierPath appendBezierPathWithArcFromPoint: NSMakePoint(origin+posi*DOT_DIST+DOT_RAD, ydist)
			   toPoint: NSMakePoint(origin+posi*DOT_DIST+DOT_RAD+(posj-posi)*DOT_DIST/2., ydist)
			   radius: radius];
	      
  	      [aBezierPath appendBezierPathWithArcFromPoint: NSMakePoint(origin+posj*DOT_DIST+DOT_RAD, ydist)
			   toPoint: NSMakePoint(origin+posj*DOT_DIST+DOT_RAD, ymid)
			   radius: radius];
            }

	  [aBezierPath stroke];
	}
    }

  //
  // restore the old graphics state
  //
  [[NSGraphicsContext currentContext] restoreGraphicsState];
  RELEASE(allMessages);
}

@end
