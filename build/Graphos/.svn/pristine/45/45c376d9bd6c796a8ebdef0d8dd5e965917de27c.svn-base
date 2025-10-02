/*
 Project: Graphos
 GRDrawableObject.m

 Copyright (C) 2008-2018 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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

#import <AppKit/NSGraphics.h>
#import "GRDrawableObject.h"
#import "GRObjectEditor.h"


@implementation GRDrawableObject

- (void)dealloc
{
    [editor release];
    [strokeColor release];
    [fillColor release];
    [super dealloc];
}

- (GRObjectEditor *)allocEditor
{
  return [[GRObjectEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super init];
  if(self)
    {
      NSColor *newColor;
      id val;

      docView = aView;
      zmFactor = zf;
      stroked = YES;
      filled = NO;
      visible = YES;
      locked = NO;
      strokeColor = [[[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
      fillColor = [[[NSColor whiteColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
      
      val = [properties objectForKey: @"stroked"];
      if (val != nil)
	[self setStroked: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
      if (newColor != nil)
	[self setStrokeColor: newColor];

      val = [properties objectForKey: @"filled"];
      if (val != nil)
	[self setFilled: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
      if (newColor != nil)
	[self setFillColor: newColor];

      val = [properties objectForKey: @"visible"];
      if (val)	
	visible = [val boolValue];
      
      val = [properties objectForKey: @"locked"];
      if (val)
	locked = [val boolValue];

      editor = [self allocEditor];
    }
  return self;
}

/** initializes all parameters from a description dictionary */
- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  self = [super init];
  if(self)
    {
      NSArray *linearr;
      NSString *str;
      id obj;
      CGFloat strokeCol[4];
      CGFloat fillCol[4];
      CGFloat strokeAlpha;
      CGFloat fillAlpha;

      editor = [self allocEditor];
      
      docView = aView;
      zmFactor = zf;

      obj = [description objectForKey: @"stroked"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      stroked = [obj boolValue];
      strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
      str = [description objectForKey: @"strokecolor"];
      linearr = [str componentsSeparatedByString: @" "];
      if ([linearr count] == 3)
	{
	  strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  strokeColor = [NSColor colorWithCalibratedRed: strokeCol[0]
						  green: strokeCol[1]
						   blue: strokeCol[2]
						  alpha: strokeAlpha];
	  [strokeColor retain];
	}
      else
	{
	  strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
	  strokeColor = [NSColor colorWithDeviceCyan: strokeCol[0]
					     magenta: strokeCol[1]
					      yellow: strokeCol[2]
					       black: strokeCol[3]
					       alpha: strokeAlpha];
	  strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	  }
      obj = [description objectForKey: @"filled"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      filled = [obj boolValue];
      fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
      str = [description objectForKey: @"fillcolor"];
      linearr = [str componentsSeparatedByString: @" "];
      if ([linearr count] == 3)
	{
	  fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  fillColor = [NSColor colorWithCalibratedRed: fillCol[0]
						green: fillCol[1]
						 blue: fillCol[2]
						alpha: fillAlpha];
	  [fillColor retain];
	}
      else
	{
	  fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
	  fillColor = [NSColor colorWithDeviceCyan: fillCol[0]
					   magenta: fillCol[1]
					    yellow: fillCol[2]
					     black: fillCol[3]
					     alpha: fillAlpha];
	  fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	}
      obj = [description objectForKey: @"visible"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      visible = [obj boolValue];
      obj = [description objectForKey: @"locked"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      locked = [obj boolValue];
    }
  return self;
}


- (NSDictionary *)objectDescription
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
    return nil;
}


- (id)copyWithZone:(NSZone *)zone
{
  GRDrawableObject *objCopy;
  GRObjectEditor *editorCopy;

  objCopy = [[[self class] allocWithZone:zone] init];

  objCopy->visible = visible;
  objCopy->locked = locked;
  objCopy->zmFactor = zmFactor;
  objCopy->stroked = stroked;
  objCopy->filled = filled;
    
  editorCopy = [[self editor] copy];
  [editorCopy setObject: objCopy];
    
  objCopy->docView = [self view];
  objCopy->editor = editorCopy;

  objCopy->strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
  objCopy->fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
    
  return objCopy;
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
    return NO;
}

- (GRDocView *)view
{
    return docView;
}

- (GRObjectEditor *)editor
{
    return editor;
}

- (BOOL)visible
{
    return visible;
}

- (void)setVisible:(BOOL)value
{
    visible = value;
    if(!visible)
        [editor unselect];
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
}

- (CGFloat)zoomFactor
{
  return zmFactor;
}

- (void)setZoomFactor:(CGFloat)f
{
    zmFactor = f;
}

- (void)setStrokeColor:(NSColor *)c
{
  [strokeColor release];
  strokeColor = [[c colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
}

- (NSColor *)strokeColor
{
    return strokeColor;
}

- (void)setFillColor:(NSColor *)c
{
  [fillColor release];
  fillColor = [[c colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
}

- (NSColor *)fillColor
{
    return fillColor;
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}

- (void)draw
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
}


@end
