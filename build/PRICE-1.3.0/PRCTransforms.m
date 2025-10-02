//
//  PRTransforms.m
//  PRICE
//
//  Created by Riccardo Mottola on Fri Nov 14 2008.
//  Copyright (c) 2002-2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#import "PRCTransforms.h"
#import "PRTransforms.h"
#import "MyDocument.h"


@implementation PRCTransforms

- (IBAction)transposeImage:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;

    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:TRANSPOSE],
        nil];

    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Transpose"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];
}

- (IBAction)rotateImage90:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:ROTATE90],
        nil];
    
    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Rotate 90"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];    
}

- (IBAction)rotateImage180:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:ROTATE180],
        nil];
    
    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Rotate 180"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];    
}

- (IBAction)rotateImage270:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:ROTATE270],
        nil];
    
    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Rotate 270"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];    
}

- (IBAction)flipImageVert:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:FLIP_VERT],
        nil];
    
    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Flip Vertical"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];    
}

- (IBAction)flipImageHoriz:(id)sender
{
    NSArray *parameters;
    PRTransforms *filter;
    
    /* encode parameters */
    parameters = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:FLIP_HORIZ],
        nil];
    
    filter = [[PRTransforms alloc] init];
    [filter setActionName:@"Flip Horizontal"];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:parameters];
    [filter release];    
}

- (void)setActionName:(NSString *)name
{
    actionName = name;
}

- (NSString *)actionName
{
    return actionName;
}

@end
