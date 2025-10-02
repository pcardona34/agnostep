//
//  PRCurvesView.h
//  PRICE
//
//  Created by Riccardo Mottola on 7 August 2011.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import <Foundation/Foundation.h>
#import <AppKit/NSView.h>
#import <AppKit/NSBezierPath.h>
#import "PRCurvesPath.h"

@class PRCCurves;
@class PRImage;

@interface PRCurvesView : NSView
{
  PRCCurves *controller;
  
  BOOL hasColor;
  unsigned pixNum;
  float histogramScale;  /* scale factor for both in and out histograms */

  unsigned long int histogramDenormL[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormR[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormG[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  unsigned long int histogramDenormB[UCHAR_MAX+1]; /* not normalized pixel count for each level */
  
  float histogramL[UCHAR_MAX+1];            /* normalized histogram */
  float histogramR[UCHAR_MAX+1];            /* normalized histogram */
  float histogramG[UCHAR_MAX+1];            /* normalized histogram */
  float histogramB[UCHAR_MAX+1];            /* normalized histogram */

  float histogramLTr[UCHAR_MAX+1];          /* transformed histogram */
  float histogramRTr[UCHAR_MAX+1];          /* transformed histogram */
  float histogramGTr[UCHAR_MAX+1];          /* transformed histogram */
  float histogramBTr[UCHAR_MAX+1];          /* transformed histogram */
  
  
  PRCurvesPath *pathLumi;
  PRCurvesPath *pathR;
  PRCurvesPath *pathG;
  PRCurvesPath *pathB;
  
  NSBezierPath *pathHLumi;
  NSBezierPath *pathHR;
  NSBezierPath *pathHG;
  NSBezierPath *pathHB;
  NSBezierPath *pathHLumiTr;
  NSBezierPath *pathHRTr;
  NSBezierPath *pathHGTr;
  NSBezierPath *pathHBTr;

  @public unsigned funL[UCHAR_MAX+1];              /* mapped function */
}

-(BOOL)hasColor;

-(PRCurvesPath *)luminancePath;
-(PRCurvesPath *)redPath;
-(PRCurvesPath *)greenPath;
-(PRCurvesPath *)bluePath;

- (void)initPathLumi;
- (void)initPathR;
- (void)initPathG;
- (void)initPathB;

-(void)setBlackPoint: (int)value;
-(void)setWhitePoint: (int)value;

-(void)setFilterController: (PRCCurves *)aFilterController; 

-(void)calculateHistogram: (PRImage *)image;
-(void)calculateTransformedHistograms;

-(void)moveControlPoint:(NSPoint)cp ofCurve:(PRCurvesPath *)curveP;

@end
