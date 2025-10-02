//
//  PRFourier.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Jan 24 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRFourier.h"
#import "PRGrayscaleFilter.h"
#include "FFT.h"

extern double *cosinus;
extern double *sinus;
extern unsigned int *bitRevIndex;

@implementation PRFourier

- (PRImage *)filterImage:(PRImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{

    /* interpret the parameters */

    return [self transformImage:image];
}

- (NSString *)actionName
{
    return @"FFT";
}

- (PRImage *)transformImage:(PRImage *)srcImage
{
    NSBitmapImageRep *srcImageRep;
    PRImage *destImage;
    NSBitmapImageRep *destImageRep;
    unsigned int w, h;
    unsigned int x, y; /* image scanning variables */
    unsigned int halfW, halfH; /* the middle */
    unsigned int i;    /* convolve matrix scanning */
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;
    int destSamplesPerPixel;
    NSInteger srcBytesPerRow;
    NSInteger srcBytesPerPixel;
    
    int num;
    unsigned int bitNum;
    double *Aa;
    double *Ab;
    double *ya;
    double *yb;
    double **Ma;   /* non quantized output */
    double **Mb;
    
    double min, max, scale;
    
    
    /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];

    w = [srcImage width];
    h = [srcImage height];
    
    if (w > h)
        bitNum = binaryLog(w);
    else
        bitNum = binaryLog(h);
    num = binpow(bitNum);
    NSAssert(num > 0, @"PRFourier. Internal error. num <= 0");

    /* find the center, maybe a better way is needed */
    halfW = (unsigned int) rint(w / 2);
    halfH = (unsigned int) rint(h / 2);
    
    sinus = (double*)calloc(num, sizeof(double));
    cosinus = (double*)calloc(num, sizeof(double));
    bitRevIndex = (unsigned int*)calloc(num, sizeof(unsigned int));
    initTrigonometrics(num, bitNum);
    
    Aa = (double*)calloc(num, sizeof(double));
    Ab = (double*)calloc(num, sizeof(double));
    ya = (double*)calloc(num, sizeof(double));
    yb = (double*)calloc(num, sizeof(double));
    
    
    if ([srcImage hasColor])
      {
        PRGrayscaleFilter *grayFilter;
        printf("Color image\n");
        grayFilter = [[PRGrayscaleFilter alloc] init];
        srcImage = [grayFilter filterImage:srcImage :METHOD_AVERAGE];
        [grayFilter release];

        srcImageRep = [srcImage bitmapRep];
      }
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    destSamplesPerPixel = 1;
        
    /* allocate float destination matrix */
    Ma = (double**)calloc(num, sizeof(double*));
    for (i = 0; i < num; i++)
    {
        Ma[i] = (double*)calloc(num, sizeof(double));
        if (!Ma[i])
        {
            printf("out of memory allocating float matrix?\n");
            return srcImage;
        }
        memset(Ma[i], '\000', num);
    }
    Mb = (double**)calloc(num, sizeof(double*));
    for (i = 0; i < num; i++)
    {
        Mb[i] = (double*)calloc(num, sizeof(double));
        if (!Mb[i])
        {
            printf("out of memory allocating float matrix?\n");
            return srcImage;
        }
        memset(Mb[i], '\000', num);
    }
    
    /* allocate destination image and its representation */
    destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:w
                    pixelsHigh:h
                    bitsPerSample:8
                    samplesPerPixel:destSamplesPerPixel
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSCalibratedWhiteColorSpace
                    bytesPerRow:w*destSamplesPerPixel
                    bitsPerPixel:0] ;
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    

    /* copy the image to the float matrix */
    for (y = 0; y < h; y++)
    {
        for (x = 0; x < w; x++)
        {
            p1 = srcData +  (y * srcBytesPerRow + x*srcBytesPerPixel);
            Ma[y][x] = (double) *p1 / UCHAR_MAX;
        }
    }
    /* replicate borders */
    if (w < num)
    {
        for (y = 0; y < h; y++)
        {
            for (x = w; x < num; x++)
            {
                p1 = srcData + (y * srcBytesPerRow + (srcBytesPerRow - (x*srcBytesPerPixel-srcBytesPerRow+1)));
                Ma[y][x] = (double) *p1 / UCHAR_MAX;
            }
        }
    }
    if (h < num)
    {
        for (y = h; y < num; y++)
        {
            for (x = 0; x < w; x++)
            {
                p1 = srcData + ((h - (y-h+1)) * srcBytesPerRow + x*srcBytesPerPixel);
                Ma[y][x] = (double) *p1 / UCHAR_MAX;
            }
        }
    }
    /* execute the actual filtering */
    /* horizontal pass */
    for (y = 0; y < num; y++)
    {
        for (i = 0; i < num; i++)
        {
            Aa[i] = Ma[y][i];
            Ab[i] = Mb[y][i];
        }
        fft(num, bitNum, Aa, Ab, ya, yb);
        for (i = 0; i < num; i++)
        {
            Ma[y][i] = ya[i];
            Mb[y][i] = yb[i];
        }
    }

    /* vertical pass */
    for (x = 0; x < num; x++)
    {
        for (i = 0; i < num; i++)
        {
            Aa[i] = Ma[i][x];
            Ab[i] = Mb[i][x];
        }
        fft(num, bitNum, Aa, Ab, ya, yb);
        for (i = 0; i < num; i++)
        {
            Ma[i][x] = ya[i];
            Mb[i][x] = yb[i];
        }
    }
    
    /* log of rised square modulus */
    for (y = 0; y < num; y++)
    {
        for (x = 0; x < num; x++)
        {
            double temp;
            temp = Ma[y][x]*Ma[y][x] + Mb[y][x]*Mb[y][x] + 1;
            if (temp <= 1)
                Ma[y][x] = 0;
            else
                Ma[y][x] = log(temp);
        }
    }

    /* now we find the range */
    min = DBL_MAX;
    max = DBL_MIN;
    y = 0;
    for (x = 1; x < w; x++)
    {
        if (Ma[y][x] > max)
            max = Ma[y][x];
        if (Ma[y][x] < min)
            min = Ma[y][x];
    }
    for (y = 1; y < h; y++)
    {
        for (x = 0; x < w; x++)
        {
            if (Ma[y][x] > max)
                max = Ma[y][x];
            if (Ma[y][x] < min)
                min = Ma[y][x];
        }
    }
    
    scale = fabs(max - min)/(double)UCHAR_MAX;
    printf ("min = %f, max = %f, scale = %f\n", min, max, scale);

    /* now we copy the result back, after scaling  */
    
    /* we recenter the FFT */
    /* top left */
    for (y = 0; y < halfH; y++)
    {
        p2 = destData + (y * w);
        for (x = 0; x < halfW; x++)
        {
            p2[x] = (unsigned char) rint((Ma[num-1-halfH+y][num-1-halfW+x]-min)/scale);
        }
    }
    /* top right */
    for (y = 0; y < halfH; y++)
    {
        p2 = destData + (y * w);
        for (x = halfW; x < w; x++)
        {
            p2[x] = (unsigned char) rint((Ma[num-1-halfH+y][x-halfW]-min)/scale);
        }
    }
    /* bottom left */
    for (y = halfH; y < h; y++)
    {
        p2 = destData + (y * w);
        for (x = 0; x < halfW; x++)
        {
            p2[x] = (unsigned char) rint((Ma[y-halfH][num-1-halfW+x]-min)/scale);
        }
    }
    /* bottom right */
    for (y = halfH; y < h; y++)
    {
        p2 = destData + (y * w);
        for (x = halfW; x < w; x++)
        {
            p2[x] = (unsigned char) rint((Ma[y-halfH][x-halfW]-min)/scale);
        }
    }

    [destImage setBitmapRep:destImageRep];
    [destImageRep release];

    /* now we free our float matrix */
    for (i = 0; i < num; i++)
        free(Ma[i]);
    free(Ma);
    for (i = 0; i < num; i++)
        free(Mb[i]);
    free(Mb);

    [destImage autorelease];
    return destImage;
}

- (BOOL)displayProgress
{
    return NO;
}



@end
