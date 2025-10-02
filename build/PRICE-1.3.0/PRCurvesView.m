//
//  PRCurvesView.m
//  PRICE
//
//  Created by Riccardo Mottola on 7 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCurvesView.h"
#import "PRCCurves.h"


@implementation PRCurvesView

- (id)initWithFrame:(NSRect)frame
  {
    self = [super initWithFrame:frame];
    if (self)
      {
	hasColor = NO;

        pathLumi = [[PRCurvesPath alloc] init];
        pathR    = [[PRCurvesPath alloc] init];
        pathG    = [[PRCurvesPath alloc] init];
        pathB    = [[PRCurvesPath alloc] init];
        
	pathHLumi = [[NSBezierPath alloc] init];
	pathHR = [[NSBezierPath alloc] init];
	pathHG = [[NSBezierPath alloc] init];
	pathHB = [[NSBezierPath alloc] init];

	pathHLumiTr = [[NSBezierPath alloc] init];
	pathHRTr = [[NSBezierPath alloc] init];
	pathHGTr = [[NSBezierPath alloc] init];
	pathHBTr = [[NSBezierPath alloc] init];

	[self initPathLumi];
	[self initPathR];
	[self initPathG];
	[self initPathB];

	histogramScale = 0.5;
      }
    return self;
}

- (void)initPath:(PRCurvesPath *)p
{
  [p removeAllPoints];

  [p moveToPoint: NSMakePoint(0, 0)];
  [p curveToPoint: NSMakePoint(255, 255) controlPoint1: NSMakePoint(50, 0) controlPoint2: NSMakePoint(205, 255)];
}

- (void)initPathLumi
{
  [self initPath: pathLumi];
}

- (void)initPathR
{
  [self initPath: pathR];
}

- (void)initPathG
{
  [self initPath: pathG];
}

- (void)initPathB
{
  [self initPath: pathB];
}


- (void)dealloc
{
  [pathLumi release];
  [pathR release];
  [pathG release];
  [pathB release];

  [pathHLumi release];
  [pathHR release];
  [pathHG release];
  [pathHB release];

  [pathHLumiTr release];
  [pathHRTr release];
  [pathHGTr release];
  [pathHBTr release];
  
  [super dealloc];
}

-(BOOL)hasColor
{
  return hasColor;
}

-(void)setFilterController: (PRCCurves *)aFilterController;
{
  controller = aFilterController;
}

-(void)setBlackPoint: (int)value
{
  PRCurvesPath *path;
  NSBezierPathElement pe;
  NSPoint cp[3];
  float diff;
  
  path = pathLumi;
  pe = [path elementAtIndex: 0 associatedPoints: cp];
  diff = cp[0].x - (float)value;
  if ((pe == NSMoveToBezierPathElement) || (pe == NSLineToBezierPathElement))
    {
      /* if we have a straight line, we move the next control point too to preserve the curve */
      NSBezierPathElement pe2;
      NSPoint cp2[3];
      
      if  ([path elementCount] > 0)
	{
	  cp[0].x = (float)value;
	  pe2 = [path elementAtIndex: 1 associatedPoints: cp2];
	  if (pe2 == NSCurveToBezierPathElement)
	    {
	      NSLog(@"old cp2-0.x: %f", cp2[0].x);
	      cp2[0].x = cp2[0].x - diff;
	      NSLog(@"new cp2-0.x: %f", cp2[0].x);
	      [path setAssociatedPoints: cp2 atIndex: 1];
	    }
	}
      [path setAssociatedPoints: cp atIndex: 0];
    }
}

-(void)setWhitePoint: (int)value
{
  PRCurvesPath *path;
  NSBezierPathElement pe;
  NSPoint cp[3];
  
  path = pathLumi;
  pe = [path elementAtIndex: [path elementCount]-1 associatedPoints: cp];
  if (pe == NSMoveToBezierPathElement)
    cp[0].x = value;
  else if (pe == NSLineToBezierPathElement)
    cp[0].x = value;
  else if (pe == NSCurveToBezierPathElement)
    {
      float diff;
    
      diff = cp[2].x - (float)value;
      cp[2].x = value;
      cp[1].x = cp[1].x - diff;
      //cp[2].x = cp[2].x - diff;
    }
  [path setAssociatedPoints: cp atIndex: [path elementCount]-1];
}


-(PRCurvesPath *)luminancePath
{
  return pathLumi;
}

-(PRCurvesPath *)redPath
{
  return pathR;
}

-(PRCurvesPath *)greenPath
{
  return pathG;
}

-(PRCurvesPath *)bluePath
{
  return pathB;
}

- (void)drawRect:(NSRect)rect
{
  [[NSColor whiteColor] set];
  [NSBezierPath fillRect: [self bounds]];

  if (hasColor)
    {
      [[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0] set];
      [pathHR stroke];
      [[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:0.7] set];
      [pathHR fill];
      [[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0] set];
      [pathHRTr stroke];
      [[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:0.7] set];
      [pathHRTr fill];
      //      [[NSColor redColor] set];
      //      [pathR stroke];
  
      [[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:1.0] set];
      [pathHG stroke];
      [[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:0.7] set];
      [pathHG fill];
      [[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:1.0] set];
      [pathHGTr stroke];
      [[NSColor colorWithDeviceRed:0.0 green:1.0 blue:0.0 alpha:0.7] set];
      [pathHGTr fill];
      //      [[NSColor greenColor] set];
      //      [pathG stroke];

      [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0] set];
      [pathHB stroke];
      [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.7] set];
      [pathHB fill];
      [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0] set];
      [pathHBTr stroke];
      [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.7] set];
      [pathHBTr fill];
      //      [[NSColor blueColor] set];
      //      [pathB stroke];
      //  FIXME: temporary, until we have full RGB support
      [[NSColor blackColor] set];
      [pathLumi stroke];
    }
  else
    {
      [[NSColor colorWithDeviceWhite:0.5 alpha:1.0] set];
      [pathHLumi stroke];
      [[NSColor colorWithDeviceWhite:0.9 alpha:1.0] set];
      [pathHLumi fill];

      [[NSColor colorWithDeviceWhite:0.5 alpha:1.0] set];
      [pathHLumiTr stroke];
      [[NSColor colorWithDeviceWhite:0.9 alpha:1.0] set];
      [pathHLumiTr fill];
  
      [[NSColor blackColor] set];
      [pathLumi stroke];
    }

  
  
  /* boundaries */
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: [self bounds]];
}

-(void)calculateHistogram: (PRImage *)image;
{
  NSBitmapImageRep *theImageRep;
  unsigned char *theData;
  NSInteger w, h;
  NSInteger x, y;
  NSInteger i;
  NSInteger srcBytesPerPixel;
  NSInteger srcBytesPerRow;
  float maxHisto;
  unsigned viewHeight;
  float histoScale;
  
  
  /* get source image representation and associated information */
  theImageRep = [image bitmapRep];
  
  w = [theImageRep pixelsWide];
  h = [theImageRep pixelsHigh];
  pixNum = h * w;
  srcBytesPerRow = [theImageRep bytesPerRow];
  srcBytesPerPixel = [theImageRep bitsPerPixel] / 8;
  hasColor = [image hasColor];
  
  theData = [theImageRep bitmapData];
  
  if (hasColor)
    {
      /* calculate the histogram */
      for (i = 0; i <= UCHAR_MAX; i++)
	histogramDenormR[i] = histogramDenormG[i] = histogramDenormB[i] = 0;
      for (y = 0; y < h; y++)
	for (x = 0; x < w; x++)
	  {
	    histogramDenormR[theData[y*srcBytesPerRow + x*srcBytesPerPixel]]++;
	    histogramDenormG[theData[y*srcBytesPerRow + x*srcBytesPerPixel + 1]]++;
	    histogramDenormB[theData[y*srcBytesPerRow + x*srcBytesPerPixel + 2]]++;
	  }
        
      /* normalize histogram */
      /* calculate the maximum luminance as maxHisto */
      maxHisto = 0;
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  histogramR[i] = (float)histogramDenormR[i] / (float)pixNum;
	  histogramG[i] = (float)histogramDenormG[i] / (float)pixNum;
	  histogramB[i] = (float)histogramDenormB[i] / (float)pixNum;
	  if (histogramR[i] > maxHisto)
	    maxHisto = histogramR[i];
	  if (histogramG[i] > maxHisto)
	    maxHisto = histogramG[i];
	  if (histogramB[i] > maxHisto)
	    maxHisto = histogramB[i];
	}
    } 
  else
    {
      /* calculate the histogram */
      for (i = 0; i <= UCHAR_MAX; i++)
        histogramDenormL[i] = 0;
      for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
          histogramDenormL[theData[y*srcBytesPerRow + x*srcBytesPerPixel]]++;
      
      /* normalize histogram */
      maxHisto = 0;
      for (i = 0; i <= UCHAR_MAX; i++)
        {
	  histogramL[i] = (float)histogramDenormL[i] / (float)pixNum;
	  if (histogramL[i] > maxHisto)
	    maxHisto = histogramL[i];
        }
    }

  viewHeight = 256;
  NSLog(@"maxHisto L : %f for %u", maxHisto, pixNum);
  histoScale = (histogramScale * viewHeight) / maxHisto;
  if (hasColor)
    {
      [pathHR removeAllPoints];
      [pathHG removeAllPoints];
      [pathHB removeAllPoints];
      [pathHR moveToPoint: NSMakePoint(0, 0)];
      [pathHR moveToPoint: NSMakePoint(0, 0)];
      [pathHG moveToPoint: NSMakePoint(0, 0)];
      [pathHB moveToPoint: NSMakePoint(0, 0)];
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  [pathHR lineToPoint: NSMakePoint(i, histogramR[i] * histoScale)];
	  [pathHG lineToPoint: NSMakePoint(i, histogramG[i] * histoScale)];
	  [pathHB lineToPoint: NSMakePoint(i, histogramB[i] * histoScale)];
	}
      [pathHR lineToPoint: NSMakePoint(viewHeight, 0)];
      [pathHG lineToPoint: NSMakePoint(viewHeight, 0)];
      [pathHB lineToPoint: NSMakePoint(viewHeight, 0)];
    }
  else
    {
      [pathHLumi removeAllPoints];
      [pathHLumi moveToPoint: NSMakePoint(0, 0)];
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  [pathHLumi lineToPoint: NSMakePoint(i, histogramL[i] * histoScale)];
	}
      [pathHLumi lineToPoint: NSMakePoint(viewHeight, 0)];
    }

  NSLog(@"curves histogram initing ended");
}

-(void)calculateFunctions
{
  unsigned i;
  NSArray *curveL;
  
  curveL = [pathLumi values];
  for (i = 0; i <= UCHAR_MAX; i++)
    funL[i] = floor([[curveL objectAtIndex: i] floatValue]);
}

-(void)calculateTransformedHistograms
{
  unsigned long int histogramDenormLTr[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormRTr[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormGTr[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormBTr[UCHAR_MAX+1]; /* not normalized pixel count for each level */  
  unsigned i;
  float maxHisto;
  unsigned viewHeight;
  float histoScale;
  
  [self calculateFunctions];  

  /* zero histogram */
  for (i = 0; i <= UCHAR_MAX; i++)
    {
      histogramDenormLTr[i] = 0;
      histogramDenormRTr[i] = 0;
      histogramDenormGTr[i] = 0;
      histogramDenormBTr[i] = 0;
    }

  /* derive new histogram */
  for (i = 0; i <= UCHAR_MAX; i++)
    {
      histogramDenormLTr[funL[i]] += histogramDenormL[i];
      histogramDenormRTr[funL[i]] += histogramDenormR[i];
      histogramDenormGTr[funL[i]] += histogramDenormG[i];
      histogramDenormBTr[funL[i]] += histogramDenormB[i];
    }
  
  /* normalize histogram */
  if (hasColor)
    {
      maxHisto = 0;
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  histogramRTr[i] = (float)histogramDenormRTr[i] / (float)pixNum;
	  histogramGTr[i] = (float)histogramDenormGTr[i] / (float)pixNum;
	  histogramBTr[i] = (float)histogramDenormBTr[i] / (float)pixNum;
	  if (histogramRTr[i] > maxHisto)
	    maxHisto = histogramRTr[i];
	  if (histogramGTr[i] > maxHisto)
	    maxHisto = histogramGTr[i];
	  if (histogramBTr[i] > maxHisto)
	    maxHisto = histogramBTr[i];
	}
    }
  else
    {
      maxHisto = 0;
      for (i = 0; i <= UCHAR_MAX; i++)
	{
	  histogramLTr[i] = (float)histogramDenormLTr[i] / (float)pixNum;
	  if (histogramLTr[i] > maxHisto)
	    maxHisto = histogramLTr[i];
	}
    }
  
  viewHeight = 256;
  NSLog(@"transformed maxHisto L : %f for %u", maxHisto, pixNum);
  histoScale =  (histogramScale * viewHeight) / maxHisto;
  [pathHLumiTr removeAllPoints];
  [pathHLumiTr moveToPoint: NSMakePoint(0, viewHeight)];
  for (i = 0; i <= UCHAR_MAX; i++)
    {
      [pathHLumiTr lineToPoint: NSMakePoint(i, viewHeight-(histogramLTr[i] * histoScale))];
    }
  [pathHLumiTr lineToPoint: NSMakePoint(viewHeight, viewHeight)];

  [pathHRTr removeAllPoints];
  [pathHGTr removeAllPoints];
  [pathHBTr removeAllPoints];
  [pathHRTr moveToPoint: NSMakePoint(0, viewHeight)];
  [pathHGTr moveToPoint: NSMakePoint(0, viewHeight)];
  [pathHBTr moveToPoint: NSMakePoint(0, viewHeight)];
  for (i = 0; i <= UCHAR_MAX; i++)
    {
      [pathHRTr lineToPoint: NSMakePoint(i, viewHeight - (histogramRTr[i] * histoScale))];
      [pathHGTr lineToPoint: NSMakePoint(i, viewHeight - (histogramGTr[i] * histoScale))];
      [pathHBTr lineToPoint: NSMakePoint(i, viewHeight - (histogramBTr[i] * histoScale))];
    }
  [pathHRTr lineToPoint: NSMakePoint(viewHeight, viewHeight)];
  [pathHGTr lineToPoint: NSMakePoint(viewHeight, viewHeight)];
  [pathHBTr lineToPoint: NSMakePoint(viewHeight, viewHeight)];
}

- (void)moveControlPoint:(NSPoint)cp ofCurve:(PRCurvesPath *)curveP
{
  NSEvent *nextEvent;
  NSPoint oldP;

  oldP = cp;
  nextEvent = [[self window] nextEventMatchingMask:
                               NSLeftMouseUpMask | NSLeftMouseDraggedMask];
  if([nextEvent type] == NSLeftMouseDragged)
    {
      NSPoint p;

      do
        {
          p = [nextEvent locationInWindow];
          p = [self convertPoint:p fromView:nil];
          
          /* bounds checking */
          if (p.x < 0)
            p.x = 0;
          if (p.x > [self frame].size.width-1)
            p.x = [self frame].size.width-1;
          if (p.y < 0)
            p.y = 0;
          if (p.y > [self frame].size.height-1)
            p.y = [self frame].size.height-1;
          
          [curveP move:oldP toPoint:p];
          [controller recalculateCurves:self];
          [controller setBlackPointValue: (int)floor([curveP blackPoint].x)];
          [controller setWhitePointValue: (int)floor([curveP whitePoint].x)];
          [self setNeedsDisplay:YES];
          
          oldP = p;
          nextEvent = [[self window] nextEventMatchingMask:
                                       NSLeftMouseUpMask | NSLeftMouseDraggedMask];

        }
      while([nextEvent type] != NSLeftMouseUp);
    }
  [controller parametersChanged:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint p;
  unsigned count = [theEvent clickCount];

  p = [theEvent locationInWindow];
  p = [self convertPoint: p fromView: nil];

  if (count == 1)
    {
      if ([pathLumi pointOnControlHandle:p])
        {
          NSLog(@"Luminance path hit");
          [self moveControlPoint:p ofCurve:pathLumi];
        }
      else if ([pathR pointOnControlHandle:p])
        {
          NSLog(@"Red path hit");
          [self moveControlPoint:p ofCurve:pathR];
        }
      else if ([pathG pointOnControlHandle:p])
        {
          NSLog(@"Green path hit");
          [self moveControlPoint:p ofCurve:pathG];
        }
      else if ([pathB pointOnControlHandle:p])
        {
          NSLog(@"Blue path hit");
          [self moveControlPoint:p ofCurve:pathB];
        }
    }
  else
    {
      NSLog(@"click count: %d", count);
    }
}

@end
