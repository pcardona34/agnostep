//
//  MyDocument.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2015 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "MyDocument.h"
#include <limits.h>

#import "PRGrayscaleFilter.h"
#import "PRInvert.h"
#import "PRConvolve55.h"
#import "PRTransforms.h"
#import "PRFourier.h"
#import "PRDFTLowPass.h"
#import "PRDFTHighPass.h"
#import "PREqualize.h"
#import "PRTraceEdges.h"
#import "PRCustTraceEdges.h"
#import "PRMedian.h"
#import "PRScale.h"
#import "PRCrop.h"
#import "PRBriCon.h"
#import "PRCurves.h"


/* changeSaveType is an undocument API call, not exported in AppKit headers */
@interface NSDocument(Hidden)
- (void)changeSaveType:(id)sender;
@end


@implementation MyDocument


- (NSData *)dataRepresentationOfType:(NSString *)aType
{
  NSData *dataOfRep;
  NSDictionary *repProperties;

  dataOfRep = nil;
  if ([aType isEqualToString:@"TIFF"] || [aType isEqualToString:@"public.tiff"])
    {
      NSLog(@"data representation of type TIFF");
      repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSTIFFCompressionLZW] forKey:NSImageCompressionMethod];
      dataOfRep = [[activeImage bitmapRep] representationUsingType: NSTIFFFileType properties:repProperties];
    }
  else if ([aType isEqualToString:@"JPEG"]  || [aType isEqualToString:@"public.jpeg"])
    {
      float level;

      level = [windowController compressionLevel];
      NSLog(@"data representation of type JPEG, %f", level);
      repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:level] forKey:NSImageCompressionFactor];
      dataOfRep = [[activeImage bitmapRep] representationUsingType: NSJPEGFileType properties:repProperties];
    }
    return dataOfRep;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
  PRImage *tempImage;
    
  tempImage = [[PRImage alloc] initWithData:data];
  if (tempImage != nil)
    {
      NSBitmapImageRep *tmpImageRep;
      BOOL convertColorSpace;
      BOOL convertPlanar;
      NSMutableDictionary *imgProps;

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
      /* since 10.4 we have different Alpha format position, let's convert it */
      tmpImageRep = [tempImage bitmapRep];
      if ([tmpImageRep bitmapFormat] != 0)
        {
          NSInteger x, y;
          NSInteger w, h;
          BOOL alphaFirst;
          BOOL nonPremultipliedA;
          BOOL floatingPoint;
          PRImage *destImage;
          NSBitmapImageRep *destImageRep;
          NSInteger           srcBytesPerRow;
          NSInteger           destBytesPerRow;
          NSInteger           srcBytesPerPixel;
          NSInteger           destBytesPerPixel;
          

          NSLog(@"We have a non-standard format, let's try to convert it");
          alphaFirst = [tmpImageRep bitmapFormat] & NSAlphaFirstBitmapFormat;
          nonPremultipliedA = [tmpImageRep bitmapFormat] & NSAlphaNonpremultipliedBitmapFormat;
          floatingPoint = [tmpImageRep bitmapFormat] & NSFloatingPointSamplesBitmapFormat;
          if ([tmpImageRep bitsPerSample] == 8)
            {
              unsigned char    *srcData;
              unsigned char    *destData;
              unsigned char    *p1;
              unsigned char    *p2;

              /* swap Alpha is hopefully only for chunky images */
              if (alphaFirst)
                {
                  imgProps = [[NSMutableDictionary alloc] init];
                  [imgProps setValue:[tmpImageRep valueForProperty:NSImageCompressionMethod] forKey:NSImageCompressionMethod];
                  [imgProps setValue:[tmpImageRep valueForProperty:NSImageCompressionFactor] forKey:NSImageCompressionFactor];
                  [imgProps setValue:[tmpImageRep valueForProperty:NSImageEXIFData] forKey:NSImageEXIFData];

                  w = [tmpImageRep pixelsWide];
                  h = [tmpImageRep pixelsHigh];

                  srcBytesPerRow = [tmpImageRep bytesPerRow];
                  srcBytesPerPixel = [tmpImageRep bitsPerPixel] / 8;
                  destImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
                  destImageRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                                pixelsWide:w
                                                pixelsHigh:h
                                             bitsPerSample:8
                                           samplesPerPixel:[tmpImageRep samplesPerPixel]
                                                  hasAlpha:[tmpImageRep hasAlpha]
                                                  isPlanar:NO
                                            colorSpaceName:[tmpImageRep colorSpaceName]
                                               bytesPerRow:0
                                              bitsPerPixel:0];
                  
                  destBytesPerRow = [destImageRep bytesPerRow];
                  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
                  srcData = [tmpImageRep bitmapData];
                  destData = [destImageRep bitmapData];
                  if (![tempImage hasColor])
                    {
                      for (y = 0; y < h; y++)
                        for (x = 0; x < w; x++)
                          {
                            p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
                            p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
                            p2[0] = p1[1];
                            p2[1] = p1[0];
                          }
                    }
                  else
                    {
                      for (y = 0; y < h; y++)
                        for (x = 0; x < w; x++)
                          {
                            p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
                            p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
                            p2[0] = p1[1];
                            p2[1] = p1[2];
                            p2[2] = p1[3];
                            p2[3] = p1[0];
                          }
                    }
                  [destImageRep setProperty:NSImageEXIFData withValue:[imgProps objectForKey:NSImageEXIFData]];
                  [destImage setBitmapRep:destImageRep];
                  [destImageRep release];
                  [tempImage release];
                  tempImage = destImage;
                  [imgProps release];
                }
            }
          else /* for 16 bit */
            {
            }
        }
#endif /* Image format conversion */

      /* if the loaded image is in BlackColorSpace we convert it to WhiteColorSpace */
      /* which is the only TIFF rep used internally and generated by PRICE */
      /* we also need to convert Planar images into a meshed configuration */
      tmpImageRep = [tempImage bitmapRep];

      imgProps = [[NSMutableDictionary alloc] init];
      [imgProps setValue:[tmpImageRep valueForProperty:NSImageCompressionMethod] forKey:NSImageCompressionMethod];
      [imgProps setValue:[tmpImageRep valueForProperty:NSImageCompressionFactor] forKey:NSImageCompressionFactor];
      [imgProps setValue:[tmpImageRep valueForProperty:NSImageEXIFData] forKey:NSImageEXIFData];

        
      NSLog(@"Properties: %@", imgProps);
      convertColorSpace = [[tmpImageRep colorSpaceName] isEqualToString: NSCalibratedBlackColorSpace] || [[tmpImageRep colorSpaceName] isEqualToString: NSDeviceBlackColorSpace];
      convertPlanar = [tmpImageRep isPlanar];
      
      if (convertColorSpace || convertPlanar)
        {
          unsigned char *dataPtr;
          unsigned char *dataPtr2;
          NSInteger k;
          NSInteger w, h;
          PRImage *newImage;
          NSBitmapImageRep *newImageRep;
          NSInteger destSamplesPerPixel;

          
          NSLog(@"Converting color space");
          w = [tmpImageRep pixelsWide];
          h = [tmpImageRep pixelsHigh];
          destSamplesPerPixel = [tmpImageRep samplesPerPixel];
          /* converting the colorspace */
          newImage = [[PRImage alloc] initWithSize:NSMakeSize(w, h)];
          newImageRep = [[NSBitmapImageRep alloc]
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
          dataPtr = [tmpImageRep bitmapData];
          dataPtr2 = [newImageRep bitmapData];
          if (convertPlanar)
            {
              NSInteger x, y;
              NSInteger xp;
              if (convertColorSpace)
                {
                  for (y = 0; y < h; y++)
                    {
                      xp = 0;
                      for (x = 0; x < w*3; x += 3)
                        {
                          dataPtr2[y*(w*3) + x] = UCHAR_MAX - dataPtr[y*w + x];
                          dataPtr2[y*(w*3) + x + 1] = UCHAR_MAX - dataPtr[y*w*2 + x];
                          dataPtr2[y*(w*3) + x + 2] = UCHAR_MAX - dataPtr[y*w*3 + x];
                          xp++;
                        }
                    }                            
                }
              else
                {
                  for (y = 0; y < h; y++)
                    {
                      xp = 0;
                      for (x = 0; x < w*3; x += 3)
                        {
                          dataPtr2[y*(w*3) + x] = dataPtr[y*w + x];
                          dataPtr2[y*(w*3) + x + 1] = dataPtr[y*w*2 + x];
                          dataPtr2[y*(w*3) + x + 2] = dataPtr[y*w*3 + x];
                          xp++;
                        }
                    }
                }
            }
          else
            {
              if (convertColorSpace)
                {
                  NSInteger s;
                  
                  s = w * h;
                  for (k = 0; k < s; k++)
                    *dataPtr2++ = UCHAR_MAX - *dataPtr++;
                } else
                {
                  /* shall never happen */
                  NSLog(@"Internal error: tried to convert image when it wasn't necessary");
                }                
            }
          // FIXME: should we remove the color space from the EXIF data?
          [newImageRep setColorSpaceName:NSCalibratedWhiteColorSpace];
          [newImageRep setProperty:NSImageEXIFData withValue:[imgProps objectForKey:NSImageEXIFData]];
          [newImage setBitmapRep:newImageRep];
          [newImageRep release];
          [tempImage release];
          tempImage = newImage;
        }
      [imgProps release];
    }

    oldImage = nil;
    /* returns a bool to be able to know if loading was successul */
    if (tempImage != nil)
    {
        /* we setActiveImage won't set the image info yet (why?)  */
        [self setActiveImage:tempImage];
        [tempImage release];
        return YES;
    } else
        return NO;
}


- (void)makeWindowControllers
/* instantiate PRWindowController */
{
    windowController = [[PRWindowController alloc] initWithWindowNibName:@"PRWindow"];
    [self addWindowController:windowController];
    
    /* set undo levels */
    [[self undoManager] setLevelsOfUndo:1];
}

- (NSWindow *)window
{
    return [windowController window];
}

- (NSView *)view
{
    return [windowController view];
}

- (PRImage *)activeImage
/* method to access the active image */
{
    return activeImage;
}

- (void)setActiveImage: (PRImage *)theImage
/* method to set the active image */
{
    if (activeImage != nil)
        [activeImage release];

    activeImage = [theImage retain];
    NSLog(@"set active, per pixel: %d %d", [[activeImage bitmapRep] bitsPerSample], [[activeImage bitmapRep] bitsPerPixel]);

    /* window controller is still nil here the first time we load an image
     * thus the info must be manually set after the nib finished loading */
    [windowController setImageToDraw:activeImage];
}

- (void)copy:(id)sender
{
    NSPasteboard *pboard;

    pboard = [NSPasteboard generalPasteboard];

    [pboard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
    [pboard setData:[activeImage TIFFRepresentation] forType:NSTIFFPboardType];
}

- (void)paste:(id)sender
{
    NSUndoManager *uMgr;
    NSPasteboard  *pboard;
    NSString      *type;
    NSData        *tempData;
    PRImage       *tempImage;

    pboard = [NSPasteboard generalPasteboard];
    type = [pboard availableTypeFromArray:[NSArray arrayWithObjects:NSTIFFPboardType, nil]];

    if (type != nil)
    {
        if ([type isEqualToString:NSTIFFPboardType])
        {
            /* get the clipboard data */
            tempData = [pboard dataForType:NSTIFFPboardType];
            if (tempData != nil)
            {
                uMgr = [self undoManager];
                /* save the method on the undo stack */
                [[uMgr prepareWithInvocationTarget: self] restoreLastImage];
                [uMgr setActionName:@"Paste"];

                /* save the current image */
                [self saveCurrentImage];

                tempImage = [[PRImage alloc] initWithData:tempData];
                [self setActiveImage: tempImage];
                [tempImage release];
                [[windowController view] setFrameSize:[activeImage size]];
                [[windowController view] setNeedsDisplay:YES];
            } else
            {
                /* guidelines say I should put a panel */
                /* #### fixme */
                NSLog(@"something went wrong in paste");
            }
        } else
            NSLog(@"received a paste of unhandled type: %@", type);
    }
}

- (void)runFilter:(PRFilter *)filter with:(NSArray *)parameters
{
    NSUndoManager *uMgr;
    PRCProgress   *filterProgr;
    NSMutableDictionary *imgProps;
    id tempVal;
    NSLog(@"before running filter, per pixel: %d %d", [[activeImage bitmapRep] bitsPerSample], [[activeImage bitmapRep] bitsPerPixel]);

    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastImage];
    [uMgr setActionName:[filter actionName]];
    
    filterProgr = nil;
    if ([filter displayProgress])
    {
        filterProgr = [[PRCProgress alloc] init];
        [filterProgr showProgress:self];
        [filterProgr setTitle: [filter actionName]];
    }
    
    /* save the current image */
    [self saveCurrentImage];
    
    /* save image properties */
    imgProps = [[NSMutableDictionary alloc] init];
    tempVal = [[activeImage bitmapRep] valueForProperty:NSImageCompressionMethod];
    if (tempVal)
      [imgProps setObject:tempVal forKey:NSImageCompressionMethod];
    tempVal = [[activeImage bitmapRep] valueForProperty:NSImageCompressionFactor];
    if (tempVal)
      [imgProps setObject:tempVal forKey:NSImageCompressionFactor];
    tempVal = [[activeImage bitmapRep] valueForProperty:NSImageEXIFData];
    if (tempVal)
      [imgProps setObject:tempVal forKey:NSImageEXIFData];
    NSLog(@"beforeFilter: %@", [[activeImage bitmapRep] valueForProperty:NSImageEXIFData]);

    /* instantiate and run the filter */
    [self setActiveImage: [filter filterImage: activeImage with:parameters progressPanel:filterProgr]];
    
    /* reset image properties */
    if ([imgProps objectForKey:NSImageEXIFData] != nil)
      {
        NSMutableDictionary *exifDict;

        exifDict = [NSMutableDictionary dictionaryWithDictionary:[imgProps objectForKey:NSImageEXIFData]];
        NSLog(@"we have EXIF Data: %@", exifDict);
        if ([exifDict objectForKey:@"PixelXDimension"])
          {
            NSNumber *w = [NSNumber numberWithInt:[activeImage width]];
            [exifDict setObject:w forKey:@"PixelXDimension"];
          }
        if ([exifDict objectForKey:@"PixelYDimension"])
          {
            NSNumber *w = [NSNumber numberWithInt:[activeImage height]];
            [exifDict setObject:w forKey:@"PixelYDimension"];
          }
        NSLog(@"New EXIF Data: %@", exifDict);
        [imgProps setObject:exifDict forKey:NSImageEXIFData];
      }
    [[activeImage bitmapRep] setProperty:NSImageEXIFData withValue:[imgProps objectForKey:NSImageEXIFData]];
    [imgProps release];
    NSLog(@"afterFilter: %@", [[activeImage bitmapRep] valueForProperty:NSImageEXIFData]);

    [filterProgr release];
    
    /* reset the selected zoom ration, this will also cause a view update */
    [windowController scaleFromMenu:nil];
}

- (void)restoreLastImage
{
    PRImage *tempImage;
    
    tempImage = [activeImage copy];
    [self setActiveImage: oldImage];
    [oldImage release];
    oldImage = tempImage;
    [[[self undoManager] prepareWithInvocationTarget: self] restoreLastImage];
    
    [windowController scaleFromMenu:nil];
}

- (void)saveCurrentImage
{
    if (activeImage != nil)
    {
        if (oldImage != nil)
            [oldImage release];
      NSLog(@"save active, per pixel: %d %d", [[activeImage bitmapRep] bitsPerSample], [[activeImage bitmapRep] bitsPerPixel]);
        oldImage = [activeImage copy];
        NSLog(@"saved, per pixel: %d %d", [[oldImage bitmapRep] bitsPerSample], [[oldImage bitmapRep] bitsPerPixel]);

    }
}

- (void)dealloc
{
    [activeImage release];
    [windowController release];
    [super dealloc];
}


- (void)setPrintInfo:(NSPrintInfo *)anObject
{
    if (printInfo != anObject)
    {
        [printInfo autorelease];
        printInfo = [anObject copyWithZone:[self zone]];
    }
}

- (NSPrintInfo *)printInfo
{
    if (printInfo == nil)
    {
        [self setPrintInfo:[NSPrintInfo sharedPrintInfo]];
        [printInfo setHorizontallyCentered:YES];
        [printInfo setVerticallyCentered:YES];
        [printInfo setLeftMargin:5.0];
        [printInfo setRightMargin:5.0];
        [printInfo setTopMargin:5.0];
        [printInfo setBottomMargin:5.0];
    }
    return printInfo;
}


- (void)printShowingPrintPanel:(BOOL)showPanels
{
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:[windowController view] printInfo:[self printInfo]];
    [op setShowPanels:showPanels];
    [op runOperationModalForWindow:[self window] delegate:nil didRunSelector:NULL contextInfo:NULL];
}

/* file panel methods */

/* undocumented API call which works fine for our purpose to intercept
   the change of the filetype and update the view information accordingly */
- (void)changeSaveType:(id)sender
{
  NSLog(@"MyDocument changeSaveType");
  [super changeSaveType:sender];
  
  [windowController changeSaveType:sender];
}


/* we override this for GNUstep */
#if defined(GNUSTEP_GUI_VERSION) && GNU_GNUSTEP_GUI_MAJOR_VERSION == 0 && GNUSTEP_GUI_MINOR_VERSION <= 22
- (NSInteger) runModalSavePanel: (NSSavePanel*)savePanel withAccessoryView: (NSView*)accessoryView

{
  NSLog(@"runModalSavePanel: withAccessoryView. We should see this only on GS gui <= 0.22");
  [windowController prepareSavePanel: savePanel];
  [windowController setWritableFileTypes:[MyDocument writableTypes]];
  [windowController setCompressionType:[self fileType]];

  /* we finally call super, but reget the accessory view since we changed it */
  return [super runModalSavePanel:savePanel withAccessoryView:[savePanel accessoryView]];
}
#endif

/* we override this for Cocoa */
- (BOOL) prepareSavePanel:(NSSavePanel *) panel
{
  BOOL r;

  r = [windowController prepareSavePanel: panel];
  [windowController setWritableFileTypes:[MyDocument writableTypes]];
  [windowController setCompressionType:[self fileType]];
  return r;
}

@end
