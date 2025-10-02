/*
 Project: Graphos
 GRBoxEditor.m

 Copyright (C) 2007-2015 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-09-18

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import "GRBoxEditor.h"
#import "GRDocView.h"
#import "GRFunctions.h"

@implementation GRBoxEditor

- (id)initEditor:(GRDrawableObject *)anObject
{
  self = [super initEditor:anObject];
  if(self != nil)
    {
    }
  return self;
}

- (NSPoint)constrainControlPoint:(NSPoint)p
{
  NSPoint pos;
  CGFloat w, h;
  NSPoint retP;
  
  retP = p;
  pos = [(GRBox *)object position];
  w = pos.x-p.x;
  h = pos.y-p.y;
  
  if (w < h)
    retP.y = pos.y+w;
  else
    retP.x = pos.x+h;
  
  return retP;
}

- (NSPoint)moveControlAtPoint:(NSPoint)p
{
  GRObjectControlPoint *cp;
  NSEvent *event;
  BOOL found = NO;
  CGFloat zFactor;
  NSPoint pp;
  
  pp = NSZeroPoint;
  cp = [(GRBox *)object startControlPoint];
  if (pointInRect([cp centerRect], p))
    {
      [self selectForEditing];
      [(GRPathObject *)object setCurrentPoint:cp];
      [cp select];
      found =  YES;
    }
  cp = [(GRBox *)object endControlPoint];
  if (pointInRect([cp centerRect], p))
    {
      [self selectForEditing];
      [(GRPathObject *)object setCurrentPoint:cp];
      [cp select];
      found =  YES;
    }

  if(!found)
    return p;

  zFactor = [object zoomFactor];

  event = [[[object view] window] nextEventMatchingMask:
				    NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  if([event type] == NSLeftMouseDragged)
    {
      [[object view] verifyModifiersOfEvent: event];
      do
        {
	  pp = [event locationInWindow];
	  pp = [[object view] convertPoint: pp fromView: nil];
	  pp = GRpointDeZoom(pp, zFactor);
	  if([[object view] shiftclick])
	    pp = [self constrainControlPoint:pp];
	  
	  [[(GRPathObject *)object currentPoint] moveToPoint: pp];
	  [(GRPathObject *)object remakePath];
	  
	  [[object view] setNeedsDisplay: YES];
	  event = [[[object view] window] nextEventMatchingMask:
					    NSLeftMouseUpMask | NSLeftMouseDraggedMask];
	  [[object view] verifyModifiersOfEvent: event];
        }
      while([event type] != NSLeftMouseUp);
  
  }
  
  return pp;
}


- (void)draw
{
  if(![object visible])
    return;
  
  if([self isGroupSelected])
    {
      [[(GRBox *)object startControlPoint] drawControlAsSelected:NO];
      [[(GRBox *)object endControlPoint] drawControlAsSelected:NO];
    }
  
  if([self isEditSelected])
    {
      [[(GRBox *)object startControlPoint] drawControl];
      [[(GRBox *)object endControlPoint] drawControl];
    }    
}

@end
