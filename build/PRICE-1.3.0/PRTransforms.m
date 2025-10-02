//
//  PRTransforms.m
//  PRICE
//
//  Created by Riccardo Mottola on Mon Dec 23 2002.
//  Copyright (c) 2002-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRTransforms.h"
#import "PRCProgress.h"

@implementation PRTransforms

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    PRImage *retImage;

    switch ([[parameters objectAtIndex:0] intValue])
    {
        case TRANSPOSE:
            retImage = [self transposeImage:image];
            break;
        case ROTATE90:
            retImage = [self rotateImage90:image];
            break;
        case ROTATE180:
            retImage = [self rotateImage180:image];
            break;
        case ROTATE270:
            retImage = [self rotateImage270:image];
            break;
        case FLIP_VERT:
            retImage = [self flipImageVert:image];
            break;
        case FLIP_HORIZ:
            retImage = [self flipImageHoriz:image];
            break;
        default:
            retImage = nil;
    }
    return retImage;
}

- (void)setActionName:(NSString *)name
{
    actionName = name;
}

- (NSString *)actionName
{
    return actionName;
}

- (PRImage *)transposeImage:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger w, h;
    NSInteger x, y;
    int s; /* sample */
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger srcSamplesPerPixel;
    NSInteger destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;

    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    
    /* execute the actual transposition */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(h, w)]; /* we swap h and w */
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:h
                          pixelsHigh:w
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerPixel *  y + destBytesPerRow * x;
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }

    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}


- (PRImage *)rotateImage90:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger          w, h;
    NSInteger          x, y;
    int s; /* sample */
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger          srcSamplesPerPixel;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;


    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    
    /* execute the actual rotation */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(h, w)]; /* we swap h and w */
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:h
                          pixelsHigh:w
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
   
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * (w-x-1) + destBytesPerPixel * y;
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }
            
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

- (PRImage *)rotateImage180:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger          w, h;
    NSInteger          x, y;
    int s; /* sample */
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger          srcSamplesPerPixel;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;
    
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;    
    
    /* execute the actual rotation */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:w
                          pixelsHigh:h
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * (h-y-1) + destBytesPerPixel * (w-x-1);
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }
            
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}


- (PRImage *)rotateImage270:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger          w, h;
    NSInteger          x, y;
    int s;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger          srcSamplesPerPixel;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;
    
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;   
    
    /* execute the actual rotation */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(h, w)]; /* we swap h and w */
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:h
                          pixelsHigh:w
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * x + destBytesPerPixel * (h-y-1);
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }
            
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

- (PRImage *)flipImageVert:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger          w, h;
    NSInteger          x, y;
    int s;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger          srcSamplesPerPixel;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;
    
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8; 
    
    /* execute the actual rotation */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:w
                          pixelsHigh:h
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * (h-y-1) + destBytesPerPixel * x;
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }

    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

- (PRImage *)flipImageHoriz:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    NSInteger w, h;
    NSInteger x, y;
    int s;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    NSInteger          srcSamplesPerPixel;
    NSInteger          destSamplesPerPixel;
    register NSInteger srcBytesPerPixel;
    register NSInteger destBytesPerPixel;
    register NSInteger srcBytesPerRow;
    register NSInteger destBytesPerRow;
    
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;   
    
    /* execute the actual rotation */
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:w
                          pixelsHigh:h
                       bitsPerSample:[srcImageRep bitsPerSample]
                     samplesPerPixel:destSamplesPerPixel
                            hasAlpha:[srcImageRep hasAlpha]
                            isPlanar:NO
                      colorSpaceName:[srcImageRep colorSpaceName]
                         bytesPerRow:0
                        bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * y + destBytesPerPixel * (w-x-1);
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
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
