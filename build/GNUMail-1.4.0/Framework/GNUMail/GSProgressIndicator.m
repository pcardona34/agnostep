/*
**
**  GSProgressIndicator.m
**
**  Copyright (c) 2018 Riccardo Mottola
**
**  Author: Riccardo Mottola <rm@gnu.org>
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

#import "GSProgressIndicator.h"

#import <AppKit/NSImage.h>

@implementation GSProgressIndicator

#define IMAGES 8

- (void)dealloc
{
  [images release];
  [super dealloc];
}

- (void)_commonInit
{
  unsigned i;
      
  images = [NSMutableArray new];
      
  for (i = 1; i <= IMAGES; i++)
    {
      NSString *imname = [NSString stringWithFormat: @"anim-logo-%u.tiff", i];
      NSImage *image = [NSImage imageNamed: imname];
      [images addObject: image];
    }
      
  animating = NO;
}


- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self)
    {
      [self _commonInit];
    }
  return self;
}

- (id)initWithFrame:(NSRect)frameRect 
{
  if (self)
    {
      [self _commonInit];
    }
  
  return self;
}

- (void)startAnimation:(id)sender
{
  index = 0;
  animating = YES;
  progTimer = [NSTimer scheduledTimerWithTimeInterval: _animationDelay
                                               target: self selector: @selector(animate:) 
                                             userInfo: nil repeats: YES];
}

- (void)stopAnimation:(id)sender
{
  if (animating)
    {
      animating = NO;
      if (progTimer && [progTimer isValid])
        [progTimer invalidate];
          
      [self setNeedsDisplay: YES];
    }
}

- (void)animate:(id)sender
{
  [self setNeedsDisplay: YES];
  index++;
  if (index == [images count])
    index = 0;
}

- (void) drawRect: (NSRect)rect
{
  if (animating)
    {
      NSImage *img;
  
      img = [images objectAtIndex: index];

      [img drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

@end
