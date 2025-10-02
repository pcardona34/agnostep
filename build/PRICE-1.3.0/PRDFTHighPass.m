//
//  PRDFTHighPass.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Oct 24 2003.
//  Copyright (c) 2003-2009 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRDFTHighPass.h"
#import "PRDFTFilter.h"
#import "FFT.h"
#include "math.h"

extern double *cosinus;
extern double *sinus;
extern unsigned int *bitRevIndex;

@implementation PRDFTHighPass

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
    return @"DFT High Pass";
}


- (PRImage *)transformImage:(PRImage *)srcImage :(BOOL)autoRange :(float) BPFreq :(float) BSFreq :(PRCProgress *)prPanel
{
    PRDFTFilter  *filter;
    double       **Fa, **Fb;
    unsigned int i, j;
    unsigned int w, h;
    unsigned int bitNum;
    unsigned int num;
    unsigned int halfNum;
    float        radius;
    PRImage      *destImage;
    
    progressSteps = 0;
    totalProgressSteps = 5;   
    progPanel = prPanel;
    
    
    /* get source image representation and associated information */
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
    Fb = (double**)calloc(num, sizeof(double*));
    for (i = 0; i < num; i++)
    {
        Fb[i] = (double*)calloc(num, sizeof(double));
        if (!Fb[i])
        {
            printf("out of memory allocating float matrix?\n");
            return srcImage;
        }
        memset(Fb[i], '\000', num);
    }
    
    /* calculate the filter */
    NSLog(@"BP %f, BS %f", BPFreq, BSFreq);
    /* top left quadrant */
    for (i = 0; i < halfNum; i++)
        for (j = 0; j < halfNum; j++)
        {
            radius = sqrt(i*i + j*j) / halfNum;
            if (radius > BPFreq)
            {
                Fa[i][j] = 1;
            } else if (radius > BSFreq)
            {
                Fa[i][j] = 0.5*(cos(M_PI*(BPFreq-radius)/(BPFreq-BSFreq))+1);
            }
        }

    /* top right quadrant */
    for (i = 0; i < halfNum; i++)
        for (j = 0; j < halfNum; j++)
            Fa[i][num - j - 1] = Fa[i][j];
    /* bottom left quadrant */
    for (i = 0; i < halfNum; i++)
        for (j = 0; j < halfNum; j++)
            Fa[num - i - 1][j] = Fa[i][j];
    /* bottom right quadrant */
    for (i = 0; i < halfNum; i++)
        for (j = 0; j < halfNum; j++)
            Fa[num - i - 1][num - j - 1] = Fa[i][j];
    
    if (progPanel != nil)
    {
        [self setActivity:@"run the filter"];
        [self advanceProgress];
    }

    /* instantiate the filter */
    filter = [[PRDFTFilter alloc] init];
    
    /* run it */
    destImage = [[filter filterImage :srcImage :Fa :Fb :num :autoRange :NULL] retain];
    
    /* release filter */
    [filter release];

    /* now we free our filter matrix */
    for (i = 0; i < num; i++)
        free(Fa[i]);
    free(Fa);
    for (i = 0; i < num; i++)
        free(Fb[i]);
    free(Fb);

    if (progPanel != nil)
    {
        [self setActivity:@"Done"];
        [self showProgress];
    }
    [destImage autorelease];
    return destImage;
}


@end
