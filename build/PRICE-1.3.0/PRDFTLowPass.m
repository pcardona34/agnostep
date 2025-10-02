//
//  PRDFTLowPass.m
//  PRICE
//
//  Created by Riccardo Mottola on Sat Sep 13 2003.
//  Copyright (c) 2003-2009 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRDFTLowPass.h"
#import "PRDFTFilter.h"
#import "FFT.h"
#include "math.h"

@implementation PRDFTLowPass

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    BOOL autoRange;
    float bandPassFreq;
    float bandStopFreq;
    
    autoRange = [[parameters objectAtIndex:0] boolValue];
    bandPassFreq = [[parameters objectAtIndex:1] floatValue];
    bandStopFreq = [[parameters objectAtIndex:2] floatValue];
    return [self transformImage:image :autoRange :bandPassFreq :bandStopFreq :progressPanel];
}

- (NSString *)actionName
{
    return @"DFT Low Pass";
}

- (PRImage *)transformImage:(PRImage *)srcImage :(BOOL)autoRange :(float) BPFreq :(float) BSFreq :(PRCProgress *)prPanel
{
    PRDFTFilter  *filter;
    double       **Fa;
    unsigned int i, j;
    unsigned int w, h;
    unsigned int bitNum;
    unsigned int num;
    unsigned int halfNum;
    PRImage      *destImage;
    float        radius;

    progressSteps = 0;
    totalProgressSteps = 5;   
    progPanel = prPanel;
    
    /* get source image associated information */
    if (progPanel != nil)
    {
        [self setActivity:@"Get image size"];
        [self advanceProgress];
    }
    w = [srcImage width];
    h = [srcImage height];

    /* we set the image square to the nearest power of two on the longer side */
    if (w > h)
        bitNum = binaryLog(w);
    else
        bitNum = binaryLog(h);
    num = binpow(bitNum);
    
    /* calculate the half comprising the zero */
    halfNum = (num >> 1);
    NSLog(@"halfNum %d", halfNum);
    
    /* allocate filter  matrix */
    Fa = (double**)calloc(num, sizeof(double*));
    for (i = 0; i < num; i++)
    {
        Fa[i] = (double*)calloc(num, sizeof(double));
        if (!Fa[i])
        {
            printf("out of memory allocating float matrix?\n");
            return srcImage;
        }
        memset(Fa[i], '\000', num);
    }
    
    /* calculate the filter */
    NSLog(@"BP %f, BS %f", BPFreq, BSFreq);
    /* top left quadrant */
    for (i = 0; i <= halfNum; i++)
        for (j = 0; j <= halfNum; j++)
        {
            radius = sqrt(i*i + j*j) / halfNum;
            if (radius < BPFreq)
            {
                Fa[i][j] = 1;
            } else if (radius < BSFreq)
            {
                Fa[i][j] = 0.5*(cos(M_PI*(radius-BPFreq)/(BSFreq-BPFreq))+1);
            }
        }

    /* top right quadrant */
    for (i = 0; i < halfNum; i++)
        for (j = 0; j < halfNum-1; j++)
            Fa[i][num - j - 1] = Fa[i][j];
    /* bottom left quadrant */
    for (i = 0; i < halfNum-1; i++)
        for (j = 0; j < halfNum; j++)
            Fa[num - i - 1][j] = Fa[i][j];
    /* bottom right quadrant */
    for (i = 0; i < halfNum-1; i++)
        for (j = 0; j < halfNum-1; j++)
            Fa[num - i - 1][num - j - 1] = Fa[i][j];


    if (progPanel != nil)
    {
        [self setActivity:@"run the filter"];
        [self advanceProgress];
    }
    
    /* instantiate the filter */
    filter = [[PRDFTFilter alloc] init];
    
    /* run it */
    destImage = [[filter filterImage :srcImage :Fa :NULL :num :autoRange :self] retain];

    /* release filter */
    [filter release];
        
    /* now we free our filter matrix */
    for (i = 0; i < num; i++)
        free(Fa[i]);
    free(Fa);

    if (progPanel != nil)
    {
        [self setActivity:@"Done"];
        [self showProgress];
    }
    [destImage autorelease];
    return destImage;
}


@end
