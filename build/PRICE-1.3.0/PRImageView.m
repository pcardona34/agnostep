//
//  PRImageView.m
//  PRICE
//
//  Created by Riccardo Mottola on Thu Dec 12 2002.
//  Copyright (c) 2002-2015 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRImageView.h"
#import "PRImage.h" // defines NSInteger


@implementation PRImageView

- (void)awakeFromNib
{
    NSMutableArray *dragTypes;
    
    /* init copy&paste */
    dragTypes = [NSMutableArray arrayWithObjects:NSColorPboardType, NSFilenamesPboardType, nil];
    [dragTypes addObjectsFromArray:[NSImage imagePasteboardTypes]];
    [self registerForDraggedTypes:dragTypes];
}

- (void)drawRect:(NSRect)rect
{
    if (![[NSGraphicsContext currentContext] isDrawingToScreen])
    {
        NSSize imageSize;
        NSRect finalRect;
        float scaleX, scaleY, scale;
        

        imageSize = [[self image] size];

        scaleX = rect.size.width / imageSize.width;
        scaleY = rect.size.height / imageSize.height;


        if (scaleX < scaleY)
            scale = scaleX;
        else
            scale = scaleY;

        finalRect = NSMakeRect(rect.origin.x, rect.origin.y, imageSize.width*scale, imageSize.height*scale);
            
        [[self image] drawInRect:finalRect  fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) operation:(NSCompositingOperation)NSCompositeCopy fraction:(float)1.0];
    } else
    {
        [super drawRect:rect];
    }
}

- (void)scaleFrameBy:(float)scale
{
    NSSize imageSize;
    NSAffineTransform *at;
    
    if (scaleFactor == scale)
      return;
    
    scaleFactor = scale;
    
    imageSize = [[self image] size];
    at = [NSAffineTransform transform];
    [at scaleBy:scale];
    
    [self setFrameSize:[at transformSize:imageSize]];
    [self setNeedsDisplay:YES];
}

/* We override setImage so we can invalidate and recalculate scaling.
   This is necesssary since scaleFrameBy is optimized not to recalculate if the same factor is given.
*/
- (void)setImage:(NSImage *)image
{
  float oldScaleFactor;
  
  [super setImage:image];
  
  oldScaleFactor = scaleFactor;
  scaleFactor = 0;
  [self scaleFrameBy:oldScaleFactor];
}

- (BOOL) knowsPageRange: (NSRangePointer) range
{
    range->location = 1;
    range->length = 1;

    return YES;
}


- (NSRect) rectForPage: (NSInteger) pageNumber
{
    NSPrintInfo *pi = [[[NSDocumentController sharedDocumentController] currentDocument] printInfo];
    return [pi imageablePageBounds];
}



-(void) dealloc
{
    [super dealloc];
}

@end
