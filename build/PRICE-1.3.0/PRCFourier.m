//
//  PRCFourier.m
//  PRICE
//  Fourier Controller
//
//  Created by Riccardo Mottola on  Fri Nov 14 2008.
//  Copyright (c) 2008 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.


#import "PRCFourier.h"
#import "PRFourier.h"
#import "MyDocument.h"

@implementation PRCFourier

- (IBAction)transformImage:(id)sender
{
    PRFourier *filter;

    filter = [[PRFourier alloc] init];
    [[[NSDocumentController sharedDocumentController] currentDocument] runFilter:filter with:nil];
    [filter release];
}

@end
