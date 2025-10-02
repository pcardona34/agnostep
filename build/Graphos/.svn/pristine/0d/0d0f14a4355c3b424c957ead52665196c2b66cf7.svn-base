/*
 Project: Graphos
 GRText.m

 Copyright (C) 2000-2018 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

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


#import "GRText.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "Graphos.h"
#import "GRTextEditor.h"

@implementation GRText

- (GRObjectEditor *)allocEditor
{
  return [[GRTextEditor alloc] initEditor:self];
}

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(CGFloat)zf
  withProperties:(NSDictionary *) properties
      openEditor:(BOOL)openedit
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      int result;
      NSString *s;
      NSFont *f;
      NSParagraphStyle *parStyle;
      NSDictionary *parAttr;
      
      pos = p;
      selRect = NSMakeRect(pos.x - 3, pos.y - 3, 6, 6);
      rotation = 0;
      scalex = 1;
      scaley = 1;

      s = [properties objectForKey:@"string"];
      if (nil == s)
        s = @"";
      f = [properties objectForKey:@"font"];
      if (nil == f)
        f = [NSFont systemFontOfSize:12];
      parStyle = [properties objectForKey:@"paragraphstyle"];
      if (nil == parStyle)
        parStyle = [NSParagraphStyle defaultParagraphStyle];
      parAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                f, NSFontAttributeName,
                              parStyle, NSParagraphStyleAttributeName, nil];
      [self setString:s attributes:parAttr];

      if(openedit)
	{
	  [(GRTextEditor *)editor setPoint: pos
				withString: nil
				attributes: nil];
	  result = [(GRTextEditor *)editor runModal];
	  if(result == NSAlertDefaultReturn)
	    {
	      [self setString: [[(GRTextEditor *)editor editorView] textString]
		   attributes: [[(GRTextEditor *)editor editorView] textAttributes]];
	    }
	  else
	    {
	      [self release];
	      return nil;
	    }
        }
    }
  return self;
}

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{  
  self = [super initFromData:description inView:aView zoomFactor:zf];
  if(self)
    {
      NSString *s;
      NSString *fontname;
      CGFloat fsize;
      NSFont *fontObj;
      float parspace;
      NSTextAlignment align;          
      NSMutableParagraphStyle *style;
      NSDictionary *parAttr;
      id obj;
          
      s = [description objectForKey: @"string"];

      pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
			[[description objectForKey: @"posy"]  floatValue]);

      fontname = [description objectForKey: @"fontname"];
      fsize = [[description objectForKey: @"fontsize"] floatValue];
      if (fsize == 0)
	{
	  NSLog(@"font size invalid");
	  fsize = 12.0;
	}
      fontObj = [NSFont fontWithName: fontname size: fsize];
      if (nil == fontObj)
	{
	  NSLog(@"font %@ of size %f not found using system", fontname, fsize);
	  fontObj = [NSFont systemFontOfSize:fsize];
	}

      align = [[description objectForKey: @"txtalign"] intValue];
      parspace = [[description objectForKey: @"parspace"] floatValue];
      style = [[NSMutableParagraphStyle alloc] init];
      [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
      [style setAlignment: align];
      [style setParagraphSpacing: parspace];
      parAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                fontObj, NSFontAttributeName,
                              style, NSParagraphStyleAttributeName, nil];
      [self setString:s attributes:parAttr];
      [style release];
  

      obj = [description objectForKey: @"rotation"];
      if (obj)
	rotation = [obj floatValue];
      
      scalex = [[description objectForKey: @"scalex"] floatValue];
      scaley = [[description objectForKey: @"scaley"] floatValue];
    }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRText *objCopy;
  
  objCopy = [super copyWithZone:zone];
  
  objCopy->str = [str copy];
  objCopy->parAttributes = [parAttributes copy];

  objCopy->pos = NSMakePoint(pos.x, pos.y);
  objCopy->size = NSMakeSize(size.width, size.height);
  objCopy->bounds = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
  objCopy->rotation = rotation;
  objCopy->scalex = scalex;
  objCopy->scaley = scaley;
  objCopy->selRect = NSMakeRect(selRect.origin.x, selRect.origin.y, selRect.size.width, selRect.size.height);
  
  return objCopy;
}



- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *s;
    float strokeCol[3];
    float fillCol[3];
    float strokeAlpha;
    float fillAlpha;
    float parspace;
    NSTextAlignment align;
    NSFont *font;
    float fsize;
    NSParagraphStyle *pstyle;
    
    font = [parAttributes objectForKey: NSFontAttributeName];
    fsize = [font pointSize];
    pstyle = [parAttributes objectForKey: NSParagraphStyleAttributeName];
    parspace = [pstyle paragraphSpacing];
    align = [pstyle alignment];


    strokeCol[0] = [strokeColor redComponent];
    strokeCol[1] = [strokeColor greenComponent];
    strokeCol[2] = [strokeColor blueComponent];
    strokeAlpha = [strokeColor alphaComponent];

    fillCol[0] = [fillColor redComponent];
    fillCol[1] = [fillColor greenComponent];
    fillCol[2] = [fillColor blueComponent];
    fillAlpha = [fillColor alphaComponent];

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"text" forKey: @"type"];

    [dict setObject: str forKey: @"string"];
    s = [NSString stringWithFormat: @"%.3f", pos.x];
    [dict setObject: s forKey: @"posx"];
    s = [NSString stringWithFormat: @"%.3f", pos.y];
    [dict setObject: s forKey: @"posy"];
    s = [font fontName];
    [dict setObject: s forKey: @"fontname"];
    s = [NSString stringWithFormat: @"%.3f", fsize];
    [dict setObject: s forKey: @"fontsize"];
    s = [NSString stringWithFormat: @"%.3f", parspace];
    [dict setObject: s forKey: @"parspace"];
    s = [NSString stringWithFormat: @"%i", (int)align];
    [dict setObject: s forKey: @"txtalign"];
    s = [NSString stringWithFormat: @"%.3f", scalex];
    [dict setObject: s forKey: @"scalex"];
    s = [NSString stringWithFormat: @"%.3f", scaley];
    [dict setObject: s forKey: @"scaley"];
    s = [NSString stringWithFormat: @"%.3f", rotation];
    [dict setObject: s forKey: @"rotation"];
    [dict setObject: [NSNumber numberWithBool:stroked] forKey: @"stroked"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        strokeCol[0], strokeCol[1], strokeCol[2]];
    [dict setObject: s forKey: @"strokecolor"];
    s = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: s forKey: @"strokealpha"];
    [dict setObject: [NSNumber numberWithBool: filled] forKey: @"filled"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        fillCol[0], fillCol[1], fillCol[2]];
    [dict setObject: s forKey: @"fillcolor"];
    s = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: s forKey: @"fillalpha"];
    [dict setObject: [NSNumber numberWithBool: visible] forKey: @"visible"];
    [dict setObject: [NSNumber numberWithBool: locked] forKey: @"locked"];

    return dict;
}


- (void)dealloc
{
  [str release];
  [parAttributes release];
  [super dealloc];
}

- (void)setString:(NSString *)aString attributes:(NSDictionary *)attrs
{
  ASSIGN(str, aString);
  ASSIGN(parAttributes, attrs);
  
  size = NSMakeSize(0, 0);
  if (str)
    size = [str sizeWithAttributes: attrs];
  bounds = NSMakeRect(pos.x, pos.y, size.width, size.height);
}

// maybe should be moved into the editor
- (void)edit
{
    int result;

    [(GRTextEditor *)editor setPoint: pos
          withString: str
          attributes: parAttributes];
    result = [(GRTextEditor *)editor runModal];
    if(result == NSAlertDefaultReturn)
        [self setString: [[(GRTextEditor *)editor editorView] textString]
             attributes: [[(GRTextEditor *)editor editorView] textAttributes]];
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
    if(pointInRect(bounds, p) || pointInRect(selRect, p))
        return YES;
    return NO;
}

- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
    pos.x += p.x;
    pos.y += p.y;
    bounds = NSMakeRect(pos.x, pos.y, size.width, size.height);
    selRect = NSMakeRect(pos.x - 3, pos.y - 3, 6, 6);
}

- (void)setZoomFactor:(CGFloat)f
{
    zmFactor = f;
}

- (void)setScalex:(float)x scaley:(float)y
{
    scalex = x;
    scaley = y;
}

- (void)setRotation:(float)r
{
    rotation = r;
}

- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    if(!locked)
        [editor unselect];
    else
        [editor selectAsGroup];
}



- (NSBezierPath *) makePathFromString: (NSString *) aString
                              forFont: (NSFont *) aFont
                              atPoint: (NSPoint) aPoint
{
    NSTextView *textview;
    NSGlyph *glyphs;
    NSBezierPath *path;
    NSRange range;
    NSLayoutManager *layoutManager;


    textview = [[NSTextView alloc] init];

    [textview setString: aString];
    [textview setFont: aFont];

    layoutManager = [textview layoutManager];

    range = [layoutManager glyphRangeForCharacterRange:
        NSMakeRange (0, [aString length])
                                  actualCharacterRange: NULL];

    glyphs = (NSGlyph *) malloc (sizeof(NSGlyph) * (range.length * 2));
    [layoutManager getGlyphs: glyphs  range: range];

    
    path = [NSBezierPath bezierPath];

    [path moveToPoint: aPoint];
    [path appendBezierPathWithGlyphs: glyphs
                               count: range.length  inFont: aFont];

    free (glyphs);
    [textview release];

    return (path);
}

- (void)draw
{
  NSArray *lines;
  float baselny;
  NSInteger i;
  NSBezierPath *bezp;
  NSMutableParagraphStyle *style;
  CGFloat parSpacing;
  NSDictionary *strAttr;
  NSFont *font;
  NSFont *tempFont;
  CGFloat fontSize;
  NSPoint posZ;
  NSRect boundsZ;
  NSSize sizeZ;
  
  if(!visible)
    return;

  posZ = pos;
  font = [parAttributes objectForKey: NSFontAttributeName];
  fontSize = [font pointSize];
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    {
      posZ = GRpointZoom(pos, zmFactor);
      fontSize = fontSize * zmFactor;
    }
  
  NSAssert (font != nil, @"Font object nil during drawing");
  style = [parAttributes objectForKey: NSParagraphStyleAttributeName];
  parSpacing = [style paragraphSpacing];
  
  tempFont = [NSFont fontWithName:[font fontName] size:fontSize];
  if (tempFont == nil)
    {
      NSLog(@"temp font obtained from %@ zoomFactor: %f is nil", font, zmFactor);
      tempFont = font;
    }
  if (filled)
    {
      strAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
				 tempFont, NSFontAttributeName,
			       strokeColor, NSForegroundColorAttributeName,
			       fillColor, NSBackgroundColorAttributeName,
			       style, NSParagraphStyleAttributeName, nil] retain];
    }
  else
    {
      strAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
				 tempFont, NSFontAttributeName,
			       strokeColor, NSForegroundColorAttributeName,
			       style, NSParagraphStyleAttributeName, nil] retain];
    }
  baselny = posZ.y;
  
  sizeZ  = [str sizeWithAttributes: strAttr];
  boundsZ = NSMakeRect(posZ.x, posZ.y, sizeZ.width, sizeZ.height);
  
  [str drawInRect:boundsZ withAttributes:strAttr];

  if ([[NSGraphicsContext currentContext] isDrawingToScreen] && [editor isSelected])
    {
      NSRect selRectZ;
        
      selRectZ = NSMakeRect(selRect.origin.x * zmFactor, selRect.origin.y * zmFactor, selRect.size.width, selRect.size.height);
      
      bezp = [NSBezierPath bezierPath];
      [bezp setLineWidth:0];
      if([str length] > 0)
	{
	  lines = [str componentsSeparatedByString: @"\n"];
	  for(i = 0; i < [lines count]; i++)
	    {
	      NSString *line;
	      NSSize lineSize;
	      
	      line = [lines objectAtIndex: i];
	      lineSize = [line sizeWithAttributes:strAttr]; 
	  
	      [[NSColor blackColor] set];
	      [bezp moveToPoint:NSMakePoint(posZ.x, baselny)];
	      [bezp lineToPoint:NSMakePoint(posZ.x + bounds.size.width*zmFactor, baselny)];
	      
	      baselny += lineSize.height + parSpacing;
	    }
	  
	  [bezp stroke];
	  [[NSColor blackColor] set];
	  NSRectFill(selRectZ);
	}
    }
  [strAttr release];
} 

@end
