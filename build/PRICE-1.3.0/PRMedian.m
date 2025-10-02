//
//  PRMedian.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Mar 25 2004.
//  Copyright (c) 2004-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRMedian.h"
#import "PRGrayscaleFilter.h"


@implementation PRMedian

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    enum medianForms form;
    int size;
    BOOL separable;
    
    /* interpret the parameters */
    form = [[parameters objectAtIndex:0] intValue];
    size = [[parameters objectAtIndex:1] intValue];
    separable = [[parameters objectAtIndex:2] boolValue];
    
    return [self medianImage:image :form :size :separable :progressPanel];
}

- (NSString *)actionName
{
    return @"Median";
}


- (PRImage *)medianImage :(PRImage *)srcImage :(enum medianForms)form :(int)size :(BOOL)separable :(PRCProgress *)prPanel
{
  NSBitmapImageRep *srcImageRep;
  PRImage          *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger        w, h;
  NSInteger        x, y;
  NSInteger        i, j;
  unsigned char    *srcData;
  unsigned char    *destData;
  unsigned char    *filterMask; /* the median window */
  int              realSize;    /* real width of the median window */
  int              c;           /* current channel */
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;    
    
    progressSteps = 0;
    totalProgressSteps = 2;
    progPanel = prPanel;
    
    realSize = size*2 + 1;
    
    /* get source image representation and associated information */
    if (progPanel != nil)
    {
        [self setActivity:@"Get image size"];
        [self advanceProgress];
    }
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;

    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:w
                              pixelsHigh:h
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:destSamplesPerPixel
                                hasAlpha:[srcImage hasAlpha]
                                isPlanar:NO
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:w*destSamplesPerPixel
                            bitsPerPixel:0];
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    if (progPanel != nil)
    {
        [self setActivity:@"Filter"];
        [self advanceProgress];
    }
    
    if (form == HORIZONTAL_F)
    {
        filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (realSize));
        if (filterMask == NULL)
            NSLog(@"Failed filterMask allocation in PRMedian");
        for (y = 0; y < h; y++)
        {
            for (x = 0 + size + 1; x < w - (size + 1); x++)
            {
                for (c = 0; c < destSamplesPerPixel; c++)
                {
                    for (i = 0; i < realSize; i++)
                        filterMask[i] = srcData[srcBytesPerRow*y + (x - size + i)*srcBytesPerPixel + c];
                    /* primitve sorting */
                    for (i = 0; i < realSize-1; i++)
                    {
                        for (j = 0; j < realSize-1-i; j++)
                        {
                            if (filterMask[j] > filterMask[j+1])
                            {
                                unsigned char temp;
                                temp = filterMask[j+1];
                                filterMask[j+1] = filterMask[j];
                                filterMask[j] = temp;
                            }
                        }
                    }
                    /* insert result in destination */
                    destData[destBytesPerRow*y + x*destBytesPerPixel + c] = filterMask[size];
                }
            }
        }
        free(filterMask);
    } else if (form == VERTICAL_F)
    {
        filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (realSize));
        for (x = 0; x < w; x++)
        {
            for (y = 0 + size + 1; y < h - (size + 1); y++)
            {
                for (c = 0; c < destSamplesPerPixel; c++)
                {
                    for (i = 0; i < realSize; i++)
                        filterMask[i] = srcData[(y - size + i) * srcBytesPerRow + x*srcBytesPerPixel + c];
                    /* primitve sorting */
                    for (i = 0; i < realSize-1; i++)
                    {
                        for (j = 0; j < realSize-1-i; j++)
                        {
                            if (filterMask[j] > filterMask[j+1])
                            {
                                unsigned char temp;
                                temp = filterMask[j+1];
                                filterMask[j+1] = filterMask[j];
                                filterMask[j] = temp;
                            }
                        }
                    }
                    /* insert result in destination */
                    destData[destBytesPerRow*y + x*destBytesPerPixel + c] = filterMask[size];
                }
            }
        }
        free(filterMask);
    } else if (form == CROSS_F)
    {
        if (separable)
        {
            unsigned char tempResult; /* to store the result between the separable passes */
            filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (realSize));
            for (x = 0 + size + 1; x < w - (size + 1); x++)
            {
                for (y = 0 + size + 1; y < h - (size + 1); y++)
                {
                    for (c = 0; c < destSamplesPerPixel; c++)
                    {
                        for (i = 0; i < realSize; i++)
                            filterMask[i] = srcData[y*srcBytesPerRow + (x - size + i)*srcBytesPerPixel + c];
                            
                        /* primitve sorting */
                        for (i = 0; i < realSize-1; i++)
                        {
                            for (j = 0; j < realSize-1-i; j++)
                            {
                                if (filterMask[j] > filterMask[j+1])
                                {
                                    unsigned char temp;
                                    temp = filterMask[j+1];
                                    filterMask[j+1] = filterMask[j];
                                    filterMask[j] = temp;
                                }
                            }
                        }
                        tempResult = filterMask[size];
                        for (i = 0; i < realSize; i++)
                            filterMask[i] = srcData[(y - size + i) * srcBytesPerRow + x*srcBytesPerPixel + c];
                        filterMask[size] = tempResult;
                        /* primitve sorting */
                        for (i = 0; i < realSize-1; i++)
                        {
                            for (j = 0; j < realSize-1-i; j++)
                            {
                                if (filterMask[j] > filterMask[j+1])
                                {
                                    unsigned char temp;
                                    temp = filterMask[j+1];
                                    filterMask[j+1] = filterMask[j];
                                    filterMask[j] = temp;
                                }
                            }
                        }
                        /* insert result in destination */
                        destData[destBytesPerRow*y + x*destBytesPerPixel + c] = filterMask[size];
                    }
                }
            }
            free(filterMask);
        } else /* not separable */
        {
            int totalSize; /* the total number of samples in the filter */
            int k;
            
            totalSize = 4 * size + 1;
            filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (totalSize));
            for (y = 0 + size + 1; y < h - (size + 1); y++)
            {
                for (x = 0 + size + 1; x < w - (size + 1); x++)
                {
                    for (c = 0; c < destSamplesPerPixel; c++)
                    {
                        k = 0;
                        for (i = 0; i < realSize; i++)
                            filterMask[k++] = srcData[y * srcBytesPerRow + (x - size + i)*srcBytesPerPixel + c];
                        for (i = 1; i <= size; i++)
                            filterMask[k++] = srcData[(y - i) * srcBytesPerRow + x*srcBytesPerPixel + c];
                        for (i = 1; i <= size; i++)
                            filterMask[k++] = srcData[(y + i) * srcBytesPerRow + x*srcBytesPerPixel + c];
                        
                        
                        /* primitve sorting */
                        for (i = 0; i < totalSize-1; i++)
                        {
                            for (j = 0; j < totalSize-1-i; j++)
                            {
                                if (filterMask[j] > filterMask[j+1])
                                {
                                    unsigned char temp;
                                    temp = filterMask[j+1];
                                    filterMask[j+1] = filterMask[j];
                                    filterMask[j] = temp;
                                }
                            }
                        }
                        /* insert result in destination */
                        destData[destBytesPerRow*y + x*destBytesPerPixel + c] = filterMask[2*size];
                    }
                }
            }
            free(filterMask);
        }
    }  else if (form == BOX_F)
    {
        if (separable)
        {
            int k;
            unsigned char *tempResult;
            
            filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (realSize));
            tempResult = (unsigned char *) malloc(sizeof(unsigned char) * (realSize));
            for (y = 0 + size + 1; y < h - (size + 1); y++)
            {
                for (x = 0 + size + 1; x < w - (size + 1); x++)
                {
                    for (c = 0; c < destSamplesPerPixel; c++)
                    {
                        for (i = 0; i < realSize; i++)
                        {
                            for (j = 0; j < realSize; j++)
                                filterMask[j] = srcData[(y - size + i) * srcBytesPerRow + (x - size + j)*srcBytesPerPixel + c];
                            
                            /* primitve sorting */
                            for (j = 0; j < realSize-1; j++)
                            {
                                for (k = 0; k < realSize-1-j; k++)
                                {
                                    if (filterMask[k] > filterMask[k+1])
                                    {
                                        unsigned char temp;
                                        temp = filterMask[k+1];
                                        filterMask[k+1] = filterMask[k];
                                        filterMask[k] = temp;
                                    }
                                }
                            }
                            /* insert result in destination */
                            tempResult[i] = filterMask[size];
                        }
    
                        
                        /* primitve sorting */
                        for (i = 0; i < realSize-1; i++)
                        {
                            for (j = 0; j < realSize-1-i; j++)
                            {
                                if (tempResult[j] > tempResult[j+1])
                                {
                                    unsigned char temp;
                                    temp = tempResult[j+1];
                                    tempResult[j+1] = tempResult[j];
                                    tempResult[j] = temp;
                                }
                            }
                        }
                        /* insert result in destination */
                        destData[destBytesPerRow*y + x*destBytesPerPixel + c] = tempResult[size];
                    }
                }
            }
            free(filterMask);
            free(tempResult);
        } else /* not separable */
        {
            int totalSize; /* the total number of samples in the filter */
            int k;
            
            totalSize = realSize*realSize;
            
            filterMask = (unsigned char *) malloc(sizeof(unsigned char) * (totalSize));
            for (y = 0 + size + 1; y < h - (size + 1); y++)
            {
                for (x = 0 + size + 1; x < w - (size + 1); x++)
                {
                    for (c = 0; c < destSamplesPerPixel; c++)
                    {
                        k = 0;
                        for (i = 0; i < realSize; i++)
                            for (j = 0; j < realSize; j++)
                                filterMask[k++] = srcData[(y - size + i) * srcBytesPerRow + (x - size + j)*srcBytesPerPixel + c];
    
                        /* primitve sorting */
                        for (i = 0; i < totalSize-1; i++)
                        {
                            for (j = 0; j < totalSize-1-i; j++)
                            {
                                if (filterMask[j] > filterMask[j+1])
                                {
                                    unsigned char temp;
                                    temp = filterMask[j+1];
                                    filterMask[j+1] = filterMask[j];
                                    filterMask[j] = temp;
                                }
                            }
                        }
                        
                        /* insert result in destination */
                        destData[destBytesPerRow*y + x*destBytesPerPixel + c] = filterMask[size*(realSize) + size]; /* center */
                    }
                }
            }
            free(filterMask);
        }
    } else
        NSLog(@"Unrecognized median filter type.");
    
    if (progPanel != nil)
    {
        [self setActivity:@"Done"];
        [self showProgress];
    }
    
    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}


@end
