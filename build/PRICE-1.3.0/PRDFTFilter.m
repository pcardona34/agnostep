//
//  PRDFTFilter.m
//  PRICE
//
//  Created by Riccardo Mottola on Tue Nov 18 2003.
//  Copyright (c) 2003-2014 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRDFTFilter.h"
#import "PRGrayscaleFilter.h"
#import "FFT.h"
#include <math.h>
#import "PRProgressAction.h"

extern double *cosinus;
extern double *sinus;
extern unsigned int *bitRevIndex;

@implementation PRDFTFilter

- (PRImage *)filterImage :(PRImage *)srcImage :(double **)filterMatRe :(double **)filterMatIm :(unsigned int) num :(BOOL)autoRange :(id)controller
/* perform a convolution between the source image and the filter given by the two matrices */
{
  NSBitmapImageRep *srcImageRep;
  PRImage *destImage;
  NSBitmapImageRep *destImageRep;
    
  unsigned int w, h;
  unsigned int x, y; /* image scanning variables */
  unsigned int i;    /* convolve matrix scanning */
  unsigned char *srcData;
  unsigned char *destData;
  NSInteger destSamplesPerPixel;
  NSInteger srcBytesPerRow;
  NSInteger srcBytesPerPixel;
    
  unsigned int leftBorder, topBorder;  /* borders to center the image */
  unsigned int rightBorder, bottomBorder;  
    
  unsigned int bitNum;
  double *Aa;
  double *Ab;
  double *ya;
  double *yb;
  double **Ma;   /* non quantized, float image */
  double **Mb;
    
  double min, max, scale;

  if (controller)
    {
      [controller setActivity:@"initialize FFT"];
      [controller advanceProgress];
    }
        
     /* get source image representation and associated information */
    srcImageRep = [srcImage bitmapRep];
    
    w = [srcImage width];
    h = [srcImage height];

    /* calculate back the bit number */
    NSAssert(num > 0, @"Internal error. num <= 0");
    bitNum = binaryLog(num);
    
    sinus = (double*)calloc(num, sizeof(double));
    cosinus = (double*)calloc(num, sizeof(double));
    bitRevIndex = (unsigned int*)calloc(num, sizeof(unsigned int));
    initTrigonometrics(num, bitNum);

    
    if (![srcImage hasColor])
      {
        PRGrayscaleFilter *grayFilter;
        printf("Color image\n");
        grayFilter = [[PRGrayscaleFilter alloc] init];
        srcImage = [grayFilter filterImage:srcImage :METHOD_AVERAGE];
        [grayFilter release];
        NSLog (@"done greyscale converting");
        /* we reget previous information that is no longer valid */
        /* get source image representation and associated information */
        srcImageRep = [srcImage bitmapRep];
      }
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    
    /* allocate 1-D FFT arrays */
    Aa = (double*)calloc(num, sizeof(double));
    Ab = (double*)calloc(num, sizeof(double));
    ya = (double*)calloc(num, sizeof(double));
    yb = (double*)calloc(num, sizeof(double));
    
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
    destSamplesPerPixel = 1;
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
                    bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    
    /* calculate borders */
    leftBorder = (num - w) / 2;
    topBorder = (num - h) / 2;
    rightBorder =  (num - w) - leftBorder;
    bottomBorder = (num - h) - topBorder;
    printf("top %d left %d\n", topBorder, leftBorder);
    
    /* copy the image to the float matrix */
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
            Ma[y + topBorder][x + leftBorder] = (double)srcData[y * srcBytesPerRow + x*srcBytesPerPixel] / UCHAR_MAX; /* the image is greyscale, no bit-depth displace */


    /* replicate borders */
    
    /* top */
    for (y = 0; y < topBorder; y++)
        for (x = 0; x < w; x++)
            Ma[y][x + leftBorder] = Ma[2*topBorder-y-1][x + leftBorder];

    /* bottom */
    for (y = 0; y < bottomBorder; y++)
        for (x = 0; x < w; x++)
            Ma[y+h+topBorder][x + leftBorder] = Ma[(h+topBorder)-y-1][x + leftBorder];

    if (leftBorder > 0)
    {
        /* top left */
        for (y = 0; y < topBorder; y++)
            for (x = 0; x < leftBorder; x++)
                Ma[y][x] = Ma[2*topBorder-y-1][2*leftBorder-x-1];
        /* left */
        for (y = 0; y < h; y++)
            for (x = 0; x < leftBorder; x++)
                Ma[y + topBorder][x] = Ma[y + topBorder][2*leftBorder-x-1];
        /* bottom left */
        for (y = 0; y < topBorder; y++)
            for (x = 0; x < leftBorder; x++)
                Ma[y+h+topBorder][x] = Ma[(h+topBorder)-y-1][2*leftBorder-x-1];
    }
    
    if (rightBorder > 0)
    {
        /* top right */
        for (y = 0; y < topBorder; y++)
            for (x = 0; x < rightBorder; x++)
                Ma[y][x+w+leftBorder] = Ma[2*topBorder-y-1][(w+leftBorder)-x-1];
        /* right */
        for (y = 0; y < h; y++)
            for (x = 0; x < rightBorder; x++)
                Ma[y + topBorder][x+w+leftBorder] = Ma[y + topBorder][(w+rightBorder)-x-1];
        /* bottom right */
        for (y = 0; y < bottomBorder; y++)
            for (x = 0; x < rightBorder; x++)
                Ma[y+h+topBorder][x+w+leftBorder] = Ma[(h+topBorder)-y-1][(w+rightBorder)-x-1];
    }

   
    
    /* execute the actual filtering */
    
    if (controller)
    {
        [controller setActivity:@"FFT forward pass"];
        [controller advanceProgress];
    }
    /* forward pass */
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

//    printf("Fa %f %f\n", filterMatRe[0][0], filterMatRe[30][30]);

    /* applying the transformation */
    if (filterMatIm) /* we have a filter with I part */
        for (x = 0; x < num; x++)
            for (y = 0; y < num; y++)
            {
                Ma[x][y] = Ma[x][y]*filterMatRe[x][y] - Mb[x][y]*filterMatIm[x][y];
                Mb[x][y] = Ma[x][y]*filterMatIm[x][y] + Mb[x][y]*filterMatRe[x][y];
            }
    else
        for (x = 0; x < num; x++)
            for (y = 0; y < num; y++)
            {
                Ma[x][y] = Ma[x][y]*filterMatRe[x][y];
                Mb[x][y] = Mb[x][y]*filterMatRe[x][y];
            }

    if (controller)
    {
        [controller setActivity:@"FFT reverse pass"];
        [controller advanceProgress];
    }
    /* reverse pass */
    /* horizontal pass */
    for (y = 0; y < num; y++)
    {
        for (i = 0; i < num; i++)
        {
            Aa[i] = Ma[y][i];
            Ab[i] = Mb[y][i];
        }
        ifft(num, bitNum, Aa, Ab, ya, yb);
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
        ifft(num, bitNum, Aa, Ab, ya, yb);
        for (i = 0; i < num; i++)
        {
            Ma[i][x] = ya[i];
            Mb[i][x] = yb[i];
        }
    }
    
    if (autoRange)
    {   /* AutoRange result */
        /* now we find the range */
        min = DBL_MAX;
        max = DBL_MIN;
        for (y = 0; y < h; y++)
        {
            for (x = 0; x < w; x++)
            {
                if (Ma[y+topBorder][x+leftBorder] > max)
                    max = Ma[y+topBorder][x+leftBorder];
                if (Ma[y+topBorder][x+leftBorder] < min)
                    min = Ma[y+topBorder][x+leftBorder];
            }
        }
        scale = fabs(max - min)/(double)UCHAR_MAX;
        printf ("min = %f, max = %f, scale = %f\n", min, max, scale);
        /* now we copy the result back, after scaling  */
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
                destData[y*w + x] = (unsigned char) rint((Ma[y+topBorder][x+leftBorder]-min)/scale);
    } else
    { /* just scale back the result */
        double sample;
        /* now we copy the result back, after clipping  */
        for (y = 0; y < h; y++)
            for (x = 0; x < w; x++)
            {
                sample = rint(Ma[y+topBorder][x+leftBorder]*UCHAR_MAX);
                if (sample > UCHAR_MAX)
                    sample = UCHAR_MAX;
                else if (sample < 0)
                    sample = 0;
                destData[y*w + x] = (unsigned char) sample;
            }
    }


    [destImage setBitmapRep:destImageRep];
    [destImageRep release];
    

    /* free up the 1-D arrays */
    free(Aa);
    free(Ab);
    free(ya);
    free(yb);

    /* now we free our float matrix */
    for (i = 0; i < num; i++)
        free(Ma[i]);
    free(Ma);
    for (i = 0; i < num; i++)
        free(Mb[i]);
    free(Mb);
    
    /* free other arrays */
    free(sinus);
    free(cosinus);
    free(bitRevIndex);
    
    if (controller)
    {
        [controller setActivity:@"FFT done"];
        [controller showProgress];
    }
    
    [destImage autorelease];
    return destImage;
}

@end
