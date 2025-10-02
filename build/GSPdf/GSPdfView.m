/*
   Project: GSPdf

   Copyright (C) 2010 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2010-07-03 23:16:10 +0200 by multix

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

#import <AppKit/NSEvent.h>
#import "GSPdfView.h"
#import "GSPdfDocWin.h"

#ifndef GNUSTEP
#import "GNUstep.h"
#endif

/* we define our own constants */
enum
{
  NSEscapeCharacter = 0x001b,
  NSSpaceCharacter = 0x0020
};

@implementation GSPdfView

- (void)setDelegate: (id)aDelegate
{
  delegate = aDelegate;
}

/* ---- Mouse event methods ---- */

- (void)mouseDown:(NSEvent *)theEvent
{
  //  [super mouseDown: theEvent];
  [delegate mouseDown: theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  [super mouseDragged: theEvent];
  [delegate mouseDragged: theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  [super mouseUp: theEvent];
  [delegate mouseUp: theEvent];
}

/* ---- Key event methods ---- */

/** respond to key equivalents which are not bound do menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
  NSString *keyStr;
  unichar keyCh;
  unsigned int modifierFlags;

#ifdef __APPLE__
/* Apple is definitively broken here and on all versions tested it returns for the arrow key
    also a KeyUp event, which it should not, as the Event is specified to be keyDown */
    if ([theEvent type] == NSKeyUp)
        return [super performKeyEquivalent:theEvent];
#endif

    keyCh = 0x0;
    keyStr = [theEvent characters];
    if ([keyStr length] > 0)
      keyCh = [keyStr characterAtIndex:0];
    modifierFlags = [theEvent modifierFlags];

    if (keyCh == NSEscapeCharacter)
      {
	//        [delegate setFullScreen:theEvent];
        return YES;
      }
    else if (keyCh == NSLeftArrowFunctionKey || keyCh == NSUpArrowFunctionKey)
      {
        [delegate previousPage:theEvent];
        return YES;
      }
    else if (keyCh == NSRightArrowFunctionKey || keyCh == NSDownArrowFunctionKey || keyCh == NSSpaceCharacter)
      {
        [delegate nextPage:theEvent];
        return YES;
      }
    else
      NSLog(@"keyCh %x", keyCh);    
    return [super performKeyEquivalent:theEvent];
}

- (void)updatePrintInfo: (NSPrintInfo *)pi;
{
  float lm, rm;
  NSRect pageRect;

  if (pi == nil)
    {
      NSLog(@"invalid printer information");
      return;
    }
  lm = [pi leftMargin];
  rm = [pi rightMargin];
  if (lm <= 0 || rm <= 0 || [pi paperSize].width <= 0 || [pi paperSize].height <= 0)
    {
      NSLog(@"invalid margin / paper size information. %f %f %f %f", lm, rm,[pi paperSize].width, [pi paperSize].height);
      return;
    }
  pageRect = NSMakeRect(0,0,[pi paperSize].width, [pi paperSize].height);

  [self setFrame: pageRect];
  [self setNeedsDisplay:YES];
}

@end
