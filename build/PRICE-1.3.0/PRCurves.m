//
//  PRCurves.m
//  PRICE
//
//  Created by Riccardo Mottola on 07/08/11.
//  Copyright 2011-2014 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCurves.h"


@implementation PRCurves

/*
 * Paramters order:
 *   Luminance Array
 *   Red Array
 *   Green Array
 *   Blue Array
 */
- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
  PRImage *retImage;
  NSArray *array;
  unsigned arrayL[UCHAR_MAX + 1];
  unsigned arrayR[UCHAR_MAX + 1];
  unsigned arrayG[UCHAR_MAX + 1];
  unsigned arrayB[UCHAR_MAX + 1];
  unsigned i;
  
  if ([parameters count] != 1 && [parameters count] != 3)
    {
      NSLog(@"inconsistent number of parametetrs: %u", (unsigned int)[parameters count]);
      return nil;
    }


  if ([parameters count] == 1)
    {
      array = [parameters objectAtIndex:0];
      if ([array count] > 0)
	{
	  if ([array count] == UCHAR_MAX+1)
	    {
	      for (i = 0; i <= UCHAR_MAX; i++)
		arrayL[i] = [(NSNumber *)[array objectAtIndex: i] unsignedIntValue];
	    }
	  else
	    {
	      NSLog(@"Incompatible size of parameter array: %u", (unsigned int)[array count]);
	    }
	}
      retImage = [self adjustImage: image :arrayL :NULL :NULL :NULL];
    }
  else
    {
      array = [parameters objectAtIndex:0];
      if ([array count] > 0)
	{
	  if ([array count] == UCHAR_MAX+1)
	    {
	      for (i = 0; i <= UCHAR_MAX; i++)
		arrayR[i] = [(NSNumber *)[array objectAtIndex: i] unsignedIntValue];
	    }
	  else
	    {
	      NSLog(@"Incompatible size of parameter array: %u", (unsigned int)[array count]);
	    }
	}
      array = [parameters objectAtIndex:1];
      if ([array count] > 0)
	{
	  if ([array count] == UCHAR_MAX+1)
	    {
	      for (i = 0; i <= UCHAR_MAX; i++)
		arrayG[i] = [(NSNumber *)[array objectAtIndex: i] unsignedIntValue];
	    }
	  else
	    {
	      NSLog(@"Incompatible size of parameter array: %u", (unsigned int)[array count]);
	    }
	}
      array = [parameters objectAtIndex:2];
      if ([array count] > 0)
	{
	  if ([array count] == UCHAR_MAX+1)
	    {
	      for (i = 0; i <= UCHAR_MAX; i++)
		arrayB[i] = [(NSNumber *)[array objectAtIndex: i] unsignedIntValue];
	    }
	  else
	    {
	      NSLog(@"Incompatible size of parameter array: %u", (unsigned int)[array count]);
	    }
	}
      retImage = [self adjustImage: image :arrayL :arrayR :arrayG :arrayB];
    }
  return retImage;
}

- (NSString *)actionName
{
  return @"Curves";
}

- (PRImage *)adjustImage :(PRImage *)srcImage :(unsigned *)arrayL :(unsigned *)arrayR :(unsigned *)arrayG :(unsigned *)arrayB
{
  NSBitmapImageRep *srcImageRep;
  PRImage *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger w, h;
  NSInteger x, y;
  unsigned char *srcData;
  unsigned char *destData;
  int tempValue;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  NSInteger srcBytesPerRow;
  NSInteger destBytesPerRow;
  NSInteger srcBytesPerPixel;
  NSInteger destBytesPerPixel;
  BOOL hasAlpha;
  
  
  /* get source image representation and associated information */
  srcImageRep = [srcImage bitmapRep];
  
  w = [srcImageRep pixelsWide];
  h = [srcImageRep pixelsHigh];
  srcBytesPerRow = [srcImageRep bytesPerRow];
  srcSamplesPerPixel = [srcImageRep samplesPerPixel];
  srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
  
  /* check bith depth and color/greyscale image */
  hasAlpha = [srcImageRep hasAlpha];

  destSamplesPerPixel = srcSamplesPerPixel;  
  /* allocate destination image and its representation */
  destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
  destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:w
                              pixelsHigh:h
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:destSamplesPerPixel
                                hasAlpha:hasAlpha
                                isPlanar:NO
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:0
                            bitsPerPixel:0];
  srcData = [srcImageRep bitmapData];
  destData = [destImageRep bitmapData];
  destBytesPerRow = [destImageRep bytesPerRow];
  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
  
  if ([srcImage hasColor])
    {
      for (y = 0; y < h; y++)
	for (x = 0; x < w; x++)
	  {
	    tempValue = arrayR[srcData[srcBytesPerRow*y + srcBytesPerPixel*x]];
	    destData[destBytesPerRow*y + destBytesPerPixel*x] = tempValue;
	
	    tempValue = arrayG[srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 1]];
	    destData[destBytesPerRow*y + destBytesPerPixel*x + 1] = tempValue;
	
	    tempValue = arrayB[srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 2]];
	    destData[destBytesPerRow*y + destBytesPerPixel*x + 2] = tempValue;
            
            if (hasAlpha)
              destData[destBytesPerRow*y + destBytesPerPixel*x + 3] = srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 3];
	  }
    }
  else
    {
      for (y = 0; y < h; y++)
	for (x = 0; x < w; x++)
	  {
	    destData[destBytesPerRow*y + destBytesPerPixel*x] = arrayL[srcData[srcBytesPerRow*y + srcBytesPerPixel*x]];
          
            if (hasAlpha)
              destData[destBytesPerRow*y + destBytesPerPixel*x + 1] = srcData[srcBytesPerRow*y + srcBytesPerPixel*x + 1];
	  }
    }
      
  [destImage setBitmapRep:destImageRep];
  [destImageRep release];
  [destImage autorelease];
  return destImage;  
}

- (BOOL)displayProgress
{
  return NO;
}

@end
