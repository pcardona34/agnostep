/*  -*-objc-*-
 *  GSPdfDocWin.m: Implementation of the GSPdfDocWin Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2002-2011
 *  Riccardo Mottola
 *  Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: February 2002
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GSPdfDocWin.h"
#import "GSPdfDocument.h"

#ifndef GNUSTEP
#import "GNUstep.h"
#endif

@implementation GSPdfDocWin

- (void)dealloc
{
  RELEASE (imageView);
  [super dealloc];
}

- (NSScrollView *)matrixScroll
{
  return matrixScroll;
}

- (GSPdfView *)imageView
{
  return imageView;
}

- (void)setBusy:(BOOL)value
{
  [leftButt setEnabled: !value];
  [rightButt setEnabled: !value];
}

- (BOOL)antiAlias
{
  return ([antiAliasSwitch state] == NSOnState);
}

- (void)windowDidLoad
/* some initialization stuff */
{
  NSUserDefaults *defaults;

  isZooming = NO;
  [leftButt  setImage: [NSImage imageNamed: @"left.tiff"]];
  [rightButt setImage: [NSImage imageNamed: @"right.tiff"]];
		
  [matrixScroll setHasHorizontalScroller: YES];
  [matrixScroll setHasVerticalScroller: NO];
		
  [zoomButt setImage: [NSImage imageNamed: @"zoomin.tiff"]];
  [handButt setImage: [NSImage imageNamed: @"hand.tiff"]];
		
  [scroll setHasHorizontalScroller: YES];
  [scroll setHasVerticalScroller: YES]; 
  [scroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];

  imageView = [[GSPdfView alloc] init];
  [imageView setImageAlignment: NSImageAlignBottomLeft];
  [imageView setImageScaling: NSScaleNone];
  [imageView setEditable: NO];
  [imageView setDelegate: self];

  [scroll setDocumentView: imageView];

  [zoomField setStringValue: [NSString stringWithFormat: @"%i", [zoomStepper intValue]]];

  defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults boolForKey: ANTI_ALIASING_KEY] == YES)
    [antiAliasSwitch setState: NSOnState];
  else
    [antiAliasSwitch setState: NSOffState];

  [[self document] windowControllerDidLoadNib: self];
}

/* set the image of the view and tries to scroll up if the size is changed */
- (void)setImage:(NSImage *)anImage
{
  NSSize oldSize;
  NSSize newSize;

  oldSize = [imageView frame].size;
  newSize = [anImage size];
  
  if (oldSize.width != newSize.width || oldSize.height != newSize.height)
    {
      float scale;
      NSRect visible;

      /* if the user did not click into the view try to preserve the center
         of the visible rectangle in its position */
      visible = [scroll documentVisibleRect];
      if (isZooming == NO)
	{
	  zoomPoint.x = NSMinX(visible) + NSWidth(visible) / 2;
	  zoomPoint.y = NSMinY(visible) + NSHeight(visible) / 2;
	}

      /* update the image */
      [[self imageView] setFrameSize: newSize];

      /* compute (the origin of) the new visible rectangle */
      if (oldSize.width == 0 && oldSize.height == 0)
	{
	  /* If the image is new (the view was empty before) scroll to the upper left corner. */
	  visible.origin = NSMakePoint(0, newSize.height);
	}
      else
	{
	  /* The image size changed and we e distinguish three cases here (independently for X and Y dimensions)
	   a) the new image is smaller than the visible rectangle
	     The origin we set in this case is rather irrelevant as the clip view
	     will constrain the origin such that the document view is placed at
	     the lower left corner of the visible rectangle.
	     FIXME Change the image view's size to the visible rectangle, set
	     the image view's alignment to NSImageAlignCenter and scaling to
	     NSScaleNone to center the image in the visible rectangle. Note
	     that this requires tracking frame size changes to adjust the
	     image view's size when the user resizes the window.
	   b) the old image was smaller than the visible rectangle
	     In this case, we center the new image under the visible rectangle.
	     Note that this case in particular is used when the first page is
	     displayed, as the image view is initialized with zero width and
	     height.
	   c) the old and new images are larger than the visible rectangle
	     In this case, we attempt to preserve the position of the zoom point.
	  */
	  if (newSize.width <= visible.size.width)
	    {
	      visible.origin.x = 0;
	    }
	  else if (oldSize.width <= visible.size.width)
	    {
	      visible.origin.x = (newSize.width - visible.size.width) / 2;
	    }
	  else
	    {
	      scale = newSize.width / oldSize.width;
	      visible.origin.x += zoomPoint.x * (scale - 1);
	    }

	  if (newSize.height <= visible.size.height)
	    {
	      visible.origin.y = 0;
	    }
	  else if (oldSize.height <= visible.size.height)
	    {
	      visible.origin.y = (newSize.height - visible.size.height) / 2;
	    }
	  else
	    {
	      scale = newSize.height / oldSize.height;
	      visible.origin.y += zoomPoint.y * (scale - 1);
	    }
	}
      [[scroll contentView] scrollToPoint: visible.origin];
    }
  [imageView setImage: anImage];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  if ([zoomButt state] == NSOnState)
    {
      NSView *documentView = [scroll documentView];
      NSPoint pointWinCoord = [theEvent locationInWindow];

      zoomPoint = [documentView convertPoint:pointWinCoord fromView:nil];
      if([theEvent type] == NSLeftMouseDown)
        {
          if ([theEvent modifierFlags] & NSControlKeyMask)
            {
              isZooming = YES;
              [zoomStepper setIntValue: [zoomStepper intValue] - [zoomStepper increment]];
              [self setZoomValue: zoomStepper];
            }
          else
            {
	      isZooming = YES;
              [zoomStepper setIntValue: [zoomStepper intValue] + [zoomStepper increment]];
              [self setZoomValue: zoomStepper];
            }
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  if([handButt state] == NSOnState)
    {
      if ([theEvent type] == NSLeftMouseDragged)
      {
        float deltaX, deltaY;
	NSPoint oldPoint;
	NSClipView *contentView;
        
        deltaX = [theEvent deltaX];
        deltaY = [theEvent deltaY];

	contentView = [scroll contentView];
	oldPoint = [contentView bounds].origin;
        [contentView scrollToPoint: NSMakePoint(oldPoint.x - deltaX, oldPoint.y - deltaY)];
      	[scroll setNeedsDisplay: YES];
      }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
}

/* --- ACTIONS --- */

- (IBAction)selectZoomButt:(id)sender
{
  [handButt setState: NSOffState];
}

- (IBAction)selectHandButt:(id)sender
{
  [zoomButt setState: NSOffState];
}


- (IBAction)nextPage:(id)sender
{
  [[self document] nextPage];
}

- (IBAction)previousPage:(id)sender
{
  [[self document] previousPage];
}

- (IBAction)setAntiAlias:(id)sender
{
  NSUserDefaults *defaults;

  [[self document] regeneratePage];
  defaults = [NSUserDefaults standardUserDefaults];

  if ([antiAliasSwitch state] == NSOnState)
    [defaults setBool: YES forKey: ANTI_ALIASING_KEY];
  else 
    [defaults setBool: NO forKey: ANTI_ALIASING_KEY];
}

- (IBAction)setZoomValue:(id)sender
{
  int value = [sender intValue];
  [(GSPdfDocument*)[self document] setZoomValue: value];
  [zoomField setStringValue: [NSString stringWithFormat: @"%i", value]];		
}

@end



